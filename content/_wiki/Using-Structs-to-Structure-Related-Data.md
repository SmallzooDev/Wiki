---
title: Using Structs to Structure Related Data
summary: 
date: 2024-04-09 00:11:26 +0900
lastmod: 2024-04-09 00:11:26 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---


## 5.0 Defining and Instantiating Structs

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```

- 기본적으로 튜플과 비슷하게 데이터를 묶어주는 역할을 한다.
- 튜플보다 더 많은 유연성을 제공한다.
- 객체지향 프로그래밍의 클래스의 데이터 부분과 비슷하다.(메서드가 없다는 점에서 객체라고 절대 부를 수 없다.)
- cpp의 구조체와 거의 동일하다.
- ts의 인터페이스와 유사하다.
- `struct` 키워드를 사용하여 정의한다.

```rust
fn main() {
  let user1 = User {
    email: String::from("some@example.com"),
    username: String::from("someusername"),
    active: true,
    sign_in_count: 1,
}
```
- `.`을 사용하여 필드에 접근할 수 있다.
- 만약 instance가 mutable하다면 필드의 값을 변경할 수 있다.
- 필드의 일부는 mutable이고 일부는 immutable일 수 없다.

```rust
fn build_user(email: String, username: String) -> User {
    User {
        email: email,
        username: username,
        active: true,
        sign_in_count: 1,
    }
}

fn build_user2(email: String, username: String) -> User {
    User {
        email,
        username,
        active: true,
        sign_in_count: 1,
    }
}
```
- 표현식 형태로 함수의 반환값으로 사용할 수 있다.
- 필드의 이름과 변수의 이름이 같다면 `email: email`을 `email`로 축약할 수 있다.

### 5.1.1 Creating Instances From Other Instances With Struct Update Syntax

```rust
fn main() {
    // --snip--
    let user2 = User {
        email: String::from("another@example.com"),
        active: user1.active,
        sign_in_count: user1.sign_in_count,
        username: user1.username,
    };
    
    let user3 = User {
        email: String::from("another@example.com"),
        ..user1
    };
}
```
- `..`을 사용하여 다른 인스턴스를 복사할 수 있다.
- 디스럭쳐링과 비슷한 문법이지만, 구조체가 기본적으로 iterable trait를 구현하고 있지는 않는다고 한다. 어떻게 구현되어있는지 궁금하다. (알아보기)
- 소유권 이전은 동일한 논리로 일어나기 때문에, 만약 stack only data가 아닌 필드를 가지고 있다면, 업데이트 이후 기존 인스턴스를 사용할 수 없게 된다.

### 5.1.2 Using Tuple Structs without Named Fields to Create Different Types

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

fn main() {
    let black = Color(0, 0, 0);
    let origin = Point(0, 0, 0);
}
```
- 필드의 이름이 없는 튜플 구조체를 사용할 수 있다.
- 필드의 이름을 붙이지 않는 구조체라고 생각하면 된다.

- 한번 타입을 정의하면, 그 필드들이 같아도 다른 타입으로 인식한다.
- `black`과 `origin`은 서로 다른 타입이기에, 함수 파라미터등으로 반대를 넣어주면 컴파일 에러가 발생한다.



### 5.1.3 Unit-Like Structs Without Any Fields

```rust
struct UnitLikeStruct;

fn main() {
    let unit_like_struct = UnitLikeStruct;
}
```

- 필드가 없는 구조체를 사용할 수 있다.
- 이런 구조체는 유닛 타입과 비슷하다.
- 데이터필드가 없는 trait를 구현할 때 유용하게 사용할 수 있다.
- 타입 파라미터나 테스트용 mock 객체를 만들 때 유용하게 사용할 수 있다.

