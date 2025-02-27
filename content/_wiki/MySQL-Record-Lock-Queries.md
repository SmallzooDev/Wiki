---
title: MySQL 레코드 락 확인 쿼리들
summary: 
date: 2025-02-27 20:37:34 +0900
lastmod: 2025-02-27 21:06:42 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## MySQL의 performance_schema.data_locks와 performance_schema.data_lock_waits 활용 예시

MySQL의 `performance_schema.data_locks`와 `performance_schema.data_lock_waits` 테이블을 활용하여 데이터베이스 락을 조회하는 다양한 예시와 결과를 정리.  

---

## performance_schema.data_locks와 performance_schema.data_lock_waits 개요
- **`data_locks`**: 현재 활성화된 모든 락 정보를 포함하는 테이블
- **`data_lock_waits`**: 트랜잭션이 기다리는 락 정보를 보여주는 테이블 (Deadlock 가능성 분석)

---

## 1. 기본적인 락 정보 조회
```sql
SELECT * FROM performance_schema.data_locks;
```
### ✅ 결과 예시
| ENGINE | OBJECT_SCHEMA | OBJECT_NAME | INDEX_NAME | LOCK_TYPE | LOCK_MODE | LOCK_STATUS |
| ------ | ------------- | ----------- | ---------- | --------- | --------- | ----------- |
| INNODB | mydb          | users       | PRIMARY    | RECORD    | X         | GRANTED     |
| INNODB | mydb          | orders      | NULL       | TABLE     | IX        | GRANTED     |

- `LOCK_TYPE`: `TABLE`, `RECORD`, `AUTO_INC` 등
- `LOCK_MODE`: `X(Exclusive)`, `S(Shared)`, `IX(Intent Exclusive)`, `IS(Intent Shared)`
- `LOCK_STATUS`: `GRANTED`, `WAITING`

---

## 2. 특정 테이블에 걸린 락 확인
```sql
SELECT ENGINE, OBJECT_SCHEMA, OBJECT_NAME, LOCK_TYPE, LOCK_MODE, LOCK_STATUS
FROM performance_schema.data_locks
WHERE OBJECT_SCHEMA = 'mydb' AND OBJECT_NAME = 'users';
```
### ✅ 결과 예시
| ENGINE | OBJECT_SCHEMA | OBJECT_NAME | LOCK_TYPE | LOCK_MODE | LOCK_STATUS |
| ------ | ------------- | ----------- | --------- | --------- | ----------- |
| INNODB | mydb          | users       | RECORD    | X         | GRANTED     |

---

## 3. 트랜잭션이 기다리고 있는 락 조회
```sql
SELECT * FROM performance_schema.data_lock_waits;
```
### ✅ 결과 예시
| REQUESTING_ENGINE | REQUESTING_THREAD_ID | REQUESTING_TRANSACTION_ID | BLOCKING_ENGINE | BLOCKING_THREAD_ID | BLOCKING_TRANSACTION_ID |
| ----------------- | -------------------- | ------------------------- | --------------- | ------------------ | ----------------------- |
| INNODB            | 12345                | 56789                     | INNODB          | 67890              | 34567                   |

- **REQUESTING_TRANSACTION_ID**: 락을 기다리는 트랜잭션
- **BLOCKING_TRANSACTION_ID**: 락을 잡고 있는 트랜잭션

---

## 4. 특정 트랜잭션이 기다리고 있는 락 확인
```sql
SELECT dl.ENGINE, dl.OBJECT_SCHEMA, dl.OBJECT_NAME, dl.LOCK_TYPE, dl.LOCK_MODE, dl.LOCK_STATUS
FROM performance_schema.data_locks dl
JOIN performance_schema.data_lock_waits dlw
ON dlw.REQUESTING_ENGINE = dl.ENGINE
AND dlw.REQUESTING_THREAD_ID = dl.THREAD_ID;
```
### ✅ 결과 예시
| ENGINE | OBJECT_SCHEMA | OBJECT_NAME | LOCK_TYPE | LOCK_MODE | LOCK_STATUS |
| ------ | ------------- | ----------- | --------- | --------- | ----------- |
| INNODB | mydb          | orders      | RECORD    | X         | WAITING     |

---

## 5. 특정 테이블에서 락을 대기 중인 트랜잭션 확인
```sql
SELECT dlw.REQUESTING_TRANSACTION_ID, dlw.BLOCKING_TRANSACTION_ID, dl.OBJECT_SCHEMA, dl.OBJECT_NAME, dl.LOCK_TYPE
FROM performance_schema.data_lock_waits dlw
JOIN performance_schema.data_locks dl
ON dlw.REQUESTING_THREAD_ID = dl.THREAD_ID
WHERE dl.OBJECT_SCHEMA = 'mydb' AND dl.OBJECT_NAME = 'orders';
```
### ✅ 결과 예시
| REQUESTING_TRANSACTION_ID | BLOCKING_TRANSACTION_ID | OBJECT_SCHEMA | OBJECT_NAME | LOCK_TYPE |
| ------------------------- | ----------------------- | ------------- | ----------- | --------- |
| 56789                     | 34567                   | mydb          | orders      | RECORD    |

---

## 📝 6. 특정 트랜잭션이 보유한 락과 대기 중인 락 함께 조회
```sql
SELECT 
    dlw.REQUESTING_TRANSACTION_ID AS waiting_txn, 
    dlw.BLOCKING_TRANSACTION_ID AS blocking_txn, 
    r.OBJECT_SCHEMA AS blocking_schema, 
    r.OBJECT_NAME AS blocking_table, 
    w.OBJECT_SCHEMA AS waiting_schema, 
    w.OBJECT_NAME AS waiting_table
FROM performance_schema.data_lock_waits dlw
JOIN performance_schema.data_locks r 
ON dlw.BLOCKING_THREAD_ID = r.THREAD_ID
JOIN performance_schema.data_locks w
ON dlw.REQUESTING_THREAD_ID = w.THREAD_ID;
```
### ✅ 결과 예시
| waiting_txn | blocking_txn | blocking_schema | blocking_table | waiting_schema | waiting_table |
| ----------- | ------------ | --------------- | -------------- | -------------- | ------------- |
| 56789       | 34567        | mydb            | orders         | mydb           | payments      |

---

## 📝 7. SHOW ENGINE INNODB STATUS와 비교하여 Deadlock 분석
```sql
SHOW ENGINE INNODB STATUS;
```
### ✅ 결과 예시
```
------------------------
LATEST DETECTED DEADLOCK
------------------------
*** (1) TRANSACTION:
TRANSACTION 56789, ACTIVE 10 sec
LOCK WAIT on table `mydb`.`orders`...
*** (2) TRANSACTION:
TRANSACTION 34567, ACTIVE 12 sec
LOCK WAIT on table `mydb`.`payments`...
```
- `performance_schema.data_lock_waits`와 비교하면 어떤 트랜잭션이 막혀 있는지 상세 확인 가능

---

## 🔥 정리
| 시나리오                      | 조회 쿼리                                               |
| ------------------------- | --------------------------------------------------- |
| 모든 락 확인                   | `SELECT * FROM performance_schema.data_locks;`      |
| 특정 테이블의 락 조회              | `WHERE OBJECT_NAME = 'users'`                       |
| 트랜잭션 대기 중인 락 확인           | `SELECT * FROM performance_schema.data_lock_waits;` |
| 특정 트랜잭션이 대기 중인 락          | `JOIN performance_schema.data_locks ON THREAD_ID`   |
| 대기 중인 트랜잭션과 보유 중인 트랜잭션 조회 | `JOIN data_locks 두 번 사용`                            |
| Deadlock 상세 분석            | `SHOW ENGINE INNODB STATUS`                         |
