---
title: 러스트의 함수영 언어 특징
summary: 
date: 2024-10-19 15:53:40 +0900
lastmod: 2025-04-30 15:50:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# 13.0.0 Functional Languages Features: Iterators and Closures

---

> Rust의 디자인과 기능은 함수형 프로그래밍에서 영감을 받았습니다. 함수형 스타일로 프로그래밍하는 것은 종종 함수를 값으로 사용하여 인수로 전달하거나, 다른 함수에서 반환하거나, 나중에 실행하기 위해 변수에 할당하는 등의 작업을 포함합니다. 이 장에서는 함수형 프로그래밍이 무엇인지 아닌지에 대해 논쟁하지 않고, 대신 함수형이라고 불리는 많은 언어의 기능과 유사한 Rust의 일부 기능에 대해 논의할 것입니다.

> 요약하자면 러스트의 디자인과 기능은 함수형 프로그래밍에서도 영감을 받았다. 하지만 뭐가 함수형인지 논의하는것보다는 많은 언어들에서 함수형 언어로 일컫어지는 기능들이 러스트에서 어떻게 사용할 수 있는지 알아본다고 한다.

구체적으로는

- `Closures` : 안에 변수를 캡쳐할 수 있는 function-like construct
- `Iterators` : series of elements를 처리하는 방법들
- 위 두가지의 성능 에 대해서 알아본다.

## 13.1 Closures: Anonymous Functions that Can Capture Their Environment

> 러스트의 클로져는 변수를 저장하거나, 다른 함수에 아규먼트로 넘길 수 있는 익명 함수이다. 특점 시점에 클로저를 생성하고, 다른 어딘가 다른 컨택스트에서 실행할 수 있다. 다만 일반 함수들과는 다르게 그들이 정의된 시점과 스코프의 값을 캡쳐할 수 있다.

클로저는 함수와 유사하지만 자신이 정의된 환경의 변수들을 사용할 수 있다.

### 13.1.1 Capturing the Environment with Closures

> Scenario : 티셔츠 회사에서는 프로모션으로 메일링 리스트에 등록된 사람에게 한정판 티셔츠를 무료로 증정한다. 메일링 리스트에 등록된 사람들은 선택적으로 프로필에 자신의 좋아하는 색상을 추가할 수 있다. 만약 무료 티셔츠를 받게 된 사람이 좋아하는 색상을 설정해 놓았다면, 그 색상으로 티셔츠를 받는다. 만약 좋아하는 색상을 지정하지 않았다면, 회사에서 현재 가장 많이 보유하고 있는 색상의 티셔츠를 받게 된다.


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

- `user_preference.unwrap_or_else(|| self.most_stocked())` : 여기서 클로저가 사용되었다. 먼저 `Option<T>`의 `unwrap_or_else` 메소드는 `Option<T>`가 `Some`이면 `T`를 반환하고, `None`이면 클로저를 실행한다.


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

> 이 부분이 헷갈리는 이유는 함수로도 구현할 수 있어보이기 때문인데 (함수를 파라미터로 넘기면), 사실 가장중요한건 외부 환경(여기서는 self)을 캡처할 수 있다는 것이다. 즉, 클로저는 self를 따로 매개변수로 넘기지 않아도 내부에서 접근할 수 있다. 반례 (함수 포인터를 넘기는 경우)를 생각하려 한다면, Option<>의 unwrap_or_else 메소드가 Inventory, ShirtColor 타입을 알아야 한다. 함수 포인터를 넘기는 경우 필요한 데이터를 명시적으로 매개변수로 전달해야 하거나 별도로 래핑을 해서 전달해야 한다.

이 예제에서의 핵심은 클로저가 `self`를 캡처하여 `most_stocked()` 메서드에 접근한다는것. 클로저 없이 일반 함수로 구현했다면, 함수에 `Inventory` 인스턴스를 명시적으로 전달해야 했어야함. 클로저의 강점은 바로 이런 상황에서 주변 환경의 변수를 자연스럽게 사용할 수 있다는 점.

### 13.1.2 Closure Type Inference and Annotation

> 클로저는 대부분의 상황에서 타입을 명시적으로 지정할 필요가 없다. 반면 함수는 하나의 인터페이스 노출되기 때문에 명시적으로 (모두가 동의하는) 타입을 지정해야 한다. 클로저는 노출된 인터페이스처럼 사용되지 않기 때문에 그렇다. 당연히 컴파일러의 타입추론에 의존하고, 꼭 필요한 경우에 타입을 명시적으로 지정하기도 한다.

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

> 이 예제는 중요한 점을 보여줍니다: 클로저가 처음 호출될 때 컴파일러는 인자 타입을 기록하고, 이후 다른 타입으로 호출하면 오류가 발생합니다. 클로저는 유연하지만 한 번 타입이 결정되면 그 타입만 받을 수 있습니다.

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
- 위의 경우 가변 참조를 이용해서 벡터를 수정 할 수 있다.
- 만약 주석을 해제하면 컴파일 에러가 발생한다.
- 만약 소유권 이전을 하고 싶다면 `move` 키워드를 사용한다.

여기서 주석 해제 시 컴파일 에러가 발생하는 이유는 클로저가 `list`에 대한 가변 참조를 가지고 있는데, 주석 해제 시 동시에 불변 참조도 시도하기 때문. (Rust의 소유권 규칙)
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

이 예제는 스레드 간 데이터 공유 시 `move` 키워드의 중요성을 보여줍니다. 스레드는 독립적으로 실행되기 때문에, 참조 대신 소유권을 이전하는 것이 안전합니다. 그렇지 않으면 메인 스레드가 먼저 종료되어 참조가 무효화될 수 있습니다.

### 13.1.3 Moving Captured Values Out of Closures and the Fn Traits

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

- 클로저가 외부 변수를 가변 참조로 캡처하여 값을 변경하므로 `FnMut` 트레이트가 적용된다.
- 클로저는 여러 번 호출 가능하다.

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

### 추가 정보: 클로저 사용 시 실용적인 팁

1. 클로저는 함수형 메서드와 함께 사용할 때 가장 효과적 (map, filter, fold 등)
2. 클로저의 타입 추론을 활용하여 코드를 간결하게 유지가능
3. 클로저가 외부 변수를 캡처하는 방식에 따라 자동으로 Fn, FnMut, FnOnce 트레이트가 결정됨
4. 병렬 프로그래밍에서는 `move` 키워드를 사용하여 데이터 경쟁 상태를 방지
5. 클로저는 짧은 일회성 코드 조각에 이상적이며, 복잡한 로직은 일반 함수로 분리하는 것이 좋습니다

## 13.2 Processing a Series of Items with Iterators

>The iterator pattern allows you to perform some task on a sequence of items in turn. An iterator is responsible for the logic of iterating over each item and determining when the sequence has finished. 
- '연속(next)', '종료'를 기반으로 연속된 요소로부터 특정 로직을 수행함
- 여타 다른언어와 다른점은 따로 없다. iter를 구현해두면 반복적인 반복로직을 작성하지 않아도 됨
- iterator는 'lazy'하다 즉 지연 평가되며, 호출 전까지는 소비하지 않음

### 13.2.1 The Iterator Trait and the next Method
```rust
pub trait Iterator {
    type Item;

    fn next(&mut self) -> Option<Self::Item>;

    // methods with default implementations elided
}

    #[test]
    fn iterator_demonstration() {
        let v1 = vec![1, 2, 3];

        let mut v1_iter = v1.iter();

        assert_eq!(v1_iter.next(), Some(&1));
        assert_eq!(v1_iter.next(), Some(&2));
        assert_eq!(v1_iter.next(), Some(&3));
        assert_eq!(v1_iter.next(), None);
    }

```
- Iterator 트레잇의 next() 메서드는 &mut self를 요구한다.
- 즉, next()를 호출하려면 해당 반복자에 대한 **가변 참조**가 필요하므로, 변수 자체가 mut여야 한다.
- 반복자는 내부 상태를 유지하고 있으며, next()가 호출될 때마다 상태가 바뀌므로 가변성이 필요하다.

### 13.2.2 Methods that Consume the Iterator
Consuming Adapters (소비형 어댑터)
- next()를 호출하여 **iterator의 소유권을 가져가며 상태를 소모**함
- 대표 예시:
    - sum(), collect(), for_each(), count(), last()

```rust
let v1 = vec![1, 2, 3];
let v1_iter = v1.iter();
let total: i32 = v1_iter.sum();
// v1_iter는 여기서 소모되어 이후에 사용할 수 없음
```
- sum()은 반복자를 끝까지 소비하며 합계를 반환
- collect()는 결과를 벡터나 해시맵 등 다른 컬렉션으로 수집
- for_each()는 side effect만 실행하고 값을 반환하지 않음

### 13.2.3 Iterator Adapters
- 원래 반복자의 요소를 **변형하거나 필터링**하여 **새로운 반복자**를 생성
- 내부적으로는 next()를 호출하지 않기 때문에 **게으르게 동작함**
- 대표 예시:
    - map(), filter(), take(), skip(), enumerate()

```rust
let v1 = vec![1, 2, 3];
v1.iter().map(|x| x + 1);  // 아무 일도 일어나지 않음
```

```rust
let v1 = vec![1, 2, 3];
let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();
assert_eq!(v2, vec![2, 3, 4]);
```
Rust 반복자는 **lazy evaluation**을 사용
→ map() 같은 어댑터는 **실제 연산을 하지 않고**, 연산을 담은 새로운 반복자만 생성함
→ collect()나 for_each() 같은 소비형 어댑터가 호출될 때만 실행됨

### 13.2.4 Using Closures that Capture Their Environment
```rust
#[derive(PartialEq, Debug)]
struct Shoe {
    size: u32,
    style: String,
}

fn shoes_in_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
    shoes.into_iter().filter(|s| s.size == shoe_size).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn filters_by_size() {
        let shoes = vec![
            Shoe {
                size: 10,
                style: String::from("sneaker"),
            },
            Shoe {
                size: 13,
                style: String::from("sandal"),
            },
            Shoe {
                size: 10,
                style: String::from("boot"),
            },
        ];

        let in_my_size = shoes_in_size(shoes, 10);

        assert_eq!(
            in_my_size,
            vec![
                Shoe {
                    size: 10,
                    style: String::from("sneaker")
                },
                Shoe {
                    size: 10,
                    style: String::from("boot")
                },
            ]
        );
    }
}
```

클로저가 환경을 캡처한다는 뜻은?
- 클로저는 함수처럼 동작하지만, **자신이 정의된 스코프의 변수들을 사용할 수 있습니다.**
- 이 경우 |s| s.size == shoe_size에서 shoe_size는 클로저 밖에 정의된 변수지만 **클로저가 이를 자동으로 참조**
- 다시 한번 거론되었지만, Rust에서는 이 과정이 **캡처(capture)**라고 부르며, **필요한 변수만 자동으로 가져옴.**

filter 어댑터는 어떤 역할을 하나요?
- filter는 반복자에서 각 항목을 받아 true/false로 판단하는 **클로저를 인자로 받음.**
- 클로저가 true를 반환하면 해당 항목은 **다음 반복자로 전달**되고,
- false를 반환하면 **버려짐.**
> bool을 반환하는 클로저를 인자로 받아 해당 실행값이 true인 경우만 filter가 생성하는 다음 반복자에 전달
