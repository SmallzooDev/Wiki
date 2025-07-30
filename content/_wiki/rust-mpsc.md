---
title: 러스트의 mpsc 🤔
summary: 
date: 2024-11-26 11:03:50 +0900
lastmod: 2025-07-30 16:23:26 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## mpsc란?
---

> Rust의 mpsc 채널은 "여러 생산자 (Multiple Producer)"와 "하나의 소비자 (Single Consumer)"로 메시지를 보내고 처리 할 수 있는
> 비동기 도구이다. 아이디어도 아이디어지만, 기본적으로 설계와 동작이 Rust의 소유권과 동시성 모델에 기반을 두고 있다.

기본적인 사용 방식은 아래와 같다.

`mpsc::channel`
- tx (생산자), rx(소비자) 를 반환받는다.

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    // 채널 생성 (버퍼 크기: 32)
    let (tx, mut rx) = mpsc::channel(32);

    // 생산자 (Producer)
    tokio::spawn(async move {
        for i in 1..=5 {
            // tx.send()로 채널에 메세지를 보낸다.
            if let Err(_) = tx.send(format!("Message {}", i)).await {
                println!("Receiver dropped");
                return;
            }
            println!("Sent: Message {}", i);
        }
    });

    // 소비자 (Consumer) : rx.recv()로 수신한 메세지를 처리한다.
    while let Some(message) = rx.recv().await {
        println!("Received: {}", message);
    }
}
```

```bash
Sent: Message 1
Received: Message 1
Sent: Message 2
Received: Message 2
...
```

`Sender`의 복제
- tx에는 `clone()`이 구현되어 있어, 여러 생산자를 복제할 수 있다.

```rust
use tokio::sync::mpsc;

#[tokio::main]
async fn main() {
    let (tx, mut rx) = mpsc::channel(32);

    // Sender를 복제
    let tx1 = tx.clone();
    let tx2 = tx.clone();

    // 첫 번째 생산자
    tokio::spawn(async move {
        tx1.send("From Producer 1").await.unwrap();
    });

    // 두 번째 생산자
    tokio::spawn(async move {
        tx2.send("From Producer 2").await.unwrap();
    });

    // 소비자
    while let Some(message) = rx.recv().await {
        println!("Received: {}", message);
    }
}
```

```bash
Received: From Producer 1
Received: From Producer 2
```

- 그 외에도 버퍼의 크기를 설정할 수 있고, 버퍼가 가득 차면 send 호출이 블록상태가 된다.(즉 컨슈머의 처리 속도가 걱정된다면, 적당한 버퍼의 크기로 조절 할 수 있다.)
- 또한 루프의 상태를 보고 send를 하거나 대기를 하는것도 send, try_send와 같은 메서드들로 구분 할 수 있다.

그리고 매우 일반적인 방법인 것 같은데, 버퍼의 크기를 조절하기도 하지만 큐 자체를 나눠서 분배 할 수 도 있다.

```rust
let (client_tx, mut client_rx) = tokio::sync::mpsc::channel::<RedisEvent>(32);
let (replication_tx, mut replication_rx) = tokio::sync::mpsc::channel::<RedisEvent>(32);

tokio::spawn(async move {
    while let Some(event) = client_rx.recv().await {
        // 클라이언트 요청 처리
    }
});

tokio::spawn(async move {
    while let Some(event) = replication_rx.recv().await {
        // 레플리케이션 작업 처리
    }
});
```

## mpsc의 장점
---

- 스레드 간 안전한 데이터 교환
  - mpsc 채널은 잘 설계하면 Rust의 소유권과 동시성 모델에 기반을 두고 있어, 생산자와 소비자가 다른 스레드에서 동작해도 데이터 경합 없이 안전하다.
  - 심지어 내부적으로 Arc나 Mutex없이 설계되어 고성능을 보장한다고 한다.
- 생산자 확장성
  - mpsc의 Sender를 클론하여 여러 생산자를 생성 할 수 있다.
- 작업 디커플링
  - 구조대로 작성한다면, 생산자와 소비자는 서로 독립적으로 동작한다.
  - 생산자는 메세지를 보내놓고, 다음 작업으로 넘어갈 수 있고 소비자는 큐에서 데이터를 꺼내 처리 할 뿐이다.
- 백프레셔 관리
  - mpsc는 버퍼링기능을 자체적으로 지원하고, 관련한 인터페이스도 잘 빠져있다.
  - 버퍼가 가득 차는 정도, 소비자의 처리속도를 고려해서 사용자가 유동적으로 조절 할 수 있고
  - 반대로 여러 소비자를 둬서 분배를 할 수 있다.

## 결론
---

1. 이상적으로 잘 설계만 한다면 멀티스레드의 장점과 (이벤트루프 기반의)싱글스레드 프로그램의 장점을 동시에 취할 수 있을 것 같다.
2. 아마도 락같은 경합 자원들을 컨슈머쪽에 몰빵하는 구조가 될 것 같은데, 이와 같은 기반으로 설계를 처음부터 잘 하고 들어가야 사용 할 수 있을 것 같다.
