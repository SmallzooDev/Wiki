---
title: 
summary: 
date: 2024-10-02 20:44:13 +0900
lastmod: 2024-10-02 20:44:13 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 9.0.0 Error Handling 
> Error는 소프트웨어의 한 요소이다.
> 당연히 러스트에서도 다양한 방식으로 에러를 핸들링 할 수 있도록 지원한다.
> 러스트 역시 에러의 가능성과 그에대한 대응을 컴파일 시점에 체크해준다.
> 러스트는 에러를 두가지로 그룹화한다. `recoverable`과 `unrecoverable` 에러로 나누어진다.
> 다른 언어에서는 해당 에러들을 굳이 구분하지 않고, 모두 exception과 같은 시스템으로 처리한다.
> 러스트는 이러한 에러를 `Result<T, E>`와 `panic!` 매크로를 통해 나눠서 처리한다.

### 9.1.0 Unrecoverable Errors with panic!

> 가끔 우리의 코드에는 안좋은 일들이 일어나고, 그 부분에 대해서 더이상 뭔가를 할 수 없는 경우가 있다.
> 이러한 경우를 `unrecoverable` 에러라고 하며, 러스트는 이러한 에러를 처리하기 위해 `panic!` 매크로를 제공한다.

```rust
fn main() {
    panic!("crash and burn");
}
```

- `panic!` 매크로는 프로그램을 즉시 종료하고, 스택을 걷어내고, 부모 프로세스에게 알린다.
- `RUSST_BACKTRACE=1` 환경변수를 사용하여 백트레이스를 출력할 수 있다.

### 9.2.0 Recoverable Errors with Result

```rust
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

- `Result`는 `Ok`와 `Err` 두 가지의 열거형을 가지고 있다.
- `Result`는 `recoverable` 에러를 나타내는데 사용된다.

```rust
use std::fs::File;

fn main() {
    let greeting_file_result = File::open("hello.txt");

    let greeting_file = match greeting_file_result {
        Ok(file) => file,
        Err(error) => panic!("Problem opening the file: {error:?}"),
    };
}
```


