---
title: 
summary: 
date: 2024-05-15 17:35:10 +0900
lastmod: 2024-05-15 17:35:10 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

```cpp

int main() {
  const char* test1 = "Hello World";
  // test1[0] = 'A'; // error: assignment of read-only location '*(test1 + 0)'
  
  const char test2[] = "Hello World";
  test2[0] = 'A'; // ok
}
```

- 배열 `이름`은 배열의 시작 주소를 가리키는 상수 포인터이다.

- 인덱스 연산자 []는 배열 요소에 접근할 때 사용되며, 이는 사실 포인터 연산으로 구현된다. 

- test1[i]는 내부적으로 *(test1 + i)로 변환된다. 

- 여기서 arr은 배열의 첫 번째 요소의 주소를 가리키는 포인터로 간주되며, i는 인덱스이다.
