---
title: mpsc refactoring review 🦀
summary: 
date: 2024-11-28 18:23:06 +0900
lastmod: 2024-11-28 18:23:06 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---


```rust
#[tokio::main]
async fn main() {
    // 1. 필요한 설정, 데이터 등을 세팅함.
    let state = StateManager::new();
    let config_handler = ConfigHandler::new(state.get_db(), state.get_config(), state.get_replication_config());

    config_handler.load_config().await;
    config_handler.configure_db().await;
    config_handler.configure_replication().await;

    let port = config_handler.get_port().await;
    let listener = TcpListener::bind(format!("127.0.0.1:{}", port)).await.unwrap();

    println!("Listening on port {}", port);

    loop {
        match listener.accept().await {
            // 2. 스트림을 따서, 스트림을 handle_client로 전달
            Ok((stream, _)) => {
                let db = state.get_db();
                let config = state.get_config();
                let replication_config = state.get_replication_config();
                task::spawn(async move {
                    // 3. 딱 봐도 알 수 있겠지만, 일단 경합자원이고 뭐고 다 넘겨버린다.
                    handle_client(stream, db, config, replication_config).await;
                });
            }
            Err(e) => {
                println!("Error accepting connection: {}", e);
            }
        }
    }
}

// === 이하 handler.rs ===
pub async fn handle_client(mut stream: TcpStream, db: Db, config: Config, replication_config: ReplicationConfig) {
    let mut buffer = [0; 512];
    loop {
        buffer.fill(0);
        // 1. (직접 받아온 스트림에서) 버퍼로 요청 메세지를 읽는다.
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
                // 2. 메세지를 파싱해서, Command 객체를 (정확히는 enum)을 만들어준다.
                match CommandParser::parse_message(message) {
                    Ok(command) => {
                        // 3. 커맨드를 실행하는, 메서드는 다음과 같이 경합자원들을 물고 들어간다(stream, db, 등등...)
                        if let Err(e) = command.handle_command(&mut stream, Arc::clone(&db), Arc::clone(&config), replication_config.clone()).await {
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


// === 이하 command.rs ===
 pub async fn handle_command(
        &self,
        stream: &mut TcpStream,
        db: Db,
        config: Config,
        replication_config: ReplicationConfig,
    ) -> std::io::Result<()> {
        let peer_addr = match stream.peer_addr() {
            Ok(addr) => addr,
            Err(_) => {
                let err_response = "-ERR Failed to retrieve client address\r\n".to_string();
                stream.write_all(err_response.as_bytes()).await?;
                return Ok(());
            }
        };

        // 1. 커맨드에서 받아온 처리 응답 결과를 경합자원인 stream에 직접 쓰는 문제.
        match self.execute(db, config, replication_config, peer_addr).await {
            Ok(responses) => {
                for response in responses {
                    match response {
                        CommandResponse::Simple(response) => {
                            stream.write_all(response.as_bytes()).await?;
                        }
                        CommandResponse::Bulk(data) => {
                            let header = format!("${}{}", data.len(), CRLF);
                            stream.write_all(header.as_bytes()).await?;
                            stream.write_all(&data).await?;
                        }
                        CommandResponse::EndStream => break,
                    }
                }
            }
            Err(e) => {
                let err_response = format!("-ERR {}\r\n", e);
                stream.write_all(err_response.as_bytes()).await?;
            }
        }

        Ok(())
    }
    pub async fn execute(
        &self,
        db: Db,
        config: Config,
        replication_config: ReplicationConfig,
        peer_addr: SocketAddr,
    ) -> Result<Vec<CommandResponse>, String> {
        match self {
          // 각 커맨드에 해당하는 처리 함수를 호출한다.
          Command::SET { key, value, ex, px } => Ok(vec![CommandResponse::Simple(
             Self::execute_set(key, value, *ex, *px, db).await,
           )]),
          // (중략 ... )
        }
    }

    async fn execute_set(key: &String, value: &String, ex: Option<u64>, px: Option<u64>, db: Db) -> String {
        let expiration_ms = match (px, ex) {
            (Some(ms), _) => Some(ms),
            (None, Some(s)) => Some(s * 1000),
            _ => None,
        };

        // 2. 실제 스레드에서 경합자원을 직접적으로 이용한다.
        db.write().await.insert(key.clone(), ValueEntry::new_relative(value.clone(), expiration_ms));
        // 3. 심지어 레플리케이션 전파와 같은 로직이 늘어난다면 또하나의 경합자원을 생성한다.
        format!("{}OK{}", SIMPLE_STRING_PREFIX, CRLF)
    }



// ====== 이하 진행하고 있는 리팩토링 =======
#[tokio::main]
async fn main() {
    let listener = TcpListener::bind("127.0.0.1:6379").await.unwrap();
    let client_manager = ClientManager::new();
    let (tx, mut rx) = mpsc::channel::<RedisEvent>(32);

    let db = Arc::new(tokio::sync::RwLock::new(Default::default()));
    let config = Arc::new(tokio::sync::RwLock::new(Default::default()));
    let replication_config = Arc::new(tokio::sync::RwLock::new(Default::default()));

    //# client manager 자체를 넘기고, 아래 spawn에서는 client manager를 사용하지 않고
    //# client추가, 삭제를 RedisEvent에 더 추가해서 넘기기 (RedisEvent::AddClient(...), RemoveClient(...))
    //# db, config, replication_config, cilent_manager는 모두 event handler에서만 사용하게 바뀌게 되어서
    //# Arc, RwLock 등 삭제
    let event_handler = EventHandler::new(
        db.clone(),
        config.clone(),
        replication_config.clone(),
        client_manager.clients.clone(), //# client_manager자체를 넘기고, 
    );

    let event_publisher = EventPublisher::new(tx);

    tokio::spawn(async move {
        while let Ok((stream, addr)) = listener.accept().await {
            //# id는 atomic같은것을 이용해서 unique함을 보장
            let client_id = addr.port() as u64;
            
            //# AddClient event로 수정하면서
            //# stream을 split 시켜서 읽는 쪽과 쓰는쪽을 분리. 
            //# 읽는쪽은 아래spawn 내부에서 사용하고, 쓰는쪽은 client에서 사용
            //# https://docs.rs/tokio/latest/tokio/net/struct.TcpStream.html#method.split
            client_manager.add_client(client_id, stream.try_clone().unwrap()).await;

            let publisher = event_publisher.clone();
            //# 매니저는 event_handler에서만 존재
            let manager = client_manager.clone();

            tokio::spawn(async move {
                //# 분리한 sream중 reader 사용
                let mut stream = manager.get_stream(client_id).await.unwrap().write().await;
                let mut buffer = [0; 1024];

                loop {
                    let bytes_read = match stream.read(&mut buffer).await {
                        Ok(0) => break,
                        Ok(n) => n,
                        Err(_) => {
                            eprintln!("Failed to read from client {}", client_id);
                            break;
                        }
                    };

                    //# 보낸 데이터를 한번에 다 읽는다는 보장이 없기 때문에
                    //# 보낼때도 byte len같은걸 해더에 담아 보내고
                    //# 읽을때도 해당 바이트를 다 읽을때까지 계속 돌면서 buffer를 채워야 함.
                    let input = String::from_utf8_lossy(&buffer[..bytes_read]).to_string();
                    if let Err(e) = publisher.publish(client_id, input.clone()).await {
                        eprintln!("Error publishing event: {}", e);
                    }
                }

                manager.remove_client(client_id).await;
            });
        }
    });

    while let Some(event) = rx.recv().await {
        event_handler.handle_event(event).await;
    }
}

//# 아래에 각족 Lock, Arc는 필요성이 없다면 모두 삭제
pub type SharedClients = Arc<RwLock<HashMap<u64, Arc<Client>>>>;

pub struct ClientManager {
    clients: SharedClients,
}

impl ClientManager {
    pub fn new() -> Self {
        Self {
            clients: Arc::new(RwLock::new(HashMap::new())),
        }
    }

    pub async fn add_client(&self, client_id: u64, client: Client) {
        let mut clients = self.clients.write().await;
        clients.insert(client_id, Arc::new(client));
    }

    pub async fn remove_client(&self, client_id: u64) {
        let mut clients = self.clients.write().await;
        clients.remove(&client_id);
    }

    pub async fn get_client(&self, client_id: u64) -> Option<Arc<Client>> {
        let clients = self.clients.read().await;
        clients.get(&client_id).cloned()
    }
}

#[derive(Debug)]
pub struct Client {
    pub id: u64,
    pub stream: Arc<RwLock<TcpStream>>,
    pub connected_at: Instant,
    pub request_count: RwLock<u64>,
}

impl Client {
    pub fn new(id: u64, stream: TcpStream) -> Self {
        Self {
            id,
            stream: Arc::new(RwLock::new(stream)),
            connected_at: Instant::now(),
            request_count: RwLock::new(0),
        }
    }

    pub async fn increment_request_count(&self) {
        let mut count = self.request_count.write().await;
        *count += 1;
    }

    pub async fn get_request_count(&self) -> u64 {
        *self.request_count.read().await
    }
}

```
