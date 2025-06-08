---
title: 프로그래밍 러스트 💭
summary: 
date: 2025-06-07 12:45:57 +0900
lastmod: 2025-06-08 20:16:48 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

> 모든 내용 출처는 : [프로그래밍-러스트](https://product.kyobobook.co.kr/detail/S000200629958?utm_source=google&utm_medium=cpc&utm_campaign=googleSearch&gt_network=g&gt_keyword=&gt_target_id=aud-901091942354:dsa-435935280379&gt_campaign_id=9979905549&gt_adgroup_id=132556570510&gad_source=1)
## 타입 관련

- 길이는 타입의 일부, 슬라이스는 길이 제한이 없으므로 변수에 직접 저장하거나 함수 인수로 전달할 수 없다.
- 슬라이스 레퍼런스는 팻 포인터로 슬라이스의 첫 번째 요소를 가리키는 포인터와 그 안에 있는 요소의 개수로 구성되는 2워드 크기의 값이다.


## 이동 관련
- 러스트에서는 모든 이동이 원본을 미초기화 상태로 두는 바이트 단위의 얕은 복사다.
- 복사는 원본의 초기화 상태를 유지한다는 점만 제외하면 이도오가 똑같다.
- 이동과 레퍼런스 카운트 기반의 포인터는 소유 관계 트리의 경직성을 완화하는 두가지 방법이다.


## 참조 관련
- cpp의 역참조는 암시적으로 이루어지고, 러스트의 역참조는 명시적으로 이루어진다. 하지만 `.`연산은 암시적 역참조를 해준다.
- 특히나 `.`연산자는 피연산자의 암묵적으로 피연산자의 레퍼런스를 차용할 수 있다.

## 라이프타임 관련
- 변수의 수명은 자신에게서 차용된 레퍼런스의 수명을 포함(contain)하거나, 에워싸야(enclose)한다.
- 또 다른 제약 조건은, 변수에 레퍼런스를 저장할 때, 레퍼런스의 타입이 변수의 전체 수명, 즉 변수가 초기화되는 지점부터 마지막으로 사용되는 지점까지 내내 유효해야한다는 것이다.
![rustlifetime](https://github.com/user-attachments/assets/d319448b-dfe6-4e12-844a-ca5c2ad77afe)
- `f(p: &'static i32)` : 레퍼런스를 전역변수에 담아두려는 의도를 시그니처에 드러내지 않고서는 원하는 행동을 할 수 없다.
- 반대로 `f<'a>(p: &a' i32)` : 인수 p가 함수의 호출 구간보더 더 긴 수명을 가진 어딘가에 보관되는 일이 없다는 걸 알 수 있다.

![lifetimerust](https://github.com/user-attachments/assets/f8cd7d24-0a80-4af7-b667-bf277889c032)

## 표현식
- 이 말은 러스트가 모든 일을 표현식으로 해내는 리스프의 오랜 전통을 따른다는 뜻이다.
- if let 표현식은 match의 축약 표기이다.
```rust
if let pattern = expr {
	block1
} else {
	block2
}


match expr {
	pattern => { block },
	_ => { block2 }
}
```
- for 루프는 iterable 표현식을 '평가'한 뒤에 그 결과로 얻은 이터레이터의 개별 값에 대해서 한 번 씩 block을 평가한다.
러스트에 loop가 있는 이유
- 컴파일러는 여러 측면에서 제어흐름을 검사하고, 이걸 flow-sensitive 분석이라고 한다.
	- 함수의 모든 경로가 예정된 반환타입의 값을 반환하는지 검사한다. (함수의 끝에 도달하는것이 가능한지 아닌지 알아야 한다.)
	- 지역변수가 초기화되지 않은 채로 쓰이는 일이 없는지 검사한다. (초기화 코드를 거치지 않고서 변수가 쓰이는 곳에 도달할 길이 없음을 확인하는 작업이 수반된다)
	- 도달할 수 없는 코드에 대해서 경고를ㄹ 내보댄다.

- 문제는 이러한 검사를 얼마나 smart하게 할 것 인지, 혹은 simple하게 할 것 인지에 대해서 균형을 잘 맞춰야 한다.
	- smart : 100% 안전한 프로그램을 거부하거나 잘못된 경고를 보내는 일이 사라진다.
	- simple : 컴파일러가 이야기하는 내용을 프로그래머가 쉽게 파악할 수 있다.

```rust
// 가짜 오류
fn wait_for_process(process: &mut Process) -> i32 {
	while true {
		if process.wait() {
			return process.exit_code();
		}
	}
	// 100% 안전하다. 무조건 while 내부의 return문에서만 반환한다. 하지만 i32반환을 요구한다.
}
```
1. 절대 탈출하지 않는 반복을 명시적으로 표현할 수 있다.
    - 일반적인 while true 루프는 이론상 무한 루프지만, Rust 컴파일러는 true가 상수인지, 조건이 언제든 false가 될 수 있는지 등을 분석해야 한다. 이 과정에서 앞서 언급한 flow-sensitive 분석이 복잡해진다.
2. 컴파일러에게 “여기서 끝나지 않고, 반드시 반복하거나 중간에 return/break로만 빠져나간다”는 점을 명확히 알릴 수 있다.
    - 위의 wait_for_process 예제에서처럼 while true로는 컴파일러가 “이 함수는 반드시 i32를 반환한다”는 점을 확신할 수 없다.
    - 반면, 다음과 같이 loop를 사용하면 컴파일러는 이 블록이 절대 끝까지 도달하지 않는다는 점을 확정할 수 있고, 함수가 항상 값을 반환한다는 사실도 확신할 수 있다.
```rust
fn wait_for_process(process: &mut Process) -> i32 {
    loop {
        if process.wait() {
            return process.exit_code();
        }
    }
}
```
- 비슷한 예시로 `!`타입이 있다. (일탈함수) -> 요건 코틀린의 Nothing타입이랑 매우 비슷하다.
- 러스트는 `Vec<T>`와 같이 제네틱타입에서는 일반적인 함수 메서드호출 문법을 막는다.
- 이건 표현식에서 `<`가 미만으로 쓰이기 때문인데, `::`연산자를 써줘야 한다.
```rust
return Vec<i32>::with_capacity(1000); // err
let ramp = (0 .. n).collect<Vec<i32>>(); // err


return Vec::<i32>::with_capacity(1000); // turbofish
let ramp = (0..n).collect::<Vec<i32>>(); // turbofish

// 아니면
return Vec::with_capacity(10); // 함수의 시그니처를 통해 추론, 생략
let ramp: Vec<i32> = (0..n).collect(); // 변수 타입지정으로 추론, 생략
```

## 오류 처리
- 일상적인 오류는 Result로 처리한다. 버그가 없는 프로그램조차도 마주하는 문제들을 표현한다.
- 패닉은 반대로 절대로 발생해서는 안 되는 오류를 위한 것이다.

### panic
- 발생하면, 
	- 패닉이 발생한 지점의 스택을 덤프해준다.
	- 스택이 해제된다.
	- 현재 함수가 쓰던 임시값, 지역변수, 인수는 생성된 순서와 반대로 드롭된다.
	- 현재 함수가 다 정리되면 호출부로 이동해서 동일한 일을 반복한다.
	- 반복하다가 스택 끝에 도달하면 스레드가 종료된다.
	- 메인스레드였다면 프로세스를 종료한다.
- 즉 패닉은 이렇게 규칙적인 과정에 어울리지 않는 이름일지도 모른다. 패닉은 크래시도, 미정의 동작도 아니며 오히려 RuntimeException에 가깝다.
- 동작은 잘 정의되어 있다. 단지 발생하면 안 될 뿐이다.
- 심지어 `std::panic::catch_unwind()`를 쓰면 스택 해제를 잡아서 스레드를 살릴수도 있다.
- 그런데 첫번째 패닉을 정리하던중 .drop()이 두번째 패닉을 유발하면 러스트는 해제를 멈추고 전체 프로세스를 중단시킨다.

### result
- 러스트는 예외가 없고 그걸 result가 대신한다.
- 기본적으로 match 표현식으로 대응하는데, 이게 try-catch역할을 한다.
- 그러나 match는 불필요하게 장황한 경우가 있어 다양한 메서드를 지원한다.
- result.is_ok(), result.is_err() : 성공 결과 여부 bool 반환
- result.ok() : option t 변환
- result.err() : option e 변환
- result.unwrap_or(fallback) : 성공일경우 결과, 아니면 fallback
- result.unwrap_or(fallback_fn) : 성공일경우 결과, 아니면 fallback함수의 결과값 (함수 혹은 클로저를 받음)
- result.unwrap() : 성공일경우 결과, 아니면 패닉
- result.expoect(message) : 성공일경우 결과, 아니면 메세지를 포함하는 패닉
- result.as_ref(), result.as_mut = 레퍼런스, 혹은 변경가능 레퍼런스를 빌려온다.
- 마지막 두 메서드가 중요한 이유는 나머지는 전부 result를 소비한다는 것이다.

```rust
result.as_ref().ok() // Option<&T>
```

## 모듈
- 모듈은 프로젝트 내부의 코드 구성에 관한 것
- 모듈은 아이템의 집합체이다. 아이템이란 '이름이 있는 기능을 말한다.'
- `pub(crate)`는 크레이트 내부 어디서든 사용할 수 있지만, 외부 인터페이스의 일부로 노출하지는 않겠다는 뜻
- 아이템을 pub으로 표기하는걸 내보내기라고 한다.

```rust
mod plant_structures {  
    pub mod roots {  
        pub mod products {  
            pub(in crate::plant_structures::roots) struct Cytokinin {  
               // ...   
        }        use products::Cytokinin; // Ok: roots 모듈 안에서는 문제 없다.  
    }  
    use crate::plant_structures::roots::products::Cytokinin; // Err: cytokinin은 비공개다.  
}  
  
use plant_structures::roots::products::Cytokinin; // Err: 비공개
```
ㅐ

## 스트럭트
- 기본적으로 포인터타입에게서 레퍼런스를 자동으로 빌려오기때문에, &self, &mut self정도면 거의 잘 동작한다
```rust
struct Queue {
    data: Vec<char>,
}

impl Queue {
    fn new() -> Self {
        Queue { data: vec![] }
    }

    fn push(&mut self, c: char) {
        self.data.push(c);
    }
}

fn main() {
    let mut bq = Box::new(Queue::new());
    bq.push('a'); // OK: Box<T>는 DerefMut 있어서 자동으로 bq -> *bq -> &mut Queue
}
```
- 그러나 어떤 메서드가 Self 포인터의 소유권을 필요로하는데 때 마침 그의 호출부가 그러한 포인터를 가지고 있다면, 러스트는 이를 그 메서드의 self 인수로 넘길 수 있게 해준다. (타입명시는 필요)
```rust
use std::rc::Rc;

struct Node {
    children: Vec<Rc<Node>>,
}

impl Node {
    // 이 메서드는 Rc<Node>의 소유권이 필요함
    fn append_to(self: Rc<Self>, parent: &mut Node) {
        parent.children.push(self); // self를 parent의 children에 추가
    }
}

fn main() {
    let mut parent = Node { children: vec![] };
    let child = Rc::new(Node { children: vec![] });
    
    // child는 Rc<Node> 타입
    // append_to 메서드는 self: Rc<Self>를 받음
    // 러스트가 이를 자동으로 매칭시켜줌
    child.append_to(&mut parent);
}
```


- 상수 매개변수를 갖는 제네릭 스트럭트도 있다.
```rust
struct Polynomial<const N: usize> {
    coefficients: [f64; N],
}

impl<const N: usize> Polynomial<N> {
    fn new(coefficients: [f64; N]) -> Polynomial<N> {
        Polynomial { coefficients }
    }

    fn eval(&self, x: f64) -> f64 {
        let mut sum = 0.0;
        for i in (0..N).rev() {
            sum = self.coefficients[i] + x * sum;
        }
        sum
    }
}

```

- 다른 종류의 제네릭의 순서는 아래와 같다
```rust
struct LumpOfReferences<'a, T, const N: usize> {
	the_lump: [&'a, T; N]
}
```
