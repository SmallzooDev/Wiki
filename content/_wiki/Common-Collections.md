---
title: 러스트의 컬렉션 모아보기
summary: 
date: 2024-04-14 13:53:34 +0900
lastmod: 2024-04-14 13:53:34 +0900
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


