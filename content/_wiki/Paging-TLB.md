---
title: OSTEP, 페이징
summary: 
date: 2025-03-02 17:09:37 +0900
lastmod: 2025-03-02 18:02:05 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## 19 페이징: 더 빠른 변환(TLB)
- 매핑 정보 저장(페이지 테이블 저장)을 위해 큰 메모리 공간이 요구됨
- 가상 주소에서 물리 주소로의 주소 변환을 위해 메모리에 존재하는 매핑정보를 읽어야함.
> 핵심 질문: 주소 변환 속도를 어떻게 향상할까?

- 주소 변환을 빠르게 하기 위해 우리는 변환-색인 버퍼(translation-lookaside-buffer) 줄여서 TLB라고 부르는 것을 도입한다.
- 칩의 MMU(memory-management unit)의 일부라고 한다.
- 자주 참조되는 가상주소 - 실주소 변환 정보를 저장하는 하드웨어 캐시이다.
- 주소-변환 캐시가 좀 더 적합한 명칭이다.
### 19.1 TLB의 기본 알고리즘

```c
// 가상 주소에서 VPN(가상 페이지 번호) 추출  
VPN = (VirtualAddress & VPN_MASK) >> SHIFT;  

// TLB 조회 (TLB 히트 여부 확인)  
(Success, TlbEntry) = TLB_Lookup(VPN);  

if (Success == True) { // TLB Hit  
    if (CanAccess(TlbEntry.ProtectBits) == True) {  
        // 가상 주소에서 오프셋 추출  
        Offset = VirtualAddress & OFFSET_MASK;  
        // TLB에서 가져온 PFN을 사용하여 물리 주소 계산  
        PhysAddr = (TlbEntry.PFN << SHIFT) | Offset;  
        // 물리 주소에서 데이터 읽기  
        Register = AccessMemory(PhysAddr);  
    } else {  
        // 접근 권한 없음 → 보호 오류 발생  
        RaiseException(PROTECTION_FAULT);  
    }  
} else { // TLB Miss → 페이지 테이블 접근  
    // 페이지 테이블 엔트리(PTE) 주소 계산  
    PTEAddr = PTBR + (VPN * sizeof(PTE));  
    // PTE 가져오기  
    PTE = AccessMemory(PTEAddr);  

    if (PTE.Valid == False) {  
        // 페이지가 유효하지 않음 → 세그멘테이션 오류 발생  
        RaiseException(SEGMENTATION_FAULT);  
    } else if (CanAccess(PTE.ProtectBits) == False) {  
        // 접근 권한 없음 → 보호 오류 발생  
        RaiseException(PROTECTION_FAULT);  
    } else {  
        // TLB에 새로운 항목 삽입  
        TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits);  
        // 같은 명령어를 다시 실행하여 변환된 주소 사용  
        RetryInstruction();  
    }  
}
```
- 모든 캐시의 설계 철학처럼, TLB역시 주소 변환 정보가 대부분의 경우 캐시에 있다라는 가정을 전제로 만들어졌다.
- TLB는 프로세싱 코어와 가까운곳에 위치하고있어 주소변환은 그다지 부담스러운작업이아니다.
- 다만 미스가 발생하는 경우 엄청나게 커진다.
### 19.2 예제: 배열 접근
- 간단한 캐시 히트 관련 예제
- 다만 페이지 크기가 TLB 효용성과 성능에 매우 중요한 역할을 보여주는 예제이다.
![Image](https://github.com/user-attachments/assets/342633de-b97b-4330-b3a6-6abcdaa00cd8)
- (a[0]부터) : miss, hit, hit, miss, hit, hit, hit, miss, hit, hit
- 이 예시에서 정말 첫접근부터 미스로 들어갔는데 70%의 히트율을 자랑한다.
- 이건 공간 지역성(Spatial Locality)때문에 그렇다
	- 현재 참조한 데이터와 가까운 주소의 데이터도 곧 참조될 가능성이 높다.
	- 예: 배열(Array)나 연속된 메모리 접근.
- 그리고 이후에는 히트할 확률이 더높은데 (tlb에 남아있는 동안 다시 참조가 일어날 가능성이 높다)
- 이것도 시간 지역성(Temoporal Locality)때문이다.
	- 최근에 참조한 데이터는 곧 다시 참조될 가능성이 높다.
	- 예: 루프(loop)에서 같은 변수를 반복적으로 참조함.
### 19.3 TLB 미스는 누가 처리할까?
- 예전에는 주로 하드웨어
- 요즘에는 os가 트랩 핸들러로 처리하기도 함

### 19.4 TLB의 구성: 무엇이 있나?
- 일반적으로 페이지테이블에 있는 것들중 일부
- protection bit 
- valid bit (근데 페이지 테이블의 valid-bit랑은 다름!!!!)
	- 페이지 테이블은 : 아직 할당되느 않은 물리 페이지 프레임 
	- tlb는 : 실제 유효한 캐시인지를 따짐, 컨텍스트 스위칭시 invalid로 다른 프로세스로부터의 접근을 막음!
- dirty bit
- 등등..

### 19.5 TLB의 문제: 문맥 교환
- 요약하자면 컨텍스트 스위칭시 이전 프로세스의 tlb가 남아서 문제라는건데,
- 비우는 방식은 오버헤드를 크게 만든다 (valid bit를 건들어도 마찬가지)
- 그래서 주소 공간 식별자를 두거나 프로세스 식별자를 두는 방식으로 보완한다.

### 19.6 이슈: 교체 정책
> 캐시 교체 정책이 매우 중요하다.
> 핵심 질문: TLB 교체 정책은 어떻게 설계해야하는가?
> 목표는 미스율을 줄이고 히트율을 증가시켜 성능을 개선하는 것이다.

- 일단 가능한건 지역성을 최대로 활용하는 LRU(least-recently-used)가 있다.
	- 일반적으로 최근에 참조되지 않은 애들일수록 다시 참조될 가능성이 적음
- 또 다른 방법은 랜덤인데 조금더 안정적인 면이 있고 잘 동작한다.
> 고장난 시계는 2번은 맞지만 딱 1초 틀린 시계는....

- 4개를 저장할수있는데 다섯개(p1,p2,p3,p4,p5)인 상황에서
- p5 진입 시점에 p1을 버리고, 다음접근이 p1이라 맞물려 미스가 나는걸 의미


