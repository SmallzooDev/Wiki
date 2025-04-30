---
title: 러스트의 컬렉션 모아보기
summary: 
date: 2024-04-14 13:53:34 +0900
lastmod: 2025-04-30 15:50:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 8.0.0 Common Collections 

- 러스트의 `std::collections` 모듈은 여러 유용한 자료구조인 컬렉션을 제공한다.

- `heap`에 저장되는 컬렉션들은 컴파일 시점에 크기를 알 수 없고 늘어나거나 줄어들거나 한다.

- 이번 장에서는 `Vec<T>`, `String`, `HashMap<K, V>`에 대해 알아본다.


## 8.1.0 Storing Lists of Values with Vectors

- `Vec<T>`는 가변 길이의 리스트를 저장할 수 있는 컬렉션이다.

- `Vec<T>`는 동일한 타입의 여러 값을 저장할 수 있고, 다음 자료를 메모리 옆칸에 연속적으로 저장하는 선형 자료구조이다. (배열)


### 8.1.1 Creating a New Vector

- `Vec<T>`를 생성하는 방법은 두 가지가 있다.

    - `Vec::new()`: 빈 벡터를 생성한다. `let v: Vec<i32> = Vec::new();` 와 같이 타입을 명시해야 한다.
    
    - `vec!`: 매크로를 사용하여 초기값을 가진 벡터를 생성한다. `let v = vec![1, 2, 3];` 이처럼 초기화까지 한번에 하면 타입을 명시하지 않아도 된다.

### 8.1.2 Updating a Vector

- `Vec<T>`에 값을 추가하는 방법은 두 가지가 있다.

    - `push`: `push` 메서드를 사용하여 값을 추가한다. `let mut v = Vec::new(); v.push(5);` 이처럼 사용한다.
    
    - `append`: `append` 메서드를 사용하여 다른 벡터를 추가한다. `let mut v = vec![1, 2, 3]; v.append(&mut vec![4, 5, 6]);` 이처럼 사용한다.

### 8.1.3 Reading Elements of Vectors

- `Vec<T>`의 요소에 접근하는 방법은 두 가지가 있다.

    - `&v[i]`: 인덱스를 사용하여 값을 참조한다. `let v = vec![1, 2, 3]; let third: &i32 = &v[2];` 이처럼 사용한다.
    
    - `get`: `get` 메서드를 사용하여 값을 참조한다. `let v = vec![1, 2, 3]; let third: Option<&i32> = v.get(2);` 이처럼 사용한다.

```rust
    let v = vec![1, 2, 3, 4, 5];

    let third: &i32 = &v[2];
    println!("The third element is {third}");

    let third: Option<&i32> = v.get(2);
    match third {
        Some(third) => println!("The third element is {third}"),
        None => println!("There is no third element."),
    }

```
- 당연하지만 포인트는 `get` 메서드는 `Option<T>`를 반환한다는 것이다. 인덱스가 범위를 벗어나면 `None`을 반환한다.

- `&v[i]`는 인덱스가 범위를 벗어나면 패닉을 일으킨다.

- 두 가지 방법 중 어떤 것을 사용할지는 상황에 따라 다르다. 인덱스가 범위를 벗어나는 경우가 없다면 `&v[i]`를 사용해서 수상한 시도를 painc으로 몰아 낼 수 있다.

- 반대로 인덱스가 범위를 벗어나는 경우가 있을 수 있다면 `get` 메서드를 사용하여 `Option<T>`를 반환하게 해서 일어날 법 한 상황에 유연하게 대처하면 된다.

- 일단 올바른 인덱스를 건낸다면, borrow checker는 소유권과 borrow 규칙을 따르게 해서 이 참조와 벡터 내용에 대한 다른 참조가 유효하도록 한다.

```rust
// error[E0502]: cannot borrow `v` as mutable because it is also borrowed as immutable
    let mut v = vec![1, 2, 3, 4, 5];

    let first = &v[0];
    v.push(6);

    println!("The first element is: {}", first);

```

- 언뜻 보기에는 컴파일 되어야 할 것 같지만, `first`가 `v`의 불변 참조를 가지고 있기 때문에 `v`를 변경할 수 없다.

- 또 더 언뜻 보기에는 첫번째 참조와 마지막 원소의 참조와는 아무런 관계가 없어 보이지만, 벡터가 메모리에 저장되는 방식 때문에 이런 제약이 생긴다.

- 벡터가 메모리에 저장되는 방식은 다음과 같다.

    - 벡터는 `capacity`와 `length`를 가진다.
    
    - `capacity`는 벡터가 메모리에 할당된 공간의 크기를 나타낸다.
    
    - `length`는 벡터에 실제로 저장된 요소의 개수를 나타낸다.
    
    - 벡터가 메모리에 저장되는 방식은 `capacity`가 늘어나면 새로운 메모리에 복사하고, `length`가 늘어나면 새로운 요소를 추가한다.

- 여기서 새로은 메모리에 복사되면 첫 번째 참조가 있는 상태에서 새로운 메모리에 복사되면서 첫 번째 참조가 해제된 메모리를 가리키게 되기 때문에 용납하지 않는다.

### 8.1.4 Iterating over the Values in a Vector

- 벡터의 각각의 모든 요소에 접근하려면, 한번에 하나의 인덱스 사용하는 대신, 모든 요소를 순회하면서 접근하는 방법이 있다.

- `i32` 값의 벡터에서 각 요소에 대한 불변 참조를 얻어 그 값을 출력하는 예제
```rust
    let v = vec![100, 32, 57];
    for i in &v {
        println!("{}", i);
    }
```

- `i32` 값의 벡터에서 각 요소에 대한 가변 참조를 얻어 그 값을 변경하는 예제
```rust
    let mut v = vec![100, 32, 57];
    for i in &mut v {
        *i += 50;
    }
```

- `for` 루프를 사용하여 벡터의 요소에 접근할 때, `&`를 사용하여 불변 참조를 얻거나, `&mut`를 사용하여 가변 참조를 얻을 수 있다.

- 가변 참조가 참조하는 값을 변경하려면 * 연산자를 사용하여 참조를 역참조해야 한다.

- borrow checker 덕에 이러한 행동은 안전하다, (위에서와 동일한 논리로, 벡터에 대한 참조는 전체 벡터의 동시 수정을 방지한다)

### 8.1.5 Using an Enum to Store Multiple Types

- 벡터는 동일한 타입의 값만 저장할 수 있다. 하지만, 열거형을 사용하면 다른 타입의 값들을 저장할 수 있다.

```rust
    enum SpreadsheetCell {
        Int(i32),
        Float(f64),
        Text(String),
    }

    let row = vec![
        SpreadsheetCell::Int(3),
        SpreadsheetCell::Text(String::from("blue")),
        SpreadsheetCell::Float(10.12),
    ];
```
> 참고로 이넘의 variant를 식별해야 몇칸씩 읽어야 하는지 알 수 있기 때문에, 이넘을 사용한다면 `태그` 또는 `디스크리미네이터`를 메모리의 해당 위치에 저장한다.


### 8.1.4 Dropping a Vector Drops Its Elements

- 벡터가 스코프를 벗어나면, 벡터와 그 안의 요소들이 모두 해제된다. ~~ㅂㅂ~~

## 8.2.0 Storing UTF-8 Encoded Text with Strings

- `String`은 가변 길이의 텍스트를 저장할 수 있는 컬렉션이다.

- `Rustcean`들이 `String`을 사용할 때, 아래의 세가지 이유로 막힌다고 한다.
  - `String`은 가능한 에러를 노출시키는 경향이 있다.
  - `String`은 생각보다 복잡한 자료구조이다.
  - `UTF-8`...

- 결론적으로 이 장에서는 문자열을 컬렉션의 맥락으로 논의한다.

- 왜냐하면 실제로 `String`은 바이트의 컬렉션이며, 텍스트로 해설될 때 유용한 기능을 제공하는 메서드가 추가되었다고 보면 적절하기 때문이다.

- Collection의 맥락에서 CRUD를 논의한다.

### 8.2.1 What is a String?

> 러스트의 `String`을 먼저 정리해야 한다.
> 기본적으로는 표준 라이브러리에서 제공하는 가변적이고, 소유권이 있으며, 확장 가능한, UTF-8 인코딩된 문자열 타입니다.
> 물론 일반적으로 String이라고 하면 해당 `String`과 `str`을 모두 포함한다.

### 8.2.2 Creating a New String

`Vec<T>`에서 가능한 많은 연산들은 `String`에서도 가능하다.
그 이유는 `String`이 `Vec<u8>`을 래핑하여 추가적인 구현(몇가지 guarantees, restrictions, capabilities 등)되어 있기 때문이다.

예를들어 생성도 벡터와 똑같이 `new`를 이용해서 할 수 있다.

```rust
    let mut s = String::new();
```

또한 `Display` 트레이트를 구현한 타입에 대해서 `to_string` 메서드를 사용할 수 있다.

```rust
    let data = "initial contents";
    let s = data.to_string();
    let s = "initial contents".to_string();
    let s = String::from("initial contents");
```

### 8.2.3 Updating a String

기본적으로 벡터와 같이 값을 추가/변경 할 수 있다.
심지어는 `+` 연산자를 사용하거나, `format!` 매크로를 사용하여 문자열을 결합 수정 할 수 있다.

```rust
    let mut s = String::from("foo");
    s.push_str("bar");
    s.push('l');
    s += "bar";
    s = s + "bar";
    s = format!("{}-{}", s, "bar");
```

```rust
fn add(self, s: &str) -> String {
```
참고로 `+` 연산자는 `add` 메서드를 호출한다.  
그리고 메서드 정의는 위와 같은데,
여기서 두가지를 알아 볼 수 있다.

```rust
    let s1 = String::from("Hello, ");
    let s2 = String::from("world!");
    let s3 = s1 + &s2;
```
이렇게 사용하면 `s1`은 더이상 사용할 수 없다. (self를 직접 사용하며 소유권을 가져가기 때문에)
두 번째로 `&String`은 `&str`로 강제 변환이 가능하다.

그리고 첫 string의 ownership을 가져가서 뒤에 이어붙여 전달하는 최적화된 구조이다.

> 그래서 연쇄적인 +의 경우는 비효율적이며 String::push_str, 혹은 format을 이용하는게 나음

### 8.2.4 Indexing into Strings

`String`은 `Vec<u8>`을 래핑하고 있다고 하기도 했고, 많은 다른 언어에서 문자열을 인덱스로 접근하는게 일반적이라 당연하 가능할 것 같은 아래의 코드는

```rust
    let s1 = String::from("hello");
    let h = s1[0];
```

컴파일 에러가 발생한다.

```
error[E0277]: the type `str` cannot be indexed by `{integer}` 
```

간단히 이유를 요약하자면, 메모리에 나열되어있는 바이트들이 `UTF-8`로 인코딩 되어있기 때문에, 
각각의 문자가 다른 바이트 수를 가지고 있는 상황에서 정수 인덱스로 접근하는 것은 불가능하기 때문이다.

### 8.2.5 Slicing Strings

"문자열"을 슬라이싱 하는 것 자체는 나쁜 아이디어 일 수 있지만 정 필요하면 range를 주는 방식으로 사용 할수는 있다.
  
```rust
    let hello = "안녕하세요";
    let s = &hello[0..3];
```

하지만 이것도 마찬가지로 `UTF-8`로 인코딩 되어있기 때문에, 문자열의 일부를 슬라이싱 하는 것은 위험하다.

### 8.2.6 Methods for Iterating Over Strings

진짜 결론적으로 실질적으로 문자를 다루고 싶다면 `chars` 메서드를 사용하면 된다.

```rust
    for c in "안녕하세요".chars() {
        println!("{}", c);
    }
```


## 8.3.0 Storing Keys with Associated Values in Hash Maps

`HashMap`은 딱히 다른게 없다..


### 8.3.1 Creating a New Hash Map & Accessing Values in a Hash Map

```rust
    use std::collections::HashMap;

    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);

    let team_name = String::from("Blue");
    let score = scores.get(&team_name).copied().unwrap_or(0);
```

`HashMap`은 Option<&T>를 반환하기 때문에 코드는 조금 더 예뻐질 수 있다.
(copied로 `Option<&T>`를 `Option<T>`로 받고, `unwrap_or`로 기본값을 설정한다.)

### 8.3.2 Hash Maps and Ownership

```rust
    let field_name = String::from("Favorite color");
    let field_value = String::from("Blue");

    let mut map = HashMap::new();
    map.insert(field_name, field_value);
```

Ownership 자체는 동일하게 동작한다. `Copy` 트레이트를 구현한 타입은 복사되어 저장되고, 그렇지 않은 타입은 소유권이 이전된다. (정확히는 insert method로 이동 후 drop)

### 8.3.3 Updating a Hash Map

```rust
    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Yellow"), 50);

    scores.entry(String::from("Blue")).or_insert(50);
```

### 8.3.4 Overwriting a Value

```rust
    let mut scores = HashMap::new();

    scores.insert(String::from("Blue"), 10);
    scores.insert(String::from("Blue"), 25);
```

### 8.3.5 Only Inserting a Value If the Key Has No Value

```rust
    let mut scores = HashMap::new();
    scores.insert(String::from("Blue"), 10);

    scores.entry(String::from("Yellow")).or_insert(50);
    scores.entry(String::from("Blue")).or_insert(50);
```

### 8.3.6 Updating a Value Based on the Old Value

```rust
    let text = "hello world wonderful world";

    let mut map = HashMap::new();

    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        *count += 1;
    }
```
