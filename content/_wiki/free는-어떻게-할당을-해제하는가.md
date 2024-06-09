---
title: c/cpp free는 어떻게 할당을 해제하는가
summary: 
date: 2024-06-08 17:17:54 +0900
lastmod: 2024-06-08 17:17:54 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## malloc()이 반환하는 값은 void* 타입이다.

- 사실 할당하고 데이터의 시작 주소를 반환하긴 하지만, 사실은 내부적으로 헤더값이 있어, 방금 할당한 메모리 공간에 대한 메타 정보를 가지고 있다.
