---
title: 코틀린 함수형 프로그래밍
summary: 
date: 2025-04-27 11:20:59 +0900
lastmod: 2025-04-27 11:45:12 +0900
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

