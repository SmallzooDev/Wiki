---
title: Package, Crates, Modules
summary: 
date: 2024-04-13 23:04:16 +0900
lastmod: 2024-04-13 23:04:16 +0900
tags: 
categories: 
description: 
showToc: true
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
