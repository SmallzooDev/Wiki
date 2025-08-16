---
title: golang의 인터페이스
summary: 
date: 2025-08-16 16:23:59 +0900
lastmod: 2025-08-16 16:23:59 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
## 핵심 차이점

### 1. Python (덕 타이핑) - 너무 자유로움

```python
# 문제: 어떤 메서드가 필요한지 알기 어려움
def program(logic):
    logic.process(data)  # process 메서드가 있기를 '기대'만 함

class Logic:
    def process(self, data):
        return "처리됨"

class WrongLogic:
    def handle(self, data):  # process가 아니라 handle!
        return "처리됨"

program(Logic())      # 작동
program(WrongLogic()) # 런타임 에러! AttributeError
```

어떤 메서드가 필요한지 코드만 봐서는 알 수 없음.

### 2. Java (명시적 구현) - 너무 경직됨

```java
// 인터페이스 먼저 정의해야 함
public interface Logic {
    String process(String data);
}

// 반드시 implements 키워드로 명시적 구현
public class LogicImpl implements Logic {
    public String process(String data) {
        return "처리됨";
    }
}

// 새로운 요구사항: 다른 라이브러리의 클래스 사용하고 싶음
public class ThirdPartyProcessor {
    public String handle(String data) {  // 메서드명이 다름!
        return "처리됨";
    }
}

// 문제: ThirdPartyProcessor는 Logic을 구현하지 않음
// 해결책: 어댑터 패턴으로 감싸야 함
public class ProcessorAdapter implements Logic {
    private ThirdPartyProcessor processor;
    
    public String process(String data) {
        return processor.handle(data);  // 어댑터 코드 필요
    }
}
```

기존 코드를 인터페이스에 맞추려면 추가 코드가 필요.

### 3. Go (암묵적 구현)

```go
// 인터페이스 정의 (보통 사용하는 쪽에서 정의)
type Logic interface {
    Process(data string) string
}

// 구현체 1: implements 키워드 없이 그냥 메서드만 구현
type LogicProvider struct{}

func (lp LogicProvider) Process(data string) string {
    return "LogicProvider로 처리됨"
}

// 구현체 2: 다른 패키지의 기존 타입도 자동으로 호환
type ThirdPartyProcessor struct{}

func (tp ThirdPartyProcessor) Process(data string) string {
    return "ThirdParty로 처리됨"
}

// 클라이언트 코드
type Client struct {
    L Logic
}

func (c Client) Program(data string) string {
    return c.L.Process(data)
}

func main() {
    // 둘 다 자동으로 Logic 인터페이스를 만족
    client1 := Client{L: LogicProvider{}}
    client2 := Client{L: ThirdPartyProcessor{}}
    
    fmt.Println(client1.Program("test"))
    fmt.Println(client2.Program("test"))
}
```

## 실제 상황

### 상황: 기존 코드에 새로운 인터페이스 추가

```go
// 1단계: 기존에 있던 구조체들
type FileLogger struct{}
func (f FileLogger) Write(msg string) { /* 파일에 쓰기 */ }

type ConsoleLogger struct{}
func (c ConsoleLogger) Write(msg string) { /* 콘솔에 쓰기 */ }

type DatabaseLogger struct{}
func (d DatabaseLogger) Write(msg string) { /* DB에 쓰기 */ }

// 2단계: 나중에 인터페이스가 필요해짐
type Logger interface {
    Write(msg string)
}

// 3단계: 기존 코드 수정 없이 바로 사용 가능!
func logMessage(logger Logger, msg string) {
    logger.Write(msg)
}

func main() {
    // 모든 기존 타입이 자동으로 Logger 인터페이스를 만족
    logMessage(FileLogger{}, "파일 로그")
    logMessage(ConsoleLogger{}, "콘솔 로그")
    logMessage(DatabaseLogger{}, "DB 로그")
}
```

**Java라면**: 모든 기존 클래스에 `implements Logger`를 추가필요.

**Python이라면**: 런타임에 `Write` 메서드가 없으면 에러.

**Go라면**: 기존 코드 수정 없이 바로 작동

## 외부 라이브러리 활용

```go
// 외부 라이브러리의 HTTP 클라이언트
type HTTPClient struct{}
func (h HTTPClient) Get(url string) string { return "response" }

// 우리가 만든 HTTP 클라이언트
type MyHTTPClient struct{}
func (m MyHTTPClient) Get(url string) string { return "my response" }

// 나중에 필요에 의해 인터페이스 정의
type Getter interface {
    Get(url string) string
}

// 둘 다 자동으로 Getter를 만족
func fetchData(client Getter, url string) string {
    return client.Get(url)
}

func main() {
    // 외부 라이브러리와 내부 구현 모두 호환
    fetchData(HTTPClient{}, "http://api.com")
    fetchData(MyHTTPClient{}, "http://api.com")
}
```