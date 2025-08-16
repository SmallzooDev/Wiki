---
title: Golang의 임베딩
summary: 
date: 2025-08-16 15:57:04 +0900
lastmod: 2025-08-16 15:57:04 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
## 기본 개념

임베딩은 Go에서 **상속과 비슷한 효과**를 내는 방법. 하지만 상속이 아니라 **컴포지션(composition)**.

## 구조체 임베딩

### 기본 사용법

```go
type Person struct {
    Name string
    Age  int
}

func (p Person) Greet() string {
    return "안녕, 나는 " + p.Name
}

type Employee struct {
    Person    // 임베딩! 타입만 쓰고 필드명 없음
    Position  string
    Salary    int
}

func main() {
    emp := Employee{
        Person:   Person{Name: "김철수", Age: 30},
        Position: "개발자",
        Salary:   5000,
    }
    
    // Person의 필드에 직접 접근 가능
    fmt.Println(emp.Name)     // "김철수"
    fmt.Println(emp.Age)      // 30
    
    // Person의 메서드도 직접 호출 가능
    fmt.Println(emp.Greet())  // "안녕, 나는 김철수"
    
    // 물론 명시적 접근도 가능
    fmt.Println(emp.Person.Name)   // "김철수"
    fmt.Println(emp.Person.Greet()) // "안녕, 나는 김철수"
}
```

## 메서드 승격(Method Promotion)

```go
type Animal struct {
    Name string
}

func (a Animal) Speak() string {
    return a.Name + "가 소리냄"
}

func (a Animal) Move() string {
    return a.Name + "가 움직임"
}

type Dog struct {
    Animal
    Breed string
}

// Dog 타입에 새로운 메서드 추가
func (d Dog) Bark() string {
    return d.Name + "가 멍멍!"
}

// Animal의 메서드 오버라이드
func (d Dog) Speak() string {
    return d.Name + "가 멍멍 짖음"
}

func main() {
    dog := Dog{
        Animal: Animal{Name: "바둑이"},
        Breed:  "진돗개",
    }
    
    fmt.Println(dog.Move())  // "바둑이가 움직임" (Animal에서 승격)
    fmt.Println(dog.Speak()) // "바둑이가 멍멍 짖음" (Dog에서 오버라이드)
    fmt.Println(dog.Bark())  // "바둑이가 멍멍!" (Dog 고유 메서드)
}
```

## 다중 임베딩

```go
type Reader struct{}
func (r Reader) Read() string { return "읽기" }

type Writer struct{}
func (w Writer) Write() string { return "쓰기" }

type ReadWriter struct {
    Reader
    Writer
}

func main() {
    rw := ReadWriter{}
    fmt.Println(rw.Read())  // "읽기"
    fmt.Println(rw.Write()) // "쓰기"
}
```

## 이름 충돌 시 해결

```go
type A struct{}
func (a A) Method() string { return "A" }

type B struct{}
func (b B) Method() string { return "B" }

type C struct {
    A
    B
}

func main() {
    c := C{}
    
    // 이건 에러! 어떤 Method()인지 모호함
    // fmt.Println(c.Method())
    
    // 명시적으로 접근해야 함
    fmt.Println(c.A.Method()) // "A"
    fmt.Println(c.B.Method()) // "B"
}
```

## 인터페이스 임베딩

```go
type Reader interface {
    Read() error
}

type Writer interface {
    Write() error
}

type ReadWriter interface {
    Reader  // 인터페이스도 임베딩 가능
    Writer
}

// 위는 아래와 동일
type ReadWriter2 interface {
    Read() error
    Write() error
}
```

### 1. 공통 기능 추가

```go
type Timestamp struct {
    CreatedAt time.Time
    UpdatedAt time.Time
}

func (t *Timestamp) Touch() {
    now := time.Now()
    if t.CreatedAt.IsZero() {
        t.CreatedAt = now
    }
    t.UpdatedAt = now
}

type User struct {
    Timestamp  // 모든 엔티티에 공통으로 추가
    Name   string
    Email  string
}

type Post struct {
    Timestamp
    Title   string
    Content string
}

func main() {
    user := &User{Name: "김철수", Email: "kim@example.com"}
    user.Touch()  // Timestamp의 메서드 사용
    
    post := &Post{Title: "제목", Content: "내용"}
    post.Touch()  // 마찬가지로 사용 가능
}
```

### 2. 기존 타입 확장

```go
type MyString string

func (ms MyString) IsPalindrome() bool {
    s := string(ms)
    runes := []rune(s)
    for i := 0; i < len(runes)/2; i++ {
        if runes[i] != runes[len(runes)-1-i] {
            return false
        }
    }
    return true
}

type EnhancedString struct {
    MyString
}

func (es EnhancedString) Length() int {
    return len(string(es.MyString))
}

func main() {
    enhanced := EnhancedString{MyString: "level"}
    fmt.Println(enhanced.IsPalindrome()) // true
    fmt.Println(enhanced.Length())       // 5
}
```

## 임베딩 vs 상속 차이점

### 상속 (다른 언어)

- **IS-A 관계**: Dog는 Animal이다
- 런타임 다형성 지원

### 임베딩 (Go)

- **HAS-A 관계**: Employee는 Person을 가진다
- 컴파일 타임에 결정됨
- 더 명시적이고 예측 가능

```go
func processAnimal(a Animal) {
    fmt.Println(a.Speak())
}

func main() {
    dog := Dog{Animal: Animal{Name: "바둑이"}}
    
    // 이건 안 됨! Dog는 Animal이 아니라 Animal을 가지는 것
    // processAnimal(dog)
    
    // 명시적으로 Animal 부분을 전달해야 함
    processAnimal(dog.Animal)
}
```

## 장점과 단점

### 장점

- **코드 재사용**: 공통 기능을 쉽게 공유
- **단순함**: 복잡한 상속 계층 없음
- **명시적**: 어떤 기능이 어디서 오는지 명확

### 단점

- **다형성 제한**: 런타임 다형성 어려움
- **인터페이스 분리**: 각각 다른 인터페이스로 처리해야 함