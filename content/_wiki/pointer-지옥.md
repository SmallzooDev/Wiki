---
title: 포인터 지옥😢
summary: 
date: 2024-05-15 23:10:23 +0900
lastmod: 2024-05-15 23:10:23 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---


```cpp
int arr[10] = {1,2,3,4,5,6,7,8,9,10};
int *p = arr;

cout << p[0] << endl;
cout << arr[0] << endl;
cout << p[5] << endl;
cout << arr[5] << endl;
cout << *p << endl;
cout << *arr << endl;
cout << *(p+5) << endl;
cout << *(arr+5) << endl;

int arr2[2][2] = {{1,2},{3,4}};

int** pp = (int**)arr2; // error : 2차원 배열은 다중 포인터와 다름

```


`int** pp = (int**)arr2; // error : 2차원 배열은 다중 포인터와 다름` : 이 부분에서 에러가 나는 이유.
- 첫 *(포인터 연산)은 arr2[0]의 주소값을 가리킨다.
 
- 두번째 *(포인터 연산)은 arr2[0][0]의 value를 가리킨다.

- 포인터 연산은 해당 메모리 주소로 가서 값을 참조하는것이다.
 
- 위의 예시에서 다중 포인터의 의도에서는 첫번째 포인터 연산을 끝냈을 때, 포인터형 변수의 값이라 인지하고 값을 참조한다. 즉 첫 포인터 연산 이후 참조한 값은 int형 변수의 주소값이다.

- 하지만 실제로 해당 주소칸에 존재하는 값은 int형 변수의 값이다.

- 여기서 해당 값을 주소로 생각하고 참조하려다 보니 에러가 발생한다.

[PointerCheatSheat](https://www.geeksforgeeks.org/cpp-pointers/)
