---
title: 파이써닉 파이썬
summary: 
date: 2025-04-21 12:39:58 +0900
lastmod: 2025-04-21 22:00:22 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 1~3장 기본 문법
---

> 진짜 간단하게 문법을 훑는다.

## 3장 프로그램 구조와 제어 흐름
---
### 예외 처리에 대한 조언

#### 코드의 특정 위치에서 처리할 수 없는 예외는 잡지 않는다.
```python
def read_data(filename):
    with open(filename, 'rt') as file:
        rows = []
        for line in file:
            row = line.split()
            rows.append((row[0], int(row[1]), float(row[2])))
    return rows
```
- 위의 경우 함수의 사용자가 잘못된 파일명을 처리할 기회가 사라짐
- 예외를 호출자한테 전달하는게 바람직하다고함
- 파이썬은 **매번 에러 확인하지 말고**, **실패하도록 내버려두라**는 철학을 가짐.
- 예외는 프로그램 흐름을 위로 “전파”시켜서, **상위 책임 코드에서 처리하는 게 자연스럽다**는 접근
> 흠..


#### 특정 위치에서 복구가 필요한 경우
```python
def read_data(filename):
    with open(filename, 'rt') as file:
        rows = []
        for line in file:
            row = line.split()
            try:
                rows.append((row[0], int(row[1]), float(row[2])))
            except ValueError as e:
                print('Bad rows: ', row)
                print('Reason: ', e)
    return rows
```
- 잡는 에러의 영역을 가능한 narrow하게 만들것

### 컨텍스트 관리와 with 문
```python
with open('debuglog', 'wt') as file:
    file.write('Debugging\n')
    # statements
    file.write('Done\n')

import threading

lock = threading.lock()
with lock:
    # 임계구역
    # statements
    # 임계구역 종료
```
- `with obj`문은 제어 흐름이 이어서 나오는 블록에 진입하고 빠져나올때 일어나는 일을 객체 obj가 관리하게 한다.
- `with obj`문이 실행되면 새로운 컨텍스트에 진입한다는 신호로 `obj.__enter__()`가 호출된다.
- 컨텍스트를 벗어날때는 `obj.__exit__(type, value, traceback)`이 호출된다. (발생한 예외가 없다면 세 args모두 None으로)
- `__exit__`이 False, None을 반환하는 경우는 예외가 컨텍스트 밖으로 전달된다.

> 여러가지 decorator 로직을 프록시 없이 작성 할 수 있을 것 같다.
> 뭔가 js의 프로토콜 기반 방법론과 비슷한 방식인것같다.
> (protocol을 구현하는 객체에 대해서 특정 예약어를 쓸 수 있게 해주는)

```python
class ListTransaction:
    def __init__(self, theList):
        self.theList = theList
    def __enter__(self):
        self.workingcopy = list(self.theList)
        return self.workingcopy
    def __exit__(self, type, value, tb):
        if type is None:
            self.theList[:] = self.workingcopy
        return False

items = [1,2,3]

with ListTransaction(items) as working:
    working.append(4)
    working.append(5)
print(items) # [1,2,3,4,5]

try:
    with ListTransaction(items) as working:
        working.append(6)
        working.append(7)
        raise RuntimeError("We're hosed!")
except RuntimeError:
    pass

print(items) # [1,2,3,4,5]
```
- 실제로 위와 같은 트랜잭션도 구현이 손쉽게 가능하다.
> exit의 리턴값은 오직 예외 전파여부만 관리함, 헷갈리지 말것

### 단언과 debug
```python
assert file, 'write_data: file not defined!'
```
- file 자리는 T/F로 평가되는 expression
- 최적화 모드로 파이썬을 실행시키면 assert실행 안함 주의
- 사용자 입력이나, 주요 연산의 성공여부를 체크하기위해 사용한다 -> (X)
- 항상 참이어야 하는 불변성을 검사할 때 사용한다 -> (O)
> 내부 프로그램의 일관성을 확인하려는 것

### 파이써닉한 파이썬
- 기본 모델은 명령형 프로그래밍이라고 한다.
- 모호함과 적절하지 않은 예외를 가장 파이써닉하지 않다고 생각하는 것 같다.

## 객체, 타입, 프로토콜
---
> 파이썬 객체 모델과 메커니즘을 설명하고, 다양한 객체의 핵심 동작을 정의하는 '프로토콜'을 특별히 주의해서 살펴보겠다.

### 객체의 고윳값과 타입
- `id()` : 보통 객체의 메모리 내 위치
- is, is not은 고윳값을 비교
- 그 외 `isinstance()`같은 것들이 있기는 하지만, 오버헤드가 있고 유사성 검사에 약한 부분이 있어 지양하는게 좋다고 한다.

### 가비지 컬렉션
- 객체의 참조 횟수는 del 문이 사용되거나, 참조가 유효 범위를 벗어나거나, 재할당 될 경우 감소한다.
- 참조횟수가 0이되면 가비지 컬렉션의 대상이 됨
- `sys.getrefcount()` 로 참조 횟수를 확인 할 수 있음
```python
a = {}
b = {}
a['b'] = b
b['a'] = a
del a
del b
```
- 이런경우 순환 가비지 컬렉터의 실행이 되기 전까지는 가비지컬렉션되지는 않음

### 참조와 복사
- 보통은 얕은 복사
- 별개의 리스트를 생성하는 것처럼 동작해도 요소는 공유되기때문에 변경을 일으킴
- `copy.deepcopy()`를 사용할 수 있기는 한데, 권장하지는 않음
> 흠...

### 1급 객체
- 파이썬에서 객체는 모두 1급
```python
line = 'ACME,100,490.10'
column_types = [str, int, float] # 이런거
row = [ty(val) for ty, val in zip(column_types, line.split(','))]
print(row)
```

```python
_formats = {
    'text' : TextFormatter,
    'csv' : CSVFormatter,
    'html' : HTMLFormatter
}

if format in _formats:
    formatter = _formats[format]()
else:
    raise RuntimeError('Unsupported format!')

```
- 이런 것들이 가능해진다. (아래는 정말 js스럽다)
> 최신 언어들의 표현력도 많이 올라가서 이게 장점이라거나 단점이라는 생각이 잘 들지는 않는 것 같다.

### None
- 싱글턴 인스턴스이다.
- `is None`을 쓸 수 있다.
- `== None`은 린트에 잡힌다.

### 객체 프로토콜과 데이터 추상화
- 대부분 프로토콜로 정의되어 있다는 것이 파이썬의 특징
> 정적 언어용 컴파일러와 달리 파이썬은 프로그램이 올바르게 동작할지 사전에 확인하지 않는다. 대신, 객체의 동작 방식은 ‘스페셜’ 또는 ‘마법’의 메서드라 부르는 디스패치(dispatch, 동적으로 실행되는 메서드)를 포함하는 동적 프로세스가 결정한다. 이러한 스페셜 메서드의 앞뒤에는 언제나 이중 밑줄이 온다.
- 디스패치는 실행 과정에서 호출 시 어떤 다형성 구현을 선택할지 결정하는 프로세스이다.

| **메서드명** | **시그니처**                                    | **설명**            |
| -------- | ------------------------------------------- | ----------------- |
| __new__  | def __new__(cls, *args, **kwargs) -> object | 인스턴스 생성 (클래스 메서드) |
| __init__ | def __init__(self, *args, **kwargs) -> None | 생성된 인스턴스 초기화      |
| __del__  | def __del__(self) -> None                   | 인스턴스가 삭제될 때 호출    |
| __repr__ | def __repr__(self) -> str                   | 객체의 표현 문자열 반환     |
### 숫자 프로토콜
- 특수한건 따로 없음
- 하위타입 때문에 피연산대상을 바꿔서 넣어줘야 하는 경우가 있는데 이런 경우도 알아서 `NotImplemented`를 보고 해줌

### 비교 프로토콜
- is는 프로토콜 포함이 아닌 인스턴스 고유값 비교 (재정의 불가)
- 그 외에는 comparator와(lt, gt), hash등 큰 차이 없는 것 같다.
- `functools` 모듈의 클래스 데코레이터를 추천한다.

### 변환 프로토콜
- str, bytes, bool, int 등 내장함수 사용을 위해 사용 할 수 있는 프로토콜 메서드들이 있다.

### 컨테이너 프로토콜
- 마찬가지로 내장함수와 특정 키워드들을 사용할 수 있게 해주는 프로토콜 (len, getitem, setitem, delitem, contains 등)

### 이터레이터 프로토콜
- js와 거의 동일
```python

s = 'Hello world'
_iter = s.__iter__()
while True:
    try:
        x = _iter.__next__()
    except StopIteration:
        break
    # for loop block의 내용들 실행

```

```python
class FRange:
    def __init__(self, start, stop, step):
        self.start = start
        self.stop = stop
        self.step = step

    def __iter__(self):
        x = self.start
        while x < self.stop:
            yield x
            x += self.step

nums = FRange(0.0, 1.0, 0.1)
for x in nums:
    print(x)

```
- 이런 부분들도 잘 됨

### 속성(attribute) 프로토콜
- 보일러 플레이트 용, 정확히 뭘 할지는 나중에 다시 나온다고 한다.

### 함수 프로토콜
- 그냥 `()`연산자가 call()을 호출하기에 따라 할 수 있다 정도

### 컨텍스트 관리자 프로토콜
- with 관련 프로토콜이고, 위에서 정리된게 전부이다.


## 파이써닉한 파이썬이라는것은..
- 결국 위와 같은 프로토콜을 잘 활용하는것?
- 구체적으로는
	- repl 잘 만들어두기
	- iterator protocol은 구현해두면 좋음
	- with를 잘 활용하기
- 정도를 거론한다.

## 함수
---
- 이런게 가능하다
```python
def func(*args, **kargs):
    # args 는 위치 인수 튜플
    # kargs는 위치 인수 튜플
    return

```
- 이렇게 해야 할 때도 있다..
```python
import time

def after(seconds, func, /, *args, **kargs):
    time.sleep(seconds)
    return func(*args, **kargs)

def duration(*, seconds, minutes, hours):
    return seconds + 60 * minutes + 3600 * hours

after(5, duration, seconds=20, minutes=3, hours=2)

```
- 스타일상 부작용이 있는 함수는 결과로 None을 반환하는것이 일반적이다.
- 중첩 함수 내의 변수 이름은 렉시컬 스코프에 묶이고, 체이닝도 한다. (지금 스코프부터 하나씩 밖으로 나가며 체이닝)
- `nonlocal`, `global`같은 변수 키워드로 다른 스코프 변수를 건들 수 있긴 하다.

### 람다
```python
# lamda args: expression
a = lamda x, y: x + y
r = a(2, 3)
```

- 클로저 주의, 함수 호출 시점의 환경을 바인딩함 (lazy binding)
```python
x = 2
f = lamda y: x * y
x = 3
g = lamda x: x * y

print(f(10)) # 30
print(g(10)) # 30

# 이렇게 해야함
# f = lambda y, x=x: x * y
# g = lambda y, x=x: x * y
```


```python
def make_greeting(names):
    funcs = []
    for name in names:
        funcs.append(lambda: print('Hello', name))
    return funcs

a, b, c = make_greeting(['Guido', "Ada", 'Margaret'])

# return funcs 시점의 name의 값이 바인딩
a() # Hello Margaret
b() # Hello Margaret
c() # Hello Margaret



def make_greeting_correct(names):
    funcs = []
    for name in names:
        funcs.append(lambda name=name: print('Hello', name))
    return funcs

a2, b2, c2 = make_greeting_correct(['Guido', "Ada", 'Margaret'])

# 직접 바인딩
a2()
b2()
c2()

```

### 콜백 함수에서 인수 전달

```python
import time

def add(x, y):
    return x + y


def after(seconds, func):
    time.sleep(seconds)
    func()

# after(10, add(2,3)) 안됨, 호출 시점에 호출됨

# 람다 thunk 사용
after(10, lambda: add(2,3))

# partial 사용
from functools import partial

after(10, partial(add, 2, 3))


# partial은 아래와 같은 것들도 가능
def func(a,b,c,d):
    print(a,b,c,d)

f = partial(func, 1, 2)
f(3,4) # func(1,2,3,4)
f(10, 20) # func(1,2,10,20)

# partial과 lamda의 차이
def func2(a,b):
    return a + b

a = 2
b = 3

f2 = lambda: func2(a,b)
g2 = partial(func2, a,b)

a = 10
b = 20
f2() # 30, 호출 시점의 a, b 바인딩
g2() # 5 partial 정의 시점의 a, b 바인딩

```
- 추가적으로 partial로 생성한 객체는 바이트로 직렬화도 가능하다. (lamda는 불가능)
