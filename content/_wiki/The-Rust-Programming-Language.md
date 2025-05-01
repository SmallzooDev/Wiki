---
title: The Rust Programming Language
summary: 
date: 2024-03-31 15:59:52 +0900
lastmod: 2025-05-02 00:11:21 +0900
tags: 
categories: 
public: true
parent: 
description: 
showToc: true
---


## 러스트 공식 가이드 문서 정리

- [The Rust Programming Language](https://doc.rust-lang.org/book/)
- 위의 러스트 공식 가이드 문서를 보고 정리한 내용입니다, 복습을 위해 공식 가이드를 한 번 다시 정리하고 시작하려고 합니다. ~~집합인가~~


 1. [[Getting-Started]] : 러스트 설치 및 프로젝트 생성에 대한 가이드
 2. [[Programming-a-Guessing-Game]] : 간단한 숫자 맞추기 게임을 만들어보며 러스트 프로그래밍 기초 문법 및 개념 익히기
 3. [[Common-Programming-Concepts]] : 러스트 프로그래밍 기초 문법 및 개념
 4. [[Understanding-Ownership]] : 러스트의 소유권 시스템에 대한 이해
	 - [[burrow-checker]] : rust-in-action 내용 
 5. [[Using-Structs-to-Structure-Related-Data]] : 구조체를 사용하여 관련 데이터 구조화하기
 6. [[Enums-and-Pattern-Matching]] : 열거형과 패턴 매칭
 7. [[Managing-Growing-Projects-with-Packages-Crates-and-Modules]] : 패키지, 크레이트, 모듈을 사용하여 프로젝트 확장하기
 8. [[Common-Collections]] : 컬렉션 사용하기
 9. [[Error-Handling]] : 에러 처리하기
 10. [[Funcional-Langauges-Features]] : Iterators and Closures
 11. [[Smart-Pointers]] : 스마트포인터 

- 변수의 수명은 컴파일 시점에서  스코프 내에서 더이상 사용이 되지 않는걸 확인 가능한 마지막 줄까지
- 이걸 악용해서 여러개의 가변 참조를 가지는게 약간 안티패턴 같다.


