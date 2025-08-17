---
title: 고루틴 요약
summary: 
date: 2025-08-17 14:27:35 +0900
lastmod: 2025-08-17 14:27:35 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## Goroutines
- Goroutine Scheduling in Go
	- Managed by the Go Runtime Scheduler
	- Uses M:N Scheduling Model
		- M goroutines are mapped onto N operating system threads
	- Efficient Multiplexing (switching)

- Concurrency vs Parellelism
	- Concurrency : multiple tasks progress simultaneously and not necessarily at the same time
	- Parellelism : tasks are executed literally at the same time on mutliple processors
- Common Pitfalls and Best Practices
	- Avoiding Goroutine Leaks
	- Limiting Goroutine Creation
	- Proper Error Handling
	- Synchronization
