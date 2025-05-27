---
title: 코틀린 함수형 프로그래밍
summary: 
date: 2025-04-27 11:20:59 +0900
lastmod: 2025-05-27 12:56:32 +0900
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

### partition

```kotlin
inline fun <T> Iterable<T>.partition(
    predicate: (T) -> Boolean
): Pair<List<T>, List<T>> {
    val first = ArrayList<T>()
    val second = ArrayList<T>()
    for (element in this) {
        if (predicate(element)) {
            first.add(element)
        } else {
            second.add(element)
        }
    }
    return Pair(first, second)
}
```

- 조건에 맞는 것과 맞지 않는 것을 분리해서 Pair로 반환
- filter를 두 번 쓰는 것보다 효율적

```kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6)
val (even, odd) = numbers.partition { it % 2 == 0 }
// even: [2, 4, 6], odd: [1, 3, 5]
```

### groupBy

```kotlin
inline fun <T, K> Iterable<T>.groupBy(
    keySelector: (T) -> K
): Map<K, List<T>> {
    val destination = LinkedHashMap<K, MutableList<T>>()
    for (element in this) {
        val key = keySelector(element)
        val list = destination.getOrPut(key) { ArrayList<T>() }
        list.add(element)
    }
    return destination
}
```

- 키별로 그룹핑해서 Map으로 반환
- SQL의 GROUP BY와 비슷한 개념

```kotlin
data class Person(val name: String, val age: Int)

val people = listOf(
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 25)
)

val grouped = people.groupBy { it.age }
// {25=[Person(Alice, 25), Person(Charlie, 25)], 30=[Person(Bob, 30)]}
```

### associate 계열

```kotlin
inline fun <T, K, V> Iterable<T>.associate(
    transform: (T) -> Pair<K, V>
): Map<K, V> {
    val destination = LinkedHashMap<K, V>()
    for (element in this) {
        destination += transform(element)
    }
    return destination
}
```

- 컬렉션을 Map으로 변환
- associateBy, associateWith 등의 변형도 있음

```kotlin
val words = listOf("apple", "banana", "cherry")
val lengthMap = words.associate { it to it.length }
// {apple=5, banana=6, cherry=6}

val firstCharMap = words.associateBy { it.first() }
// {a=apple, b=banana, c=cherry}

val upperMap = words.associateWith { it.uppercase() }
// {apple=APPLE, banana=BANANA, cherry=CHERRY}
```

### distinct와 distinctBy

```kotlin
fun <T> Iterable<T>.distinct(): List<T> {
    return this.toMutableSet().toList()
}

inline fun <T, K> Iterable<T>.distinctBy(
    selector: (T) -> K
): List<T> {
    val set = HashSet<K>()
    val list = ArrayList<T>()
    for (e in this) {
        val key = selector(e)
        if (set.add(key)) {
            list.add(e)
        }
    }
    return list
}
```

- distinct: 중복 제거
- distinctBy: 특정 속성 기준으로 중복 제거

```kotlin
val numbers = listOf(1, 2, 2, 3, 3, 3)
println(numbers.distinct()) // [1, 2, 3]

val people = listOf(
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 25)
)
val distinctByAge = people.distinctBy { it.age }
// [Person(Alice, 25), Person(Bob, 30)] - 나이가 같은 Charlie는 제외
```

### take와 drop 계열

- take: 앞에서부터 n개 가져오기
- drop: 앞에서부터 n개 버리기
- takeWhile: 조건이 참인 동안 가져오기
- dropWhile: 조건이 참인 동안 버리기

```kotlin
val numbers = listOf(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)

println(numbers.take(3)) // [1, 2, 3]
println(numbers.drop(3)) // [4, 5, 6, 7, 8, 9, 10]

println(numbers.takeWhile { it < 5 }) // [1, 2, 3, 4]
println(numbers.dropWhile { it < 5 }) // [5, 6, 7, 8, 9, 10]
```

### zip

```kotlin
infix fun <T, R> Iterable<T>.zip(
    other: Iterable<R>
): List<Pair<T, R>> {
    return zip(other) { t1, t2 -> t1 to t2 }
}
```

- 두 컬렉션을 짝지어서 Pair의 리스트로 만듦
- 길이가 다르면 짧은 쪽에 맞춰짐

```kotlin
val names = listOf("Alice", "Bob", "Charlie")
val ages = listOf(25, 30, 35, 40)

val paired = names.zip(ages)
// [(Alice, 25), (Bob, 30), (Charlie, 35)] - 40은 버려짐

val formatted = names.zip(ages) { name, age -> "$name is $age years old" }
// ["Alice is 25 years old", "Bob is 30 years old", "Charlie is 35 years old"]
```

### 순서 관련 함수들

- sorted: 정렬 (Comparable 구현 필요)
- sortedBy: 특정 속성으로 정렬
- sortedWith: 커스텀 Comparator로 정렬
- reversed: 순서 뒤집기

```kotlin
val words = listOf("banana", "apple", "cherry")

println(words.sorted()) // [apple, banana, cherry]
println(words.sortedBy { it.length }) // [apple, banana, cherry] - 길이순
println(words.sortedWith(compareByDescending { it.length })) // [banana, cherry, apple]
println(words.reversed()) // [cherry, apple, banana]
```

### 검색 함수들

- find: 첫 번째로 조건에 맞는 원소 (없으면 null)
- first: 첫 번째 원소 (없으면 예외)
- firstOrNull: 첫 번째 원소 (없으면 null)
- any: 조건에 맞는 원소가 하나라도 있는지
- all: 모든 원소가 조건에 맞는지
- none: 조건에 맞는 원소가 하나도 없는지

```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

println(numbers.find { it > 3 }) // 4
println(numbers.first { it > 3 }) // 4
println(numbers.any { it > 3 }) // true
println(numbers.all { it > 0 }) // true
println(numbers.none { it < 0 }) // true
```

### 집계 함수들

- count: 원소 개수 (조건 있으면 조건에 맞는 개수)
- sum: 합계 (숫자 타입만)
- average: 평균 (숫자 타입만)
- min, max: 최솟값, 최댓값
- minBy, maxBy: 특정 속성 기준 최솟값, 최댓값을 가진 원소

```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

println(numbers.count()) // 5
println(numbers.count { it > 3 }) // 2
println(numbers.sum()) // 15
println(numbers.average()) // 3.0

val people = listOf(
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 20)
)
println(people.minBy { it.age }) // Person(Charlie, 20)
println(people.maxBy { it.age }) // Person(Bob, 30)
```

### 체이닝의 장점과 주의사항

- 함수형 스타일의 컬렉션 처리는 가독성이 좋고 실수가 적다
- 하지만 중간 컬렉션이 계속 생성되므로 성능에 주의해야 함
- 성능이 중요한 경우 시퀀스(sequence)를 고려해볼 것

```kotlin
// 매번 새로운 리스트가 생성됨
val result = (1..1000000)
    .filter { it % 2 == 0 }
    .map { it * 2 }
    .take(10)

// 지연 계산으로 성능 개선
val result2 = (1..1000000).asSequence()
    .filter { it % 2 == 0 }
    .map { it * 2 }
    .take(10)
    .toList()
```

## 시퀀스 (Sequence)

---
### 시퀀스의 특징

- 지연 계산(lazy evaluation)
- 중간 연산은 지연되고 종단 연산에서 실행
- 무한 시퀀스 생성 가능
- 메모리 효율적


```kotlin
// 컬렉션 방식 - 즉시 계산
val result1 = (1..100)
    .filter { it % 2 == 0 }  // 새로운 리스트 생성
    .map { it * 2 }          // 또 다른 새로운 리스트 생성
    .take(5)                 // 또 다른 새로운 리스트 생성

// 시퀀스 방식 - 지연 계산
val result2 = (1..100).asSequence()
    .filter { it % 2 == 0 }  // 아직 실행 안됨
    .map { it * 2 }          // 아직 실행 안됨
    .take(5)                 // 아직 실행 안됨
    .toList()                // 여기서 모든 연산이 한번에 실행
```

### 무한 시퀀스


```kotlin
val fibonacci = generateSequence(1 to 1) { (first, second) ->
    second to (first + second)
}.map { it.first }

val first10Fibonacci = fibonacci.take(10).toList()
// [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]
```

## 고차 함수 심화

---

### let, run, with, apply, also

```kotlin
// let - 객체를 it으로 받아서 블록 실행, 블록의 결과 반환
val result = "Hello".let { str ->
    str.uppercase() + " World"
} // "HELLO World"

// run - 객체를 this로 받아서 블록 실행, 블록의 결과 반환
val result2 = "Hello".run {
    uppercase() + " World"
} // "HELLO World"

// with - 객체를 this로 받아서 블록 실행, 블록의 결과 반환 (확장함수 아님)
val result3 = with("Hello") {
    uppercase() + " World"
} // "HELLO World"

// apply - 객체를 this로 받아서 블록 실행, 객체 자신을 반환
val person = Person("").apply {
    name = "Alice"
    age = 25
} // Person(name="Alice", age=25)

// also - 객체를 it으로 받아서 블록 실행, 객체 자신을 반환
val numbers = mutableListOf(1, 2, 3).also { list ->
    println("Original list: $list")
} // 리스트는 그대로, 로그만 출력
```

### takeIf와 takeUnless

```kotlin
// takeIf - 조건이 참이면 객체 반환, 거짓이면
val positiveNumber = (-5).takeIf { it > 0 } // null

// takeUnless - 조건이 거짓이면 객체 반환, 참이면 null
val notEmptyString = "".takeUnless { it.isEmpty() } // null

// 실용적인 예
fun processUser(user: User?): String {
    return user
        ?.takeIf { it.isActive }
        ?.let { "Processing user: ${it.name}" }
        ?: "User is inactive or null"
}
```
