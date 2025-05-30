---
title: 코틀린 코루틴 👾
summary: kotlin coroutines 책 정리
date: 2025-04-28 16:58:11 +0900
lastmod: 2025-05-30 21:48:54 +0900
tags:
  - Kotlin
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
> 원소나 원소들의 집합을 나타내는 인터페이스 입니다. Job, CoroutineName, CoroutineDispatcher와 같은 Element 객체들이 인덱싱된 집합이라는 점에서 맵이나 셋과 같은 컬렉션이랑 개념이 비슷합니다. 특이한 점은 각 Element 또한 CoroutineContext라는 점입니다. 따라서 컬렉션내 모든 원소는 그 자체만으로 컬렉션이라 할 수 있습니다.


### CoroutineContext에서 원소 찾기
- 컬렉션과 비슷하다는 특성으로 하여금 get을 이용하 유일한 키를 가진 원소를 찾을 수 있다.
- 대괄호를 사용하는 방법도 가능
```kotlin
fun main() {
    val ctx: CoroutineContext = CoroutineName("A name")
    val coroutineName: CoroutineName? = ctx[CoroutineName]
	// 또는 ctx.get(CoroutineName)
    println(coroutineName?.name) // A name
    val job: Job? = ctx[Job] // 또는 ctx.get(Job)
    println(job) // null
}
```
- 무튼 CoroutineName을 찾기 위해서는 CoroutineName만 사용하면됨
- companian object기 때문에 .name과 같이 접근

### 컨텍스트 더하기
> 일반적인 자료구조처럼 더할 수 있다.
```kotlin
fun main() {
    val ctx1: CoroutineContext = CoroutineName("Name1")
    println(ctx1[CoroutineName]?.name) // Name1
    println(ctx1[Job]?.isActive) // null
    val ctx2: CoroutineContext = Job()
    println(ctx2[CoroutineName]?.name) // null
    println(ctx2[Job]?.isActive) // 'Active' 상태이므로 true입니다.
    // 빌더를 통해 생성되는 잡의 기본 상태가 'Actice' 상태이므로 true가 됩니다.
    val ctx3 = ctx1 + ctx2
    println(ctx3[CoroutineName]?.name) // Name1
    println(ctx3[Job]?.isActive) // true
}

//CoroutineContext에 같은 키를 가진 또 다른 원소가 더해지면 맵처럼 새로운
//원소가 기존 원소를 대체합니다.

fun main() {
    val ctx1: CoroutineContext = CoroutineName("Name1")
    println(ctx1[CoroutineName]?.name) // Name1
    val ctx2: CoroutineContext = CoroutineName("Name2")
    println(ctx2[CoroutineName]?.name) // Name2
    val ctx3 = ctx1 + ctx2
    println(ctx3[CoroutineName]?.name) // Name2
}

```

### 코루틴 컨텍스트와 빌더
> 기본적으로 자식은 부모의 컨텍스트를 상속받는다, 당연히 자식이 빌더의 인자에서 정의된 특정 컨텍스트를 가진다면 상속받은 컨텍스트를 대체한다.
```kotlin
fun CoroutineScope.log(msg: String) {
    val name = coroutineContext[CoroutineName]?.name
    println("[$name] $msg")
}

fun main() = runBlocking(CoroutineName("main")) {
    log("started")
    val v1 = async {
        delay(500)
        log("Running async")
        42
    }

    launch(CoroutineName("not main")) {
        delay(1000)
        log("Running launch")
    }

    log("The answer is ${v1.await()}")
}

/**
 * [main] started
 * [main] Running async
 * [main] The answer is 42
 * [not main] Running launch
 */
```
- defaultContext + parentContext + childContext

### 중단 함수에서 컨텍스트에 접근하기
> continutation 객체 참조로 접근이 된다.
```kotlin
suspend fun printName() {
    println(coroutineContext[CoroutineName]?.name)
}
suspend fun main() = withContext(CoroutineName("Outer")) {
    printName() // Outer
    launch(CoroutineName("Inner")) {
        printName() // Inner
    }
    delay(10)
    printName() // Outer
}

/**
 * fun printName(continuation: Continuation<Unit>) {
 *     val context = continuation.context
 *     println(context[CoroutineName]?.name)
 * }
 */

```
> 이 책의 가장 헷갈리는 부분중 하나는 Continuation Passing Style (CPS)가 컴파일 타임에 일어나는데 (suspend함수들을 continuation객체를 넣고 실행 흐름을 넣고 상태를 분리하는 등의 작업) 이 부분을 설명을 해주긴 했지만, 이렇게 설명을 스킵하는 부분이 있다는게 아쉽다. 무튼 cps가 일어난후 개념적으로는 아래 주석처리된 함수처럼 변하고 알아서 해준다는 이야기 🤨

## 8장 잡과 자식 코루틴 기다리기
구조화된 동시성에서 배운 부모-자식 관계의 특성 리마인드
- 자식은 부모로부터 컨텍스트를 상속받습니다.
- 부모는 모든 자식이 작업을 마칠 때까지 기다립니다.
- 부모 코루틴이 취소되면 자식 코루틴도 취소됩니다.
- 자식 코루틴에서 에러가 발생하면, 부모 코루틴 또한 에러로 소멸합니다.
위의 내용중 1번은 지난 장에서 컨텍스트를 이야기하며 배웠고, 나머지 세개는 8,9장에서 주요하게 다루는 job과 관련된 내용이다.

### Job이란 무엇인가?
- job은 수명을 가지고 있으며 취소 가능하다.
- 인터페이스이긴 하지만, 구체적인 사용법과 상태를 가지고 있다는 점에서 추상 클래스처럼 다룰 수 있다.
- job의 수명은 상태로 나타낸다
![jobstate](https://github.com/user-attachments/assets/d8242239-7d27-4d9d-9d62-9058d29c1e98)
- 'Active' : 잡이 실행되고 코루틴이 잡을 수행하는 상태 (이 상태에서 자식 코루틴 생성 가능)
- 'New' : 지연시작되었을때 제한적으로 사용, 보통은 바로 Active
- 'Completing' : 실행이 완료된 상태, (자식코루틴이 있다면 기다림)
- 'Completed' : 자식 코루틴들도 완료된 상태
- 'Cancelling' : 취소되거나 실패됨, 그 이후에 후처리중인 상태
- 'Cancelled' : 취소된 다음 후처리까지 완료된 상태.

```kotlin
suspend fun main() = coroutineScope {
// 빌더로 생성된 잡은
    val job = Job()
    println(job) // JobImpl{Active}@ADD
// 메서드로 완료시킬 때까지 Active 상태입니다.
    job.complete()
    println(job) // JobImpl{Completed}@ADD
// launch는 기본적으로 활성화되어 있습니다.
    val activeJob = launch {
        delay(1000)
    }
    println(activeJob) // StandaloneCoroutine{Active}@ADD
// 여기서 잡이 완료될 때까지 기다립니다.
    activeJob.join() // (1초 후)
    println(activeJob) // StandaloneCoroutine{Completed}@ADD
// launch는 New 상태로 지연 시작됩니다.
    val lazyJob = launch(start = CoroutineStart.LAZY) {
        delay(1000)
    }
    println(lazyJob) // LazyStandaloneCoroutine{New}@ADD
// Active 상태가 되려면 시작하는 함수를 호출해야 합니다.
    lazyJob.start()
    println(lazyJob) // LazyStandaloneCoroutine{Active}@ADD
    lazyJob.join() // (1초 후)
    println(lazyJob) // LazyStandaloneCoroutine{Completed}@ADD
}

```
잡의 상태를 확인하기 위한 프로퍼티들 

| 상태                   | isActive | isCompleted | isCancelled |
| -------------------- | -------- | ----------- | ----------- |
| New (지연 시작될 때 시작 상태) | false    | false       | false       |
| Active (시작 상태 기본값)   | true     | false       | false       |
| Completing (일시적인 상태) | true     | false       | false       |
| Cancelling (일시적인 상태) | false    | false       | true        |
| Cancelled (최종 상태)    | false    | true        | true        |
| Completed (최종 상태)    | false    | true        | false       |
### 코루틴 빌더는 부모의 잡을 기초로 자신들의 잡을 생성한다
> 빌더들은 자신만의 잡을 생성한다. 대부분의 코루틴 빌더들이 실제로 잡을 반환한다
```kotlin
fun main(): Unit = runBlocking {  
    val job: Job = launch {  
        delay(1000)  
        println("Test")  
    }  
}

fun main(): Unit = runBlocking { 
    val deferred: Deferred<String> = async { 
        delay(1000)
        "Test"
    }
    
    val job: Job = deferred // 가능 deferred<>는 Job 인터페이스를 구현
}


// coroutineContext[Job] 으로 접근 가능하지만, 이런 확장 프로퍼티가 있다.
val CoroutineContext.job: Job
	get() = get(Job) ?: error("Current context doesn't...")

fun main(): Unit = runBlocking {
	print(coroutineContext.job.isActive) // true
}

```

> Job은 코루틴이 상속하지 않는 유일한 코루틴 컨텍스트이며, 이는 코루틴에서 아주 중요한 법칙입니다. 모든 코루틴은 자신만의 Job을 생성하며 인자 또는 부모 코루틴으로부터 온 잡은 새로운 잡의 부모로 사용됩니다

> 표현이 와닿지 않는데, 간단히 말하면 다른 컨텍스트 요소들과 달리 Job은 직접 상속되지 않고, 대신 부모-자식 관계를 형성한다는 이야기 🤓

```kotlin
val parentJob = Job()
val parentContext = CoroutineName("Parent") + parentJob

launch(parentContext) {
    val myJob = coroutineContext[Job]!!
    println("내 Job: $myJob")
    println("부모와 같은 Job? ${myJob === parentJob}") // false!
    println("부모 Job: ${myJob.parent}") // parentJob과 동일
    
    launch { // 자식 코루틴
        val childJob = coroutineContext[Job]!!
        println("자식의 부모 Job: ${childJob.parent}") // myJob과 동일
    }
}
```

```kotlin
fun main(): Unit = runBlocking {
    launch(Job()) { // 새로운 잡이 부모로부터 상속받은 잡을 대체합니다.
        delay(1000)
        println("Will not be printed")
    }
}
// (아무것도 출력하지 않고, 즉시 종료합니다.)
```

### 자식들 기다리기
> 잡의 첫 번째 중요한 이점은 코루틴이 완료될 때까지 기다리는데 사용될 수 있다는 것, join메서드를 사용해서 할 수 있다.
- join은 지정한 job이 completed, cancelled와 같은 마지막 상태로 조달할 때 까지 기다리는 중단함수.

```kotlin
fun main(): Unit = runBlocking {
    launch {
        delay(1000)
        println("Test1")
    }
    launch {
        delay(2000)
        println("Test2")
    }

    val children = coroutineContext[Job]
        ?.children
    val childrenNum = children?.count()
    println("Number of children: $childrenNum")
    children?.forEach { it.join() }
    println("All tests are done")
}

```

### 잡 팩토리 함수
- Job() 팩토리 함수로 잡을 생성할수 있다.
- 주로 다른 자식 코루틴을 엮어서 부모 job으로 활용하기는 하는데 아래와 같은 실수를 하면 안된다.

```kotlin
suspend fun main(): Unit = coroutineScope {  
    val job = Job()  
    launch(job) { // 새로운 잡이 부모로부터 상속받은 잡을 대체합니다.  
        delay(1000)  
        println("Text 1")  
    }  
    launch(job) { // 새로운 잡이 부모로부터 상속받은 잡을 대체합니다.  
        delay(2000)  
        println("Text 2")  
    }  
	// job.complete() 이렇게 빈 잡을 완료시키고 join하거나 하지 않으면
    job.join() // 여기서 영원히 대기하게 됩니다.
    // job.children.forEach { it.join() } 이렇게 하던지..
    println("Will not be printed")  
}
```


## 9장 취소
> 코루틴에서 아주 중요한 기능 중 하나는 바로 취소 입니다.
> 취소는 아주 중요한 기능이기 때문에 중단 함수를 사용하는 클래스와 라이브러리를 취소를 지원하고 있습니다. 단순히 스레드를 죽이면 연결을 닫고 자원을 해제하는 기회가 없기 때문에 최악이고, 개발자들이 상태를 직접 확인하는건 불편합니다.

> 코틀린 코루틴의 취소 방식은 아주 간단하고 편리하며 안전하며, 저자의 커리어동안 본 모든 방식중 단연 최고라고 합니다 😮

### 기본적인 취소
- 호출한 코루틴은 첫 번째 중단점(아래 예제에서는 delay)에서 잡을 끝냅니다.
- 잡이 자식을 가지고 있다면, 그들 또한 취소됩니다. 하지만 부모는 영향을 받지 않습니다.
- 잡이 취소되면, 취소된 잡은 새로운 코루틴의 부모로 사용될 수 없습니다.
- 취소된 잡은 ‘Cancelling’ 상태가 되었다가 ‘Cancelled’ 상태로 바뀝니다

```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = launch {
        repeat(1000) {
            delay(200)
            println("Printing $it")
        }
    }

    delay(1100)
    job.cancel()
    job.join()
    println("Cancelled!!")
}
```
- cancel 함수에 예외를 인자로 넣어 취소된 원인을 명확하게 할 수 있다.
- CancelationException의 서브타입으로 넣어야 한다.
- cancel 이후 join을 하지 않으면 경쟁 상태가 될 수 있다.
```kotlin
delay(1000)
job.cancel()                    // 취소 요청만 보냄 (즉시 반환)
println("Cancelled successfully") // 바로 실행됨!
// 하지만 job이 아직 실행 중일 수 있음!
```

```kotlin
job.cancel()
job.join()  // 실제 종료까지 기다림
println("Cancelled successfully") // 이제 확실히 끝난 후 출력
```

- 아래의 가장 명확하고 직관적인 이름을 가진 함수를 쓰는걸 추천한다.
```kotlin
public suspend fun Job.cancelAndJoin() {
    cancel()
    return join()
}
```

### 취소는 어떻게 작동하는가?
잡이 취소되면 'Cancelling' 상태로 바뀐다. 상태가 바뀐 뒤 첫 번째 중단점에서 CancellationException 예외를 던진다. 예외는 try-catch로 직접 잡을수 있지만, 다시 던져주는 것이 좋다.

```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        try {
            repeat(1_000) { i ->
                delay(200)
                println("Printing $i")
            }
        } catch (e: CancellationException) {
            println(e)
            throw e
        }
    }
    delay(1100)
    job.cancelAndJoin()
    println("Cancelled successfully")
    delay(1000)
}
```
- 사실 잡아서 처리할일은 디버깅 정도니까 아래 예시가 유의미 한 것 같다 (자원정리)
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        try {
            delay(Random.nextLong(2000))
            println("Done")
        } finally {
            print("Will always be printed")
        }
    }
    delay(1000)
    job.cancelAndJoin()
}
```

### 취소 중 코루틴을 한 번 더 호출하기
- Job이 Cancelling 상태가 된 이후에는 다른 코루틴을 시작하는건 무시되고, 중단하려고 하면 exception이 터진다.
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        try {
            delay(2000)
            println("Job is done")
        } finally {
            println("Finally")
            launch { // 무시됩니다.
                println("Will not be printed")
            }
            delay(1000) // 여기서 예외가 발생합니다.
            println("Will not be printed")
        }
    }
    delay(1000)
    job.cancelAndJoin()
    println("Cancel done")
}
// (1초 후)
// Finally
// Cancel done
```
- 그렇지만 취소 후 정리작업중 꼭 진행해야하는 것들에 중단이 필요한 경우가 있다.
- 예를들어 db롤백같은 것들이 있는데, 이러한 경우 withContext를 이용한다.
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        try {
            delay(200)
            println("Coroutine finished")
        } finally {
            println("Finally")
            withContext(NonCancellable) {
                delay(1000)
                println("Clean up done!")
            }
        }
    }

    delay(100)
    job.cancelAndJoin()
    println("Done")
}

/**
 * Finally
 * Clean up done!
 * Done
 */
```


### invokeOnCompletion
- 마찬가지로 자원 정리에서 쓰인다.
- 잡이 'Completed', 'Cancelled'와 같이 마지막 상태에 도달했을 때 호출될 핸들러를 지정해준다.
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = launch {
        delay(Random.nextLong(2400))
        println("Finished")
    }
    delay(800)
    job.invokeOnCompletion { exception: Throwable? ->
        println("Will always be printed")
        println("The exception was: $exception")
    }
    delay(800)
    job.cancelAndJoin()
}
// Will always be printed
// The exception was:
// kotlinx.coroutines.JobCancellationException
// (또는)
// Finished
// Will always be printed
// The exception was null

```
- invokeOnCompletion은 취소하는 중에 동기적으로 호출되며, 어떤 스레드에서 실행할지 결정할 수는 없다.

### 중단 할 수 없는것을 중단하기
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        repeat(1_000) { i ->
            Thread.sleep(200) // 여기서 복잡한 연산이나
			// 파일을 읽는 등의 작업이 있다고 가정합니다.
            println("Printing $i")
        }
    }
    delay(1000)
    job.cancelAndJoin()
    println("Cancelled successfully")
    delay(1000)
}
// Printing 0
// Printing 1
// Printing 2
// ... (1000까지)

```
- Thread.sleep()은 코루틴의 중단점이 아니라 스레드의 중단이다.
- 결과적으로 아래 코루틴에는 중단점이 없다.
- 하지만 실제로는 엄청 긴 cpu bound 작업들이 Thread.sleep()처럼 블로킹된 것 처럼 동작 할 수 있다.
```kotlin
    launch(job) {
        repeat(1_000) { i ->
            Thread.sleep(200)
            println("Printing $i")
        }
    }
```
- 이런 경우 아래처럼, 중간에 yield()를 넣어주면서 해결한다.
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        repeat(1_000) { i ->
            Thread.sleep(200)
			yield() // 200ms 마다 도달하는 중단점
            println("Printing $i")
        }
    }
    delay(1000)
    job.cancelAndJoin()
    println("Cancelled successfully")
    delay(1000)
}
```
- 다른 방법으로는 coroutineScope의 isActive 프로퍼티를 이용 할 수 있다.
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        do {
            Thread.sleep(200)
            println("Printing")
        } while (isActive) // 200ms마다 스스로 취소된 job인지 확인
    }
    delay(1100)
    job.cancelAndJoin()
    println("Cancelled successfully")
}
```
- 위와 비슷한 방법으로 ensureActive()함수가 있음
```kotlin
suspend fun main(): Unit = coroutineScope {
    val job = Job()
    launch(job) {
        repeat(1000) { num ->
            Thread.sleep(200)
            ensureActive()
            println("Printing $num")
        }
    }
    delay(1100)
    job.cancelAndJoin()
    println("Cancelled successfully")
}
```
- 1번의 yield와 2,3번은 비슷해보이지만 매우 다르다.
- 중단하고 재개하는 일이 일어나기 때문에 스레드풀을 가진 디스패처를 사용하면 스레드가 바뀔 수 있다고 한다.
- 그리고 ensureActive가 좀 더 가볍다고 한다.
- yield는 cpu사용량이 크거나 스레드를 실제로 블로킹하는 경우 자주 사용한다고 한다.

## 10장 예외 처리
> 기본적으로 자식의 에러는 부모로 전파되며 부모가 종료되면, 다른 형제 코루틴에도 에러가 전파된다.

```kotlin
fun main(): Unit = runBlocking {
// try-catch 구문으로 래핑하지 마세요. 무시됩니다.
    try {
        launch {
            delay(1000)
            throw Error("Some error")
        }
    } catch (e: Throwable) { // 여기선 아무 도움이 되지 않습니다.
        println("Will not be printed")
    }
    launch {
        delay(2000)
        println("Will not be printed")
    }
}
// Exception in thread "main" java.lang.Error: Some error...

```
그리고 이런건 도움이 되지 않는다.

### SupervisorJob
가장 중요한 방법은 SupervisorJob을 사용하는것
```kotlin
fun main(): Unit = runBlocking {
    val scope = CoroutineScope(SupervisorJob())
    scope.launch {
        delay(1000)
        throw Error("Some error")
    }
    scope.launch {
        delay(2000)
        println("Will be printed")
    }
}
// Exception...
// Will be printed

```
- 이건 뒤에가서 조금 더 자세히
### SupervisorScope
```kotlin
fun main(): Unit = runBlocking {
    supervisorScope {
        launch {
            delay(1000)
            throw Error("Some error")
        }
        launch {
            delay(2000)
            println("Will be printed")
	    }
	}
	
	delay(1000)
	println("Done")
	// Exception...
}
```
- 이래도 안일어남

### 코루틴 예외 핸들러
```kotlin
fun main(): Unit = runBlocking {
    val handler =
        CoroutineExceptionHandler { ctx, exception ->
            println("Caught $exception")
        }
    val scope = CoroutineScope(SupervisorJob() + handler)
    scope.launch {
        delay(1000)
        throw Error("Some error")
    }
    scope.launch {
        delay(2000)
        println("Will be printed")
    }

	delay(3000)
}
// Caught java.lang.Error: Some error
// Will be printed

```

## 11장 코루틴 스코프 함수
> 스코프를 다루지 못하던 기존의 코드들
```kotlin
// 데이터를 동시에 가져오지 않고, 순차적으로 가져옵니다.
suspend fun getUserProfile(): UserProfileData {
    val user = getUserData() // (1초 후)
    val notifications = getNotifications() // (1초 후)
    return UserProfileData(
        user = user,
        notifications = notifications,
    )
}

// async로 래핑하기 위해 Global scope를 사용했습니다.
suspend fun getUserProfile(): UserProfileData {
    val user = GlobalScope.async { getUserData() }
    val notifications = GlobalScope.async {
        getNotifications()
    }
    return UserProfileData(
        user = user.await(), // (1초 후)
        notifications = notifications.await(),
    )
}

```
- 취소될 수 없음(부모가 취소되어도 async 내부의 함수가 실행 중인 상태가 되므로 작업이 끝날 때까지 자원이 낭비).
- 부모로부터 스코프를 상속받지 않음(항상 기본 디스패처에서 실행되며, 부모의 컨텍스트를 전혀 신경 쓰지 않음).
- 그렇다고 함수 인자로 스코프를 넘기는것도 나쁘다.

### coroutineScope
> 스코프를 시작하는 중단 함수이며, 인자로 들어온 함수가 생성한 값을 반환
```kotlin
suspend fun <R> coroutineScope(
	block: suspend CoroutineScope.() -> R
): R
```

```kotlin
suspend fun longTask() = coroutineScope {
    launch {
        delay(1000)
        val name = coroutineContext[CoroutineName]?.name
        println("[$name] Finished task 1")
    }
    launch {
        delay(2000)
        val name = coroutineContext[CoroutineName]?.name
        println("[$name] Finished task 2")
    }
}
fun main() = runBlocking(CoroutineName("Parent")) {
    println("Before")
    longTask()
    println("After")
}
// Before
// (1초 후)
// [Parent] Finished task 1
// (1초 후)
// [Parent] Finished task 2
// After

```

### 코루틴 스코프 함수
> 스코프를 만드는 함수도 용도에 따라 다양하게 있다.
- `coroutineScope`: 기본적인 코루틴 스코프 생성
- `supervisorScope`: SupervisorJob을 사용하는 버전
- `withContext`: 코루틴 컨텍스트 변경 가능
- `withTimeout`: 타임아웃 기능 포함

헷갈리는 스코프함수와 코루틴 빌더의 정리:

| 코루틴 빌더                      | 코루틴 스코프 함수                        |
| --------------------------- | --------------------------------- |
| launch, async, produce      | coroutineScope, supervisorScope 등 |
| CoroutineScope의 확장 함수       | 중단 함수                             |
| CoroutineScope 리시버의 컨텍스트 사용 | 중단 함수의 컨티뉴에이션 컨텍스트 사용             |
| 예외가 Job을 통해 부모로 전파          | 일반 함수처럼 예외를 던짐                    |
| 비동기 코루틴 시작                  | 호출된 곳에서 코루틴 시작                    |
## 12장 디스패처
> 코틀린 코루틴 라이브러리가 제공하는 중요한 기능은 코루틴이 실행되어야(시작하거나 재개하는 등) 할 스레드(또는 스레드 풀)를 결정할 수 있다는 것

### 기본 디스패처
> 디스패처를 설정하지 않으면 기본적으로 설정되는 디스패처는 CPU 집약적인 연산을 수행하도록 설계된 Dispatchers.Default
- cpu갯수와 동일한 스레드수를 설정
```kotlin
suspend fun main() = coroutineScope {
	repeat(1000) {
	launch { // 또는 launch(Dispatchers.Default) {
		// 바쁘게 만들기 위해 실행합니다.
		List(1000) { Random.nextLong() }.maxOrNull()
		val threadName = Thread.currentThread().name
		println("Running on thread: $threadName")
		}
	}
}
```

### IO 디스패처
**IO 디스패처의 용도** `Dispatchers.IO`는 다음과 같은 상황에서 사용하도록 설계되었다:
- 파일 읽기/쓰기 작업
- 안드로이드 셰어드 프레퍼런스 사용
- 블로킹 함수 호출
- 시간이 오래 걸리는 I/O 연산

메인 스레드나 기본 디스패처를 블로킹하면 전체 애플리케이션에 영향을 주기 때문에 별도의 IO 디스패처를 사용한다.

**스레드 풀 관리와 제한**
- `Dispatchers.IO`는 최대 64개 스레드까지 사용할 수 있다 (또는 코어 수가 더 많다면 해당 수만큼)
- `Dispatchers.Default`는 프로세서 코어 수로 제한된다
- 두 디스패처는 같은 스레드 풀을 공유하여 효율성을 높인다

**블로킹 함수의 래핑** 블로킹 함수를 중단 함수로 변환할 때는 `withContext(Dispatchers.IO)`로 래핑하는 패턴을 사용한다:

```kotlin
class DiscUserRepository(
    private val discReader: DiscReader
) : UserRepository {
    override suspend fun getUser(): UserData =
        withContext(Dispatchers.IO) {
            UserData(discReader.read("userName"))
        }
}
```

**limitedParallelism 활용** `Dispatchers.IO`의 64개 스레드 제한을 넘어서야 하는 경우 `limitedParallelism` 함수를 사용한다. 이 함수는 독립적인 스레드 풀을 가진 새로운 디스패처를 생성하며, 원하는 만큼 많은 스레드를 설정할 수 있다. 예를 들어, 100개의 코루틴이 각각 1초씩 블로킹하는 작업에서 일반 IO 디스패처는 2초가 걸리지만, `limitedParallelism(100)`을 사용하면 1초만 소요된다.
