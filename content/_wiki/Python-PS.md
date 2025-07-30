---
title: Python PS 정리 🔄
summary: 
date: 2025-05-03 11:28:36 +0900
lastmod: 2025-07-30 11:16:55 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# 파이썬 PS 1단계: 기초 문법 완전정복

## 📥 1. 입출력 처리

### 기본 입력

```python
# 한 줄 입력
n = int(input())
s = input()
a, b = map(int, input().split())

# 여러 줄 입력
arr = []
for _ in range(n):
    arr.append(int(input()))

# 리스트 한번에 입력
numbers = list(map(int, input().split()))
```

### 빠른 입력 (sys.stdin)

```python
import sys
input = sys.stdin.readline

# 주의: readline()은 개행문자를 포함하므로
n = int(input())  # 숫자는 자동으로 개행문자 제거
s = input().strip()  # 문자열은 strip() 필요
```

### 출력 최적화

```python
# 기본 출력
print(result)
print(a, b, c)  # 공백으로 구분
print(a, b, c, sep=', ')  # 구분자 지정

# 빠른 출력 (대량 데이터)
import sys
print = sys.stdout.write
# 사용 시 개행문자 직접 추가 필요: print(str(result) + '\n')

# 여러 줄 출력
results = []
for i in range(n):
    results.append(str(i))
print('\n'.join(results))
```

### 🚨 입출력 주요 함정

- `input().split()`의 결과는 문자열 리스트
- `sys.stdin.readline()`은 개행문자 포함
- 대량 출력 시 `print()` 여러 번보다 한 번에 출력이 빠름

## 🔤 2. 문자열(String) 핵심 메서드

### 기본 조작

```python
s = "Hello World"

# 길이와 인덱싱
len(s)  # 11
s[0]    # 'H'
s[-1]   # 'd'
s[1:5]  # 'ello'

# 대소문자 변환
s.upper()      # 'HELLO WORLD'
s.lower()      # 'hello world'
s.capitalize() # 'Hello world'
s.title()      # 'Hello World'

# 공백 처리
s.strip()      # 양쪽 공백 제거
s.lstrip()     # 왼쪽 공백 제거
s.rstrip()     # 오른쪽 공백 제거
```

### 검색과 분할

```python
s = "hello world hello"

# 검색
s.find('world')     # 6 (첫 번째 인덱스)
s.find('xyz')       # -1 (없음)
s.index('world')    # 6 (없으면 ValueError)
s.count('hello')    # 2

# 분할과 결합
s.split()           # ['hello', 'world', 'hello']
s.split('l')        # ['he', '', 'o wor', 'd he', '', 'o']
' '.join(['a', 'b', 'c'])  # 'a b c'

# 치환
s.replace('hello', 'hi')  # 'hi world hi'
s.replace('l', 'L', 2)    # 'heLLo world hello' (최대 2개만)
```

### 판별 메서드

```python
# 문자 종류 판별
'123'.isdigit()      # True
'abc'.isalpha()      # True
'abc123'.isalnum()   # True
'   '.isspace()      # True

# 패턴 판별
'hello'.startswith('he')  # True
'world'.endswith('ld')    # True
```

### 🚨 문자열 주요 함정

- 문자열은 불변(immutable) → 수정 시 새 객체 생성
- `split()`과 `split(' ')`는 다름 (연속 공백 처리 방식)
- 대량 문자열 연결 시 `''.join(list)`가 `+` 연산보다 빠름

## 📋 3. 리스트(List) 핵심 메서드

### 기본 생성과 조작

```python
# 생성
arr = [1, 2, 3, 4, 5]
arr2 = [0] * n  # 크기 n인 0으로 초기화된 리스트
matrix = [[0] * m for _ in range(n)]  # 2차원 리스트

# 추가와 삭제
arr.append(6)        # 끝에 추가: [1,2,3,4,5,6]
arr.insert(0, 0)     # 인덱스 0에 삽입: [0,1,2,3,4,5,6]
arr.extend([7, 8])   # 리스트 확장: [0,1,2,3,4,5,6,7,8]

arr.pop()            # 마지막 요소 제거 후 반환: 8
arr.pop(0)           # 인덱스 0 요소 제거 후 반환: 0
arr.remove(3)        # 값 3인 첫 번째 요소 제거
```

### 정렬과 검색

```python
arr = [3, 1, 4, 1, 5]

# 정렬
arr.sort()                    # 원본 수정: [1,1,3,4,5]
sorted_arr = sorted(arr)      # 새 리스트 반환
arr.sort(reverse=True)        # 내림차순: [5,4,3,1,1]
arr.sort(key=len)            # 문자열 길이로 정렬

# 검색
arr.index(4)         # 4의 인덱스: 2
arr.count(1)         # 1의 개수: 2
4 in arr            # True
```

### 슬라이싱과 복사

```python
arr = [1, 2, 3, 4, 5]

# 슬라이싱
arr[1:4]        # [2, 3, 4]
arr[:3]         # [1, 2, 3]
arr[2:]         # [3, 4, 5]
arr[::2]        # [1, 3, 5] (2칸씩)
arr[::-1]       # [5, 4, 3, 2, 1] (뒤집기)

# 복사
shallow = arr[:]           # 얕은 복사
deep = [x for x in arr]    # 리스트 컴프리헨션으로 복사
import copy
deep_copy = copy.deepcopy(arr)  # 깊은 복사
```

### 리스트 컴프리헨션

```python
# 기본 형태
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]

# 중첩 루프
pairs = [(x, y) for x in range(3) for y in range(3)]

# 조건부 표현식
result = [x if x > 0 else 0 for x in [-1, 2, -3, 4]]
```

### 🚨 리스트 주요 함정

- `[[0] * m] * n`은 같은 리스트 객체를 n번 참조 (얕은 복사)
- `sort()`는 원본 수정, `sorted()`는 새 리스트 반환
- 리스트 중간 삽입/삭제는 O(n) 시간복잡도

## 📖 4. 딕셔너리(Dictionary) 핵심 메서드

### 기본 조작

```python
# 생성
d = {'a': 1, 'b': 2}
d2 = dict(a=1, b=2)
d3 = dict([('a', 1), ('b', 2)])

# 접근과 수정
d['a']              # 1
d.get('c', 0)       # 키 'c'가 없으면 0 반환
d['c'] = 3          # 새 키-값 추가
d.update({'d': 4, 'e': 5})  # 여러 키-값 추가
```

### 조회와 순회

```python
d = {'a': 1, 'b': 2, 'c': 3}

# 키, 값, 항목 조회
d.keys()           # dict_keys(['a', 'b', 'c'])
d.values()         # dict_values([1, 2, 3])
d.items()          # dict_items([('a', 1), ('b', 2), ('c', 3)])

# 순회
for key in d:              # 키 순회
    print(key, d[key])

for key, value in d.items():  # 키-값 쌍 순회
    print(key, value)

# 존재 확인
'a' in d           # True (키 존재 확인)
1 in d.values()    # True (값 존재 확인)
```

### 고급 활용

```python
# defaultdict 활용
from collections import defaultdict
dd = defaultdict(int)  # 기본값 0
dd = defaultdict(list) # 기본값 빈 리스트

# Counter 활용
from collections import Counter
counter = Counter([1, 2, 2, 3, 3, 3])
# Counter({3: 3, 2: 2, 1: 1})
counter.most_common(2)  # [(3, 3), (2, 2)]

# 딕셔너리 컴프리헨션
squares = {x: x**2 for x in range(5)}
filtered = {k: v for k, v in d.items() if v > 1}
```

### 🚨 딕셔너리 주요 함정

- 존재하지 않는 키 접근 시 KeyError → `get()` 사용 권장
- Python 3.7+ 에서 딕셔너리는 삽입 순서 보장
- 순회 중 딕셔너리 크기 변경 시 오류 발생 가능

## 🔢 5. 집합(Set) 핵심 메서드

### 기본 조작

```python
# 생성
s = {1, 2, 3, 4, 5}
s2 = set([1, 2, 2, 3, 3])  # {1, 2, 3} (중복 제거)
empty_set = set()          # 빈 집합 ({}는 딕셔너리)

# 추가와 제거
s.add(6)           # 요소 추가
s.update([7, 8])   # 여러 요소 추가
s.remove(5)        # 요소 제거 (없으면 KeyError)
s.discard(5)       # 요소 제거 (없어도 오류 없음)
s.pop()            # 임의 요소 제거 후 반환
s.clear()          # 모든 요소 제거
```

### 집합 연산

```python
a = {1, 2, 3, 4}
b = {3, 4, 5, 6}

# 합집합
a | b              # {1, 2, 3, 4, 5, 6}
a.union(b)

# 교집합
a & b              # {3, 4}
a.intersection(b)

# 차집합
a - b              # {1, 2}
a.difference(b)

# 대칭차집합
a ^ b              # {1, 2, 5, 6}
a.symmetric_difference(b)

# 부분집합 판별
{1, 2}.issubset({1, 2, 3})     # True
{1, 2, 3}.issuperset({1, 2})   # True
```

### 🚨 집합 주요 함정

- 빈 집합은 `set()`, `{}`는 빈 딕셔너리
- 집합은 순서가 없음 → 인덱싱 불가
- 해시 가능한 객체만 저장 가능 (list는 불가, tuple은 가능)

## 🔄 6. 조건문과 반복문 고급 활용

### 조건문 최적화

```python
# 삼항 연산자
result = value if condition else default

# 다중 조건
if a < b < c:  # a < b and b < c와 동일
    pass

# in 연산자 활용
if x in [1, 2, 3, 4, 5]:  # 리스트보다 집합이 빠름
if x in {1, 2, 3, 4, 5}:  # O(1) vs O(n)
```

### 반복문 패턴

```python
# enumerate로 인덱스와 값 동시 순회
for i, value in enumerate(arr):
    print(f"Index {i}: {value}")

# zip으로 여러 리스트 동시 순회
names = ['Alice', 'Bob', 'Charlie']
ages = [25, 30, 35]
for name, age in zip(names, ages):
    print(f"{name} is {age} years old")

# range 활용
for i in range(10):        # 0~9
for i in range(1, 11):     # 1~10
for i in range(0, 10, 2):  # 0,2,4,6,8

# 역순 반복
for i in range(n-1, -1, -1):  # n-1부터 0까지
for i in reversed(range(n)):   # 위와 동일
```

### 반복 제어

```python
# break와 continue
for i in range(10):
    if i == 3:
        continue  # 3은 건너뛰기
    if i == 7:
        break     # 7에서 종료
    print(i)

# else절 활용 (break로 종료되지 않았을 때만 실행)
for i in range(5):
    if i == 10:  # 이 조건은 만족되지 않음
        break
else:
    print("반복문이 완전히 종료됨")  # 실행됨
```

## ⚡ 7. 함수와 람다 표현식

### 함수 정의와 활용

```python
# 기본 함수
def gcd(a, b):
    while b:
        a, b = b, a % b
    return a

# 기본값 매개변수
def power(base, exp=2):
    return base ** exp

# 가변 인수
def sum_all(*args):
    return sum(args)

def print_info(**kwargs):
    for key, value in kwargs.items():
        print(f"{key}: {value}")
```

### 람다 표현식

```python
# 기본 람다
square = lambda x: x ** 2
add = lambda x, y: x + y

# 정렬에서 람다 활용
students = [('Alice', 85), ('Bob', 90), ('Charlie', 78)]
students.sort(key=lambda x: x[1])  # 점수로 정렬

# map, filter, reduce와 함께
numbers = [1, 2, 3, 4, 5]
squares = list(map(lambda x: x**2, numbers))
evens = list(filter(lambda x: x % 2 == 0, numbers))

from functools import reduce
product = reduce(lambda x, y: x * y, numbers)
```

### 내장 함수 활용

```python
# 수학 함수
abs(-5)          # 5
min(1, 2, 3)     # 1
max([1, 2, 3])   # 3
sum([1, 2, 3])   # 6
pow(2, 3)        # 8

# 형변환
int('123')       # 123
float('3.14')    # 3.14
str(123)         # '123'
bool(0)          # False

# 유용한 함수들
len([1, 2, 3])   # 3
type(123)        # <class 'int'>
isinstance(123, int)  # True
```

## 🛡️ 8. 예외처리 기본

### try-except 패턴

```python
# 기본 예외처리
try:
    result = 10 / 0
except ZeroDivisionError:
    result = 0

# 여러 예외 처리
try:
    value = int(input())
    result = 10 / value
except (ValueError, ZeroDivisionError) as e:
    print(f"오류 발생: {e}")
    result = 0

# else와 finally
try:
    file = open('data.txt', 'r')
except FileNotFoundError:
    print("파일을 찾을 수 없습니다")
else:
    data = file.read()  # 예외가 없을 때만 실행
finally:
    if 'file' in locals():
        file.close()    # 항상 실행
```

### PS에서 자주 사용하는 예외처리

```python
# 안전한 입력 처리
def safe_input():
    try:
        return int(input())
    except:
        return 0

# 리스트 인덱스 안전 접근
def safe_get(lst, index, default=None):
    try:
        return lst[index]
    except IndexError:
        return default

# 딕셔너리 안전 접근 (get() 메서드가 더 나음)
def safe_dict_get(d, key, default=0):
    try:
        return d[key]
    except KeyError:
        return default
```

## 📝 1단계 핵심 요약

### 꼭 기억해야 할 패턴

1. **빠른 입출력**: `sys.stdin.readline`과 `strip()`
2. **문자열 처리**: `split()`, `join()`, `replace()`
3. **리스트 조작**: 컴프리헨션, 슬라이싱, `sort()` vs `sorted()`
4. **딕셔너리**: `get()`, `defaultdict`, `Counter`
5. **집합 연산**: 중복 제거, 교집합/합집합
6. **반복문**: `enumerate()`, `zip()`, `range()`

### 자주 하는 실수들

- 2차원 리스트 생성 시 얕은 복사
- 문자열 불변성 무시
- 딕셔너리 KeyError
- 빈 집합을 `{}`로 생성
- `input()`과 `sys.stdin.readline()`의 차이점

# 파이썬 PS 2단계: 다른 언어 개발자를 위한 파이썬 특화 기법

## 🔀 1. 분기문과 제어문 - 파이썬만의 특징

### 조건문의 파이썬스러운 표현

#### 삼항 연산자 (Ternary Operator)

```python
# 기본 형태
result = value_if_true if condition else value_if_false

# 실용 예시
max_val = a if a > b else b
status = "pass" if score >= 60 else "fail"
sign = 1 if num >= 0 else -1

# 중첩 삼항 연산자 (권장하지 않음)
grade = "A" if score >= 90 else "B" if score >= 80 else "C"

# Java/C++ 개발자 주의: 파이썬은 ? : 연산자가 없음
# Java: int result = condition ? value1 : value2;
# Python: result = value1 if condition else value2
```

#### Truthy/Falsy 값 활용

```python
# 파이썬에서 False로 평가되는 값들
falsy_values = [False, None, 0, 0.0, '', [], {}, set()]

# 실용적인 활용
def process_data(data):
    if not data:  # 빈 리스트, None, 빈 문자열 모두 처리
        return "No data"
    return f"Processing {len(data)} items"

# 기본값 설정 패턴
name = input_name or "Anonymous"  # input_name이 빈 문자열이면 "Anonymous"
items = user_items or []          # user_items가 None이면 빈 리스트

# Java/C++과 다른 점: 0, 빈 컬렉션도 False
# Java: if (list.size() > 0) vs Python: if list:
```

#### 체이닝 비교 (Chained Comparisons)

```python
# 파이썬만의 독특한 기능
age = 25
if 18 <= age < 65:  # Java/C++: if (age >= 18 && age < 65)
    print("Working age")

# 여러 조건 체이닝
if a < b < c < d:  # 모든 부등호가 성립해야 함
    print("Ascending order")

# 실용 예시
def is_valid_score(score):
    return 0 <= score <= 100

def is_triangle(a, b, c):
    return a + b > c and b + c > a and c + a > b

# 주의: 복잡한 체이닝은 가독성을 해칠 수 있음
```

### match-case 문 (Python 3.10+)

```python
# Switch-case의 파이썬 버전
def handle_http_status(status):
    match status:
        case 200:
            return "OK"
        case 404:
            return "Not Found"
        case 500 | 502 | 503:  # 여러 값 매칭
            return "Server Error"
        case status if 400 <= status < 500:  # 조건부 매칭
            return "Client Error"
        case _:  # default case
            return "Unknown Status"

# 패턴 매칭 활용
def process_data(data):
    match data:
        case []:  # 빈 리스트
            return "Empty list"
        case [x]:  # 원소 하나인 리스트
            return f"Single item: {x}"
        case [x, y]:  # 원소 두 개인 리스트
            return f"Two items: {x}, {y}"
        case [x, *rest]:  # 첫 번째 원소와 나머지
            return f"First: {x}, Rest: {rest}"
        case {"type": "user", "name": name}:  # 딕셔너리 패턴
            return f"User: {name}"
        case _:
            return "Unknown pattern"
```

## 🔄 2. 반복문 - 파이썬의 강력한 이터레이션

### for문의 다양한 활용

```python
# 기본 for문 (Java/C++와 다른 점)
# Java: for(int i = 0; i < 10; i++)
# Python: for i in range(10)

# 인덱스와 값 동시 접근
fruits = ['apple', 'banana', 'cherry']
for i, fruit in enumerate(fruits):
    print(f"{i}: {fruit}")

# 시작 인덱스 지정
for i, fruit in enumerate(fruits, 1):  # 1부터 시작
    print(f"{i}: {fruit}")

# 여러 시퀀스 동시 순회
names = ['Alice', 'Bob', 'Charlie']
ages = [25, 30, 35]
for name, age in zip(names, ages):
    print(f"{name} is {age} years old")

# 길이가 다른 시퀀스 처리
from itertools import zip_longest
for name, age in zip_longest(names, ages, fillvalue="Unknown"):
    print(f"{name}: {age}")
```

### range의 고급 활용

```python
# 기본 range 패턴
for i in range(10):        # 0~9
    pass

for i in range(1, 11):     # 1~10
    pass

for i in range(0, 10, 2):  # 0,2,4,6,8 (step=2)
    pass

# 역순 반복
for i in range(10, 0, -1):    # 10,9,8,...,1
    pass

for i in reversed(range(10)): # 9,8,7,...,0
    pass

# 실용적인 패턴들
# 2차원 배열 순회
matrix = [[1,2,3], [4,5,6], [7,8,9]]
for i in range(len(matrix)):
    for j in range(len(matrix[i])):
        print(matrix[i][j])

# 더 파이썬스러운 방법
for row in matrix:
    for cell in row:
        print(cell)

# 인덱스가 필요한 경우
for i, row in enumerate(matrix):
    for j, cell in enumerate(row):
        print(f"matrix[{i}][{j}] = {cell}")
```

### while문과 제어

```python
# while-else 패턴 (다른 언어에 없는 기능)
def find_factor(n):
    i = 2
    while i * i <= n:
        if n % i == 0:
            print(f"Found factor: {i}")
            break
        i += 1
    else:  # break로 빠져나오지 않았을 때 실행
        print(f"{n} is prime")

# for-else도 동일하게 작동
def search_item(items, target):
    for item in items:
        if item == target:
            print(f"Found {target}")
            break
    else:
        print(f"{target} not found")

# 무한루프 패턴
while True:
    user_input = input("Enter command (quit to exit): ")
    if user_input == "quit":
        break
    process_command(user_input)
```

## 🍬 3. 슈가 신택스 (Syntactic Sugar)

### 리스트 컴프리헨션의 고급 활용

```python
# 기본 컴프리헨션
squares = [x**2 for x in range(10)]
evens = [x for x in range(20) if x % 2 == 0]

# 중첩 루프 컴프리헨션
matrix = [[i+j for j in range(3)] for i in range(3)]
# 결과: [[0,1,2], [1,2,3], [2,3,4]]

# 조건부 표현식과 함께
result = [x if x > 0 else 0 for x in [-1, 2, -3, 4]]

# 복잡한 조건
filtered = [x for x in range(100) 
           if x % 2 == 0 and x % 3 == 0 and x > 10]

# 중첩 리스트 평탄화
nested = [[1, 2], [3, 4], [5, 6]]
flattened = [item for sublist in nested for item in sublist]
# 결과: [1, 2, 3, 4, 5, 6]

# 문자열 처리
words = ["hello", "world", "python"]
lengths = [len(word) for word in words]
capitals = [word.upper() for word in words if len(word) > 4]
```

### 딕셔너리와 집합 컴프리헨션

```python
# 딕셔너리 컴프리헨션
squares_dict = {x: x**2 for x in range(5)}
# 결과: {0: 0, 1: 1, 2: 4, 3: 9, 4: 16}

# 조건부 딕셔너리 컴프리헨션
word_lengths = {word: len(word) for word in words if len(word) > 3}

# 딕셔너리 변환
original = {'a': 1, 'b': 2, 'c': 3}
reversed_dict = {v: k for k, v in original.items()}

# 집합 컴프리헨션
unique_lengths = {len(word) for word in words}

# 실용적인 예시: 단어 빈도 계산
text = "hello world hello python world"
word_count = {word: text.split().count(word) for word in set(text.split())}
```

### 언패킹과 패킹

```python
# 기본 언패킹
point = (3, 4)
x, y = point

# 확장 언패킹 (Python 3+)
numbers = [1, 2, 3, 4, 5]
first, *middle, last = numbers  # first=1, middle=[2,3,4], last=5
first, second, *rest = numbers  # first=1, second=2, rest=[3,4,5]

# 함수 인수 언패킹
def greet(name, age, city):
    print(f"Hello {name}, {age} years old from {city}")

person = ("Alice", 25, "Seoul")
greet(*person)  # 튜플 언패킹

person_dict = {"name": "Bob", "age": 30, "city": "Busan"}
greet(**person_dict)  # 딕셔너리 언패킹

# 변수 교환
a, b = b, a  # Java/C++: temp = a; a = b; b = temp;

# 여러 변수 동시 할당
a = b = c = 0
x, y, z = 1, 2, 3
```

### Walrus 연산자 (:=) - Python 3.8+

```python
# 할당과 동시에 조건 검사
if (n := len(some_list)) > 10:
    print(f"List is too long ({n} elements)")

# while 루프에서 유용
while (line := input("Enter something: ")) != "quit":
    print(f"You entered: {line}")

# 리스트 컴프리헨션에서 중복 계산 방지
# 나쁜 예: expensive_function이 두 번 호출됨
results = [expensive_function(x) for x in data if expensive_function(x) > 0]

# 좋은 예: walrus 연산자로 한 번만 호출
results = [y for x in data if (y := expensive_function(x)) > 0]
```

## 🐍 4. 파이썬 특징적인 부분들

### 동적 타이핑의 활용

```python
# 같은 변수에 다른 타입 할당 가능 (Java/C++와 다름)
var = 42          # int
var = "hello"     # str
var = [1, 2, 3]   # list

# 타입 힌트 (Python 3.5+) - 실행에는 영향 없음
def greet(name: str, age: int) -> str:
    return f"Hello {name}, you are {age} years old"

# isinstance를 이용한 타입 체크
def process_input(data):
    if isinstance(data, str):
        return data.upper()
    elif isinstance(data, list):
        return len(data)
    elif isinstance(data, (int, float)):  # 여러 타입 체크
        return data * 2
    else:
        return None

# 덕 타이핑 (Duck Typing)
def print_items(container):
    # 리스트든 튜플이든 문자열이든 이터러블이면 작동
    for item in container:
        print(item)
```

### 다중 할당과 특수한 값들

```python
# None 값 처리 (Java의 null과 유사하지만 다름)
def safe_divide(a, b):
    return a / b if b != 0 else None

result = safe_divide(10, 0)
if result is not None:  # == None이 아닌 is를 사용
    print(f"Result: {result}")

# 다중 할당의 활용
def get_min_max(numbers):
    return min(numbers), max(numbers)

min_val, max_val = get_min_max([1, 5, 3, 9, 2])

# 언더스코어로 무시할 값 표시
_, max_val = get_min_max(numbers)  # 최솟값 무시
first, _, third = (1, 2, 3)       # 두 번째 값 무시
```

### 메서드 체이닝과 fluent interface

```python
# 문자열 메서드 체이닝
text = "  Hello World  "
result = text.strip().lower().replace(" ", "_")
# 결과: "hello_world"

# 리스트 메서드는 체이닝 불가 (대부분 None 반환)
# 나쁜 예
# numbers = [3, 1, 4, 1, 5].sort().reverse()  # AttributeError!

# 올바른 예
numbers = [3, 1, 4, 1, 5]
numbers.sort()
numbers.reverse()

# 또는 함수형 스타일
numbers = sorted([3, 1, 4, 1, 5], reverse=True)
```

### 컨텍스트 매니저 (with 문)

```python
# 파일 처리 (자동으로 파일 닫기)
with open('data.txt', 'r') as f:
    content = f.read()
# 파일이 자동으로 닫힘

# 여러 파일 동시 처리
with open('input.txt', 'r') as infile, open('output.txt', 'w') as outfile:
    outfile.write(infile.read().upper())

# 커스텀 컨텍스트 매니저
from contextlib import contextmanager

@contextmanager
def timer():
    import time
    start = time.time()
    print("Timer started")
    try:
        yield
    finally:
        end = time.time()
        print(f"Elapsed time: {end - start:.2f}s")

# 사용
with timer():
    # 시간을 측정할 코드
    time.sleep(1)
```

## 🔧 5. 함수형 프로그래밍과 람다

### 람다 함수의 다양한 활용

```python
# 기본 람다
square = lambda x: x ** 2
add = lambda x, y: x + y

# 정렬에서 람다 활용
students = [('Alice', 85), ('Bob', 90), ('Charlie', 78)]

# 이름으로 정렬
students.sort(key=lambda student: student[0])

# 점수로 정렬 (내림차순)
students.sort(key=lambda student: student[1], reverse=True)

# 복잡한 정렬 기준
data = [('A', 1, 100), ('B', 2, 85), ('A', 3, 95)]
# 첫 번째 필드로 정렬, 같으면 세 번째 필드로 정렬
data.sort(key=lambda x: (x[0], x[2]))

# 조건부 람다
get_grade = lambda score: 'A' if score >= 90 else 'B' if score >= 80 else 'C'
```

### map, filter, reduce 함수형 패턴

```python
# map: 모든 요소에 함수 적용
numbers = [1, 2, 3, 4, 5]
squares = list(map(lambda x: x**2, numbers))
# 결과: [1, 4, 9, 16, 25]

# 여러 시퀀스에 적용
nums1 = [1, 2, 3]
nums2 = [4, 5, 6]
sums = list(map(lambda x, y: x + y, nums1, nums2))
# 결과: [5, 7, 9]

# filter: 조건을 만족하는 요소만 선택
evens = list(filter(lambda x: x % 2 == 0, numbers))
# 결과: [2, 4]

# reduce: 누적 연산
from functools import reduce
product = reduce(lambda x, y: x * y, numbers)  # 1*2*3*4*5 = 120
max_val = reduce(lambda x, y: x if x > y else y, numbers)

# 실용적인 예시: 단어에서 모음 제거
def remove_vowels(text):
    vowels = "aeiouAEIOU"
    return ''.join(filter(lambda char: char not in vowels, text))

# 중첩 함수와 클로저
def make_multiplier(n):
    return lambda x: x * n

double = make_multiplier(2)
triple = make_multiplier(3)
print(double(5))  # 10
print(triple(5))  # 15
```

### 고차 함수 패턴

```python
# 함수를 인수로 받는 함수
def apply_operation(numbers, operation):
    return [operation(x) for x in numbers]

# 사용 예시
result1 = apply_operation([1, 2, 3, 4], lambda x: x**2)
result2 = apply_operation([1, 2, 3, 4], lambda x: x * 2)

# 함수를 반환하는 함수
def create_validator(min_val, max_val):
    def validator(value):
        return min_val <= value <= max_val
    return validator

age_validator = create_validator(0, 120)
score_validator = create_validator(0, 100)

# 데코레이터 기본 이해
def timing_decorator(func):
    def wrapper(*args, **kwargs):
        import time
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.4f}s")
        return result
    return wrapper

@timing_decorator
def slow_function():
    import time
    time.sleep(1)
    return "Done"
```

## 📊 6. 자료구조 유용한 패턴들

### 딕셔너리 고급 패턴

```python
# 패턴 1: 키가 있으면 값 증가, 없으면 1로 설정
# 방법 1: get() 사용
count = {}
for item in items:
    count[item] = count.get(item, 0) + 1

# 방법 2: setdefault() 사용
count = {}
for item in items:
    count.setdefault(item, 0)
    count[item] += 1

# 방법 3: defaultdict 사용 (가장 깔끔)
from collections import defaultdict
count = defaultdict(int)
for item in items:
    count[item] += 1

# 방법 4: Counter 사용 (가장 파이썬스러움)
from collections import Counter
count = Counter(items)

# 패턴 2: 그룹핑
# 학생들을 성적별로 그룹핑
students = [('Alice', 'A'), ('Bob', 'B'), ('Charlie', 'A'), ('David', 'B')]

# defaultdict로 그룹핑
from collections import defaultdict
groups = defaultdict(list)
for name, grade in students:
    groups[grade].append(name)
# 결과: {'A': ['Alice', 'Charlie'], 'B': ['Bob', 'David']}

# itertools.groupby 사용 (정렬된 데이터)
from itertools import groupby
students.sort(key=lambda x: x[1])  # 성적으로 정렬 먼저
groups = {grade: [name for name, _ in group] 
          for grade, group in groupby(students, key=lambda x: x[1])}
```

### 리스트와 큐, 스택 패턴

```python
# 스택 패턴 (LIFO)
stack = []
stack.append(1)    # push
stack.append(2)
item = stack.pop() # pop (2)

# 큐 패턴 (FIFO) - deque 사용 권장
from collections import deque
queue = deque()
queue.append(1)      # enqueue
queue.append(2)
item = queue.popleft()  # dequeue (1)

# 우선순위 큐
import heapq
heap = []
heapq.heappush(heap, (priority, item))
priority, item = heapq.heappop(heap)

# 최대 힙 구현 (음수 이용)
max_heap = []
heapq.heappush(max_heap, -value)
max_value = -heapq.heappop(max_heap)

# 리스트의 고급 조작
# 특정 조건의 모든 요소 제거
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
# 홀수만 남기기
numbers = [x for x in numbers if x % 2 == 1]

# 또는 filter 사용
numbers = list(filter(lambda x: x % 2 == 1, numbers))

# 리스트에서 중복 제거 (순서 유지)
def remove_duplicates(lst):
    seen = set()
    result = []
    for item in lst:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result

# 또는 dict.fromkeys() 트릭 (Python 3.7+)
unique_list = list(dict.fromkeys(original_list))
```

### 집합 연산 고급 활용

```python
# 집합의 강력한 연산들
set1 = {1, 2, 3, 4, 5}
set2 = {4, 5, 6, 7, 8}

# 교집합: 공통 원소
common = set1 & set2  # {4, 5}

# 합집합: 모든 원소
all_items = set1 | set2  # {1, 2, 3, 4, 5, 6, 7, 8}

# 차집합: set1에만 있는 원소
only_in_set1 = set1 - set2  # {1, 2, 3}

# 대칭차집합: 둘 중 하나에만 있는 원소
symmetric_diff = set1 ^ set2  # {1, 2, 3, 6, 7, 8}

# 실용적인 활용: 두 리스트의 공통 원소 찾기
list1 = [1, 2, 3, 4, 5]
list2 = [4, 5, 6, 7, 8]
common_elements = list(set(list1) & set(list2))

# 중복 원소 찾기
def find_duplicates(lst):
    seen = set()
    duplicates = set()
    for item in lst:
        if item in seen:
            duplicates.add(item)
        else:
            seen.add(item)
    return list(duplicates)
```

### collections 모듈의 특수 자료구조

```python
from collections import namedtuple, OrderedDict, ChainMap

# namedtuple: 필드명이 있는 튜플
Point = namedtuple('Point', ['x', 'y'])
p = Point(3, 4)
print(p.x, p.y)  # 3 4
print(p[0], p[1])  # 3 4 (인덱스로도 접근 가능)

# Student 예시
Student = namedtuple('Student', ['name', 'age', 'grade'])
alice = Student('Alice', 20, 'A')
print(f"{alice.name} got {alice.grade}")

# OrderedDict: 삽입 순서 유지 (Python 3.7+에서는 일반 dict도 순서 유지)
from collections import OrderedDict
ordered = OrderedDict()
ordered['first'] = 1
ordered['second'] = 2
ordered['third'] = 3

# ChainMap: 여러 딕셔너리를 하나처럼 사용
default_config = {'timeout': 30, 'retries': 3}
user_config = {'timeout': 60}
config = ChainMap(user_config, default_config)
print(config['timeout'])  # 60 (user_config가 우선)
print(config['retries'])  # 3 (default_config에서)
```

## 🎯 7. 실전 활용 패턴 모음

### 파일 처리 패턴

```python
# 파일 읽기 패턴들
# 전체 파일 읽기
with open('file.txt', 'r', encoding='utf-8') as f:
    content = f.read()

# 줄 단위로 읽기
with open('file.txt', 'r', encoding='utf-8') as f:
    lines = f.readlines()  # 개행문자 포함
    lines = [line.strip() for line in lines]  # 개행문자 제거

# 한 줄씩 처리 (메모리 효율적)
with open('file.txt', 'r', encoding='utf-8') as f:
    for line in f:
        process_line(line.strip())

# CSV 처리
import csv
with open('data.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row['name'], row['age'])
```

### 에러 처리 패턴

```python
# 기본 try-except 패턴
try:
    result = risky_operation()
except SpecificError as e:
    handle_specific_error(e)
except (ErrorType1, ErrorType2) as e:
    handle_multiple_errors(e)
except Exception as e:
    handle_generic_error(e)
else:
    # 예외가 발생하지 않았을 때
    success_handler(result)
finally:
    # 항상 실행
    cleanup()

# EAFP (Easier to Ask for Forgiveness than Permission) 패턴
# 파이썬스러운 방법
try:
    return my_dict[key]
except KeyError:
    return default_value

# vs LBYL (Look Before You Leap) - 덜 파이썬스러움
if key in my_dict:
    return my_dict[key]
else:
    return default_value
```

### 성능 최적화 팁

```python
# 문자열 연결 최적화
# 나쁜 예 (O(n²))
result = ""
for word in words:
    result += word + " "

# 좋은 예 (O(n))
result = " ".join(words)

# 리스트 내포 vs map/filter
# 리스트 내포가 일반적으로 더 빠름
squares1 = [x**2 for x in range(1000)]
squares2 = list(map(lambda x: x**2, range(1000)))

# 집합 멤버십 테스트
# 리스트: O(n), 집합: O(1)
large_list = list(range(10000))
large_set = set(range(10000))

# 느림
if 9999 in large_list:
    pass

# 빠름
if 9999 in large_set:
    pass

# 딕셔너리 vs 리스트 검색
# key로 검색할 때는 딕셔너리가 훨씬 빠름
data_dict = {i: f"value_{i}" for i in range(1000)}
data_list = [(i, f"value_{i}") for i in range(1000)]
```

## 📝 3단계 핵심 요약

### Java/C++ 개발자가 주의할 점

1. **타입 시스템**: 동적 타이핑, isinstance() 활용
2. **반복문**: range() 사용법, enumerate/zip 활용
3. **조건문**: Truthy/Falsy 개념, 체이닝 비교
4. **메모리 관리**: 가비지 컬렉션 자동, with문 활용

### 파이썬다운 코딩 스타일

1. **EAFP over LBYL**: 예외 처리 우선
2. **컴프리헨션 활용**: 리스트/딕셔너리/집합 컴프리헨션
3. **언패킹 활용**: 튜플/딕셔너리 언패킹
4. **내장 함수 활용**: map, filter, zip, enumerate

### 자주 사용하는 패턴 체크리스트

- [ ] `collections.Counter`로 빈도 계산
- [ ] `collections.defaultdict`로 그룹핑
- [ ] `enumerate()`로 인덱스와 값 동시 접근
- [ ] `zip()`으로 여러 시퀀스 동시 순회
- [ ] 리스트 컴프리헨션으로 변환과 필터링
- [ ] `any()`/`all()`로 조건 검사
- [ ] `*args`/`**kwargs`로 가변 인수 처리



# 파이썬 PS 3단계: PS 핵심 패턴

## 🔍 1. 탐색 알고리즘 (DFS/BFS 템플릿)

### DFS (깊이 우선 탐색)

#### 재귀적 DFS

```python
def dfs_recursive(graph, start, visited=None):
    if visited is None:
        visited = set()
    
    visited.add(start)
    print(start)  # 방문 처리
    
    for neighbor in graph[start]:
        if neighbor not in visited:
            dfs_recursive(graph, neighbor, visited)
    
    return visited

# 사용 예시
graph = {
    'A': ['B', 'C'],
    'B': ['A', 'D', 'E'],
    'C': ['A', 'F'],
    'D': ['B'],
    'E': ['B', 'F'],
    'F': ['C', 'E']
}
```

#### 스택을 이용한 DFS

```python
def dfs_iterative(graph, start):
    visited = set()
    stack = [start]
    
    while stack:
        vertex = stack.pop()
        if vertex not in visited:
            visited.add(vertex)
            print(vertex)  # 방문 처리
            
            # 역순으로 추가 (재귀와 같은 순서로 방문하기 위해)
            for neighbor in reversed(graph[vertex]):
                if neighbor not in visited:
                    stack.append(neighbor)
    
    return visited
```

#### 2차원 격자에서 DFS

```python
def dfs_grid(grid, start_row, start_col, visited):
    rows, cols = len(grid), len(grid[0])
    
    # 경계 체크 및 방문 체크
    if (start_row < 0 or start_row >= rows or 
        start_col < 0 or start_col >= cols or
        visited[start_row][start_col] or 
        grid[start_row][start_col] == 0):  # 0은 벽이라 가정
        return
    
    visited[start_row][start_col] = True
    print(f"방문: ({start_row}, {start_col})")
    
    # 4방향 탐색 (상, 하, 좌, 우)
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    for dr, dc in directions:
        dfs_grid(grid, start_row + dr, start_col + dc, visited)

# 사용 예시
grid = [
    [1, 1, 0, 1],
    [1, 0, 1, 1],
    [0, 1, 1, 1],
    [1, 1, 1, 0]
]
visited = [[False] * len(grid[0]) for _ in range(len(grid))]
```

### BFS (너비 우선 탐색)

#### 기본 BFS

```python
from collections import deque

def bfs(graph, start):
    visited = set()
    queue = deque([start])
    visited.add(start)
    
    while queue:
        vertex = queue.popleft()
        print(vertex)  # 방문 처리
        
        for neighbor in graph[vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)
    
    return visited
```

#### 최단거리를 구하는 BFS

```python
def bfs_shortest_path(graph, start, end):
    visited = set()
    queue = deque([(start, 0)])  # (노드, 거리)
    visited.add(start)
    
    while queue:
        vertex, distance = queue.popleft()
        
        if vertex == end:
            return distance
        
        for neighbor in graph[vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, distance + 1))
    
    return -1  # 경로가 없음
```

#### 2차원 격자에서 BFS

```python
def bfs_grid(grid, start_row, start_col):
    rows, cols = len(grid), len(grid[0])
    visited = [[False] * cols for _ in range(rows)]
    queue = deque([(start_row, start_col, 0)])  # (행, 열, 거리)
    visited[start_row][start_col] = True
    
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    
    while queue:
        row, col, dist = queue.popleft()
        print(f"방문: ({row}, {col}), 거리: {dist}")
        
        for dr, dc in directions:
            new_row, new_col = row + dr, col + dc
            
            if (0 <= new_row < rows and 0 <= new_col < cols and
                not visited[new_row][new_col] and 
                grid[new_row][new_col] == 1):  # 1은 이동 가능한 칸
                
                visited[new_row][new_col] = True
                queue.append((new_row, new_col, dist + 1))
```

### 🚨 DFS/BFS 주요 함정

- 재귀 DFS의 스택 오버플로우 (Python 기본 재귀 한도: 1000)
- `sys.setrecursionlimit(10**6)` 설정 필요한 경우
- BFS에서 `deque` 사용 필수 (list의 pop(0)은 O(n))
- 방문 체크를 큐에 넣을 때 vs 큐에서 뺄 때의 차이점

## 📊 2. 정렬과 이진탐색 패턴

### 다양한 정렬 기법

#### 기본 정렬

```python
# 리스트 정렬
arr = [3, 1, 4, 1, 5, 9, 2, 6]
arr.sort()                    # 원본 수정
sorted_arr = sorted(arr)      # 새 리스트 반환

# 역순 정렬
arr.sort(reverse=True)
```

#### 커스텀 정렬

```python
# 튜플 정렬 (여러 기준)
students = [('Alice', 85, 20), ('Bob', 90, 19), ('Charlie', 85, 21)]

# 점수 내림차순, 같으면 나이 오름차순
students.sort(key=lambda x: (-x[1], x[2]))

# 문자열 길이로 정렬
words = ['apple', 'pie', 'banana', 'book']
words.sort(key=len)

# 절댓값으로 정렬
numbers = [-3, -1, 4, -5, 2]
numbers.sort(key=abs)
```

#### 안정 정렬 vs 불안정 정렬

```python
# Python의 sort()는 stable sort (같은 값의 원래 순서 유지)
data = [('A', 1), ('B', 2), ('C', 1), ('D', 2)]
data.sort(key=lambda x: x[1])
# 결과: [('A', 1), ('C', 1), ('B', 2), ('D', 2)]
# A와 C의 순서, B와 D의 순서가 유지됨
```

### 이진탐색 (Binary Search)

#### 기본 이진탐색

```python
def binary_search(arr, target):
    left, right = 0, len(arr) - 1
    
    while left <= right:
        mid = (left + right) // 2
        
        if arr[mid] == target:
            return mid
        elif arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1
    
    return -1  # 찾지 못함

# 내장 함수 사용
import bisect
arr = [1, 3, 5, 7, 9]
index = bisect.bisect_left(arr, 5)  # 5가 들어갈 위치
```

#### Lower Bound / Upper Bound

```python
def lower_bound(arr, target):
    """target 이상인 첫 번째 원소의 인덱스"""
    left, right = 0, len(arr)
    
    while left < right:
        mid = (left + right) // 2
        if arr[mid] < target:
            left = mid + 1
        else:
            right = mid
    
    return left

def upper_bound(arr, target):
    """target 초과인 첫 번째 원소의 인덱스"""
    left, right = 0, len(arr)
    
    while left < right:
        mid = (left + right) // 2
        if arr[mid] <= target:
            left = mid + 1
        else:
            right = mid
    
    return left

# bisect 모듈 활용
import bisect
arr = [1, 2, 2, 2, 3, 4, 5]
lower = bisect.bisect_left(arr, 2)   # 1
upper = bisect.bisect_right(arr, 2)  # 4
count = upper - lower                # 2의 개수: 3
```

#### 매개변수 탐색 (Parametric Search)

```python
def parametric_search(check_function, left, right):
    """
    check_function(x)가 True가 되는 최소값을 찾는 이진탐색
    """
    result = right + 1
    
    while left <= right:
        mid = (left + right) // 2
        
        if check_function(mid):
            result = mid
            right = mid - 1
        else:
            left = mid + 1
    
    return result

# 예시: 나무 자르기 문제
def can_cut_wood(trees, height, target):
    """높이 height로 잘랐을 때 target 이상의 나무를 얻을 수 있는지"""
    total = sum(max(0, tree - height) for tree in trees)
    return total >= target

trees = [20, 15, 10, 17]
target = 7
max_height = parametric_search(
    lambda h: can_cut_wood(trees, h, target), 
    0, max(trees)
)
```

### 🚨 정렬/이진탐색 주요 함정

- 이진탐색 전 반드시 정렬 필요
- `left <= right` vs `left < right` 조건 차이
- 무한루프 방지를 위한 mid 계산 주의
- overflow 방지: `mid = left + (right - left) // 2`

## 👥 3. 투 포인터, 슬라이딩 윈도우

### 투 포인터 기법

#### 기본 투 포인터

```python
def two_sum_sorted(arr, target):
    """정렬된 배열에서 합이 target인 두 수 찾기"""
    left, right = 0, len(arr) - 1
    
    while left < right:
        current_sum = arr[left] + arr[right]
        
        if current_sum == target:
            return [left, right]
        elif current_sum < target:
            left += 1
        else:
            right -= 1
    
    return [-1, -1]  # 찾지 못함
```

#### 연속 부분배열의 합

```python
def subarray_sum(arr, target):
    """합이 target인 연속 부분배열의 개수"""
    left = 0
    current_sum = 0
    count = 0
    
    for right in range(len(arr)):
        current_sum += arr[right]
        
        # 합이 target보다 클 때 left 포인터 이동
        while current_sum > target and left <= right:
            current_sum -= arr[left]
            left += 1
        
        if current_sum == target:
            count += 1
    
    return count
```

#### 서로 다른 문자의 최장 부분문자열

```python
def longest_unique_substring(s):
    """서로 다른 문자로만 이루어진 최장 부분문자열의 길이"""
    left = 0
    max_length = 0
    char_set = set()
    
    for right in range(len(s)):
        # 중복 문자가 나올 때까지 left 이동
        while s[right] in char_set:
            char_set.remove(s[left])
            left += 1
        
        char_set.add(s[right])
        max_length = max(max_length, right - left + 1)
    
    return max_length
```

### 슬라이딩 윈도우

#### 고정 크기 윈도우

```python
def max_sum_subarray(arr, k):
    """크기가 k인 부분배열의 최대 합"""
    if len(arr) < k:
        return -1
    
    # 첫 번째 윈도우의 합
    window_sum = sum(arr[:k])
    max_sum = window_sum
    
    # 윈도우를 슬라이딩하면서 합 계산
    for i in range(k, len(arr)):
        window_sum = window_sum - arr[i - k] + arr[i]
        max_sum = max(max_sum, window_sum)
    
    return max_sum
```

#### 가변 크기 윈도우

```python
def min_window_sum(arr, target):
    """합이 target 이상인 최소 길이 부분배열"""
    left = 0
    min_length = float('inf')
    current_sum = 0
    
    for right in range(len(arr)):
        current_sum += arr[right]
        
        # 조건을 만족하는 동안 윈도우 크기 줄이기
        while current_sum >= target:
            min_length = min(min_length, right - left + 1)
            current_sum -= arr[left]
            left += 1
    
    return min_length if min_length != float('inf') else 0
```

#### 문자열에서 패턴 매칭

```python
def find_anagrams(s, p):
    """문자열 s에서 p의 anagram인 부분문자열의 시작 인덱스들"""
    from collections import Counter
    
    if len(p) > len(s):
        return []
    
    p_count = Counter(p)
    window_count = Counter()
    result = []
    
    for i in range(len(s)):
        # 윈도우에 문자 추가
        window_count[s[i]] += 1
        
        # 윈도우 크기가 p의 길이와 같아지면
        if i >= len(p) - 1:
            if window_count == p_count:
                result.append(i - len(p) + 1)
            
            # 윈도우에서 첫 번째 문자 제거
            left_char = s[i - len(p) + 1]
            window_count[left_char] -= 1
            if window_count[left_char] == 0:
                del window_count[left_char]
    
    return result
```

### 🚨 투 포인터/슬라이딩 윈도우 주요 함정

- 포인터 이동 조건을 명확히 정의
- 윈도우 크기 조절 시 경계 조건 주의
- Counter나 딕셔너리 사용 시 0이 되는 키 처리

## 🏃 4. 그리디 알고리즘 패턴

### 기본 그리디 패턴

#### 활동 선택 문제

```python
def activity_selection(activities):
    """끝나는 시간이 빠른 순으로 최대한 많은 활동 선택"""
    # (시작시간, 끝시간) 튜플 리스트를 끝시간 기준으로 정렬
    activities.sort(key=lambda x: x[1])
    
    selected = [activities[0]]
    last_end_time = activities[0][1]
    
    for start, end in activities[1:]:
        if start >= last_end_time:  # 겹치지 않으면 선택
            selected.append((start, end))
            last_end_time = end
    
    return selected

# 사용 예시
activities = [(1, 4), (3, 5), (0, 6), (5, 7), (3, 9), (5, 9), (6, 10), (8, 11)]
result = activity_selection(activities)
```

#### 거스름돈 문제

```python
def make_change(amount, coins):
    """가장 적은 개수의 동전으로 거스름돈 만들기 (그리디 조건 만족 시)"""
    coins.sort(reverse=True)  # 큰 동전부터
    
    result = []
    for coin in coins:
        count = amount // coin
        if count > 0:
            result.extend([coin] * count)
            amount %= coin
        
        if amount == 0:
            break
    
    return result if amount == 0 else []  # 만들 수 없으면 빈 리스트

# 사용 예시
coins = [500, 100, 50, 10]
change = make_change(1260, coins)
```

#### 최소 신장 트리 (크루스칼)

```python
def find_parent(parent, x):
    """Union-Find의 find 연산"""
    if parent[x] != x:
        parent[x] = find_parent(parent, parent[x])
    return parent[x]

def union_parent(parent, rank, a, b):
    """Union-Find의 union 연산"""
    a = find_parent(parent, a)
    b = find_parent(parent, b)
    
    if rank[a] < rank[b]:
        parent[a] = b
    elif rank[a] > rank[b]:
        parent[b] = a
    else:
        parent[b] = a
        rank[a] += 1

def kruskal(n, edges):
    """크루스칼 알고리즘으로 최소 신장 트리"""
    # 간선을 비용 순으로 정렬
    edges.sort(key=lambda x: x[2])
    
    parent = list(range(n))
    rank = [0] * n
    mst = []
    total_cost = 0
    
    for a, b, cost in edges:
        if find_parent(parent, a) != find_parent(parent, b):
            union_parent(parent, rank, a, b)
            mst.append((a, b, cost))
            total_cost += cost
    
    return mst, total_cost
```

### 그리디 선택의 정당성 증명 패턴

#### 회의실 배정

```python
def meeting_rooms(meetings):
    """최소한의 회의실로 모든 회의 배정"""
    import heapq
    
    if not meetings:
        return 0
    
    # 시작시간 기준으로 정렬
    meetings.sort(key=lambda x: x[0])
    
    # 각 회의실의 끝나는 시간을 저장하는 최소 힙
    heap = []
    
    for start, end in meetings:
        # 가장 빨리 끝나는 회의실이 현재 회의 시작 전에 끝나면
        if heap and heap[0] <= start:
            heapq.heappop(heap)
        
        heapq.heappush(heap, end)
    
    return len(heap)  # 필요한 회의실 개수
```

### 🚨 그리디 주요 함정

- 그리디 선택이 항상 최적해를 보장하지 않음
- 반례를 찾아 그리디 조건 확인 필요
- 정렬 기준을 신중하게 선택

## 🧮 5. 동적계획법(DP) 기본 패턴

### 기본 DP 패턴

#### 피보나치 수열

```python
# Top-down (메모이제이션)
def fibonacci_memo(n, memo={}):
    if n in memo:
        return memo[n]
    
    if n <= 1:
        return n
    
    memo[n] = fibonacci_memo(n-1, memo) + fibonacci_memo(n-2, memo)
    return memo[n]

# Bottom-up (테이블 방식)
def fibonacci_dp(n):
    if n <= 1:
        return n
    
    dp = [0] * (n + 1)
    dp[1] = 1
    
    for i in range(2, n + 1):
        dp[i] = dp[i-1] + dp[i-2]
    
    return dp[n]

# 공간 최적화
def fibonacci_optimized(n):
    if n <= 1:
        return n
    
    prev2, prev1 = 0, 1
    for i in range(2, n + 1):
        current = prev1 + prev2
        prev2, prev1 = prev1, current
    
    return prev1
```

#### 0-1 배낭 문제

```python
def knapsack_01(weights, values, capacity):
    """0-1 배낭 문제"""
    n = len(weights)
    # dp[i][w] = i번째 물건까지 고려했을 때 무게 w 이하로 얻을 수 있는 최대 가치
    dp = [[0] * (capacity + 1) for _ in range(n + 1)]
    
    for i in range(1, n + 1):
        for w in range(1, capacity + 1):
            # i번째 물건을 넣지 않는 경우
            dp[i][w] = dp[i-1][w]
            
            # i번째 물건을 넣는 경우 (무게가 허용되면)
            if weights[i-1] <= w:
                dp[i][w] = max(dp[i][w], 
                              dp[i-1][w-weights[i-1]] + values[i-1])
    
    return dp[n][capacity]

# 공간 최적화 버전
def knapsack_01_optimized(weights, values, capacity):
    dp = [0] * (capacity + 1)
    
    for i in range(len(weights)):
        # 뒤에서부터 갱신 (중복 사용 방지)
        for w in range(capacity, weights[i] - 1, -1):
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i])
    
    return dp[capacity]
```

#### 최장 증가 부분 수열 (LIS)

```python
def lis_dp(arr):
    """O(n²) 동적계획법"""
    n = len(arr)
    dp = [1] * n  # dp[i] = i번째 원소를 마지막으로 하는 LIS 길이
    
    for i in range(1, n):
        for j in range(i):
            if arr[j] < arr[i]:
                dp[i] = max(dp[i], dp[j] + 1)
    
    return max(dp)

def lis_binary_search(arr):
    """O(n log n) 이진탐색"""
    import bisect
    
    tails = []  # tails[i] = 길이 i+1인 증가수열의 마지막 원소 중 최솟값
    
    for num in arr:
        pos = bisect.bisect_left(tails, num)
        if pos == len(tails):
            tails.append(num)
        else:
            tails[pos] = num
    
    return len(tails)
```

#### 편집 거리 (Edit Distance)

```python
def edit_distance(str1, str2):
    """두 문자열 간의 편집 거리 (삽입, 삭제, 교체)"""
    m, n = len(str1), len(str2)
    
    # dp[i][j] = str1[:i]를 str2[:j]로 변환하는 최소 연산 수
    dp = [[0] * (n + 1) for _ in range(m + 1)]
    
    # 초기화: 빈 문자열로 변환
    for i in range(m + 1):
        dp[i][0] = i  # 모두 삭제
    for j in range(n + 1):
        dp[0][j] = j  # 모두 삽입
    
    for i in range(1, m + 1):
        for j in range(1, n + 1):
            if str1[i-1] == str2[j-1]:
                dp[i][j] = dp[i-1][j-1]  # 문자가 같으면 그대로
            else:
                dp[i][j] = 1 + min(
                    dp[i-1][j],    # 삭제
                    dp[i][j-1],    # 삽입
                    dp[i-1][j-1]   # 교체
                )
    
    return dp[m][n]
```

### DP 상태 설계 패턴

#### 구간 DP

```python
def matrix_chain_multiplication(matrices):
    """행렬 연쇄 곱셈의 최소 곱셈 횟수"""
    n = len(matrices)
    # dp[i][j] = i번째부터 j번째 행렬까지 곱하는 최소 비용
    dp = [[0] * n for _ in range(n)]
    
    # 구간 길이를 늘려가며 계산
    for length in range(2, n + 1):  # 구간 길이
        for i in range(n - length + 1):
            j = i + length - 1
            dp[i][j] = float('inf')
            
            # k를 기준으로 분할
            for k in range(i, j):
                cost = (dp[i][k] + dp[k+1][j] + 
                       matrices[i][0] * matrices[k][1] * matrices[j][1])
                dp[i][j] = min(dp[i][j], cost)
    
    return dp[0][n-1]
```

#### 비트마스크 DP

```python
def traveling_salesman(dist):
    """외판원 문제 (TSP)"""
    n = len(dist)
    # dp[mask][i] = mask에 표시된 도시들을 방문하고 i에서 끝나는 최소 비용
    dp = [[float('inf')] * n for _ in range(1 << n)]
    
    # 시작점(0번 도시)에서 출발
    dp[1][0] = 0
    
    for mask in range(1 << n):
        for i in range(n):
            if not (mask & (1 << i)):  # i번 도시를 방문하지 않았으면
                continue
            
            for j in range(n):
                if i == j or not (mask & (1 << j)):
                    continue
                
                # j에서 i로 가는 경우
                prev_mask = mask ^ (1 << i)
                dp[mask][i] = min(dp[mask][i], 
                                 dp[prev_mask][j] + dist[j][i])
    
    # 모든 도시를 방문하고 시작점으로 돌아가는 최소 비용
    result = float('inf')
    final_mask = (1 << n) - 1
    for i in range(1, n):
        result = min(result, dp[final_mask][i] + dist[i][0])
    
    return result
```

### 🚨 DP 주요 함정

- 상태 정의가 명확하지 않으면 구현 어려움
- 메모이제이션에서 기본값 설정 주의
- 순서에 따른 중복 계산 방지
- 공간 복잡도 최적화 가능 여부 검토

## 🔤 6. 문자열 처리 고급 기법

### 패턴 매칭

#### KMP 알고리즘

```python
def build_failure_function(pattern):
    """KMP 알고리즘의 실패 함수 구축"""
    m = len(pattern)
    failure = [0] * m
    j = 0
    
    for i in range(1, m):
        while j > 0 and pattern[i] != pattern[j]:
            j = failure[j - 1]
        
        if pattern[i] == pattern[j]:
            j += 1
            failure[i] = j
    
    return failure

def kmp_search(text, pattern):
    """KMP 알고리즘으로 패턴 검색"""
    n, m = len(text), len(pattern)
    if m == 0:
        return []
    
    failure = build_failure_function(pattern)
    matches = []
    j = 0
    
    for i in range(n):
        while j > 0 and text[i] != pattern[j]:
            j = failure[j - 1]
        
        if text[i] == pattern[j]:
            j += 1
        
        if j == m:
            matches.append(i - m + 1)
            j = failure[j - 1]
    
    return matches
```

#### 라빈-카프 알고리즘

```python
def rabin_karp_search(text, pattern):
    """라빈-카프 알고리즘 (롤링 해시)"""
    n, m = len(text), len(pattern)
    if m > n:
        return []
    
    base = 256
    mod = 10**9 + 7
    
    # 패턴의 해시값 계산
    pattern_hash = 0
    for char in pattern:
        pattern_hash = (pattern_hash * base + ord(char)) % mod
    
    # base^(m-1) % mod 계산
    h = 1
    for _ in range(m - 1):
        h = (h * base) % mod
    
    # 첫 번째 윈도우의 해시값
    window_hash = 0
    for i in range(m):
        window_hash = (window_hash * base + ord(text[i])) % mod
    
    matches = []
    for i in range(n - m + 1):
        # 해시값이 같으면 실제 문자열 비교
        if window_hash == pattern_hash:
            if text[i:i+m] == pattern:
                matches.append(i)
        
        # 다음 윈도우의 해시값 계산 (롤링)
        if i < n - m:
            window_hash = (window_hash - ord(text[i]) * h) % mod
            window_hash = (window_hash * base + ord(text[i + m])) % mod
            window_hash = (window_hash + mod) % mod  # 음수 방지
    
    return matches
```

### 문자열 변환과 처리

#### 회문 검사와 관련 알고리즘

```python
def is_palindrome(s):
    """기본 회문 검사"""
    left, right = 0, len(s) - 1
    while left < right:
        if s[left] != s[right]:
            return False
        left += 1
        right -= 1
    return True

def longest_palindrome_center_expand(s):
    """중심 확장으로 최장 회문 찾기"""
    def expand_around_center(left, right):
        while left >= 0 and right < len(s) and s[left] == s[right]:
            left -= 1
            right += 1
        return right - left - 1
    
    start = end = 0
    for i in range(len(s)):
        # 홀수 길이 회문
        len1 = expand_around_center(i, i)
        # 짝수 길이 회문
        len2 = expand_around_center(i, i + 1)
        
        max_len = max(len1, len2)
        if max_len > end - start:
            start = i - (max_len - 1) // 2
            end = i + max_len // 2
    
    return s[start:end + 1]

def manacher_algorithm(s):
    """매내처 알고리즘 (O(n) 회문 검사)"""
    # 문자 사이에 특별 문자 삽입
    processed = '#'.join('^{}$'.format(s))
    n = len(processed)
    
    # 각 위치에서의 회문 반지름
    radius = [0] * n
    center = right = 0
    
    for i in range(1, n - 1):
        # 이전에 계산된 정보 활용
        if i < right:
            radius[i] = min(right - i, radius[2 * center - i])
        
        # 중심 확장
        while processed[i + radius[i] + 1] == processed[i - radius[i] - 1]:
            radius[i] += 1
        
        # 오른쪽 경계 갱신
        if i + radius[i] > right:
            center, right = i, i + radius[i]
    
    # 최장 회문 찾기
    max_len = max(radius)
    center_index = radius.index(max_len)
    start = (center_index - max_len) // 2
    
    return s[start:start + max_len]
```

#### 접미사 배열과 LCP

```python
def suffix_array_naive(s):
    """접미사 배열 (단순 구현)"""
    suffixes = [(s[i:], i) for i in range(len(s))]
    suffixes.sort()
    return [suffix[1] for suffix in suffixes]

def lcp_array(s, suffix_arr):
    """최장 공통 접두사 배열"""
    n = len(s)
    rank = [0] * n
    lcp = [0] * (n - 1)
    
    # 각 접미사의 순위 계산
    for i in range(n):
        rank[suffix_arr[i]] = i
    
    h = 0
    for i in range(n):
        if rank[i] > 0:
            j = suffix_arr[rank[i] - 1]
            while (i + h < n and j + h < n and 
                   s[i + h] == s[j + h]):
                h += 1
            lcp[rank[i] - 1] = h
            if h > 0:
                h -= 1
    
    return lcp
```

### 정규표현식 패턴

```python
import re

# 자주 사용하는 정규표현식 패턴들
patterns = {
    'email': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    'phone': r'^\d{3}-\d{3,4}-\d{4}$',
    'number': r'^-?\d+(\.\d+)?$',
    'korean': r'[가-힣]+',
    'english': r'[a-zA-Z]+',
    'alphanumeric': r'^[a-zA-Z0-9]+$'
}

def validate_input(text, pattern_name):
    """입력값 검증"""
    pattern = patterns.get(pattern_name)
    if pattern:
        return bool(re.match(pattern, text))
    return False

# 문자열에서 모든 숫자 추출
def extract_numbers(text):
    return re.findall(r'-?\d+\.?\d*', text)

# 특정 패턴으로 문자열 분할
def smart_split(text, delimiter_pattern=r'[,;\s]+'):
    return re.split(delimiter_pattern, text.strip())
```

### 🚨 문자열 처리 주요 함정

- 유니코드 처리 시 인코딩 문제
- 정규표현식의 성능 이슈 (백트래킹)
- 문자열 불변성으로 인한 성능 저하
- KMP/라빈-카프에서 모듈로 연산 오버플로우

## 📝 2단계 핵심 요약

### 필수 암기 템플릿

1. **DFS/BFS**: 재귀/스택/큐를 이용한 그래프 탐색
2. **이진탐색**: lower_bound, upper_bound, 매개변수 탐색
3. **투 포인터**: 정렬된 배열에서 조건 만족하는 쌍 찾기
4. **슬라이딩 윈도우**: 고정/가변 크기 부분배열 문제
5. **그리디**: 활동 선택, 최소 신장 트리
6. **DP**: 0-1배낭, LIS, 편집거리

### 알고리즘 선택 가이드

- **완전탐색이 가능한가?** → DFS/BFS
- **정렬된 상태에서 특정 값 찾기** → 이진탐색
- **연속된 부분에서 조건 만족** → 투 포인터/슬라이딩 윈도우
- **매 순간 최선의 선택** → 그리디
- **작은 문제의 최적해로 큰 문제 해결** → DP
- **패턴 검색/문자열 변환** → KMP/라빈-카프
