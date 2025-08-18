---
title: 고루틴 요약
summary: 
date: 2025-08-17 14:27:35 +0900
lastmod: 2025-08-17 14:27:35 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## Goroutines
- Goroutine Scheduling in Go
	- Managed by the Go Runtime Scheduler
	- Uses M:N Scheduling Model
		- M goroutines are mapped onto N operating system threads
	- Efficient Multiplexing (switching)

- Concurrency vs Parellelism
	- Concurrency : multiple tasks progress simultaneously and not necessarily at the same time
	- Parellelism : tasks are executed literally at the same time on mutliple processors
- Common Pitfalls and Best Practices
	- Avoiding Goroutine Leaks
	- Limiting Goroutine Creation
	- Proper Error Handling
	- Synchronization

## Channels
### Why Use Channels?
> Channels are a way for go routines to communicate with each aother and synchronize their execution
- 동시 실행되는 고루틴(Goroutines) 간의 안전하고 효율적인 통신을 가능하게 함
- 동시성 프로그램에서 데이터 흐름을 동기화하고 관리하는 데 도움

### Channels Basics
- **채널 생성**: `make(chan Type)`
- **데이터 송수신**: `<-` 연산자 사용
- **채널 방향성**:
    - **송신 전용**: `ch <- value`
    - **수신 전용**: `value := <- ch`
```go
// 채널 생성
ch := make(chan int)

// 고루틴에서 데이터 전송
go func() {
    ch <- 42
}()

// 메인에서 데이터 수신
value := <-ch
fmt.Println(value) // 출력: 42
```

### Unbuffered Channel
#### 왜 아래 코드는 실행되지 않는가?

```go
func main() {
    greeting := make(chan string)
    greetString := "Hello"
    greeting <- greetString // 여기서 데드락 발생!
    receiver := <-greeting
    fmt.Println(receiver)
}
```

문제점: 데드락 발생

1. `make(chan string)`으로 **언버퍼드 채널**을 생성
2. `greeting <- greetString`에서 채널에 데이터를 **송신**하려고 시도
3. **언버퍼드 채널은 동시에 송신자와 수신자가 있어야 데이터 전송이 가능**
4. 하지만 현재 **수신자가 없음** (수신 코드는 다음 줄에 있음)
5. 송신 작업이 **무한정 블로킹**되어 프로그램이 멈춤

#### 왜 아래 코드는 실행되는가?

```go
func fixed_main() {
    greeting := make(chan string)
    greetString := "Hello"
    go func() {
        greeting <- greetString // 별도 고루틴에서 송신
    }()
    receiver := <-greeting      // 메인 고루틴에서 수신
    fmt.Println(receiver)
}
```

해결책: 별도의 고루틴 사용

1. `go func()`로 **새로운 고루틴** 생성
2. **송신자**: 별도 고루틴에서 `greeting <- greetString` 실행
3. **수신자**: 메인 고루틴에서 `<-greeting` 실행
4. **동시에 송신자와 수신자가 존재**하므로 데이터 전송 성공

채널에서 수신이 블로킹되는 이유

언버퍼드 채널의 특성
- **동기적(Synchronous)**: 송신자와 수신자가 동시에 준비되어야 함
- **핸드셰이크 방식**: 송신자가 데이터를 보내고 수신자가 받을 때까지 둘 다 대기
- **버퍼 없음**: 데이터를 임시 저장할 공간이 없음

블로킹 시나리오
```go
// 시나리오 1: 수신자가 없을 때 송신 블로킹
ch <- "data" // 수신자가 나타날 때까지 무한 대기

// 시나리오 2: 송신자가 없을 때 수신 블로킹  
data := <-ch // 송신자가 데이터를 보낼 때까지 무한 대기
```
### Buffered Channel

버퍼드 채널을 사용하는 이유
- 비동기 통신(Asynchronous Communication)
- 부하 분산(Load Balancing)
- 흐름 제어(Flow Control)

버퍼드 채널 생성
- `make(chan Type, capacity)`
- 버퍼 용량(Buffer Capacity)

채널 버퍼링의 핵심 개념
- 블로킹 동작(Blocking Behavior)
- 논블로킹 작업(Non-Blocking Operations)
- 성능에 미치는 영향(Impact on Performance)

버퍼드 채널 사용 모범 사례
- 과도한 버퍼링 피하기(Avoid Over-Buffering)
- 우아한 종료(Graceful Shutdown)
- 버퍼 사용량 모니터링(Monitoring Buffer Usage)


버퍼드 채널 동작 원리

```go
// 언버퍼드 채널 (동기적)
unbuffered := make(chan int)
unbuffered <- 1 // 수신자가 있을 때까지 블로킹

// 버퍼드 채널 (비동기적)
buffered := make(chan int, 3)
buffered <- 1 // 즉시 완료 (버퍼에 공간 있음)
buffered <- 2 // 즉시 완료
buffered <- 3 // 즉시 완료
buffered <- 4 // 이제 블로킹 (버퍼 가득참)
```

버퍼 상태에 따른 동작

1. 버퍼에 공간이 있을 때: 송신 즉시 완료
2. 버퍼가 가득 찰 때: 송신자 블로킹
3. 버퍼에 데이터가 있을 때: 수신 즉시 완료
4. 버퍼가 비어있을 때: 수신자 블로킹

실제 사용 예시

작업 큐 패턴

```go
// 워커 풀을 위한 버퍼드 채널
jobs := make(chan Job, 100)

// 작업 생산자
go func() {
    for i := 0; i < 1000; i++ {
        jobs <- Job{ID: i}
    }
    close(jobs)
}()

// 작업 소비자들
for i := 0; i < 10; i++ {
    go worker(jobs)
}
```

흐름 제어

```go
// 동시 요청 수 제한
semaphore := make(chan struct{}, 10)

for i := 0; i < 100; i++ {
    semaphore <- struct{}{} // 허용 토큰 획득
    go func() {
        defer func() { <-semaphore }() // 토큰 반환
        // 실제 작업 수행
    }()
}
```

Common Pitfalls and Best Practices
- 데드락 방지
- 불필요한 버퍼링 피하기
- 채널 방향성 고려
- 우아한 종료(Graceful Shutdown)
- 언블로킹을 위한 `defer` 사용

### Channel Synchronization
채널 동기화(Channel Synchronization)

채널 동기화가 중요한 이유

- 고루틴 간 데이터가 올바르게 교환되도록 보장
- 실행 흐름을 조정하여 경쟁 상태를 방지하고 예측 가능한 동작 보장
- 고루틴의 생명주기와 작업 완료를 관리하는 데 도움

일반적인 함정과 모범 사례

- 데드락 방지
- 채널 닫기
- 불필요한 블로킹 방지

---

채널 동기화 패턴

완료 신호(Done Signal)

```go
done := make(chan bool)

go func() {
    // 작업 수행
    fmt.Println("작업 완료")
    done <- true
}()

// 완료까지 대기
<-done
fmt.Println("모든 작업 완료")
```

워커 풀 동기화

```go
const numWorkers = 3
done := make(chan bool, numWorkers)

for i := 0; i < numWorkers; i++ {
    go func(id int) {
        // 작업 수행
        fmt.Printf("워커 %d 완료\n", id)
        done <- true
    }(i)
}

// 모든 워커 완료 대기
for i := 0; i < numWorkers; i++ {
    <-done
}
```

채널 닫기를 통한 종료 신호

```go
quit := make(chan struct{})

go func() {
    for {
        select {
        case <-quit:
            fmt.Println("종료 신호 받음")
            return
        default:
            // 계속 작업
        }
    }
}()

// 종료 신호 전송
close(quit)
```

sync.WaitGroup과의 비교

```go
// 채널 사용
done := make(chan struct{})
go func() {
    defer close(done)
    // 작업 수행
}()
<-done

// WaitGroup 사용
var wg sync.WaitGroup
wg.Add(1)
go func() {
    defer wg.Done()
    // 작업 수행
}()
wg.Wait()
```

주의사항
- 적절한 close필요
```go
package main

import (
	"fmt"
	"time"
)

func main() {
	data := make(chan string)

	go func() {
		for i := range 5 {
			data <- "hello" + fmt.Sprint(i)
			time.Sleep(100 * time.Millisecond)
		}
		close(data) // 여기서 닫아주지않으면
	}()

	for value := range data { // 여기서 무한 대기
		fmt.Println("received value : ", value, " : ", time.Now())
	}
}

```

- 채널을 닫은 후에는 더 이상 데이터를 전송할 수 없음
- 닫힌 채널에서 수신하면 즉시 제로값 반환
- 데드락을 피하기 위해 고루틴 생명주기를 신중하게 관리
- select문을 사용하여 논블로킹 작업 구현 가능

### Channel Directions
채널 방향성이 중요한 이유

- 코드 명확성과 유지보수성 향상
- 채널에서 의도하지 않은 작업 방지
- 채널의 목적을 명확히 정의하여 타입 안전성 강화

채널 방향성의 기본 개념

- 단방향 채널(Unidirectional Channels)
- 송신 전용 채널(Send-Only Channels)
- 수신 전용 채널(Receive-Only Channels)
- 테스팅과 디버깅

함수 시그니처에서 채널 방향성 정의

- 송신 전용 매개변수: `func produceData(ch chan<- int)`
- 수신 전용 매개변수: `func consumeData(ch <-chan int)`
- 양방향 채널: `func bidirectional(ch chan int)`

---

채널 방향성 사용 예시

기본 양방향 채널

```go
// 양방향 채널 생성
ch := make(chan int)

// 송신과 수신 모두 가능
ch <- 42
value := <-ch
```

송신 전용 채널 함수

```go
// 송신만 가능한 채널을 매개변수로 받음
func producer(ch chan<- int) {
    for i := 0; i < 5; i++ {
        ch <- i  // 송신 가능
        // value := <-ch  // 컴파일 에러! 수신 불가
    }
    close(ch)
}

// 사용 예시
ch := make(chan int)
go producer(ch)  // 양방향 채널이 송신 전용으로 변환됨
```

수신 전용 채널 함수

```go
// 수신만 가능한 채널을 매개변수로 받음
func consumer(ch <-chan int) {
    for value := range ch {
        fmt.Println("받은 값:", value)  // 수신 가능
        // ch <- 100  // 컴파일 에러! 송신 불가
    }
}

// 사용 예시
ch := make(chan int)
go consumer(ch)  // 양방향 채널이 수신 전용으로 변환됨
```


```go
func main() {
    ch := make(chan int, 5)
    
    // 생산자: 송신 전용으로 사용
    go producer(ch)
    
    // 소비자: 수신 전용으로 사용
    consumer(ch)
}

func producer(ch chan<- int) {
    for i := 1; i <= 5; i++ {
        ch <- i
        fmt.Printf("송신: %d\n", i)
    }
    close(ch)
}

func consumer(ch <-chan int) {
    for value := range ch {
        fmt.Printf("수신: %d\n", value)
    }
}
```

채널 방향성 변환 규칙

```go
ch := make(chan int)        // 양방향 채널

var sendOnly chan<- int = ch    // 양방향 → 송신 전용 (가능)
var recvOnly <-chan int = ch    // 양방향 → 수신 전용 (가능)

// var bidir chan int = sendOnly   // 송신 전용 → 양방향 (불가능!)
// var bidir chan int = recvOnly   // 수신 전용 → 양방향 (불가능!)
```

실제 활용 시나리오

```go
// 워커 풀 패턴에서 방향성 활용
func setupWorkerPool() {
    jobs := make(chan Job, 100)
    results := make(chan Result, 100)
    
    // 작업 생성자 (송신 전용)
    go jobProducer(jobs)
    
    // 워커들 (작업은 수신, 결과는 송신)
    for i := 0; i < 3; i++ {
        go worker(jobs, results)
    }
    
    // 결과 수집자 (수신 전용)
    resultCollector(results)
}

func jobProducer(jobs chan<- Job) {
    // 작업만 송신
}

func worker(jobs <-chan Job, results chan<- Result) {
    // 작업 수신, 결과 송신
}

func resultCollector(results <-chan Result) {
    // 결과만 수신
}
```

장점과 효과

- 컴파일 타임에 채널 오용 방지
- 함수의 의도와 책임이 명확해짐
- 코드 리뷰와 유지보수가 쉬워짐
- API 설계 시 채널 사용 방법을 명확히 전달
- 실수로 인한 데드락이나 고루틴 누수 방지


### Multiplexing using select
멀티플렉싱을 사용하는 이유

- 동시성(Concurrency)
- 논블로킹 작업(Non-Blocking Operations)
- 타임아웃과 취소(Timeouts and Cancellations)

select 사용 모범 사례

- 바쁜 대기 피하기(Avoiding Busy Waiting)
- 데드락 처리(Handling Deadlocks)
- 가독성과 유지보수성(Readability and Maintainability)
- 테스팅과 디버깅(Testing and Debugging)

---

기본 select 문법

```go
select {
case <-ch1:
    // ch1에서 수신할 때 실행
case ch2 <- value:
    // ch2로 송신할 때 실행
case <-time.After(1 * time.Second):
    // 1초 타임아웃
default:
    // 즉시 실행 가능한 case가 없을 때
}
```

논블로킹 채널 작업

```go
// 논블로킹 수신
select {
case msg := <-ch:
    fmt.Println("메시지 받음:", msg)
default:
    fmt.Println("메시지 없음")
}

// 논블로킹 송신
select {
case ch <- "hello":
    fmt.Println("메시지 전송됨")
default:
    fmt.Println("채널이 가득참")
}
```

여러 채널에서 동시 대기

```go
func waitForMultipleChannels() {
    ch1 := make(chan string)
    ch2 := make(chan int)
    quit := make(chan bool)
    
    go func() {
        time.Sleep(1 * time.Second)
        ch1 <- "문자열 데이터"
    }()
    
    go func() {
        time.Sleep(2 * time.Second)
        ch2 <- 42
    }()
    
    for {
        select {
        case msg := <-ch1:
            fmt.Println("ch1에서:", msg)
        case num := <-ch2:
            fmt.Println("ch2에서:", num)
        case <-quit:
            fmt.Println("종료")
            return
        }
    }
}
```

타임아웃 구현

```go
func withTimeout() {
    ch := make(chan string)
    
    go func() {
        time.Sleep(2 * time.Second)
        ch <- "늦은 메시지"
    }()
    
    select {
    case msg := <-ch:
        fmt.Println("받은 메시지:", msg)
    case <-time.After(1 * time.Second):
        fmt.Println("타임아웃 발생!")
    }
}
```

워커 풀에서 select 활용

```go
func workerWithSelect(jobs <-chan Job, results chan<- Result, quit <-chan bool) {
    for {
        select {
        case job := <-jobs:
            // 작업 처리
            result := processJob(job)
            results <- result
        case <-quit:
            fmt.Println("워커 종료")
            return
        }
    }
}
```

팬인(Fan-in) 패턴

```go
func fanIn(ch1, ch2 <-chan string) <-chan string {
    out := make(chan string)
    
    go func() {
        defer close(out)
        for {
            select {
            case msg, ok := <-ch1:
                if !ok {
                    ch1 = nil // 닫힌 채널 무시
                    continue
                }
                out <- msg
            case msg, ok := <-ch2:
                if !ok {
                    ch2 = nil // 닫힌 채널 무시
                    continue
                }
                out <- msg
            }
            
            // 모든 채널이 닫히면 종료
            if ch1 == nil && ch2 == nil {
                return
            }
        }
    }()
    
    return out
}
```

select에서 우선순위 처리

```go
func prioritySelect() {
    highPriority := make(chan string)
    lowPriority := make(chan string)
    
    for {
        select {
        case msg := <-highPriority:
            fmt.Println("높은 우선순위:", msg)
        default:
            select {
            case msg := <-highPriority:
                fmt.Println("높은 우선순위:", msg)
            case msg := <-lowPriority:
                fmt.Println("낮은 우선순위:", msg)
            }
        }
    }
}
```

바쁜 대기 피하기

```go
// 잘못된 예 - 바쁜 대기
for {
    select {
    case msg := <-ch:
        processMessage(msg)
    default:
        // CPU를 계속 사용하게 됨
    }
}

// 올바른 예 - 블로킹 대기
for {
    select {
    case msg := <-ch:
        processMessage(msg)
    case <-time.After(100 * time.Millisecond):
        // 주기적인 다른 작업
        doPeriodicWork()
    }
}
```

컨텍스트를 활용한 취소

```go
func workWithContext(ctx context.Context) {
    ch := make(chan string)
    
    go func() {
        // 백그라운드 작업
        time.Sleep(5 * time.Second)
        ch <- "작업 완료"
    }()
    
    select {
    case result := <-ch:
        fmt.Println("결과:", result)
    case <-ctx.Done():
        fmt.Println("작업 취소됨:", ctx.Err())
    }
}
```

주의사항과 팁

- default case가 있으면 select는 절대 블로킹되지 않음
- 여러 case가 동시에 준비되면 무작위로 선택됨
- 닫힌 채널에서 수신은 항상 즉시 실행됨 (제로값 반환)
- select 내부에서 break는 select문만 종료 (반복문 아님)
- 채널이 nil이면 해당 case는 영원히 실행되지 않음


사용예시
```go
package main

import (
	"fmt"
	"time"
)

func main() {
	// === NON BLOCKING RECIEVE OPERATION
	ch := make(chan int)
	select {
	case msg := <-ch:
		fmt.Println("Received: ", msg)
	default:
		fmt.Println("No messages available")
	}

	// === NON BLOCKING SEND OPERATION
	select {
	case ch <- 1:
		fmt.Println("Sent message.")
	default:
		fmt.Println("Channel is not ready to receive")
	}

	// === NON BLOCKING OPERATION IN REAL TIME SYSTEMS
	data := make(chan int)
	quit := make(chan bool)

	go func() {
		for {
			select {
			case d := <-data:
				fmt.Println("Data received: ", d)
			case <-quit:
				fmt.Println("Stopping...")
				return
			default:
				fmt.Println("Waiting for data...")
				time.Sleep(500 * time.Millisecond)
			}
		}
	}()

	for i := range 5 {
		data <- i
		time.Sleep(time.Second)
	}

	quit <- true
}

```


filter 패턴
```go

package main

import "fmt"

func producer(ch chan<- int) {
	for i := range 5 {
		ch <- i
	}
	close(ch)
}

func filter(in <-chan int, out chan<- int) {
	for val := range in {
		if val%2 == 0 {
			out <- val
		}
		close(out)
	}
}

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)

	go producer(ch1)
	go filter(ch1, ch2)

	for val := range ch2 {
		fmt.Println(val)
	}
}

```