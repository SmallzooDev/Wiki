---
title: cpp-casting 🐋
summary: 
date: 2024-06-09 17:08:32 +0900
lastmod: 2024-06-09 17:08:32 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

1. static_cast
static_cast는 가장 기본적인 형태의 캐스팅이다. 컴파일 시간에 타입 변환을 수행하며, 컴파일러가 타입 안전성을 어느 정도 보장해 준다. 주로 기본 타입 간의 변환, 명시적 생성자를 사용한 객체 생성, 상속 관계에 있는 클래스 간의 변환 등에 사용된다.

```cpp
Copy code
int a = 10;
double b = static_cast<double>(a); // int를 double로 변환
```

2. dynamic_cast
dynamic_cast는 주로 다형성(polymorphism)을 사용하는 클래스 계층에서의 포인터 또는 참조 타입 변환에 사용된다. 실행 시간에 타입 검사를 수행하여 안전한 타입 변환을 보장해 준다. dynamic_cast는 주로 상속 관계에서 부모 클래스 포인터를 자식 클래스 포인터로 변환할 때 사용되며, 변환이 실패하면 nullptr을 반환한다.
RTTI(Runtime Type Information)를 사용하여 실행 시간에 타입 정보를 확인하므로, dynamic_cast를 사용하려면 반드시 가상 함수(virtual function)가 정의된 클래스여야 한다.


```cpp
Copy code
class Base { virtual void foo() {} };
class Derived : public Base { void foo() override {} };

Base* basePtr = new Derived;
Derived* derivedPtr = dynamic_cast<Derived*>(basePtr); // 성공하면 derivedPtr이 유효한 포인터가 된다
```

3. const_cast
const_cast는 변수의 const 또는 volatile 속성을 제거하거나 추가할 때 사용된다. 주로 기존의 const 객체를 변경해야 할 때 사용되며, 이는 안전하게 사용해야 한다. 비유하자면, const_cast는 책을 읽기 전용으로 두었다가 다시 수정 가능하도록 설정하는 것과 비슷하다.

```cpp
Copy code
const int a = 10;
int* b = const_cast<int*>(&a); // const를 제거하여 a를 수정 가능하게 만든다
```

4. reinterpret_cast
reinterpret_cast는 가장 강력하고 위험한 형태의 캐스팅이다. 포인터나 데이터의 비트 패턴을 단순히 다른 타입으로 해석한다. 주로 포인터 타입 간의 변환이나 비트 패턴을 그대로 유지한 채 다른 타입으로 해석하고자 할 때 사용된다.

```cpp
Copy code
int a = 65;
char* b = reinterpret_cast<char*>(&a); // int 포인터를 char 포인터로 변환
```


