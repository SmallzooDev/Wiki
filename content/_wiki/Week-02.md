---
title: 
summary: 
date: 2024-04-27 13:42:50 +0900
lastmod: 2024-04-27 13:42:50 +0900
tags: 
categories: 
description: 
showToc: true
---

## 05. 막간 : 프로세스 API 

> 개념적인 내용이 아닌 실제적인 측면에서 코드를 보는 장은 막간이라고 별도 표기한다.

이번 절에서는, Unix 시스템의 프로세스 생성에 관해 배운다.

Unix는 프로세스를 생성하는 시스템콜로 다음 두가지를 제공한다.

- `fork()`

- `exec()`

- 그리고 `wait()` 함수를 통해 자식 프로세스가 종료될 때까지 기다릴 수 있다.

> 핵심 질문 : 프로세스를 생성하고 제어하는 방법, 프로세스를 생성하고 제어하려면 운영체제가 어떤 인터페이스를 제공해야 하는가?
> 유용성, 편리성, 그리고 성능을 위해서는 어떻게 인터페이스를 설계해야 하는가?

### 5.1 fork()

- 참고로 `fork()` 시스템콜은 가장 이해하기 힘들거나 적어도 가장 특이한 시스템콜 중 하나이다.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  printf("hello world (pid:%d)\n", (int) getpid());
  int rc = fork();
  
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  } else if (rc == 0) {
    printf("hello, I am child (pid:%d)\n", (int) getpid());
  } else {
    printf("hello, I am parent of %d (pid:%d)\n", rc, (int) getpid());
  }
  
  return 0;
}
```

```shell
gcc -o c1 c1.c -Wall
./c1
```

```shell
hello world (pid:4605)
hello, I am parent of 4607 (pid:4605)
hello, I am child (pid:4607)
```

- 'hello world'는 부모 프로세스가 출력하고 본인 pid를 출력했다.

- `fork()` 시스템콜 이후 if 분기를 자세히 볼 필요가 있다.

- 부모 프로세스 (pid 4605)는 else 분기로 가고 자식 프로세스 (pid 4607)는 else if 분기로 간다.

- 이해하기 힘든 포인트는, `fork()` 시스템콜 이후에는 두 개의 똑같은(더 정확히 말하면 거의 똑같은)  프로세스가 생성된다는 것이다.

- 더 이해하기 힘든 포인트는, 자식 프로세스가 `main()` 함수의 처음부터 실행하지 않는다는 것이다.

- 거의 동일한 프로세스의 복사본이 생성되고, 그 복사본은 스스로의 주소 공간, 레지스터, 자신의 pc값을 갖지만 매우 중요한 차이점이 있다.

- 부모 프로세스는 `fork()` 시스템콜 이후에 자식 프로세스의 pid를 반환하고, 자식 프로세스는 0을 반환한다는 것이다.

- 이것은 부모 프로세스와 자식 프로세스가 서로 다른 일을 할 수 있게 해준다.

### 5.2 wait()

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

int main(int argc, char *argv[]) {
  printf("hello world (pid:%d)\n", (int) getpid());
  int rc = fork();
  
  if (rc < 0) {
    fprintf(stderr, "fork failed\n");
    exit(1);
  } else if (rc == 0) {
    printf("hello, I am child (pid:%d)\n", (int) getpid());
  } else {
    int wc = wait(NULL);
    printf("hello, I am parent of %d (wc:%d) (pid:%d)\n", rc, wc, (int) getpid());
  }
  
  return 0;
}
```

- `wait()` 함수를 사용하면 부모 프로세스가 자식 프로세스가 종료될 때까지 기다릴 수 있다.

- 그래서 아래처럼 의도한 실행 순서를 보게 된다.

```shell
hello world (pid:4605)
hello, I am child (pid:4607)
hello, I am parent of 4607 (pid:4605)
```


### 5.3 exec()

- `exec()` 시스템콜은 새로운 프로그램을 실행하는데 사용된다.

- p2.c 프로그램은 같은 프로그램의 카피를 실행할때만 유용하다.

- p3.c 프로그램은 `exec()` 시스템콜을 사용하여 wc 프로그램을 실행한다.

- wc는 unix 명령어로 파일의 줄, 단어, 문자 수를 세는 프로그램이다.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    printf("hello world (pid:%d)\n", (int) getpid());
    int rc = fork();
    if (rc < 0) {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) {
        // child (new process)
        printf("hello, I am child (pid:%d)\n", (int) getpid());
        char *myargs[3];
        myargs[0] = strdup("wc");   // program: "wc" (word count)
        myargs[1] = strdup("p3.c"); // argument: file to count
        myargs[2] = NULL;           // marks end of array
        execvp(myargs[0], myargs);  // runs word count
        printf("this shouldn't print out");
    } else {
        // parent goes down this path (original process)
        int wc = wait(NULL);
        printf("hello, I am parent of %d (wc:%d) (pid:%d)\n",
	       rc, wc, (int) getpid());
    }
    return 0;
}
```

실행 결과
```shell
❯ ./p3
hello world (pid:7119)
hello, I am child (pid:7120)
      30     120     896 p3.c
hello, I am parent of 7120 (wc:7120) (pid:7119)
❯ wc p3.c
      30     120     896 p3.c
```
- 참고 : wc 프로그램이 잘 동작하는지 보기 위해 쉘에서 별도로 한 번 더 실행했다.

```c
        char *myargs[3];
        myargs[0] = strdup("wc");   // program: "wc" (word count)
        myargs[1] = strdup("p3.c"); // argument: file to count
        myargs[2] = NULL;           // marks end of array
        execvp(myargs[0], myargs);  // runs word count
```

- `execvp()` 함수는 `exec()` 시스템콜을 호출하는데, `p3.c`파일을 인자로 준 `wc` 프로그램을 실행한다.

```shell
      30     120     896 p3.c
```

- 그래서 위와 같이 `p3.c` 파일의 줄, 단어, 문자 수를 세는 결과를 출력한다.

- 해당 `wc` 프로그램이 끝나면, 자식 프로세스는 종료되고,

```c
        // parent goes down this path (original process)
        int wc = wait(NULL);
        printf("hello, I am parent of %d (wc:%d) (pid:%d)\n",
        	       rc, wc, (int) getpid());
```

- `wait()` 함수를 통해 기다리고 있던부모 프로세스가 재실행되어 아래 문구를 출력한다.
 
```shell
hello, I am parent of 7120 (wc:7120) (pid:7119)
```
- `fork()`역시 매우 독특하다.

- `fork()` 시스템콜은 실행할 프로그램(executable)과 몇개의 인자를 제공한다.

- `fork()` 시스템콜이 호출되면, 인자로 제공한 프로그램의 코드가 로드되고, 지금 코드의 세그먼트와 정적 데이터를 덮어쓴다.

- 또한 힙이나 세그먼트 같은 메모리 공간은 새로 초기화된다.

- 즉 새로운 프로세스를 실행시키는것이 아니라, 지금 프로세스를 새로운 프로그램으로 덮어쓰는 것이다.

- 그 증거로 `exec()` 시스템콜 이후의 기존 프로세스는 실행되지 않는다 ("this shouldn’t print out").

- 즉 다른 `program`을 덮어씌워 실행시키는 것이다.

- PID는 변하지 않고, 말인 즉슨 새로운 프로세스를 실행시키는것은 아닌, 다른 프로그램을 실행시키는 것이다.

> 프로그램과 프로세스의 차이에 대한 감을 잡기 좋은 예제이다.


> Tip : Getting It Right
> Lamson은 "옳은 일을 하라" 그리고 그것은 어떠한 추상화나 단순화로도 대체될 수 없다고 말한다.
> 책에서는 다양한 프로세스의 생성 디자인이 있을 수 있지만,
> 정확히 해야 할 일 은 `fork()`, `exec()`과 같이 단순하고 올바른 방법이 이라며 강조했다.


### 5.4 왜, 이런 API를?

- 프로세스를 생성하는 간단한 일에 왜이렇게 이상하고 복잡한 인터페이스를 제공하는 것일까?

- 밝혀진 바에 따르면, Unix의 Shell을 구현하려면 `fork()`와 `exec()`의 분리는 꼭 필요했다.

- 쉘은 코드를 `fork()` 이후, 그리고 `exec()`이전에 실행해야 했기 때문이다.

- 쉘은 기본적으로 단순한 유저 프로그램이다.

- 프롬프트를 보여주고, 입력을 기다린다.

- 만약 커맨드(일반적으로 실행 가능한 프로그램과 인자)를 입력받으면, 
 
- (대부분의 경우에) 쉘은 해당 실행 가능한 프로그램이 파일시스템의 어디에 있는지 찾는다.

- 그리고 `fork()`를 호출하여 커맨드를 실행할 자식 프로세스를 생성한다.

- 그리고 `exec()`를 호출하여 그 프로그램을 실행한다.

- 마지막으로 `wait()`를 호출하여 자식 프로세스가 종료될 때까지 기다린다.

- 자식프로세스가 종료되었다면, 쉘은 `wait()`의 결과를 리턴하고 다시 프롬프트를 보여준다(다음 커맨드를 위해).

- `fork()`와 `exec()`의 분리는 이런 상태에서 다양한 유용한 것들을 쉽게 할 수 있도록 만들어준다.

```shell
wc p3.c > newfile.txt
```
- 위의 예제어서, wc 프로그램의 출력은 newfile.txt 파일로 리다이렉트된다.

- 쉘이 이걸 해내는 방법은 매우 단순한데, 자식스포세스가 생성되면, 쉘은 standard output을 닫고, newfile.txt를 open한다.

- 그래서 wc 프로그램의 출력은 화면에 뿌려지는대신, newfile.txt로 들어가게 된다.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <assert.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    int rc = fork();
    if (rc < 0) {
        // fork failed; exit
        fprintf(stderr, "fork failed\n");
        exit(1);
    } else if (rc == 0) {
    	  // child: redirect standard output to a file
	      close(STDOUT_FILENO); 
	      open("./p4.output", O_CREAT|O_WRONLY|O_TRUNC, S_IRWXU);

	     // now exec "wc"...
        char *myargs[3];
        myargs[0] = strdup("wc");   // program: "wc" (word count)
        myargs[1] = strdup("p4.c"); // argument: file to count
        myargs[2] = NULL;           // marks end of array
        execvp(myargs[0], myargs);  // runs word count
    } else {
        // parent goes down this path (original process)
        int wc = wait(NULL);
      	assert(wc >= 0);
    }
    return 0;
}
```

- 위의 작업을 보여주는 코드이다.

- fork()를 호출해서 자식 프로세스(기존의 프로세스의 복사본)를 생성한다.

- 자식 프로세스가 타게될 분기에서는 close(STDOUT_FILENO)로 표준 출력을 닫는다.

- 그리고 open()을 호출하여 p4.output 파일을 열고, 그 파일을 표준 출력으로 사용한다.

- 그리고 exec()의 실행으로 인해서 기존의 프로그램이 wc로 덮어씌워지고 그동안의 출력은 p4.output 파일로 리다이렉트된다.

- 유닉스의 파이프는 이와 같은 방식으로 동작한다.

- 더 정확히는 한 프로세스의 출력이 커널 내 파이프(큐)로 들어가고, 다른 프로세스는 그 파이프로부터 입력을 받는다.

- 이러한 방식으로 프로세스의 체인을 구현해뒀다.

> 추가적으로 찾아본 내용 :
> `pipe()` 시스템 호출은 파이프를 생성하는데 사용된다,
> `pipe()` 를 호출하면 커널 내부에 파이프라고 불리는 메모리 버퍼가 생성된다.
> 실제로 큐로 구현되어있어, 한쪽 끝에서 데이터가 쓰이고 다른 한 쪽 끝에서 데이터가 읽힌다. (읽기 쓰기용 디스크립터가 각각 있음)

### 5.5 프로세스 제어와 사용자.

- 유닉스에는 fork(), exec(), wait()와 같은 프로세스 제어를 위한 api들 외에도 다양한 프로세스 제어를 위한 api들이 있다.

- 예를 들어, `kill()` 시스템콜은 다른 프로세스를 멈추거나 끝내기 위한 **시그널** 을 보내기 위해 사용된다.

- **시그널이라는 운영체제의 매커니즘은 외부 사건을 프로세서에 전달하는 토대이다.**

- 실제로 `signal()` 시스템콜은 시그널을 받았을 때 어떻게 반응할지를 알려줄 수 있도록 되어있는 시스템 콜이다.

- 이러한 프로세스 제어를 위한 시스템콜을 알게된다면 자연스럽게 보안과 관련된 이슈들도 알게된다.

- 예를 들어, 누구나 다른 프로세스를 죽일 수 있는 권한을 가지고 있으면, 그것은 보안 이슈가 될 수 있다.

- 그래서 `user`와 같은 개념을 도입하였다.

- 간단하게만 알아보면 `user`는 인증과정을 거쳐 시스템에 로그인 할 수 있고, 하나 이상의 프로세스를 실행할 수 있는 권한을 가진다.

- 일반적으로 그 프로세스들에 대해서만 제어 권한을 가진다.

- **운영체제는 CPU, 메모리와 디스크 같은 자원을 각 사용자와 프로세스들에 할당하여 전체적인 시스템의 목적에 도달하도록 만드는 역할을 한다.**

### 5.7 요약

- 이번 장에서는 프로세스를 다루는 API중 일부를 알아봤다!

- 각 프로세스는 이름이 있다. 대부분의 시스템에서 이름은 PID라는 번호이다.

- UNIX 시스템에서는 fork 시스템 콜을 사용하여 새로운 프로세스를 생성한다. 
- 생성의 주체가 되는 프로세스는 부모 프로세스, 생성된 프로세스는 자식 프로세스라고 한다. 
  
- `wait()` 시스템 콜을 사용하여 부모 프로세스가 자식 프로세스가 종료될 때까지 기다릴 수 있다.

- `exec()` 시스템 콜을 사용하여 자식 프로세스가 부모와의 연관성을 완전히 끊어서 새로운 프로그램을 실행할 수 있다.

- UNIX 쉘은 보통 fork, exec, wait를 사용하여 사용자의 명령을 시작한다. fork와 exec을 분리하였기에 실행 중인
- 프로그램을 조작하지 않고도 입/출력 재지정, 파이프, 그리고 다른 기능을 처리하는것이 가능하다.

- 프로세스 제어는 시그널이라는 형태로 제공되며, 이를 활용하여 작업을 멈추고, 재시작하거나, 종료할 수 있다.

- 누가 어떠한 프로세스를 제어 할 수 있는지는 사용자라는 개념속에 포함되어있다.

- 슈퍼사용자는 시스템의 모든 프로세스를 제어할 수 있지만, 일반 사용자는 자신의 프로세스만을 제어할 수 있다.


