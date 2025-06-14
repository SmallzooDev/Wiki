---
title: 세마포어와 뮤텍스 🔄
summary: 여러가지 사유로 자주 맞닥뜨려서 다시 정리
date: 2025-06-12 20:09:32 +0900
lastmod: 2025-06-15 00:18:31 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

> 출처 : 공룡책과 ostep 

[공룡책](https://product.kyobobook.co.kr/detail/S000001868743), [ostep](https://product.kyobobook.co.kr/detail/S000001732174)

### 경쟁 조건, 임계 영역
> 여러개의 프로세스가 동일한 데이터에 접근했을 때, 접근이 일어난 순서에 따라서 결과값이 달라지는것을 경쟁조건, Race condition이라고 한다.

> Critical section problem은 프로세스들이 협력적으로 데이터를 공유할 수 있도록 그들의 활동을 Synchronize하는 데 사용할 수 있는 프로토콜을 설계하는 것이다.
- 여러 프로세스들에서 공유 데이터에 접근하는 부분의 코드를 임계영역으로 정의한다.
- 그리고 해당 영역에 접근하기 위해 permission을 요구하도록 한다.
	- 이 요청을 보내는쪽을 entry section이라고 한다.
	- 그리고 entry section은 exit section으로 끝나야 한다.
	- 마지막으로 exit section 이후에도 남아있는 코드를 remainder section이라 한다.
```bash
do {
    // entry section (진입 구역)
    
    // critical section (임계 구역)
    
    // exit section (종료 구역)
    
    // remainder section (나머지 구역) - 임계구역과 관련없는 작업
    
} while (true);
```
- Critica section problem은 아래 세가지를 만족해야 한다.
	- Mutual exclusion : 특정 프로세스가 임계영역 코드를 실행중이라면 다른 프로세스는 임계영역 코드를 실행할 수 없다.
	- Progress : 만약 아무 프로세스도 임계영역을 실행중이지 않고, 어떤 프로세스가 임계영역 진입을 원한다면, remainder영역을 실행중이지 않은 프로세스들만 어떤 프로세스가 다음이 될지에 대한 결정에 참여 할 수 있다. 그리고 이러한 결정은 무기한 지연되어서는 안된다.
	- Bounded waiting : 한 프로세스가 자신의 임계 구역에 진입 요청을 한 후, 그 요청이 승인되기 전까지 다른 프로세스들이 자신의 임계 구역에 진입할 수 있는 횟수에 대한 한계 또는 제한이 존재한다.
> 참고로 싱글코어 프로세서라면 세상 쉬운 문제이다. 공유자원을 수정할 때는 인터럽트를 막아버리면 된다.
 
> 또한 이 문제는 Preemptive Kernels에서 발생한다. Nonpreemptive Kernels는 커널에 다른프로세스가 진입해있다면 커널을 양보할 때 까지 기다린다


