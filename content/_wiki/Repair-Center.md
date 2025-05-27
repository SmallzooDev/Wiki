---
title: 분산환경에서 결제 구현하기 💭
summary: 
date: 2025-05-28 00:51:19 +0900
lastmod: 2025-05-28 00:58:53 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## As-Is
---
![pg](https://private-user-images.githubusercontent.com/121675217/448007234-80460bf6-6f77-4671-bba9-953ef11e42a3.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDgzNjEzMjUsIm5iZiI6MTc0ODM2MTAyNSwicGF0aCI6Ii8xMjE2NzUyMTcvNDQ4MDA3MjM0LTgwNDYwYmY2LTZmNzctNDY3MS1iYmE5LTk1M2VmMTFlNDJhMy5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwNTI3JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDUyN1QxNTUwMjVaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1jZjJiZTkwYTZiYjRjMzk4ZjBmOGJlYjZhYWJmOTI2YTI0YjZjZmU5NGMxNWYyZThjZjg3N2ExMjllZWU5ODRjJlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.Y4r9cQ3gC_M6v-4d4Fgp7GJr9EI5hxUCXQBOp8RACj0)

>todo : 프로세스 간단한 설명
## To-Be
---
![pg2](https://private-user-images.githubusercontent.com/121675217/448006089-8484b194-9883-4173-b657-2ae2bad46514.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NDgzNjEzMjUsIm5iZiI6MTc0ODM2MTAyNSwicGF0aCI6Ii8xMjE2NzUyMTcvNDQ4MDA2MDg5LTg0ODRiMTk0LTk4ODMtNDE3My1iNjU3LTJhZTJiYWQ0NjUxNC5wbmc_WC1BbXotQWxnb3JpdGhtPUFXUzQtSE1BQy1TSEEyNTYmWC1BbXotQ3JlZGVudGlhbD1BS0lBVkNPRFlMU0E1M1BRSzRaQSUyRjIwMjUwNTI3JTJGdXMtZWFzdC0xJTJGczMlMkZhd3M0X3JlcXVlc3QmWC1BbXotRGF0ZT0yMDI1MDUyN1QxNTUwMjVaJlgtQW16LUV4cGlyZXM9MzAwJlgtQW16LVNpZ25hdHVyZT1lMmYyMmZkZmVjNzE5ZDg3ZjhiMGMzNjlhNjdhNTIxOTFhYzM3YzBjNWJjYTllY2EzYWVkNzgxZTM5MzE3Y2I1JlgtQW16LVNpZ25lZEhlYWRlcnM9aG9zdCJ9.EYS2ol1PdsMTmAsi7jqBxL7evtPE5lpfLKvybwfYfy4)

>todo : 분산환경이 된 이유, 자사 상품 관리 서버 설명


## Impl
---
>todo : 상태 추가를 한 이야기, 로컬 캐시를 쓰지 못한 이유, 트랜잭션으로 묶여야 했던 것들, 


## 회고
---
> todo : 아쉬웠던점, 아웃박스를 두려고 했다면, 나중에 알게된 사실 (socket timeout)

