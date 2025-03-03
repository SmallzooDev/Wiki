---
title: Concurrency-Intro
summary: 
date: 2025-03-03 11:58:56 +0900
lastmod: 2025-03-03 18:08:15 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 25 병행성에 관한 대화
> 여러사람이 동시에 복숭아를 집을 수 있도록 했을때는 빨랐어요,
> 반면에 제 방법은 한번에 한명씩 집기 때문에 정확하겠지만 꽤 느리겠군요.

> 멀티 쓰레드 프로그램이라고 불리는 프로그램들이 있네, 각 쓰레드는 독립된 객체로서 프로그램 내에서 프로그램을 대신하여 일으 하지, 이 쓰레드들은 메모리에 접근하는데, 쓰레드 입장에서 보면 메모리는 아까 이야기했던 복숭아와 같은 거야

> 동시성을 운영체제에서 다뤄야 할 몇 가지 이유가 있지.
> 운영체제는 락과 컨디션 변수와 같은 기본 동적으로 멀티쓰레드 프로그램을 지원해야 한다네.
> 둘째로 운영체제는 그 자체로 최초의 동시 프로그램이기 때문이야


## 26 병행성: 개요
- 프로그램에서 한 순간에 하나의 명령어만을 실행하는 (단일 PC값) 고전적인 관점에서 벗어나 멀티 쓰레드 프로그램은 하나 이상의 실행 지점을 가지고 있다(독립적으로 불러 들여지고 실행될 수 있는 여러개의 PC값).
- 멀티 쓰레드를 이해하는 다른 방법은 각 쓰레드가 프로세스와 매우 유사하지만, 차이가 있다면 쓰레드들은 주소공간을 공유하기 때문에 동일한 값에 접근할 수있다는 것이다.
- 하나의 스레드의 상태는 프로세스의 상태와 매우 유사하다. 스레드는 어디서 명령어를 불러들일지 추적하는 프로그램 카운터와 연산을 위한 레지스터들을 가지고 있다.
- 만약 두개의 스레드가 하나의 프로세서에서 실행중이라면 실행하고자 하는 스레드는 반드시 context switch을 통해서 실행중이 스레드와 교체되어야 한다.
- 스레드의 문맥교환은 t1이 사용하던 레지스터들을 저장하고 t2가 사용하던 레지스터의 내용으로 복원한다는 점에서 프로세스의 문맥 교환과 유사하다. 
- 프로세스가 문맥 교환을 핼 때에 프로세스의 상태를 프로세스 제어 블럭에 저장하듯이 스레드는 스레드 제어 블럭이 필요하다.
- 가장 큰 차이중 하나는 프로세스의 경우오 달리 스레드간의 문맥 교환에서는 주소공간을 그대로 사용한다는 것이다.
- 스레드와 프로세스의 또 다는 차이는 스택에 있다. 고전적 프로세스 주소공간과 같은 간단한 모델에서는 스택이 하나만 존재한다.(주로 주소 공간의 하부에)
- 반면에 멀티스레드 프로세스의 경우에는 각 스레드가 독립적으로 실행되며 주소공간에는 하나의 스택이 아니라 스레드마다 스택이 할당되어 있다.
![Image](https://github.com/user-attachments/assets/371a9be3-d9bc-4f86-b2f8-5f46b9895313)

### 26.1 왜 스레드를 사용하는가?
- 우리는 멀티스레드를 사용하면서 발생하는 문제를 배울것이기 때문에 그 전에 왜 사용하는지의 효용에 대해서 알아볼것이다.
- 주요하게는 두가지 이유가 있다.
	- 병렬처리 (parallelism) : 
		- 예를 들어 두개의 큰 배열을 더하거나, 배열의 각 원소 값을 증가시키는 것과 같이 매우 큰 배열을 대상으로 연산을 수행하는 프로그램을 작성하고 있따고 가정해보자.
		- 단일프로세스는 간단하다 - 각 작업을 하나씩 수행 후 완료
		- 그러나 멀티프로세스시스템에서는 각 프로세서가 작업의 일부분을 수행하게 함으로써 실행속도를 높일수 있다.
		- 표준 단일 스레드 프로그램을 멀티프로세서상에서 같은 작업을 하는 프로그램으로 변환하는 작업을 병려화라고 한다.
	- 두번째는 약간 미묘한데, 느린 I/O로 인해 프로그램 실행이 멈추지 않도록 하기 위해서 스레드를 이용한다.
		- 프로그램중 하나의 스레드가 대기하는동안 스케줄러는 다른 스레드로 전환할 수 있고 이 스레드는 준비 상태이며 유용한 작업을 수행한다.

### 26.2 예제: 스레드 생성
```c
#include <stdio.h>
#include <assert.h>
#include <pthread.h>
#include "common.h"
#include "common_threads.h"

void *mythread(void *arg) {
    printf("%s\n", (char *) arg);
    return NULL;
}

int main(int argc, char *argv[]) {
    pthread_t p1, p2;
    int rc;
    printf("main: begin\n");
    Pthread_create(&p1, NULL, mythread, "A");
    Pthread_create(&p2, NULL, mythread, "B");
    // join waits for the threads to finish
    Pthread_join(p1, NULL);
    Pthread_join(p2, NULL);
    printf("main: end\n");
    return 0;
}
```

![Image](https://github.com/user-attachments/assets/937172e6-167e-4fd4-81b2-7cbe5d32163f)

![Image](https://github.com/user-attachments/assets/0318ce13-e63a-40bb-8a3e-d71bd6864e26)

- 함수 호출처럼 스레드를 생성하기도 한다.
- 함수호출에서는 함수실행후에 호출자에게 리턴하는 반면에 스레드의 생성에서는 실행할 명령어들을 갖고있는 새로운 스레드가 생성되고 생성된 스레드는 호출자와는 별개로 실행된다.
- 스레드 생성함수가 리턴되기 전에 스레드가 실행 될 수 도 있고, 그보다 이후에 실행 될 수 있다.
- 다음에 실행될 스레드는 스케줄러에 의해 결정된다.
- 이 예제에서 알 수 있듯 스레드는 일을 복잡하게 만든다.

### 26.3 훨씬 더 어려운 이유: 데이터 공유

```c
#include <stdio.h>
#include <pthread.h>
#include "common.h"
#include "common_threads.h"

static volatile int counter = 0;

// mythread()
// Simply adds 1 to counter repeatedly, in a loop
// No, this is not how you would add 10,000,000 to
// a counter, but it shows the problem nicely.
void *mythread(void *arg) {
    printf("%s: begin\n", (char *) arg);
    int i;
    for (i = 0; i < 1e7; i++) {
        counter = counter + 1;
    }
    printf("%s: done\n", (char *) arg);
    return NULL;
}

// main()
// Just launches two threads (pthread_create)
// and then waits for them (pthread_join)
int main(int argc, char *argv[]) {
    pthread_t p1, p2;
    printf("main: begin (counter = %d)\n", counter);
    Pthread_create(&p1, NULL, mythread, "A");
    Pthread_create(&p2, NULL, mythread, "B");

    // join waits for the threads to finish
    Pthread_join(p1, NULL);
    Pthread_join(p2, NULL);
    printf("main: done with both (counter = %d)\n", counter);
    return 0;
}
```
- 이 프로그램은 단일 프로세서더라도 기대한대로 결과가 출력되지 않는다.

### 26.4 문제의 핵심: 제어 없는 스케줄링
![Image](https://github.com/user-attachments/assets/4b61fae9-19c3-4f29-8424-c301bdfd3bc7)
- 요약하면 t1이 값을 읽고, 저장하기 직전에 인터럽트, t2로 전환, 51로 정상 수행, 인터럽트, t1이 작업을 이어서하다보니 51을 다시 반영..
- 이러한 상황 즉 명령어의 실행 순서에 따라 결과가 달라지는 상황을 경쟁조건이라고 한다. (race condition, data race)
- 이러한 경우 비결정적인 결과가 발생한다  (indeterminate)
- 그리고 멀티스레드와 같은 코드를 실행할때 경쟁조건이 발생하기 때문에 이러한 코드 부분을 임계 영역(critical section)이라고 한다. 공유 변수/자원을 접근하고 하나 이상의 스레드에서 동시에 실행되면 안되는 코드
- 이러한 코드에서 필요한것은 상호 배제이다. 이 속성은 하나의 스레드가 임계 영역 내의 코드를 실행중일 때는 다른스레드가 실행할 수 없도록 보장해준다.
- 그리고 원자성이라는 것은 전부 아니면 전무 즉 모두 실행되거나, 중간 상태가 없도록 모두 실행되지 않아야 한다는 의미이다. (atomic)

### 26.5 원자성에 대한 바람
- 임계 영역 문제에 대한 해결 방법중 하나로 강력한 명령어 한 개로 의도한 동작을 수행하여, 인터럽트 발생 가능성을 원천적으로 차단하는 것이다.
```
mov 0x8049alc, % e a x
add $0x1, &eax
mov seax, 0x8049alc
```
- 위의 일련의 명령어를 이러한 `memory-add 0x8049alc, $0x1` 하나의 문장으로 구분해서 원자성을 띄게 한다면 가능하기는 하다.
- 하지만 현실적으로 어려운 부분이 많다.
- 예를들어 병행성을 가지는 B-tree를 만드는 중이라고 했을 때, 원자적으로 B-tree를 갱신하는 `어셈블리어`를 원해야 할까? 그러면 어셈블리어는 전혀 일반적이지 않게 된다.
- 따라서 우리가 해야 할 일은 하드웨어에 동기화 함수 (synchronization primitives)구현에 필요한 몇가지 유용한 명령어를 원하면 된다.
- 이 하드웨어 지원을 사용하고 운영체제의 도움을 받아 한 번에 하나의 스레드만 임계영역에서 실행하도록 구성된 멀티스레드 프로그램을 만들 수 있다.

### 26.6 또 다른 문제: 상대 기다리기
- 더 복잡해지는 것중에 하나는 스레드간의 순서도 생길수 있다.
- 예를들어 하나의스레드가 다른 스레드가 어떤 동작을 끝낼 때 까지 대기해야 하는 상황도 빈번하게 발생한다.
- 프로세스가 디스크 i/o를 요청하고 응답이 올 때 까지 잠든 경우가 좋은 예이다.


>참고로 이 장은 멀티스레드의 문제에 대한 정의와 용어정리가 정부인데, 용어정리를 원문과 함께 다시하면 좋을 것 같아서 아래의 인용문을 가져왔다, 거의 모든 용어는 다익스트라가 정의했다고 한다.
```
These four terms are so central to concurrent code that we thought it
worth while to call them out explicitly. See some of Dijkstra’s early work
[D65,D68] for more details.

• A critical section is a piece of code that accesses a shared resource,
usually a variable or data structure.

• A race condition (or data race [NM92]) arises if multiple threads of
execution enter the critical section at roughly the same time; both
attempt to update the shared data structure, leading to a surprising
(and perhaps undesirable) outcome.

• An indeterminate program consists of one or more race conditions;
the output of the program varies from run to run, depending on
which threads ran when. The outcome is thus not deterministic,

something we usually expect from computer systems.

• To avoid these problems, threads should use some kind of mutual
exclusion primitives; doing so guarantees that only a single thread
ever enters a critical section, thus avoiding races, and resulting in
deterministic program outputs
```

## 27 막간: 스레드 api
>핵심 질문 : 스레드를 생성하고 제어하는 방법
>운영체제가 스레드를 생성하고 제어하는 데 어떤 인터페이스를 제공해야 할까?
>어떻게 이 인터페이스를 설계해야 쉽고 유용하게 사용할 수 있을까?

### 27.1 스레드 생성
```c
#include <pthread.h>
int pthread_create(pthread_t *thread,
                   const pthread_attr_t *attr,
                   void *(*start_routine)(void *),
                   void *arg);
```
- `thread` : pthread_t 타입 구조체의 포인터. 이 구조가 스레드와 상호작용하는데 쓰이기때문에 초기화시 전달.
- `attr` : 스레드의 속성 지정, 스택 크기와 스레드의 스케줄링 우선순위와 같은 정보들
- `*(*start_routine)(void *)` : 이 스레드가 실행할 함수, 예시에서는 void 함수를 전달
- `*arg` : 실행할 함수에게 전달한 인자.

```c
#include <stdio.h>
#include <pthread.h>

typedef struct {
    int a;
    int b;
} myarg_t;

void *mythread(void *arg) {
    myarg_t *args = (myarg_t *) arg;
    printf("%d %d\n", args->a, args->b);
    return NULL;
}

int main(int argc, char *argv[]) {
    pthread_t p;
    myarg_t args = {10, 20};

    int rc = pthread_create(&p, NULL, mythread, &args);
    if (rc != 0) {
        fprintf(stderr, "Error creating thread\n");
        return 1;
    }
...
}
```
### 27.2 스레드 종료
```c
int pthread_join (pthread_t thread, void **value_ptr);
```
- `thread` : 기다릴 스레드
- `**value_ptr` : 반환값의 포인터
```c
typedef struct { int a; int b; } myarg_t;
typedef struct { int x; int y; } myret_t;

void *mythread(void *arg) {
    myret_t *rvals = Malloc(sizeof(myret_t));
    rvals->x = 1;
    rvals->y = 2;
    return (void *) rvals;
}

int main(int argc, char *argv[]) {
    pthread_t p;
    myret_t *rvals;
    myarg_t args = { 10, 20 };
    Pthread_create(&p, NULL, mythread, &args);
    Pthread_join(p, (void **) &rvals);
    printf("returned %d %d\n", rvals->x, rvals->y);
    free(rvals);
    return 0;
}
```
- 특히 주의해야할것은 스레드의 반환값에 스레드 콜스택의 포인터를 절대 반환하지 말라는 것이다.
> 사실 위의 예시들은 그냥 프로시저 호출을 쓰는게 낫다. 굳이 저렇게 할 이유가 없다
- 보통 웹서버는 그냥 join을 거의 안쓰고 메인스레드를 이용해서 사용자 요청을 받아 작업자에게 전달하는 작업을 무한히 할 것
- 또는 실제 병렬적으로 처리하는경우는 이렇게 하나두개의 일만 하지 않기 때문에 그냥 예시코드라 하는것

```c
#include <stdio.h>
#include <pthread.h>

void *mythread(void *arg) {
    int id = *(int *)arg;
    printf("Thread %d is running\n", id);
    return NULL;
}

int main() {
    pthread_t threads[3];
    int ids[3] = {1, 2, 3};

    // 여러 개의 쓰레드 생성
    for (int i = 0; i < 3; i++) {
        pthread_create(&threads[i], NULL, mythread, &ids[i]);
    }

    // 모든 쓰레드가 종료될 때까지 기다림
    for (int i = 0; i < 3; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("All threads finished\n");
    return 0;
}
```


### 27.3 락
- POSIX 스레드 라이브러리에서는 아래처럼 제공된다.
```c
int pthread_mutex_lock(pthread_mutex_t *mutex);
int pthread_mutex_unlock(pthread_mutex_t *mutex);
```

- 뭔가 아래처럼  생긴 코드를 생각하겠지만 일부 틀린점이 있다.
- 다만 기본적으로 `pthread_mutex_lock()`이 호출되었을때 다른 어떤 스레드도 락을 가지고 있지 않다면 이 스레드가 락을 얻어 임계 영역에 진입한다.
- 락 획득을 시도하는 스레드는 락을 얻을 때까지 호출에서 리턴하지 않는다.
- 락을 획득한 스레드만 언락을 호출해야한다.
```c
pthread_mutex_t lock;
pthread_mutex_lock(&lock);
x = x + 1; // or whatever your critical section is
pthread_mutex_unlock(&lock);
```
- 이코드가 동작하지않는 이유는 두가지이지다.
	- 첫번째로는 초기화를 하지 않았다.
	- 두번째 문제는 락과 언락을 호출 할 때 에러코드를 확인하지 않았다는 것이다.
	- 만약 조용히 실패하는경우 여러스레드가 임계영역에 동시 진입이 가능하다.
```c
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

pthread_mutex_t lock;
int x = 0; // 공유 자원 (임계 영역 보호 필요)

void *mythread(void *arg) {
    if (pthread_mutex_lock(&lock) != 0) { // 락 획득 실패 시 오류 처리
        perror("pthread_mutex_lock failed");
        return NULL;
    }

    // 임계 영역 (Critical Section)
    x = x + 1;
    printf("Thread %ld: x = %d\n", pthread_self(), x);

    if (pthread_mutex_unlock(&lock) != 0) { // 언락 실패 시 오류 처리
        perror("pthread_mutex_unlock failed");
        return NULL;
    }

    return NULL;
}

int main() {
    pthread_t t1, t2;

    // 뮤텍스 초기화 (반환값 체크)
    if (pthread_mutex_init(&lock, NULL) != 0) {
        perror("pthread_mutex_init failed");
        return 1;
    }

    // 두 개의 스레드 생성
    pthread_create(&t1, NULL, mythread, NULL);
    pthread_create(&t2, NULL, mythread, NULL);

    // 스레드 종료 대기
    pthread_join(t1, NULL);
    pthread_join(t2, NULL);

    // 뮤텍스 제거
    pthread_mutex_destroy(&lock);

    return 0;
}
```
- 아예 코드를 아래처럼 깔끔하게 유지하도록!
```c
// Keeps code clean; only use if exit() OK upon failure
void Pthread_mutex_lock(pthread_mutex_t *mutex) {
	int rc = pthread_mutex_lock(mutex);
	assert(rc == 0);
}
```

- 아래 두 루틴도 있지만 사용하지 않는 편이 낫다.
```c
int pthread_mutex_trylock(pthread_mutex_t *mutex);
int pthread_mutex_timedlock(pthread_mutex_t *mutex,
								struct timespec *abs_timeout);
```

### 27.4 컨디션 변수
```c
int pthread_cond_wait(pthread_cond_t *cond, pthread_mutex_t *mutex);
int pthread_cond_signal(pthread_cond_t *cond);
```
- 한 스레드가 계속 진행하기 전에 다른 스레드가 무엇인가를 해야 하는 경우
```c
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
Pthread_mutex_lock(&lock);
while (ready == 0)
	Pthread_cond_wait(&cond, &lock);
Pthread_mutex_unlock(&lock);
```

## 28 락

### 28.1 기본 개념
- 프로그래머들은 소스코드의 임계영역을 락으로 둘러서 그 임계영역이 마치 하나의 원자 단위 명령어인것처럼 실행되도록 한다.
```c
lock_t mutex; // some globally-allocated lock 'mutex'
lock(&mutex);
balance = balance + 1;
unlock(&mutex);
```
- 락은 일종의 변수이며, 락변수는 둘중 하나의 상태를 갖는다
	- 사용가능 (available, unlocked, free)
	- 사용중 (acquired)
	- 그리고 임계 영역에서는 정확히 하나의 스레드가 락을 획득한 상태이다
	- 락 소유자의 unlcok()으로 락은 사용 가능으로 되돌아간다.
- 락은 프로그래머에게 스케줄링에 대한 최소한의 제어권을 제공한다.
	- 프로그래머가 스레드를 생성하고 운영체제가 제어한다.
	- 락은 스레드에 대한 제어권을 일부 이양 받을 수 있게 해준다.

### 28.2 Pthread 락
- 스레드간의 상호 배제 (mutual exclusion)을 제공하기 때문에 posix 라이브러리는 락을 mutex라고 부른다.

### 28.3 락의 구현
- 락의 동작 방식은 이해하기가 쉬워 대략적으로 이해했을 것이다 그렇다면 어떻게 락을 만들어야 하는가?

> 핵심질문 : 락은 어떻게 만들까?
> 효율적인 락은 어떻게 만들어야할까? 효율적인 락은 낮은 비용으로 상호 배제 기법을 제공하고, 다음에 다룰 몇가지 속성들을 추가로 가져야 한다. 어떤 하드웨어 지원 혹은 운영체제 지원이 필요할까?

### 28.4 락의 평가
- 다음과 같은 것들이 락의 평가요인이다.
	- 상호 배제 (mutual exclusion)을 제대로 지원하는가?
	- 공정성 (fairness)는 스레드들이 락획득에 대한 공정한 기회가 주어지는가? 반대로 starve상태가 일어나지는 않는가?
	- 성능 (performance)는 락 사용 시간적 오버헤드를 평가해야한다.
		- 이건 여러스레드, 혹은 멀티 cpu간에서도 평가를 각각 해야한다.

### 28.5 인터럽트 제어
- 초창기 단일 프로세스 시스템에서는 상호 배제 지원을 위해 임계영역 내에서는 인터럽트를 비활성하는 방식을 사용했다.
```c
void lock() {
    DisableInterrupts();
}

void unlock() {
    EnableInterrupts();
}
```
- 단순하다, 그리고 이해하기 쉽다.
	- 노력하지 않아도 잘 동작할것을 짐작할 수 있다.
	- 임계영역내의 동작이 진행되는 동안 인터럽트를 무시할 수 있다면, 임계영역내의 동작이 원자적으로 시행될것을 보장할 수 있다.
- 단점이 많다.
	- 첫 번째는, 이 요청을 하는 스레드가 인터럽트를 활성/비활성하는 priviledged 연산을 실행 할 수 있도록 허가해야 한다.
		- 그리고 이 priviledged 권한을 통해 다른 것을 하지 않는다는것을 신뢰 할 수 있어야 한다.
		- 예를들어 lock을 얻고 무한루프 혹은 나쁜짓을 해도 lde에서는 제어권을 다시 가져올 수 없다.
	- 두 번째는, 멀티프로세서에서는 적용을 할 수 없다는 것이다.
		- 여러 스레드가 여러 cpu에서 실행중이라면 각 스레드가 동일한 임계 영역을 진입하려고 시도할 수 있다.
		- 특정 프로세서에서의 인터럽트 비활성화는 다른 프로세스에서 실행중인 프로그램에는 영향이 없다.
	- 세 번째는, 장시간동안 인터럽트를 중시지시키는 것은 중요한 인터럽트의 시점을 놓칠 수 있다는 것이다.
		- 예를 들어 cpu가 저장 장치에서 읽기 요청을 마친 사실을 모르고 지나갔다고 해보자.
		- 운영체제가 읽기 결과를 기다리는 프로세스를 어떻게 깨울까?
	- 마지막은, 이 방법은 비효율적이라는 것이다. (최신 cpu에서는 매우 느리게 동작한다.)

### 28.6 실패한 시도: 오직 load/store 명령어만 사용하기
```c
typedef struct __lock_t { int flag; } lock_t;

void init(lock_t *mutex) {
    // 0 -> lock is available, 1 -> held
    mutex->flag = 0;
}

void lock(lock_t *mutex) {
    while (mutex->flag == 1) // 만약 사용중이면 기다린다.
        ; // spin-wait (do nothing)
    mutex->flag = 1; // now SET it!
}

void unlock(lock_t *mutex) {
    mutex->flag = 0;
}
```
- 위의 코드는 두가지 문제가 있다.
	- 먼저 제대로 동작하는지 여부이다.
		- 두개의 스레드가 flag 0을 보고 같이 진입하는게 가능하다
	- 두번째는 성능이다.
		- 락을 기다리는동안 spin-wait을 하는게 락을 해제할 때 까지 시간을 낭비한다.
		- 단일프로세서에서는 특히 매우 손해가 크다. 락을 소유한 스레드조차도 실행할 수 없기 때문이다.
			- 이건 lock을 호출한 스레드가 기다리기때문에, 소유한 스레드도 컨텍스트 스위치 전까지는 뭘 할 수 가 읎음

### 28.7 Test-And-Set을 사용하여 작동하는 스핀 락 구현하기
- 원자적 교체라고도 알려진 명령어이다.
```c
int TestAndSet(int *old_ptr, int new) {
    int old = *old_ptr; // fetch old value at old_ptr
    *old_ptr = new; // store 'new' into old_ptr
    return old; // return the old value
}
```
- 위 코드와 동일한 동작을 하는 하드웨어 명령어를 지원받는것 (실제 c코드가 아닌)


```c
typedef struct __lock_t {
    int flag;
} lock_t;

void init(lock_t *lock) {
    // 0: lock is available, 1: lock is held
    lock->flag = 0;
}

void lock(lock_t *lock) {
    while (TestAndSet(&lock->flag, 1) == 1)
        ; // spin-wait (do nothing)
}

void unlock(lock_t *lock) {
    lock->flag = 0;
}
```
- 첫번째로
	- 처음 스레드가 lock()을 호출하고 다른 어떤 스레드도 락을 보유하지 않는다면
	- 현재의 flag =0이라면,
	- 이 스레드가 TestAndSet(flag, 1)을 호출하면 이 루틴은 flag의 이전 값인 0을 반환한다.
	- flag값을 검사한 스레드는 while문에서 회전하지 않고 락을 획득한다.
- 두 번째는
	- 처음 스레드가 락을 획득하여 flag값이 1인상태이다.
	- 두번째 스레드가 lock을 호출하면 첫 스레드가 반환할때까지 while문을 반복한다.
	
> 주의할점은 선점형 스케줄러를 사용해야 한다는 것이다.(preemptive scheduler)
> 그렇지 않으면 spin while loop가 영원히 독점할수 있기 때문이다.

### 28.8 스핀 락 평가
- 단일 cpu의 경우는 오버헤드가 상당히 크다.
- 임계영역내에서 락을 갖고있던 스레드가 선점된 경우, N-1개의 다른 스레드가 있다고 가정 할 때 스케줄러가 락을 획득하려는 다르 스레드를 깨우고 대기하면서 시간을 낭비 할 수 있다.
- 반면에 cpu가 여러개인 경우 스핀락은 꽤 합리적으로 동작한다.
- 물론 대기는 있지만, 락을 점유한 cpu의 작업이 끊기지 않을 것 이기 때문에 금방금방 락이 넘어갈것이다.

### 28.9 Compare-And-Swap

```c
int CompareAndSwap(int *ptr, int expected, int new) {
    int original = *ptr;
    if (original == expected)
        *ptr = new;
    return original;
}
```
- ptr이 가리키고 있는 주소의 값이 expected와 일치하는지 검사하는것이다.
- 일치한다면 주소의 값을 새로운 값으로 변경한다.
- 만약 불일치한다면 아무것도 하지 않는다.
- 원래의 메모리 값을 반환하여 호출한 코드의 락 획득 여부를 알 수 있도록한다.


### 28.11 Fetch-And-Add
```c
int FetchAndAdd(int *ptr) {
    int old = *ptr;
    *ptr = old + 1;
    return old;
}
```
```c
typedef struct __lock_t {
    int ticket;
    int turn;
} lock_t;

void lock_init(lock_t *lock) {
    lock->ticket = 0;
    lock->turn = 0;
}

void lock(lock_t *lock) {
    int myturn = FetchAndAdd(&lock->ticket);
    while (lock->turn != myturn)
        ; // spin
}

void unlock(lock_t *lock) {
    lock->turn = lock->turn + 1;
}
```
- 스케줄링이 가능하도록 한 방법

### 28.12 요약: 과도한 스핀
> 핵심질문: 회전은 낭비이다. 회전을 피하는 방법이 무엇이 있을까?


### 28.13 간단한 접근법: 조건 없는 양보!
```c
void init() {
    flag = 0;
}

void lock() {
    while (TestAndSet(&flag, 1) == 1)
        yield(); // give up the CPU
}

void unlock() {
    flag = 0;
}
```
- 간단하고 좋은 접근방식이지만, 컨텍스트 스위치 비용도 상당하다.

### 28.14 큐의 사용: 스핀 대신 잠자기
- 위의 접근법들은 지나치게 운에 의존하고 있다.
- 이번에는 큐를 사용할것이다.
```c
typedef struct __lock_t {
    int flag;
    int guard;
    queue_t *q;
} lock_t;

void lock_init(lock_t *m) {
    m->flag = 0;
    m->guard = 0;
    queue_init(m->q);
}

void lock(lock_t *m) {
    while (TestAndSet(&m->guard, 1) == 1)
        ; // acquire guard lock by spinning

    if (m->flag == 0) {
        m->flag = 1; // lock is acquired
        m->guard = 0;
    } else {
        queue_add(m->q, gettid());
        m->guard = 0;
        park();
    }
}

void unlock(lock_t *m) {
    while (TestAndSet(&m->guard, 1) == 1)
        ; // acquire guard lock by spinning

    if (queue_empty(m->q))
        m->flag = 0; // let go of lock; no one wants it
    else
        unpark(queue_remove(m->q)); // hold lock (for next thread!)

    m->guard = 0;
}
```
- `park()`,`unpark(thread)`는 각각 호출한 스레드 혹은, 아규먼트로 넘긴 스레드를 재우고 깨우는 함수이다.
- 경쟁발생 획득한애들 빼고 다 큐에넣고, 그동안 락 획득여부를 누군가 획득했다고 설정해놓고, 큐가 비워지고 언락해야하는 누군가가 그재서야 flag를 0으로 되돌린다
- 문제는 여기도 경쟁조건이 있다는건데 (park()를 호출하기 직전 vs 점유중인 락을 해제하는경우)
- 이러면 락은 해제됐고 점유한 스레드가없어서 깨워줄 방법이 없다.
- Solaris는 이 문제를 setPark()를 통해서 해결했는데
- 이 루틴은 스레드가 현재 park()호출 직전이라는것으 표시한다. 만약 그때 인터럽트가 실행되어 park()가 호출되기 전에 다른 스레드가 unpark()를 먼저 호출한다면 블럭되는대신 바로 리턴된다.
```c
    } else {
        queue_add(m->q, gettid());
		setpark(); // 요기
        m->guard = 0;
        park();
    }
```

## 29 락 기반의 병행 자료 구조
> 범용 자료 구조에서 락을 사용하는 방법을 살펴본다.
> 자료 구조에 락을 추가하면 해당 자료 구조를 경쟁조건으로부터 thread safe한 자료구조로 만들 수 있다.

> 핵심 질문: 지료구조에 락을 추가하는 방법
> 특정 자료구조가 주어졌을 때, 어떤 방식으로 락을 추가해야 그 자료구조가 정확하게 동작하게 만들 수 있을까?


### 29.1 Concurrent Counters
- 카운터는 가장 간단한 자료구조이고, 보편적이며, 인터페이스가 간단하다.
**간단하지만, 확장성이 없다.**
```c
typedef struct __counter_t {
    int value;
} counter_t;

void init(counter_t *c) {
    c->value = 0;
}

void increment(counter_t *c) {
    c->value++;
}

void decrement(counter_t *c) {
    c->value--;
}

int get(counter_t *c) {
    return c->value;
}
```
- 일단 이렇게 구현하면 thread safa하게 만들수 있다. 
```c
typedef struct __counter_t {
    int value;
    pthread_mutex_t lock;
} counter_t;

void init(counter_t *c) {
    c->value = 0;
    pthread_mutex_init(&c->lock, NULL);
}

void increment(counter_t *c) {
    pthread_mutex_lock(&c->lock);
    c->value++;
    pthread_mutex_unlock(&c->lock);
}

void decrement(counter_t *c) {
    pthread_mutex_lock(&c->lock);
    c->value--;
    pthread_mutex_unlock(&c->lock);
}

int get(counter_t *c) {
    pthread_mutex_lock(&c->lock);
    int rc = c->value;
    pthread_mutex_unlock(&c->lock);
    return rc;
}
```
- 이상태에서는 간단하고 정확하게 동작하지만, 성능이 문제다.
	- 저자의 테스트에서 카운트 100만번 계산하는데
		- 싱글스레드는 0.03초
		- 두개의 스레드는 5초 이상이 걸렸다고 한다. (...)
	- 완벽한 확장성이라는 것이랑 거리가 멀다
		- 완벽한 확정성을 달성했다면 스레드의 갯수만큼 반비례로 시간이 줄어들었어야한다.
		- 혹은 200만번을 진행했을때, 동일하게 0.03초가 걸리거나

**확장성 있는 카운팅**
- 그래서 근사 카운터 (approximate counter)라고 불리는 기법을 사용한다고한다.
- 기본 개념은  스레드 로컬한 지역 카운터를 가지고 경쟁없이 증가시키고, 이건 지역락에 의해서만 보호한다.
- 그 다음 전역카운터값을 지역카운터값으로 갱신하고 그시점에 지역카운터 값은 0으로 초기화한다.
- 지역에서 전역으로 값을 전달하는 빈도는 S값에 의해서 설정된다.
	- S값이 작을수록 (갱신빈도는 커질수록) 카운터의 확장성이 없어지며, 
	- S값이 클수록 (갱신빈조는 작아질수록) 전역카운터값이 실제 카운터 값과 일치하지 않을 확률이 커진다.

```c

typedef struct __counter_t {
    int global; // global count
    pthread_mutex_t glock; // global lock
    int local[NUMCPUS]; // per-CPU count
    pthread_mutex_t llock[NUMCPUS]; // ... and locks
    int threshold; // update frequency
} counter_t;

// init: record threshold, init locks, init values
// of all local counts and global count
void init(counter_t *c, int threshold) {
    c->threshold = threshold;
    c->global = 0;
    pthread_mutex_init(&c->glock, NULL);
    for (int i = 0; i < NUMCPUS; i++) {
        c->local[i] = 0;
        pthread_mutex_init(&c->llock[i], NULL);
    }
}

// update: usually, just grab local lock and update
// local amount; once local count has risen ’threshold’,
// grab global lock and transfer local values to it
void update(counter_t *c, int threadID, int amt) {
    int cpu = threadID % NUMCPUS;
    pthread_mutex_lock(&c->llock[cpu]);
    c->local[cpu] += amt;
    if (c->local[cpu] >= c->threshold) {
        // transfer to global (assumes amt>0)
        pthread_mutex_lock(&c->glock);
        c->global += c->local[cpu];
        pthread_mutex_unlock(&c->glock);
        c->local[cpu] = 0;
    }
    pthread_mutex_unlock(&c->llock[cpu]);
}

// get: just return global amount (approximate)
int get(counter_t *c) {
    pthread_mutex_lock(&c->glock);
    int val = c->global;
    pthread_mutex_unlock(&c->glock);
    return val; // only approximate!
}
```

### 29.2 Concurrent Linked List
```c
// basic node structure
typedef struct __node_t {
    int key;
    struct __node_t *next;
} node_t;

// basic list structure (one used per list)
typedef struct __list_t {
    node_t *head;
    pthread_mutex_t lock;
} list_t;

void List_Init(list_t *L) {
    L->head = NULL;
    pthread_mutex_init(&L->lock, NULL);
}

int List_Insert(list_t *L, int key) {
    pthread_mutex_lock(&L->lock);
    node_t *new = malloc(sizeof(node_t));
    if (new == NULL) {
        perror("malloc");
        pthread_mutex_unlock(&L->lock);
        return -1; // fail
    }
    new->key = key;
    new->next = L->head;
    L->head = new;
    pthread_mutex_unlock(&L->lock);
    return 0; // success
}

int List_Lookup(list_t *L, int key) {
    pthread_mutex_lock(&L->lock);
    node_t *curr = L->head;
    while (curr) {
        if (curr->key == key) {
            pthread_mutex_unlock(&L->lock);
            return 0; // success
        }
        curr = curr->next;
    }
    pthread_mutex_unlock(&L->lock);
    return -1; // failure
}
```

- 마찬가지로 확장성이 좋지 않다는 문제가 있다.
- 이건 정말 필요한 부분만 락을 거는 방식으로 해결한다.
```c
void List_Init(list_t *L) {
    L->head = NULL;
    pthread_mutex_init(&L->lock, NULL);
}

void List_Insert(list_t *L, int key) {
    // synchronization not needed before allocation
    node_t *new = malloc(sizeof(node_t));
    if (new == NULL) {
        perror("malloc");
        return;
    }
    new->key = key;

    // just lock critical section
    pthread_mutex_lock(&L->lock);
    new->next = L->head;
    L->head = new;
    pthread_mutex_unlock(&L->lock);
}

int List_Lookup(list_t *L, int key) {
    int rv = -1;
    pthread_mutex_lock(&L->lock);
    node_t *curr = L->head;
    while (curr) {
        if (curr->key == key) {
            rv = 0;
            break;
        }
        curr = curr->next;
    }
    pthread_mutex_unlock(&L->lock);
    return rv; // now both success and failure
}
```

### 29.3 Concurrent Queue
- 꼭 필요한 부분에만 락을 걸어서 부하를 줄인 좋은 최적화 예제
```c
typedef struct __node_t {
    int value;
    struct __node_t *next;
} node_t;

typedef struct __queue_t {
    node_t *head;
    node_t *tail;
    pthread_mutex_t head_lock, tail_lock;
} queue_t;

void Queue_Init(queue_t *q) {
    node_t *tmp = malloc(sizeof(node_t));
    tmp->next = NULL;
    q->head = q->tail = tmp;
    pthread_mutex_init(&q->head_lock, NULL);
    pthread_mutex_init(&q->tail_lock, NULL);
}

void Queue_Enqueue(queue_t *q, int value) {
    node_t *tmp = malloc(sizeof(node_t));
    assert(tmp != NULL);
    tmp->value = value;
    tmp->next = NULL;

    pthread_mutex_lock(&q->tail_lock);
    q->tail->next = tmp;
    q->tail = tmp;
    pthread_mutex_unlock(&q->tail_lock);
}

int Queue_Dequeue(queue_t *q, int *value) {
    pthread_mutex_lock(&q->head_lock);
    node_t *tmp = q->head;
    node_t *new_head = tmp->next;
    if (new_head == NULL) {
        pthread_mutex_unlock(&q->head_lock);
        return -1; // queue was empty
    }
    *value = new_head->value;
    q->head = new_head;
    pthread_mutex_unlock(&q->head_lock);
    free(tmp);
    return 0;
}
```

## 30 Condition Variables
- 락 이외에도 병행 프로그램을 제작할 수 있는 다른 기법들이 존재한다.
- 스레드가 실행을 계속하기 전에 특정 조건의 만족여부를 검사해야하는 경우가 많이 있다.
```c
void *child(void *arg) {
    printf("child\n");
    // XXX how to indicate we are done?
    return NULL;
}

int main(int argc, char *argv[]) {
    printf("parent: begin\n");
    pthread_t c;
    pthread_create(&c, NULL, child, NULL); // create child
    // XXX how to wait for child?
    printf("parent: end\n");
    return 0;
}
```
- 우리가 원하는것
```c
parent: begin
child
parent: end
```
- 공유 변수를 쓸 수 있기도 하지만, 그러면 부모가 회전을 해야하기때문에 효율적이지 않다.

### 30.1 컨디션 변수의 개념과 관련 루틴
- 컨디션 변수는 일존의 큐 자료 구조이다.
- 어떤 상태가 원하는 것과 다를때 조건이 만족되기를 대기하는 큐이다.
```c
int done = 0;
pthread_mutex_t m = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t c = PTHREAD_COND_INITIALIZER;

void thr_exit() {
    Pthread_mutex_lock(&m);
    done = 1;
    Pthread_cond_signal(&c);
    Pthread_mutex_unlock(&m);
}

void *child(void *arg) {
    printf("child\n");
    thr_exit();
    return NULL;
}

void thr_join() {
    Pthread_mutex_lock(&m);
    while (done == 0)
        Pthread_cond_wait(&c, &m);
    Pthread_mutex_unlock(&m);
}

int main(int argc, char *argv[]) {
    printf("parent: begin\n");
    pthread_t p;
    Pthread_create(&p, NULL, child, NULL);
    thr_join();
    printf("parent: end\n");
    return 0;
}
```
- pthread_cond_t c; 라고 써서 c가 컨디션 변수가 되도록 한다.
- 컨디션 변수에는 wait()과 signal()이라는 두개의 연산이 있다.
	- wait은 스레드가 스스로를 잠재우기 위해서
	- signal은 조건이 만족되기를 대기하며 잠자고 있던 스레드를 깨울때 호출한다.
```c
pthread_cond_wait (pthread_cond_t *c, thread_mutex_t *m) ;
pthread_cond_signal (pthread_cond_t *c) ;
```
- 과정을 명확히 기억해야 한다.
	1. 슬립에서 깨어난 프로세스는 리턴하기 전에 락을 재획득해야한다.
	2. 시그널을 받아서 대기상태에서 깨어났더라도 락획득에 실패하면 다시 슬립한다.

### 30.2 생산자/소비자 (유한버퍼) 문제
- 자주 사용되는 패턴
- 생산자는 데이터를 만들어 버퍼에 넣고, 소비자는 버퍼에서 데이터를 꺼내어 사용한다.
- 웹서버등 엄청 많이 사용되는 패턴
- 유닉스도 마찬가지이다.
```bash
grep foo file.txt | wc -1
```
- grep이 생산자 wc가 소비자
- 문제는 유한 버퍼가 공유 자원이라는 것이다, 경쟁 조건의 발생을 방지하기 위해 동기화기 필요하다.
```c
int buffer;
int count = 0; // initially, empty

void put(int value) {
    assert(count == 0);
    count = 1;
    buffer = value;
}

int get() {
    assert(count == 1);
    count = 0;
    return buffer;
}
```
- 간단하다, 생산자는 버퍼가 비어있다면 (count = 0) 넣고,
- 소비자는 버퍼가 차있으면 (count = 1) 뺀다.
```c
void *producer(void *arg) {
    int i;
    int loops = (int) arg;
    for (i = 0; i < loops; i++) {
        put(i);
    }
}

void *consumer(void *arg) {
    while (1) {
        int tmp = get();
        printf("%d\n", tmp);
    }
}
```
- 이런 코드는 제대로 동작하지 않는다.
- 공유변수 (count에서 경쟁 조건이 발생하기 때문이다.)

#### 불완전한 해답.
```c
int loops; // must initialize somewhere...
cond_t cond;
mutex_t mutex;

void *producer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex); // p1
        if (count == 1) // p2
            Pthread_cond_wait(&cond, &mutex); // p3
        put(i); // p4
        Pthread_cond_signal(&cond); // p5
        Pthread_mutex_unlock(&mutex); // p6
    }
}

void *consumer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex); // c1
        if (count == 0) // c2
            Pthread_cond_wait(&cond, &mutex); // c3
        int tmp = get(); // c4
        Pthread_cond_signal(&cond); // c5
        Pthread_mutex_unlock(&mutex); // c6
        printf("%d\n", tmp);
    }
}
```
- 이코드는 동작할 것 같지만 스레드가 늘어나면 문제가 생긴다.
- 소비자 먼저 실행된다 (TC1)
- 락을 획득하고(c1) 버퍼를 소비할 수 있는지 검사한다(c2)
- 비어있음을 확인하고 대기하며 (c3) 락을 해제한다.
- 그리고 생산자가 실행된다.
- 락을 획득하고(p1), 버퍼가 비었는지 확인한다 (p2)
- 비어있음을 확인하고 버퍼를 채운다(p4)
- 버퍼가 가득찼다는 시그널을 보낸다 (p5)
- 소비자는 준비 큐로 이동한다.
- 소비자는 준비되었지만 실행가능하지는 않은 상태이다.
- 생산자는 실행을 계속한다.
- 버퍼가 차있으므로 대기상태로 전이한다.(p6, p1-p3)
- 여기서 문제가 발생한다. (Tc2)가 끼어들면서 버퍼값을 수행한다.
- Tc2가 버퍼를 소비한 직후 Tc1이 실행된다고 하자
- 절묘하게도 대기에서 리턴하기전에 락을 획득하지만 버퍼가 비어있다.
- Tc1이 버퍼를 읽는 행위를 막지 못했다.
![이미지](https://github.com/user-attachments/assets/d5da1eec-4a37-4c31-82ce-ab2b09d898e4)
- 문제의 원인은 단순하다 Tc1이 시그널을 받는 시점과 스레드가 실행되는 시점의 시차 때문이다.
- 깨운다는 행위의 본질은 스레드의 상태를 변경하는것이다, 깨우고 실되는 시점 사이에 버퍼는 다시 변경될 수 있다.
- 때문에 깨어난 스레드가 실제 실행되는 시점에는 시그널을 받았던 시점의 상태가 그대로 유지되어있는지를 체크해야한다.
- 이것을 Mesa semantic이라고 한다.
- 가장 간단한 해결책은 if를 while문으로 변경하는것이다
```c
int loops; // must initialize somewhere...
cond_t cond;
mutex_t mutex;

void *producer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex); // p1
        while (count == 1) // p2
            Pthread_cond_wait(&cond, &mutex); // p3
        put(i); // p4
        Pthread_cond_signal(&cond); // p5
        Pthread_mutex_unlock(&mutex); // p6
    }
}

void *consumer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex); // c1
        while (count == 0) // c2
            Pthread_cond_wait(&cond, &mutex); // c3
        int tmp = get(); // c4
        Pthread_cond_signal(&cond); // c5
        Pthread_mutex_unlock(&mutex); // c6
        printf("%d\n", tmp);
    }
}
```

- 또하나의 문제가 있다.
- 만약에 생산자가 버퍼를 채우고,
- 소비자가 비우고,
- 소비자를 또 깨우면
- 세상에나 세개의 스레드가 다 자버릴 수 있다.
![임이지](https://github.com/user-attachments/assets/6bacd8a0-4241-4ee6-be11-3fb399e769e0)

- 변수를 두개써서 해결할 수있기는하다.
```c
cond_t empty, fill;
mutex_t mutex;

void *producer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex);
        while (count == 1)
            Pthread_cond_wait(&empty, &mutex);
        put(i);
        Pthread_cond_signal(&fill);
        Pthread_mutex_unlock(&mutex);
    }
}

void *consumer(void *arg) {
    int i;
    for (i = 0; i < loops; i++) {
        Pthread_mutex_lock(&mutex);
        while (count == 0)
            Pthread_cond_wait(&fill, &mutex);
        int tmp = get();
        Pthread_cond_signal(&empty);
        Pthread_mutex_unlock(&mutex);
        printf("%d\n", tmp);
    }
}
```

- 여기서 이것까지만 개선해주면!
```c
#define MAX 100

int buffer[MAX];
int fill = 0;
int use = 0;
int count = 0;

void put(int value) {
    buffer[fill] = value;
    fill = (fill + 1) % MAX;
    count++;
}

int get() {
    int tmp = buffer[use];
    use = (use + 1) % MAX;
    count--;
    return tmp;
}
```
- 다중스레스 생산자/소비자 해법이 완료되었다.
