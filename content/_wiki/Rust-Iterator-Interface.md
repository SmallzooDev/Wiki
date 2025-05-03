---
title: Rust Iter 정리 🔄
summary: 
date: 2025-05-03 11:28:36 +0900
lastmod: 2025-05-03 11:32:14 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# Rust Iterator 인터페이스 종합 

## 1. 핵심 트레이트

### Iterator 트레이트

```rust
pub trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
    // ... 여러 기본 구현 메서드들
}
```

### IntoIterator 트레이트

```rust
pub trait IntoIterator {
    type Item;
    type IntoIter: Iterator<Item = Self::Item>;
    fn into_iter(self) -> Self::IntoIter;
}
```

### FromIterator 트레이트

```rust
pub trait FromIterator<A> {
    fn from_iter<T>(iter: T) -> Self
    where
        T: IntoIterator<Item = A>;
}
```

## 2. 반복자 생성 메서드

### 기본 컬렉션 반복자

- `iter()`: 불변 참조 반복자 (`&T`)
- `iter_mut()`: 가변 참조 반복자 (`&mut T`)
- `into_iter()`: 소유권 이전 반복자 (`T`)

### 범위 반복자

```rust
// 범위 문법으로 반복자 생성
let range = 1..5;        // 1, 2, 3, 4
let inclusive = 1..=5;   // 1, 2, 3, 4, 5
```

### 스트림 반복자

- `std::io::Lines`: 파일의 각 줄을 순회
- `std::io::Bytes`: 바이트 스트림을 순회

### 기타 반복자 생성

- `once`: 단일 값을 생성하는 반복자

```rust
use std::iter;
let once = iter::once(42);  // 42만 생성
```

- `repeat`: 동일한 값을 무한히 생성하는 반복자

```rust
let repeat = iter::repeat('a');  // 'a'를 무한히 생성
```

- `empty`: 빈 반복자

```rust
let empty: iter::Empty<i32> = iter::empty();  // 항목 없음
```

## 3. 반복자 어댑터 메서드 (자주 사용되는 것들)

### 필터링 어댑터

- `filter(pred)`: 조건을 만족하는 항목만 유지
- `filter_map(f)`: 변환과 필터링을 동시에 수행
- `take(n)`: 처음 n개 항목만 유지
- `take_while(pred)`: 조건이 참인 동안의 항목만 유지
- `skip(n)`: 처음 n개 항목을 건너뜀
- `skip_while(pred)`: 조건이 참인 동안 항목을 건너뜀
- `step_by(n)`: n 단계마다 항목을 선택
- `peekable()`: 다음 항목을 미리 확인할 수 있는 반복자 생성

### 변환 어댑터

- `map(f)`: 각 항목을 변환
- `flat_map(f)`: 중첩 반복자를 평탄화
- `flatten()`: 중첩된 반복자를 한 수준 평탄화
- `inspect(f)`: 각 항목을 검사 (디버깅용)
- `cloned()`: 참조 반복자의 값을 복제
- `copied()`: 복사 가능한 참조 반복자의 값을 복사
- `map_while(f)`: 조건이 참인 동안 변환
- `scan(state, f)`: 상태를 가진 변환

### 결합 어댑터

- `chain(other)`: 두 반복자를 연결
- `zip(other)`: 두 반복자를 쌍으로 결합
- `unzip()`: 쌍의 반복자를 두 개로 분리
- `enumerate()`: 인덱스와 값의 쌍으로 변환
- `partition(pred)`: 조건에 따라 두 그룹으로 분리

### 순서 관련 어댑터

- `rev()`: 반복자의 순서를 뒤집음 (양방향 반복자에만 적용 가능)
- `cycle()`: 반복자를 무한히 반복
- `interleave(other)`: 두 반복자의 항목을 번갈아가며 생성
- `interleave_shortest(other)`: 더 짧은 반복자까지만 번갈아가며 생성

### 그룹화 어댑터

- `chunks(n)`: n개 항목의 청크로 그룹화
- `chunks_exact(n)`: 정확히 n개 항목의 청크로 그룹화
- `windows(n)`: n개 항목의 슬라이딩 윈도우로 그룹화

## 4. 반복자 소비자 메서드

### 컬렉션 변환

- `collect()`: 반복자를 컬렉션으로 변환

```rust
let v: Vec<i32> = (0..5).collect();
let s: HashSet<i32> = (0..5).collect();
let m: HashMap<char, i32> = vec![('a', 1), ('b', 2)].into_iter().collect();
```

### 계산 소비자

- `sum()`: 모든 항목의 합계를 계산
- `product()`: 모든 항목의 곱을 계산
- `fold(init, f)`: 초기값과 함수로 모든 항목을 접음
- `reduce(f)`: 첫 항목을 초기값으로 사용하여 접음
- `try_fold(init, f)`: 오류 처리가 가능한 fold
- `try_reduce(f)`: 오류 처리가 가능한 reduce

### 검색 소비자

- `find(pred)`: 조건을 만족하는 첫 항목을 찾음
- `position(pred)`: 조건을 만족하는 첫 항목의 위치를 찾음
- `rposition(pred)`: 뒤에서부터 조건을 만족하는 첫 항목의 위치를 찾음
- `contains(&x)`: 특정 항목을 포함하는지 확인
- `any(pred)`: 조건을 만족하는 항목이 있는지 확인
- `all(pred)`: 모든 항목이 조건을 만족하는지 확인
- `max()`: 최대 항목을 찾음
- `min()`: 최소 항목을 찾음
- `max_by(cmp)`: 비교 함수로 최대 항목을 찾음
- `min_by(cmp)`: 비교 함수로 최소 항목을 찾음
- `max_by_key(f)`: 키 함수로 최대 항목을 찾음
- `min_by_key(f)`: 키 함수로 최소 항목을 찾음

### 기타 소비자

- `count()`: 항목의 수를 반환
- `last()`: 마지막 항목을 반환
- `nth(n)`: n번째 항목을 반환
- `for_each(f)`: 각 항목에 함수를 적용
- `try_for_each(f)`: 오류 처리가 가능한 for_each
- `is_partitioned(pred)`: 반복자가 분할되어 있는지 확인
- `is_sorted()`: 반복자가 정렬되어 있는지 확인
- `is_sorted_by(cmp)`: 비교 함수로 정렬 여부 확인

## 5. 특수 반복자 유형

### Peekable

다음 항목을 소비하지 않고 미리 확인할 수 있는 반복자:

```rust
let mut peekable = [1, 2, 3].iter().peekable();
if let Some(&first) = peekable.peek() {
    println!("다음 항목: {}", first);
}
```

### Fuse

`None`을 반환한 이후 항상 `None`을 반환하도록 보장하는 반복자:

```rust
let fused = [1, 2, 3].iter().fuse();
```

### Cycle

반복자를 무한히 반복하는 반복자:

```rust
let mut cycle = [1, 2, 3].iter().cycle();
// 1, 2, 3, 1, 2, 3, ...
```

### Enumerate

인덱스와 값의 쌍으로 생성하는 반복자:

```rust
let enumerated = ['a', 'b', 'c'].iter().enumerate();
// (0, 'a'), (1, 'b'), (2, 'c')
```

### Chain

두 반복자를 연결하는 반복자:

```rust
let chained = [1, 2].iter().chain([3, 4].iter());
// 1, 2, 3, 4
```

### Zip

두 반복자를 쌍으로 묶는 반복자:

```rust
let zipped = [1, 2].iter().zip(['a', 'b'].iter());
// (1, 'a'), (2, 'b')
```

## 6. 구현 패턴

### 컬렉션에 반복자 구현하기

```rust
struct MyCollection<T> {
    data: Vec<T>,
}

impl<T> MyCollection<T> {
    fn iter(&self) -> impl Iterator<Item = &T> {
        self.data.iter()
    }
    
    fn iter_mut(&mut self) -> impl Iterator<Item = &mut T> {
        self.data.iter_mut()
    }
}

impl<T> IntoIterator for MyCollection<T> {
    type Item = T;
    type IntoIter = std::vec::IntoIter<T>;
    
    fn into_iter(self) -> Self::IntoIter {
        self.data.into_iter()
    }
}

impl<'a, T> IntoIterator for &'a MyCollection<T> {
    type Item = &'a T;
    type IntoIter = std::slice::Iter<'a, T>;
    
    fn into_iter(self) -> Self::IntoIter {
        self.data.iter()
    }
}

impl<'a, T> IntoIterator for &'a mut MyCollection<T> {
    type Item = &'a mut T;
    type IntoIter = std::slice::IterMut<'a, T>;
    
    fn into_iter(self) -> Self::IntoIter {
        self.data.iter_mut()
    }
}
```

### 사용자 정의 반복자 구현하기

```rust
struct Fibonacci {
    curr: u32,
    next: u32,
}

impl Fibonacci {
    fn new() -> Fibonacci {
        Fibonacci { curr: 0, next: 1 }
    }
}

impl Iterator for Fibonacci {
    type Item = u32;
    
    fn next(&mut self) -> Option<Self::Item> {
        let new_next = self.curr + self.next;
        self.curr = self.next;
        self.next = new_next;
        Some(self.curr)
    }
}
```

## 7. 유용한 패턴과 기법

### 컬렉션 변환하기

```rust
// Vec<T> -> Vec<U>
let v: Vec<i32> = vec![1, 2, 3];
let doubled: Vec<i32> = v.iter().map(|&x| x * 2).collect();

// Vec<T> -> HashSet<T>
let set: HashSet<i32> = v.iter().cloned().collect();

// Vec<T> -> HashMap<K, V>
let map: HashMap<i32, char> = vec![(1, 'a'), (2, 'b')].into_iter().collect();
```

### 그룹화 및 필터링

```rust
// 짝수와 홀수로 그룹화
let (even, odd): (Vec<i32>, Vec<i32>) = (1..=10).partition(|&n| n % 2 == 0);

// 조건에 따라 필터링
let positive: Vec<i32> = vec![-1, 2, -3, 4].into_iter().filter(|&x| x > 0).collect();
```

### `Result`와 함께 사용하기

```rust
// 모든 결과가 Ok인지 확인
let results = vec![Ok(1), Ok(2), Ok(3)];
let all_ok = results.iter().all(|r| r.is_ok());

// Ok 값만 수집
let ok_values: Vec<i32> = results.into_iter().filter_map(Result::ok).collect();
```

### `Option`과 함께 사용하기

```rust
// Some 값만 수집
let options = vec![Some(1), None, Some(2)];
let values: Vec<i32> = options.into_iter().filter_map(|o| o).collect();
```

### 중첩 구조 처리하기

```rust
// 중첩 반복자 평탄화
let nested = vec![vec![1, 2], vec![3, 4]];
let flat: Vec<i32> = nested.into_iter().flatten().collect();  // [1, 2, 3, 4]

// map과 flatten 조합
let words = vec!["hello", "world"];
let chars: Vec<char> = words.iter()
    .flat_map(|word| word.chars())
    .collect();  // ['h', 'e', 'l', 'l', 'o', 'w', 'o', 'r', 'l', 'd']
```

### 순차 처리 vs 병렬 처리

```rust
// 순차 처리 (표준 라이브러리)
let sum: i32 = (1..1000).sum();

// 병렬 처리 (rayon 크레이트 사용)
use rayon::prelude::*;
let sum: i32 = (1..1000).into_par_iter().sum();
```

### 무한 반복자 다루기

```rust
// 무한 반복자 생성
let infinite = std::iter::repeat(1);

// 유한 반복자로 제한
let finite: Vec<i32> = infinite.take(5).collect();  // [1, 1, 1, 1, 1]
```

## 8. 외부 크레이트의 반복자 확장

### Itertools 크레이트

Itertools는 표준 라이브러리의 반복자 기능을 확장:

```rust
use itertools::Itertools;

// 그룹화
let groups = vec![1, 1, 1, 3, 3, 2, 2, 2]
    .into_iter()
    .group_by(|&x| x);

// 순열
let permutations = [1, 2, 3].iter().permutations(2);

// 조합
let combinations = [1, 2, 3, 4].iter().combinations(2);

// intersperse
let interspersed: Vec<i32> = [1, 2, 3].iter()
    .cloned()
    .intersperse(0)
    .collect();  // [1, 0, 2, 0, 3]

// 중복 항목 제거
let unique: Vec<i32> = [1, 2, 1, 3, 2].iter()
    .cloned()
    .unique()
    .collect();  // [1, 2, 3]
```

### Rayon 크레이트

Rayon은 병렬 반복자 제공:

```rust
use rayon::prelude::*;

// 병렬 맵
let v: Vec<i32> = (0..1000)
    .into_par_iter()
    .map(|i| i * i)
    .collect();

// 병렬 필터
let evens: Vec<i32> = (0..1000)
    .into_par_iter()
    .filter(|i| i % 2 == 0)
    .collect();
```
