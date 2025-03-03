---
title: OSTEP, 페이징
summary: 
date: 2025-03-02 17:09:37 +0900
lastmod: 2025-03-03 17:13:45 +0900
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


## 20 페이징: 더 작은 테이블
> 핵심 질문: 페이지 테이블을 어떻게 더 작게 만들까
> 단순한 배열 기반의 페이지 테이블은 크기가 크며 일반적인 시스템에서 메모리를 과도하게 차지한다.

- 32비트 주소공간에서 4kb는 4mb의 페이지테이블을 가진다.
### 20.1 간단한 해법: 더 큰 페이지
- 32비트 주소공간에서 16kb를 가정해보자, 이제는 18비트 vpn과 14비트의 오프셋을 갖게된다.
- 문제는 이러면 내부 단편화가 심해진다.
- 결론적으로 옳바른 해결방법은 아니다.

### 20.2 하이브리드 접근 방법: 페이징과 세그먼트
- 힙 코드, 스택 세그먼트에 대한 페이지 테이블을 따로 주는것이다.
- 일견 좋아보이기는 하지만, 외부단편화, 내부단편화가 심했다.

### 20.3 멀티 레벨 페이지 테이블
> 페이지 테이블을 트리 구조로 표현한다. 매우 효율적이기 때문에 많은 현대 시스템에서 사용되고 있다.

- 기본 개념은 간단하다.
	- 먼저, 페이지 테이블을 페이지 크기의 단위로 다눈다.
	- 그 다음, 페이지 테이블의 페이지가 유효하지 않은 항목이 있으면, 해당 페이지를 할당하지 않는다.
	- 페이지 디렉터리라는 자료 구조를 사용하여 페이지 테이블 각페이지의 할당 여부와 위치를 파악한다.
![Image](https://github.com/user-attachments/assets/9d5ec32a-ca78-455d-902d-5e477d962ca7)
- pfn은 page frame number
- valid는 그 페이지 내에 valid한 페이지가 있는지
- 없으면 그냥 메모리에 안올린다.
- 장점은 메모리 관리 자체가 유리하고, 사용된 주소 공간의 크기에 비례하여 페이지 테이블 공간이 생긴다는것
- 추가 비용은 tlb미스시 주소 변환을 위해 두번의 메모리 로드가 필요하다는것
- 리눅스(x86-64)에서는 **4단계 페이지 테이블(PML4, PDPT, PD, PT)**을 사용하여 **필요한 부분만 동적 할당**한다.
- 최신 Intel CPU에서는 5-Level 페이지 테이블을 지원하여 더 넓은 주소 공간을 관리한다.
- 64bit, 4kb기준 
	- 2^64/2^12 = (64비트 / 4kb) = 2^52개의 엔트리이고,
	- 거기에 8byte를 곱하면 32(PB)
```c
VPN = (VirtualAddress & VPN_MASK) >> SHIFT;
(Success, TlbEntry) = TLB_Lookup(VPN);
if (Success == True) { // TLB 히트 (TLB에서 해당 가상 페이지 번호를 찾음)
    if (CanAccess(TlbEntry.ProtectBits) == True) { // 접근 권한 확인
        Offset = VirtualAddress & OFFSET_MASK;
        PhysAddr = (TlbEntry.PFN << SHIFT) | Offset; // 물리 주소 계산
        Register = AccessMemory(PhysAddr); // 메모리 접근
    } else {
        RaiseException(PROTECTION_FAULT); // 접근 권한이 없으면 예외 발생
    }
} else { // TLB 미스 (TLB에 해당 항목이 없음)
    PDIndex = (VPN & PD_MASK) >> PD_SHIFT; // 페이지 디렉터리에서 인덱스 추출
    PDEAddr = PDBR + (PDIndex * sizeof(PDE)); // 페이지 디렉터리 엔트리 주소 계산
    PDE = AccessMemory(PDEAddr); // 페이지 디렉터리 엔트리 가져오기

    if (PDE.Valid == False) { // 페이지 디렉터리 엔트리가 유효하지 않음
        RaiseException(SEGMENTATION_FAULT); // 세그멘테이션 오류 발생
    } else {
        // 페이지 디렉터리 엔트리가 유효함 -> 페이지 테이블에서 PTE 조회
        PTIndex = (VPN & PT_MASK) >> PT_SHIFT; // 페이지 테이블 인덱스 추출
        PTEAddr = (PDE.PFN << SHIFT) + (PTIndex * sizeof(PTE)); // 페이지 테이블 엔트리 주소 계산
        PTE = AccessMemory(PTEAddr); // 페이지 테이블 엔트리 가져오기

        if (PTE.Valid == False) { // 페이지 테이블 엔트리가 유효하지 않음
            RaiseException(SEGMENTATION_FAULT);
        } else if (CanAccess(PTE.ProtectBits) == False) { // 접근 권한 확인
            RaiseException(PROTECTION_FAULT);
        } else {
            TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits); // TLB에 페이지 테이블 엔트리 추가
            RetryInstruction(); // 다시 명령어 실행
        }
    }
}
```
### 20.5 페이지 테이블을 디스크로 스와핑하기
- 말 그대로 너무 심하면 디스크로 스왑

## 21 물리 메모리 크기의 극복: 메커니즘
> 핵심 질문: 물리 메모리 이상으로 나아가기 위해서 어떻게할까
> 운영체제는 어떻게 크고 느린 장치를 사용하면서 마치 커다란 가상 주소 공간이 있는 것처럼 할 수 있을까?

- 멀티프로그래밍 시스템이 발명되면서 많은 프로세스들의 페이지를 물리 메모리에 전부 저장하는것이 불가능하게 되었다.
- 그래서 일부 페이지들을 스왑 아웃하는 기능이 필요하게 되었다.
- 멀티프로그램밍과 사용 편의성 등의 이유로 실제 물리 메모리보다 더많은 용량의 메모리가 필요하게 됭ㅆ다.
- 이게 현대 Virtual Memory의 역할이다.

### 21.1 스왑 공간
- 먼저 디스크에 페이지들을 저장할 수 있는 일정 곤간을 확보하는게 필요하다.
- 이 용도의 공간을 스왑 공간이라고 한다.
- 운영체제는 스왑 공간에 있는 모든 페이지들의 디스크 주소를 기억해야한다.
- 이러면 운영체제는 프로세스들에게 매우 큰 메모리 공간이 있는것처럼 여겨지게 할 ㅅ ㅜ있다.

### 21.2 Present Bit
> 막간을 이용한 윗 내용 정리:
> 만약 vpn을 tlb에서 찾을 수 없다면, 하드웨어는 페이지 테이블의 메모리 주소를 파악하고(페이지 테이블 베이스 레지스터 이용) vpn을 인덱스하여 원하는 페이지 테이블 항목을 추출한다. 해당 페이지 테이블 항목이 유효하고 관련 페이지가 물리 메모리에 존재한다면 하드웨어는 pte에서 pfn정보를 추출하고 그 정보를 tlb에 탑재후 명령어를 재실행한다.

- 여기서 디스크 스왑이 가능하려면, 하드웨어가 pte에서 해당 페이지가 물리 메모리에 존재하지 않는다는것을 표현해야한다. 그걸 present bit를 이용해서 하는데, 만약 해당 비트가 0이면 물리 메모리에 존재하지 않는다는 것이고, 그 상황을 page fault라고 한다.
- 페이지 폴트가 발생하면 page fault handler 가 실행된다.

### 21.3 페이지 폴트
- 페이지 폴트는 보통 운영체제에서 처리된다.
- 그러면 자연적으로 드는 의문이 있다. "디스크 어디에 있는 지 어떻게 알지?"
	- 해당 정보는 페이지 테이블에 저장된다
	- pfn과 같은 pte 비트들은 페이지 디스크 주소를 나타내는데 사용할 수 있다.
- 이후 재실행하면 tlb미스가 발생할거고 그 미스를 처리하는 과정에서 tlb값이 갱신된다.
- 물론 이 과정은 I/O전송중에 차단된 상태가 된다.

```c
VPN = (VirtualAddress & VPN_MASK) >> SHIFT;
(Success, TlbEntry) = TLB_Lookup(VPN);

if (Success == True) { // TLB 히트 (TLB에서 해당 가상 페이지 번호를 찾음)
    if (CanAccess(TlbEntry.ProtectBits) == True) { // 접근 권한 확인
        Offset = VirtualAddress & OFFSET_MASK;
        PhysAddr = (TlbEntry.PFN << SHIFT) | Offset; // 물리 주소 계산
        Register = AccessMemory(PhysAddr); // 메모리 접근
    } else {
        RaiseException(PROTECTION_FAULT); // 접근 권한이 없으면 예외 발생
    }
} else { // TLB 미스 (TLB에 해당 항목이 없음)
    PTEAddr = PTBR + (VPN * sizeof(PTE)); // 페이지 테이블 엔트리 주소 계산
    PTE = AccessMemory(PTEAddr); // 페이지 테이블 엔트리 가져오기

    if (PTE.Valid == False) { // 페이지 테이블 엔트리가 유효하지 않음
        RaiseException(SEGMENTATION_FAULT);
    } else {
        if (CanAccess(PTE.ProtectBits) == False) { // 접근 권한 확인
            RaiseException(PROTECTION_FAULT);
        } else if (PTE.Present == True) { // 페이지가 물리 메모리에 존재하는 경우
            // 하드웨어 관리 TLB를 가정
            TLB_Insert(VPN, PTE.PFN, PTE.ProtectBits); // TLB에 PTE 정보 삽입
            RetryInstruction(); // 다시 명령어 실행
        } else if (PTE.Present == False) { // 페이지가 메모리에 존재하지 않는 경우
            RaiseException(PAGE_FAULT); // 페이지 폴트 예외 발생
        }
    }
}
```
- 하드웨어에서

```c
PFN = FindFreePhysicalPage(); // 사용 가능한 물리 페이지를 찾음

if (PFN == -1) { // 사용 가능한 물리 페이지가 없음
    PFN = EvictPage(); // 페이지 교체 알고리즘 실행 (기존 페이지를 제거)
}

DiskRead(PTE.DiskAddr, PFN); // 디스크에서 페이지를 읽어 물리 메모리에 로드 (I/O 대기)

PTE.present = True; // 페이지 테이블 갱신: 페이지가 이제 메모리에 있음
PTE.PFN = PFN; // 페이지 프레임 번호(PFN) 설정

RetryInstruction(); // 원래 명령어 재시도
```
- 소프트웨어에서
### 21.4 메모리에 빈 공간이 없으면
- 페이지 교체를 통해서 물리메모리상의 페이지를 디스크로 내보낸다.
- 다음장의 정책에서 다룸!

## 물리메모리 크기의 극복 : 정책
> 위에 언급된 빈 굥간이 없으면 (디스크에서 불러올때)
> 메모리에 있는 페이지를 evict해야 하는데 이걸 교체정책이라고 한다.
> 핵심 질문 : 내보낼 페이지는 어떻게 결정하는가?


### 22.1 캐시 관리
- 일단 이 상황 자체르 캐시로 볼 수 있다.
- 시스템의 가상 메모리 페이지를 가져다 좋기 위한 캐시로 메인 메모리를 생각 할 수 있다.
- 그렇다면 이 관리 정책은 캐시 미스를 최소화하고 캐시 히트를 최대화 하는 방식으로 접근 할 수 있다.
- 그리고 미스와 히트 정보를 안다면 프로그램의 amat (평균 메모리 접근 시간)을 계산 할 수있다.
- AMAT = TimeToMemory + (PageMissPercent * TimeToDiskk)
- 현대 시스템에서는 디스크 접근 비용이 너무 크기 때문에 아주 작은 미스가 전체적인 AMAT에 큰 영향을 주게 된다.

### 22.2 최적 교체 정책
- Belady는 가장 나중에 접근될 페이지를 교체하는 것이 최적이며, 가장 적은 횟수의 미스를 발생시킨다는 것을 증명했다. 이 정책은 간단하지만 구현하기는 어려운 정책이다.

![Image](https://github.com/user-attachments/assets/f8b46418-b88a-4df4-a6f3-484b41aa95d0)
- 아주아주 심각한 맹점이 있다, 미래를 보는 경우에만 가능하다는 것이다!
- 하지만 확실한건 이건 최적의 선택이라는 것이다 즉 성능 판단의 지표가 미래를 보고 스케줄링했을때의 최적을 100점으로 두는 것이다.

### 22.3 간단한 정책: FIFO
- 간단하지만 성능이 안좋다
- 위의 최적이랑 비교했을시 coldstart 제외 57퍼센트 정도

### 22.4 또 다른 간단한 정책: 무작위 선택
- 위의 정책과 마찬가지로 구현이 편하지만 성능이 들쑥날쑥한다.

### 22.5 과거 정보의 사용: LRU
- least recently used가 선택되어 나간다.
- 빈도수(frequency), 최근성(recency)을 고려한다.
- 지역성 원칙을 이용하는 정책이다.
- 현실적으로 가장 많이 사용된다.

### 22.6 워크로드에 따른 성능 비교
- 지역성이 없는 경우 : LRU, FIFO, Random 모두 동일한 성능을 보인다.
![Image](https://github.com/user-attachments/assets/fe3fa7f8-ea1a-494b-86ab-c8dee20ef5fe)
- 80:20 워크로드 : 20퍼센트가 80퍼센트의 참조를 유발하는 상위에 몰린 워크로드, lru성능이 매우 좋다
![Image](https://github.com/user-attachments/assets/c3f56927-6d52-4245-84f6-cab1fbc20201)
- 순차 반복 워크로드 : 순차적으로 반복 참조가 일어나는 워크로드
![Image](https://github.com/user-attachments/assets/d33e381b-812b-4bc1-968d-04ffdd435ac0)
### 22.7 과거 이력 기반 알고리즘 구현
- LRU는 그래도 특정 워크로드와 평균적으로 매우 훌륭하지만, 구현이 너무 어렵다.
- 과거의 정보를 기록해야하는데 운영체제와 같은 부분에서그런걸 잘못하면 크게 성능이 감소한다.

## 23 완벽한 가상 메모리 시스템
> 핵심 질문 : 완전한 VM 시스템을 구현하는 방법

- 2개의 시스템을 상세히 살펴보면서 이러한 구현방법에 대해 알아볼 예정이다.
- 첫 번째는 1970년대 초 개발된 것으로 "현대적인" 가상 메모리 관리자의 최초 사례중 하나로 VAX/VMS운영체제에서 찾을 수 있다.
- 두 번째는 Linux 가상 메모리 시스템으로서 가장 확장성이 뛰어난 다중 코어 시스템에서 효과적으로 실행된다.

### 23.1 vax/vms 가상 메모리
- 512바이트의 페이지 크기를 가진 vms의 설계자들의 가장 큰 이슈는 페이지 크기였다. (선형 페이지였음)
- 두가지 방법을 이용해서 메모리 압박을 이겨냈다.
	- 첫째, 사용자 주소공간을 두개의 세그먼트로 나누어 프로세스마다 각 영역을 위한 페이지테이블을 가지도록
	- 둘때, 사용자 페이지 테이블들을 커널의 가상 메모리에 배치
