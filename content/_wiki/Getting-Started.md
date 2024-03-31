---
title: 러스트 공식 가이드1장 정리
summary: 
date: 2024-03-31 16:59:07 +0900
lastmod: 2024-03-31 16:59:07 +0900
tags: ["Rust"]
categories: 
public: true
parent: 
description: 
showToc: true
---

#### 1.1. Installation
> 러스트 설치에 대한 아주 간단한 가이드.

- 간단한 내용이라 딱히 정리할 내용은 없다.

#### 1.2. Hello, World!
> 러스트로 Hello, World! 출력하기.

**특징적인 내용은 아래와 같다.**
1. 공식 가이드의 Helloworld 섹션 첫줄에 다른 언어에 대한 이해도를 전제하고 있다.
2. 실제로 공식 가이드 문서 내내 러스트의 특징을 다른 언어의 특징과 거울처럼 대비하며 설명한다.
3. 파일명 컨벤션은 스네이크 케이스를 사용한다. (그리고 그걸 첫장에 설명한다.)
4. rustc와 같은 컴파일 커맨드도 첫장에 알려준다.


```rust
fn main() {
    println!("Hello, World!");
}
```

- 다양한 언어를 배워오면서 느끼는건, Hello, World!를 출력하려고 할 때 언어의 특징을 알 수 있다는 것이다. ~~Public static void main(String[] args) ....~~
- 러스트는 `println!` 매크로를 사용한다. (매크로는 러스트의 특징 중 하나이다, 나중에 자세히 정리가 나온지만 간단하게 설명하면 러스트의 매크로는 러스트의 문법을 확장할 수 있는 기능이다.)

##### Hello World Anatomy
- `fn` : 함수를 선언할 때 사용하는 키워드.
- 러스트의에서 `main`함수의 의미 : 프로그램의 시작점을 나타낸다.(The main function is special: it is always the first code that runs in every executable Rust program.)
- `{}` : 블록을 나타낸다. 블록은 코드의 범위를 나타낸다. (블록은 러스트의 다른 부분과 마찬가지로 중괄호로 둘러싸여 있다.)
- `println!` : 매크로를 호출하는 방법. (매크로는 러스트의 문법을 확장할 수 있는 기능이다.)
- `;` : 문장의 끝을 나타낸다. (러스트는 문장의 끝에 세미콜론을 붙여야 한다, 식의 끝에 세미콜론을 붙이는 것은 문장의 끝을 나타낸다. 이 가이드에서도 문과 식을 구분하는 것이 중요하다.)
- 러스트의 들여쓰기는 4칸을 권장한다. (공식 가이드에서는 4칸을 권장하는데.. 왜..?)

그 외에는 간단한 컴파일 관련 설명이다.


#### 1.3. Hello, Cargo!
> MZ한 언어답게 트랜디한 공식 빌드 시스템이자 패키지 매니저인 Cargo에 대한 간단한 가이드.

- Cargo는 러스트의 빌드 시스템이자 패키지 매니저이다.

```toml
[package]
name = "hello_cargo"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]

```

- 보통은 이렇게 생겼다. (Cargo.toml 파일)
- `cargo new hello_cargo` : 새로운 프로젝트를 생성한다.
- `cargo build` : 프로젝트를 빌드한다.
    - 기본적으로 러스트는 디버그 모드로 빌드한다.
    - 그래서 빌드된 실행 파일(바이너리)은 `target/debug/${my_project_name}`에 위치한다.
- `cargo run` : 프로젝트를 실행한다.
- `cargo check` : 프로젝트를 빌드하지 않고 컴파일을 실행한다.
- `cargo build --release` : 프로젝트를 릴리즈 모드로 빌드한다.
- `cargo update` : 프로젝트의 의존성을 업데이트한다.
- 의존성을 체크하는 lock 파일이 있다. (Cargo.lock)
- 빌드할 때 알아서 변경을 감지하고 빌드한다. (즉, 변경사항이 없으면 빌드하지 않는다.)
- `cargo check`으로 컴파일만 하는 이휴는 빠르기 때문이다, 프로젝트 중간중간 컴파일체크만 하고 싶을 때 사용한다고 한다.
- `--release` 플래그로 릴리즈 모드로 빌드할 수 있다. (릴리즈 모드는 최적화가 적용된다.)

컨벤션은 아래와 같다.

```shell
$ git clone example.org/someproject
$ cd someproject
$ cargo build

```

#### Conculusion & Impression
- 패키지매니저를 공식적으로 가지고 있고, 빌드 시스템이 강력하다.
- 기본적으로 간단한 문법의 언어이다.
- 매크로가 있다.
