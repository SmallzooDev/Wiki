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

## 5.2 An Example Program Using Structs

구조체를 사용하지 않고 작성한 코드를 구조체를 사용하여 리팩토링하는 간단한 예제.

```rust
fn main() {
    let width1 = 30;
    let height1 = 50;

    println!(
        "The area of the rectangle is {} square pixels.",
        area(width1, height1)
    );
}
```
- 파라미터가 두개이며, 해당 값들이 어떤 값인지에 대한 인지가 필요해서 별로라고 한다.

### 5.2.1 Refactoring with Tuples

```rust
fn main() {
    let rect1 = (30, 50);

    println!(
        "The area of the rectangle is {} square pixels.",
        area(rect1)
    );
}

fn area(dimensions: (u32, u32)) -> u32 {
    dimensions.0 * dimensions.1
}
```

- 조금 더 낫긴 하지만, 의미적으로 `dimensions.0`과 `dimensions.1`이 `width`와 `height`라는 것을 알 수 없다.

### 5.2.2 Refactoring with Structs: Adding More Meaning

```rust
fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!(
        "The area of the rectangle is {} square pixels.",
        area(&rect1)
    );
}

fn area(rectangle: &Rectangle) -> u32 {
    rectangle.width * rectangle.height
}
```

- 구조체를 사용하여 가독성을 높일 수 있다.
- ownership을 넘기지 않고 참조를 넘기는 것이 좋다.

### 5.2.3 Adding Useful Functionality with Derived Traits

```rust
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!("rect1 is {}", rect1);
}
```

- `println!` 매크로는 `Display` trait를 구현한 타입만 사용할 수 있다, 관련된 컴파일 에러를 확인 할 수 있다.
```
   = help: the trait `std::fmt::Display` is not implemented for `Rectangle`
   = note: in format strings you may be able to use `{:?}` (or {:#?} for pretty-print) instead
```
- 친절한 컴파일러의 조언을 따라 `{:?}`를 사용해서 출력하는 예제.

```rust
fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!("rect1 is {:?}", rect1);
}
```

- 또 다른 에러가 발생한다.

```
   = note: `Rectangle` cannot be formatted using `{:?}` because it doesn't implement `std::fmt::Debug`
```

- `Debug` trait를 구현해야 한다는 에러이다.
- `#[derive(Debug)]`를 사용하여 `Debug` trait를 구현할 수 있다.
- 이는 `#[derive(Debug)]`를 사용하여 컴파일러가 자동으로 구현하도록 할 수 있다.


```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}
```

- 이제 `{:?}`를 사용하여 출력할 수 있다.
- `{:?}`는 `Debug` trait를 구현한 타입을 출력할 수 있다.

```rust
fn main() {
    let rect1 = Rectangle { width: 30, height: 50 };

    println!("rect1 is {:?}", rect1);
}
```

- `Debug` format을 사용해서 출력하는 다른 방법은 `dbg!` 매크로를 사용하는 것이다.
- `dbg!` 매크로는 `println!` 매크로와 비슷하지만, `dbg!` 매크로는 값을 반환하고, ownership을 가져갔다 반환해준다 (println!은 참조만 가져간다.)

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

fn main() {
    let scale = 2;
    let rect1 = Rectangle {
        width: dbg!(30 * scale),
        height: 50,
    };

    dbg!(&rect1);
}
```

```bash
$ cargo run
   Compiling rectangles v0.1.0 (file:///projects/rectangles)
    Finished dev [unoptimized + debuginfo] target(s) in 0.61s
     Running `target/debug/rectangles`
[src/main.rs:10] 30 * scale = 60
[src/main.rs:14] &rect1 = Rectangle {
    width: 60,
    height: 50,
}
```


## 5.3 Method Syntax

- 구조체에 메서드를 추가할 수 있다.
- 메서드는 함수와 비슷하지만, 구조체의 인스턴스에 대해 호출된다는 점이 다르다.
- 메서드는 `self` 파라미터를 가지고 있어야 한다.
- `self` 파라미터는 메서드를 호출한 인스턴스를 가리킨다.

### 5.3.1 Defining Methods

```rust
#[derive(Debug)]
struct Rectangle {
    width: u32,
    height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };

    println!(
        "The area of the rectangle is {} square pixels.",
        rect1.area()
    );
}
```

- `impl` 블록을 사용하여 메서드를 정의할 수 있다.

- `impl` 블록은 구조체의 이름과 메서드를 구현할 구조체의 이름을 가지고 있다.

- `self` 파라미터를 사용하여 메서드를 호출한 인스턴스를 가리킬 수 있다.

- `self` 파라미터는 `self: &self`의 약어이다.

-  Self 타입은 impl 블록이 적용되는 타입의 별칭이다. (`alias`)

- `rectangle: &Rectangle` 에서처럼, 이 메소드가 Self 인스턴스를 빌린다는 것을 나타내기 위해 self 약어 앞에 &를 사용해야 한다. 

- 메소드는 다른 매개변수처럼 self의 소유권을 가질 수도 있고, 여기처럼 self를 불변으로 빌릴 수도 있으며, 혹은 self를 가변으로 빌릴 수도 있다.

- 반대로 `&mut self`로 선언하면, 해당 인스턴스를 가변으로 빌릴 수 있다.

- 특정한 인스턴스를 변화시키고, 기존의 인스턴스를 사용할 수 없게 하고 싶다면, `&mut self`를 사용하면 된다.

```rust
struct Circle {
    radius: f64,
}

impl Circle {
    // Circle의 면적을 계산하는 메서드
    fn area(&self) -> f64 {
        3.14159 * self.radius * self.radius
    }

    // Circle의 반지름을 주어진 배율로 조정하는 메서드
    fn scale(&mut self, factor: f64) {
        self.radius *= factor;
    }
}

fn main() {
    let mut circle = Circle { radius: 5.0 };

    println!("원래 면적: {}", circle.area());

    // circle의 반지름을 2배로 조정
    circle.scale(2.0);

    println!("조정된 면적: {}", circle.area());
}
```

```rust
impl Circle {
    // Circle을 Square로 변환하는 메서드
    fn into_square(self) -> Square {
        Square { side: self.radius * 2.0 }
    }
}

struct Square {
    side: f64,
}

fn main() {
    let circle = Circle { radius: 5.0 };
    let square = circle.into_square(); // 여기서 circle의 소유권이 이동됨

    // println!("원의 반지름: {}", circle.radius); // 오류: `circle`은 더 이상 유효하지 않음
    println!("정사각형의 변 길이: {}", square.side);
}
```

```rust
fn main() {
    let circle = Circle { radius: 5.0 };

    // circle.scale(2.0); // 오류: `circle`은 불변 참조이며, `scale`은 가변 참조를 요구함
}
```

- 함수 대신 메서드를 사용하는 이유는 단지 구조체에서 타입을 매번 쓰지 않기 위해서가 아니라, 해당 타입에 대한 method를 조직화 하기 때문이다. (organization)

- 메서드를 사용하면, 해당 타입에 대한 모든 기능을 한 곳에 모아둘 수 있다.

- 필드의 이름과 메서드의 이름이 같게 할 수 있다.

- getter와 같은것들도 구현하는데, 이건 나중에..

### 5.3.2 Where's the -> Operator?

- (c/cpp 에서) `->` 연산자는 포인터의 메서드를 호출할 때 사용한다. 객체에서 직접 호출하는 경우는 `.`
- 역참조를 해서 호출할 필요가 있기 때문인데, `object` 가 포인터라면, `object->method()`는 `(*object).method()`와 비슷하다.
- 러스트에서는 이러한 과정이 자동화 되어있다 (`automatic referencing and dereferencing`).
- `object.method()` 와 같이 메서드를 호출하면, 러스트는 자동으로 `&`, `&mut`, *를 추가하여 호출한다.

```rust
// same
p1.distance(&p2);
(&p1).distance(&p2);
```

- 짐작할수 있듯이 self라는 명확한 수신자를 사용하기 때문에 가능하다
- 리시버가 `&self`, `&mut self`, `self`로 정의되어 있기 때문에, 읽기 수정 소비에 대한 부분을 명확하게 파악 할 수 있다.

- 예를 들어, 어떤 객체 obj가 있고 이 객체에 대한 메서드 method()가 정의되어 있을 때, 
 
- Rust는 obj.method() 호출을 적절하게 처리한다. 
 
- 이 메서드가 &self를 요구한다면, Rust는 자동으로 &obj.method()를 호출한다. 
 
- 만약 메서드가 &mut self를 요구한다면, Rust는 &mut obj.method()로 처리한다. 
 
- 객체가 값으로 메서드를 호출해야 한다면, Rust는 필요에 따라 (*obj).method()처럼 역참조를 자동으로 처리한다.

### 5.3.3 Methods with More Parameters

- 메서드는 추가적인 파라미터를 가질 수 있다.

```rust
fn main() {
    let rect1 = Rectangle {
        width: 30,
        height: 50,
    };
    let rect2 = Rectangle {
        width: 10,
        height: 40,
    };
    let rect3 = Rectangle {
        width: 60,
        height: 45,
    };

    println!("Can rect1 hold rect2? {}", rect1.can_hold(&rect2));
    println!("Can rect1 hold rect3? {}", rect1.can_hold(&rect3));
}
```

```rust
impl Rectangle {
    fn can_hold(&self, other: &Rectangle) -> bool {
        self.width > other.width && self.height > other.height
    }
}
```

- self reciever 이후는 그냥 일반적인 함수와 동일하다.

### 5.3.4 Associated Functions

- self 파라미터를 가지지 않는 함수를 `impl` 블록 내에 정의할 수 있다.

- self 파라미터가 없기 때문에, 메서드는 아니고 `associated function`이라고 한다.

- associated function은 주로 구조체의 인스턴스를 생성하는데 사용된다.

```rust
impl Rectangle {
    fn square(size: u32) -> Self {
        Self {
            width: size,
            height: size,
        }
    }
}
```

- 마지막으로 impl블록을 여러개 둘 수 있는데, 큰 의미는 없는 것 같다
