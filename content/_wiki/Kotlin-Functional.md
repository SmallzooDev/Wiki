---
title: 코틀린 함수형 프로그래밍
summary: 
date: 2025-04-27 11:20:59 +0900
lastmod: 2025-05-10 16:13:55 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 함수 타입
---
### 함수 타입 정의
- (T) -> Boolean : Boolean을 반환하는 함수 Predicate
- (T) -> R : 값 하나를 다른 값으로 변환하는 함수 transfrom
- (T) -> Unit : Unit을 반환하는 함수 operation

### 함수 타입 활용
- invoke라는 단 하나의 메서드만 제공함, 명시적 invoke호출과 ()연산자로 호출
- 함수타입 파라미터를 ()? 로 감싸서 널러블함을 표현할 수 있음 (이경우는 명시적 invoke만 가능)

### named parameter
- 함수 타입을 정의 할 때 'named parameter'를 사용 가능
- 오직 개발 편의를 위한 것

## 익명 함수
---

- 익명함수는 함수 타입 객체를 반환하는 표현식
- generic, default parameter는 지원하지 않음
```kotlin
val add2 = fun(a: Int, b: Int) = a + b
```
- 익명함수 자체는 요즘 사용하지 않는다고 함
	- 람다가 더 짧고 지원이 더 잘됨
	- 인텔리제이는 람다만 힌트를 제공
- 그래도 아래와 같은 상황에는 아직 유용
	- return 범위 명확히 구분하고 싶을 때
	- 타입 명시적 선언 (람다보다 깔끔)
	- return을 명시적으로 사용해야 할 때
	- 고차함수 인자가 2개 이상이고 복잡할 때

## 람다 표현식
---
>코틀린에서 람다 표현식(lambda expression)은 return을 허용하지 않는 이유는, 람다가 그 자체로 “독립적인 실행 흐름”을 갖는 함수가 아니라, “호출되는 컨텍스트에 의존하는 작은 코드 블록”이기 때문입니다. 즉, 람다 안에서 return을 자유롭게 허용해버리면, 람다를 호출하는 “바깥 함수” 전체의 흐름까지 예측 불가능하게 망칠 수 있기 때문에, 명확한 제약을 둔 것입니다.

- 익명함수보다 더 짧은 대안
- 람다 표현식이 더 많은 기능을 지원

| **항목**    | **익명 함수 (anonymous function)**     | **람다식 (lambda expression)**           |
| --------- | ---------------------------------- | ------------------------------------- |
| 작성 방식     | fun 키워드 사용                         | { 파라미터 -> 본문 } 형태                     |
| return 동작 | 로컬 return (해당 함수만 빠져나감)            | 기본적으로 바깥 함수로 비탈출(non-local return) 가능 |
| 타입 추론     | 명확한 타입 명시 가능                       | 타입 추론 많이 의존                           |
| 제어문 사용    | return, break, continue 자유롭게 사용 가능 | 제한 있음 (non-local return 조심)           |
> 함수를 나타내는 객체가 결괏값으로 생성되는 표현식을 함수 리터럴이라 한다


- 타입 추론을 잘 이용하는게 좋다.
- 람다의 변수명에 타입을 명시, 혹은 람다 작성시 타입을 명시해서 타입추론을 잘 하게 만드는게 좋다
- it 키워드를 이용하기에도 도움이 된다.
- 그 외에는 후행람다와 같은 간단한 문법 정의 이야기이다.

## 함수 참조
---
> 객체로 사용할 수 있는 함수가 필요하다면 람다 표현식으로 새로운 객체를 생성할 수도 있지만, 기존의 함수를 참조할 수도 있습니다.

- `::` 또는 `Receiver::` 로 함수 참조가 가능
```kotlin
class Complex(
    val real: Double,
    val imaginary: Double,
)

fun main() {
    val complex: ()-> Complex = ::makeComplex
    val complex2: (Double)-> Complex = ::makeComplex
    val complex3: (Double, Double)-> Complex = ::makeComplex
}

fun makeComplex(
    real: Double = 0.0,
    imaginary: Double = 0.0
) = Complex(real, imaginary)

```
- 최신버전에는 디폴트파라미터들도 다 고려해서 타입정의를 허용해주는 것 같다.
- 메소드를 참조하는경우 리시버를 명시해줘야함
```kotlin
data class Complex(val real: Double, val imaginary: Double) {
    fun doubled(): Complex =
        Complex(this.real * 2, this.imaginary * 2)

    fun times(num: Int) =
        Complex(real * num, imaginary * num)
}

fun main() {
    val c1 = Complex(1.0, 2.0)
    val f1: (Complex) -> Complex = Complex::doubled
    println(f1(c1)) // Complex(real=2.0, imaginary=4.0)
    val f2: (Complex, Int) -> Complex = Complex::times
    println(f2(c1, 4)) // Complex(real=4.0, imaginary=8.0)


```
- 메서드 참조는 프로퍼티가 아닌 타입을 이용해야함 (제네릭 타입 명시 포함)
```kotlin
val func = list.sum // err
val func: (List<Int>) -> Int = List<Int>::sum
```
- 한정된 함수 참조(bound reference)를 쓰고 싶으면 리시버 객체를 고정해서 참조할 수 있다.
- 이때는 타입::메서드 형태가 아니라 **객체::메서드** 형태로 작성해야 한다.
- 이렇게 하면 리시버를 따로 넘기지 않고, 나머지 인자만 받는 함수처럼 쓸 수 있다.
```kotlin
val c1 = Complex(1.0, 2.0)

val f3: () -> Complex = c1::doubled
println(f3()) // Complex(real=2.0, imaginary=4.0)

val f4: (Int) -> Complex = c1::times
println(f4(3)) // Complex(real=3.0, imaginary=6.0)
```

- Complex::doubled은 (Complex) -> Complex였는데
- c1::doubled는 () -> Complex로 바뀜. (리시버가 고정됐으니까 인자를 따로 받을 필요가 없어짐)
- Complex::times는 (Complex, Int) -> Complex였는데
- c1::times는 (Int) -> Complex로 변함. (리시버인 c1이 이미 채워진 상태)

요약하면,

> **타입::메서드** → 리시버를 따로 받아야 함
> **객체::메서드** → 리시버가 고정돼 있어서 나머지 인자만 받음

```kotlin
// MainPresenter는 view를 가지고 있음
class MainPresenter(
    private val view: MainView,
    private val repository: MarvelRepository
) : BasePresenter() {

    fun onViewCreated() {
        // getAllCharacters()는 Single<List<MarvelCharacter>>를 반환한다고 가정
        subscriptions += repository.getAllCharacters()
            .applySchedulers()
            .subscribeBy(
                // onSuccess에 this::show 넘김
                // => subscribeBy가 데이터를 넘겨줄 때, this.show(items)로 호출
                onSuccess = this::show,
                onError = view::showError
            )
    }

    // 이 show 함수는 List<MarvelCharacter>를 받아서 view에 넘김
    fun show(items: List<MarvelCharacter>) {
        view.show(items)
    }
}
```

- subscribeBy는 그냥 콜백 함수를 저장해두고 나중에 호출
- subscribeBy는 그 콜백 함수(this::show)가 어떤 객체(this)를 품고 있는지 몰라도 됨
- this::show는 **이미 MainPresenter 인스턴스에 바인딩되어 있는 함수 참조**라서,subscribeBy가 단순히 onSuccess(data) 이렇게 호출만 하면, 내부적으로는 **this.show(data)** 가 실행되고,그 안에서 자연스럽게 **this.view.show(data)** 같은 것도 정상 접근 가능하다.


## 컬렉션 처리
---
> 컬렉션 처리는 프로그래밍에서 가장 빈번하게 일어나는 작업 중 하나이자, 수십년동안 함수형 프로그래밍의 주요 셀링포인트 였습니다.
> 리스프 프로그래밍 언어의 뜻 또한 list processing이다.

### forEach와 onEach
```kotlin

inline fun <T> Iterable<T>.forEach(action: (T) -> Unit) {
	for (element in this) action(element)
}

inline fun <T, C:Iterable<T>> C.onEach(
	action: (T) -> Unit
): C {
	for (element in this) action(element)
	return this
}
```
- forEach -> Unit
- onEach -> 이터러블 반환 (체이닝)
```kotlin

users.
	.filter { it.isActive }
	.onEach { log("Sending Msg gor user $it") }
	.flatMap { it.remainingMessages }
	.filter { it.isTobeSent }
	.forEach { sendMessage(it) }

```

### filter
```kotlin

inline fun <T> Iterable<T>.filter(
	predicate: (T) -> Boolean
): List<T> {
	val destination = ArrayList<T>()
	for (element in this) {
		if (predicate(element)) {
			destination.add(element)
		}
	}
}
```
- 현실의 필터와는 다르게 맞는것들만 걸러줌
- 저자는 "predicate에 맞지 않는 원소들을 거르는 필터"라 생각하면 직관적이라고 함
### map
```kotlin
inline fun <T, R> Iterable<T>.map(
	transform: (T) -> R
): List<R> {
	val size = if (this is Collection<*>) this.size else 10
	val destination = ArrayList<R>(size)
	for (element in this) {
		destination.add(transform(element))
	}
}
```
- 동일 크기의 컬렉션을 반환
- 성능이 중요한 경우 mapNotNull을 사용

### flatMap
```kotlin
inline fun <T, R> Iterable<T>.flatMap(
	transform: (T) -> Iterable<R>
): List<R> {
	val size = if (this is Collection<*>) this.size else 10
	val destination = ArrayList<R>(size)
	for (element in this) {
		destination.addAll(transform(element))
	} 
	return destination
}
```

### fold
```kotlin
inline fun <T, R> Iterable<T>.fold(
	initial: R,
	operation: (acc: R, T) -> R
): R {
	var accumulator = initial
	for (element in this) {
		accumulator = operation(accumulator, element)
	}
	return accumulator
}
```
- 누산기
- reduce와 다르게 초기값을 지정
- 가장 만능이지만, 직접 사용할일은 적음 (fold를 래핑한 연산들이 거의 다 제공됨)

### withIndex와 인덱스된 변형 함수들
```kotlin
fun <T> Iterable<T>.withIndex(): Iterable<IndexedValue<T>> = IdexingIterable { iterator() }

data class IndexedValue<out T>(
	val index: Int,
	val value: T
)
```

```kotlin
fun main() {
	listOf("A", "B", "C", "D") // List<String>
		.withIndex() // List<IndexedValue<String>>
		.filter { (index, value) -> index % 2 == 0 }
		.map { (index, value) -> "[$index] $value" }
		.forEach { println(it) }
}

// [0] A
// [2] C
```
