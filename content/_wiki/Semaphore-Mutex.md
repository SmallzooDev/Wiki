---
title: 세마포어와 뮤텍스 🔄
summary: 여러가지 사유로 자주 맞닥뜨려서 다시 정리
date: 2025-06-12 20:09:32 +0900
lastmod: 2025-06-12 20:34:10 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

> 출처 : 공룡책과 ostep 

[공룡책](https://product.kyobobook.co.kr/detail/S000001868743), [ostep](https://product.kyobobook.co.kr/detail/S000001732174)

### 경쟁 조건
> 여러개의 프로세스가 동일한 데이터에 접근했을 때, 접근이 일어난 순서에 따라서 결과값이 달라지는것을 경쟁조건, Race condition이라고 한다.
