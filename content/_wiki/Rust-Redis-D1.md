---
title: Rust-Redis-D1
summary: 
date: 2024-10-30 20:28:17 +0900
lastmod: 2024-10-30 20:28:17 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 0. PreRequisite
---
> 해당 문서의 참고입니다! https://app.codecrafters.io/concepts/rust-tcp-server
- `std::net` 모듈은 TCP 서버를 만들기 위한 모듈이다.
- 그리고 아래의 다섯가지 메셔드를 주요하게 이용한다.
1. `TcpListener::bind` : `pub fn bind<A: ToSocketAddrs>(addr: A) -> Result<TcpListener>` - 주어진 주소에 바인딩된 새로운 `TcpListener` 인스턴스를 반환한다
2. `TcpListener::incoming` : `pub fn incoming(&self) -> Incoming` - 이 리스너로 들어오는 coneection에 대한 iterator를 반환한다.
3. `TcpStream::connect` : `pub fn connect<A: ToSocketAddrs>(addr: A) -> Result<TcpStream>` - 주어진 주소로 연결된 새로운 `TcpStream` 인스턴스를 반환한다.
4. `TcpStream::read` : `pub fn read(&mut self, buf: &mut [u8]) -> Result<usize>` - 스트림에서 데이터를 읽어서 주어진 버퍼에 저장한다.
5. `TcpStream::write_all` : `pub fn write_all(&mut self, buf: &[u8]) -> Result<()>` - 스트림에 주어진 버퍼의 모든 데이터를 쓴다.

TcpLister Struct는 아래와 같이 구성되어 있다.
```rust
impl TcpListener {
    // accept는 대기 중인 연결을 수락하고, connection을 반환한다.
    pub fn accept(&self) -> Result<(TcpStream, SocketAddr)>;
    // incoming은 이 listener로 들어오는 connection에 대한 iterator를 반환한다.
    pub fn incoming(&self) -> Incoming<TcpStream>;
    // local_addr는 이 listener가 바인딩된 주소를 반환한다.
    pub fn local_addr(&self) -> Result<SocketAddr>;
}
```

TcpStream Struct는 아래와 같이 구성되어 있다.
```rust
impl TcpStream {
    pub fn read(&mut self, buf: &mut [u8]) -> Result<usize>;
    pub fn write(&mut self, buf: &[u8]) -> Result<usize>;
    pub fn write_all(&mut self, buf: &[u8]) -> Result<()>;
}
```

참고하자면, write_all은 아래처럼 버퍼의 모든 데이터를 쓰는걸 보장해주기 때문에, 간단하게 사용할 수 있다.
```rust
fn write_all(&mut self, mut buf: &[u8]) -> io::Result<()> {
    while !buf.is_empty() {
        match self.write(buf) {
            Ok(0) => {
                return Err(io::Error::new(
                    io::ErrorKind::WriteZero,
                    "failed to write whole buffer",
                ));
            }
            Ok(n) => buf = &buf[n..],
            Err(ref e) if e.kind() == io::ErrorKind::Interrupted => {}
            Err(e) => return Err(e),
        }
    }
    Ok(())
}
```

```rust
fn handle_client(mut stream: TcpStream) {
    let mut buffer = [0; 512];
    loop {
        let byte_read = stream.read(&mut buffer).expect("Failed to read");
        if byte_read == 0 {
            return;
        }
        stream.write_all(&buffer[0..byte_read]).expect("Feil to write");
    }
}

fn main() {
    let listener = TcpListener::bind("localhost:8080").expect("Could not bind");
    for stream in listener.incoming() {
        match stream {
            Ok(stream) => {
                handle_client(stream);
            }
            Err(e) => {
                eprintln!("Failed: {}", e);
            }
        }
    } 
}
```
> 참고 : 한번에 하나의 커넥션만 처리가 가능하고, 다른 커넥션은 blocked된다.

## 1. Day 1 Code
---
> Day 1에서는 기본적인 TcbServer 바인딩과, 메세지를 읽어서 다시 클라이언트에게 보내는 기능을 구현한다.


```rust

use regex::Regex;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::task;

enum Command {
    PING,
    ECHO(String),
}

#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();
    loop {
        match listener.accept().await {
            Ok((stream, _)) => {
                task::spawn(async move {
                    handle_client(stream).await;
                });
            }
            Err(e) => {
                println!("Error accepting connection : {}", e);
            }
        }
    }
}

async fn handle_client(mut stream: TcpStream) {
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
                match parse_message(message) {
                    Ok(command) => {
                        if let Err(e) = handle_command(command, &mut stream).await {
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

fn parse_message(message: &str) -> Result<Command, String> {
    let re_ping = Regex::new(r"^\*1\r\n\$4\r\nPING\r\n$").unwrap();
    let re_echo = Regex::new(r"^\*2\r\n\$4\r\nECHO\r\n\$(\d+)\r\n(.+)\r\n$").unwrap();

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
    } else {
        Err("Unknown command".to_string())
    }
}

async fn handle_command(command: Command, stream: &mut TcpStream) -> std::io::Result<()> {
    match command {
        Command::PING => {
            stream.write_all(b"+PONG\r\n").await?;
        }
        Command::ECHO(echo_message) => {
            let response_message = format!("${}\r\n{}\r\n", echo_message.len(), echo_message);
            stream.write_all(response_message.as_bytes()).await?;
        }
    }
    Ok(())
}
```
## 2. Day 1 Review
---

### Trouble Shooting 

1. 먼저 tokio를 써도 되는지 모르고, std::net으로 비동기와 이벤트루프를 구현하려고 했다. 중간에 이게 맞나 싶어서 정답지를 봤는데, 다른사람들은 그냥 tokio 쓰더라..
2. 정규식은 어렵고 귀찮다 + 레디스 프로토콜을 모르고 비비려다가 더 고생했고, 정규식 부분은 그냥 검색해서 긁어왔다.

