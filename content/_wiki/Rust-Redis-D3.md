---
title: Build Redis With Rust 🦀
summary: 
date: 2024-11-02 17:20:03 +0900
lastmod: 2024-11-02 17:20:03 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## Day 3 코드
---

`command.rs`
```rust
use crate::{Config, Db, ValueEntry};
use tokio::io::AsyncWriteExt;
use tokio::net::TcpStream;

pub enum Command {
    PING,
    ECHO(String),
    GET(String),
    SET { key: String, value: String, px: Option<u64>, ex: Option<u64> },
    CONFIG(ConfigCommand),
}

pub enum ConfigCommand {
    GET(String),
}

impl Command {
    pub fn parse_message(message: &str) -> Result<Command, String> {
        let mut lines = message.lines();
        let first_line = lines.next().ok_or("Argument Error : Empty message")?;

        if first_line.starts_with('*') {
            let num_args: usize = first_line[1..].parse().map_err(|_| "Invalid array size")?;
            let mut args = Vec::new();

            for _ in 0..num_args {
                let bulk_len_line = lines.next().ok_or("Missing bulk length")?;
                if !bulk_len_line.starts_with('$') {
                    return Err("Invalid bulk string format".into());
                }
                let bulk_len: usize = bulk_len_line[1..].parse().map_err(|_| "Invalid bulk length")?;
                let bulk_string = lines.next().ok_or("Missing bulk string")?;

                if bulk_string.len() != bulk_len {
                    return Err("Bulk string length mismatch".into());
                }
                args.push(bulk_string.to_string());
            }

            if let Some(command_name) = args.get(0).map(|s| s.as_str()) {
                match command_name {
                    "PING" => Command::parse_ping(&args),
                    "ECHO" => Command::parse_echo(&args),
                    "GET" => Command::parse_get(&args),
                    "SET" => Command::parse_set(&args),
                    "CONFIG" => Command::parse_config(&args),
                    _ => Err(format!("Unknown command: {}", command_name)),
                }
            } else {
                Err("Empty command".into())
            }
        } else {
            Err("Unsupported protocol type".into())
        }
    }

    pub async fn handle_command(&self, stream: &mut TcpStream, db: Db, config: Config) -> std::io::Result<()> {
        let response = self.execute(db, config).await;
        stream.write_all(response.as_bytes()).await?;
        Ok(())
    }

    pub async fn execute(&self, db: Db, config: Config) -> String {
        match self {
            Command::PING => "+PONG\r\n".to_string(),
            Command::ECHO(echo_message) => format!("${}\r\n{}\r\n", echo_message.len(), echo_message),
            Command::GET(key) => Self::execute_get(&key, db).await,
            Command::SET { key, value, ex, px } => Self::execute_set(key, value, *ex, *px, db).await,
            Command::CONFIG(command) => Self::execute_config(command, config).await,
        }
    }

    async fn execute_get(key: &String, db: Db) -> String {
        match db.read().await.get(key) {
            Some(value_entry) => {
                if value_entry.is_expired() {
                    "$-1\r\n".to_string()
                } else {
                    format!("${}\r\n{}\r\n", value_entry.value.len(), value_entry.value.clone())
                }
            }
            None => "$-1\r\n".to_string(),
        }
    }

    async fn execute_set(key: &String, value: &String, ex: Option<u64>, px: Option<u64>, db: Db) -> String {
        db.write().await.insert(key.clone(), ValueEntry::new(value.clone(), ex, px));
        "+OK\r\n".to_string()
    }

    async fn execute_config(command: &ConfigCommand, config: Config) -> String {
        match command {
            ConfigCommand::GET(key) => {
                match config.read().await.get(key.as_str()) {
                    Some(value) => {
                        format!("*2\r\n${}\r\n{}\r\n${}\r\n{}\r\n", key.len(), key, value.len(), value)
                    }
                    None => "$-1\r\n".to_string(),
                }
            }
        }
    }

    fn parse_ping(args: &[String]) -> Result<Command, String> {
        if !(args.len() == 1) {
            return Err("Argument Error : PING command takes no arguments".into());
        }
        Ok(Command::PING)
    }


    fn parse_echo(args: &[String]) -> Result<Command, String> {
        if !(args.len() == 2) {
            return Err("Argument Error : ECHO command takes only one argument".into());
        }
        Ok(Command::ECHO(args[1].clone()))
    }

    fn parse_get(args: &[String]) -> Result<Command, String> {
        if !(args.len() == 2) {
            return Err("Argument Error : GET command takes only one argument".into());
        }
        Ok(Command::GET(args[1].clone()))
    }

    fn parse_set(args: &[String]) -> Result<Command, String> {
        if args.len() < 3 {
            return Err("Argument Error : SET requires at least key value argument".into());
        }

        let key = args[1].clone();
        let value = args[2].clone();
        let mut ex = None;
        let mut px = None;

        let mut arg_index = 3;
        while arg_index < args.len() {
            match args[arg_index].to_uppercase().as_str() {
                "PX" => {
                    if arg_index + 1 < args.len() {
                        px = Some(args[arg_index + 1].parse::<u64>().map_err(|_| "Argument Error : Invalid px value")?);
                        arg_index += 2;
                    } else {
                        return Err("Argument Error : Px option argument err".into());
                    }
                }
                "EX" => {
                    if arg_index + 1 < args.len() {
                        ex = Some(args[arg_index + 1].parse::<u64>().map_err(|_| "Argument Error : Invalid ex value")?);
                        arg_index += 2;
                    } else {
                        return Err("Argument Error : Ex option argument err".into());
                    }
                }
                _ => return Err(format!("Argument Error: {} unknown option", args[arg_index]))
            }
        }

        Ok(Command::SET { key, value, ex, px })
    }

    fn parse_config(args: &[String]) -> Result<Command, String> {
        match args[1].to_uppercase().as_str() {
            "GET" => {
                Ok(Command::CONFIG(ConfigCommand::GET(args[2].clone())))
            }
            _ => Err("Argument Error : Unsupported CONFIG subcommand!".into()),
        }
    }
}
```

`handler.rs`
```rust
use crate::command::Command;
use crate::{Config, Db};
use std::sync::Arc;
use tokio::io::AsyncReadExt;
use tokio::net::TcpStream;

pub async fn handle_client(mut stream: TcpStream, db: Db, config: Config) {
    let mut buffer = [0; 512];
    loop {
        buffer.fill(0);
        match stream.read(&mut buffer).await {
            Ok(0) => break,
            Ok(n) => {
                let message = match std::str::from_utf8(&buffer[..n]) {
                    Ok(msg) => msg,
                    Err(_) => {
                        println!("Failed to parse message as UTF-8");
                        continue;
                    }
                };

                println!("Received message: {:?}", message);
                match Command::parse_message(message) {
                    Ok(command) => {
                        if let Err(e) = command.handle_command(&mut stream, Arc::clone(&db), Arc::clone(&config)).await {
                            println!("Failed to send response: {}", e);
                        }
                    }
                    Err(e) => {
                        println!("Failed to parse command: {}", e);
                    }
                }
            }
            Err(e) => {
                println!("Error reading from stream: {}", e);
                break;
            }
        }
    }
}

pub async fn handle_env(args: Vec<String>, config: Config) -> Result<(), String> {
    if args.len() <= 1 {
        println!("No configuration arguments provided. Using default settings.");
        return Ok(());
    }

    let mut dir: Option<String> = None;
    let mut path_name: Option<String> = None;
    let mut arg_index = 1;

    while arg_index < args.len() {
        match args[arg_index].as_str() {
            "--dir" => {
                if arg_index + 1 < args.len() {
                    dir = Some(args[arg_index + 1].clone());
                    arg_index += 2;
                } else {
                    return Err("Argument Error: --dir option requires an argument".into());
                }
            }
            "--dbfilename" => {
                if arg_index + 1 < args.len() {
                    path_name = Some(args[arg_index + 1].clone());
                    arg_index += 2;
                } else {
                    return Err("Argument Error: --dbfilename option requires an argument".into());
                }
            }
            _ => return Err(format!("Argument Error: '{}' is an unknown option", args[arg_index])),
        }
    }

    match (dir, path_name) {
        (Some(dir), Some(path_name)) => {
            let mut config_guard = config.write().await;
            config_guard.insert("dir".to_string(), dir);
            config_guard.insert("dbfilename".to_string(), path_name);
            println!("Environment configuration applied.");
        }
        (None, None) => {
            println!("No configuration arguments provided. Using default settings.");
        }
        _ => {
            return Err("Argument Error: Both --dir and --dbfilename must be provided together.".into());
        }
    }

    Ok(())
}
```
`value_entry.rs`
```rust
use std::time::{Duration, Instant};

#[derive(Clone)]
pub struct ValueEntry {
    pub(crate) value: String,
    expiration: Option<Instant>,
}

impl ValueEntry {
    pub fn new(value: String, ex: Option<u64>, px: Option<u64>) -> ValueEntry {
        let expiration = match (px, ex) {
            (Some(ms), _) => Some(Instant::now() + Duration::from_millis(ms)),
            (_, Some(s)) => Some(Instant::now() + Duration::from_secs(s)),
            _ => None,
        };
        ValueEntry { value, expiration }
    }

    pub fn is_expired(&self) -> bool {
        if let Some(expiration) = self.expiration {
            Instant::now() > expiration
        } else {
            false
        }
    }
}
```

`main.rs`
```rust
mod command;
mod value_entry;
mod handler;

use crate::handler::{handle_client, handle_env};
use crate::value_entry::ValueEntry;
use std::collections::HashMap;
use std::env;
use std::sync::Arc;
use tokio::net::TcpListener;
use tokio::sync::RwLock;
use tokio::task;

type Db = Arc<RwLock<HashMap<String, ValueEntry>>>;
type Config = Arc<RwLock<HashMap<String, String>>>;


#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();
    let db = Arc::new(RwLock::new(HashMap::new()));
    let config = Arc::new(RwLock::new(HashMap::new()));
    let args: Vec<String> = env::args().collect();

    if let Err(e) = handle_env(args.clone(), Arc::clone(&config)).await {
        eprintln!("Failed to handle environment configuration: {}", e);
        return;
    }

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let db_clone = Arc::clone(&db);
                let config_clone = Arc::clone(&config);
                task::spawn(async move {
                    handle_client(stream, db_clone, config_clone).await;
                });
            }
            Err(e) => {
                println!("Error accepting connection : {}", e);
            }
        }
    }
}


```


## Day 3 정리
- 최소한의 리팩토링을 하려고 했다. 정규식 부분을 싹 걷어내고, 일부 모듈을 분리했다.
- 작성하고 보니 Command쪽이 계속 비대해지고, parser 부분 로직이 충분히 분리할 수 있을 것 같다.
- enum을 조금 더 예쁘게 표현 할 수 있을 것 같다. (구조는 마음에 드는데 들고 다니는 데이터가 만족스럽지 않다.)
- 서브커맨드들이 많아지면 지금의 구조가 구릴 것 같다
- 특히 인덱스를 전진시키며 파싱하는 부분은 조금 더 잘 추상화해면 빼둘 수 있을 것 같다.
