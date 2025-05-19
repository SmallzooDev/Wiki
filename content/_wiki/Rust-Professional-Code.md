---
title: Rust Professional Code 🦀
summary: 
date: 2025-05-19 16:11:34 +0900
lastmod: 2025-05-19 18:17:21 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# Rust Professional Code
> Rust-Professional-Code 책에 대한 내용정리, 간단하고 필요한 부분만 정리하여 개인 참고용
- 지금 나에게도 중요한 내용들도 많지만, 당장 나에게 필요하지는 않은 큰 프로젝트를 관리하는 방법, 다른 언어 바이너리와의 통합과 같은 것들이 많다.
- 언젠가는 필요해지겠지만 그러한 내용들은 그 즈음에 읽어가는게 낫다는 생각이 들어 필요한 부분만 리마인드용으로 발췌해서 정리하려 한다.
## Chapter 4 데이터 구조

### String, str, &str, &'satic str에 대한 설명
> 문자열 타입들이 많아 혼란스럽지만, 기본데이터(연속적인 문자의 열)와 상호작용하는 인터페이스를 나눠서 생각하는 것이 중요하다. 러스트에는 한 종류의 문자열만 있지만, 문자열을 할당하고 해당 문자열의 참조를 처리하는데에는 여러 가지 방법이 있다.

#### String과 str
- 이 둘은 기술적으로는 다른 타입이지만, 의도와 목적 면에서는 대동소이하다.
- 유일한 실질적인 차이점은 메모리 관리 방법이다.
- str : '스택'에 할당된 utf-8 문자열, 대여할 수 있지만 이동하거나 변경 할 수 없음
- String: '힙'에 할당된 utf-8 문자열, 대여와 변경이 가능함
```c
char *stack_string = "stack-allocated string";
char *heap_string = strndup("heap-allocated string);
```
- 비유하자면 str은 전자, String은 후자라고 생각하면 된다.
> 러스트에서의 메모리 할당은 명시적이므로 일반적으로 타입 자체가 요소의 수와 함께 메모리 할당 방법도 정의한다.

#### 효율적으로 문자열 사용하기
- 러스트에서 작업 할 때 대부분 String, &str을 사용하고 str은 사용하지 않는다.
- 러스트 표준 라이브러리에서
	- 불변 문자열 함수는 &str 타입에 대해 구현된다.
	- 가변 문자열 함수는 String 타입에서만 구현된다.
- str은 직접 생성할 수는 없으며, 그에 대한 참조만 빌릴 수 있다.
- 함수 파라미터로 사용되는 경우처럼 String을 항상 &str로 빌릴 수 있기 때문에 &str 타입은 최소 공통 분모 역할을 한다.
- static의 경우는 프로세스의 전체 수명 동안 유효한 참조를 정의하는 특수한 수명 지정자이다.
- 참고로 &str로 `&'static str`을 빌릴 수 없다.

| 특성      | `str`                | `&str`                   | `String`                                       | `&'static str`                               |
| ------- | -------------------- | ------------------------ | ---------------------------------------------- | -------------------------------------------- |
| 종류      | 슬라이스                 | 문자열 슬라이스 참조              | 소유권이 있는 문자열                                    | 정적 수명을 가진 문자열 슬라이스                           |
| 크기      | 동적                   | 2*포인터 크기 (16바이트)         | 24바이트 (포인터, 길이, 용량)                            | 2*포인터 크기 (16바이트)                             |
| 수명      | N/A (단독 사용 불가)       | 참조 수명에 종속                | 소유권 기반, 명시적 수명 없음                              | 프로그램 전체 수명                                   |
| 수정 가능성  | 불변                   | 불변                       | 가변                                             | 불변                                           |
| 할당      | 스택 (일반적으로)           | 없음 (참조만)                 | 힙                                              | 정적 메모리 영역                                    |
| 생성 방법   | 직접 생성 불가             | `&"hello"`, 슬라이싱         | `String::from("hello")`, `"hello".to_string()` | `"hello"`, `const S: &'static str = "hello"` |
| 주요 용도   | 타입 정의용               | 문자열 참조 및 읽기              | 문자열 수정 및 소유                                    | 컴파일 타임 상수 문자열                                |
| 예시      | `fn f(s: str)` (불가능) | `fn f(s: &str)`          | `let s = String::from("hello")`                | `const VERSION: &'static str = "1.0"`        |
| 변환      | N/A                  | `&String` → `&str` 자동 변환 | `.as_str()` → `&str`                           | `&'static str` → `&str` 가능                   |
| 연결      | 불가능                  | 불가능 (새 String 필요)        | `+` 연산자, `push_str()`                          | 불가능 (새 String 필요)                            |
| 문자열 리터럴 | N/A                  | 리터럴은 `&'static str`      | `to_string()` 으로 변환 필요                         | 문자열 리터럴 자체                                   |

- str과 String의 또 다른 차이점은 String은 이동할수 있지만, str은 안된다는 것이다.
```rust
fn print_String(s: String) {
	println!("print_String: {}", s);
}

fn print_str(s: &str) {
	println!("print_String: {}", s);
}

fn main() {
	// let s: str = "impossible str"; <- 컴파일 안됨
	print_String(String::from("String")); // 가능, value는 이동한다.
	print_str(&String::from("String")); // 참조를 반환하기에 가능
	print_str("str"); // main 스택에 str 생성하고, 이를 참조로 전달하기에 가능하다
}
```

#### 슬라이스와 배열 이해하기
