---
title: 러스트 공식 가이드 2장 정리
summary: 
date: 2024-03-31 20:35:47 +0900
lastmod: 2024-03-31 20:35:47 +0900
tags: ["Rust"]
categories: 
public: true
parent: 
description: 
showToc: true
---

#### 2. Programming a Guessing Game
> 간단한 숫자 맞추는 게임을 통해 러스트의 기본적인 문법과 기능을 익히는 예제, 처음 문법을 배우는 입장에서 생각보다 다룰 내용이 많았었던 기억이 난다.

##### Setting Up a New Project

**프로젝트 생성**
```bash
$ cargo new guessing_game
$ cd guessing_game
```

##### Processing a Guess

`src/main.rs`
```rust
use std::io; // io 라이브러리를 가져온다.

fn main() {
    println!("Guess the number!");

    println!("Please input your guess.");

    let mut guess = String::new(); // 빈 문자열을 생성한다.

    io::stdin().read_line(&mut guess) // 사용자 입력을 받아 guess 변수에 저장한다.
        .expect("Failed to read line");

    println!("You guessed: {}", guess); // 사용자 입력을 출력한다.
}
```

##### Storing Values with Variables

```rust
let mut guess = String::new(); // 빈 문자열을 생성한다.
```
- `let` : 변수를 생성하는 키워드.
- `mut` : mutable한 변수를 생성한다. (변경 가능한 변수, 기본적으로는 immutable)

> 개인적인 소감이지만 이러한 부분에서 러스트의 언어 디자인이 마음에 들었다, 다른 언어는 기본적으로 가변 변수를 선언하거나 키워드를 다르게 두는데
> 러스트는 `let` 키워드로 변수를 선언하고 `mut` 키워드로 가변 변수를 선언해서 가변 변수를 선언하는 부분을 사용자가 명시적으로 표현하게끔 했다.

결론적으로 가변으로 선언한 guess라는 변수에, String::new() 표현식의 '값'을 할당한다.
참고로 러스트의 String은 표준 라이브러리의 String 타입이며, 힙에 할당된 UTF-8 인코딩된 텍스트를 가리키는 포인터이다(growable : 크기가 가변적이다).

- `::` : 연산자는 특정 타입의 연관 함수를 호출한다.

##### Receives User Input

```rust
io::stdin().read_line(&mut guess) // 사용자 입력을 받아 guess 변수에 저장한다.
```

- `io::stdin()` : io 모듈의 stdin 함수를 호출한다.
- `read_line(&mut guess)` : Stdin 타입의 read_line 메서드를 호출한다. 이 메서드는 사용자 입력을 받아들이고, 그 값을 문자열에 저장한다(정확히는 추가한다).
- `&` : 참조 연산자, 정확히는 이 값이 참조를 가리킨다는 의미이다, 참고로 `&`은 immutable 하기에 `&mut`을 사용해서 가변 참조를 만들어야 한다.

##### Handling Potential Failure with the `Result` 

```rust
    .expect("Failed to read line");
```
- read_line 메서드는 input으로 받은 String에 유저로부터 받은 값을 추가해주고, 그 결과로 Result 타입을 반환한다.
- `Result` : 러스트의 표준 라이브러리에 정의된 열거형이다. 이 열거형은 Ok와 Err 두 가지의 variant를 가지고 있다.

> 이 가이드에서 enum에 대한 좋은 정의를 제공한다. "열거형은 여러 가능한 상태 중 하나로 존재할 수 있는 타입을 나타내는데, 이때 각각의 가능한 상태를 variant라고 부릅니다."

Result의 variant는 다음과 같다.
- `Ok` : 연산이 성공적으로 완료되었음을 나타낸다.
- `Err` : 연산이 실패했음을 나타낸다.

- `Result` 타입의 값은 (다른 타입들처럼) method를 가질 수 있다. (뭔가 객체지향 프로그래밍의 인스턴스와 메서드를 연상시킨다. 러스트는 객체지향이 아니지만..)
- 무튼 `Result` 타입의 `expect` 메서드를 요약하면, `Result` 값이 `Err` variant를 가지고 있다면, 프로그램을 강제 종료하고, 인자로 받은 메시지를 출력한다.
  > 뭔가 파라미터로 받아서 처리해야 하는 것 같은데, 체이닝을 통해 이어지는 것 같다! 이러면 어디에 구현을 해뒀을까 생각해보면 나중에 trait를 배울 때 더 이해가 잘 될 것 같다.
- 반대로 `Result` 값이 `Ok` variant를 가지고 있다면, `expect` 메서드는 `Ok` variant가 가지고 있는 값을 반환한다. ~~Optional~~
- 참고로 `Result` 타입의 값에 expect 메서드를 호출하지 않으면 컴파일러는 경고를 발생시킨다(컴파일은 된다).
- `expect` 메서드는 프로그램을 강제 종료시키기 때문에, 이 메서드를 사용할 때는 주의해야 한다.

##### Printing Values with `println!`

```rust
    println!("You guessed: {}", guess); // 사용자 입력을 출력한다.
```
> ~~난 모든언어에서 포매팅이 항상 지루하더라..~~

러스트의 포매팅은 중괄호 `{}`를 사용한다. 중괄호는 문자열에 포매팅할 값의 위치를 나타낸다. 중괄호 안에는 값을 넣을 수 있다. 여러 개의 중괄호를 사용할 수도 있다.

예시 :
```rust
let x = 5;
let y = 10;
println!("x = {} and y = {}", x, y);
```


##### Generating a Secret Number

- 러스트에는 랜덤 숫자를 생성하는 기능이 내장되어 있지 않다. 따라서 외부 라이브러리(by Rust team)를 사용해야 한다.
- `rand` 라이브러리를 사용한다.
- `Cargo.toml` 파일에 의존성을 추가한다.

```toml
[dependencies]
rand = "0.8.4"
```

##### Generating a Random Number

```rust
use rand::Rng;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("The secret number is: {}", secret_number);

    println!("Please input your guess.");

    let mut guess = String::new();

    io::stdin().read_line(&mut guess)
        .expect("Failed to read line");

    println!("You guessed: {}", guess);
}
```
`Rng` 는 랜덤 숫자를 제공하는 메서드를 정의한 트레이트이다. 이 트레이트는 `rand` 라이브러리에 정의되어 있다.
trait란 뒤에서 아주 자세히 다루겠지만, 간단히 말하면 트레이트는 메서드의 집합을 정의한다.
스레드 로컬한 랜덤 숫자 생성기를 생성하고, 1부터 100까지의 랜덤 숫자를 생성한다.

> 정리하자면 `rand::thread_rng().gen_range(1..101)` 는 `rand` 라이브러리의 `thread_rng` 함수를 호출하고, 이 함수는 `Rng` 트레이트를 구현한 객체를 반환한다. 이 객체는 `gen_range` 메서드를 호출할 수 있고, 이 메서드는 1부터 100까지의 랜덤 숫자를 반환한다.
> `gen_range` 메서드는 range를 인자로 받는다. range는 `..` 연산자로 표현되며, 이 연산자는 첫 번째 숫자부터 두 번째 숫자까지의 범위를 나타낸다. 이때 두 번째 숫자는 범위에 포함되지 않는다.

##### Comparing the Guess to the Secret Number

```rust
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("The secret number is: {}", secret_number);

    println!("Please input your guess.");

    let mut guess = String::new();

    io::stdin().read_line(&mut guess)
        .expect("Failed to read line");

    let guess: u32 = guess.trim().parse()
        .expect("Please type a number!");

    println!("You guessed: {}", guess);

    // cmp 메서드는 Ordering 열거형을 반환한다.
    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Too small!"),
        Ordering::Greater => println!("Too big!"),
        Ordering::Equal => println!("You win!"),
    }
}
```

위 코드에서는 Ordering 열거형을 스코프에 가져와서 사용한다. 이 열거형은 Less, Greater, Equal 세 가지 variant를 가지고 있다.
`match` 표현식은 `guess.cmp(&secret_number)`의 결과를 패턴 매칭한다. 이 결과는 Ordering 열거형의 variant 중 하나이다.

> 열거형으로 타입의 값을 매칭하는 방식과, 그 타입 내부의 메서드를 호출하는 방식이 러스트의 특징 중 하나라고 생각한다. 이러한 방식은 러스트의 타입 시스템을 이해하는데 도움이 된다.
> 러스트의 타입 시스템은 다른 언어와는 다르게, 타입의 값과 타입의 메서드를 분리해서 생각하게끔 한다.
> 표현식과 문의 차이점을 잘 생각하면서 코드를 보면 이해가 조금 더 쉬운 것 같다.

rust arm 이라는 표현이 나왔는데, arm은 패턴 매칭을 위한 키워드인 것 같다. 이 키워드는 match 표현식에서 사용된다.
참고로 위의 코드는 아래의 컴파일 에러를 발생시킨다.
```bash
$ cargo build
   Compiling libc v0.2.86
   Compiling getrandom v0.2.2
   Compiling cfg-if v1.0.0
   Compiling ppv-lite86 v0.2.10
   Compiling rand_core v0.6.2
   Compiling rand_chacha v0.3.0
   Compiling rand v0.8.5
   Compiling guessing_game v0.1.0 (file:///projects/guessing_game)
error[E0308]: mismatched types
  --> src/main.rs:22:21
   |
22 |     match guess.cmp(&secret_number) {
   |                 --- ^^^^^^^^^^^^^^ expected struct `String`, found integer
   |                 |
   |                 arguments to this function are incorrect
   |
   = note: expected reference `&String`
              found reference `&{integer}`
note: associated function defined here
  --> /rustc/d5a82bbd26e1ad8b7401f6a718a9c57c96905483/library/core/src/cmp.rs:783:8

For more information about this error, try `rustc --explain E0308`.
error: could not compile `guessing_game` due to previous error
```

이 컴파일 에러는 `guess` 변수의 타입이 `String`인데, `cmp` 메서드의 인자로 `&secret_number`를 넘겨주고 있기 때문에 발생한다.
모두가 알고 있듯이 러스트는 강타입 언어이고 아래와 같이 수정을 해야한다.

```rust
    let guess: u32 = guess.trim().parse()
        .expect("Please type a number!");
```

```rust
    let mut guess = String::new();

    io::stdin()
        .read_line(&mut guess)
        .expect("Failed to read line");

    let guess: u32 = guess.trim().parse().expect("Please type a number!");

    println!("You guessed: {guess}");

    match guess.cmp(&secret_number) {
        Ordering::Less => println!("Too small!"),
        Ordering::Greater => println!("Too big!"),
        Ordering::Equal => println!("You win!"),
    }

```

- guess를 재선언했네...?

- rust에는 Shadowing이라는 개념이 있다. 이는 같은 이름의 변수를 여러 번 선언할 수 있다는 것이다. 이때, 이전에 선언한 변수는 가려진다.

- 나중에 더 보겠지만, 이전에 선언한 변수는 더 이상 사용할 수 없다. 이는 변수의 타입을 변경할 때 유용하다.

- 나머지는 이전에 다룬 내용과 동일하다.

##### Allowing Multiple Guesses with Looping

```rust
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..101);

    println!("The secret number is: {}", secret_number);

    loop {
        println!("Please input your guess.");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("You guessed: {}", guess);

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
```

> 크 깔끔..

- 개인적으로 변화도 많고 슈가신택스로 떡칠된 부분이 반복문이라고 생각한다.
- 타입 매칭과 break, continue같은 반복문 키워드만으로 깔끔한 코드를 작성할 수 있다.



##### 왜 굳이 처음부터 이렇게 하지 않았는지 궁금하지만, 게임 종료하기

```rust
use rand::Rng;
use std::cmp::Ordering;
use std::io;

fn main() {
    println!("Guess the number!");

    let secret_number = rand::thread_rng().gen_range(1..=100);

    loop {
        println!("Please input your guess.");

        let mut guess = String::new();

        io::stdin()
            .read_line(&mut guess)
            .expect("Failed to read line");

        let guess: u32 = match guess.trim().parse() {
            Ok(num) => num,
            Err(_) => continue,
        };

        println!("You guessed: {guess}");

        match guess.cmp(&secret_number) {
            Ordering::Less => println!("Too small!"),
            Ordering::Greater => println!("Too big!"),
            Ordering::Equal => {
                println!("You win!");
                break;
            }
        }
    }
}
```



##### Conclusion & Impression
1. 러스트의 기본 문법과 기능을 익히기에 좋은 예제였다.
2. 러스트의 타입 시스템과 패턴 매칭을 이해하는데 도움이 되었다.
3. 러스트의 표준 라이브러리에 대한 이해를 높일 수 있었다.
4. 러스트의 문법이나 기능을 배울 때, 러스트의 특징을 잘 드러내는 예제라고 생각한다.
5. 뭔가 아쉬운점은 공식 문서의 내용 그대로를 가져온 느낌인데 앞으로는 내생각을 조금 더 작성해야지!

