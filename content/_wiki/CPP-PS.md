---
title: C++ PS 정리 🔄
summary: 
date: 2025-07-31 11:28:36 +0900
lastmod: 2025-07-31 11:28:36 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
# C++ PS 1단계: 기초 문법 완전정복

## 📥 1. 입출력 처리

### 기본 입력

```cpp
#include <iostream>
#include <string>
using namespace std;

// 한 줄 입력
int n;
cin >> n;

string s;
cin >> s;  // 공백 전까지
getline(cin, s);  // 한 줄 전체

int a, b;
cin >> a >> b;

// 여러 줄 입력
vector<int> arr(n);
for (int i = 0; i < n; i++) {
    cin >> arr[i];
}

// 배열 한번에 입력
vector<int> numbers(n);
for (auto& x : numbers) cin >> x;
```

### 빠른 입력 (최적화)

```cpp
// 입출력 속도 향상
ios_base::sync_with_stdio(false);
cin.tie(NULL);
cout.tie(NULL);

// 버퍼 사용 (매우 빠름)
#include <cstdio>
int n;
scanf("%d", &n);
char s[100];
scanf("%s", s);

// C++14 이상에서 범위 기반 입력
vector<int> v(n);
for (auto& x : v) cin >> x;
```

### 출력 최적화

```cpp
// 기본 출력
cout << result << '\n';  // endl보다 '\n'이 빠름
cout << a << ' ' << b << ' ' << c << '\n';

// 정밀도 설정
cout << fixed << setprecision(10) << 3.14159265359 << '\n';

// 여러 줄 출력
for (int i = 0; i < n; i++) {
    cout << i << '\n';
}

// stringstream 활용 (대량 출력)
stringstream ss;
for (int i = 0; i < n; i++) {
    ss << i << '\n';
}
cout << ss.str();
```

### 🚨 입출력 주요 함정

- `endl`은 버퍼를 flush하므로 `'\n'`보다 느림
- `ios_base::sync_with_stdio(false)` 사용 시 C 스타일 입출력 혼용 불가
- `cin.ignore()`로 버퍼에 남은 개행문자 제거 필요한 경우

## 🔤 2. 문자열(string) 핵심 메서드

### 기본 조작

```cpp
string s = "Hello World";

// 길이와 인덱싱
s.length();  // 11
s.size();    // 11 (동일)
s[0];        // 'H'
s.back();    // 'd'
s.substr(1, 4);  // "ello"

// 대소문자 변환
transform(s.begin(), s.end(), s.begin(), ::toupper);  // 대문자로
transform(s.begin(), s.end(), s.begin(), ::tolower);  // 소문자로

// 공백 처리 (algorithm 헤더 필요)
// 왼쪽 공백 제거
s.erase(s.begin(), find_if(s.begin(), s.end(), [](int ch) {
    return !isspace(ch);
}));

// 오른쪽 공백 제거
s.erase(find_if(s.rbegin(), s.rend(), [](int ch) {
    return !isspace(ch);
}).base(), s.end());
```

### 검색과 분할

```cpp
string s = "hello world hello";

// 검색
size_t pos = s.find("world");     // 6
if (pos != string::npos) {        // 찾음
    cout << "Found at " << pos << '\n';
}
s.find("xyz");                     // string::npos (못 찾음)
int count = 0;
pos = 0;
while ((pos = s.find("hello", pos)) != string::npos) {
    count++;
    pos += 5;
}

// 분할과 결합
vector<string> split(const string& s, char delimiter) {
    vector<string> tokens;
    stringstream ss(s);
    string token;
    while (getline(ss, token, delimiter)) {
        tokens.push_back(token);
    }
    return tokens;
}

// 치환
size_t start_pos = 0;
while((start_pos = s.find("hello", start_pos)) != string::npos) {
    s.replace(start_pos, 5, "hi");
    start_pos += 2;
}
```

### 판별 메서드

```cpp
// 문자 종류 판별
bool all_digits = all_of(s.begin(), s.end(), ::isdigit);
bool all_alpha = all_of(s.begin(), s.end(), ::isalpha);
bool all_alnum = all_of(s.begin(), s.end(), ::isalnum);

// 패턴 판별
if (s.find("he") == 0) {  // startswith
    cout << "Starts with 'he'\n";
}
if (s.size() >= 2 && s.substr(s.size() - 2) == "ld") {  // endswith
    cout << "Ends with 'ld'\n";
}
```

### 🚨 문자열 주요 함정

- C++의 string은 가변(mutable)
- `+` 연산은 새 객체 생성, `+=`가 더 효율적
- 대량 문자열 연결 시 `stringstream` 활용

## 📋 3. 벡터(vector) 핵심 메서드

### 기본 생성과 조작

```cpp
// 생성
vector<int> arr = {1, 2, 3, 4, 5};
vector<int> arr2(n, 0);  // 크기 n, 0으로 초기화
vector<vector<int>> matrix(n, vector<int>(m, 0));  // 2차원 벡터

// 추가와 삭제
arr.push_back(6);         // 끝에 추가
arr.insert(arr.begin(), 0);  // 맨 앞에 삽입
arr.insert(arr.begin() + 2, 99);  // 인덱스 2에 삽입

arr.pop_back();           // 마지막 요소 제거
arr.erase(arr.begin());   // 첫 번째 요소 제거
arr.erase(arr.begin() + 2);  // 인덱스 2 제거
arr.erase(remove(arr.begin(), arr.end(), 3), arr.end());  // 값 3 모두 제거
```

### 정렬과 검색

```cpp
vector<int> arr = {3, 1, 4, 1, 5};

// 정렬
sort(arr.begin(), arr.end());              // 오름차순
sort(arr.begin(), arr.end(), greater<int>());  // 내림차순

// 커스텀 정렬
sort(arr.begin(), arr.end(), [](int a, int b) {
    return a > b;  // 내림차순
});

// 검색
auto it = find(arr.begin(), arr.end(), 4);
if (it != arr.end()) {
    int index = distance(arr.begin(), it);  // 인덱스 구하기
}

int cnt = count(arr.begin(), arr.end(), 1);  // 1의 개수

// 이진 탐색 (정렬된 벡터)
if (binary_search(arr.begin(), arr.end(), 4)) {
    cout << "Found\n";
}
```

### 유용한 알고리즘

```cpp
vector<int> arr = {1, 2, 3, 4, 5};

// 뒤집기
reverse(arr.begin(), arr.end());

// 회전
rotate(arr.begin(), arr.begin() + 2, arr.end());  // 왼쪽으로 2칸

// 순열
do {
    // 현재 순열 처리
} while (next_permutation(arr.begin(), arr.end()));

// 중복 제거
sort(arr.begin(), arr.end());
arr.erase(unique(arr.begin(), arr.end()), arr.end());

// 최대/최소
auto [min_it, max_it] = minmax_element(arr.begin(), arr.end());
int min_val = *min_it;
int max_val = *max_it;
```

### 🚨 벡터 주요 함정

- `vector<bool>`은 특수화되어 있어 주의 필요
- `push_back` 시 재할당으로 인한 성능 저하 → `reserve()` 활용
- 반복자 무효화 주의 (삽입/삭제 시)

## 📖 4. 맵(map)과 셋(set) 핵심 메서드

### map 기본 조작

```cpp
// 생성
map<string, int> m;
m["apple"] = 1;
m["banana"] = 2;

// 접근과 수정
cout << m["apple"] << '\n';  // 1
m["cherry"] = 3;              // 새 키-값 추가

// 안전한 접근
if (m.find("grape") != m.end()) {
    cout << m["grape"] << '\n';
}

// 또는 C++20
if (m.contains("grape")) {
    cout << m["grape"] << '\n';
}
```

### 조회와 순회

```cpp
map<string, int> m = {{"a", 1}, {"b", 2}, {"c", 3}};

// 순회 (정렬된 순서)
for (const auto& [key, value] : m) {
    cout << key << ": " << value << '\n';
}

// 키 존재 확인
if (m.count("a")) {  // 또는 m.find("a") != m.end()
    cout << "Key exists\n";
}

// 삭제
m.erase("b");
```

### unordered_map (해시맵)

```cpp
// O(1) 평균 시간복잡도
unordered_map<string, int> um;
um["apple"] = 1;

// 커스텀 해시 함수
struct PairHash {
    size_t operator()(const pair<int, int>& p) const {
        return hash<int>()(p.first) ^ (hash<int>()(p.second) << 1);
    }
};

unordered_map<pair<int, int>, int, PairHash> coord_map;
```

### set과 multiset

```cpp
// set: 중복 없는 정렬된 집합
set<int> s = {3, 1, 4, 1, 5};  // {1, 3, 4, 5}
s.insert(2);
s.erase(3);

// 범위 검색
auto it1 = s.lower_bound(2);  // 2 이상인 첫 원소
auto it2 = s.upper_bound(4);  // 4 초과인 첫 원소

// multiset: 중복 허용
multiset<int> ms = {1, 2, 2, 3, 3, 3};
cout << ms.count(3) << '\n';  // 3
```

### 🚨 map/set 주요 함정

- map은 자동 정렬 (O(log n) 연산)
- unordered_map은 해시 충돌 시 성능 저하
- `[]` 연산자는 없는 키 접근 시 자동 생성

## 🔢 5. 기타 STL 컨테이너

### queue와 priority_queue

```cpp
// 일반 큐
queue<int> q;
q.push(1);
q.push(2);
cout << q.front() << '\n';  // 1
q.pop();

// 우선순위 큐 (최대 힙)
priority_queue<int> pq;
pq.push(3);
pq.push(1);
pq.push(4);
cout << pq.top() << '\n';  // 4

// 최소 힙
priority_queue<int, vector<int>, greater<int>> min_pq;

// 커스텀 비교
struct Compare {
    bool operator()(const pair<int, int>& a, const pair<int, int>& b) {
        return a.second > b.second;  // second 기준 최소 힙
    }
};
priority_queue<pair<int, int>, vector<pair<int, int>>, Compare> custom_pq;
```

### stack과 deque

```cpp
// 스택
stack<int> st;
st.push(1);
st.push(2);
cout << st.top() << '\n';  // 2
st.pop();

// 덱 (양방향 큐)
deque<int> dq;
dq.push_back(1);
dq.push_front(0);
dq.pop_back();
dq.pop_front();
```

## 🔄 6. 조건문과 반복문 고급 활용

### 조건문 최적화

```cpp
// 삼항 연산자
int result = condition ? value_if_true : value_if_false;

// switch 문
switch (value) {
    case 1:
        // 처리
        break;
    case 2:
    case 3:  // 여러 케이스
        // 처리
        break;
    default:
        // 기본 처리
}

// C++17 if문 초기화
if (auto it = m.find(key); it != m.end()) {
    // it 사용
}
```

### 반복문 패턴

```cpp
// 범위 기반 for문
vector<int> v = {1, 2, 3, 4, 5};
for (const auto& x : v) {
    cout << x << ' ';
}

// 인덱스와 함께
for (int i = 0; i < v.size(); i++) {
    cout << i << ": " << v[i] << '\n';
}

// 역순 반복
for (int i = n - 1; i >= 0; i--) {
    // 처리
}

// iterator 활용
for (auto it = v.begin(); it != v.end(); ++it) {
    cout << *it << ' ';
}
```

## ⚡ 7. 함수와 람다 표현식

### 함수 정의와 활용

```cpp
// 기본 함수
int gcd(int a, int b) {
    while (b) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

// 기본값 매개변수
int power(int base, int exp = 2) {
    return pow(base, exp);
}

// 템플릿 함수
template<typename T>
T getMax(T a, T b) {
    return (a > b) ? a : b;
}

// 가변 인자 (C++11)
template<typename... Args>
void print(Args... args) {
    ((cout << args << ' '), ...);
    cout << '\n';
}
```

### 람다 표현식

```cpp
// 기본 람다
auto square = [](int x) { return x * x; };
auto add = [](int x, int y) { return x + y; };

// 정렬에서 람다 활용
vector<pair<string, int>> students = {{"Alice", 85}, {"Bob", 90}, {"Charlie", 78}};
sort(students.begin(), students.end(), [](const auto& a, const auto& b) {
    return a.second > b.second;  // 점수 내림차순
});

// 캡처
int factor = 10;
auto multiply = [factor](int x) { return x * factor; };

// STL 알고리즘과 함께
vector<int> numbers = {1, 2, 3, 4, 5};
transform(numbers.begin(), numbers.end(), numbers.begin(), 
          [](int x) { return x * x; });

vector<int> evens;
copy_if(numbers.begin(), numbers.end(), back_inserter(evens),
        [](int x) { return x % 2 == 0; });
```

### 유용한 STL 함수들

```cpp
// 수학 함수
abs(-5);           // 5
min(1, 2);         // 1
max({1, 2, 3});    // 3 (initializer_list)
__gcd(12, 8);      // 4 (내장 GCD)

// 알고리즘 함수
vector<int> v = {1, 2, 3, 4, 5};
int sum = accumulate(v.begin(), v.end(), 0);  // 15
bool all_positive = all_of(v.begin(), v.end(), [](int x) { return x > 0; });
bool any_even = any_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
```

## 🛡️ 8. 예외처리와 디버깅

### 기본 예외처리

```cpp
try {
    int result = 10 / 0;  // 실제로는 정수 나눗셈은 예외 발생 안함
} catch (const exception& e) {
    cerr << "Error: " << e.what() << '\n';
}

// 사용자 정의 예외
class CustomException : public exception {
    const char* what() const noexcept override {
        return "Custom error occurred";
    }
};
```

### 디버깅 기법

```cpp
// assert 매크로
#include <cassert>
assert(n > 0);  // 조건이 false면 프로그램 중단

// 디버그 출력
#ifdef DEBUG
    #define debug(x) cerr << #x << " = " << x << '\n'
#else
    #define debug(x)
#endif

// 사용
int value = 42;
debug(value);  // DEBUG 정의시: value = 42 출력
```

## 📝 1단계 핵심 요약

### 꼭 기억해야 할 패턴

1. **빠른 입출력**: `ios_base::sync_with_stdio(false)`와 `'\n'`
2. **문자열 처리**: `substr()`, `find()`, `stringstream`
3. **벡터 조작**: `sort()`, `unique()`, 범위 기반 for문
4. **맵/셋**: `find()`, `count()`, unordered 버전
5. **STL 알고리즘**: `accumulate()`, `transform()`, `copy_if()`
6. **람다 표현식**: 정렬과 STL 알고리즘에서 활용

### 자주 하는 실수들

- endl 대신 '\n' 사용
- 벡터 크기 미리 예약 (`reserve()`)
- map의 `[]` 연산자 자동 생성 주의
- iterator 무효화 주의
- 부호 없는 정수형 오버플로우

# C++ PS 2단계: 다른 언어 개발자를 위한 C++ 특화 기법

## 🔀 1. 분기문과 제어문 - C++만의 특징

### 조건문의 C++스러운 표현

#### 삼항 연산자 (Ternary Operator)

```cpp
// 기본 형태
int result = condition ? value_if_true : value_if_false;

// 실용 예시
int max_val = (a > b) ? a : b;
string status = (score >= 60) ? "pass" : "fail";
int sign = (num >= 0) ? 1 : -1;

// 중첩 삼항 연산자 (가독성 주의)
char grade = (score >= 90) ? 'A' : (score >= 80) ? 'B' : 'C';

// Python과 다른 점: C++는 전통적인 ? : 연산자 사용
// Python: result = value1 if condition else value2
// C++: int result = condition ? value1 : value2;
```

#### 조건 평가와 단락 평가 (Short-circuit Evaluation)

```cpp
// C++에서 false로 평가되는 값들
// 0, nullptr, false만 false (Python과 다름)

// 단락 평가 활용
if (ptr != nullptr && ptr->value > 0) {
    // ptr이 null이면 뒤는 평가하지 않음
}

// 기본값 설정 패턴
string name = input_name.empty() ? "Anonymous" : input_name;

// Python과 다른 점: 빈 컨테이너도 true
vector<int> v;
if (v.empty()) {  // 명시적으로 empty() 체크 필요
    cout << "Empty vector\n";
}
```

#### constexpr if (C++17)

```cpp
template<typename T>
void process(T value) {
    if constexpr (is_integral_v<T>) {
        cout << "Integer: " << value << '\n';
    } else if constexpr (is_floating_point_v<T>) {
        cout << "Float: " << fixed << setprecision(2) << value << '\n';
    } else {
        cout << "Other type\n";
    }
}

// 컴파일 타임에 분기 결정
template<int N>
void print() {
    if constexpr (N > 10) {
        cout << "Large number\n";
    } else {
        cout << "Small number\n";
    }
}
```

### switch 문의 고급 활용

```cpp
// 기본 switch
switch (status) {
    case 200:
        return "OK";
    case 404:
        return "Not Found";
    case 500:
    case 502:
    case 503:  // 여러 값 매칭
        return "Server Error";
    default:
        return "Unknown Status";
}

// C++17 switch with initialization
switch (auto val = calculate(); val) {
    case 1:
        // val 사용 가능
        break;
    case 2:
        break;
}

// enum class와 switch
enum class Color { Red, Green, Blue };

Color c = Color::Red;
switch (c) {
    case Color::Red:
        cout << "Red\n";
        break;
    case Color::Green:
        cout << "Green\n";
        break;
    case Color::Blue:
        cout << "Blue\n";
        break;
}
```

## 🔄 2. 반복문 - C++의 강력한 이터레이션

### 범위 기반 for문 (Range-based for loop)

```cpp
// 기본 사용법
vector<int> v = {1, 2, 3, 4, 5};
for (int x : v) {
    cout << x << ' ';
}

// 참조로 받기 (복사 방지)
for (const auto& x : v) {
    cout << x << ' ';
}

// 수정하려면 비const 참조
for (auto& x : v) {
    x *= 2;
}

// 구조화 바인딩 (C++17)
map<string, int> m = {{"Alice", 25}, {"Bob", 30}};
for (const auto& [name, age] : m) {
    cout << name << " is " << age << " years old\n";
}

// 초기화 리스트
for (int x : {1, 2, 3, 4, 5}) {
    cout << x << ' ';
}
```

### 전통적인 for문의 다양한 활용

```cpp
// 인덱스와 함께
for (size_t i = 0; i < v.size(); ++i) {
    cout << i << ": " << v[i] << '\n';
}

// 역순 반복 (부호 없는 정수 주의)
for (int i = n - 1; i >= 0; --i) {
    cout << v[i] << ' ';
}

// 또는 size_t 사용시
for (size_t i = n; i-- > 0; ) {
    cout << v[i] << ' ';
}

// 2차원 배열 순회
int matrix[3][3] = {{1,2,3}, {4,5,6}, {7,8,9}};
for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 3; ++j) {
        cout << matrix[i][j] << ' ';
    }
    cout << '\n';
}

// 더 C++스러운 방법
for (const auto& row : matrix) {
    for (int cell : row) {
        cout << cell << ' ';
    }
    cout << '\n';
}
```

### 반복자(Iterator) 활용

```cpp
// 기본 반복자
vector<int> v = {1, 2, 3, 4, 5};
for (auto it = v.begin(); it != v.end(); ++it) {
    cout << *it << ' ';
}

// 역방향 반복자
for (auto it = v.rbegin(); it != v.rend(); ++it) {
    cout << *it << ' ';
}

// 반복자 산술
auto mid = v.begin() + v.size() / 2;
cout << "Middle element: " << *mid << '\n';

// 거리 계산
auto pos = find(v.begin(), v.end(), 3);
if (pos != v.end()) {
    cout << "Found at index: " << distance(v.begin(), pos) << '\n';
}

// 반복자 카테고리별 활용
// Random Access Iterator (vector, deque)
sort(v.begin(), v.end());

// Bidirectional Iterator (list, set, map)
list<int> lst = {1, 2, 3, 4, 5};
reverse(lst.begin(), lst.end());
```

## 🍬 3. 템플릿과 제네릭 프로그래밍

### 함수 템플릿

```cpp
// 기본 함수 템플릿
template<typename T>
T getMax(T a, T b) {
    return (a > b) ? a : b;
}

// 여러 타입 매개변수
template<typename T, typename U>
auto add(T a, U b) -> decltype(a + b) {
    return a + b;
}

// C++14 이후 (auto 반환 타입)
template<typename T, typename U>
auto add(T a, U b) {
    return a + b;
}

// 템플릿 특수화
template<>
string getMax<string>(string a, string b) {
    return (a.length() > b.length()) ? a : b;
}

// 가변 템플릿 (C++11)
template<typename... Args>
void print(Args... args) {
    ((cout << args << ' '), ...);  // C++17 fold expression
    cout << '\n';
}
```

### 클래스 템플릿

```cpp
// 기본 클래스 템플릿
template<typename T>
class Stack {
private:
    vector<T> elements;
public:
    void push(const T& elem) {
        elements.push_back(elem);
    }
    
    T pop() {
        T elem = elements.back();
        elements.pop_back();
        return elem;
    }
    
    bool empty() const {
        return elements.empty();
    }
};

// 사용
Stack<int> intStack;
Stack<string> stringStack;

// 템플릿 매개변수 추론 (C++17)
Stack s{1, 2, 3};  // Stack<int>로 추론
```

### SFINAE와 enable_if

```cpp
// 정수 타입만 허용하는 함수
template<typename T>
typename enable_if<is_integral<T>::value, T>::type
sum(T a, T b) {
    return a + b;
}

// C++17 if constexpr로 더 간단하게
template<typename T>
T process(T value) {
    if constexpr (is_integral_v<T>) {
        return value * 2;
    } else if constexpr (is_floating_point_v<T>) {
        return value / 2.0;
    } else {
        return value;
    }
}

// Concepts (C++20)
template<typename T>
concept Numeric = is_arithmetic_v<T>;

template<Numeric T>
T multiply(T a, T b) {
    return a * b;
}
```

## 🐍 4. C++ 특징적인 부분들

### 포인터와 참조

```cpp
// 포인터
int x = 5;
int* ptr = &x;
cout << *ptr << '\n';  // 5

// 널 포인터
int* p = nullptr;  // C++11, NULL 대신 사용

// 참조
int& ref = x;
ref = 10;  // x도 10이 됨

// const 참조 (임시 객체 바인딩 가능)
const int& cref = 42;

// 포인터 vs 참조
void by_pointer(int* p) {
    if (p) *p = 10;
}

void by_reference(int& r) {
    r = 10;  // 널 체크 불필요
}

// 스마트 포인터 (C++11)
unique_ptr<int> up = make_unique<int>(42);
shared_ptr<int> sp = make_shared<int>(42);
weak_ptr<int> wp = sp;
```

### 이동 의미론 (Move Semantics)

```cpp
// 이동 생성자와 이동 대입
class Buffer {
    char* data;
    size_t size;
public:
    // 이동 생성자
    Buffer(Buffer&& other) noexcept 
        : data(other.data), size(other.size) {
        other.data = nullptr;
        other.size = 0;
    }
    
    // 이동 대입 연산자
    Buffer& operator=(Buffer&& other) noexcept {
        if (this != &other) {
            delete[] data;
            data = other.data;
            size = other.size;
            other.data = nullptr;
            other.size = 0;
        }
        return *this;
    }
};

// std::move 활용
vector<string> v1 = {"hello", "world"};
vector<string> v2 = move(v1);  // v1의 내용이 v2로 이동

// 완벽한 전달 (Perfect Forwarding)
template<typename T>
void wrapper(T&& arg) {
    process(forward<T>(arg));
}
```

### RAII와 스코프 가드

```cpp
// RAII (Resource Acquisition Is Initialization)
class FileHandler {
    FILE* file;
public:
    FileHandler(const char* filename) {
        file = fopen(filename, "r");
    }
    ~FileHandler() {
        if (file) fclose(file);
    }
    // 복사 금지
    FileHandler(const FileHandler&) = delete;
    FileHandler& operator=(const FileHandler&) = delete;
};

// 스코프 가드 패턴
class ScopeGuard {
    function<void()> onExit;
public:
    ScopeGuard(function<void()> f) : onExit(f) {}
    ~ScopeGuard() { onExit(); }
};

// 사용
{
    ScopeGuard guard([]{ cout << "Exiting scope\n"; });
    // 작업 수행
}  // 자동으로 "Exiting scope" 출력
```

### constexpr과 컴파일 타임 계산

```cpp
// constexpr 함수
constexpr int factorial(int n) {
    return (n <= 1) ? 1 : n * factorial(n - 1);
}

// 컴파일 타임에 계산
constexpr int fact5 = factorial(5);  // 120

// constexpr 변수
constexpr double pi = 3.14159265359;
constexpr int arr_size = 100;
int arr[arr_size];  // 가능

// C++14 constexpr 확장
constexpr int fibonacci(int n) {
    if (n <= 1) return n;
    int prev = 0, curr = 1;
    for (int i = 2; i <= n; ++i) {
        int next = prev + curr;
        prev = curr;
        curr = next;
    }
    return curr;
}
```

## 🔧 5. 함수형 프로그래밍과 람다

### 람다 표현식의 고급 활용

```cpp
// 기본 람다
auto square = [](int x) { return x * x; };
auto add = [](int x, int y) { return x + y; };

// 캡처 모드
int a = 1, b = 2;
auto f1 = [a, b]() { return a + b; };      // 값 캡처
auto f2 = [&a, &b]() { return a + b; };    // 참조 캡처
auto f3 = [=]() { return a + b; };         // 모든 변수 값 캡처
auto f4 = [&]() { return a + b; };         // 모든 변수 참조 캡처
auto f5 = [=, &b]() { return a + b; };     // a는 값, b는 참조

// mutable 람다
auto counter = [count = 0]() mutable {
    return ++count;
};

// 제네릭 람다 (C++14)
auto generic_add = [](auto a, auto b) {
    return a + b;
};

// 재귀 람다
function<int(int)> fib = [&fib](int n) {
    return (n <= 1) ? n : fib(n-1) + fib(n-2);
};
```

### STL 알고리즘과 함수형 프로그래밍

```cpp
vector<int> v = {1, 2, 3, 4, 5};

// transform: 모든 요소에 함수 적용
vector<int> squares;
transform(v.begin(), v.end(), back_inserter(squares),
          [](int x) { return x * x; });

// accumulate: 누적 연산
int sum = accumulate(v.begin(), v.end(), 0);
int product = accumulate(v.begin(), v.end(), 1, multiplies<int>());

// partition: 조건에 따라 분할
partition(v.begin(), v.end(), [](int x) { return x % 2 == 0; });

// all_of, any_of, none_of
bool all_positive = all_of(v.begin(), v.end(), [](int x) { return x > 0; });
bool has_even = any_of(v.begin(), v.end(), [](int x) { return x % 2 == 0; });
bool no_negative = none_of(v.begin(), v.end(), [](int x) { return x < 0; });

// 함수 합성
auto compose = [](auto f, auto g) {
    return [=](auto x) { return f(g(x)); };
};

auto add_one = [](int x) { return x + 1; };
auto double_it = [](int x) { return x * 2; };
auto add_one_then_double = compose(double_it, add_one);
```

### std::function과 함수 객체

```cpp
// std::function
function<int(int, int)> operation;
operation = add;
cout << operation(5, 3) << '\n';  // 8

operation = [](int a, int b) { return a * b; };
cout << operation(5, 3) << '\n';  // 15

// 함수 객체 (Functor)
struct Multiplier {
    int factor;
    Multiplier(int f) : factor(f) {}
    int operator()(int x) const {
        return x * factor;
    }
};

Multiplier times3(3);
cout << times3(5) << '\n';  // 15

// STL 함수 객체
vector<int> v = {3, 1, 4, 1, 5};
sort(v.begin(), v.end(), greater<int>());  // 내림차순
```

## 📊 6. 메모리 관리와 최적화

### 동적 메모리 할당

```cpp
// 기본 new/delete
int* p = new int(42);
delete p;

int* arr = new int[10];
delete[] arr;

// placement new
char buffer[sizeof(string)];
string* ps = new (buffer) string("Hello");
ps->~string();  // 명시적 소멸자 호출

// nothrow new
int* p = new(nothrow) int[1000000000];
if (!p) {
    cout << "Allocation failed\n";
}
```

### 스마트 포인터 활용

```cpp
// unique_ptr: 단독 소유권
unique_ptr<int> up1 = make_unique<int>(42);
unique_ptr<int> up2 = move(up1);  // 소유권 이전

// shared_ptr: 공유 소유권
shared_ptr<int> sp1 = make_shared<int>(42);
shared_ptr<int> sp2 = sp1;  // 참조 카운트 증가
cout << sp1.use_count() << '\n';  // 2

// weak_ptr: 순환 참조 방지
shared_ptr<Node> node1 = make_shared<Node>();
shared_ptr<Node> node2 = make_shared<Node>();
node1->next = node2;
node2->prev = weak_ptr<Node>(node1);  // 순환 참조 방지

// 커스텀 삭제자
auto deleter = [](FILE* f) { fclose(f); };
unique_ptr<FILE, decltype(deleter)> file(fopen("data.txt", "r"), deleter);
```

### 메모리 최적화 기법

```cpp
// 메모리 풀
template<typename T>
class MemoryPool {
    vector<T> pool;
    stack<T*> available;
public:
    T* allocate() {
        if (available.empty()) {
            pool.emplace_back();
            return &pool.back();
        }
        T* ptr = available.top();
        available.pop();
        return ptr;
    }
    
    void deallocate(T* ptr) {
        available.push(ptr);
    }
};

// 작은 문자열 최적화 (SSO)
// std::string은 이미 SSO 구현

// 메모리 정렬
struct alignas(64) CacheLinePadded {
    int data;
    // 캐시 라인 크기로 정렬
};

// reserve를 통한 재할당 방지
vector<int> v;
v.reserve(1000);  // 미리 공간 할당
for (int i = 0; i < 1000; ++i) {
    v.push_back(i);  // 재할당 없음
}
```

## 🎯 7. 실전 활용 패턴 모음

### 비트 연산 최적화

```cpp
// 비트 플래그
enum Flags {
    FLAG_A = 1 << 0,  // 1
    FLAG_B = 1 << 1,  // 2
    FLAG_C = 1 << 2   // 4
};

int flags = FLAG_A | FLAG_C;  // 플래그 설정
if (flags & FLAG_A) {  // 플래그 확인
    cout << "Flag A is set\n";
}
flags &= ~FLAG_A;  // 플래그 해제

// 비트 카운트
int popcount(unsigned int n) {
    return __builtin_popcount(n);  // GCC/Clang
}

// 최하위 비트
int lowest_bit(int n) {
    return n & -n;
}

// 비트 순회
for (int subset = mask; subset; subset = (subset - 1) & mask) {
    // mask의 모든 부분집합 순회
}
```

### 입출력 최적화

```cpp
// 빠른 입력
inline int fastInput() {
    int x = 0;
    char c = getchar();
    bool neg = false;
    
    while (c < '0' || c > '9') {
        if (c == '-') neg = true;
        c = getchar();
    }
    
    while (c >= '0' && c <= '9') {
        x = x * 10 + (c - '0');
        c = getchar();
    }
    
    return neg ? -x : x;
}

// 버퍼링된 출력
class FastOutput {
    static const int BUFFER_SIZE = 1 << 16;
    char buffer[BUFFER_SIZE];
    int pos = 0;
    
public:
    ~FastOutput() { flush(); }
    
    void flush() {
        fwrite(buffer, 1, pos, stdout);
        pos = 0;
    }
    
    void print(int x) {
        if (x < 0) {
            buffer[pos++] = '-';
            x = -x;
        }
        
        char digits[20];
        int len = 0;
        do {
            digits[len++] = '0' + x % 10;
            x /= 10;
        } while (x);
        
        while (len--) {
            buffer[pos++] = digits[len];
        }
        buffer[pos++] = '\n';
        
        if (pos > BUFFER_SIZE - 100) flush();
    }
};
```

### 컴파일 타임 최적화

```cpp
// 템플릿 메타프로그래밍
template<int N>
struct Factorial {
    static constexpr int value = N * Factorial<N-1>::value;
};

template<>
struct Factorial<0> {
    static constexpr int value = 1;
};

// 사용
constexpr int fact5 = Factorial<5>::value;  // 120

// SFINAE를 이용한 타입 체크
template<typename T>
using EnableIfIntegral = enable_if_t<is_integral_v<T>, bool>;

template<typename T, EnableIfIntegral<T> = true>
T safe_add(T a, T b) {
    if (a > 0 && b > numeric_limits<T>::max() - a) {
        throw overflow_error("Integer overflow");
    }
    return a + b;
}
```

## 📝 2단계 핵심 요약

### Python/Java 개발자가 주의할 점

1. **메모리 관리**: 수동 관리, RAII 패턴 활용
2. **포인터와 참조**: 명확한 구분과 활용
3. **템플릿**: 컴파일 타임 다형성
4. **이동 의미론**: 성능 최적화의 핵심

### C++다운 코딩 스타일

1. **RAII 활용**: 자원 관리 자동화
2. **STL 알고리즘**: 반복문 대신 알고리즘 사용
3. **const 정확성**: const를 적극 활용
4. **스마트 포인터**: raw 포인터 대신 사용

### 자주 사용하는 패턴 체크리스트

- [ ] `ios_base::sync_with_stdio(false)`로 입출력 최적화
- [ ] 범위 기반 for문과 auto 활용
- [ ] STL 알고리즘과 람다 조합
- [ ] 스마트 포인터로 메모리 관리
- [ ] constexpr로 컴파일 타임 계산
- [ ] 이동 의미론으로 성능 최적화
- [ ] 템플릿으로 제네릭 프로그래밍

# C++ PS 3단계: PS 핵심 패턴

## 🔍 1. 탐색 알고리즘 (DFS/BFS 템플릿)

### DFS (깊이 우선 탐색)

#### 재귀적 DFS

```cpp
vector<vector<int>> graph;
vector<bool> visited;

void dfs_recursive(int node) {
    visited[node] = true;
    cout << node << ' ';  // 방문 처리
    
    for (int neighbor : graph[node]) {
        if (!visited[neighbor]) {
            dfs_recursive(neighbor);
        }
    }
}

// 사용 예시
int main() {
    int n = 6;  // 노드 수
    graph.resize(n);
    visited.resize(n, false);
    
    // 그래프 구성
    graph[0] = {1, 2};
    graph[1] = {0, 3, 4};
    graph[2] = {0, 5};
    graph[3] = {1};
    graph[4] = {1, 5};
    graph[5] = {2, 4};
    
    dfs_recursive(0);
}
```

#### 스택을 이용한 DFS

```cpp
void dfs_iterative(int start) {
    vector<bool> visited(graph.size(), false);
    stack<int> st;
    st.push(start);
    
    while (!st.empty()) {
        int node = st.top();
        st.pop();
        
        if (!visited[node]) {
            visited[node] = true;
            cout << node << ' ';  // 방문 처리
            
            // 역순으로 추가 (재귀와 같은 순서)
            for (int i = graph[node].size() - 1; i >= 0; i--) {
                if (!visited[graph[node][i]]) {
                    st.push(graph[node][i]);
                }
            }
        }
    }
}
```

#### 2차원 격자에서 DFS

```cpp
int dx[] = {-1, 1, 0, 0};  // 상하좌우
int dy[] = {0, 0, -1, 1};

void dfs_grid(vector<vector<int>>& grid, int x, int y, 
              vector<vector<bool>>& visited) {
    int n = grid.size();
    int m = grid[0].size();
    
    // 경계 체크 및 방문 체크
    if (x < 0 || x >= n || y < 0 || y >= m || 
        visited[x][y] || grid[x][y] == 0) {
        return;
    }
    
    visited[x][y] = true;
    cout << "방문: (" << x << ", " << y << ")\n";
    
    // 4방향 탐색
    for (int i = 0; i < 4; i++) {
        dfs_grid(grid, x + dx[i], y + dy[i], visited);
    }
}

// 연결 요소 개수 구하기
int countComponents(vector<vector<int>>& grid) {
    int n = grid.size();
    int m = grid[0].size();
    vector<vector<bool>> visited(n, vector<bool>(m, false));
    int count = 0;
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (grid[i][j] == 1 && !visited[i][j]) {
                dfs_grid(grid, i, j, visited);
                count++;
            }
        }
    }
    
    return count;
}
```

### BFS (너비 우선 탐색)

#### 기본 BFS

```cpp
void bfs(int start) {
    vector<bool> visited(graph.size(), false);
    queue<int> q;
    
    visited[start] = true;
    q.push(start);
    
    while (!q.empty()) {
        int node = q.front();
        q.pop();
        cout << node << ' ';  // 방문 처리
        
        for (int neighbor : graph[node]) {
            if (!visited[neighbor]) {
                visited[neighbor] = true;
                q.push(neighbor);
            }
        }
    }
}
```

#### 최단거리를 구하는 BFS

```cpp
int bfs_shortest_path(int start, int end) {
    vector<int> distance(graph.size(), -1);
    queue<int> q;
    
    distance[start] = 0;
    q.push(start);
    
    while (!q.empty()) {
        int node = q.front();
        q.pop();
        
        if (node == end) {
            return distance[end];
        }
        
        for (int neighbor : graph[node]) {
            if (distance[neighbor] == -1) {
                distance[neighbor] = distance[node] + 1;
                q.push(neighbor);
            }
        }
    }
    
    return -1;  // 경로가 없음
}
```

#### 2차원 격자에서 BFS

```cpp
int bfs_grid(vector<vector<int>>& grid, int startX, int startY) {
    int n = grid.size();
    int m = grid[0].size();
    vector<vector<bool>> visited(n, vector<bool>(m, false));
    queue<pair<pair<int, int>, int>> q;  // {{x, y}, dist}
    
    visited[startX][startY] = true;
    q.push({{startX, startY}, 0});
    
    while (!q.empty()) {
        auto [pos, dist] = q.front();
        auto [x, y] = pos;
        q.pop();
        
        cout << "방문: (" << x << ", " << y << "), 거리: " << dist << '\n';
        
        for (int i = 0; i < 4; i++) {
            int nx = x + dx[i];
            int ny = y + dy[i];
            
            if (nx >= 0 && nx < n && ny >= 0 && ny < m &&
                !visited[nx][ny] && grid[nx][ny] == 1) {
                
                visited[nx][ny] = true;
                q.push({{nx, ny}, dist + 1});
            }
        }
    }
    
    return -1;
}
```

### 🚨 DFS/BFS 주요 함정

- 재귀 DFS의 스택 오버플로우 (기본 스택 크기 제한)
- BFS에서 방문 체크를 큐에 넣을 때 해야 중복 방지
- 2차원 배열에서 dx, dy 배열 순서 실수
- 그래프 표현 방식 (인접 리스트 vs 인접 행렬)

## 📊 2. 정렬과 이진탐색 패턴

### 다양한 정렬 기법

#### 기본 정렬

```cpp
// 벡터 정렬
vector<int> arr = {3, 1, 4, 1, 5, 9, 2, 6};
sort(arr.begin(), arr.end());              // 오름차순
sort(arr.begin(), arr.end(), greater<int>());  // 내림차순

// 배열 정렬
int arr2[] = {3, 1, 4, 1, 5};
sort(arr2, arr2 + 5);
```

#### 커스텀 정렬

```cpp
// 구조체 정렬
struct Student {
    string name;
    int score;
    int age;
};

vector<Student> students = {
    {"Alice", 85, 20}, 
    {"Bob", 90, 19}, 
    {"Charlie", 85, 21}
};

// 점수 내림차순, 같으면 나이 오름차순
sort(students.begin(), students.end(), [](const Student& a, const Student& b) {
    if (a.score != b.score) return a.score > b.score;
    return a.age < b.age;
});

// pair 정렬 (자동으로 first, second 순)
vector<pair<int, int>> pairs = {{3, 1}, {1, 4}, {1, 2}};
sort(pairs.begin(), pairs.end());
```

#### 안정 정렬

```cpp
// stable_sort는 같은 값의 원래 순서 유지
vector<pair<string, int>> data = {
    {"A", 1}, {"B", 2}, {"C", 1}, {"D", 2}
};
stable_sort(data.begin(), data.end(), [](const auto& a, const auto& b) {
    return a.second < b.second;
});
// 결과: {{"A", 1}, {"C", 1}, {"B", 2}, {"D", 2}}
```

### 이진탐색 (Binary Search)

#### 기본 이진탐색

```cpp
int binary_search_manual(vector<int>& arr, int target) {
    int left = 0, right = arr.size() - 1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;  // 오버플로우 방지
        
        if (arr[mid] == target) {
            return mid;
        } else if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
    
    return -1;  // 찾지 못함
}

// STL 이진탐색
vector<int> arr = {1, 3, 5, 7, 9};
if (binary_search(arr.begin(), arr.end(), 5)) {
    cout << "Found\n";
}
```

#### Lower Bound / Upper Bound

```cpp
// 직접 구현
int lower_bound_manual(vector<int>& arr, int target) {
    int left = 0, right = arr.size();
    
    while (left < right) {
        int mid = left + (right - left) / 2;
        if (arr[mid] < target) {
            left = mid + 1;
        } else {
            right = mid;
        }
    }
    
    return left;
}

// STL 활용
vector<int> arr = {1, 2, 2, 2, 3, 4, 5};
auto lower = lower_bound(arr.begin(), arr.end(), 2);
auto upper = upper_bound(arr.begin(), arr.end(), 2);
int count = upper - lower;  // 2의 개수: 3

// 인덱스로 변환
int lower_idx = lower - arr.begin();
int upper_idx = upper - arr.begin();
```

#### 매개변수 탐색 (Parametric Search)

```cpp
// 조건을 만족하는 최솟값/최댓값 찾기
bool check(int mid, /* 필요한 매개변수 */) {
    // mid가 조건을 만족하는지 확인
    return true;  // or false
}

int parametric_search(int left, int right) {
    int result = -1;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (check(mid)) {
            result = mid;  // 가능한 값 저장
            right = mid - 1;  // 더 작은 값 탐색 (최솟값)
            // left = mid + 1;  // 더 큰 값 탐색 (최댓값)
        } else {
            left = mid + 1;  // 불가능하면 더 큰 값
            // right = mid - 1;  // 불가능하면 더 작은 값
        }
    }
    
    return result;
}

// 예시: 나무 자르기
bool can_cut_wood(vector<int>& trees, int height, int target) {
    long long total = 0;
    for (int tree : trees) {
        if (tree > height) {
            total += tree - height;
        }
    }
    return total >= target;
}

int find_max_height(vector<int>& trees, int target) {
    int left = 0, right = *max_element(trees.begin(), trees.end());
    int result = 0;
    
    while (left <= right) {
        int mid = left + (right - left) / 2;
        
        if (can_cut_wood(trees, mid, target)) {
            result = mid;
            left = mid + 1;  // 더 높은 높이 시도
        } else {
            right = mid - 1;
        }
    }
    
    return result;
}
```

### 🚨 정렬/이진탐색 주요 함정

- 이진탐색 전 정렬 필수
- `mid = (left + right) / 2`는 오버플로우 위험
- lower_bound는 이상, upper_bound는 초과
- 실수형 이진탐색은 횟수로 제한

## 👥 3. 투 포인터, 슬라이딩 윈도우

### 투 포인터 기법

#### 기본 투 포인터

```cpp
// 정렬된 배열에서 합이 target인 두 수 찾기
pair<int, int> two_sum_sorted(vector<int>& arr, int target) {
    int left = 0, right = arr.size() - 1;
    
    while (left < right) {
        int sum = arr[left] + arr[right];
        
        if (sum == target) {
            return {left, right};
        } else if (sum < target) {
            left++;
        } else {
            right--;
        }
    }
    
    return {-1, -1};
}
```

#### 연속 부분배열의 합

```cpp
// 합이 target인 연속 부분배열의 개수
int subarray_sum(vector<int>& arr, int target) {
    int left = 0;
    long long sum = 0;
    int count = 0;
    
    for (int right = 0; right < arr.size(); right++) {
        sum += arr[right];
        
        while (sum > target && left <= right) {
            sum -= arr[left];
            left++;
        }
        
        if (sum == target) {
            count++;
        }
    }
    
    return count;
}

// 합이 target 이상인 최소 길이 부분배열
int min_subarray_length(vector<int>& arr, int target) {
    int left = 0;
    long long sum = 0;
    int min_len = INT_MAX;
    
    for (int right = 0; right < arr.size(); right++) {
        sum += arr[right];
        
        while (sum >= target) {
            min_len = min(min_len, right - left + 1);
            sum -= arr[left];
            left++;
        }
    }
    
    return (min_len == INT_MAX) ? 0 : min_len;
}
```

#### 서로 다른 문자의 최장 부분문자열

```cpp
int longest_unique_substring(string s) {
    unordered_set<char> char_set;
    int left = 0;
    int max_length = 0;
    
    for (int right = 0; right < s.length(); right++) {
        while (char_set.count(s[right])) {
            char_set.erase(s[left]);
            left++;
        }
        
        char_set.insert(s[right]);
        max_length = max(max_length, right - left + 1);
    }
    
    return max_length;
}

// K개 이하의 서로 다른 문자를 포함하는 최장 부분문자열
int longest_k_distinct(string s, int k) {
    unordered_map<char, int> char_count;
    int left = 0;
    int max_length = 0;
    
    for (int right = 0; right < s.length(); right++) {
        char_count[s[right]]++;
        
        while (char_count.size() > k) {
            char_count[s[left]]--;
            if (char_count[s[left]] == 0) {
                char_count.erase(s[left]);
            }
            left++;
        }
        
        max_length = max(max_length, right - left + 1);
    }
    
    return max_length;
}
```

### 슬라이딩 윈도우

#### 고정 크기 윈도우

```cpp
// 크기가 k인 부분배열의 최대 합
int max_sum_subarray(vector<int>& arr, int k) {
    if (arr.size() < k) return -1;
    
    // 첫 번째 윈도우
    int window_sum = 0;
    for (int i = 0; i < k; i++) {
        window_sum += arr[i];
    }
    int max_sum = window_sum;
    
    // 윈도우 슬라이딩
    for (int i = k; i < arr.size(); i++) {
        window_sum = window_sum - arr[i - k] + arr[i];
        max_sum = max(max_sum, window_sum);
    }
    
    return max_sum;
}

// 크기가 k인 윈도우의 최댓값들
vector<int> sliding_window_maximum(vector<int>& arr, int k) {
    deque<int> dq;  // 인덱스 저장
    vector<int> result;
    
    for (int i = 0; i < arr.size(); i++) {
        // 윈도우 범위 벗어난 원소 제거
        while (!dq.empty() && dq.front() < i - k + 1) {
            dq.pop_front();
        }
        
        // 현재 원소보다 작은 원소들 제거
        while (!dq.empty() && arr[dq.back()] < arr[i]) {
            dq.pop_back();
        }
        
        dq.push_back(i);
        
        if (i >= k - 1) {
            result.push_back(arr[dq.front()]);
        }
    }
    
    return result;
}
```

#### 문자열 패턴 매칭

```cpp
// 문자열 s에서 p의 애너그램인 부분문자열 찾기
vector<int> find_anagrams(string s, string p) {
    vector<int> result;
    if (p.length() > s.length()) return result;
    
    vector<int> p_count(26, 0), window_count(26, 0);
    
    // p의 문자 빈도 계산
    for (char c : p) {
        p_count[c - 'a']++;
    }
    
    // 첫 번째 윈도우
    for (int i = 0; i < p.length(); i++) {
        window_count[s[i] - 'a']++;
    }
    
    if (window_count == p_count) {
        result.push_back(0);
    }
    
    // 윈도우 슬라이딩
    for (int i = p.length(); i < s.length(); i++) {
        window_count[s[i] - 'a']++;
        window_count[s[i - p.length()] - 'a']--;
        
        if (window_count == p_count) {
            result.push_back(i - p.length() + 1);
        }
    }
    
    return result;
}
```

### 🚨 투 포인터/슬라이딩 윈도우 주요 함정

- 포인터 이동 조건 명확히 정의
- 윈도우 크기와 경계 조건 주의
- 오버플로우 가능성 체크
- deque 활용한 최댓값/최솟값 추적

## 🏃 4. 그리디 알고리즘 패턴

### 기본 그리디 패턴

#### 활동 선택 문제

```cpp
// 끝나는 시간이 빠른 순으로 최대한 많은 활동 선택
int activity_selection(vector<pair<int, int>>& activities) {
    // 끝나는 시간 기준 정렬
    sort(activities.begin(), activities.end(), 
         [](const auto& a, const auto& b) {
             return a.second < b.second;
         });
    
    int count = 1;
    int last_end = activities[0].second;
    
    for (int i = 1; i < activities.size(); i++) {
        if (activities[i].first >= last_end) {
            count++;
            last_end = activities[i].second;
        }
    }
    
    return count;
}
```

#### 거스름돈 문제

```cpp
// 가장 적은 개수의 동전으로 거스름돈 만들기
vector<int> make_change(int amount, vector<int>& coins) {
    sort(coins.begin(), coins.end(), greater<int>());
    vector<int> result;
    
    for (int coin : coins) {
        while (amount >= coin) {
            result.push_back(coin);
            amount -= coin;
        }
    }
    
    return (amount == 0) ? result : vector<int>();
}
```

#### 최소 신장 트리 (크루스칼)

```cpp
struct Edge {
    int u, v, weight;
    bool operator<(const Edge& other) const {
        return weight < other.weight;
    }
};

class UnionFind {
    vector<int> parent, rank;
public:
    UnionFind(int n) : parent(n), rank(n, 0) {
        for (int i = 0; i < n; i++) {
            parent[i] = i;
        }
    }
    
    int find(int x) {
        if (parent[x] != x) {
            parent[x] = find(parent[x]);
        }
        return parent[x];
    }
    
    bool unite(int x, int y) {
        int px = find(x);
        int py = find(y);
        
        if (px == py) return false;
        
        if (rank[px] < rank[py]) {
            parent[px] = py;
        } else if (rank[px] > rank[py]) {
            parent[py] = px;
        } else {
            parent[py] = px;
            rank[px]++;
        }
        
        return true;
    }
};

int kruskal(int n, vector<Edge>& edges) {
    sort(edges.begin(), edges.end());
    UnionFind uf(n);
    int total_weight = 0;
    int edge_count = 0;
    
    for (const Edge& e : edges) {
        if (uf.unite(e.u, e.v)) {
            total_weight += e.weight;
            edge_count++;
            if (edge_count == n - 1) break;
        }
    }
    
    return total_weight;
}
```

### 그리디 선택의 정당성

#### 회의실 배정

```cpp
// 최소한의 회의실로 모든 회의 배정
int meeting_rooms(vector<pair<int, int>>& meetings) {
    vector<int> starts, ends;
    
    for (const auto& meeting : meetings) {
        starts.push_back(meeting.first);
        ends.push_back(meeting.second);
    }
    
    sort(starts.begin(), starts.end());
    sort(ends.begin(), ends.end());
    
    int rooms = 0, max_rooms = 0;
    int i = 0, j = 0;
    
    while (i < starts.size()) {
        if (starts[i] < ends[j]) {
            rooms++;
            max_rooms = max(max_rooms, rooms);
            i++;
        } else {
            rooms--;
            j++;
        }
    }
    
    return max_rooms;
}

// Priority Queue 활용
int meeting_rooms_pq(vector<pair<int, int>>& meetings) {
    if (meetings.empty()) return 0;
    
    sort(meetings.begin(), meetings.end());
    priority_queue<int, vector<int>, greater<int>> pq;
    
    pq.push(meetings[0].second);
    
    for (int i = 1; i < meetings.size(); i++) {
        if (meetings[i].first >= pq.top()) {
            pq.pop();
        }
        pq.push(meetings[i].second);
    }
    
    return pq.size();
}
```

### 🚨 그리디 주요 함정

- 그리디 선택이 항상 최적해 보장하지 않음
- 정렬 기준 선택이 중요
- 반례 찾기로 검증 필요
- 동적계획법과 구분

## 🧮 5. 동적계획법(DP) 기본 패턴

### 기본 DP 패턴

#### 피보나치 수열

```cpp
// Top-down (메모이제이션)
vector<long long> memo;

long long fibonacci_memo(int n) {
    if (n <= 1) return n;
    
    if (memo[n] != -1) return memo[n];
    
    return memo[n] = fibonacci_memo(n-1) + fibonacci_memo(n-2);
}

// Bottom-up
long long fibonacci_dp(int n) {
    if (n <= 1) return n;
    
    vector<long long> dp(n + 1);
    dp[0] = 0;
    dp[1] = 1;
    
    for (int i = 2; i <= n; i++) {
        dp[i] = dp[i-1] + dp[i-2];
    }
    
    return dp[n];
}

// 공간 최적화
long long fibonacci_optimized(int n) {
    if (n <= 1) return n;
    
    long long prev2 = 0, prev1 = 1;
    
    for (int i = 2; i <= n; i++) {
        long long current = prev1 + prev2;
        prev2 = prev1;
        prev1 = current;
    }
    
    return prev1;
}
```

#### 0-1 배낭 문제

```cpp
// 기본 2차원 DP
int knapsack_01(vector<int>& weights, vector<int>& values, int capacity) {
    int n = weights.size();
    vector<vector<int>> dp(n + 1, vector<int>(capacity + 1, 0));
    
    for (int i = 1; i <= n; i++) {
        for (int w = 1; w <= capacity; w++) {
            // i번째 물건을 넣지 않는 경우
            dp[i][w] = dp[i-1][w];
            
            // i번째 물건을 넣는 경우
            if (weights[i-1] <= w) {
                dp[i][w] = max(dp[i][w], 
                              dp[i-1][w-weights[i-1]] + values[i-1]);
            }
        }
    }
    
    return dp[n][capacity];
}

// 공간 최적화 (1차원 DP)
int knapsack_01_optimized(vector<int>& weights, vector<int>& values, int capacity) {
    vector<int> dp(capacity + 1, 0);
    
    for (int i = 0; i < weights.size(); i++) {
        // 뒤에서부터 갱신 (중복 사용 방지)
        for (int w = capacity; w >= weights[i]; w--) {
            dp[w] = max(dp[w], dp[w - weights[i]] + values[i]);
        }
    }
    
    return dp[capacity];
}
```

#### 최장 증가 부분 수열 (LIS)

```cpp
// O(n²) DP
int lis_dp(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp(n, 1);
    
    for (int i = 1; i < n; i++) {
        for (int j = 0; j < i; j++) {
            if (arr[j] < arr[i]) {
                dp[i] = max(dp[i], dp[j] + 1);
            }
        }
    }
    
    return *max_element(dp.begin(), dp.end());
}

// O(n log n) 이진탐색
int lis_binary_search(vector<int>& arr) {
    vector<int> tails;
    
    for (int num : arr) {
        auto it = lower_bound(tails.begin(), tails.end(), num);
        if (it == tails.end()) {
            tails.push_back(num);
        } else {
            *it = num;
        }
    }
    
    return tails.size();
}

// LIS 복원
vector<int> lis_with_path(vector<int>& arr) {
    int n = arr.size();
    vector<int> dp(n, 1);
    vector<int> parent(n, -1);
    
    for (int i = 1; i < n; i++) {
        for (int j = 0; j < i; j++) {
            if (arr[j] < arr[i] && dp[j] + 1 > dp[i]) {
                dp[i] = dp[j] + 1;
                parent[i] = j;
            }
        }
    }
    
    // 최대 길이와 끝 인덱스 찾기
    int max_length = 0, end_idx = -1;
    for (int i = 0; i < n; i++) {
        if (dp[i] > max_length) {
            max_length = dp[i];
            end_idx = i;
        }
    }
    
    // 경로 복원
    vector<int> lis;
    for (int i = end_idx; i != -1; i = parent[i]) {
        lis.push_back(arr[i]);
    }
    reverse(lis.begin(), lis.end());
    
    return lis;
}
```

#### 편집 거리 (Edit Distance)

```cpp
int edit_distance(string s1, string s2) {
    int m = s1.length(), n = s2.length();
    vector<vector<int>> dp(m + 1, vector<int>(n + 1));
    
    // 초기화
    for (int i = 0; i <= m; i++) dp[i][0] = i;
    for (int j = 0; j <= n; j++) dp[0][j] = j;
    
    for (int i = 1; i <= m; i++) {
        for (int j = 1; j <= n; j++) {
            if (s1[i-1] == s2[j-1]) {
                dp[i][j] = dp[i-1][j-1];
            } else {
                dp[i][j] = 1 + min({
                    dp[i-1][j],    // 삭제
                    dp[i][j-1],    // 삽입
                    dp[i-1][j-1]   // 교체
                });
            }
        }
    }
    
    return dp[m][n];
}
```

### DP 상태 설계 패턴

#### 구간 DP

```cpp
// 행렬 연쇄 곱셈
int matrix_chain_multiplication(vector<pair<int, int>>& matrices) {
    int n = matrices.size();
    vector<vector<int>> dp(n, vector<int>(n, 0));
    
    // 구간 길이를 늘려가며 계산
    for (int len = 2; len <= n; len++) {
        for (int i = 0; i <= n - len; i++) {
            int j = i + len - 1;
            dp[i][j] = INT_MAX;
            
            for (int k = i; k < j; k++) {
                int cost = dp[i][k] + dp[k+1][j] + 
                          matrices[i].first * matrices[k].second * matrices[j].second;
                dp[i][j] = min(dp[i][j], cost);
            }
        }
    }
    
    return dp[0][n-1];
}
```

#### 비트마스크 DP

```cpp
// 외판원 문제 (TSP)
int tsp(vector<vector<int>>& dist) {
    int n = dist.size();
    vector<vector<int>> dp(1 << n, vector<int>(n, INT_MAX));
    
    // 시작점에서 출발
    dp[1][0] = 0;
    
    for (int mask = 1; mask < (1 << n); mask++) {
        for (int i = 0; i < n; i++) {
            if (!(mask & (1 << i))) continue;
            
            for (int j = 0; j < n; j++) {
                if (i == j || !(mask & (1 << j))) continue;
                
                int prev_mask = mask ^ (1 << i);
                if (dp[prev_mask][j] != INT_MAX) {
                    dp[mask][i] = min(dp[mask][i], 
                                     dp[prev_mask][j] + dist[j][i]);
                }
            }
        }
    }
    
    // 모든 도시를 방문하고 시작점으로 돌아가는 최소 비용
    int result = INT_MAX;
    int final_mask = (1 << n) - 1;
    for (int i = 1; i < n; i++) {
        if (dp[final_mask][i] != INT_MAX) {
            result = min(result, dp[final_mask][i] + dist[i][0]);
        }
    }
    
    return result;
}
```

### 🚨 DP 주요 함정

- 상태 정의가 가장 중요
- 초기값 설정 주의
- 메모리 제한 고려 (상태 압축)
- Top-down vs Bottom-up 선택

## 🔤 6. 문자열 처리 고급 기법

### 패턴 매칭

#### KMP 알고리즘

```cpp
// 실패 함수 구축
vector<int> build_failure_function(string pattern) {
    int m = pattern.length();
    vector<int> failure(m, 0);
    int j = 0;
    
    for (int i = 1; i < m; i++) {
        while (j > 0 && pattern[i] != pattern[j]) {
            j = failure[j - 1];
        }
        
        if (pattern[i] == pattern[j]) {
            j++;
            failure[i] = j;
        }
    }
    
    return failure;
}

// KMP 검색
vector<int> kmp_search(string text, string pattern) {
    int n = text.length(), m = pattern.length();
    vector<int> matches;
    
    if (m == 0) return matches;
    
    vector<int> failure = build_failure_function(pattern);
    int j = 0;
    
    for (int i = 0; i < n; i++) {
        while (j > 0 && text[i] != pattern[j]) {
            j = failure[j - 1];
        }
        
        if (text[i] == pattern[j]) {
            j++;
        }
        
        if (j == m) {
            matches.push_back(i - m + 1);
            j = failure[j - 1];
        }
    }
    
    return matches;
}
```

#### 라빈-카프 알고리즘

```cpp
vector<int> rabin_karp_search(string text, string pattern) {
    const int base = 256;
    const int mod = 1e9 + 7;
    int n = text.length(), m = pattern.length();
    vector<int> matches;
    
    if (m > n) return matches;
    
    // 패턴의 해시값
    long long pattern_hash = 0;
    for (char c : pattern) {
        pattern_hash = (pattern_hash * base + c) % mod;
    }
    
    // base^(m-1) % mod
    long long h = 1;
    for (int i = 0; i < m - 1; i++) {
        h = (h * base) % mod;
    }
    
    // 첫 윈도우의 해시값
    long long window_hash = 0;
    for (int i = 0; i < m; i++) {
        window_hash = (window_hash * base + text[i]) % mod;
    }
    
    // 롤링 해시
    for (int i = 0; i <= n - m; i++) {
        if (window_hash == pattern_hash) {
            if (text.substr(i, m) == pattern) {
                matches.push_back(i);
            }
        }
        
        if (i < n - m) {
            window_hash = (window_hash - text[i] * h % mod + mod) % mod;
            window_hash = (window_hash * base + text[i + m]) % mod;
        }
    }
    
    return matches;
}
```

### 문자열 변환과 처리

#### 회문 검사와 관련 알고리즘

```cpp
// 기본 회문 검사
bool is_palindrome(string s) {
    int left = 0, right = s.length() - 1;
    while (left < right) {
        if (s[left] != s[right]) return false;
        left++;
        right--;
    }
    return true;
}

// 중심 확장으로 최장 회문
string longest_palindrome_expand(string s) {
    auto expand_around_center = [&](int left, int right) {
        while (left >= 0 && right < s.length() && s[left] == s[right]) {
            left--;
            right++;
        }
        return right - left - 1;
    };
    
    int start = 0, max_len = 0;
    for (int i = 0; i < s.length(); i++) {
        int len1 = expand_around_center(i, i);      // 홀수 길이
        int len2 = expand_around_center(i, i + 1);  // 짝수 길이
        
        int len = max(len1, len2);
        if (len > max_len) {
            max_len = len;
            start = i - (len - 1) / 2;
        }
    }
    
    return s.substr(start, max_len);
}

// Manacher's Algorithm (O(n))
string manacher_algorithm(string s) {
    // 전처리: 문자 사이에 특수 문자 삽입
    string processed = "#";
    for (char c : s) {
        processed += c;
        processed += '#';
    }
    
    int n = processed.length();
    vector<int> radius(n, 0);
    int center = 0, right = 0;
    
    for (int i = 0; i < n; i++) {
        if (i < right) {
            radius[i] = min(right - i, radius[2 * center - i]);
        }
        
        // 중심 확장
        while (i - radius[i] - 1 >= 0 && 
               i + radius[i] + 1 < n &&
               processed[i - radius[i] - 1] == processed[i + radius[i] + 1]) {
            radius[i]++;
        }
        
        // 오른쪽 경계 갱신
        if (i + radius[i] > right) {
            center = i;
            right = i + radius[i];
        }
    }
    
    // 최장 회문 찾기
    int max_len = 0, center_idx = 0;
    for (int i = 0; i < n; i++) {
        if (radius[i] > max_len) {
            max_len = radius[i];
            center_idx = i;
        }
    }
    
    int start = (center_idx - max_len) / 2;
    return s.substr(start, max_len);
}
```

#### 접미사 배열

```cpp
// 단순 구현 O(n²log n)
vector<int> suffix_array_naive(string s) {
    int n = s.length();
    vector<pair<string, int>> suffixes;
    
    for (int i = 0; i < n; i++) {
        suffixes.push_back({s.substr(i), i});
    }
    
    sort(suffixes.begin(), suffixes.end());
    
    vector<int> sa;
    for (const auto& suffix : suffixes) {
        sa.push_back(suffix.second);
    }
    
    return sa;
}

// LCP 배열
vector<int> lcp_array(string s, vector<int>& sa) {
    int n = s.length();
    vector<int> rank(n), lcp(n - 1);
    
    for (int i = 0; i < n; i++) {
        rank[sa[i]] = i;
    }
    
    int h = 0;
    for (int i = 0; i < n; i++) {
        if (rank[i] > 0) {
            int j = sa[rank[i] - 1];
            while (i + h < n && j + h < n && s[i + h] == s[j + h]) {
                h++;
            }
            lcp[rank[i] - 1] = h;
            if (h > 0) h--;
        }
    }
    
    return lcp;
}
```

### 트라이 (Trie)

```cpp
class TrieNode {
public:
    TrieNode* children[26];
    bool is_end;
    
    TrieNode() {
        is_end = false;
        for (int i = 0; i < 26; i++) {
            children[i] = nullptr;
        }
    }
};

class Trie {
private:
    TrieNode* root;
    
public:
    Trie() {
        root = new TrieNode();
    }
    
    void insert(string word) {
        TrieNode* node = root;
        for (char c : word) {
            int idx = c - 'a';
            if (!node->children[idx]) {
                node->children[idx] = new TrieNode();
            }
            node = node->children[idx];
        }
        node->is_end = true;
    }
    
    bool search(string word) {
        TrieNode* node = root;
        for (char c : word) {
            int idx = c - 'a';
            if (!node->children[idx]) {
                return false;
            }
            node = node->children[idx];
        }
        return node->is_end;
    }
    
    bool starts_with(string prefix) {
        TrieNode* node = root;
        for (char c : prefix) {
            int idx = c - 'a';
            if (!node->children[idx]) {
                return false;
            }
            node = node->children[idx];
        }
        return true;
    }
};
```

### 🚨 문자열 처리 주요 함정

- 문자열 인덱스 범위 체크
- 유니코드 처리 주의
- 해시 충돌 가능성
- 메모리 사용량 (특히 Trie)

## 📝 3단계 핵심 요약

### 필수 암기 템플릿

1. **DFS/BFS**: 그래프 탐색의 기본
2. **이진탐색**: lower_bound, upper_bound, 매개변수 탐색
3. **투 포인터**: 연속 부분배열, 두 수의 합
4. **슬라이딩 윈도우**: 고정/가변 크기 윈도우
5. **그리디**: 정렬 후 선택, 증명 필요
6. **DP**: 상태 정의가 핵심, 점화식 도출

### 알고리즘 선택 가이드

- **완전탐색 가능?** → DFS/BFS
- **정렬된 데이터?** → 이진탐색
- **연속된 구간?** → 투 포인터/슬라이딩 윈도우
- **최적 부분구조?** → DP
- **탐욕적 선택?** → 그리디
- **문자열 패턴?** → KMP/라빈-카프/Trie

### 시간복잡도 체크리스트

- O(2^n): 부분집합, 완전탐색
- O(n!): 순열
- O(n³): 3중 반복문, 플로이드
- O(n²): 2중 반복문, 단순 DP
- O(n log n): 정렬, 이진탐색 기반
- O(n): 선형 탐색, 투 포인터
- O(log n): 이진탐색
- O(1): 해시 테이블 접근