---
title: rust smart pointers
summary: 
date: 2025-05-01 16:49:21 +0900
lastmod: 2025-05-02 00:11:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

# 15.0 Smart Pointers
> Smart pointers, on the other hand, are data structures that act like a pointer but also have additional metadata and capabilities.
> This pointer enables you to allow data to have multiple owners by keeping track of the number of owners and, when no owners remain, cleaning up the data.

- burrow 시스템과 연관해서 봐야하는것들이 있다.
	- 참조는 데이터를 burrow 해주지만,
	- smart pointer는 해당 데이터를 소유한다.

| Aspect            | Reference (`&T`)                | Smart Pointer (`Box<T>`, etc.)   |
| ----------------- | ------------------------------- | -------------------------------- |
| Ownership         | Borrows only                    | Owns the data                    |
| Memory Allocation | Stack (points to stack or heap) | Usually heap                     |
| Lifetimes         | Tied to scope of borrow         | Can live beyond original owner   |
| Mutability Rules  | Strict compile-time rules       | Some allow runtime mutability    |
| Use Case          | Fast, safe temporary access     | Complex ownership/sharing models |
> Though we didn’t call them as such at the time, we’ve already encountered a few smart pointers in this book, including String and Vec<> in Chapter 8. Both these types count as smart pointers because they own some memory and allow you to manipulate it. They also have metadata and extra capabilities or guarantees. String, for example, stores its capacity as metadata and has the extra ability to ensure its data will always be valid UTF-8.
- 위 내용을 요약하면, 메모리(힙의)를 소유하고, 조작할 기능이 있다면 스마트포인터와 본질적으로 다르지 않다는 것, 대표적으로 문자열과 벡터같은 것들이 있다고 말한다.
- 결론은 힙 메모리를 소유하는 구조체일 뿐이지만 몇가지를 더 구현것
	- 몇가지의 예시는 Deref, Drop등이 있다.
	- Deref은 참조처럼 동작하기 위한 기능을 정의한 것 이고,
	- Drop은 구조체 메모리 정리를 위해서 구현해야한다.

> 스마트 포인터는 결국 **“어떻게 소유하고, 언제 해제하며, 누가 접근할 수 있게 할지”에 대한 책임을 가지는 구조체**이자 그 목적 자체를 위해서 설계된 구조체이다.


이 장에서 다룰 표준 라이브러리의 대표적인 스마트 포인터들
1. Box
	- 값을 힙(Heap)에 저장할 수 있도록 해줌
2. Rc
	- 참조 카운팅 기반 소유권: 여러 소유자가 하나의 데이터를 공유할 수 있음
3. RefCell
	- Ref와 RefMut를 통해 접근
	- 런타임에 Burrow checker를 수행 (컴파일 타임이 아닌)

추가로 다룰 개념
- Interior Mutability (내부 가변성):
외부적으로는 불변처럼 보여도, 내부 데이터를 가변적으로 조작할 수 있도록 허용하는 패턴
- 순환 참조(Reference Cycles):
- Rc 등을 사용할 때 잘못하면 메모리 누수가 발생할 수 있음
- 이를 예방하는 방법도 설명함

## 15.1 Using Box to Point to Data on the Heap
> Boxes don’t have performance overhead, other than storing their data on the heap instead of on the stack. But they don’t have many extra capabilities either. You’ll use them most often in these situations:
- Box는 오버헤드가 없음에도 다양한 기능들을 제공한다.
- 아래는 가장 대표적인 예시들

컴파일 타임에 크기를 알 수 없는 타입을 사용해야 하지만, 정확한 크기를 요구하는곳에 써야 할 상황
- 대표적으로 재귀적인 자료구조
```rust
enum List {
    Cons(i32, List), // ❌ 컴파일 에러 발생
    Nil,
}

fn main() {
    let list = Cons(1, Cons(2, Cons(3, Nil)));
}
```

```rust
error[E0072]: recursive type `List` has infinite size
```
- 재귀적으로 끝없이 확장될 수 있어서 컴파일 시 계산할 수 없다.
```rust
enum List {
    Cons(i32, Box<List>), // ✅ Box를 사용해 고정 크기 포인터로 만듦
    Nil,
}

fn main() {
    let list = List::Cons(1, Box::new(
                List::Cons(2, Box::new(
                List::Cons(3, Box::new(List::Nil)))));
}
```
- 위처럼 Box를 통해 해결

큰 데이터를 복사하지 않고 넘기고 싶을 때 (Box로 move만 하고 실제 데이터는 그대로)
```rust
fn process(data: Box<[u8; 1000000]>) {
    println!("처리 완료");
}

fn main() {
    let big = Box::new([0u8; 1000000]); // 실제 데이터는 heap에
    process(big); // 포인터만 move됨, 복사 없음
}
```
- 정확히는 소유권을 '이동시키며' 값을 넘기고싶을때 사용한다.
- 소유권을 가지고 오므로 함수 내에서 자유롭게 사용가능하며 owner의 수명 제약도 상관없이 쓸 수 있다

타입은 모르고, 트레잇만 중요할 때
```rust
trait Draw {
    fn draw(&self);
}

struct Button;
struct Checkbox;

impl Draw for Button {
    fn draw(&self) { println!("Button 그리기"); }
}
impl Draw for Checkbox {
    fn draw(&self) { println!("Checkbox 그리기"); }
}

fn main() {
    let ui: Vec<Box<dyn Draw>> = vec![
        Box::new(Button),
        Box::new(Checkbox),
    ];

    for comp in ui {
        comp.draw();
    }
}
```
