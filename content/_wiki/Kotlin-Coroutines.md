---
title: 코틀린 코루틴 👾
summary: kotlin coroutines 책 정리
date: 2025-04-28 16:58:11 +0900
lastmod: 2025-05-29 17:17:33 +0900
tags:
  - Kotlin
  - Cpp
categories: 
description: 
showToc: true
tocOpen: true
---




## 3장 중단은 어떻게 작동할까?
- 중단 함수는 코틀린 코루틴의 핵심이다.
- 중단이 가능하다는 것 자체가 코루틴의 다른 모든 개념의 기초가 된다.
- 말 그대로 중단을 의미하며, 스레드와의 다른점은 스레드는 저장이 불가능하고 멈추기만 한다는 것.

> 운영체제 수준에서 스레드가 재개될 때는, 직전에 실행하던 지점의 스택과 레지스터 상태를 복원해서 정확히 거기서부터 다시 실행한다. 하지만 말 그대로 운영체제 수준인 것이며 코루틴처럼 중단 지점과 상태에 대해서 프로그래머가(언어 런타임에서) 개입 할 수 없다. 예를들어 중단된 코루틴이 다른 스레드에서 시작되는것을 보면 이해가 쉽다 


> 즉 스레드는 시스템 레벨에서 자동으로 처리되는 블랙박스이며, 코루틴의 suspend는 개발자와 언어 런타임이 함께 만든 제어 가능한 컨트롤 플로우이다.

> 실제로 Thread.suspend()와 Thread.resume()같은 인터페이스도 있긴 했지만, deprecated 🤪

멈추는것은 실제로 아래와 같이 동작한다.
```kotlin
suspend fun main() {
    println("Before")
    suspendCoroutine<Unit> { continuation ->
        println("Before too")
    }
    println("After")
}
```
- suspendCoroutine 함수를 통해서 프로그램을 멈춘다.
- 인자로 람다를 받으며 해당 람다는 중단되기 전에 실행된다.
- 해당 람다함수는 Conituation을 인자로 받는다.
- 해당 람다함수는 Continuation객체를 저장한 뒤 코루틴을 다시 실행할 시점을 결정하기 위해 사용된다.

> 참고 : resume과 resumeWith이 원래 인터페이였지만, 1.3 이후로 resumeWith만 남게 되었고, 기존 인터페이스는 Continuation을 수신객체로 하는 확장함수가 되었다.
```kotlin
inline fun <T> Countinuation<T>.resume(value: T): Unit =
    resumeWith(Result.success(value))

inline fun <T> Continuation<T>.resumeWithException(exception: Throwable): Unit =
    resumeWith(Result.failure(exception))
```

### 재개의 기준이 시간인 경우

- 아래처럼 Thread를 써서 1초를 카운트 할 수 있긴 하다.
```kotlin
fun continueAfterSecond(continuation: Continuation<Unit>) {
    thread {
        Thread.sleep(1000) // 스레드가 생성되고 1초만 세고 다시 사라짐
        continuation.resume(Unit)
    }
}

suspend fun main() {
    println("Before")
    suspendCoroutine<Unit> {
        continueAfterSecond(it)
    }
}
```
- 이건 위의 주석에 적어둔 것처럼 비용이 발생하는 스레드를 생성하고 1초뒤에 사라지게 두는게 아깝다
- 그래서 jvm이 제공하는 ScheduledExecutorService를 사용 할 수 있다.

```kotlin
private val executor =
    Executors.newSingleThreadScheduledExecutor {
        Thread(it, "scheduler").apply { isDaemon = true }
    }
suspend fun delay(timeMillis: Long): Unit =
    suspendCoroutine { cont ->
        executor.schedule({
            cont.resume(Unit)
        }, timeMillis, TimeUnit.MILLISECONDS)
    }
suspend fun main() {
    println("Before")
    delay(1000)
    println("After")
}
```
- 물론 스레드를 사용하기는 하지만, delay함수를 사용하는 모든 코루틴이 가지는 전용 스레드이다. (만들고 재사용)


### 재개의 기준이 값인 경우
```kotlin
suspend fun main() {
    val i: Int = suspendCoroutine<Int> { cont ->
        cont.resume(42)
    }

    val str: String = suspendCoroutine<String> { cont ->
        cont.resume("Some text")
    }
}
```
- 위처럼 제네릭으로 넘긴 타입파라미터에 해당하는 값을 resume() 하면서 호출 할 수 있다.

```kotlin
suspend fun main() {
    println("Before")
    val user = suspendCoroutine<User> { cont ->
        requestUser { user ->
            cont.resume(user)
        }
    }
    println(user)
    println("After")
}
```
- requestUser가 io를 발생시키는데 io동안 블로킹 되지 않고 다른일을 하다가 값이 반환되는 시점에 중단한 함수를 재개한다.
```kotlin
suspend fun requestUser(): User {
    return suspendCancellableCoroutine<User> { cont ->
        requestUser { user ->
            cont.resume(user)
        }
    }
}
```
- 위 코드처럼 중단함수는 분리해서 두는게 유용하다.

### 예외로 재개가 필요한경우
```kotlin
suspend fun requestUser(): User {
    return suspendCancellableCoroutine<User> { cont ->
        requestUser { resp ->
            if (resp.isSuccessful) {
                cont.resume(resp.data)
            } else {
                val e = ApiException(
                    resp.code,
                    resp.message
                )
                cont.resumeWithException(e)
            }
        }
    }
}
```
## 4장 코루틴의 실제 구현
- 중단 함수는 함수가 시작할 때와 중단 함수가 호출되었을 때 상태를 가진다는 점에서 상태 머신과 비슷하다.
- 컨티뉴에이션 객체는 상태를 나타내는 숫자와 로컬데이터를 가짐
- 함수의 컨티뉴에이션 객체가 이 함수를 부르는 다른 함수의 컨티뉴에이션 객체를 decorate함. 그 결과, 모든 컨티뉴에이션 객체는 실행을 재개하거나 재개된 함수를 완료할 때 사용되는 콜스택으로 사용됨.

### 컨티뉴에이션 전달 방식

`suspend` 키워드가 붙은 함수는 컴파일 타임에 완전히 다른 형태로 변환된다.

**컴파일 전 (우리가 작성하는 코드):**
```kotlin
suspend fun getUser(): User?
suspend fun setUser(user: User)
```

**컴파일 후 (실제 바이트코드):**
```kotlin
fun getUser(continuation: Continuation<*>): Any?
fun setUser(user: User, continuation: Continuation<*>): Any
```

**왜 반환 타입이 Any?로 바뀌는가:**
```kotlin
suspend fun getUser(): User? {
    delay(1000) // 여기서 중단될 수 있음
    return User("김철수")
}

// 컴파일되면
fun getUser(continuation: Continuation<*>): Any? {
    // 케이스 1: 즉시 완료되는 경우
    return User("김철수")  // User? 타입 반환
    
    // 케이스 2: 중단되는 경우  
    return COROUTINE_SUSPENDED  // 특별한 마커 반환
}
```

**두 가지 가능한 반환값:**
1. `User?` - 함수가 중단 없이 완료된 경우
2. `COROUTINE_SUSPENDED` - 함수가 중단된 경우

이 둘의 공통 슈퍼타입이 `Any?`이므로 반환 타입이 `Any?`가 된다.

**실제 동작 예시:**
```kotlin
// 우리 코드
suspend fun example() {
    val user = getUser() // 여기서 중단될 수 있음
    println(user)
}

// 컴파일된 코드 (간단화)
fun example(continuation: Continuation<*>): Any {
    val result = getUser(continuation)
    if (result == COROUTINE_SUSPENDED) {
        return COROUTINE_SUSPENDED // 나도 중단됨
    }
    val user = result as User?
    println(user)
    return Unit
}
```

- `suspend` 키워드 하나로 함수 시그니처가 완전히 바뀌는 것
- 예를 들어 아래와 같은 중단함수가 구현된다고 생각하면
```kotlin
suspend fun myFunction() {
    println("Before")
    delay(1000) // 중단 함수
    println("After")
}

fun myFunction(continuation: Continuation<Unit>): Any {
	// continuation 객체를 래핑한다. 
	// 이미 래핑되어있으면 안함, 이 함수가 콜백을 받아 다시 호출되는 상황을 생각하면 이해가능
	// 참고로 이 래핑 객체가 콜스택 역할을 한다
    val continuation = continuation as? MyFunctionContinuation
        ?: MyFunctionContinuation(continuation)
    // conetinutation 객체의 label값으로 시작될 위치와 수행할 로직을 식별
    if (continuation.label == 0) {
        println("Before")
        continuation.label = 1
        // 이런식으로 래핑된 continuation을 다음 스택으로 던짐
        if (delay(1000, continuation) == COROUTINE_SUSPENDED){
            return COROUTINE_SUSPENDED
        }
    }
    if (continuation.label == 1) {
        println("After")
        return Unit
    }
    error("Impossible")
}


```
- 눈여겨 봐야할점은 continuation객체의 래핑으로 콜스택 형성
- continuation.label 값으로 실행할 분기 결정
- COROUTINE_SUSPENDED 값을 반환하며 아래 콜백들에게 COROUTINE_SUSPENDED값 전달 정도이다.

```kotlin
cont = object : ContinuationImpl(continuation) {
    var result: Any? = null
    var label = 0
    override fun invokeSuspend(`$result`: Any?): Any? {
        this.result = `$result`;
        return myFunction(this);
    }
};

```

- 결론적인 myfunction
```kotlin
fun myFunction(continuation: Continuation<Unit>): Any {
    val continuation = continuation as? MyFunctionContinuation
        ?: MyFunctionContinuation(continuation)
    if (continuation.label == 0) {
        println("Before")
        tinuation.label = 1
        if (delay(1000, continuation) == COROUTINE_SUSPENDED){
            return COROUTINE_SUSPENDED
        }
    }
    if (continuation.label == 1) {
        println("After")
        return Unit
    }
    error("Impossible")
}
class MyFunctionContinuation(
    val completion: Continuation<Unit>
) : Continuation<Unit> {
    override val context: CoroutineContext
        get() = completion.context

    var label = 0
    var result: Result<Any>? = null
    override fun resumeWith(result: Result<Unit>) {
        this.result = result
        val res = try {
            val r = myFunction(this)
            if (r == COROUTINE_SUSPENDED) return
            Result.success(r as Unit)
        } catch (e: Throwable) {
            Result.failure(e)
        }
        completion.resumeWith(res)
    }
}

```

### 중단함수가 상태를 갖는 경우
```kotlin
suspend fun myFunction() {
    println("Before")
    var counter = 0
    delay(1000) // 중단 함수
    counter++
    println("Counter: $counter")
    println("After")
}

fun myFunction(continuation: Continuation<Unit>): Any {
    val continuation = continuation as? MyFunctionContinuation
        ?: MyFunctionContinuation(continuation)
    var counter = continuation.counter
    if (continuation.label == 0) {
        println("Before")
        counter = 0
        continuation.counter = counter
        continuation.label = 1
        if (delay(1000, continuation) == COROUTINE_SUSPENDED){
            return COROUTINE_SUSPENDED
        }
    }
    if (continuation.label == 1) {
        counter = (counter as Int) + 1
        println("Counter: $counter")
        println("After")
        return Unit
    }
    error("Impossible")
}
class MyFunctionContinuation(
    val completion: Continuation<Unit>
) : Continuation<Unit> {
    override val context: CoroutineContext
        get() = completion.context
    var result: Result<Unit>? = null
    var label = 0
    var counter = 0
    override fun resumeWith(result: Result<Unit>) {
        this.result = result
        val res = try {
            val r = myFunction(this)
            if (r == COROUTINE_SUSPENDED) return
            Result.success(r as Unit)
        } catch (e: Throwable) {
            Result.failure(e)
        }
        completion.resumeWith(res)
    }
}
```

### 값을 받아서 재개되는 함수
```kotlin
suspend fun printUser(token: String) {
    println("Before")
    val userId = getUserId(token) // 중단 함수
    println("Got userId: $userId")
    val userName = getUserName(userId, token) // 중단 함수
    println(User(userId, userName))
    println("After")
}

fun printUser(
    token: String,
    continuation: Continuation<*>
): Any {
    val continuation = continuation as? PrintUserContinuation
        ?: PrintUserContinuation(
            continuation as Continuation<Unit>,
            token
        )
    var result: Result<Any>? = continuation.result
    var userId: String? = continuation.userId
    val userName: String
    if (continuation.label == 0) {
        println("Before")
        continuation.label = 1
        val res = getUserId(token, continuation)
        if (res == COROUTINE_SUSPENDED) {
            return COROUTINE_SUSPENDED
        }
        result = Result.success(res)
    }
    if (continuation.label == 1) {
        userId = result!!.getOrThrow() as String
        println("Got userId: $userId")
        continuation.label = 2
        continuation.userId = userId
        val res = getUserName(userId, token, continuation)
        if (res == COROUTINE_SUSPENDED) {
            return COROUTINE_SUSPENDED
        }
        result = Result.success(res)
    }
    if (continuation.label == 2) 
        userName = result!!.getOrThrow() as String
        println(User(userId as String, userName))
        println("After")
        return Unit
    }
    error("Impossible")
}

class PrintUserContinuation(
    val completion: Continuation<Unit>,
    val token: String
) : Continuation<String> {
    override val context: CoroutineContext
        get() = completion.context
    var label = 0
    var result: Result<Any>? = null
    var userId: String? = null
    override fun resumeWith(result: Result<String>) {
        this.result = result
        val res = try {
            val r = printUser(token, this)
            if (r == COROUTINE_SUSPENDED) return
            Result.success(r as Unit)
        } catch (e: Throwable) {
            Result.failure(e)
        }
        completion.resumeWith(res)
    }
}

```

