---
title: Rust IO for PS
summary: 
date: 2025-05-02 18:07:45 +0900
lastmod: 2025-05-02 18:17:40 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# Rust 코딩 테스트를 위한 입출력 인터페이스

## 템플릿

```rust
use std::io::{self, Read, Write};

fn main() {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    let mut lines = input.lines();
    
    // 여기서부터 다양한 입력 처리 방식
}
```
## 인터페이스 정리

```rust
use std::io::{self, Read, Write};
```

- `std::io`: Rust의 표준 입출력 모듈
- `Read`: 읽기 작업을 위한 트레이트
- `Write`: 쓰기 작업을 위한 트레이트

## 함수 및 메소드 명세
### 1. io::stdin()
```rust
let mut stdin = io::stdin().lock();
```

- **타입**: `fn stdin() -> Stdin`
- **설명**: 표준 입력의 핸들을 가져옴
- **반환값**: `Stdin` 구조체 (표준 입력 관리)

### 2. Stdin::lock()

```rust
let mut stdin = io::stdin().lock();
```

- **타입**: `fn lock(&self) -> StdinLock<'_>`
- **설명**: 표준 입력에 대한 락을 획득하여 입력 스트림에 독점적으로 접근
- **반환값**: `StdinLock` (락이 걸린 표준 입력 핸들)
- **참고**: 성능 향상을 위해 사용됨. 다중 스레드 환경에서 입력 충돌 방지

### 3. io::stdout()

```rust
let mut stdout = io::stdout().lock();
```

- **타입**: `fn stdout() -> Stdout`
- **설명**: 표준 출력의 핸들을 가져옴
- **반환값**: `Stdout` 구조체 (표준 출력 관리)

### 4. Stdout::lock()

```rust
let mut stdout = io::stdout().lock();
```

- **타입**: `fn lock(&self) -> StdoutLock<'_>`
- **설명**: 표준 출력에 대한 락을 획득하여 출력 스트림에 독점적으로 접근
- **반환값**: `StdoutLock` (락이 걸린 표준 출력 핸들)
- **참고**: 출력 성능 향상 및 출력 충돌 방지에 사용됨

### 5. String::new()

```rust
let mut input = String::new();
```

- **타입**: `fn new() -> String`
- **설명**: 빈 문자열을 생성
- **반환값**: 비어있는 새 `String` 인스턴스
- **참고**: 입력을 저장할 버퍼로 사용됨

### 6. Read::read_to_string()

```rust
stdin.read_to_string(&mut input).unwrap();
```

- **타입**: `fn read_to_string(&mut self, buf: &mut String) -> Result<usize>`
- **설명**: 스트림의 모든 바이트를 읽어 문자열로 변환하고 지정된 버퍼에 추가
- **매개변수**: `buf` - 입력을 저장할 문자열 버퍼
- **반환값**: `Result<usize>` - 성공 시 읽은 바이트 수, 실패 시 오류
- **참고**: EOF(End-of-File)까지 모든 내용을 읽음

### 7. Result::unwrap()

```rust
stdin.read_to_string(&mut input).unwrap();
```

- **타입**: `fn unwrap(self) -> T`
- **설명**: `Result`가 `Ok`인 경우 내부 값을 반환, `Err`인 경우 프로그램 종료(panic)
- **반환값**: `Result`가 `Ok`인 경우 내부 값 `T`
- **참고**: 에러 처리를 간소화하기 위해 사용, 코딩 테스트에서는 적합하지만 실제 애플리케이션에서는 적절한 에러 처리 권장

### 8. str::lines()

```rust
let mut lines = input.lines();
```

- **타입**: `fn lines(&self) -> Lines<'_>`
- **설명**: 문자열을 줄 단위로 분할하는 이터레이터 생성
- **반환값**: `Lines` (문자열의 각 줄을 순회하는 이터레이터)
- **참고**: 개행 문자(`\n`, `\r\n`)를 기준으로 분할하며 반환된 줄에는 개행 문자가 포함되지 않음

## 이터레이터 메소드

### 1. Iterator::next()

- **타입**: `fn next(&mut self) -> Option<Self::Item>`
- **설명**: 이터레이터에서 다음 항목을 가져옴
- **반환값**: `Option<Item>` - 다음 항목이 있으면 `Some(item)`, 없으면 `None`
- **사용예**:
    
    ```rust
    let next_line = lines.next().unwrap();
    ```
    

### 2. str::parse()

- **타입**: `fn parse<F>(&self) -> Result<F, F::Err> where F: FromStr`
- **설명**: 문자열을 지정된 타입으로 파싱
- **반환값**: `Result<F, F::Err>` - 파싱 성공 시 변환된 값, 실패 시 오류
- **사용예**:
    
    ```rust
    let n: usize = lines.next().unwrap().parse().unwrap();
    ```
    

## 출력 관련 매크로
### 1. write!()
- **타입**: 매크로
- **설명**: 형식화된 문자열을 `Write` 트레이트를 구현한 객체에 출력
- **매개변수**:
    - 첫 번째: 출력 대상(`Write` 트레이트 구현체)
    - 두 번째: 형식 문자열
    - 나머지: 형식 문자열에 대응하는 값들
- **반환값**: `Result<(), Error>` - 성공 시 `Ok(())`, 실패 시 오류
- **사용예**:
    
    ```rust
    write!(stdout, "{}", output).unwrap();
    ```
    

### 2. writeln!()
- **타입**: 매크로
- **설명**: `write!`와 유사하지만 끝에 개행 문자를 추가
- **사용예**:
    
    ```rust
    writeln!(stdout, "{}", output).unwrap();
    ```
## 다양한 입력 처리 케이스

### 1. 정수 하나 읽기

```rust
let n: usize = lines.next().unwrap().parse().unwrap();
```

### 2. 공백으로 구분된 정수 여러 개 읽기

```rust
let numbers: Vec<i32> = lines.next().unwrap()
    .split_whitespace()
    .map(|s| s.parse().unwrap())
    .collect();
```

### 3. 여러 줄의 정수 읽기

```rust
let mut numbers = Vec::new();
for _ in 0..n {
    let num: i32 = lines.next().unwrap().parse().unwrap();
    numbers.push(num);
}
```

### 4. 공백으로 구분된 문자열 여러 개 읽기

```rust
let strings: Vec<String> = lines.next().unwrap()
    .split_whitespace()
    .map(|s| s.to_string())
    .collect();
```

### 5. 문자 배열 읽기

```rust
let chars: Vec<char> = lines.next().unwrap().chars().collect();
```

### 6. 2차원 격자 읽기

```rust
let mut grid = Vec::new();
for _ in 0..n {
    let row: Vec<i32> = lines.next().unwrap()
        .chars()
        .map(|c| c.to_digit(10).unwrap() as i32)
        .collect();
    grid.push(row);
}
```

### 7. 테스트 케이스 처리

```rust
let t: usize = lines.next().unwrap().parse().unwrap();
for _ in 0..t {
    // 각 테스트 케이스 처리
    let n: usize = lines.next().unwrap().parse().unwrap();
    // 추가 입력 처리
}
```

### 8. 빈 줄을 포함한 입력 처리

```rust
while let Some(line) = lines.next() {
    if line.is_empty() {
        continue; // 빈 줄 건너뛰기
    }
    // 입력 처리
}
```

### 9. EOF까지 모든 줄 처리

```rust
while let Some(line) = lines.next() {
    // 각 줄 처리
    let n: i32 = line.parse().unwrap();
    // 작업 수행
}
```

## 출력 패턴

### 1. 단일 값 출력

```rust
write!(stdout, "{}", result).unwrap();
```

### 2. 개행 포함 출력

```rust
writeln!(stdout, "{}", result).unwrap();
```

### 3. 여러 값 출력

```rust
write!(stdout, "{} {}", a, b).unwrap();
```

### 4. 벡터 요소 출력

```rust
for item in &items {
    write!(stdout, "{} ", item).unwrap();
}
writeln!(stdout).unwrap(); // 줄바꿈
```

### 5. 여러 줄 출력

```rust
for result in &results {
    writeln!(stdout, "{}", result).unwrap();
}
```

## 실전 예시

### 예시 1: 백준 11053 - 가장 긴 증가하는 부분 수열

```rust
use std::io::{self, Read, Write};

fn main() {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    let mut lines = input.lines();
    
    // 배열 크기
    let n: usize = lines.next().unwrap().parse().unwrap();
    
    // 수열 A
    let seq: Vec<i32> = lines.next().unwrap()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();
    
    // DP 배열 초기화
    let mut dp = vec![1; n];
    
    // LIS 계산
    for i in 1..n {
        for j in 0..i {
            if seq[j] < seq[i] && dp[j] + 1 > dp[i] {
                dp[i] = dp[j] + 1;
            }
        }
    }
    
    // 최대 길이 찾기
    let result = dp.iter().max().unwrap();
    
    // 결과 출력
    write!(stdout, "{}", result).unwrap();
}
```

### 예시 2: 수열 합 구하기

```rust
use std::io::{self, Read, Write};

fn main() {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    let mut lines = input.lines();
    
    // 수열 크기와 구간 쿼리 수
    let header: Vec<usize> = lines.next().unwrap()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();
    let (n, q) = (header[0], header[1]);
    
    // 수열 입력
    let numbers: Vec<i64> = lines.next().unwrap()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();
    
    // 각 쿼리 처리
    for _ in 0..q {
        let query: Vec<usize> = lines.next().unwrap()
            .split_whitespace()
            .map(|s| s.parse().unwrap())
            .collect();
        let (l, r) = (query[0] - 1, query[1] - 1);
        
        // 구간 합 계산
        let sum: i64 = numbers[l..=r].iter().sum();
        
        // 결과 출력
        writeln!(stdout, "{}", sum).unwrap();
    }
}
```

### 예시 3: 그래프 입력 처리

```rust
use std::io::{self, Read, Write};
use std::collections::VecDeque;

fn main() {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    let mut lines = input.lines();
    
    // 노드 수와 간선 수
    let nm: Vec<usize> = lines.next().unwrap()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();
    let (n, m) = (nm[0], nm[1]);
    
    // 그래프 초기화
    let mut graph = vec![Vec::new(); n + 1];
    
    // 간선 입력
    for _ in 0..m {
        let edge: Vec<usize> = lines.next().unwrap()
            .split_whitespace()
            .map(|s| s.parse().unwrap())
            .collect();
        let (a, b) = (edge[0], edge[1]);
        
        graph[a].push(b);
        graph[b].push(a); // 무방향 그래프인 경우
    }
    
    // BFS 수행 (1번 노드에서 시작)
    let mut visited = vec![false; n + 1];
    let mut queue = VecDeque::new();
    
    visited[1] = true;
    queue.push_back(1);
    
    while let Some(node) = queue.pop_front() {
        write!(stdout, "{} ", node).unwrap();
        
        for &next in &graph[node] {
            if !visited[next] {
                visited[next] = true;
                queue.push_back(next);
            }
        }
    }
}
```

### 예시 4: 2D 격자 문제 (미로 탐색)

```rust
use std::io::{self, Read, Write};
use std::collections::VecDeque;

fn main() {
    let mut stdin = io::stdin().lock();
    let mut stdout = io::stdout().lock();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    let mut lines = input.lines();
    
    // 미로 크기
    let nm: Vec<usize> = lines.next().unwrap()
        .split_whitespace()
        .map(|s| s.parse().unwrap())
        .collect();
    let (n, m) = (nm[0], nm[1]);
    
    // 미로 입력
    let mut maze = Vec::new();
    for _ in 0..n {
        let row: Vec<u8> = lines.next().unwrap()
            .chars()
            .map(|c| c.to_digit(10).unwrap() as u8)
            .collect();
        maze.push(row);
    }
    
    // BFS로 최단 경로 찾기
    let mut visited = vec![vec![false; m]; n];
    let mut distance = vec![vec![0; m]; n];
    let mut queue = VecDeque::new();
    let dirs = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    
    visited[0][0] = true;
    distance[0][0] = 1;
    queue.push_back((0, 0));
    
    while let Some((r, c)) = queue.pop_front() {
        if r == n - 1 && c == m - 1 {
            break;
        }
        
        for (dr, dc) in &dirs {
            let nr = (r as i32 + dr) as usize;
            let nc = (c as i32 + dc) as usize;
            
            if nr < n && nc < m && maze[nr][nc] == 1 && !visited[nr][nc] {
                visited[nr][nc] = true;
                distance[nr][nc] = distance[r][c] + 1;
                queue.push_back((nr, nc));
            }
        }
    }
    
    // 결과 출력
    write!(stdout, "{}", distance[n-1][m-1]).unwrap();
}
```
