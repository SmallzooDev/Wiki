---
title: 러스트 공식 가이드 3장 정리
summary: 
date: 2024-04-01 21:00:33 +0900
lastmod: 2024-04-01 21:00:33 +0900
tags: 
categories: 
public: true
parent: 
description: 
showToc: true
---

## 3 Common Programming Concepts

> 이번 장에서는 러스트의 기본적인 프로그래밍 개념들을 다룬다, 가장 특징적인 부분이라면 다른 언어를 대비해서 러스트가 어떤 부분이 다른지 위주로 설명하는 가장 크게 두드러진다는 것이다.

> mz한 언어답게 예약어가 예약되어 있다고 한다 ㅋㅋ(아직 예약어로써 기능하지는 않지만, 미래의 예약어가 될 수 있어 예약해둔 keword)



### 3.1 Variables and Mutability

- 변수는 기본적으로 불변이며, 이렇게 된게 러스트의 nudge라고 한다.

`src/main.rs`

```rust
fn main() {
    let x = 5;
    println!("The value of x is: {}", x);
    x = 6;
    println!("The value of x is: {}", x);
}
```

```bash
$ cargo run
   Compiling variables v0.1.0 (file:///projects/variables)
error[E0384]: cannot assign twice to immutable variable `x`
 --> src/main.rs:4:5
  |
2 |     let x = 5;
  |         -
  |         |
  |         first assignment to `x`
  |         help: consider making this binding mutable: `mut x`
3 |     println!("The value of x is: {x}");
4 |     x = 6;
  |     ^^^^^ cannot assign twice to immutable variable

For more information about this error, try `rustc --explain E0384`.
error: could not compile `variables` due to previous error
```

- 친절한 컴파일에러..

무튼 변수를 변경하려면 `mut` 키워드를 사용해야 한다, 이렇게 하면 일단 변수를 선언하고, 고심한 이후에 mut 키워드를 붙이는 습관이 들 수 있다.


#### Constants

- 상수는 `const` 키워드를 사용하며, 타입을 명시해야 한다.

- 전역을 포함한 어느 스코프에서도 선언이 가능하다.

- 런타임에 계산되는 값은 상수로 선언할 수 없고, 오직 상수 표현식(컴파일 타임에 계산되는 값)만 가능하다.

```rust
const THREE_HOURS_IN_SECONDS: u32 = 60 * 60 * 3;
```


#### Shadowing

- 변수를 재선언하는 것을 shadowing이라고 한다.
```rust
fn main() {
    let x = 5;

    let x = x + 1;

    {
        let x = x * 2;
        println!("The value of x in the inner scope is: {x}");
    }

    println!("The value of x is: {x}");
}
```

결과는
```bash
The value of x in the inner scope is: 12
The value of x is: 6
```

- 변수 재 선언과는 다르고, 특히 스코프를 벗어나면 이전 변수가 다시 보이게 된다는게 특징이다.

- 그리고 타입을 변경하여도 shadowing이 가능하다.

```rust
let spaces = "   ";
let spaces = spaces.len();
```

- 이렇게 하면 spaces는 문자열이었다가 숫자로 바뀌게 된다, space_len 같은 변수를 만들 필요가 없다.

- 실제로 저장하고 싶은 데이터는 공백의 갯수이기 때문에 특정한 상황에서 효율적일 수 있다.

- 뭔가 스코프에 따라 Shadowing이 영향을 받기도 해서 위험해 보이고, 처음에는 표현식.타입의메셔드() 이런 방법보다 더 나은가 싶긴 했는데, 러스트의 문법적 특징과 잘 어울리게 쓰면 멋진 코드가 나오는 것 같다.


### 3.2 Data Types

-  러스트는 정적 타입 언어이다.

- `컴파일 타임에` 모든 타입이 알려져야 한다.

```rust
let guess: u32 = "42".parse().expect("Not a number!");
```

- 컴파일 시점에 다양한 가능성이 있는 경우라면 타입을 명시해야 컴파일 에러가 나지 않는다.

- 그리고 러스트에는 스칼라 타입과 컴파운드 타입이 있다.

#### Scalar Types

- 기본적으로 하나로 표현되는 값이다. (다른 언어의원시 타입)

- 러스트의 스칼라 타입은 정수형, 부동소수점, 불리언, 문자로 구성된다.


##### Integer Types
- 정수형은 unsigned인지만 구분하고, 크기에 따라 8, 16, 32, 64, 128비트로 나뉜다.

- i8 -> 8비트 signed integer

- u64 -> 64비트 unsigned integer

- isize, usize는 운영체제에 따라 32, 64비트로 결정된다. (64비트 운영체제에서는 64비트) (포인터 사이즈)

- 디폴트값은 i32이다.

- 추가적으로 정수 오버플로우는 검사하지 않고, 2의 보수 래핑을 한다. 11111 -> 00000

- 이를 방지하기 위해서 보통은 충분히 큰 타입을 사용하라고,,,,할수는 없으니 (~~BigDecimal.java~~) 
  
- std의 `Wrapping`을 사용하면 된다.

```rust
use std::num::Wrapping;

fn main() {
    let x = Wrapping(0u8);
    let y = Wrapping(1u8);
    let z = x - y;
    println!("{:?}", z);
}
```

##### Floating-Point Types
- 부동소수점은 f32, f64로 나뉜다.

- f64가 디폴트이다.

- IEEE-754 표준을 따른다고 한다


##### Numeric Operations

산술연산자는 간단하게..
```rust
fn main() {
    let sum = 5 + 10;
    let difference = 95.5 - 4.3;
    let product = 4 * 30;
    let quotient = 56.7 / 32.2;
    let remainder = 43 % 5;
}
```


##### The Boolean Type
- 생략


##### The Character Type

- 러스트의 char는 유니코드 스칼라 값이다.
- 크기는 4바이트이다.
- 유니코드 스칼라 값은 0x0000과 0xD7FF, 0xE000과 0x10FFFF 사이의 값을 가진다.
- 0부터 55295까지의 범위는 기본 다국어 평면,
- 57344부터 1114111까지의 범위는 보조 다국어 평면이다.

```rust
fn main() {
    let heart_eyed_cat = '😻'; // 가능!
}
```

#### Compound Types

- 여러 값을 하나로 묶어서 저장하는 타입이다.
- 튜플과 배열이 있다.
- 튜플은 고정된 길이를 가지고 각 요소의 타입은 달라도 된다.
- 러스트는 배열의 길이를 컴파일 시점에 알아야 한다.

```rust
fn main() {
    let tup: (i32, f64, u8) = (500, 6.4, 1);
}
```

```rust
fn main() {
    let tup = (500, 6.4, 1);

    let (x, y, z) = tup; // 디스트럭처링 가능

    println!("The value of y is: {y}");
}
```


```rust
fn main() {
    let x: (i32, f64, u8) = (500, 6.4, 1);

    let five_hundred = x.0; // 인덱스로 접근가능

    let six_point_four = x.1;

    let one = x.2;
}
```

Array

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];
}
```

- 배열은 고정된 길이를 가지고, 모든 요소의 타입은 같아야 한다.
- 배열의 길이는 타입의 일부이다.
- 배열의 요소에 접근할 때는 인덱스를 사용한다.

> 배열은 데이터를 힙(heap) 대신 스택(stack)에 할당하려는 경우에 유용하다. 스택에 할당하면 데이터를 빠르게 할당하고 접근할 수 있지만, 데이터가 컴파일 시점에 정해진 크기만큼만 스택에 할당될 수 있기 때문에 유연하지 않다. 힙에 할당하면 컴파일 시점에 크기가 정해지지 않아서 런타임에 크기를 늘릴 수 있지만, 느리다.

> 보통 공식 가이드에서는 명확한 이유가 없다면 벡터를 사용하라고 권한다.  벡터는 힙에 할당되고, 컴파일 시점에 크기가 정해지지 않아서 런타임에 크기를 늘릴 수 있다.

- 나중에 훨씬 더 자세하게 거론된다

```rust
fn main() {
    let a = [1, 2, 3, 4, 5];
    let a = [3; 5]; // [3, 3, 3, 3, 3]

    let first = a[0];
    let second = a[1];
}
```

- 저수준의 언어임에도 OOI 에러를 패닉으로 잡아내준다.


### 3.3 Functions

```rust
fn main() {
    println!("Hello, world!");

    another_function();
}

fn another_function() {
    println!("Another function.");
}



```rust
fn main() {
    another_function(5, 6);
}

fn another_function(x: i32, y: i32) {
    println!("The value of x is: {x}");
    println!("The value of y is: {y}");
}
```
- 함수 선언의 위치는 중요하지 않다.
- 파라미터는 타입을 명시해야 한다.

#### Statements and Expressions

> Function bodies are made up of a series of statements optionally ending in an expression. 
> So far, the functions we’ve covered haven’t included an ending expression, 
> but you have seen an expression as part of a statement. 
> Because Rust is an expression-based language, this is an important distinction to understand. 
> Other languages don’t have the same distinctions, 
> so let’s look at what statements and expressions are and how their differences affect the bodies of functions

- 이 장에서 가장 중요한 부분이라고 생각한다.
- 먼저 함수를 일련의 '문(statement)'로 구성되어 있고, 이 문들은 선택적으로 '표현식(expression)'으로 끝난다 고 정의하고있다.
- 또한 러스트는 표현식 기반 언어라고 정의한다.

- `문(statement)`는 어떤 작업을 수행하고 값을 반환하지 않는다.
- `표현식(expression)`은 값을 반환한다.
- 예를 들어, let x = 5; 는 문이고, 5 + 6;은 표현식이다.
- let x = 5; 는 변수에 값을 할당하고, 그 자체로 평가될 값이 없다.
- 반면 5 + 6;은 두 값을 더한 결과를 반환하고, 반환한 값으로 평가된다.
- 참고로 `{}` 블록은 표현식이며, 블록 내부의 마지막 표현식이 블록 전체의 값이 된다.
- 함수를 호출하는 것, 매크로를 호출하는것 것은 표현식이다.
- 표현식의 끝에는 세미콜론을 붙이지 않는다.

결론적으로 return 키워드는 함수를 일찍 종료시킬 때 사용되며, 일반적으로는 문들의 나열 이후에 마지막 표현식으로 값을 반환한다!



### 3.4 Comments
생략..?

### 3.5 Control Flow

- 러스트의 if문은 특징적인 내용은 별로 없다.

- 조건식은 반드시 bool 타입이어야 한다. (거의 대부분의 강타입 언어가 그렇듯이)
 
- 분기가 많은 경우 match 키워드를 사용하는 것이 좋다.
 
- 러스트의 if는 표현식이기 때문에 다음과 같이 3항 연산자를 대체할 수 있다.

```rust
fn main() {
    let number = 3;

    if number < 5 {
        println!("condition was true");
    } else {
        println!("condition was false");
    }

    let condition = true;
    let number = if condition { 5 } else { 6 };

    println!("The value of number is: {number}");
}
```
- 반복문은 loop, while, for가 있다.

- loop는 조건 검사를 전적으로 프로그래머에게 맡기는 반복문이다.

- 내가 배운 언어에서는 없었던 것 같다.

- 종료 조건을 잘 생각하고 코드를 작성해야 한다.

- 종료 keyword인 break 뒤에 값을 반환할 수 있다 (표현식으로 사용 가능)

```rust

fn main() {
    let mut counter = 0;

    let result = loop {
        counter += 1;

        if counter == 10 {
            break counter * 2;
        }
    };

    println!("The result is {result}");
}
```
- 루프에 레이블을 붙일 수 있다.

```rust
'outer: loop {
    println!("Entered the outer loop");

    'inner: loop {
        println!("Entered the inner loop");

        break 'outer;
    }

    println!("This point will never be reached");
}
```
- 독특한 기능인 것 같다. 당연히 레이블을 붙이지 않아도 되고, 그런 경우 loop 제어 키워드들은 가장 가까운 루프를 기준으로 동작한다.

- 루프 레이블과 루프의 값 반환을 함께 사용하는 예제

```rust
fn main() {
    let mut counter = 0;

    let result = 'outer: loop {
        println!("Entered the outer loop");

        'inner: loop {
            println!("Entered the inner loop");

            counter += 1;

            if counter == 10 {
                break 'outer counter * 2;
            }
        }
    };

    println!("The result is {result}");
}
```

- while은 조건이 참인 동안 반복한다 (특징적이지 않다)

```rust
fn main() {
    let mut number = 3;

    while number != 0 {
        println!("{number}");

        number -= 1;
    }

    println!("LIFTOFF!!!");
}
```

- for는 컬렉션을 순회한다.

- 먼저 while 기반의 인덱스 순회 방법을 소개한다.

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];
    let mut index = 0;

    while index < 5 {
        println!("{a[index]}");

        index += 1;
    }
}
```

- 이런 방법은 러스트의 인덱스 오버플로우를 방지하기 위해 좋지 않으며, 느리다고 언급한다.

- 느린 이유는 루프의 매 반복마다 OOI를 체크하기위한 런타임 코드를 추가하기 때문이라고 한다.

- 일단 for문은 이렇게 생겼다.

```rust
fn main() {
    let a = [10, 20, 30, 40, 50];

    for element in a.iter() {
        println!("{element}");
    }
}
```

- 지정한 횟수만큼의 반복을 원한다면, `range()`를 사용하면 된다.

```rust
fn main() {
    for number in (1..4).rev() { // .rev()는 역순으로 순회한다.
       println!("{number}");
    }
    println!("LIFTOFF!!!");
}
```

### 러스트의 순회는 어떻게 구현되어있을까?

- 먼저Java와 같은 언어에서는 Iterable 인터페이스를 구현하고, Iterator를 반환하는 메서드를 구현한다.

- 그리고 Iterator는 대충 아래와 같이 생겼다.

```java
public interface Iterator<T> {
    boolean hasNext();
    T next();
}
```

- 그래서 Iterator를 구현한 클래스는 hasNext()와 next()를 구현해야 한다.

- 이러한 경우 인덱스를 카운트 하지 않고 Iterator의 구현체를 순회 할 수 있다.

- Iterator의 구현체와 사용 예시 (for 문)

```java
public class MyIterator<T> implements Iterator<T>, Iterable<T> {
    private T[] elements;
    private int index = 0;

    public MyIterator(T[] elements) {
        this.elements = elements;
    }

    @Override
    public boolean hasNext() {
        return index < elements.length;
    }

    @Override
    public T next() {
        return elements[index++];
    }

    @Override
    public Iterator<T> iterator() {
        return this;
    }
}
```

```java
public class Main {
    public static void main(String[] args) {
        Integer[] elements = {1, 2, 3, 4, 5};
        MyIterator<Integer> iterator = new MyIterator<>(elements);

        for (Integer element : iterator) {
            System.out.println(element);
        }
    }
}
```

- 이런경우 축약된 for문은 Iterator를 구현한 클래스에 대해서만 사용할 수 있다.

- 축약된 for문에서는 Iterator의 hasNext()와 next()를 호출하며, hasNext()가 false를 반환할 때까지 next()를 호출한다.

- 즉 길이와 인덱스를 몰라도 순회가 가능하다.


- Javascript에서는 이터러블과 이터레이터를 사용한다. (이터러블 프로토콜과 이터레이터 프로토콜)

- 이터러블 프로토콜은 Symbol.iterator 메서드를 구현하고, 이터레이터를 반환하는 것이다.

- 이터레이터 프로토콜은 next() 메서드를 구현하고, value와 done을 반환하는 것이다.

- 마찬가지로 예시는 아래와 같다

- 생긴건 자바와 조금 다르지만 원리는 같다 (다음원소가 있는지 확인하고, 다음 원소를 반환한다)

```javascript
function MyIterator(elements) {
    this.elements = elements;
    this.index = 0;
}


MyIterator.prototype.next = function() {
    return this.elements[this.index++];
}

MyIterator.prototype.hasNext = function() {
    return this.index < this.elements.length;
}

MyIterator.prototype[Symbol.iterator] = function() {
    return this;
}

const elements = [1, 2, 3, 4, 5];

const iterator = new MyIterator(elements);

for (const element of iterator) {
    console.log(element);
}
```

- 프로토타입 기반 언어라서 그렇다고 한다. 이 객체가 특정한 추상화의 구현체인지를 따지는것 (자바, c++)과, 이 객체와 다른 언어의 유사점(프로토콜 구현 등)을 기반으로 따지는것 (자바스크립트)의 차이라고 한다.

- 무튼 마지막으로 러스트는 트레이트를 사용한다.

- 트레이트를 배우고 Iterator를 다뤄야지!


### Summary & Impression

- 러스트는 표현식 기반 언어이다.
