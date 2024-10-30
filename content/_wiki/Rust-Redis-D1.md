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

## Rust-Redis-D1 
---

### 0. PreRequisite
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

