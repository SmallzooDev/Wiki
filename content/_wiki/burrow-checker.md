---
title: 
summary: 
date: 2024-09-29 16:44:30 +0900
lastmod: 2024-09-29 16:44:30 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## burrow-checker에 대해 도움이 될 만 한 내용을 정리한 문서, rust-in-action 내용을 참고하여 작성하였습니다.

> 대여 검사는 서로 연결된 세 가지 개념인 수명, 소유권, 대여에 의존한다.

- `소유권` : 러스트에서 소유권은 해당 값이 더 이상 필요 없을 때 깨끗이 지우는 것 과 관련이 있다.
- `수명` : 값에 접근해도 문제없는 기간을 의미한다.
- `대여` : 값에 접근함을 의미한다. 원래 소유자에게 값을 되돌려 주지 않아도 된다는 점에서 현실의 대여와 헷갈린다. "값의 소유자는 하나이며, 프로그램의 많은 다른 부분에서 이 값을 접근하기 위한 장치"를 생각하면 조금 더 편하다.


### 01. Preriquisite 

```rust
#[derive(Debug)]
struct SomeStruct {
    some_field: u64,
}

fn do_not_take_ownership(primitive_type_case_param: u64) {
    println!("do nothing!");
}

fn take_ownership(some_struct: SomeStruct) {
    println!("do nothing!");
}

fn main() {
    let fine_case: u64 = 1;
    let ownership_error_case: SomeStruct = SomeStruct { some_field: 1 };

    do_not_take_ownership(fine_case);
    take_ownership(ownership_error_case);

    println!("fine_case: {}", fine_case);
    println!("ownership_error_case: {:?}", ownership_error_case);
}
```


```
error[E0382]: borrow of moved value: `ownership_error_case`
  --> src/main.rs:22:44
   |
16 |     let ownership_error_case: SomeStruct = SomeStruct { some_field: 1 };
   |         -------------------- move occurs because `ownership_error_case` has type `SomeStruct`, which does not implement the `Copy` trait
...
19 |     take_ownership(ownership_error_case);
   |                    -------------------- value moved here
...
22 |     println!("ownership_error_case: {:?}", ownership_error_case);
   |                                            ^^^^^^^^^^^^^^^^^^^^ value borrowed here after move
   |
note: consider changing this parameter type in function `take_ownership` to borrow instead if owning the value isn't necessary
  --> src/main.rs:10:32
   |
10 | fn take_ownership(some_struct: SomeStruct) {
   |    --------------              ^^^^^^^^^^ this parameter takes ownership of the value
   |    |
   |    in this function
   = note: this error originates in the macro `$crate::format_args_nl` which comes from the expansion of the macro `println` (in Nightly builds, run with -Z macro-backtrace for more info)
```

- `fine_case`는 `u64` 타입이기 때문에 `Copy` 트레이트를 구현하고 있어서 `do_not_take_ownership` 함수에 값을 전달해도 문제가 없다.
- `ownership_error_case`는 `SomeStruct` 타입이기 때문에 `Copy` 트레이트를 구현하고 있지 않아서 `take_ownership` 함수에 값을 전달하면 소유권이 이동하게 된다. 그래서 `ownership_error_case`를 사용하려고 하면 컴파일 에러가 발생한다.
- 여기까지는 rust 기본 문접 가이드에서 나온 내용이라 어렵지는 않다. `}` 를 만나면 스코프의 종료와 함께 해당 스코프에 있는 변수(정확히는 스코프 내에서 생성된, 아규먼트를 포함한)들을 drop한다.

> 값이 범위를 넘어가거나 다른 어떤 이유로 수명이 끝난다면, 파괴자가 호출된다.
> 파괴자는 값에 대한 참조를 지우고 메모리를 해제함으로써 프로그램으로부터 값의 흔적을 지우는 함다.
> ... (중략)
> 이 시스템에 함축된 한 가지 의미는 "값은 절대로 소유자보다 오래 지속될 수 없다" 는 것이다.

- 시스템은 아이디어를 함의하기 때문에 단순히 일어나는 일보다 왜 이렇게 되었을까를 이해하는게 더 중요하다고 생각한다.
- 개인적인 생각으로는 언어가 아무것도 안하거나 (c/cpp) 가비지 컬렉션같이 성능을 깎아먹는 것 대신,  `소유권 시스템`을 만들고 컴파일러가 이를 체크하도록 하는 것 자체가 아이디어인 것 같다.(하나의 시스템을 컴파일러가 검사한다면 사용자는 알아서 잘 하겠지!)


### 02. 소유권 문제 해결하기

러스트의 소유권 시스템은 훌륭하지만, 시스템을 이해하기 전에는 실수하기 십상이다. 그래서 처음 시작할 때 도움되는 네가지 전략은 아래와 같다.
- 완전한 소유권이 필요하지 않은 경우에는 참조를 사용한다.
- 값을 복제한다.
- 이동 문제를 보조하기 위해 설계된 타입으로 데이터를 감싼다.

> 사실 '장기간 유지되어야 하는 객체 수를 줄일 수 있도록 코드를 리팩토링 한다.' 와 같은 해결책도 책에서는 소개하고 있지만, 일반적인 내용이며 예시를 직접 보는게 도움이 될 것 같아 정리하지는 않았다.


**완전한 소유권이 필요하지 않은 경우에는 참조를 사용한다.**

- 가장 직접적이며 단순한 해결방법이다. `& T`, `& mut T` 를 사용한다.
- 기존에 다른 언어를 배운 사람들에게 익숙한 방법이면서도 러스트 소유권 시스템 룰을 따를 수 있다.
- 다만 트리나 그래프같은 상황에서 소유권으로 인해 생기는 이슈에는 대응하지 못한다.

**값을 복제한다.**

- 소유권 이전이 문제가 되는 상황에 대해서 또 하나의 간단한 해결책은 값을 복제하는 것이고 크게 두가지 방법이 있다.
- `std::marker::Copy` 트레이트를 구현하고 있는 타입은 값이 복사되어 전달된다. 
  - 원시 타입과 같은 경우는 CPU 입장에서는 부하가 덜하다는 장점이 있어 보통 `Copy` 트레이트를 구현하고 있다.
  - 그래서 때로 몇몇 상황에서는 암묵적으로 수행된다는 특징이 있다.
  - 비트 대 비트 사본을 만들기 때문에, 비용이 싸고 값이 동일하다.
- `std::clone::Clone` 
  - 절대 암묵적일 수 없다. `clone()` 메서드를 호출해야 한다.
  - 느리고 비쌀 수 있으며, 정의하는 것에 따라서 원래 값과 달라질 수 있다.


**데이터를 특별한 타입으로 감싸기.**

`Rc<T>`는 기본적으로 아래와 같이 구현되어 있다.
(가장 핵심적인 부분과 그부분을 보기위해 필요한 부분만 정리했다.)

```rust
pub struct Rc<T> {
    ptr: NonNull<RcBox<T>>, // 실제 데이터에 대한 포인터, NonNull은 null이 아닌 포인터를 보장한다.
}

struct RcBox<T> {
    strong: Cell<usize>,    // Strong 참조 count
    weak: Cell<usize>,      // Weak 참조 count
    value: T,               // 실제 데이터
}
```

```rust
impl<T> Rc<T> {
    // RcBox<T>의 value를 가리키는 포인터를 반환
    fn inner(&self) -> &RcBox<T> {
        unsafe { self.ptr.as_ref() }
    }
}

impl<T> Clone for Rc<T> {
    #[inline]
    fn clone(&self) -> Rc<T> {
        unsafe {
            // strong 카운트 증가
            self.inner().inc_strong();
            Rc {
                ptr: self.ptr,
            }
        }
    }
}

impl<T> Drop for Rc<T> {
    fn drop(&mut self) {
        unsafe {
            if self.inner().dec_strong() == 0 {
                // strong 카운트가 0이 되면 value를 드롭
                ptr::drop_in_place(self.inner_mut().value_mut());
                // weak 카운트도 0이면, 메모리를 해제
                if self.inner().weak() == 0 {
                    deallocate(self.ptr.as_ptr() as *mut u8);
                }
            }
        }
    }
}
```

- 간단하게, `Rc<T>`는 `RcBox<T>`를 가리키는 포인터를 가지고 있고, `RcBox<T>`는 실제 데이터와 참조 카운트를 가지고 있다
- `Rc<T>`는 `Clone` 트레이트를 구현하고 있어서 `clone()` 메서드를 호출하면 참조 카운트를 증가시킨다.
- 그리고 `Drop` 트레이트를 구현하고 있어서 참조 카운트가 0이 되면 메모리를 해제한다.

`RefCell<T>`도 마찬가지로, 가장 핵심적인 부분과 그부분을 보기위해 필요한 부분만 정리했다.

```rust
pub struct RefCell<T: ?Sized> {
    value: UnsafeCell<T>,  // 내부 데이터 (UnsafeCell로 내부 변경 가능)
    borrow: Cell<isize>,   // 현재의 빌림 상태 (불변 빌림: 양수, 가변 빌림: -1)
}
```
