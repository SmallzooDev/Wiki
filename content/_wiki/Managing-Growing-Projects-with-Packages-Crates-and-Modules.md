---
title: Package, Crates, Modules
summary: 
date: 2024-04-13 23:04:16 +0900
lastmod: 2024-04-13 23:04:16 +0900
tags: ["Rust"]
categories: 
description: 
showToc: true
tocOpen: true
---


## 7.0 패키지, 크래이트, 모듈을 이용해 커지는 프로젝트를 관리하기

- 프로젝트가 커지면서 코드를 관리하는 것이 중요해진다, 기능을 단위로 모듈화하고 나눠야 관리하는것이 편리하다.

- 이 챕터는 그러한 것들을 하는 방법을 다룬다.

- 높은 레벨에서의 코드 재사용성을 위해 encaptulating, implementing등 달성하는 방법을 다룬다.

- 실제 구현을 알지 못해도 사용할 수 있는 인터페이스로 추상화를 제공하는 방법을 다룬다.

- scope와 namespace를 이용해 코드를 구조화하는 방법을 다룬다.

- 위에 내용들을 아우르는 러스트의 모듈화 시스템은 아래와 같다.

  - `package` : 크레이트를 빌드하고 공유하는 단위
  - `crate` : 라이브러리나 실행파일을 빌드하는 단위
  - `module` : 코드를 그룹화하고 namespace를 제공하는 단위
  - `path` : 모듈을 참조하는 방법

### 7.1 Package and Crates

- `crate`는 러스트의 컴파일러가 한번에 고려 할 수 있는 가장 최소의 코드 단위이다.

- `cargo` 가 아닌 `rustc`로 컴파일을 하는 경우에, 하나의 소스코드파일만 컴파일 하더라도, 컴파일러는 그 하나의 파일을 하나의 크레이트로 취급한다.

- `crate`는 모듈을 포함 할 수 있는데, 해당 모듈은 `crate`로 컴파일된 다른 모듈에 정의 된 것을 사용할 수 있다.

- `crate`는 두가지 형태로 나뉜다.

  - `binary crate` : 실행파일을 만드는 크레이트, cli 프로그램이나 서버 프로그램처럼, 또한 `main`함수를 꼭 ㅎ포함해야한다.
  - `library crate` : 라이브러리를 만드는 크레이트, `main`함수를 포함하지 않으며, 실행 가능한 바이너리를 만들지 않는다.

- `crate root`는 컴파일러가 크레이트를 시작하는 파일을 가리킨다. 이 파일은 `crate`의 루트 모듈을 정의한다.

- `package`는 하나 이상의 크레이트들을 포함하는(bundle) 단위이다. 
 
- `package`는 `Cargo.toml`파일을 가지며, 이 파일은 `package`의 메타데이터를 정의해서 package 내부의 해당 크레이트들을 어떻게 빌드 해야 하는지 알려준다.

- `package`는 하나의 크레이트만 포함 할 수도 있고, 여러개의 크레이트를 포함 할 수도 있다.

- 다수의 `binary crate`를 가질 수 있으나, 하나의 `library crate`만 가질 수 있다.

- `src/main.rs`와 `src/lib.rs`는 각각 `binary crate`와 `library crate`의 `crate root`이다.

## 7.2 Defining Modules to Control Scope and Privacy

이 챕터에서는 모듈과 모듈 시스템에 대해 다룬다.
주요 키워드들은 다음과 같다

- `module` : 코드를 그룹화하고 namespace를 제공하는 단위
- `use` : 모듈을 다른 스코프로 가져오는 키워드
- `as` : 가져온 모듈을 다른 이름으로 사용하는 키워드
- `pub` : 모듈을 공개하는 키워드

### 7.2.1 Modules Cheetsheet

러스트의 모듈 시스템이 따르는 규칙과 동작하는 방법은 아래와 같다.

- `Start from the crate root` : 크레이트를 컴파일 할 때, 컴파일러는 컴파일 할 코드를 찾기 위해 `crate root`를 찾는다. (`src/main.rs`와 `src/lib.rs`).

- `Declaring modules` : crate root에서 새로운 모듈들을 선언 할 수 있따. 모듈은 `mod` 키워드와 선언한다. 예를들어 `mod garden;`과 같이 선언하면 컴파일러는 모듈의 코드를 아래와 같은 위치에서 찾는다
 
- `Defining modules in other files` : 모듈을 다른 파일에 정의 할 수 있다. 이때 파일의 이름은 모듈의 이름과 같아야 한다. 예를들어 `mod garden;`이라고 선언하면, `garden.rs`나 `garden/mod.rs`파일을 찾는다.
  - Inline : `mod garden { ... }` 와 같이 중괄호와 세미콜론으로 정의된 모듈이 있는지 인라인에서 찾는다.
  - File : `src/garden.rs`나 `src/garden/mod.rs`파일을 찾는다.
 
 - `Declaring subomodules` : 모듈 내부에 또 다른 모듈을 선언 할 수 있다(crate root에는 안된다). 이때도 `mod` 키워드를 사용한다. 이번에는 `mod vegetables;`를 `mod garden;`안에 선언하면 아래와 같은 순서로 찾는다.
  - Inline : `mod vegetables { ... }` 와 같이 중괄호와 세미콜론으로 정의된 모듈이 있는지 인라인에서 찾는다.
  - File : `src/garden/vegetables.rs`나 `src/garden/vegetables/mod.rs`파일을 찾는다.

- `Paths to code in modules` : 모듈이 크레이트에 일부가 된다면, 해당 모듈의 코드를 크레이트의 어디에서든 참조할 수 있다. 만약 pricacy 규칙에 어긋나지 않는다면 `Asparagus`모듈의 `type`을 호출하려면 `crate::garden::vegetables::Asparagus`와 같이 호출 할 수 있다.

- `Private vs public` : 모듈 내부의 코드는 기본적으로 private이다. `pub` 키워드를 사용해 모듈을 공개 할 수 있다. 모듈을 공개하면, 다른 크레이트에서 해당 모듈을 사용 할 수 있다.

- `Use` : `use` 키워드를 사용해 모듈을 가져올 수 있다. `use` 키워드는 모듈을 현재 스코프로 가져온다.

```
// binary crate name backyard
backyard
├── Cargo.lock
├── Cargo.toml
└── src
    ├── garden
    │   └── vegetables.rs
    ├── garden.rs
    └── main.rs
```

File : `src/main.rs`
```rust
use crate::garden::vegetables::Asparagus;

pub mod garden;

fn main() {
    let plant = Asparagus {};
    println!("I'm growing {:?}!", plant);
}
```

File : `src/garden.rs`
```rust
pub mod vegetables;
```

File : `src/garden/vegetables.rs`
```rust
pub struct Asparagus {
    pub name: String,
}
```

### 7.2.2 Grouping Related Code in Modules

- 모듈은 크레이트 내부의 코드를 조직화햇해서 읽기 쉽고 재사용 가능한 코드를 만들 수 있게 해준다.

- 또한 private과 public으로 코드의 접근성을 제어할 수 있다.

- 기본적으로 private으로 캡슐화 하기 때문에, 다른 코드에서 해당 구현을 알거나 사용할 수 없다.

- 실제로 사용하거나 의존해야 할 코드들만 public으로 만들면 된다. 

- 아래는 모듈을 사용해 레스토랑을 만드는 예제이다.


Filename : `src/lib.rs`
```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}

        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}

        fn serve_order() {}

        fn take_payment() {}
    }
}
```
- 이런식으로 모듈을 사용하고, 그룹화해두면 왜 관련되어 있는지를 알 수 있고, 그러한 코드들을 쉽게 찾을 수 있다.

- 마찬가지로 이 모듈에 코드를 추가/수정 할 때도, 그러기 위한 가이드라인을 제공해 줄 수 있다.

module tree
```
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```

- 참고로 `src/main.rs`나 `src/lib.rs`는 crate root인 이유는, 이 두 파일중 하나가 크레이트의 모듈구조 루트인 모듈 `crate`를 선언하기 때문이다.

- 그리고 그 아래에 마치 파일시스템처럼 모듈이 구조화 될 수 있다.

## 7.3 Paths for Referring to an Item in the Module Tree

- 위에 살짝 언급한 것처럼 우리가 러스트에서 모듈의 아이템을 찾기 위해서는 파일시스템처럼 `path`를 기반으로 찾아나가게 된다.

- `path`는 두가지 형태가 있다.
  - `absolute path` : 크레이트의 루트에서 시작하는 경로, 루트는 `crate`나 `mod` 키워드로 선언된 모듈이다.
  - `relative path` : 현재 모듈에서 시작하는 경로, `self`, `super`, 혹은 아이템의 이름으로 시작한다.

- 두 경로 모두, 하나 이상의 식별자와 `::` 로 구분된다.

- 아래는 `crate`의 루트 모듈에서 `front_of_house`모듈의 `hosting`모듈의 `add_to_waitlist`함수를 호출하는 예제이다.

```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // Absolute path
    crate::front_of_house::hosting::add_to_waitlist();

    // Relative path
    front_of_house::hosting::add_to_waitlist();
}
```
- 첫 번째 호출은 `crate`의 루트 모듈에서 시작하는 `absolute path`이다.

- 두 번째 호출은 현재 모듈에서 시작하는 `relative path`이다.

> 가능하면 상대경로 대신 절대경로를 지정하는 것이 낫다고 이야기한다. 당연히 일장일단은 있지만, 코드 수정이나 리팩토링을 할 때, 
> 수정이 얼마나 적어질지가 가장 주요한 기준이라고 했을 때,
> 코드 정의와 호출을 서로 독립적으로 이동하려는 경우가 더 많이 때문이라고 이야기한다. 
> 호출하는 부분이 정의된 부분에 대한 상대경로를 사용하면, 정의된 부분이 다른곳으로 옮겨졌을 때, 호출하는 부분의 변경이 생기는 상황이 더 자주 발생한다.

- 무튼 위의 코드는 동작하지 않는다. 왜냐하면 `add_to_waitlist`함수는 private이기 때문이다.

- 이를 해결하기 위해서는 `pub`키워드를 사용해야 한다.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}
```

### 7.4.1 Starting Relative Paths with `super`

- `super` 키워드를 사용해 상위 모듈로 이동할 수 있다.

- file system에서 `..`과 같은 역할을 한다.

- 부모 모듈과 자식 모듈이 연관되어 있을 때, rearrange를 할 때 유용하다.

Filename : `src/lib.rs`

```rust
fn deliver_order() {}

mod back_of_house {
    fn fix_incorrect_order() {
        cook_order();
        super::deliver_order();
    }

    fn cook_order() {}
}
```

- 이러한 기능을 제공하는 이유는, 모듈의 구조를 변경할 때, 코드를 수정하지 않고도 모듈의 위치를 변경할 수 있게 해주기 때문이다.

### 7.3.2 Making Structs and Enums Public

- 구조체와 열거형에서도 `pub`키워드를 사용해 접근성을 제어 할 수 있지만, 추가적으로 알아야 할 것이 있다.

- 구조체가 public이라고 해서 그 구조체의  필드가 public이 되는 것은 아니다.

- 구조체의 필드를 public으로 만들려면, 구조체의 필드를 public으로 만들어야 한다.


```rust
mod back_of_house {
    pub struct Breakfast {
        pub toast: String,
        seasonal_fruit: String,
    }

    impl Breakfast {
        pub fn summer(toast: &str) -> Breakfast {
            Breakfast {
                toast: String::from(toast),
                seasonal_fruit: String::from("peaches"),
            }
        }
    }
}

pub fn eat_at_restaurant() {
    // Order a breakfast in the summer with Rye toast
    let mut meal = back_of_house::Breakfast::summer("Rye");
    // Change our mind about what bread we'd like
    meal.toast = String::from("Wheat");
    println!("I'd like {} toast please", meal.toast);

    // The next line won't compile if we uncomment it; we're not allowed
    // to see or modify the seasonal fruit that comes with the meal
    // meal.seasonal_fruit = String::from("blueberries");
}
```

- 위의 코드는 private으로 선언된 `seasonal_fruit`필드가 있어 해당 필드를 접근하려고 하면 컴파일 에러가 발생한다.

- 심지어 해당 struct의 인스턴스를 생성할 때도, 해당 필드를 초기화 할 수 없기 때문에, summer와 같은 생성자를 만들어서 사용해야 한다.

- 패키지와 클래스의 의의가 상대적으로 불분명했던 자바와 달리, 러스트는 패키지와 크레이트의 경계가 명확하고, 어떠한 의미에서는 캡슐화에 대한 더 다양한 제어를 제공한다.

- 반대로 enum은 그 자체로 public이면, 그 안에 있는 모든 variant들도 public이다.

```rust
mod back_of_house {
    pub enum Appetizer {
        Soup,
        Salad,
    }
}

pub fn eat_at_restaurant() {
    let order1 = back_of_house::Appetizer::Soup;
    let order2 = back_of_house::Appetizer::Salad;
}
```

## 7.4 Bringing Paths into Scope with the `use` Keyword

- `use` 키워드를 사용하면, 모듈의 아이템을 현재 스코프로 가져올 수 있다.

- `use` 키워드는 `::`를 사용해 접근해야 하는 아이템을 간단하게 사용할 수 있게 해준다.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
}
```
- `use` 키워드를 사용하면, symbolic link를 만드는 것과 같다.

- `use` 는 `use`를 선언한 스코프에서만 유효하다.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    use crate::front_of_house::hosting;
    hosting::add_to_waitlist();
}

fn seat_at_table() {
    hosting::add_to_waitlist(); // 컴파일 에러
}
```

### 7.4.2 Creating Idiomatic use Paths

- `use` 키워드를 사용해서 함수를 특정해서 가져오는것이 아니라 모듈을 가져오는 것이 의아 할 수 있다.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

use crate::front_of_house::hosting::add_to_waitlist;

pub fn eat_at_restaurant() {
    add_to_waitlist();
}
```

- 물론 결과는 같다.

- 이렇게 부모 모듈까지 불러오면, 실제로 사용 할 때는 `hosting::add_to_waitlist`와 같이 사용해야 하고, 이렇게 하면서 이 함수가 로컬에 정의되어 있지 않다는 것을 알리면서 최소한의 경로를 사용 할 수 있게 해준다.

- 반대로 `use` 키워드를 사용해 함수를 가져오면 해당 함수가 어디에 정의되어있는지 헷갈릴 수 있다.

- 반대로 `struct`나 `enum`을 가져올 때는, 전체 경로를 명시하는것이 관용적이다.

```rust
use std::collections::HashMap;

fn main() {
    let mut map = HashMap::new();
    map.insert(1, 2);
}
```
- 딱히 이유는 없고, 그냥 관용적인 방법이다.

- 또한 `use` 키워드를 사용해 여러개의 아이템을 가져올 때 같은 이름을 가진 아이템을 가져올 수 없다.

```rust
use std::fmt;
use std::io;

fn function1() -> fmt::Result {
    // --snip--
}

fn function2() -> io::Result<()> {
    // --snip--
}
```

만약 아래와 같이 사용하면 컴파일 에러가 발생한다.

```rust
use std::fmt::Result;
use std::io::Result;

fn function1() -> Result {
    // --snip--
}

fn function2() -> Result<()> {
    // --snip--
}
```

- 이런 경우에는 `as` 키워드를 사용해 다른 이름으로 가져올 수 있다.

```rust
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {
    // --snip--
}

fn function2() -> IoResult<()> {
    // --snip--
}

```

### 7.4.3 Re-exporting Names with `pub use`

- 기본적으로 `use` 키워드로 가져온 아이템은 private이다.

- 만약 가져온 아이템을 public으로 만들고 싶다면, `pub use` 키워드를 사용하면 된다.

```rust
mod front_of_house {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
    hosting::add_to_waitlist();
}

```

- 이렇게 하면 `hosting`모듈은 public이 되고, `add_to_waitlist`함수도 public이 된다.

- `restaurant::front_of_house::hosting::add_to_waitlist`와 같이 사용해야 하는 것을.

- `restaurant::hosting::add_to_waitlist`와 같이 사용할 수 있다.

- 이러한 기능은, 코드의 내부 구조가 이 코드를 사용하려는 프로그래머에게 노출되지 않도록 할 수 있다. (노출되지 않으므로 변경되어도 영향을 받지 않고, 도메인에 대한 생각을 하지 않을 수 있다.)

### 7.4.4 Using External Packages

- 외부 패키지를 사용할 때는, `Cargo.toml`에 의존성을 추가하고, `use` 키워드를 사용해 가져올 수 있다.

- `use` 키워드를 사용해 가져올 때는, 패키지의 이름을 사용해야 한다.

```toml
[dependencies]
rand = "0.8.3"
```

```rust
use rand::Rng;

fn main() {
    let secret_number = rand::thread_rng().gen_range(1..101);
    println!("The secret number is: {}", secret_number);
}
```

- 이렇게 하면 `rand`패키지의 `Rng` trait을 가져올 수 있다.

- `Rng` trait의 스코프에 있는 `thread_rng`함수를 호출하고, `gen_range`함수를 호출 할 수 있다.


## 7.5 Separating Modules into Different Files

- 파일시스템과 이름을 조금 생각해두면 딱히 어려운건 없기에 생략~

