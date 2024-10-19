---
title: 러스트의 함수영 언어 특징
summary: 
date: 2024-10-19 15:53:40 +0900
lastmod: 2024-10-19 15:53:40 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 13.0.0 Functional Languages Features: Iterators and Closures
---

> Rust’s design has taken inspiration from many existing languages and techniques, and one significant influence is functional programming. Programming in a functional style often includes using functions as values by passing them in arguments, returning them from other functions, assigning them to variables for later execution, and so forth.
> In this chapter, we won’t debate the issue of what functional programming is or isn’t but will instead discuss some features of Rust that are similar to features in many languages often referred to as functional.

> 요약하자면 러스트의 디자인과 기능은 함수형 프로그래밍에서도 영감을 받았다. 하지만 뭐가 함수형인지 논의하는것보다는 많은 언어들에서 함수형 언어로 일컫어지는 기능들이 러스트에서 어떻게 사용할 수 있는지 알아본다고 한다.

구체적으로는
- `Closures` : 안에 변수를 캡쳐할 수 있는 function-like construct
- `Iterators` : series of elements를 처리하는 방법들
- 위 두가지의 성능
에 대해서 알아본다.

### 13.1 Closures: Anonymous Functions that Can Capture Their Environment
> 러스트의 클로져는 변수를 저장하거나, 다른 함수에 아규먼트로 넘길 수 있는 익명 함수이다.
> 특점 시점에 클로저를 생성하고, 다른 어딘가 다른 컨택스트에서 실행할 수 있다.
> 다만 일반 함수들과는 다르게 그들이 정의된 시점과 스코프의 값을 캡쳐할 수 있다.


#### 13.1.1 Captureing the Environment with Closures

> Scenario : 티셔츠 회사에서는 프로모션으로 메일링 리스트에 등록된 사람에게 한정판 티셔츠를 무료로 증정한다. 
> 메일링 리스트에 등록된 사람들은 선택적으로 프로필에 자신의 좋아하는 색상을 추가할 수 있다. 
> 만약 무료 티셔츠를 받게 된 사람이 좋아하는 색상을 설정해 놓았다면, 그 색상으로 티셔츠를 받는다. 
> 만약 좋아하는 색상을 지정하지 않았다면, 회사에서 현재 가장 많이 보유하고 있는 색상의 티셔츠를 받게 된다.

```rust
#[derive(Debug, PartialEq, Copy, Clone)]
enum ShirtColor {
    Red,
    Blue,
}

struct Inventory {
    shirts: Vec<ShirtColor>,
}

impl Inventory {
    fn giveaway(&self, user_preference: Option<ShirtColor>) -> ShirtColor {
        user_preference.unwrap_or_else(|| self.most_stocked())
    }

    fn most_stocked(&self) -> ShirtColor {
        let mut num_red = 0;
        let mut num_blue = 0;

        for color in &self.shirts {
            match color {
                ShirtColor::Red => num_red += 1,
                ShirtColor::Blue => num_blue += 1,
            }
        }
        if num_red > num_blue {
            ShirtColor::Red
        } else {
            ShirtColor::Blue
        }
    }
}

fn main() {
    let store = Inventory {
        shirts: vec![ShirtColor::Blue, ShirtColor::Red, ShirtColor::Blue],
    };

    let user_pref1 = Some(ShirtColor::Red);
    let giveaway1 = store.giveaway(user_pref1);
    println!(
        "The user with preference {:?} gets {:?}",
        user_pref1, giveaway1
    );

    let user_pref2 = None;
    let giveaway2 = store.giveaway(user_pref2);
    println!(
        "The user with preference {:?} gets {:?}",
        user_pref2, giveaway2
    );
}
```
- `user_preference.unwrap_or_else(|| self.most_stocked())` : 여기서 클로저가 사용되었다.
먼저 `Option<T>`의 `unwrap_or_else` 메소드는 `Option<T>`가 `Some`이면 `T`를 반환하고, `None`이면 클로저를 실행한다.
```rust
impl<T> Option<T> {
    pub fn unwrap_or_else<F>(self, f: F) -> T
    where
        F: FnOnce() -> T,   // 이때 F는 T를 반환하는 클로저 타입, 이외에도 FnMut, Fn 트레이트도 있다.
    {
        match self {
            Some(value) => value,
            None => f(),    // None이면 클로저 f를 실행해 그 결과를 반환
        }
    }
}
```
- `|| self.most_stocked()` : 즉 여기서는 `||`로 시작하고, `self.most_stocked()`를 본문으로 가지는 클로저를 넘긴 것이다.
- 결과값이 필요해진 경우 (`unwrap_or_else`가 호출되는 경우) 클로저가 실행되어 `most_stocked` 메소드를 호출한다.

> 이 부분이 헷갈리는 이유는 함수로도 구현할 수 있어보이기 때문인데 (함수를 파라미터로 넘기면), 
> 사실 가장중요한건 외부 환경(여기서는 self)을 캡처할 수 있다는 것이다. 
> 즉, 클로저는 self를 따로 매개변수로 넘기지 않아도 내부에서 접근할 수 있다.
> 반례 (함수 포인터를 넘기는 경우)를 생각하려 한다면, `Option<T>`의 `unwrap_or_else` 메소드가 `Inventory`, `ShirtColor` 타입을 알아야 한다..
> 함수 포인터를 넘기는 경우 필요한 데이터를 명시적으로 매개변수로 전달해야 하거나 별도로 래핑을 해서 전달해야 한다.


#### 13.1.2 Closure Type Inference and Annotation

> 클로저는 대부분의 상황에서 타입을 명시적으로 지정할 필요가 없다.
> 반면 함수는 하나의 인터페이스 노출되기 때문에 명시적으로 (모두가 동의하는) 타입을 지정해야 한다.
> 클로저는 노출된 인터페이스처럼 사용되지 않기 때문에 그렇다.
> 당연히 컴파일러의 타입추론에 의존하고, 꼭 필요한 경우에 타입을 명시적으로 지정하기도 한다.

```rust
fn  add_one_v1   (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|             { x + 1 };
let add_one_v4 = |x|               x + 1  ;
```
- 넷 다 가능하고, 타입을 지정하지 않으면 평가시점에 타입을 추론한다.

```rust
    let example_closure = |x| x;

    let s = example_closure(String::from("hello"));
    let n = example_closure(5);
```
```bash
$ cargo run
   Compiling closure-example v0.1.0 (file:///projects/closure-example)
error[E0308]: mismatched types
 --> src/main.rs:5:29
  |
5 |     let n = example_closure(5);
  |             --------------- ^- help: try using a conversion method: `.to_string()`
  |             |               |
  |             |               expected struct `String`, found integer
  |             arguments to this function are incorrect
  |
note: closure parameter defined here
 --> src/main.rs:2:28
  |
2 |     let example_closure = |x| x;
  |                            ^

For more information about this error, try `rustc --explain E0308`.
error: could not compile `closure-example` due to previous error

```
- `example_closure`는 처음 평가시 `String`을 받았기 때문에 `String`으로 타입이 결정되었다.
- 클로저의 소유권은 함수와 대응된다(동일하다)
```rust
fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let only_borrows = || println!("From closure: {:?}", list);

    println!("Before calling closure: {:?}", list);
    only_borrows();
    println!("After calling closure: {:?}", list);
}
```
- 위의 경우 불변 참조를 사용했기 때문에 컴파일이 된다.

```rust
fn main() {
    let mut list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    let mut borrows_mutably = || list.push(7);
    // println!("Before calling closure: {:?}", list);
    borrows_mutably();
    println!("After calling closure: {:?}", list);
}
```

- 위의 경우 가변 참조를 이용해서 벡터를 수장 할 수 있다.
- 만약 주석을 해제하면 컴파일 에러가 발생한다.
- 만약 소유권 이전을 하고 싶다면 `move` 키워드를 사용한다.
```rust
use std::thread;

fn main() {
    let list = vec![1, 2, 3];
    println!("Before defining closure: {:?}", list);

    thread::spawn(move || println!("From thread: {:?}", list))
        .join()
        .unwrap();
}
```
- `move` 키워드를 사용하면 클로저는 소유권을 이전받는다.
- 이 예제는 새로운 쓰레드에서 클로저를 실행하는데 클로저 본문이 immutable 참조만 필요하기에 기본적으로는 immutable 참조를 사용한다.
- 그런데 소유권은 아직 메인 쓰레드에 있기 때문에 불변참조가 유지되는동안 list가 drop될 가능성이 있다.
- 그래서 `move` 키워드를 사용해서 소유권을 이전하도록 강제되어있다.

#### 13.1.3 Moving Captured Values Out of Closures and the Fn Traits

클로저가 외부 환경으로부터 변수를 캡처하는 방식은 Rust에서 **Fn**, **FnMut**, **FnOnce** 트레이트에 영향을 준다.

클로저는 외부 환경에서 변수를 캡처할 수 있으며, 이를 처리하는 방식은 크게 세 가지로 나뉜다:

- **값을 클로저 내부로 이동시키기**: 외부 변수의 소유권을 가져오는 경우.
- **값을 변경하기**: 외부 변수의 값을 변경할 수 있는 경우.
- **값을 읽기만 하기**: 외부 변수의 값을 읽기만 하고, 변경하지 않는 경우.

Rust에서는 클로저가 외부 변수를 어떻게 캡처하느냐에 따라 **Fn**, **FnMut**, **FnOnce** 트레이트 중 하나가 자동으로 구현된다.

`FnOnce`: 클로저가 외부 변수의 소유권을 가져가면 **한 번만 호출**될 수 있다.

`FnMut`: 클로저가 외부 변수의 값을 변경할 수 있는 경우, **여러 번 호출** 가능하다.

`Fn`: 외부 변수를 읽기만 할 때는 **여러 번 호출** 가능하다.

```rust
fn consume_with_fn_once<F>(f: F)
where
    F: FnOnce(),
{
    f();  // 한 번만 호출 가능
}

fn main() {
    let name = String::from("Rust");

    let introduce = || {
        // name의 소유권을 가져가서 이동시킴
        println!("Hello, {}!", name);
    };

    consume_with_fn_once(introduce); // OK
    // introduce();  // 에러 발생! introduce는 이미 소유권을 이동시켜 한 번만 호출 가능
}
```

클로저가 외부 변수의 소유권을 가져가기 때문에, `FnOnce` 트레이트가 적용된다. 소유권이 이동되었으므로 클로저는 한 번만 호출 가능하다.

```rust
fn consume_with_fn_mut<F>(mut f: F)
where
    F: FnMut(),
{
    f();  // 여러 번 호출 가능
    f();
}

fn main() {
    let mut count = 0;

    let mut increment = || {
        count += 1; // 외부 변수 count를 변경
        println!("Count: {}", count);
    };

    consume_with_fn_mut(increment);  // OK
}
```

클로저가 외부 변수를 가변 참조로 캡처하여 값을 변경하므로 `FnMut` 트레이트가 적용된다. 클로저는 여러 번 호출 가능하다.

```rust
fn consume_with_fn<F>(f: F)
where
    F: Fn(),
{
    f();  // 여러 번 호출 가능
    f();
}

fn main() {
    let greeting = String::from("Hello");

    let say_hello = || {
        println!("{}", greeting);  // greeting을 읽기만 함
    };

    consume_with_fn(say_hello);  // OK
}
```

클로저가 외부 변수를 읽기만 하므로 `Fn` 트레이트가 적용된다. 변수를 변경하지 않기 때문에 여러 번 호출이 가능하다.

클로저가 외부 변수를 어떻게 캡처하느냐에 따라 Rust는 자동으로 `Fn`, `FnMut`, `FnOnce` 트레이트를 구현한다.

- **`FnOnce`**: 클로저가 외부 변수의 소유권을 가져갈 때.
- **`FnMut`**: 클로저가 외부 변수를 변경할 때.
- **`Fn`**: 클로저가 외부 변수를 읽기만 할 때.

이러한 방식으로 Rust는 클로저가 외부 변수와 어떻게 상호작용하는지에 따라 자동으로 적절한 트레이트를 적용해준다.

