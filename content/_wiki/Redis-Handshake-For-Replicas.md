---
title: 레디스 HandShake중 이슈 처리하기😬
summary: 레디스 레플리카를 등록하는 과정 중 replconf, psync를 처리하는 중 발생한 문제.
date: 2024-11-23 15:52:17 +0900
lastmod: 2024-11-23 15:52:17 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---


레디스 레플리케이션을 위한 handshake는 간단하게 아래와 같은 순서로 이루어진다.

1. slave가 마스터에 `PING` 호출 -> `PONG`
2. slave가 마스터에 `REPLCONF` -> `+OK\r\n` : 포트정보 등을 인자로 전달하여 알려줌(ex. `REPLCONF listening-port 6380`)
3. 몇차례의 `REPLCONF` 반복
4. `PSYNC` -> `+FULLRESYNC <REPL_ID> 0\r\n`


그리고 간단하게, 지금까지 나의 레디스 ReplicationConfig의 구조는 아래와 같다.

```rust
#[derive(Clone)]
pub struct ReplicationConfig {
    role: Arc<RwLock<String>>,
    master_host: Arc<RwLock<Option<String>>>,
    master_port: Arc<RwLock<Option<u16>>>,
    master_replid: Arc<RwLock<String>>,
    master_repl_offset: Arc<RwLock<u64>>,
    slaves: Arc<RwLock<Vec<SlaveInfo>>>,
}

#[derive(Clone, Debug)]
pub struct SlaveInfo {
    pub addr: SocketAddr,
    pub offset: i64,
}

impl ReplicationConfig {
    pub fn new() -> Self {
        let replid = Self::generate_replication_id();
        Self {
            role: Arc::new(RwLock::new("master".to_string())),
            master_host: Arc::new(RwLock::new(None)),
            master_port: Arc::new(RwLock::new(None)),
            master_replid: Arc::new(RwLock::new(replid)),
            master_repl_offset: Arc::new(RwLock::new(0)),
            slaves: Arc::new(RwLock::new(Vec::new())),
        }
    }
    
    ...(중략)
```

그리고 주요한 메서드는 아래와 같다.

```rust
impl ReplicationConfig {

    ...(중략)
     pub async fn register_slave(&self, addr: SocketAddr) {
        let mut slaves = self.slaves.write().await;
        if !slaves.iter().any(|slave| slave.addr == addr) {
            slaves.push(SlaveInfo {
                addr,
                offset: 0,
            });
            println!("Slave registered: {:?}", addr);
        }
    }

    pub async fn update_slave_offset(&self, addr: SocketAddr, offset: i64) {
        let mut slaves = self.slaves.write().await;
        if let Some(slave) = slaves.iter_mut().find(|slave| slave.addr == addr) {
            slave.offset = offset;
        }
    }


    pub async fn update_slave_state(&self, addr: SocketAddr, offset: i64) {
        let mut slaves = self.slaves.write().await;
        if let Some(slave) = slaves.iter_mut().find(|slave| slave.addr == addr) {
            slave.offset = offset;
        }
    }

    pub async fn list_slaves(&self) -> Vec<SlaveInfo> {
        let slaves = self.slaves.read().await.clone();
        println!("Current slaves: {:?}", slaves);
        slaves
    }
}

```
마지막으로, 실제 커맨드를 실행시키는 부분은 아래와 같다.

```rust 
pub async fn execute_replconf(
        args: &Vec<String>,
        peer_addr: SocketAddr,
        replication_config: ReplicationConfig,
    ) -> String {
        println!("peer_addr on replconf : {:?}", peer_addr);
        if args[0] == "listening-port" {
            if let Ok(port) = args[1].parse::<u16>() {
                let addr = SocketAddr::new(peer_addr.ip(), port);
                replication_config.register_slave(addr).await;
                return format!("{}OK{}", SIMPLE_STRING_PREFIX, CRLF);
            }
        } else if args[0] == "capa" {
            return format!("{}OK{}", SIMPLE_STRING_PREFIX, CRLF);
        }

        format!("-ERR Invalid REPLCONF arguments{}", CRLF)
    }

    async fn execute_psync(
        args: &Vec<String>,
        replication_config: ReplicationConfig,
        peer_addr: SocketAddr,
    ) -> Vec<CommandResponse> {
        println!("peer_addr on psync : {:?}", peer_addr);
        let slaves = replication_config.list_slaves().await;
        println!("Slaves during PSYNC: {:?}", slaves);
        if !slaves.iter().any(|slave| slave.addr == peer_addr) {
            println!(
                "-ERR Slave not registered: {}:{}{}",
                peer_addr.ip(),
                peer_addr.port(),
                CRLF
            );
            return vec![CommandResponse::Simple(format!(
                "-ERR Slave not registered: {}:{}{}",
                peer_addr.ip(),
                peer_addr.port(),
                CRLF
            ))];
        }

        let master_repl_id = replication_config.get_repl_id().await;

        let requested_offset: i64 = args
            .get(1)
            .and_then(|offset| offset.parse::<i64>().ok())
            .unwrap_or(-1);

        let master_offset = 0;

        if requested_offset == -1 || requested_offset < master_offset {
            let full_resync_response = format!(
                "{}FULLRESYNC {} {}{}",
                SIMPLE_STRING_PREFIX, master_repl_id, master_offset, CRLF
            );

            // TODO : give real rdb file if needed
            const EMPTY_RDB_FILE: &[u8] = &[
                0x52, 0x45, 0x44, 0x49, 0x53, 0x30, 0x30, 0x30, 0x39,
                0xFF,
            ];

            vec![
                CommandResponse::Simple(full_resync_response),
                CommandResponse::Bulk(EMPTY_RDB_FILE.to_vec()),
            ]
        } else {
            vec![CommandResponse::Simple(format!(
                "{}CONTINUE{}",
                SIMPLE_STRING_PREFIX, CRLF
            ))]
        }
    }

```

즉 replconf으로 온 요청을 식볋해서, slave 목록을 저장하고, psync 요청때 해당 slave의 offset을 활성화 하는 방식으로 관리했다.

그 과정에서 스트림에서 직접 ip와 port를 받아오는 걸로 처리를 했는데 (psync에는 slave에 대한 식별값이나, 호스트 관련 정보를 전달하지 않음)

문제는 테스트 케이스에서 replconf를 등록한 요청과, 실제 스트림에서 추출한 peer_addr정보가 다르다는 것 이었다.

디버그 로그
```bash
[tester::#ZN8] Running tests for Stage #ZN8 (Replication - Single-replica propagation)
[tester::#ZN8] $ ./your_program.sh --port 6379
[your_program] Configuration loaded.
[your_program] Listening on port 6379
[tester::#ZN8] [handshake] replica: $ redis-cli PING
[your_program] Received message: "*1\r\n$4\r\nPING\r\n"
[tester::#ZN8] [handshake] Received "PONG"
[tester::#ZN8] [handshake] replica: > REPLCONF listening-port 6380
[your_program] Received message: "*3\r\n$8\r\nREPLCONF\r\n$14\r\nlistening-port\r\n$4\r\n6380\r\n"
[your_program] peer_addr on replconf : 127.0.0.1:38364
[your_program] Slave registered: 127.0.0.1:6380
[tester::#ZN8] [handshake] Received "OK"
[tester::#ZN8] [handshake] replica: > REPLCONF capa psync2
[your_program] Received message: "*3\r\n$8\r\nREPLCONF\r\n$4\r\ncapa\r\n$6\r\npsync2\r\n"
[your_program] peer_addr on replconf : 127.0.0.1:38364
[tester::#ZN8] [handshake] Received "OK"
[tester::#ZN8] [handshake] replica: > PSYNC ? -1
[tester::#ZN8] Expected simple string or bulk string, got ERROR
[tester::#ZN8] Test failed (try setting 'debug: true' in your codecrafters.yml to see more details)
[your_program] Received message: "*3\r\n$5\r\nPSYNC\r\n$1\r\n?\r\n$2\r\n-1\r\n"
[your_program] peer_addr on psync : 127.0.0.1:38364
[your_program] Current slaves: [SlaveInfo { addr: 127.0.0.1:6380, offset: 0 }]
[your_program] Slaves during PSYNC: [SlaveInfo { addr: 127.0.0.1:6380, offset: 0 }]
[your_program] -ERR Slave not registered: 127.0.0.1:38364
[your_program] 

```
그래서 실제로 레디스 관련 자료를 찾아봤는데, 딱히 도움이되는 내용은 없었다.

일반적으로 docs는 slave기준으로 내려주는 커맨드에 대한 설명만 자세하게 나와있다.[redis-docs](https://redis.io/docs/latest/commands/psync/)

그래서 직접 소스코드를 보는 수 밖에 없었다.

먼저 `replication.c` 의 `void syncCommand(client *c)`를 보면 이처럼 이미 식별값을 가지고 있다.
```c
if (c->flags & CLIENT_SLAVE) return;
```

그리고 여기가 해당 식별값을 설정하는 부분이고, 사실상 client 인스턴스에 식별값이 다 있다고 생각이 됐다.
```c
void replicationCreateSlave(client *c) {
    c->flags |= CLIENT_SLAVE;
    c->replstate = SLAVE_STATE_WAIT_BGSAVE_START;
    listAddNodeTail(server.slaves, c);
}
```
그리고 여기가 `REPLCONF`, `SYNC/PSYNC` 같은 커맨드에서 호출되는건 확인하긴 했는데.. 그 클라이언트 초기화 하는 부분은 직접 찾기 너무 귀찮아서 gpt에게 물어봤다.

```c
void acceptCommonHandler(connection *conn, int flags, char *ip) {
    client *c = createClient(conn); // 새 클라이언트 생성
    if (c == NULL) {
        serverLog(LL_WARNING, "Error creating client");
        return;
    }

    if (connPeerToString(conn, c->ip, sizeof(c->ip), &c->port) == -1) {
        serverLog(LL_WARNING, "Error identifying peer address");
        freeClient(c);
        return;
    }

    serverLog(LL_VERBOSE, "Accepted %s:%d", c->ip, c->port);
}
```

그래서 찾은건 여기 코드고 클라이언트의 peer_addr을 스트림에서 추출하는것과 동일하다고 가정하면,
클라이언트에 대한 식별은 ip(replconf 커맨드로 바뀔 수 있는 호스트는 제외)라고 생각되어 수정했다.


## 결론
---
1. 어렵다.
2. 힘들다.
3. 생각보다 codecrafters의 설명이 자세하진 않다.
4. 클라이언트로 추상화 미리 해둬야 하나?
