---
title: Enums and Pattern Matching in Rust
summary: 
date: 2024-04-09 21:57:53 +0900
lastmod: 2025-04-30 15:50:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 6 Enum and Pattern Matching
> In this chapter, we’ll look at enumerations, also referred to as enums. Enums allow you to define a type by enumerating its possible variants
- 가능한 상태의 목록을 열거하여 타입을 정의한다는 정의가 마음에 든다.


## 6.1 Defining an Enum
> 구조체가 데이터를 그룹화 하는 방법을 제공한다면, enum은 특정한 값이 가질수 있는 모든 가능한 값을 정의한다.
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
- 여기서 무엇인가의 처리란 바로 `Option`의 variants를 다뤄야 하는 것이고, 그러한 과정 이후에 null(None) 에 대한 대응을 진행하게된다.

## 6.2 The match Control Flow Construct

- `match`는 다른 언어의 `switch`와 비슷한 역할을 한다.
- Pattern은 literal value, variable, wild card, tuple, destructured structure, enum 등을 포함할 수 있다.
- `match`는 컴파일러로 하여금 모든 케이스를 다루는지 확인하게 한다.
- 동전 자판기처럼 처음으로 일치하는 패턴을 만나면 해당 블록을 실행하고, 나머지는 무시한다.

```rust
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter => 25,
    }
}
```
- if 문과 다른 점은 굳이 `boolean`을 사용하지 않아도 된다는 점이다.
- `match`의 arm이란 `=>`과 `,`로 구분된 패턴과 실행 코드 블록이다. 패턴과 코드 블록으로 이루어져 있다.
- 각각의 arm에 연관되어있는 코드 블록은 표현식이며, 이 표현식의 결과는 `match` 표현식의 결과가 된다.
- 한 줄을 넘는 코드를 작성할 때는 `{}`를 사용해야 한다.

### 6.2.1 Patterns That Bind to Values

- `match`의 또 다른 유용한 기능은 패턴에 매칭되는 값을 바인딩 할 수 있다는 것이고, enum variants 의 값을 추출할  수 있다.
```rust
#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
```

- `Quarter` variant는 `UsState`를 가지고 있다.
```rust
fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        },
    }
}
```
- `Coin::Quarter(state)`에서 `state`는 `UsState` 타입이 된다.
- 이렇게 하면 `UsState`를 추출할 수 있다.

### 6.2.2 Matching with Option

- `match` rust의 유연한 enum과 함께 사용할 때 매우 강력한 도구가 된다.
- `match` 의 variable binding 기능 덕에 코드가 깔끔하게 떨어지는 경우가 많고, 실제로 코드를 작성하면서도 이점을 느낄 수 있다.


## 6.3.3 Mathches Are Exhaustive

- `match`는 모든 경우를 다루지 않으면 컴파일 되지 않는다.
```rust
fn plus_one(x: Option<i32>) -> Option<i32> {
    match x {
        Some(i) => Some(i + 1),
    }
}
```

- 위 코드는 컴파일 되지 않는다. `None`에 대한 처리가 없기 때문이다.
- 이처럼 러스트의 `match`는 철저하기 때문에 일어날 수 있는 실수를 방지해준다.

### 6.3.4 Catch-all Patterns and The `_` Placeholder

- enum과 `match`를 사용할 때, 특정 값에 대해서만 특별한 처리를 하고, 나머지에 대해서는 아예 처리를 하지 않을 때가 있다.

```rust
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other),
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
    fn move_player(num_spaces: u8) {}

```

- 이러한 경우 3,7이 아닌 모든 경우는 `other`에 매칭되어 처리된다.
- 참고로 다른 언어의 `switch`에서와 같이 other을 위에 쓰면 그 아래 arm들은 비교조차 안하기 때문에 주의가 필요하다.
- 비슷하게 catch-all 하면서도, 해당 값에 대해서는 아무것도 하지 않을 때는 `_`를 사용한다.

```rust
    let dice_roll = 9;
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        _ => (), // or another actions for now do nothing
    }

    fn add_fancy_hat() {}
    fn remove_fancy_hat() {}
```

## 6.4 Concise Control Flow with `if let`

- `if let`을 사용하면, 하나의 값에 대해서만 매칭을 하고, 나머지를 무시하는 경우에 `match`를 사용하는 것보다 간결하게 코드를 작성할 수 있다.
```rust
    let some_u8_value = Some(0u8);
    match some_u8_value {
        Some(3) => println!("three"),
        _ => (),
    }

    if let Some(3) = some_u8_value {
        println!("three");
    }
``` 


- 두 코드 모두 정확히 같은 동작을 한다.
- `if let`은 보일러 플레이트도, verbose한 코드도, 굳이 필요없는 들여쓰기도 없애주지만, `match`의 exhaustive checking을 제공하지 않는다.
- 결론적으로 syntax sugar이다.
- else를 사용할 수도 있다.

```rust
    let mut count = 0;
    if let Coin::Quarter(state) = coin {
        println!("State quarter from {:?}!", state);
    } else {
        count += 1;
    }
```


## 6.5 Summary
다양한 match 사용 예제

```rust
// 1. 트래픽 라이트 시뮬레이터
enum TrafficLight {
    Red,
    Yellow,
    Green,
}

fn simulate_traffic_light(light: TrafficLight) {
    match light {
        TrafficLight::Red => println!("Stop"),
        TrafficLight::Yellow => println!("Caution"),
        TrafficLight::Green => println!("Go"),
    }
}

// 2. 파일 읽기 함수
use std::fs;

fn read_file(file_path: &str) -> Result<String, String> {
    match fs::read_to_string(file_path) {
        Ok(contents) => Ok(contents),
        Err(_) => Err(String::from("Failed to read the file.")),
    }
}

// 3. 동물의 소리 출력
enum Animal {
    Dog,
    Cat,
    Bird,
}

fn make_sound(animal: Animal) {
    match animal {
        Animal::Dog => println!("Woof!"),
        Animal::Cat => println!("Meow!"),
        Animal::Bird => println!("Tweet!"),
    }
}

// 4. 모양의 면적 계산
enum Shape {
    Circle(f64),
    Triangle(f64, f64),
    Rectangle(f64, f64),
}

fn calculate_area(shape: Shape) -> f64 {
    match shape {
        Shape::Circle(radius) => std::f64::consts::PI * radius * radius,
        Shape::Triangle(base, height) => 0.5 * base * height,
        Shape::Rectangle(width, height) => width * height,
    }
}

// 5. 주소 정보 출력
enum Address {
    City(String),
    State(String),
    Country(String),
}

struct Location {
    city: String,
    state: String,
    country: String,
}

fn print_city_address(address: Address) {
    match address {
        Address::City(city) => println!("City: {}", city),
        _ => (),
    }
}

// 6. 두 옵션 처리
enum OptionEnum<T> {
    Some(T),
    None,
}

fn process_option(option1: OptionEnum<i32>, option2: OptionEnum<i32>) {
    match (option1, option2) {
        (OptionEnum::Some(val1), OptionEnum::Some(val2)) => println!("Both options have values: {}, {}", val1, val2),
        _ => println!("At least one option is None."),
    }
}

// 7. 사칙연산 함수
fn calculate_operation(op: &str, num1: f64, num2: f64) -> Result<f64, String> {
    match op {
        "+" => Ok(num1 + num2),
        "-" => Ok(num1 - num2),
        "*" => Ok(num1 * num2),
        "/" => {
            if num2 == 0.0 {
                Err(String::from("Division by zero is not allowed."))
            } else {
                Ok(num1 / num2)
            }
        },
        _ => Err(String::from("Invalid operation.")),
    }
}

// 8. 계절 출력
enum Season {
    Spring,
    Summer,
    Autumn,
    Winter,
}

fn print_season_message(season: Season) {
    match season {
        Season::Spring => println!("It's spring!"),
        Season::Summer => println!("It's summer!"),
        Season::Autumn => println!("It's autumn!"),
        Season::Winter => println!("It's winter!"),
    }
}

// 9. 로그인 함수
fn login(username: &str, password: &str) -> Result<(), String> {
    if password == "correctpassword" {
        Ok(())
    } else {
        Err(String::from("Incorrect password."))
    }
}

// 10. 주문 상태 출력
enum OrderStatus {
    Pending,
    Completed,
}

fn print_order_status(status: OrderStatus) {
    match status {
        OrderStatus::Pending => println!("Your order is pending."),
        OrderStatus::Completed => println!("Your order is completed."),
    }
}

```

