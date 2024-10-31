---
title: Rust-Redis-D2
summary: 
date: 2024-10-31 19:26:52 +0900
lastmod: 2024-10-31 19:26:52 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 1. Code
---

```rust
use regex::Regex;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::RwLock;
use tokio::task;

type Db = Arc<RwLock<HashMap<String, String>>>;

enum Command {
    PING,
    ECHO(String),
    GET(String),
    SET(String, String),
}

impl Command {
    fn parse_message(message: &str) -> Result<Command, String> {
        let re_ping = Regex::new(r"^\*1\r\n\$4\r\nPING\r\n$").unwrap();
        let re_echo = Regex::new(r"^\*2\r\n\$4\r\nECHO\r\n\$(\d+)\r\n(.+)\r\n$").unwrap();
        let re_get = Regex::new(r"^\*2\r\n\$3\r\nGET\r\n\$(\d+)\r\n(.+)\r\n$").unwrap();
        let re_set = Regex::new(r"^\*3\r\n\$3\r\nSET\r\n\$(\d+)\r\n(.+)\r\n\$(\d+)\r\n(.+)\r\n$").unwrap();

        if re_ping.is_match(message) {
            Ok(Command::PING)
        } else if let Some(captures) = re_echo.captures(message) {
            let length: usize = captures[1].parse().unwrap_or(0);
            let echo_message = &captures[2];

            if echo_message.len() == length {
                Ok(Command::ECHO(echo_message.to_string()))
            } else {
                Err("Invalid ECHO command format: length mismatch".to_string())
            }
        } else if let Some(captures) = re_get.captures(message) {
            let key = captures[2].to_string();
            Ok(Command::GET(key))
        } else if let Some(captures) = re_set.captures(message) {
            let key = captures[2].to_string();
            let value = captures[4].to_string();
            Ok(Command::SET(key, value))
        } else {
            Err("Unknown command".to_string())
        }
    }

    async fn handle_command(&self, stream: &mut TcpStream, db: Db) -> std::io::Result<()> {
        let response = self.execute(db).await;
        stream.write_all(response.as_bytes()).await?;
        Ok(())
    }

    async fn execute(&self, db: Db) -> String {
        match self {
            Command::PING => "+PONG\r\n".to_string(),
            Command::ECHO(echo_message) => format!("${}\r\n{}\r\n", echo_message.len(), echo_message),
            Command::GET(key) => Self::execute_get(&key, db).await,
            Command::SET(key, value) => Self::execute_set(key, value, db).await,
        }
    }

    async fn execute_get(key: &String, db: Db) -> String {
        match db.read().await.get(key) {
            Some(value) => format!("${}\r\n{}\r\n", value.len(), value),
            None => "$-1\r\n".to_string()
        }
    }

    async fn execute_set(key: &String, value: &String, db: Db) -> String {
        db.write().await.insert(key.clone(), value.clone());
        "+OK\r\n".to_string()
    }
}

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();
    let db = Arc::new(RwLock::new(HashMap::new()));

    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                let db_clone = Arc::clone(&db);
                task::spawn(async move {
                    handle_client(stream, db_clone).await;
                });
            }
            Err(e) => {
                println!("Error accepting connection : {}", e);
            }
        }
    }
}

async fn handle_client(mut stream: TcpStream, db: Db) {
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
                        if let Err(e) = command.handle_command(&mut stream, Arc::clone(&db)).await {
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

```

## 2. Review
1. 정말 간단한 리팩토링을 진행했다, 정말 보기 싫은 것들만 정리했고, 모듈 분리는 일단 계속 해보다가 할 것 같다.(포스팅 하기 편하고, 사이트에서 리뷰받기가 수월한 것 같다)
2. Tokio의 `RwLock`을 사용했는데, 이것은 `Mutex`와 비슷하지만 읽기 전용 락을 여러 스레드가 가질 수 있다.
3. 그리고 SET, GET을 추가했다. 
4. 명령을 파싱하는 부분이 정규식 쓰는것도 그렇고 너무 마음에 안들고 더럽다, 레디스 프로토콜이 있다는걸 생각하면 좋은 방법이 있을것같아서 생각해봐야겠다.
  - 생각해본 절차는 명령어를 먼저 뽑고, 그 다음을 프로토콜대로 파싱하면 key-val 혹은 match하는 구조로 만들 수 있을 것 같다.
  - 일단 빨리 프로토콜을 봐야지..
