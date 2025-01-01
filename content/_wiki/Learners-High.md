---
title: Learner's high 🏃‍➡️
summary: 러너스 하이 계획 실행 문서 
date: 2024-12-14 12:11:58 +0900
lastmod: 2024-12-14 12:11:58 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---


## Before Start
---

- [[L-Day-00]]

## Intro
---

### 모호한 과제가 아니다, 어려운 과제일뿐.

1. 먼저 토스의 일하는 방식을 소개받았다. 자료를 보고 다시 정리해야겠지만, 구체적으로 기억나는건 
  - 내가 배포한 것들의 임팩트 측정하기
  - 그러기 위해 레퍼런스와 자료, 내가 사용하는 도구를 살피기 등
  - 구체적으로 데이터와 함께 의사소통하기
  - roi를 고민하며 움직이기 등등이 있다.
2. 그 다음은 실습 과제이다.
  - 터무니 없는 과제를 받았다. 처음에는 모호해보였고, 안된다고 하는 생각이 많이 들었다.
  - "내가 지금 가지고 있는 태스크가 몇개지?", "할당받은 태스크 없이 내가 역제안 한 적이 있었나?" 와 같은 고민이 주를 이뤘다.
  - 특히 우리는 신규개발팀으로 밀려드는 태스크를 처리하기에도 벅찬 팀이기 때문에 더더욱 그랬다.
3. 그래도 같이 보니까 보이더라.
  - 내생각에 토스정도의 집단이, 경력직 개발자들을 모아놓고 이사람들이 지금 태스크가 있고 일정이 있고 어쩌고를 생각하지 못했을 리 없다.
  - 결국 토스가 일하는 방식대로 회사에서 일해보라는 것 자체가 주요한 과제이다.

> 결국 위의 두가지를 조합하면, 능동적으로 문제를 정의해야하고, 해당 문제를 해결하고, 해결했다는것을 수치와 함께 증명하며 커뮤니케이션하고,
> 해결된 나의 코드의 임팩트를 정의하고, 위와 같은 증명과 커뮤니케이션을 통해 상위직책자를 설득하고, 일을 끝내라는 것 까지가 과제이다.

위와 같이 일하면 토스가 같이 일하고 싶어하는 주요 지표를 모두 달성하게 된다(기술, 운영, 제품, 커뮤니케이션 등)
즉 명확한 과제라고 생각이 들었다.

뭐 물론 말을 흐리시기는 하셨지만, 사이드, 토이 프로젝트를 했을 때 받게되는 이른바 불이익은 아마 내가 몇가지를 증명하지 못했다는 것들이겠지
> 분명히 사이드나 토이프로젝트를 진행하는건 컴포트존이다.

### 회사, 그리고 나의 상황.

회사의 상황
1. 물론 우리는 서비스데스크를 태우고 기술협의가 끝난 프로젝트만 진행하는게 디폴트이다.
2. 그러나 종종 고도화나 리팩토링 관련 태스크가 없었던 것 은 아니다.(물론 주로 운영팀이지만)
3. 회사의 메인 프로젝트를 전면 리뉴얼한 이후라 우리가 일부 운영업무도 같이하고 있다.
4. 결론적으로 내가 정말 영민하게 배포의 임팩트와 수치를 입증한다면 분명히 이야기를 꺼내 볼 수 있다.

나의 상황
1. 지금 간단한 신규 프로젝트를 하고 있고 다음주말까지 일정이 잡혀있다.
2. 우리팀과 모기업은 공동연차로 마지막주가 연차 일정이 잡혀있다.(아마도 신규 프로젝트는 휴가자들이 복귀하는 1월 1일 즈음부터)
3. 분명히 유리한 점과 불리한 점이 같이 공존하고 있는 것 같다. 


### 무슨 문제를 인식할까?

1. 지금 하고 있는 프로젝트는 신규 프로젝트이고, 간단한 프로젝트라 내가 임팩트를 보이기는 아쉽다. 물론 내일 일하면서 더 많은 고민을 해보겠지만, 당장은 디벨롭할 여지가 많아보이지는 않는다.(아직은 모르고 접근하다가 달라질 수 있다)
2. 만성적인 성능이슈가 있는 부분 - 장바구니, 상품쪽 등 지금 명확하게 성능 이슈가 있는 부분이 있다. 아마 성능 개선이 다음 프로젝트에 있을 것 같다. 분명히 너무 맛있는 주제이지만 내가 20여일 안쪽으로 결과를 내기에는 지난번에 운영팀에서 성능개선에 실패했었다. 물론 포기는 아니고 검토 할 예정
3. 테스트코드 등 기존 프로젝트에 불편했던 부분
4. 그 외에는 서비스데스크를 조금 뒤져봐야 할 것 같다.

### 한계를 대비하자


1. 물론 안된다는 이유를 대며 배제를 하지는 않을것이다. 그러나 분명히 한계점이 있는 부분이 있다.
2. 먼저, 외부 혹은 추가 컴포넌트를 사용하는건 어려울 수 있다. aws결제가 걸린 부분은 결제와 승인이 날 지 그리고 그걸 20일 안쪽으로 해결이 가능할지 판단하기가 어렵다.(보수적으로 접근)
3. 내 태스크를 야근을 땡겨서 처리한다고 해도 남은 시간은 20일남짓 그 안에 문제를 세우고 해결해야 한다.


## Days
---
1. [[Learners-high-week-1]]
2. [[Learners-high-week-2]]
