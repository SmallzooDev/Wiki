---
title: rust smart pointers
summary: 
date: 2025-05-01 16:49:21 +0900
lastmod: 2025-05-02 15:04:11 +0900
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
    Cons(i32, &mut List), // or &List
    Nil,

}
```
- 이런 방법도 될 것 같지만 사실 두가지 문제가 있다.
	- 소유권이 아니라 참조를 넘기기 때문에 원본 변수의 라이프타임을 알 수 없고
	- 소유하는게 아님으로 발생하는 문제들이 있다.

```
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
	- 고정크기 포인터로 컴파일타임에 값의 크기를 추론할 수 있고
	- 해당 힙에 저장된 데이터의 소유권을 enum이 가지게 할 수 있다.

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

## 15.1 Treating Smart Pointers Like Reqular References with the Deref Trait
> Implementing the Deref trait allows you to customize the behavior of the _dereference operator_ * (not to be confused with the multiplication or glob operator). By implementing Deref in such a way that a smart pointer can be treated like a regular reference, you can write code that operates on references and use that code with smart pointers too.

### 15.1.1 Following the Pointer to the Value
- Deref를 구현하는 것의 목적은 역참조 연산자 * 을 사용하기 위해서이다.
```rust
fn main() {
	let x = 5;
	let y = Box::new(x);

	assert_eq!(5, x);
	assert_eq!(5, *y);
}
```

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> MyBox<T> {
    fn new(x:T) -> MyBox<T> {
        MyBox(x)
    }
}

impl<T> Deref for MyBox<T> {
    type Target = T;
    
    fn deref(&self) -> &Self::Target {
        &self.0
    }
}
```
- 위의 코드처럼 deref을 구현하면 역참조 연산자를 사용 할 수 있다.
### 15.1.2 Using Box Like Reference
> The reason the deref method returns a reference to a value, and that the plain dereference outside the parentheses in *(y.deref()) is still necessary, is to do with the ownership system If the deref method returned the value directly instead of a reference to the value, the value would be moved out of self. We don’t want to take ownership of the inner value inside MyBox<> in this case or in most cases where we use the dereference operator.
- 값을 반환하지 않고 참조를 반환하는 이유는 소유권이 넘어가는거고 그걸 원치 않기 때문이다.
- 그래서 실질적으로 컴파일러는 역참조 연산자를 만났을 때 `*(y.deref())`를 호출해주는 것이다.
- `*` 연산자는 우리가 코드에서 `*`를 사용할 때마다, 먼저 deref 메서드를 호출하고 그 결과에 대해 다시 한 번 `*` 연산자를 호출하는 방식으로 한 번만 대체된다. 이 `*` 연산자의 치환(substitution)은 무한히 재귀되지 않는다.

```rust
use std::ops::Deref;

struct MyBox<T>(T);

impl<T> Deref for MyBox<T> {
    type Target = T;
    fn deref(&self) -> &T {
        &self.0
    }
}

fn main() {
    let x = MyBox::new(MyBox::new(5));
    
    // 한 번의 * => deref() 호출 1번
    let inner = *x; // 타입은 MyBox<i32>

    // 다시 * => deref() 호출 1번
    let value = *inner; // 타입은 i32

    assert_eq!(value, 5);
}

impl<T> MyBox<T> {
    fn new(x: T) -> Self {
        MyBox(x)
    }
}
```
- 즉 위의 케이스에서는 명시적으로 2번의 호출을 해줘야 원본 값을 얻을수 있다는 것이다.

### 15.1.3 Implicit Deref Coercions with Fuctions and Methods
> _Deref coercion_ converts a reference to a type that implements the Deref trait into a reference to another type. For example, deref coercion can convert &String to &str because String implements the Deref trait such that it returns &str. Deref coercion is a convenience Rust performs on arguments to functions and methods, and works only on types that implement the Deref trait. It happens automatically when we pass a reference to a particular type’s value as an argument to a function or method that doesn’t match the parameter type in the function or method definition. A sequence of calls to the deref method converts the type we provided into the type the parameter needs.

- Deref Coercion은 함수나 메서드의 인자로 전달한 값들이 불일치하면서 Deref를 구현했을 때, 연쇄적인 역참조를 자동으로 수행해줘서 타입을 맞춰주는 기능이다.
- 대표적으로 &String이 &str로 변환되는걸 볼 수 있는데, 이건 String이 Deref되었을때 &str을 반환하도록 Deref를 구현해뒀기 때문이다.
```rust
// &Box의 참조를 넘김 -> 
// 알아서 Deref 호출해서 &String 넘김 ->
// 알아서 Deref 호출해서 &str을 아규먼트로 전달
fn hello(name: &str) {
    println!("Hello, {name}!");
}

fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&m);
}




// 만약 Coercions가 일어나지 않는다면
fn main() {
    let m = MyBox::new(String::from("Rust"));
    hello(&(*m)[..]);
}
```
동작 메커니즘
1. 컴파일러가 타입 불일치를 감지
2. 컴파일러는 `Deref::deref` 메서드를 필요한 만큼 호출하여 매개변수 타입과 일치하는 참조를 얻음
3. 이 과정은 컴파일 시간에 해결되므로 런타임 성능에 영향을 주지 않음

Deref Coercion과 가변성의 상호작용
- Deref Coercion은 다음 세 가지 경우에 적용됨:
	1. `&T`에서 `&U`로 변환 (조건: `T: Deref<Target=U>`)
	    - 불변 참조에서 불변 참조로 변환
	    - 예: `&String`에서 `&str`로
	2. `&mut T`에서 `&mut U`로 변환 (조건: `T: DerefMut<Target=U>`)
	    - 가변 참조에서 가변 참조로 변환
	3. `&mut T`에서 `&U`로 변환 (조건: `T: Deref<Target=U>`)
	    - 가변 참조에서 불변 참조로 변환
	    - 이는 가능하지만 반대(불변→가변)는 불가능

세 번째 경우가 중요한 이유:
- 가변 참조를 불변 참조로 변환하는 것은 안전 (차용 규칙을 위반하지 않음)
- 불변 참조를 가변 참조로 변환하는 것은 안됨:
    - 러스트의 차용 규칙에 따르면, 가변 참조는 해당 데이터에 대한 유일한 참조여야 함
    - 불변 참조가 유일한 참조라는 보장이 없으므로 가변 참조로 변환할 수 없음

## 15.2 Running Code on Cleanup with the Drop Trait

Drop 트레이트는 스마트 포인터 패턴에서 중요한 트레이트로, 값이 스코프를 벗어날 때 수행할 동작을 사용자가 직접 정의할 수 있게 해줌.

- 값이 스코프를 벗어날 때 자동으로 정리 코드를 실행
- 파일 핸들, 네트워크 연결, 락과 같은 리소스를 해제하는 데 사용
- 메모리 누수를 방지하고 안전한 리소스 관리를 가능하게 함
- 러스트에서는 프로그래머가 매번 리소스를 해제하는 코드를 직접 호출할 필요가 없음
- 컴파일러가 자동으로 값이 스코프를 벗어날 때 정리 코드를 삽입함
- 코드 전체에 정리 코드를 명시적으로 배치할 필요가 없음
```rust
fn drop(&mut self) {
    // 정리 코드 작성
}
```
- 이렇게 drop 메서드만 작성하면됨
- 참고로 `drop` 메서드가 호출된 후에는 러스트 런타임이 해당 값의 메모리를 자동으로 해제. 
- 즉, `self`의 모든 필드들(내부에 있는 `String`, `Vec` 등)도 자동으로 자신들의 `drop` 메서드가 호출되며 정리됨
- 그냥 위의 값이 해제되기전에 수행해야 할 정리작업만 명시하면됨.
```rust
fn main() {
    let c = CustomSmartPointer {
        data: String::from("some data"),
    };
    println!("CustomSmartPointer created.");
    c.drop(); // 컴파일 오류!
    println!("CustomSmartPointer dropped before the end of main.");
}
```
- 명시적으로 직접 호출은 막혀있음
```bash
$ cargo run
   Compiling drop-example v0.1.0 (file:///projects/drop-example)
error[E0040]: explicit use of destructor method
  --> src/main.rs:16:7
   |
16 |     c.drop();
   |       ^^^^ explicit destructor calls not allowed
   |
help: consider using `drop` function
   |
16 |     drop(c);
   |     +++++ ~

For more information about this error, try `rustc --explain E0040`.
error: could not compile `drop-example` (bin "drop-example") due to 1 previous error

```
- `std::mem::drop` 요거 호출하면 됨

## 15.3 Rc, the Reference Counted Smart Pointer
> In the majority of cases, ownership is clear: you know exactly which variable owns a given value. However, there are cases when a single value might have multiple owners. For example, in graph data structures, multiple edges might point to the same node, and that node is conceptually owned by all of the edges that point to it. A node shouldn’t be cleaned up unless it doesn’t have any edges pointing to it and so has no owners.

목적 : 
- 하나의 값에 여러 소유자가 있어야 하는 경우 사용
- 컴파일 시점에 어떤 부분이 마지막으로 데이터를 사용할지 결정할 수 없을 때 활용
- 값에 대한 참조 개수를 추적하여 더 이상 사용되지 않을 때 정리

사용이 필요한 환경 : 
- 프로그램의 여러 부분에서 읽어야 하는 데이터를 힙에 할당할 때
- 컴파일 시점에 어떤 부분이 마지막으로 데이터를 사용할지 결정할 수 없을 때
- 만약 마지막 사용자를 알 수 있다면, 일반적인 소유권 규칙을 사용하는 것이 더 효율적

### 15.3.1 Using Rc to Share Data

![image](https://doc.rust-lang.org/book/img/trpl15-03.svg)
출처 : https://doc.rust-lang.org/book/ch15-04-rc.html#rct-the-reference-counted-smart-pointer

```rust
enum List {
    Cons(i32, Box<List>),
    Nil,
}

use crate::List::{Cons, Nil};

fn main() {
    let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
    let b = Cons(3, Box::new(a));
    let c = Cons(4, Box::new(a));
}
```
- 위와 같이 구현했다고 햇을 때, 아래와 같이 컴파일 에러가 난다.
```bash
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
error[E0382]: use of moved value: `a`
  --> src/main.rs:11:30
   |
9  |     let a = Cons(5, Box::new(Cons(10, Box::new(Nil))));
   |         - move occurs because `a` has type `List`, which does not implement the `Copy` trait
10 |     let b = Cons(3, Box::new(a));
   |                              - value moved here
11 |     let c = Cons(4, Box::new(a));
   |                              ^ value used here after move

For more information about this error, try `rustc --explain E0382`.
error: could not compile `cons-list` (bin "cons-list") due to 1 previous error

```

```rust
enum List {
    Cons(i32, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;

fn main() {
    let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
    let b = Cons(3, Rc::clone(&a));
    let c = Cons(4, Rc::clone(&a));
}
```
- 위와 같이 해결 할 수 있다.
- 만약 c 앞에 d 노드를 붙이고 싶다면 : `let d = Cons(2, Rc::new(c))` 처럼하면 된다.

`Rc::clone(&a)` vs `a.clone()`
- a.clone()을 호출하는 대신 Rc::clone(&a)를 사용할 수 있지만, 컨벤션은 Rc::clone을 사용하는 것.
- Rc::clone의 구현은 clone 구현처럼 모든 데이터의 deep copy를 수행하지 않음.
- Rc::clone 호출은 단지 참조 카운트를 증가시킴
- Rc::clone을 사용함으로써 깊은 복사 종류의 클론과 참조 카운트를 증가시키는 클론을 시각적으로 구분 가능.
	- 코드의 성능 이슈를 찾을 때는 깊은 복사 클론만 고려하고 `Rc::clone` 호출은 무시할 수 있다.

## 15.4 RefCell and the Interial Mutability Pattern
> _Interior mutability_ is a design pattern in Rust that allows you to mutate data even when there are immutable references to that data; normally, this action is disallowed by the borrowing rules. To mutate data, the pattern uses unsafe code inside a data structure to bend Rust’s usual rules that govern mutation and borrowing.

- `RefCell<T>`은 컴파일 시간이 아닌 런타임에 대여 규칙을 확인하는 타입. 
- 이를 통해 일반적인 Rust 규칙에서는 불가능한 상황(혹은 unsafe 사용해야하는 상황)에서 데이터를 변경할 수 있다.

### 15.4.1 Enforcing Borrowing Rules at Runtime with RecCell

먼저 Borrowing check 로직을 리마인드하면:
- 특정 시점에,  _하나의_ 가변 참조 _또는_ 여러 개의 불변 참조를 가질 수 있지만, 둘 다는 안된다.
- 참조는 항상 유효해야 한다.

대여 규칙을 컴파일 시간에 검사하는 장점은 오류가 개발 과정에서 더 일찍 발견되고, 모든 분석이 미리 완료되기 때문에 런타임 성능에 영향을 미치지 않는다는 것. 즉 컴파일 시간에 대여 규칙을 검사하는 것이 대부분의 경우 최선의 선택이며, 이것이 Rust의 기본값인 이유이다.
- 그리고 러스트는 보통 보수적인 방법을 택한다.
- 잘못될 가능성이 남아있는 코드를 컴파일해준다면, 러스트는 신뢰성을 잃는다는 관념 하에 작성되어있따.
- 사용자가 불편하더라도 신뢰성을 지키는 디자인

결론적으로 `RefCell<T>` 타입은 코드가 대여 규칙을 따르지만 컴파일러가 이를 이해하고 보장할 수 없을 때 사용한다.

한 번 다시 요약하면 :
- `Rc<T>`는 동일한 데이터의 다중 소유자를 가능하게 한다. 
	- `Box<T>`와 `RefCell<T>`는 단일 소유자를 가진다.
- `Box<T>`는 컴파일 시간에 검사되는 불변 또는 가변 대여를 허용한다. 
	- `Rc<T>`는 컴파일 시간에 검사되는 불변 대여만 허용한다.
	- `RefCell<T>`는 런타임에 검사되는 불변 또는 가변 대여를 허용한다.
- `RefCell<T>`은 런타임에 검사되는 가변 대여를 허용하기 때문에, `RefCell<T>`이 불변이더라도 `RefCell<T>` 내부의 값을 변경할 수 있다.

### 15.4.2 Interior Mutability: A Mutable Borrow to an Immutable Value

다시 돌아와서 RecCell이 해결해야 하는 상황을 본다
```rust
fn main() {
    let x = 5;
    let y = &mut x;
}
```

```bash
$ cargo run
   Compiling borrowing v0.1.0 (file:///projects/borrowing)
error[E0596]: cannot borrow `x` as mutable, as it is not declared as mutable
 --> src/main.rs:3:13
  |
3 |     let y = &mut x;
  |             ^^^^^^ cannot borrow as mutable
  |
help: consider changing this to be mutable
  |
2 |     let mut x = 5;
  |         +++

For more information about this error, try `rustc --explain E0596`.
error: could not compile `borrowing` (bin "borrowing") due to 1 previous error

```
- 값이 불변으로 보이면서도 메서드 내에서 자신을 변경할 수 있으면 유용한 상황이 있다.
- 컴파일러의 대여 검사기가 이 내부 가변성을 허용하고, 대여 규칙은 런타임에 검사된다. 
- 규칙을 위반하면 컴파일러 오류 대신 `panic!`이 발생하게 한다.

### 15.4.3 A Use Case for Interior Mutability: Mock Objects

일단 그러한 내부가변성이 필요한 상황을 먼저 정의한다:
- 특정 동작을 관찰하고 그 동작이 제대로 구현되었는지 검증하기 위해 모의 객체를 사용하는 상황

```rust
pub trait Messenger {
    fn send(&self, msg: &str);
}

pub struct LimitTracker<'a, T: Messenger> {
    messenger: &'a T,
    value: usize,
    max: usize,
}

impl<'a, T> LimitTracker<'a, T>
where
    T: Messenger,
{
    pub fn new(messenger: &'a T, max: usize) -> LimitTracker<'a, T> {
        LimitTracker {
            messenger,
            value: 0,
            max,
        }
    }

    pub fn set_value(&mut self, value: usize) {
        self.value = value;

        let percentage_of_max = self.value as f64 / self.max as f64;

        if percentage_of_max >= 1.0 {
            self.messenger.send("Error: You are over your quota!");
        } else if percentage_of_max >= 0.9 {
            self.messenger
                .send("Urgent warning: You've used up over 90% of your quota!");
        } else if percentage_of_max >= 0.75 {
            self.messenger
                .send("Warning: You've used up over 75% of your quota!");
        }
    }
}
```

```rust
#[cfg(test)]
mod tests {
    use super::*;

    struct MockMessenger {
        sent_messages: Vec<String>,
    }

    impl MockMessenger {
        fn new() -> MockMessenger {
            MockMessenger {
                sent_messages: vec![],
            }
        }
    }

    impl Messenger for MockMessenger {
        fn send(&self, message: &str) {
            self.sent_messages.push(String::from(message));
        }
    }

    #[test]
    fn it_sends_an_over_75_percent_warning_message() {
        let mock_messenger = MockMessenger::new();
        let mut limit_tracker = LimitTracker::new(&mock_messenger, 100);

        limit_tracker.set_value(80);

        assert_eq!(mock_messenger.sent_messages.len(), 1);
    }
}
```

1. **Messenger 트레잇**
    - send(&self, message: &str) 메서드를 갖고 있음.
    - 이메일이나 문자 전송 같은 역할을 할 수 있음.
    - 실제 전송이 아니라, 테스트에서는 ‘전송이 호출되었는지’를 확인하고 싶음.
2. **LimitTracker**
    - 어떤 값이 max 값을 넘으면, Messenger를 통해 경고 메시지를 전송함.
    - 그런데 set_value는 반환값이 없기 때문에 외부에서 호출 결과를 직접 확인할 수 없음.
    - 따라서 **Messenger 트레잇을 구현한 모의 객체(mock object)** 가 필요함.
3. **MockMessenger**
    - 실제로 메시지를 전송하지 않고, `Vec<String>`에 메시지를 저장만 함.
    - 이렇게 저장된 메시지를 테스트 코드에서 검사해서, 동작이 제대로 되었는지 확인할 수 있음.
4. **문제점: 러스트의 borrow checker 에러**
    - send는 &self로 선언되어 있어서 **불변 참조**임.
    - 그런데 내부에서 self.sent_messages.push(...)를 호출하면서 **가변 접근**을 하려고 하기 때문에 에러 발생.

```rust
fn send(&self, message: &str) {
    self.sent_messages.push(String::from(message)); // &self 불변 참조인데, 값을 변경
}
```
- 위와같이 불변참조인데 값을 변경하려고 하면 안되는 상황이 있다.

```rust
use std::cell::RefCell;

struct MockMessenger {
    sent_messages: RefCell<Vec<String>>,
}

impl MockMessenger {
    fn new() -> MockMessenger {
        MockMessenger {
            sent_messages: RefCell::new(vec![]),
        }
    }
}

impl Messenger for MockMessenger {
    fn send(&self, message: &str) {
        self.sent_messages.borrow_mut().push(String::from(message));
    }
}
```
- 위처럼 편하게 수정할 수 있다.

#### Another Useful Usecases of Refcell 

lazy init, caching :
```rust
use std::cell::RefCell;

struct ExpensiveComputation {
    input: i32,
    cached_result: RefCell<Option<i32>>,
}

impl ExpensiveComputation {
    fn new(input: i32) -> Self {
        Self {
            input,
            cached_result: RefCell::new(None),
        }
    }

    fn result(&self) -> i32 {
        // 내부 상태를 불변 참조로 노출하면서도 결과는 캐싱 가능
        let mut cache = self.cached_result.borrow_mut();
        if let Some(value) = *cache {
            value
        } else {
            let computed = self.input * 2; // 예시용으로 가벼운 연산, 여기에 엄청 큰 연산을 두는 걸 상정한다
            *cache = Some(computed);
            computed
        }
    }
}
```

상태를 공유하는 케이스 : 
```rust
use std::cell::RefCell;
use std::rc::Rc;

struct AppState {
    count: RefCell<i32>,
}

fn increment(state: &AppState) {
    *state.count.borrow_mut() += 1;
}
```
- 처음에는 위의 코드가 와닿지 않을 수 있는데, 이런 상태는 보통 여러 컴포넌트들이 공유해야한다.
- 그러려면 Rc를 써야하는데 RefCell으로 안둔다면,
```rust
use std::rc::Rc;

struct AppState {
    count: i32,
}

fn increment(state: &AppState) {
    state.count += 1; // ❌ 에러: cannot assign to `state.count`, as `state` is not declared as mutable
}
```
- 위와 같이 불변 객체에 대한 접근이 막히게 된다.
- 그래서 다시 아까처럼
```rust
use std::cell::RefCell;
use std::rc::Rc;

struct AppState {
    count: RefCell<i32>,
}

fn increment(state: &AppState) {
    *state.count.borrow_mut() += 1; // ✅ 내부 가변성으로 가능!
}
```
- RecCell을 이용해서 해결이 가능하다.

### 15.4.4 Keeping Track of Runtime with Refcell
RefCell은 런타임에 빌림 규칙을 검사하는 안전한 API를 제공한다 :
 - borrow() 메서드는 **Ref**라는 스마트 포인터를 반환하며, 이는 불변 참조처럼 사용할 수 있다
 - borrow_mut() 메서드는 **RefMut**라는 스마트 포인터를 반환하며, 가변 참조처럼 사용할 수 있다
 - 이 두 스마트 포인터는 모두 Deref 트레잇을 구현하므로 일반 참조처럼 사용할 수 있다

런타임에 버로우체크와 painic을 발생시키는 예시 : 
```rust
impl Messenger for MockMessenger {
    fn send(&self, message: &str) {
        let mut one_borrow = self.sent_messages.borrow_mut();
        let mut two_borrow = self.sent_messages.borrow_mut();

        one_borrow.push(String::from(message));
        two_borrow.push(String::from(message));
    }
}
```

```bash
thread 'tests::it_sends_an_over_75_percent_warning_message' panicked at src/lib.rs:60:53:
already borrowed: BorrowMutErr
```

### 15.4.5 Having Multiple Owners of Mutable Data By Combining Rc and Refcell
선 요약 : 

`Rc`만 사용하는 경우
- 여러 소유자를 허용하지만, 불변 참조만 허용됨 → 데이터 변경 불가

`RefCell`만 사용하는 경우
- 단일 소유자만 가능하지만, 내부 가변성(Interior Mutability)을 통해 데이터 변경 가능

`Rc<RefCell>` 조합
- 여러 소유자 + 가변 접근을 동시에 구현할 수 있음
- Rc가 소유권 공유를, RefCell이 내부 가변성을 제공

```rust
#[derive(Debug)]
enum List {
    Cons(Rc<RefCell<i32>>, Rc<List>),
    Nil,
}

use crate::List::{Cons, Nil};
use std::cell::RefCell;
use std::rc::Rc;

fn main() {
    let value = Rc::new(RefCell::new(5));

    let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

    let b = Cons(Rc::new(RefCell::new(3)), Rc::clone(&a));
    let c = Cons(Rc::new(RefCell::new(4)), Rc::clone(&a));

    *value.borrow_mut() += 10;

    println!("a after = {a:?}");
    println!("b after = {b:?}");
    println!("c after = {c:?}");
}
```

```bash
$ cargo run
   Compiling cons-list v0.1.0 (file:///projects/cons-list)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.63s
     Running `target/debug/cons-list`
a after = Cons(RefCell { value: 15 }, Nil)
b after = Cons(RefCell { value: 3 }, Cons(RefCell { value: 15 }, Nil))
c after = Cons(RefCell { value: 4 }, Cons(RefCell { value: 15 }, Nil))

```

## 15.5 Refecence Cycles Can Leak Memory
- 러스트에서도 메모리 leaks를, 이장에서 만든 것들을 통해 유발할 수 있다.
```rust
#[derive(Debug)]
enum List {
    Cons(i32, RefCell<Rc<List>>),
    Nil,
}

impl List {
    fn tail(&self) -> Option<&RefCell<Rc<List>>> {
        match self {
            Cons(_, item) => Some(item),
            Nil => None,
        }
    }
}
```

```rust
fn main() {
    let a = Rc::new(Cons(5, RefCell::new(Rc::new(Nil))));

    println!("a initial rc count = {}", Rc::strong_count(&a));
    println!("a next item = {:?}", a.tail());

    let b = Rc::new(Cons(10, RefCell::new(Rc::clone(&a))));

    println!("a rc count after b creation = {}", Rc::strong_count(&a));
    println!("b initial rc count = {}", Rc::strong_count(&b));
    println!("b next item = {:?}", b.tail());

    if let Some(link) = a.tail() {
        *link.borrow_mut() = Rc::clone(&b);
    }

    println!("b rc count after changing a = {}", Rc::strong_count(&b));
    println!("a rc count after changing a = {}", Rc::strong_count(&a));

    // Uncomment the next line to see that we have a cycle;
    // it will overflow the stack
    // println!("a next item = {:?}", a.tail());
}
```

설명이 약간 부족한데, 여기서 스택이 터지는 이유는 순환구조 자체의 문제는 아니고 Debut Trait의 이슈다 :
```
1.	a.tail() → Some(RefCell { value: Rc<List> })
2.	Debug는 이 RefCell을 출력하려고 value를 출력함 → 내부의 Rc<List>를 따라감
3.	Rc<List>의 내부를 출력 → 이건 b
4.	그런데 b도 Cons(10, RefCell<Rc<List>>) → 다시 RefCell 안의 Rc<List>를 출력
5.	이건 다시 a → 무한 반복…
```

그리고 drop이 호출되었을때도 문제가 발생한다 :
![leakDrop](https://doc.rust-lang.org/book/img/trpl15-04.svg)
- 출처 : https://doc.rust-lang.org/book/ch15-06-reference-cycles.html#reference-cycles-can-leak-memory
- 참조카운트는 변수할당 으로 각각 1번, RcList의 참조가 일어나면서 각각 한번씩 생성된다.
	- a.tail()에 b를 할당하면서 생긴 카운트 포함
- drop으로 a, b를 정리해도 tail, rcList참조로 생긴 참조카운트는 줄어들지 않는다.
- 결국 메모리 유출이 발생한다.

### 15.5.1 Preventing Reference Cycles: Turning an Rc into a Weak

> 지금까지 우리는 Rc::clone을 호출하면 Rc 인스턴스의 strong_count가 증가하며, Rc 인스턴스는 strong_count가 0일 때만 정리된다는 것을 보여주었습니다. Rc 인스턴스 내의 값에 대한 *약한 참조(weak reference)*도 Rc::downgrade를 호출하고 Rc에 대한 참조를 전달하여 만들 수 있습니다. 강한 참조는 Rc 인스턴스의 소유권을 공유하는 방법입니다. 약한 참조는 소유권 관계를 표현하지 않으며, 그 개수는 Rc 인스턴스가 정리되는 시점에 영향을 미치지 않습니다. 이들은 참조 순환을 일으키지 않을 것인데, 약한 참조를 포함하는 모든 순환은 관련된 값들의 강한 참조 개수가 0이 되면 끊어질 것이기 때문입니다.

> Rc::downgrade를 호출하면 Weak 타입의 스마트 포인터를 얻게 됩니다. Rc 인스턴스의 strong_count를 1 증가시키는 대신, Rc::downgrade를 호출하면 weak_count가 1 증가합니다. Rc 타입은 strong_count와 유사하게 weak_count를 사용하여 얼마나 많은 Weak 참조가 존재하는지 추적합니다. 차이점은 Rc 인스턴스가 정리되기 위해 weak_count가 0일 필요는 없다는 것입니다.

> Weak가 참조하는 값이 이미 삭제되었을 수 있기 때문에, Weak가 가리키는 값으로 무언가를 하기 위해서는 그 값이 여전히 존재하는지 확인해야 합니다. 이는 Weak 인스턴스의 upgrade 메서드를 호출하여 수행하는데, 이 메서드는 OptionRc를 반환합니다. Rc 값이 아직 삭제되지 않았다면 Some 결과를 얻고, Rc 값이 삭제되었다면 None 결과를 얻습니다. upgrade는 OptionRc를 반환하기 때문에, Rust는 Some 경우와 None 경우가 처리되도록 보장하며, 유효하지 않은 포인터는 없을 것입니다.


#### 문제의 출발점: Rc는 순환 참조를 유발할 수 있음
- Rc::clone은 Rc의 strong_count를 증가시킴.
- Rc는 strong_count가 0일 때만 힙에서 drop됨.
- 따라서 두 개체가 서로를 Rc로 참조하면 reference cycle이 발생하고, 이는 메모리 해제가 불가능해짐.

#### 해결책: Rc::downgrade를 통해 Weak생성
- Rc::downgrade(&rc_value) 호출 시 Weak 스마트 포인터 생성.
- 이 포인터는 소유권을 갖지 않음 (strong_count에 영향 없음).
- 대신 weak_count를 1 증가시킴.
- Weak는 힙 해제에 영향을 주지 않기 때문에 참조 사이클을 방지.
  
#### Weak값 접근: .upgrade() 메서드
- Weak는 해당 값이 살아 있을 수도 있고 아닐 수도 있음.
- upgrade() 호출 시 Option<Rc<>> 반환.
    - 값이 살아 있으면 Some(Rc<>)
    - drop되었으면 None

```rust
use std::cell::RefCell;
use std::rc::Rc;

#[derive(Debug)]
struct Node {
    value: i32,
    children: RefCell<Vec<Rc<Node>>>,
}
```
Node라는 이름의 구조체를 만들고, 그 안에 자신의 i32 값과 자식 Node 값들에 대한 참조를 보관:
- Node가 자식 노드들을 소유하길 원하고, 각 노드에 직접 접근할 수 있도록 여러 변수들과 그 소유권을 공유하길 원함.
- 이를 위해 Vec<> 항목의 타입을 RcNode로 정의
- 또한 어떤 노드가 다른 노드의 자식인지 수정할 수 있길 원하므로, children 필드는 Vec<Rc<>>를 감싼 RefCell<>로 정의

```rust
fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        children: RefCell::new(vec![]),
    });

    let branch = Rc::new(Node {
        value: 5,
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });
}
```
leaf의 RcNode를 복제하여 branch에 저장, 이는 leaf에 있는 노드가 두 명의 소유자(leaf와 branch)를 갖게 된다는 의미
- 이러면 branch에서 leaf를 갈수는 있는데, 반대는 안됨

```rust
use std::cell::RefCell;
use std::rc::{Rc, Weak};

#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}
```
- Node 구조체 정의에 parent 필드를 추가해야 한다. 
- 여기서 문제는 parent의 타입을 무엇으로 해야 하느냐인데, 
- Rc<>를 사용하면 안 됨. 
- 왜냐하면 leaf.parent가 branch를 가리키고 branch.children이 다시 leaf를 가리키는 reference cycle을 만들게 되기 때문


관계를 다시 생각해보면, 부모 노드는 자식 노드를 소유해야 함, 만약 부모 노드가 제거되면, 자식 노드들도 제거되어야 하지만. 자식 노드는 부모 노드를 소유해서는 안 됨. 

자식 노드가 제거되어도 부모는 계속 존재해야 하기 때문. 이 경우는 **약한 참조(weak references)** 를 사용해야 한다.

```rust
fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());

    let branch = Rc::new(Node {
        value: 5,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });

    *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
}
```

```rust
fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    ); // leaf strong = 1, weak = 0

    {
        let branch = Rc::new(Node {
            value: 5,
            parent: RefCell::new(Weak::new()),
            children: RefCell::new(vec![Rc::clone(&leaf)]),
        });

        *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

        println!(
            "branch strong = {}, weak = {}",
            Rc::strong_count(&branch),
            Rc::weak_count(&branch),
        ); // branch strong = 1, weak = 1

        println!(
            "leaf strong = {}, weak = {}",
            Rc::strong_count(&leaf),
            Rc::weak_count(&leaf),
        ); // leaf strong = 2, weak = 0
    } // 여기서 branch는 스코프를 벗어나므로 drop됨

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
    // leaf parent = None

    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    ); // leaf strong = 1, weak = 0
}
```
