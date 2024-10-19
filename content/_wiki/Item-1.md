---
title: Effective Rust Item 1  데이터 구조를 타입 시스템으로 표현하라
summary: 
date: 2024-10-19 15:17:47 +0900
lastmod: 2024-10-19 15:17:47 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

# 데이터 구조를 타입 시스템으로 표현하라


> 복잡한 데이터 구조를 구성하는 방법을 배운다. 이 과정에서 enum은 핵심적인 역할을 한다.
> 러스트의 enum은 기본적으로 다른 언어와 같지만, 배리언트에 직접 데이터 필드를 넣을 수 있다는 점에서 다른 언어보다 훨씬 유연하고 표현력이 높다.

**기본 타입**

`i8 i16 i32 i64 i128` : 부호 있는 정수
`u8 u16 u32 u64 u128` : 부호 없는 정수
`isize usize` : 시스템 아키텍처에 따라 크키가 변하는 정수, 포인터와 인덱스 연산에 사용
`f32 f64` : 부동 소수점
`bool` : 참/거짓
`char` : 유니코드 문자
`()` : 유닛타입, c언어의 void와 비슷한 역할

- 특징적일것은 없지만 컴파일러가 조금 더 빡빡하게 체크해준다.

```rust
let x: i32 = 42;
let y: i16 = x;
// error[E0308]: mismatched types, 
let y: i16 = x.try_into().unwrap();

let x = 42i32;
let y: i64 = x;
// error[E0308]: mismatched types,
let y: i64 = x.try_into(); 
```

** 묶음 타입 (arggregates) **
- 튜플 : 고정된 크기의 묶음, 각 요소의 타입은 다를 수 있다.
- 배열 : 고정된 크기의 묶음, 모든 요소의 타입은 같아야 한다.
- 구조체 : 이름이 붙은 필드를 가지는 묶음, 각 필드의 타입은 다를 수 있다.
- 튜플 구조체 : 이름이 붙지 않은 필드를 가지는 묶음, 각 필드의 타입은 다를 수 있다.
```rust
// 튜플 구조체
struct TextMatch(usize, String);

let m = TextMatch(42, "hello".to_string());

assert_eq!(m.0, 42);
```

** 열거 타입 (enum) **
- 기본적으로는 상호 배타적인 값들의 집합을 나타낸다.
```rust
enum Direction {
    Up = 'h',
    Down = 'j',
    Left = 'k',
    Right = 'l',
}

assert_eq!(Direction::Up as char, 'h');
```

> 단순히 bool타입을 사용하는 것보다는 열거 타입을 사용하는 것이 더 가독성이 좋고, 유지보수하기 쉽다.

```rust
pub fn print_page(is_both_side: bool, is_color: bool) { /* ... */ }

// this better
pub fn print_page(side: Sides, color: Color) { /* ... */ }

pub enum Sides {
    Both,
    One,
}

pub enum Color {
    Color,
    BlackAndWhite,
}

```
> 사실 더 나은 방법은 뉴타입 패턴을 이용해 래핑하는 것이지만, 많약 옵션이 추가될 여지가 있다면 위처럼 열거 타입을 사용하는 것이 좋다.
- `enum`의 타입안정성은 `mathch`표현식을 통해 보장 할 수 있다.

```rust
let direction = match input {
    'h' => Direction::Up,
    'j' => Direction::Down,
    'k' => Direction::Left,
};
// error[E0004]: non-exhaustive patterns
```
- 모든 variant를 다루지 않으면 컴파일러가 에러를 발생시킨다.
> 물론 '_'를 사용해 모든 variant를 다루지 않도록 할 수 있긴 하지만, 그렇게 하면 새로운 variant가 추가되었을 때 컴파일러가 알려주지 않기 때문에 조심해서 사용해야 한다.

**필드가 있는 enum**
> C/C++에서 enum과 union을 조합한것에 타입 안정성이 보장되는 것을 그냥 enum으로 표현할 수 있다.
> 즉, 프로그램 데이터 구조의 불변성을 러스트의 타입 시스템으로 인코딩할 수 있으며, 이러한 불현성을 어기면 컴파일이 되지 않는다.

- c언어와 union을 사용한 예제
```c
enum State {
    INT,
    FLOAT
};

union Value {
    int i;
    float f;
};

struct Data {
    enum State state;
    union Value value;
};

void print_value(struct Data* data) {
    if (data->state == FLOAT) {
        printf("%f\n", data->value.f);
    }
}
```

- 러스트의 enum의 기능을 활용한 예제
```rust
enum Value {
    Int(i32),
    Float(f32),
}

fn print_value(value: Value) {
    match value {
        Value::Int(i) => println!("{}", i),
        Value::Float(f) => println!("{}", f),
    }
}
```

> 그리고, 작성자의 의도가 컴파일러뿐만 아니라 사람에게도 명확하게 드러나는 enum이야 말로 제대로 설계된 enum이라 할 수 있다.
> 이런식의 (아래의 예시처럼) 구성이야 말로 바로 이번 아이템의 핵심 주제인 '러스트는 어떻게 타입 시스템을 통해 프로그램 컨셉을 디자인하는가'를 
> 보여주는 좋은 예시라 할 수 있다.

```rust
use std::collections::{HashMap, HashSet};

pub enum SchedulerState {
  Insirt,
  Pending(HashSet<Job>),
  Running(HashMap<Job, Worker>),
}

```
- 유효하지 못한 상태가 타입에 표현 될 수 없도록 설계를 제대로 해야한다.
> 필드나 매개변수의 유효성 조건에 대한 주석이 달린다면, 개념을 타입 시스팀에 제대로 표현하지 못했다는 뜻이다.

```rust
pub struct Car {
    pub is_parked: bool,  // 주차 중이면 speed는 반드시 0이어야 한다.
    pub speed: u32,
}
```

```rust
pub enum CarState {
    Parked,
    Driving(u32),
}

pub struct Car {
    pub state: CarState,
}
```

**흔히 사용하는 enum 타입**

- `Option<T>` : 값이 있을 수도 있고 없을 수도 있는 타입
  - `Some(T)` : 값이 있는 경우
  - `None` : 값이 없는 경우
  - 컬렉션과 관련해서는 조금 더 생각해볼 부분이 있다. (`Vec<Thing>` vs `Option<Vec<Thing>>`)
  - 값이 없는 스트링에서는 ""와 None중에 어떠한것이 좋을지에 대해서는 Option<String>이 좋다.

- `Result<T, E>` : 성공할 수도 있고 실패할 수도 있는 타입
  - `Ok(T)` : 성공한 경우
  - `Err(E)` : 실패한 경우
  - 실패할 수 있는 모든 연산에 사용해야 한다.
  - `?` 연산자를 사용하면 에러를 반환하고, 함수의 반환 타입이 Result인 경우에는 자동으로 에러를 반환한다.

```rust
fn read_file_basic() -> Result<String, io::Error> {
    let mut file = match File::open("test.txt") {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut contents = String::new();
    match file.read_to_string(&mut contents) {
        Ok(_) => Ok(contents),
        Err(e) => Err(e),
    }
}

fn main() {
    match read_file_basic() {
        Ok(contents) => println!("File contents: {}", contents),
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}
```

```rust
fn read_file_chain() -> Result<String, io::Error> {
    let mut contents = String::new();
    File::open("test.txt")?.read_to_string(&mut contents)?;
    Ok(contents)
}

fn main() {
    match read_file_chain() {
        Ok(contents) => println!("File contents: {}", contents),
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}
```
