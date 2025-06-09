---
title: 프로그래밍 러스트 💭
summary: 
date: 2025-06-07 12:45:57 +0900
lastmod: 2025-06-09 21:37:29 +0900
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



## Pattern
- 표현식은 값을 생산하고 패턴은 값을 소비한다.
```rust
let x = 5;
let y = x;        // y = x에서 x는 패턴, 5라는 값을 받아서 소비

match some_value {
    Some(data) => println!("{}", data),  // Some(data)는 패턴, 값을 받아서 분해
    None => println!("nothing"),         // None도 패턴
}

let (a, b) = (1, 2);  // (a, b)는 패턴, (1, 2) 튜플을 받아서 분해
```

- ref 패턴
```rust
struct Person {
    name: String,
    age: u32,
}

let person = Person {
    name: String::from("Alice"),
    age: 30,
};

match person {
    Person { ref name, age } => {
        println!("{} is {} years old", name, age);  // name은 &String, age는 u32
    }
}
// person.name은 이동되지 않았지만, person.age는 Copy라서 복사됨
```

```rust
enum BinaryTree<T> {
    Empty,
    NotEmpty(Box<TreeNode<T>>),
}

struct TreeNode<T> {
    element: T,
    left: BinaryTree<T>,
    right: BinaryTree<T>,
}

impl <T: Ord> BinaryTree<T> {
    fn add(&mut self, value: T) {
        match *self { 
            BinaryTree::Empty => {
                *self = BinaryTree::NotEmpty(Box::new(TreeNode {
                    element: value,
                    left: BinaryTree::Empty,
                    right: BinaryTree::Empty,
                }))
            }
            
            BinaryTree::NotEmpty(ref mut node) => {
                if value <= node.element {
                    node.left.add(value);
                } else {
                    node.right.add(value);
                }
            }
        }
    }
}

let mut tree = BinaryTree::Empty;
tree.add("Mercury");
tree.add("Venus");

```

## trait
- 러스트는 dyn Write 타입의 객체를 허용하지 않는다. 크기를 모르기 때문이다. (레퍼런스를 이용한다는 뜻)
- 러스트는 실행 시점 타입정보(v테이블)을 가르키는데 별도의 팻포인터를 사용하고 구조체에는 넣지 않기에, 타입 자체의 크기자 작아도 얼마든지 trait를 구현할 수 있다.

제네릭
- 기본적으로 사용처마다 각 타입에 대한 코드를 생성
- 런타임 오버헤드가 없음
- 컴파일 타임에 모든 타입이 결정됨
- 인라인 최적화 가능
- 코드 크기 증가 (code bloat)

트레이트 객체
- 런타임에 메서드 호출 결정 (약간의 성능 오버헤드)
- 다양한 타입을 하나의 컬렉션에 저장 가능
- 코드 크기가 작음
- Object Safety 규칙을 따라야 함

실제 동적으로 타입을 결정해야하는 상황이 있어 트레이트객체를 써야 할 때도 있다.
```rust
struct Salad {
	veggies: Vec<Box<dyn Vegetabls>>
}
```

- 위와 같은 경우 아니고, 제네릭의 코드량 증가가 부담스럽지 않다면 일반적으로 제네릭을 쓰는게 맞다고 한다.
	- 제네릭은 함수 호출을 최적화 하는데 필요한 모든 정보를 가지고 있다.
	- 반면 트레이트 객체는 실행시점에 알 수 있기 때문에, 동일한 객체를 전달해도 런타임에 가상 메서드 호출비용과 오류 검사 비용이 든다.
	- 그 외에도 다형성이나, 다중 상속 비스무리한 처리를 하기에도 제네릭이 훨씬 편하다
- 트레이트에서도 Self타입을 쓸 수 있다. 그러면 트레이트 객체로 만들 수 없다는 것이다.
- 사실 트레이트 객체는 자바의 인터페이스나 cpp의 추상 기본 클래스를 써서 구현할 수 있는 수준의 아주 단순한 트레이트를 위한 것이다.
- 러스트의 서브트레이트는 실제로 Self의 바운드에 대한 축약 표기에 불과하다.
```rust
trait Creature: Visible {
	...
}

trait Creature: where Self: Visible {
	...
}
```

- 다른언어의 인터페이스가 정적메서드나 생성자를 포함할 수 없지만, 트레이트는 러스트의 정적메서드라 할 수 있는 타입 연관 함수를 포함 할 수 있다.
```rust
trait StringSet {
    fn new() -> Self;
    fn from_slice(strings: &[&str]) -> Self;
    fn contains(&self, string: &str) -> bool;
    fn add(&mut self, string: &str);
}

fn unknown_words<S: StringSet>(document: &[String], wordlist: &S) -> S {
    let mut unknowns = S::new();
    for word in document {
        if !wordlist.contains(word) {
            unknowns.add(word);
        }
    }
    unknowns;
}

```
- 트레이트 객체에서는 마찬가지로 타입 연관 함수는 쓸 수 없다.
```rust
trait StringSet {
    fn new() -> Self
    where
        Self: Sized;
    fn from_slice(strings: &[&str]) -> Self
    where
        Self: Sized;
    fn contains(&self, string: &str) -> bool;
    fn add(&mut self, string: &str);
}
```
- 이런식으로 제약해두면 타입 연관 함수가 아닌 함수들은 사용이 가능하다

- to_string은 ToString 트레이트의 to_string 메서드를 가르킴, 여기서는 str타입의 구현을 호출
```rust
"hello".to_string();
```
- 이 시점에서 개입된건 트레이트, 트레이트 메서드, 트레이트 메서드의 구현, 이 구현이 적용되는 값 총 네개이다.
- 이걸 구체화 하는 예시
```rust
// str 타입 연관함수의 self 자리에 직접 넣어서 호출
str::to_string("hello");  
// ToString 트레이트의 to_string 메서드를 직접 호출 컴파일러가 "hello"의 타입(str)을 보고 적절한 구현을 찾음
ToString::to_string("hello");
// str 타입의 ToString 트레이트 구현을 명시적으로 지정해서 호출 가장 구체적인 호출 방식
<str as ToString>::to_string("hello);
```
- 밑에서 두번째는 qualified 호출이라고 하며, 마지막은 fully qualified 호출이라고 함.

위에가 필요한 억지스러운 예시
```rust
// outlaw가 Visible, HasPistol trait를 구현한 구현체일때 각 트레이트에 fn draw(&self)가 있다면
outlaw.draw(); // err

Visible::draw(&outlaw);
HasPistol::draw(&outlaw);
```

조금 더 자연스러운 예시들
```rust
let zero = 0; // i8? u8? usize? ...
zero.abs(); // err
i64::abs(zero);
```

- 트레이트는 타입 간의 관계를 기술할 수 있어서 여러 타입이 맞물려 돌아가야 하는 상황에도 쓰일 수 있다. 여기서 중요한 점은 트레이트와 메서드 시그니처를 읽고 이들과 관련된 타입에 대해서 어떤 말을 하고 있는지 파악하기 위해서 이부분을 알야야 한다는 것이다.
```rust
pub trait Iterator {
	type Item;

	fn next(&mut self) -> Option<Self::Item>;
}

impl Iterator for Args {
	type Item = String;

	fn next(&mut self) -> Option<String> {}
}

fn collect_into_vector<I: Iterator>(iter: I) -> Vec<I::Item> {
	let mut results = Vec::new();
	for value in iter {
		results.push(value);
	}
	results
}
```

```rust
fn dump<I>(iter: I)
	where I: Iterator
{
	for (index, value) in iter.enumerate() {
		println!("{}: {:?}", index, value); // err
	}
}

fn dump<I>(iter: I)
	where I: Iterator, I::Item: Debug`
{
	for (index, value) in iter.enumerate() {
		println!("{}: {:?}", index, value);
	}
}

// 혹은 
fn dump<I>(iter: I)
	where I: Iterator<Item=String>

// 트레이트 객체를 사용하고 싶다면
fn dump(iter: &mut dyn Iterator<Item=String>) {
	for (index, s) in iter.enumerate() {
		println!("{}: {:?}", index, s);
	}
}
```
- 위처럼 이터레이터가 가장 대표적인 예시지만, 스레드풀 라이브러리에서의 Task가 Output과 같은 연관타입을, Pattern 트레이트가 Match를 , RDB를 다루는 라이브러리가 DatabaseConnection을 가지는 것처럼 트레이트가 단순히 메서드의 모음 이상의 역할을 할 때 늘 유용하다.
- 다만 이렇게 하나의 산출물만 나오는것처럼 행복하게 풀리는 것은 아니다
- 러스트에서 곱셈은 다음의 트레이트를 통해 수행된다.
```rust
/// std::ops::Mul, '*'를 지원하는 타입을 위한 트레이트.
pub trait Mul<RHS> {
	/// * 연산자를 적용하고 난 뒤의 결과 타입.
	type Output;
	/// * 연산자를 위한 메서드.
	fn mul(self, rhs: RHS) -> Self::Output;
}
```
- 제네릭 트레이트에는 고아 규칙에 특별 허가권이 부여된다. 트레이트의 타입 매개변수가 현재 크레이트에 정의된 타입을 하나라도 포함할 때는 외부 타입에 대해서 외부 트레이트를 구현할 수 있다는게 그것이다.
- 이게 통하는 이유는 다른 크레이트에서 정의할 방법이 없어 구현간에 충돌이 발생할 수 없기 때문이다.
```rust
// 예를 들어, 내 크레이트에서 이런 건 불가능
impl std::fmt::Display for Vec<i32> {  // 에러!
    // Vec도 외부 타입, Display도 외부 트레이트
}

// 다른 크레이트에서 정의된 타입들
struct ExternalTypeA;
struct ExternalTypeB;

// std에 정의된 Mul 트레이트 (외부 트레이트)
// 이건 원래 안 됨 (외부 타입 + 외부 트레이트)
impl Mul<ExternalTypeB> for ExternalTypeA {  // 에러!
    type Output = i32;
    fn mul(self, rhs: ExternalTypeB) -> i32 { 42 }
}

// 내 크레이트에서 정의한 타입
struct MyType;

// 이건 가능! (MyType이 타입 매개변수에 포함됨)
impl Mul<MyType> for ExternalTypeA {  // 가능!
    type Output = i32;
    fn mul(self, rhs: MyType) -> i32 { 42 }
}

// 또는 이것도 가능!
impl Mul<ExternalTypeB> for MyType {  // 가능!
    type Output = i32;
    fn mul(self, rhs: ExternalTypeB) -> i32 { 42 }
}
```

- 많은 제네릭타입을 조합하면 흉물스러워진다.
```rust

fn cyclical_zip(v: Vec<u8>, u: Vec<u8>) ->
	iter::Cycle<iter::Chain<IntoIter<u8>, IntoIter<u8>>> {
	v.into_iter().chain(u.into_iter()).cycle()
}
```

1. `IntoIter<u8>`
```rust
v.into_iter()  // Vec<u8> → IntoIter<u8>
u.into_iter()  // Vec<u8> → IntoIter<u8>
```
- `std::vec::IntoIter<u8>`의 줄임말
- 벡터를 소비해서 소유권을 가진 반복자로 변환

2. `iter::Chain<IntoIter<u8>, IntoIter<u8>>`
```rust
v.into_iter().chain(u.into_iter())
```
- `std::iter::Chain<std::vec::IntoIter<u8>, std::vec::IntoIter<u8>>`
- 두 반복자를 연결해서 하나의 반복자로 만듦
- 첫 번째 반복자의 모든 요소를 먼저 순회하고, 그 다음 두 번째 반복자 순회

3. `iter::Cycle<iter::Chain<IntoIter<u8>, IntoIter<u8>>>`
```rust
v.into_iter().chain(u.into_iter()).cycle()
```
- `std::iter::Cycle<std::iter::Chain<std::vec::IntoIter<u8>, std::vec::IntoIter<u8>>>`
- Chain 반복자를 무한히 반복하는 반복자로 변환

```rust
fn cyclical_zip(v: Vec<u8>, u: Vec<u8>) -> impl Iterator<Item=u8>
```

## 연산자 오버로딩
- 이번 장의 목표는 여러분이 자신의 타입을 언어에 잘 통합하도록 돕는 것 뿐 아니라, 연산자를 통해 쓰이는 타입에 가장 자연스럽게 작용하는 제네릭 함수를 작성하는 법에 관한 더 나은 감각을 전해 주는 것이다.
> 여긴 일단 가볍게 읽기만, 뭔가 인사이트보다는 레퍼런스에 가까운 장인 것 같다, 다른 장들보다 훨씬 인사이트가 적었던 것 같아 읽기는 힘들었다.

## 유틸리티 트레이트
