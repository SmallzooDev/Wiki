---
title: 코틀린 함수형 프로그래밍
summary: 
date: 2025-04-27 11:20:59 +0900
lastmod: 2025-04-27 23:22:27 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 함수 타입
---
### 함수 타입 정의
- (T) -> Boolean : Boolean을 반환하는 함수 Predicate
- (T) -> R : 값 하나를 다른 값으로 변환하는 함수 transfrom
- (T) -> Unit : Unit을 반환하는 함수 operation

### 함수 타입 활용
- invoke라는 단 하나의 메서드만 제공함, 명시적 invoke호출과 ()연산자로 호출
- 함수타입 파라미터를 ()? 로 감싸서 널러블함을 표현할 수 있음 (이경우는 명시적 invoke만 가능)

### named parameter
- 함수 타입을 정의 할 때 'named parameter'를 사용 가능
- 오직 개발 편의를 위한 것

## 익명 함수
---

- 익명함수는 함수 타입 객체를 반환하는 표현식
- generic, default parameter는 지원하지 않음
```kotlin
val add2 = fun(a: Int, b: Int) = a + b
```
- 익명함수 자체는 요즘 사용하지 않는다고 함
	- 람다가 더 짧고 지원이 더 잘됨
	- 인텔리제이는 람다만 힌트를 제공
- 그래도 아래와 같은 상황에는 아직 유용
	- return 범위 명확히 구분하고 싶을 때
	- 타입 명시적 선언 (람다보다 깔끔)
	- return을 명시적으로 사용해야 할 때
	- 고차함수 인자가 2개 이상이고 복잡할 때

## 람다 표현식
---
- 익명함수보다 더 짧은 대안
- 람다 표현식이 더 많은 기능을 지원

| **항목**    | **익명 함수 (anonymous function)**     | **람다식 (lambda expression)**           |
| --------- | ---------------------------------- | ------------------------------------- |
| 작성 방식     | fun 키워드 사용                         | { 파라미터 -> 본문 } 형태                     |
| return 동작 | 로컬 return (해당 함수만 빠져나감)            | 기본적으로 바깥 함수로 비탈출(non-local return) 가능 |
| 타입 추론     | 명확한 타입 명시 가능                       | 타입 추론 많이 의존                           |
| 제어문 사용    | return, break, continue 자유롭게 사용 가능 | 제한 있음 (non-local return 조심)           |
