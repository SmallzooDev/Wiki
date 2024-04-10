---
title: Enums and Pattern Matching in Rust
summary: 
date: 2024-04-09 21:57:53 +0900
lastmod: 2024-04-09 21:57:53 +0900
tags: 
categories: 
description: 
showToc: true
---

## 6 Enum and Pattern Matching
> In this chapter, we’ll look at enumerations, also referred to as enums. Enums allow you to define a type by enumerating its possible variants
> 가능한 상태의 목록을 열거하여 타입을 정의한다는 정의가 마음에 든다.
> 보통 상대적으로 새로운 언어들이 명시적이면서 경제적이면서 예쁜 문법을 제공하는데 러스트의 enum이 특히 그런 느낌이다.


## 6.1 Defining an Enum

- 구조체가 데이터를 그룹화 하는 방법을 제공한다면, enum은 특정한 값이 가질수 있는 모든 가능한 값을 정의한다.
> 이런 류의 정의가 좋은 것 같다. 처음 Generic을 배울 때 처음에 복잡하고 읽기 어려운 문법과 사용 방법에 포커스를 하고 공부하니 이해가 안됐었는데, 
> 똑같은 로직을 여러번 작성하지 않기 위해 사용하는 문법이라고 c++ primer plus 책에서 설명을 해줘서 해당 관점으로 이해하려 하니 이해가 잘 되었었던 기억이 난다.

- 공식 가이드에서는 IP 주소를 다루는 예제를 들고 있다. IP주소라는 개념을 코드로 '표현'한다면
    - 4개의 8비트 숫자로 구성된 IPv4 주소를 다루는 경우
    - 8개의 16비트 숫자로 구성된 IPv6 주소를 다루는 경우
- 이렇게 두가지 상태만 존재하고, 모든 IP의 버전은 두가지 중 하나에 속하게 된다.

- IP 주소이면서 저 두가지의 상태가 아닌 다른 상태에 속할 수 없고, 둘 다에 속할 수 없으며, 이런 경우에 enum을 이용해서 표현할 수 있다.

- 버전 4와 버전 6 주소 모두 근본적으로는 IP 주소이므로, 코드가 어떤 종류의 IP 주소에도 적용되는 상황을 처리할 때 동일한 타입으로 취급되어야 한다.

- 즉 모든, 고유한, 가능한 상태의 열거이므로 일정 정도의 추상화의 역할을 한다. 

```rust
enum IpAddrKind {
    V4,
    V6,
}

let four = IpAddrKind::V4;
let six = IpAddrKind::V6;

fn route(ip_kind: IpAddrKind) {}

route(IpAddrKind::V4);
route(IpAddrKind::V6);
```
- 문법은 enum 키워드로 시작하고, 각 상태는 중괄호로 묶인 목록으로 정의된다.
- 각 상태는 그 자체로 유효한 값이다. 이 값은 enum의 이름을 통해 접근할 수 있다.
- enum의 이름과 상태의 이름은 같은 이름 공간에 있으므로, enum의 이름을 통해 상태를 참조할 수 있다.

- enum에 값을 저장할 수도 있다.

```rust
enum IpAddr {
    V4(String),
    V6(String),
}

let home = IpAddr::V4(String::from("127.0.0.1"));
let loopback = IpAddr::V6(String::from("::1"));
```

- 이렇게 하면 각 상태가 다른 타입의 데이터를 가질 수 있다.
- 단순히 열거형에 String을 매핑하는 정도가 아니라 아래와 같은 것들도 가능하다.

```rust
enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);
let loopback = IpAddr::V6(String::from("::1"));
```

- 이렇게 하면 각 상태가 다른 타입의 데이터를 가질 수 있다.

```rust
struct Ipv4Addr {
    // --snip--
}

struct Ipv6Addr {
    // --snip--
}

enum IpAddr {
    V4(Ipv4Addr),
    V6(Ipv6Addr),
}
```

- 이렇게 하면 각 상태가 다른 구조체를 가질 수 있다.

```rust
enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}
```

- 다양한 것들을 매핑하되, 하나의 enumerate variants에 같은 타입이 아닌 것들을 매핑할 수 있다.

```rust
struct QuitMessage; // unit struct
struct MoveMessage {
    x: i32,
    y: i32,
}
struct WriteMessage(String); // tuple struct
struct ChangeColorMessage(i32, i32, i32); // tuple struct
```

```rust
    impl Message {
        fn call(&self) {
            // method body would be defined here
        }
    }

    let m = Message::Write(String::from("hello"));
    m.call();

```

- impl로 메소드를 정의할 수 있다.

### 6.1.1 The Option Enum and Its Advantages Over Null Values 

- `Option<T>`는 표준 라이브러리에 정의된 enum이다.
 
- `Option<T>`는 `Some(T)`와 `None` 두가지 상태를 가진다.
 
- `Option<T>`는 null 값의 대안으로 사용할 수 있다.
 
- Java의 Optional과 비슷한 개념이다.
 
- 값이 있는 경우, 그렇지 않은 경우(그 모든 `variant`) 가 있고, 그 모든케이스를 다뤄야하는데, Option을 사용하면 정확히 모든 케이스를 핸들링 했는지, 컴파일러가 체크해준다.

- 우리는 언어를 배울때, 해당 언어가 어떠한 기능을 포함(include)하고 있는지에는 충분히 주목하면서, 어떠한 기능을 배제(exclude)하고 있는지에는 충분히 주목하지 않는다.

- 기능의 배제 또한 언어의 특징이라는 점을 서적에서 강조하고 있다.

- 결론적으로 Rust는 null을 제공하지 않는다. null이라는 기능을 제공하는 언어의 모든 값은 두가지 variant를 가진다. (`null`, `not null`)

Tony Hoare가 null을 발명했는데, 후에 이것이 'my billion dollar mistake'라고 말했다.

> 공식 가이드 문서에서 해당 내용과 관련한 인터뷰 기사를 인용하고 있는데, 이게 대충 60년만의 사과라고 한다.
> 해당 기사의 배스트 댓글에는, "Bjarne Stroustrup의 사과까지는 14년이 더 남았네" 라는 댓글이 달려 있어 검색해봤는데,
> 1979년은 cpp의 탄생년 이었다. 

- 무튼 실제 구현은 아래와 같다.

```rust
enum Option<T> {
    None,
    Some(T),
}
```
- prelude에는 Option이 포함되어 있어서(그만큼 유용하고 자주 사용해야 하기에) 따로 include할 필요가 없고, Option을 사용할 때는 `Option::`을 사용하지 않아도 된다.

- `Some<T>` 는 제네릭으로 특정 타입을 가질 수 있다.

```rust
let some_number = Some(5);
let some_string = Some("a string");

let absent_number: Option<i32> = None;
```

- some_number의 타입은 `Option<i32>`이다.
- some_string의 타입은 `Option<&str>`이다.
- absent_number의 타입은 `Option<i32>`이다.

- 무튼 결론적으로 `Some` value는 값이 있는 경우를 나타내고, `None` value는 값이 없는 경우를 나타낸다.

- `None` variant는 사실상 null과 같은 의미를 지니는데, 굳이 이렇게 하는 이유는 뭘까? (왜 `null`보다 `None`을 사용하는가?)

- 짧게 요약하면, `Option<T>`와 `T`는 다른 타입이기 때문에 컴파일러는 `Option<T>`를 사용 할 때, 무조건적으로 valid value라고 상정하지 않기 때문이다.

```rust
let x: i8 = 5;
let y: Option<i8> = Some(5);

let sum = x + y;
```

- 위 코드는 컴파일 되지 않는다. `Option<i8>`와 `i8`은 다른 타입이기 때문이다.

- 당연하게도 `i8`과 `i8`이 아닌 무엇인가의 값을 더하는 방법을 알지 못한다.

- 컴파일러가 이해 할 수 있는 코드를 작성하기 위해서는, `Option<i8>`를 그냥 사용하는것이 아닌 무엇인가의 처리를 해야한다.

- 여기서 무엇인가의 처리란 바로 `Option`의 variants를 
