---
title: 코틀린 코루틴 👾
summary: kotlin coroutines 책 정리
date: 2025-04-28 16:58:11 +0900
lastmod: 2025-05-29 23:39:41 +0900
tags:
  - Kotlin
  - Cpp
categories: 
description: 
showToc: true
tocOpen: true
---

> 모든 내용의 출처는 : https://www.yes24.com/product/goods/123034354


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

### 콜 스택
코루틴을 중단하면 스레드를 반환해 콜스택에 있는 정보가 사라진다.

문제는 재개될 때 콜스택에 있는 정보가 없다는건데, 그걸 컨티뉴에이션 객체가 콜스택의 역할을 대신한다.

```kotlin
internal abstract class BaseContinuationImpl(  
    val completion: Continuation<Any?>?,  
) : Continuation<Any?>, CoroutineStackFrame, Serializable {  
    // 아래 함수는 resumeWith가 재귀 함수라,  
    // 이를 전개하기 위해 final로 구현되어 있습니다.  
    final override fun resumeWith(result: Result<Any?>) {  
        // 아래 반복문은 current.resumeWith(param)에서  
        // 재귀를 전개하여 재개되었을 때  
        // 스택 트레이스를 적절하게 작은 크기로 만듭니다.  
        var current = this  
        var param = result  
        while (true) {  
            // 컨티뉴에이션 객체를 재개할 때마다  
            // "resume" 디버그 조사를 실행함으로써  
            // 디버깅 라이브러리가  
            // 중단된 콜 스택 중 어떤 부분이 이미 재개되었는지  
            // 추적할 수 있게 합니다.  
            probeCoroutineResumed(current)  
            with(current) {  
                val completion = completion!! // 완료되지 않은 상태에서  
                // 컨티뉴에이션 객체를 재개하면  
                // 곧바로 실패합니다.  
                val outcome: Result<Any?> =  
                    y {  
                        val outcome = invokeSuspend(param)  
                        if (outcome === COROUTINE_SUSPENDED)  
                            return  
                        Result.success(outcome)  
                    } catch (exception: Throwable) {  
                Result.failure(exception)  
            }  
                releaseIntercepted()  
                // 상태 머신이 종료되는 중일 때 실행됩니다.  
                if (completion is BaseContinuationImpl) {  
                    // 반복문을 통해 재귀 호출을 풉니다.  
                    current = completion  
                    param = outcome  
                } else {  
                    // 최상위 컨티뉴에이션 객체인 completion에 도달했습니다 --                    // 실행 후 반환합니다.  
                    completion.resumeWith(outcome)  
                    return  
                }  
            }  
        }  
    }    // ...  
}
```

## 5장 코루틴: 언어 차원에서의 지원 vs 라이브러리
> 질문을 좀 더 요약하자면, 컴파일러레벨의 지원을 포함한 언어 자체적인 지원과 kotlinx.coroutines 라이브러리의 기능을 따로 봐야 한다는 것이다.

일단 언어 레벨의 지원은 직접 사용하기 어렵지만 보편적이라 거의 모든 동시성 스타일이 허용된다는 것과
라이브러리에서는 반대로 사용하기 편리하지만, 단 하나의 명확한 동시성 스타일을 위해 설계되어있다는 차이가 있다.
## 6장 코루틴 빌더
> 중단 함수는 컨티뉴에이션 객체를 다른 중단 함수로 전달해야 합니다. 따라서 중단 함수가 일반 함수를 호출하는 것은 가능하지만, 일반 함수가 중단 함수를 호출하는 것은 불가능합니다. 모든 중단 함수는 또 다른 중단 함수에 의해 호출되어야 하며, 이는 앞서 호출한 중단 함수 또한 마찬가지입니다. 중단 함수를 연속으로 호출하면 시작되는 지점이 반드시 있습니다. 코루틴 빌더가 그 역할을 하며, 일반 함수와 중단 가능한 세계를 연결시키는 다리가 됩니다.

kotlinx.coroutines 라이브러리가 제공하는 세가지 필수적인 코루틴 빌더를 알아본다.
- launch
- runBlocking
- async

### launch 빌더
```kotlin
fun main() {
    GlobalScope.launch {
        delay(1000L)
        println("World!")
    }
    GlobalScope.launch {
        delay(1000L)
        println("World!")
    }
    GlobalScope.launch {
        delay(1000L)
        println("World!")
    }
    println("Hello,")
    Thread.sleep(2000L) // 메인함수가 코루틴의 delay가 끝나는동안 끝나버리는 것을 막기 위해
}

// Hello,
// (1초후)
// World!
// World!
// World!
```

- launch 함수는 CoroutineScope 인터페이스의 확장함수이다.
- CoroutineScope 인터페이스는 부모 코루틴과 자식 코루틴 사이의 관계를 정립하기 위한 목적으로 사용되는 구조화된 동시성의 핵심이다.
- launch는 thread함수를 호출해서 새로운 스레드를 시작하는것과 비슷하게 동작한다.(비용은 thread가 압도적)

### runBlocking 빌더
```kotlin
fun main() {
    runBlocking {
        delay(1000L)
        println("World!")
    }
    runBlocking {
        delay(1000L)
        println("World!")
    }
    runBlocking {
        delay(1000L)
        println("World!")
    }
    println("Hello,")
}
// (1초 후)
// World!
// (1초 후)
// World!
// (1초 후)
// World!
// Hello,
```
- 블로킹이 필요한 경우 사용한다.
- 블로킹을 시작한 스레드를 중단시킨다. (정확히 말하면, 새로운 코루틴을 실행한 뒤 완료될 때까지 스레드를 중단 가능한 상태로 블로킹한다)

### async 빌더
```kotlin
fun main() = runBlocking {
    val resultDeferred: Deferred<Int> = GlobalScope.async {
        delay(1000L)
        42
    }
// 다른 작업을 합니다...
    val result: Int = resultDeferred.await() // (1초 후)
    println(result) // 42
// 다음과 같이 간단하게 작성할 수도 있습니다.
    println(resultDeferred.await()) // 42
}

```
- launch와 비슷하지만 값을 생성하도록 설계되어있다.
- 이 값은 람다 표현식에 의해 반환되어야 한다. (마지막에 위치한 함수형의 인자에 의해 반환된다)
- async함수는 `Deferred<T>` 타입의 객체를 리턴하며, 여기서 T는 생성되는 값의 타입이다.
```kotlin
fun main() = runBlocking {
    val res1 = GlobalScope.async {
        delay(1000L)
        "Text 1"
    }
    val res2 = GlobalScope.async {
        delay(3000L)
        "Text 2"
    }
    val res3 = GlobalScope.async {
        delay(2000L)
        "Text 3"
    }
    println(res1.await())
    println(res2.await())
    println(res3.await())
}
// (1초 후)
// Text 1
// (2초 후)
// Text 2
// Text 3

```

- 아래처럼 병렬적으로 작업을 진행할때 사용
```kotlin
scope.launch {
    val news = async {
        newsRepo.getNews()
            .sortedByDescending { it.date }
    }
    val newsSummary = newsRepo.getNewsSummary()
	// async로 래핑할 수도 있지만,
	// 불필요한 작업입니다.
    view.showNews(
        newsSummary,
        news.await()
    )
}

```

### 구조화된 동시성
> 코루틴이 GlobalScope에서 시작되었다면 프로그램은 해당 코루틴을 기다리지 않습니다. 코루틴은 어떤 스레드도 블록하지 않기 때문에 프로그램(메인 스레드)가 끝나는 걸 막을 방법이 없습니다.

```kotlin
fun main() = runBlocking {
    GlobalScope.launch { delay(1000L); println("World!") }
    GlobalScope.launch { delay(2000L); println("World!") }
    println("Hello,")
}
```
- 위가 가장 대표적인 예시이다.
- runBlocking은 자신의 스코프에서 수행된 코루틴은 블록해준다. GlobalScope에서 수행된 코루틴은 관계가 없기 때문에 블락하지 않는다.
> 그럼 애초에 왜 이렇게 GlobalScope가 필요할까?
- 그 이유는 launch, async가 CoroutineScope의 확장 함수이기 때문
```kotlin
fun <T> runBlocking(
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend CoroutineScope.() -> T
): T
fun CoroutineScope.launch(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> Unit
): Job
fun <T> CoroutineScope.async(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> T
): Deferred<T>

```
- 반면에 runBlocking은 CoroutineScope의 확장함수를 인자로 받는다.
- 그리고 그 인자의 람다에서는 CoroutineScope를 this로 참조 가능하다.
```kotlin
fun main() = runBlocking {
    this.launch { // launch로 호출한 것과 같습니다.
        delay(1000L)
        println("World!")
    }
    launch { // this.launch로 호출한 것과 같습니다.
        delay(2000L)
        println("World!")
    }
    println("Hello,")
}
```

- 아래처럼 scope를 알아서 생성한다.
```kotlin
fun <T> runBlocking(
    context: CoroutineContext = EmptyCoroutineContext,
    block: suspend CoroutineScope.() -> T
): T {
    val scope = BlockingCoroutine<T>(context)
    return scope.startBlockingCoroutine(block)
}
```
- 이런 관점에서 부모가 (예시에서는 runBlocking이) 자식들을 해당 스코프내에서 호출한다.
- 이를 통해 "구조화된 동시성"이라는 관계가 성립한다.

부모 자식 관계의 가장 중요한 특징은다음과 같다.
1. 자식은 부모로부터 컨텍스트를 상속받는다.
2. 부모는 모든 자식이 작업을 마칠 때까지 기다린다
3. 부모 코루틴이 취소되면 자식 코루틴도 취소된다
4. 자식 코루틴에서 에러가 발생하면, 부모 코루틴 또한 에러로 소멸한다.

### 현업에서의 코루틴 사용
> 첫 번째 빌더가 스코프에서 시작되면 다른 빌더가 첫 번째 빌더의 스코프에서 시작될 수 있습니다. 이것이 애플리케이션이 구조화되는 본질입니다.

- 이쪽의 예시코드는 뭔가 좀 잘못된것같다.
- 내용 자체도 큰 의미 없는 것 같다.
- 실사용 코드를 보여주는게 목적이었던 것 같긴 한데..
- 그나마 중단 함수에서 스코프를 어떻게 처리하냐는 물음이 의미가 있는 것 같다.
	- 중단 함수 내에서는 중단 될 수 있지만 함수 내에는 스코프가 없다.
	- 스코프를 인자로 넘기는건 좋은방법이 아니다.

### couroutineScope 사용하기
```kotlin
suspend fun getArticlesForUser(
    userToken: String?,
): List<ArticleJson> = coroutineScope {
    val articles = async { articleRepository.getArticles() }
    val user = userService.getUser(userToken)
    articles.await()
        .filter { canSeeOnList(user, it) }
        .map { toArticleJson(it) }
}

```
- coroutineScope는 람다 표현식이 필요로 하는 스코프를 만들어 주는 중단 함수
- 이 함수는 let, run, use 또는 runBlocking처럼 람다식이 반환하는 것 이면 무엇이든 반환

## 7장 코루틴 컨텍스트
슥 지나갔지만 코루틴 빌더 시그니처에 보면 첫 번째 파라미터가 CoroutineContext이다.
그리고, 확장함수의 리시버, 마지막 람다의 리시버도 CoroutineScope이다.
```kotlin
fun CoroutineScope.launch(
    context: CoroutineContext = EmptyCoroutineContext,
    start: CoroutineStart = CoroutineStart.DEFAULT,
    block: suspend CoroutineScope.() -> Unit
): Job
```
그래서 CoroutineScope를 보면 뭔가 context를 래핑한 것 같은 것이 있다.
```kotlin
public interface CoroutineScope {
	public val coroutineContext: CoroutineContext
}
```
심지어 Continuation에도 있다.
```kotlin
public interface Continuation<in T> {
	public val context: CoroutineContext
	public fun resumeWith(result: Result<T>)
}
```


### CorutineContext 인터페이스
