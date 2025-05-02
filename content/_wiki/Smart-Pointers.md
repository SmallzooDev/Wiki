---
title: rust smart pointers
summary: 
date: 2025-05-01 16:49:21 +0900
lastmod: 2025-05-02 11:41:49 +0900
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
