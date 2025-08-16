---
title: go 제로값과 값없음
summary: 
date: 2025-08-16 14:29:10 +0900
lastmod: 2025-08-16 14:29:10 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## "값이 없음"을 어떻게 표현할까?

예를 들어 사용자 정보를 담는 구조체가 있으면.

```go
type User struct {
    Name string
    Age  int
}

user := User{Name: "홍길동"}
fmt.Println(user.Age) // 0
```

여기서 문제가 생긴다. `user.Age`가 0인데, 이게 진짜 0살인지 아니면 나이 정보가 없는 건지 구분할 수 없다.

## 해결책 1: 포인터 사용

```go
type User struct {
    Name string
    Age  *int
}

// 나이를 아는 경우
age := 25
user1 := User{Name: "김철수", Age: &age}

// 나이를 모르는 경우
user2 := User{Name: "박영희", Age: nil}

// 사용할 때
if user1.Age != nil {
    fmt.Printf("%s 나이: %d\n", user1.Name, *user1.Age)
} else {
    fmt.Printf("%s 나이 정보 없음\n", user1.Name)
}
```

이렇게 하면 `nil`로 "값이 없음"을 명확하게 표현할 수 있다.

## 해결책 2: bool 플래그 사용

```go
type User struct {
    Name   string
    Age    int
    HasAge bool
}

user1 := User{Name: "김철수", Age: 25, HasAge: true}
user2 := User{Name: "박영희", HasAge: false}

if user1.HasAge {
    fmt.Printf("%s 나이: %d\n", user1.Name, user1.Age)
} else {
    fmt.Printf("%s 나이 정보 없음\n", user1.Name)
}
```

## JSON에서는 포인터가 유용하다

JSON을 다룰 때는 포인터 방식이 더 편리하다.

```go
type User struct {
    Name string `json:"name"`
    Age  *int   `json:"age,omitempty"`
}

// JSON: {"name": "홍길동", "age": 25}
// 파싱하면 Age는 25를 가리키는 포인터

// JSON: {"name": "김철수"}  
// 파싱하면 Age는 nil
```

`omitempty` 태그와 포인터를 함께 쓰면, 값이 없을 때 JSON에서 해당 필드를 아예 생략할 수 있다.

## 주의사항

포인터를 함수 파라미터로 넘길 때 조심해야 함.

```go
func updateAge(user *User, newAge int) {
    if user == nil {
        return // nil이면 아무것도 할 수 없음
    }
    age := newAge
    user.Age = &age
}
```

nil 포인터를 받으면 값을 설정할 수 없으니까 항상 nil 체크를 해야 함.

## 결론

- **일반적인 경우**: bool 플래그 방식이 더 안전
- **JSON 처리**: 포인터 + nil 방식이 편리
- **항상 nil 체크** 잊지 말기

