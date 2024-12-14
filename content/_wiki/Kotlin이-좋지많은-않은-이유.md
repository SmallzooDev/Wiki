---
title: Kotlin을 공부하며 아쉬운 부분 🤐
summary: 먹고 살기위해 하는거지
date: 2024-12-14 13:34:21 +0900
lastmod: 2024-12-14 13:34:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

> 자바는 좋고, 러스트도 좋지만 코틀린은 특유의 슈가신택스가 마냥 달갑지 않은 경우가 있는 것 같다.
> 코틀린 공부가 더딘 이유기도 한 것 같다. 하지만 진짜 쓰게 될 때를 대비해 공부하면서 느낀 소감을 작성하고 싶어졌다.
> 물론 백개의 편한 슈가 신택스중에 한두가지의 아쉬운점이라 내가 코틀린이라는 언어를 감히 비판하는게 아닌 읽다가 잘 인지했으면 해서 기록하는 개인적인 소감일 뿐이다.

### 01. 엄청엄청 유연한 식(expression)과 문(statement)의 경계

```kotlin
fun getValue(value: Int?): Int {
    return value ?: return 0
}
```

```kotlin
fun getValue(value: Int?): Int {
  return value ?:0
}
```

코틀린의 특정 statement(throw, return등과 함깨하는)들은 값으로 취급되는 표현식처럼 쓸 수 있다.
그래서 이 두가지가 가능하고, 이 두가지가 가능하다는건 물론 유용할수도 있지만, 오히려 헷갈리는 경우도 많은 것 같다.
