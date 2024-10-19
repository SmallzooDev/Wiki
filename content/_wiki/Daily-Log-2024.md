---
title: Daily-Log 2024 (Daily 아님주의) 🙈
summary: 
date: 2024-09-24 21:29:39 +0900
lastmod: 2024-09-24 21:29:39 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: false
---

# Daily-Log 📝

---

#### 2024-09-24
- 가장 큰 프로젝트가 오픈했고, 오픈 직후의 이슈들도 정리되어 가고 있다.
- 밀렸던 포스팅들을 하나씩 올리려고 한다.
- 프로젝트 때문에 몇날 밤을 새웠는데, 몇일 쉬었다고 정신 못차리고 스터디와 사이드 프로젝트를 진행하려고 한다.
- 그 때문에 러스트 공부를 시급하게 해야한다.
- 당장 오늘 Rust In Action 복습을 시작했다.


#### 2024-09-25
- 러스트 사이드 프로젝트의 교모와 시기가 상당히 타이트 할 것 같다.
- 10월 초 긴 연휴 내에 각자 필요한 것들을 준비하기로 했다.
- 최소 서버는 러스트로 구현 할 것 같다 (actix-web)
- 러스트 문법에 대한 복습을 짧게 마치고, 프레임워크에 대한 공부와 러스트 웹소켓 관련 코드들을 찾아보려고 한다.


#### 2024-09-26
- 공부 할 때 알고 있었던 내용에 대한 더 명쾌한 정의가 나오면 쾌감이 쩐다.
- 해피해킹 키보드를 선물받았다. 나도 일본을 다녀왔는데 구매하지 못했고 선물도 딱히 준비하지 못했는데 미안했다.
- 키보드에 대한 적응은 사실 필요없었음(카라비너를 이용해서 이미 미니배열에 최적화 되도록 설정들을 사용하고 있었는데 관련해서 해피해킹 사용자들이 어떻게 하나 많이 찾아보고 있었음)


#### 2024-10-07
- 키보드의 2번 레이어의 스페이스바를 option키로 바꾸기

#### 2024-10-11
- 이펙티브 러스트가 출시됐다, 아마 이 책도 읽으며 포스팅을 작성할까 한다. 
- 이 탬플릿이 좋을 것 같다. [Kotlin-in-Action](https://velog.io/@cksgodl/Kotlin-In-Action-%EC%9D%BD%EC%9C%BC%EB%A9%B0-%EA%B8%B0%EC%96%B5%ED%95%A0%EB%A7%8C-%ED%95%9C-%EA%B2%83)
- aerospace config 에 아래 설정 추가하기
```toml
# See: https://nikitabobko.github.io/AeroSpace/commands#workspace
alt-1 = 'workspace 1'
alt-2 = 'workspace 2'
alt-3 = 'workspace 3'
alt-4 = 'workspace 4'
alt-5 = 'workspace 5'
alt-r = 'workspace T' # for Terminal
alt-t = 'workspace B' # for Browsers
alt-q = 'workspace G' # for GPT
alt-y = 'workspace C' # for Chat
alt-m = 'workspace M' # for Music
alt-n = 'workspace N' # for Notes

# See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
alt-shift-1 = 'move-node-to-workspace 1'
alt-shift-2 = 'move-node-to-workspace 2'
alt-shift-3 = 'move-node-to-workspace 3'
alt-shift-4 = 'move-node-to-workspace 4'
alt-shift-5 = 'move-node-to-workspace 5'
alt-shift-r = 'move-node-to-workspace T'
alt-shift-t = 'move-node-to-workspace B'
alt-shift-q = 'move-node-to-workspace G'
alt-shift-y = 'move-node-to-workspace C'
alt-shift-m = 'move-node-to-workspace M'
alt-shift-n = 'move-node-to-workspace N'
```
- 블로그를 조금 유지보수 했다, 좀 보기 싫었던 css를 수정했다.
- 새로운 취미? 혹은 목표로 매일 수학 1시간 공부하기를 해볼 예정이다, 그 이유는 아래와 같다.
  - 학창시절에는 수학을 그나마 좋아했지만, 어느 순간 이후로 담을 쌓고 있었고 필요 할 때 마다 필요한부분을 보는정도로 때워왔다.
  - 경제학을 공부할때 미분 조금 뭐 이런식으로..
  - 그러다가 수학이 꼭 필요한 시점이 금방 오지 않을까? 라는 생각을 해왔는데, 뭔가 진짜 와가는 것 도 같고,
  - 오늘은 특히 하스켈 관련한 포스팅을 보다가 수학이 필요하다는 생각이 들었다.(항상 뭔가를 볼 때 수학적인 내용이 나올 때 마다 가슴한켠을 찌르는데 바빠서 외면해왔다. )
  - 급한건 선형대수, 이산수학 (그리고 그걸 위한 미적분)이고, 개인적으로 빨리 보고싶은건 수리논리학이다.
  - 그래도 지금은 재활이 필요한 시점이라 마침 적절한 인프런 강의도 있기에 기초대수학으로 시작해보려고 한다.
- 취미라고 한 이유는 지금 당장 할 일이 많아 죽겠고, 공부할것도 많아 죽겠어서 당장 이게 먼저가 아닌건 분명히 아는데 막연한 불안감과 양심때문에 굳이 하는거라서 그렇다.
- 선형대수학은 학부때 c를 받았고 그만큼 지루했는데 잘 해내길 바래야겠다.

#### 2024-10-14
- 이펙티브 러스트트를 시작하려고한다.
- 이번 주 수요일까지 간단하게 초기세팅을 완료한 러스트 서버를 띄워야한다.
- 아마도 axum + mongodb + jwt관련 세팅 추가하고 띄울 것 같다.
- `.ideavimrc` 파일 을 만들고 관리해야 겠다, 점점더 dotfiles에 대한 요구가 많아져서 둘 다 같이 빨리 작업해야겠다 

#### 2024-10-17
- 러스트 axum 서버를 이용한 서버 초기 구현을 끝냈다.
- 생각보다 훨씬 오래걸렸다.
- 처음에는 axum관련 코드에 익숙하지 않았고, 이슈 해결하는게 오래걸렸다.
- 너무 복잡한 boiler_plate template을 선택해서 조금 더 해맸던 것 같다.
- 마침 layered architecture 패턴으로 된 템플릿 찾아서 그냥 해당 탬플릿으로  바꾸고 나아졌다.
- model과 model_controller를 기준으로 하고 라우팅 핸들러가 직접 참조하는식으로 하려고 했는데, 잘 안됐다 뭔가 코드가 애매하게 나온다.
  - 기본적으로 아직 상태관리가 익숙하지 않아서 그런 것 같긴 하다
  - 의존성주입 덕분에 편했던 부분을 직접 관리하려고 하니 생각보다 예쁘게 안나와서 일단 기본적으로 구현했다.
  - AppState, Axum의 State 부분을 잘 관리하는 best case코드를 실제로 좀 보고싶은데 아무래도 자료가 조금 부족하다

#### 2024-10-18
> '올바른 문제'를 '올바른 때'에 '제대로된 방법'으로 풀어 가는 사람이 결국 이깁니다
- 이번 주말의 목표로는 수학공부를 시작하는것과, dotfiles 레포 만들기가 있다 기대된다.

> 확장성은 증가한 부하에 대처하는 시스템 능력을 설명하는데 사용하는 용어지만 시스템에 부여하는 일차원적인 표식이 아님을 주의하자. "X는 확장 가능하다" 또는 "Y는 확장성이 없다"
> 같은 말은 의미가 없다. 오히려 확장성을 논한다는 것은 "시스템이 특정 방식으로 커지면 이에 대처하기 위한 선택은 무엇인가?"와 "추가 부하를 다루기 위해 계산 자원을 어떻게 투입할까?" 같은 질문을 고려한다는 의미다.
- 아주 좋은 관점이자 좋은 문구인 것 같다. (심지어 튜터링중에 써먹기도 너무 좋다)
- 가끔패턴이나 방법론책(이펙티브 시리즈, 클린코드, 클린아키텍처)나, 특정 패러다임등을 처음 공부하시는 분들이 너무 심취하셔서  "~ 패턴을 사용하지 않았으니 안좋은 코드다" 라는 식으로 생각하시는 경우가 있는데, 소개해주기 좋은 관점인 것 같다.