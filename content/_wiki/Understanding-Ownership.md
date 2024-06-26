---
title: Understanding the Ownership of the Rust Programming Language
summary: 
date: 2024-04-05 20:22:13 +0900
lastmod: 2024-04-05 20:22:13 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 4.0 Ownership
> 소유권은 러스트의 가장 특징적인 개념이다, 러스트를 이해하기 위해서, 또는 러스트가 왜 다른 언어들보다 주목받는지 이해하기 위해서 가장 중요한 장이라고 생각한다.

### 4.1.1 What is Ownership?
>  Ownership은 러스트가 메모리를 관리하는 규칙이다.

- 모든 프로그래밍 언어는 메모리를 관리하는 방법이 있다.

- 가장 대표적인 두 갈래는 GC(Garbage Collection)와 수동 메모리 관리로 볼 수있다.

- GC는 프로그램이 실행되는동안, 더 이상 사용하지 않는 메모리를 찾아내고 해체하는 방법이다.

- 수동 메모리 관리는 프로그래머가 메모리를 직접 관리하는 방법이다.

- 당연히 GC가 편리하고 안전하지만, 성능이 떨어진다는 단점이 있다.

- 러스트는 세번째 방법인 Ownership을 사용한다.

- 개인적으로 Ownership에서 가장 중요한 포인트는 '규칙'이라고 생각한다.

- 소유권이 적용되는 규칙을 요약하면 다음과 같다.

    - 각각의 값은 소유자(owner)가 있다.
    
    - 한번에 하나의 소유자만 존재할 수 있다.
    
    - 소유자가 스코프를 벗어나면, 값은 해제된다.

- 사실 완전히 새로운 방식은 아니다. C++의 RAII(Resource Acquisition Is Initialization)와 비슷한 개념이다.

- RAII는 객체가 생성될 때, 자원을 할당하고, 소멸될 때 자원을 해제하는 방식이다.

  - 객체의 생성과 소멸을 자원의 할당과 해제로 연결짓는다.

- 참조가 없으면(스코프를 나가면) 자동으로 해제된다는 점에서는 GC와 비슷하다.

  - GC를 아주 무식하게 요약하면 참조가 없어진 매모리를 체크하고 회수한다고 할 수 있다.

- Rust는'규칙'에 기반한 소유권을 사용하여 메모리를 관리한다, 반대로 생각하면, 메모리를 낭비하거나 위험에 빠뜨리지 않는 '규칙을' 구현한 것에 더 큰 의의가 있다.

- 그에 대한 댓가로 Rust는 컴파일타임에 메모리 안정성을 검증 할 수 있고, GC와 같이 런타임에 추가적인 비용이 발생하지 않는다.

- 결론적으로 프로그래머는 Rust의 Ownership이라는 규칙을 따르며 프로그래밍을 하는 것은 어렵지만, 그 댓가로 안전하면서도 빠른 프로그램을 만들 수 있다.


### 4.1.2 Stack and Heap

> Stack과 Heap은 우리의 코드가 런타임에 사용 할 수 있는 메모리이다. 스택은 자료구조 스택의 개념을 따른다. LIFO는 굳이 설명 안해도 괜찮지만,
> 특정한 메모리 공간에 일렬로 늘어서 있는 선형 자료구조임은 인지해야 한다. 왜냐면 힙은 스택과 다르게 메모리의 어느 곳에든 할당하고, 첫칸의 포인터를 반환받기 때문인다.
> 보통 스택은 빠르고, 힙은 느리다고 알려져 있다. 그 이유는 스택은 LIFO로 데이터를 저장하고, 힙은 데이터를 저장하고 찾기 위해 추가적인 작업이 필요하기 때문이다.
> 실제로는 주로 혼용해서 사용하는데, 스택에 힙의 포인터를 저장하고, 실제 참조가 필요할 때 힙을 참조하는 방식으로 사용한다.

- 이 레퍼런스가 의미있는 이유를 잘 생각해 봐야 한다.

- Rust는 Stack과 Heap을 사용하여 메모리를 관리한다.

- 예를들어 함수가 호출 될 때 마다, 함수의 지역변수와 매개변수가 스택에 저장된다(힙 데이터 포함). 그리고 사용이 끝나면 스택에서 제거된다.

- 결론적으로 우리가 관리해야하는 데이터는 사실상 힙에 할당된 데이터이다.

- Stack은 스코프 또는 사용 시점에 따라 자동으로 관리되지만, 힙은 프로그래머가 직접 관리해야 한다.

- 책에서는 Stack과 Heap을 생각하면서 프로그래밍 해야 할 필요는 없지만, Ownership 시스템이 뭘 어떻게 하는지, 그리고 왜 그렇게 하는지 이해하는데 도움이 된다고 한다.

### 4.1.3 Ownership Rules
다시 Ownership의 규칙을 살펴보면, 다음과 같다.

- 각각의 값은 소유자(owner)가 있다.
- 한번에 하나의 소유자만 존재할 수 있다.
- 소유자가 스코프를 벗어나면, 값은 해제된다.

이부분을 이해하기 위해서는 러스트의 변수 바인딩방식, 스코프를 이해해야 한다.

### 4.1.4 Variable Scope

** 문자열 리터럴 에서**
```rust
fn main() { // s is not valid here, it's not yet declared
    let s = "hello"; // s is valid from this point forward
} // this scope is now over, and s is no longer valid

```

- 위의 코드에 가장 중요한 포인트
- 변수 s는 선언된 블록 내에서만 유효하다.
- 블록이 끝나면 변수 s는 소멸된다.
- 아직까지 다른 언어와 크게 다르지 않다.


### 4.1.5 The String Type

**String 타입에서**
```rust
fn main() {
    let s = String::from("hello");
    // do stuff with s
} // this scope is now over, and s is no longer valid

```

- String 타입도 별반 다르지 않은 것 같은데..?

### 4.1.6 Memory and Allocation

- 문자 리터럴의 경우, 컴파일 타임에 컨텐츠를 알 수 있기 때문에, 해당 컨텐츠가 하드코딩되어 바이너리에 포함된다. 그래서 빠르고 효율적이지만, 변경이 불가능하다.
 
- 반면 String 타입은 컴파일 타임에 크기를 알 수 없고, 런타임에 크기가 결정되어 할당될 공간을 찾아 힙에 저장되어야 한다.

이 시점에 가장 중요한 포인트는 다음과 같다.

- 런타임에 메모리 할당을 요청해서 할당해야한다.
 
- 그로인해 이 메모리를 해제하고 반환해하는 방법이 필요하다.

- 첫 번째는 `String::from` 함수를 통해 이루어졌다 (쉽다 쉬워).

- 그런데 두 번째는 프로그래머들의 아주 오래된 고민중에 하나이다. (GC가 없는 언어에서는)
  - 메모리를 할당하고 해제하는 것은 프로그래머의 몫이다.
  - 근데 그게 잘 되겠냐고, 사람은 실수를 하기 마련인데...
  - 일단 해제를 안하면 메모리 누수가 발생해서 프로그램이 느려지고, 더 심하면 프로그램이 죽을 수 있다.
  - 해제를 두번하면, 프로그램이 죽을 수 있다.
  - 해제를 너무 일찍하면, 프로그램이 죽을 수 있다.
  - 결론적으로 메모리 관리는 어렵다.

- Rust는 Ownership 규칙을 통해 이 문제를 해결한다.

```rust
fn main() {
    let s = String::from("hello");
    // do stuff with s
} // this scope is now over, and s is no longer valid
```

- 위의 코드에서 s는 스코프를 벗어나면 해제된다. (쉽고 편리하고 안전해보이지!, 안전한건 맞는데 쉽고 편할까?) 
  
- 무튼 이것이 Ownership의 규칙이다.

- 참고로 실제 구현은 `drop`이라는 함수를 통해 이루어진다.

- 스코프의 기준이 되는 닫힌 중괄호가 실행되면, 내부적으로는 `drop` 함수가 호출되어 메모리가 해제된다.

### 4.1.7 Ways Variables and Data Interact : Move

```rust
  let x = 5;
  let y = x;
```

- 여기서는 x의 값을 복사해서 y에 넣고 실제로 x와 y인 5는 스택에 각각 푸시된다.

```rust
  let s1 = String::from("hello");
  let s2 = s1;
```

- 여기는 다르다! String의 데이터는 세 부분으로 나뉘어져 있다 (포인터, 길이, 용량)
  - 포인터는 힙에 저장된 데이터를 가리키는 주소
  - 길이는 데이터의 길이
  - 용량은 할당된 메모리의 크기

- 일단 이 데이터 (참조와 뭐 대충 메타데이터)는 스택에 저장된다.

![image](https://doc.rust-lang.org/book/img/trpl04-02.svg)
출처 : [The Rust Programming Language](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)

- 그리고 s1을 s2에 할당하면 어떻게 될까?

- 결론은 s1의 데이터중 스택에 저장된 데이터는 s2로 복사되고, 힙에 저장된 데이터는 복사되지 않는다.

- 그런데 문제는 여기서 발생한다. s1과 s2가 모두 힙의 데이터를 가리키고 있으면, 두 변수가 스코프를 벗어나면 두 변수가 동시에 메모리를 해제하려고 할 것이다.

- ~~메모리를 두번 해제해...? "죽을게"~~

- 가 아니고 Rust는 이런 상황을 방지하기 위해 장치를 마련해뒀다.

- 내용을 먼저 보면

- `let s2 = s1` 코드 이후의 시점에, s1을 더이상 유효하지 않다고 간주한다.

```rust
  let s1 = String::from("hello");
  let s2 = s1;
  println!("{}, world!", s1);
```

```bash
$ cargo run
   Compiling ownership v0.1.0 (file:///projects/ownership)
error[E0382]: borrow of moved value: `s1`
 --> src/main.rs:5:28
  |
2 |     let s1 = String::from("hello");
  |         -- move occurs because `s1` has type `String`, which does not implement the `Copy` trait
3 |     let s2 = s1;
  |              -- value moved here
4 |
5 |     println!("{}, world!", s1);
  |                            ^^ value borrowed here after move
  |
  = note: this error originates in the macro `$crate::format_args_nl` which comes from the expansion of the macro `println` (in Nightly builds, run with -Z macro-backtrace for more info)
help: consider cloning the value if the performance cost is acceptable
  |
3 |     let s2 = s1.clone();
  |                ++++++++

For more information about this error, try `rustc --explain E0382`.
error: could not compile `ownership` due to previous error
```

- 실제로 이런 에러가 발생한다.

- 얕은 복사 나도 알아 라고 입이 근질근질하셨던분들은 고려해야 할 게 하나 더 늘은 샘이다.

- Rust는 얕은 복사를 하지 않고, move라는 개념을 사용한다.

![image](https://doc.rust-lang.org/book/img/trpl04-04.svg)
출처 : [The Rust Programming Language](https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html)

- 결론적으로 스코프를 나갈때마다 메모리를 해제하면 되는데 왜 그렇게 안했지? 와 같은 생각에는 다음과 같은 이유가 있었고(중복 해제) 러스트는 이러한 부분들에 대한 규칙을 지정하며 해결하고 있는 것이다.

- 참고로 깊은 복사를 하고 싶다면 `clone` 함수를 사용하면 된다.

```rust
  let s1 = String::from("hello");
  let s2 = s1.clone();
  println!("{}, world!", s1);
```

- 이렇게 하면 s1과 s2는 서로 다른 데이터를 가리키게 된다.

### 4.1.8 Copy Trait

- 앞에서 분류한 Stack only 타입들은 굳이 move를 하지 않아도 된다.

- 이런 타입들은 Copy 트레이트를 구현하고 있다.

- Copy 트레이트는 다음과 같은 특징을 가진다.

    - 스택에 저장되는 타입들은 Copy 트레이트를 구현하고 있다.
    
    - Copy 트레이트를 구현하고 있는 타입들은 move 대신 복사가 이루어진다.
    
    - Copy 트레이트를 구현하고 있는 타입들은 스코프를 벗어나도 메모리가 해제되지 않는다.

- Copy 트레이트를 구현하고 있는 타입들은 다음과 같다.
  
      - i32
      
      - bool
      
      - f64
      
      - char
      
      - Tuple (단, 모든 요소가 Copy 트레이트를 구현하고 있어야 한다.)

- 이외에는 drop trait를 구현하고 있어 Copy 트레이트를 구현할 수 없다.


### 4.1.9 Ownership and Functions

- 함수의 인자로 값을 넘기는 것은 변수를 할당하는 것과 의미론적으로 비슷하다.

- 함수의 인자로 값을 넘기면, 해당 값은 함수의 스코프로 이동한다.

```rust
fn main() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // x would move into the function,
                                    // but i32 is Copy, so it's okay to still
                                    // use x afterward

} // Here, x goes out of scope, then s. But because s's value was moved, nothing
  // special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{}", some_string);
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{}", some_integer);
} // Here, some_integer goes out of scope. Nothing special happens.
```

- 함수의 반환값 역시 마찬가지로 move가 이루어진다.

```rust
fn main() {
    let s1 = gives_ownership();         // gives_ownership moves its return
                                        // value into s1

    let s2 = String::from("hello");     // s2 comes into scope

    let s3 = takes_and_gives_back(s2);  // s2 is moved into
                                        // takes_and_gives_back, which also
                                        // moves its return value into s3
} // Here, s3 goes out of scope and is dropped. s2 was moved, so nothing
  // happens. s1 goes out of scope and is dropped.

fn gives_ownership() -> String {             // gives_ownership will move its
                                             // return value into the function
                                             // that calls it

    let some_string = String::from("yours"); // some_string comes into scope

    some_string                              // some_string is returned and
                                             // moves out to the calling
                                             // function
}

// This function takes a String and returns one
fn takes_and_gives_back(a_string: String) -> String { // a_string comes into
                                                      // scope

    a_string  // a_string is returned and moves out to the calling function
}
```


- 납득이 안가는 예제는 없는 것 같다.

- 다만 모든 함수가 소유권을 가져갔다가 반환하는것은 지루하기 때문에 러스트는 참조를 사용한다.

## 4.2 References and Borrowing

```
fn main() {
    let s1 = String::from("hello");

    let len = calculate_length(&s1);

    println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize { // s is a reference to a String
    s.len()
}
```
- 러스트에서 참조는 변수를 빌려오는 것이다.

![Rust Reference](https://doc.rust-lang.org/book/img/trpl04-05.svg)

- 참고로 reference의 반대는 dereference이며 `*` 연산자를 사용한다.
- 참조를 사용하면 소유권을 넘기지 않으므로, `drop` 함수가 호출되지 않는다.

- 참조는 기본적으로 immutable하다.

```rust
fn main() {
    let s = String::from("hello");

    change(&s);
}

fn change(some_string: &String) {
    some_string.push_str(", world");
}
```

- 위의 코드는 에러가 발생한다.

```bash
$ cargo run
   Compiling ownership v0.1.0 (file:///projects/ownership)
error[E0596]: cannot borrow `*some_string` as mutable, as it is behind a `&` reference
 --> src/main.rs:8:5
  |
7 | fn change(some_string: &String) {
  |                        ------- help: consider changing this to be a mutable reference: `&mut String`
8 |     some_string.push_str(", world");
  |     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `some_string` is a `&` reference, so the data it refers to cannot be borrowed as mutable

For more information about this error, try `rustc --explain E0596`.
error: could not compile `ownership` due to previous error
```

- 참조를 mutable로 사용하려면 `&mut`을 사용해야 한다.
```rust
fn main() {
    let mut s = String::from("hello");

    change(&mut s);
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}

```

- 참조를 사용하면 소유권을 넘기지 않으므로, 여러 참조를 사용할 수 있다.

```rust
fn main() {
    let mut s = String::
    from("hello");
    
    let r1 = &mut s;
    let r2 = &mut s;
    
    println!("{}, {}", r1, r2);
}
```

```bash
$ cargo run
   Compiling ownership v0.1.0 (file:///projects/ownership)
error[E0499]: cannot borrow `s` as mutable more than once at a time
  --> src/main.rs:5:17
    |
4   |     let r1 = &mut s;

5   |     let r2 = &mut s;
    |                 ^^^^ mutable borrow starts here in previous iteration of loop 
      
6   |
7   |     println!("{}, {}", r1, r2);
    |                        -- borrow later used here
    |
    = note: this error originates in a macro outside of the current crate (in Nightly builds, run with -Z external-macro-backtrace for more info)
    
error: aborting due to previous error

For more information about this error, try `rustc --explain E0499`.
error: could not compile `ownership` due to previous error

```
- 실제 코드를 작성하는데 가장 힘들게 느껴지는 제약사항 중 하나이다.
 
- 러스트는 이러한 제약사항을 통해 메모리 안정성을 보장한다.
 
- 정확히는 러스트는 데이터 레이스를 방지하기 위해 이러한 제약사항을 두고 있다.

- 데이터 레이스는 두개 이상의 스레드가 동시에 같은 데이터에 접근할 때 발생하는 문제이다.

  - 동시에 같은 데이터에 접근하면서, 적어도 하나의 접근이 쓰기일 때, 동시성 로직이 없는 경우에 발생한다.

- 러스트는 이러한 문제를 방지하기 위해 컴파일 타임에 이러한 문제를 방지한다.

```
fn main() {
    let mut s = String::("hello");
    
    {
        let r1 = &mut s;
    } // r1 goes out of scope here, so we can make a new reference with no problems.
    
    let r2 = &mut s;
```

- 다수의 참조가 필요 할 때, 위와 같이 블록을 사용하여 스코프를 나누어 사용하면 된다.

- 참조의 범위를 제한함으로써, 데이터 레이스를 방지할 수 있다.

- 또 하나의 제약사항은 불변 참조와 가변 참조를 동시에 사용할 수 없다는 것이다.

```rust
fn main() {
    let mut s = String::from("hello");
    
    let r1 = &s;
    let r2 = &s;
    let r3 = &mut s; // error
}
```

- 불변 참조값이 있는 동안에는 가변 참조로 인해서 데이터가 변경되는것을 원하지 않기 때문에 막아둔 것이다.

- 추가적으로 러스트는 컴파일 시점에 불변 참조의 마지막 사용 위치 이후에는 가변 참조를 사용할 수 있도록 해준다.

```rust
fn main() {
    let mut s = String::from("hello");
    
    let r1 = &s;
    let r2 = &s;
    println!("{} and {}", r1, r2);
    // r1 and r2 are no longer used after this point
    
    let r3 = &mut s;
}
```


### 4.2.1 Dangling References

- Dangling References는 참조가 가리키는 메모리가 해제된 경우를 말한다.
  - 메모리 해제 후에도 참조가 존재하는 경우,
  - 범위 밖 참조가 일어나는 경우,
  - 복사된 포인터가 일으키는 경우 등이 있다.

- 러스트는 참조가 유효한 동안에는 반드시 데이터가 스코프 내에 있도록 보장한다. 
- 즉, 데이터가 참조보다 먼저 스코프 밖으로 벗어나서는 안 되며, 이를 통해 댕글링 참조가 생성되는 것을 컴파일 시점에 방지한다.

- 예를들어 함수가 로컬 변수의 참조를 반환하는 경우, 러스트는 컴파일 에러를 발생시킨다.

```rust
fn main() {
    let reference_to_nothing = dangle();
}

fn dangle() -> &String { 
    let s = String::from("hello");
    &s 
}
```

## 4.3 The Slice Type

- 슬라이드는 참조의 일종으로, 오너쉽을 가지지 않는다.

- 예시 : 문자열에서 첫 단어를 찾는 함수 만들어보기 (공백을 기준으로)

```rust
fn first_word(s: &String) -> ?
```

- 이 함수는 문자열의 참조를 받는데, 무엇을 반환해야 할까?

```rust
fn first_word(s: &String) -> usize {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return i;
        }
    }

    s.len()
}
```

```rust
let bytes = s.as_bytes(); // as_bytes() 메소드는 문자열을 바이트 배열로 변환한다.
```

```rust
for (i, &item) in bytes.iter().enumerate() // iter() 메소드는 컬렉션을 반복하는 반복자를 생성한다, enumerate() 메소드는 반복자를 튜플로 변환한다.
```

- 문자열의 인덱스를 반환하는 방식으로 구현했다,

```rust
fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s); // word will get the value 5

    s.clear(); // this empties the String, making it equal to ""

    // word still has the value 5 here, but there's no more string that
    // we could meaningfully use the value 5 with. word is now totally invalid!
}
```

4.3.1 String Slices

- 슬라이스는 문자열의 일부분을 참조하는 방법이고 이렇게 생겼다.

```rust
let s = String::from("hello world");

let hello = &s[0..5];
let world = &s[6..11];
```

![image](https://doc.rust-lang.org/book/img/trpl04-06.svg)

> Rather than a reference to the entire String, 
> hello is a reference to a portion of the String, 
> specified in the extra [0..5] bit. 
> We create slices using a range within brackets by specifying [starting_index..ending_index], 
> where starting_index is the first position in the slice and ending_index is one more than the last position in the slice. 
> Internally, the slice data structure stores the starting position and the length of the slice, 
> which corresponds to ending_index minus starting_index. So, in the case of let world = &s[6..11];, 
> world would be a slice that contains a pointer to the byte at index 6 of s with a length value of 5.

```rust
let s = String::from("hello");

let slice = &s[0..2];
let slice = &s[..2];

let len = s.len();

let slice = &s[3..len];
let slice = &s[3..];

let slice = &s[0..len];
let slice = &s[..];
```

```rust
fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();

    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }

    &s[..]
}
```

- 똑같이 개념적으로는 인덱스를 통해 문자열을 찾는 방식이지만, 참조를 엮어두면 훨씬 더 안전하게 사용 할 수 있다.

- 스트링이 유효한 동안에 슬라이스도 유효하다.

```rust
fn main() {
    let mut s = String::from("hello world");

    let word = first_word(&s);

    s.clear(); // error!

    println!("the first word is: {}", word);
}
```

```bash
$ cargo run
   Compiling ownership v0.1.0 (file:///projects/ownership)
error[E0502]: cannot borrow `s` as mutable because it is also borrowed as immutable
  --> src/main.rs:18:5
   |
16 |     let word = first_word(&s);
   |                           -- immutable borrow occurs here
17 |
18 |     s.clear(); // error!
   |     ^^^^^^^^^ mutable borrow occurs here
19 |
20 |     println!("the first word is: {}", word);
   |                                       ---- immutable borrow later used here

For more information about this error, try `rustc --explain E0502`.
error: could not compile `ownership` due to previous error

```

- String의 내용을 지우기 위해서는 해당 String에 대한 가변 참조가 필요한데, 만약 이미 불변 참조가 존재한다면 
 
- clear 메소드를 호출하여 String의 내용을 변경하려고 할 때 컴파일 오류가 발생한다. 
 
- 이는 println! 매크로가 word에서 불변 참조를 사용하려고 하기 때문에 발생한다. 
 
- 따라서, clear 함수가 가변 참조를 요구하는 동안 word의 불변 참조가 여전히 활성화되어 있어야 한다. 
 
- 러스트는 가변 참조와 불변 참조가 동시에 존재하는 것을 허용하지 않기 때문에 컴파일이 실패한다. 
 
 - 결론적으로 String Literal은 바이너리를 참조하는 것이다.

> 위 코드에서 s의 타입은 &str입니다. 
> 이는 특정 이진 파일 내의 위치를 가리키는 슬라이스로, 
> 문자열 리터럴이 어떻게 처리되는지를 명확히 이해할 수 있게 해줍니다. 
> 문자열 리터럴이 불변인 이유도 여기에 있습니다
> &str은 불변 참조이기 때문입니다.따라서, 문자열 리터럴은 프로그램의 이진 파일 내에 직접 저장되며, 
> 이를 통해 생성된 &str 타입의 변수는 이진 파일 내 해당 문자열의 위치를 가리키는 불변의 슬라이스가 됩니다. 
> 이러한 특성은 문자열 리터럴이 왜 변경할 수 없는지(immutable)를 설명해 줍니다.
 
 ```rust
 let s = "Hello, world!";
 ```

- 참고로 경험 많은 개발자들은 다음과 같이 시그니처를 유연하게 만들어서 사용한다고 한다.
```rust
fn first_word(s: &str) -> &str
```

- 위처럼 s 매개변수의 타입으로 문자열 슬라이스를 사용하게 만든다. 
 
- 이를 통해 문자열 슬라이스를 직접 전달할 수 있고, String이 있을 경우 String의 슬라이스나 String에 대한 참조를 전달할 수 있게 된다. 
 
- 이러한 유연성은 역참조 강제 변환(deref coercions)이라는 기능을 활용하는 것으로 ~~나중에~~...

```rust
fn main() {
    let my_string = String::from("hello world");

    // `first_word` works on slices of `String`s, whether partial or whole
    let word = first_word(&my_string[0..6]);
    let word = first_word(&my_string[..]);
    // `first_word` also works on references to `String`s, which are equivalent
    // to whole slices of `String`s
    let word = first_word(&my_string);

    let my_string_literal = "hello world";

    // `first_word` works on slices of string literals, whether partial or whole
    let word = first_word(&my_string_literal[0..6]);
    let word = first_word(&my_string_literal[..]);

    // Because string literals *are* string slices already,
    // this works too, without the slice syntax!
    let word = first_word(my_string_literal);
}
```
