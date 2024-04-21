---
title: Week-01 📚
summary: 
date: 2024-04-21 14:26:30 +0900
lastmod: 2024-04-21 14:26:30 +0900
tags: 
categories: 
description: 
showToc: true
---

## 01 장 - 이 책에 대한 대화

- 아주 간단한 이 책에 대한 소개를 하는 챕터이다.
 
- 두 장으로 이루어져 있고, 이 책에서 자주 나오게 되는 교수와 학생의 대화 형식으로 이루어져 있다.

- 핵심적인 아이디어를 요약하면 다음과 같다. 
  - 리처드 파인만의 물리학 아주 쉬운 6가지 이야기라는 강의 노트가 있다.
  - 물리학이 6만큼 어려우면, 운영체제는 3만큼 어렵기 때문에, 이 책의 제목이 "운영체제 아주 쉬운 세 가지 이야기"이다.
  - 이 책은 운영체제에 대한 이야기를 3가지로 나누어서 설명한다. `가상화`, `병행성`, `영속성`

## 02 장 - 운영체제 개요

> 이 책에서 다루게 될 내용이지만 아주 간단하게 약식으로 설명하는 글이 있어 가져왔다.
> c/cpp를 공부할 때 이분의 블로그와 강의자료를 들었는데 상대적으로 최근에 업로드된 문서이다.
> [내가 c언어를 배우기 전에 알았다면 좋았을 것들](https://modoocode.com/315)

- 프로그램은 명령어를 실행하는 아주 단순한 일을 한다.

- 프로세서는 명렁어를 반입(fetch)하고, 디코딩(decoding)하고, 실행(execute)하는 일을 한다.

- 그리고 프로그램을 쉽게 실행하고, 프로그램간의 메모리 공유를 가능케 하고, 장치와 상호작용을 가능케하고, 다양한 흥미로운 일을 할 수 있는 `소프트웨어`가 `운영체제`이다.

- 운영체제는 앞에서 언급한 일을 하기 위해서 `Virtualization`이라는 기법을 사용한다.

- 실제 프로세서, 메모리, 디스크 같은 물리적인 자원을 이용해서 일반적이고, 강력하고, 사용이 편리한 가상 형태의 자원을 생성한다.

- 그래서 운영체제를 가상머신이라고 하기도 한다.

- 가상화를 이용해서 실제 사용자들이 해당 자원을 접근 할 수 있는 API를 제공하며, Application이 사용 할 수 있는 시스템콜을 제공한다.


### 02.1 CPU 가상화

> **핵심 질문 : 자원을 어떻게 가상화 시키는가?**

- 운영체제가 자원을 가상화 시켜서 사용하면 편리한건 너무 당연하기 때문에, 이러한 문제는 질문이 될 수 없다.

- 이것을 어떻게, 어떠한 기법과 정책으로, 어떻게 효율적으로, 어떠한 하드웨어 지원이 필요한지 와 같은 질문이 중요하다.

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

void Spin(int howlong) {
  double t = GetTime();
  while ((GetTime() - t) < (double)howlong)
    ; // do nothing in loop
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    printf("Usage: CPU <string>\n");
    exit(-1);
  }
  char *str = argv[1];
  while (1) {
    Spin(1);
    printf("%s\n", str);
  }
  return 0;
}
```

- 위 코드는 CPU를 사용하는 프로그램이다. 이 프로그램은 인자로 받은 문자열을 1초에 한 번 영원히 출력한다.

```shell
$ gcc -o CPU CPU.c
$ ./CPU A & ; ./CPU B & ; ./CPU C & ;
```

- 이렇게 실행시키면 마치 CPU가 세 개인 것 처럼 ABC가 번갈아가며 출력된다.

- 이렇게 CPU를 가상화 시키는 것은 유용하지만, 새로운 문제가 발생한다. 예를 들어 동일한 시점에 실행되어야 하는 프로그램이 많아지면, 어떠한 프로그램이 실행되어야 하는가 와 같은 이슈가 생긴다.

- 이러한 문제를 해결하기 위해서 필요한 정책 같은 것들이 있는데, 이번 장에서는 이러한 정책들을 다루게 된다.(즉 자원 관리자로서의 운영체제 역할에 대해 다룬다.)

### 02.2 메모리 가상화

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>

double GetTime() {
  struct timeval t;
  int rc = gettimeofday(&t, NULL);
  assert(rc == 0);
  return (double)t.tv_sec + (double)t.tv_usec / 1e6;
}



void Spin(int howlong) {
  double t = GetTime();
  while ((GetTime() - t) < (double)howlong)
    ; // do nothing in loop
}

int main(int argc, char *argv[]) {
  int *p = malloc(sizeof(int)); // 메모리를 한당 받는다. 
  assert(p != NULL);
  printf("(%d) address pointed to by p: %p\n", getpid(), p); // process의 id를 출력한다.
  *p = 0;                                                    // 할당받은 메모리에 0을 넣는다. 
  while (1) {
    Spin(1);
    *p = *p + 1;
    printf("(%d) p: %d\n", getpid(), *p); // process의 id와 p의 값을 출력한다.
  }
}

```

- 위 코드는 메모리를 사용하는 프로그램이다. 이 프로그램은 메모리를 할당 받고, 1초에 한 번씩 메모리에 있는 값을 1씩 증가시킨다.

- 그러면서 주석에 있는 내용처럼 process의 id와 메모리 주소를 출력한다.

다수의 프로그램을 동시에 실행시킨 결과는 다음과 같다.

```shell
$ gcc -o MEM MEM.c
$ ./MEM & ; ./MEM & ; ./MEM & ;

[1] 7890
[2] 7891
[3] 7892

(7890) memory address of p: 0x200000000
(7891) memory address of p: 0x200000000
(7892) memory address of p: 0x200000000
(7890) p: 0
(7891) p: 0
(7892) p: 0
(7890) p: 1
(7891) p: 1
(7892) p: 1
(7890) p: 2
(7891) p: 2
(7892) p: 2
(7890) p: 3
(7891) p: 3
(7892) p: 3
...
```
- 주목해야 할 결과값은 메모리 주소이다. 프로그램이 실행되는 메모리 주소는 모두 같다.

- 이 역시 메모리 가상화의 결과이다. 프로그램은 자신만의 메모리를 가지고 있다고 생각하지만, 실제로는 운영체제가 제공하는 가상 메모리를 사용하고 있다.

- 이와 같은 메모리의 가상화 역시 이 책에서 다루게 된다.


### 02.3 병행성 (Concurrency)

- 프로그램이 한 번에 많은 일을 하려 할 때 (동시에) 발생하는 문제를 다룬다.

- 사실 운영체제는 한 프로세스 실행, 다음 프로세스 실행, 다음 프로세스 실행, ... 이런식으로 프로세스를 번갈아가며 실행하는데 이 때 발생하는 문제들이 생긴다.

```c
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

volatile int counter = 0;
int loops;

// loop 횟수만큼 counter를 증가시키는 함수
void *worker(void *arg) {
  int i;
  for (i = 0; i < loops; i++) {
    counter++;
  }
  return NULL;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "usage: threads <value>\n");
    exit(1);
  }
  loops = atoi(argv[1]); // 인자로 받은 값을 loops에 저장한다.

  pthread_t p1, p2;
  printf("Initial value : %d\n", counter);
  
  double t1 = GetTime();
  pthread_create(&p1, NULL, worker, NULL); // thread p1 worker 함수 실행
  pthread_create(&p2, NULL, worker, NULL); // thread p2 worker 함수 실행
  pthread_join(p1, NULL);
  pthread_join(p2, NULL);
  double t2 = GetTime();
  printf("Final value : %d\n", counter);
  printf("Time : %f\n", t2 - t1);
  return 0;
}
```

- 이 코드는 복잡해보이지만 전혀 그렇지 않다. thread 2개를 생성하고, 각각의 thread에서 worker 함수를 실행한다.

- worker 함수는 인자로 받은 loop 횟수만큼 counter를 증가시킨다.

- 실제 실행 결과는 다음과 같다.

```shell
$ gcc -o THREAD THREAD.c -lpthread
$ ./THREAD 1000

Initial value : 0
Final value : 2000
Time : 0.000000
```

- 일단 값이 2000이 나왔다. 이는 2개의 thread가 각각 1000번씩 counter를 증가시켰기 때문이다.

- 더 많은 횟수로 실행한 결과는 다음과 같다.

```shell
$ ./THREAD 100000

Initial value : 0
Final value : 143012
Time : 0.000000
```

- 이번에는 143012가 나왔다. 인자 * 스레드의 개수 만큼 counter가 증가해야 하는데 그렇지 않은 이유는 아래와 같다.

- 실제 카운터를 증가시키는 코드의 로직은 다음과 같다.
  - counter를 메모리에서 레지스터로 불러온다.
  - 레지스터에 1을 더한다.
  - 레지스터의 값을 메모리에 저장한다.

- 이 세가지 작업이 원자성을 가지지 않는다. 즉, 다른 스레드가 counter를 읽어가는 동안 다른 스레드가 counter를 증가시킬 수 있다.

- 이러한 문제가 Concurrency 문제이며, 이러한 문제를 해결하기 위한 방법들을 이 책에서 다룬다.

> **병행성의 핵심 질문 : 올바르게 동작하는 병행 프로그램은 어떻게 작성해야 하는가**
> 같은 메모리 공간에 다수의 쓰레드가 동시에 실행단다고 할 때, 올바르게 동작하는 프로그램을 어떻게 잘성 할 수 있는가? 운영체제는 어떠한 기본 기법을 제공하는가, 하드웨어는 어떠한 지원을 제공하는가?
> 병행성 문제를 해결하기 위해 기본 기법들과 하드웨어 기능을을 어떻게 사용할 수 있는가?

### 02.4 영속성 (Persistence)

- RAM은 읽고 쓰기가 레지스터, 캐시에 비해서는 느리지만, 그래도 충분히 빠르다.

| 작업          | 시간 (현실 시간으로 환산) |
|---------------|------------------------|
| CPU 사이클    | 1초                    |
| L1 캐시 접근 | 2초                    |
| L2 캐시 접근 | 7초                    |
| L3 캐시 접근 | 1분                    |
| RAM 접근      | 4분                    |
| NVMe SSD 접근 | 17시간                 |
| 일반 SSD 접근 | 1.5일 ~ 4일            |
| 일반 하드디스크 접근 | 1 ~ 9달         |
| 서울 - 샌프란시스코 패킷 전송 시간 | 14년 |
- 출처 : [내가 c언어를 배우기 전에 알았다면 좋았을 것들](https://modoocode.com/315)

- 그러나 RAM은 전원이 꺼지면 모든 데이터가 사라진다. 

- 그래서 우리는 데이터를 영구적으로 저장할 수 있는 영속성을 구현하기 위해 하드웨어와 소프트웨어가 필요하다.

- 많이들 알고 있겠지만, 하드웨어는 I/O 장치 형태로 제공되며, 요즘은 주로 SSD를 사용한다.

- 디스크를 관리하는 운영체제 소프트웨어는 파일 시스템이라고 한다. (파일시스템은 사용자가 생성한 파일을 시스템의 디스크에 안전하고 효율적으로 저장할 `책임`이 있다.)

- 다행인 것은, 이러한 영속성 저장소는 가상화 하지 않는다!

- 영속성과 관련한 핵심 질문은 다음과 같다.

> **영속성의 핵심 질문 : 데이터를 영속적으로 저장하는 방법은 무엇인가**
> 파일 시스템은 데이터를 여속적으로 관리하는 운영체제의 일부분인다. 올바르게 동작하기 위해서는 어떤 기법이 필요할까? 이러한 작업 성능을 높이기 위해서 어떤 기법과 정책이 필요할까?
> 하드웨어와 소프트웨어가 실패하더라도 올바르게 동작하려면 어떻게 해야 할까?
