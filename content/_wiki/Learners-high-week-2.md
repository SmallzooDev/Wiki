---
title: 러너스 하이 2~3주차 회고
summary: 
date: 2024-12-25 23:34:00 +0900
lastmod: 2025-01-19 16:29:06 +0900
tags: 
categories: 
description: 
showToc: false
tocOpen: false
---
## Week 2,3 Intro
---

커뮤니티 관련 프론트엔드 백엔드 작업을 마치고, qa가 완료되었다.
qa기간중이기는 하지만 일정상 여유가 생긴 덕에 다음 작업을 준비할 시간이 생겼었다.
다음 이슈는 소셜로그인 관련 오류를 해결하는 운영이슈였는데, 해당 이슈를 요약하자면

1. 사용자의 소셜 로그인이 실패하는 이슈
2. 특정 환경에서만 재현이 가능함 (운영 + 특정한 조건)
3. 그 외에 환경에서는 정상적으로 동작하고 있음

와 같은 특징을 가지고 있었다.
먼저 고객 센터를 통해서 인입이 된 이슈였는데, 2번의 특정 재현 조건을 알기가 어려워서 지난 번 인입때, 운영 로그를 뒤적이다가 이슈를 해결하지 못하고, 다른 업무를 본 이후에 처리하기로 되어 있는 이슈였다.

지난번 인입때, 해당 시간대의 gb 단위의 로그를 보다가 결국 찾거나 특정하지 못하고 덮어뒀었는데, 로그로 이슈를 해결 할 수 없었던 이유가, 여러가지 있었다.

1. 멀티스레드 환경에서 요청과 관련한 로그를 특정할 식별자가 없어서 다른 수많은 로그들과 섞인다.
2. 소셜로그인 같은 요청은 서버와 클라이언트가 하나의 목적을 가지면서 연속적으로 요청 응답 하는데 이 과정을 연속성 있게 볼 방법이 없다.
3. 그냥 로그가 잘 안되어 있었다.

> 사실 디버깅을 하는 용도의 스테이징 환경이 잘 되어있어 크게 불편함 없이 위와 같은 상태로 개발을 해왔던 것 같다.
> 실제로도 디버깅을 하는건, 로컬에서 하거나 몇가지 로그를 추가해서 스테이징에 올려두면 거의 운영과 동일한 상태로 로그를 볼 수 있기 때문에 위와 같은 불편함을 겪을 상황은 그렇게 많지 않기도 했다.
> 다만 지금처럼 실제로 운영 로그를 봐야 하는 경우에는 극도로 불편하기도 했고, 우리가 로그를 이용해서 문제를 얼마나 잘 인지하고 있을 지, 지금처럼 고객센터를 통한 인입이 되어야 이슈를 인지하는 상황이 맞는지 의문이 들었다.



## Week 2,3 Summary!
---
1. Thread local한 MDC를 이용해서 로그에서 요청을 단위로 식별 할 수 있게 했다.
2. PII가 아니면서도 사용자를 식별 할 수 있는 값으로 사용자의 연속성 있는 요청 흐름을 볼 수 있게 보완했다.
3. 그라파나에 관련한 메트릭을 추가했다.
4. 해당 이슈도 해결하고, 과정중에서 밝혀진 숨겨진 이슈도 특정해서 해결했다.


## About MDC
---
위에서 설명한 불편한 일들을 가지고 동료와 이야기를 나누던 도중 mdc에대해서 알게 되었고, 딱 필요한 부분이 mdc라는 것을 알게 되었다. 간단하게 찾아본 내용들을 요약하면, 쓰레드로컬을 사용하는 로그 전용 키밸류 저장소였다.

보통 인프라 가장 앞단에서 `x-trace-id`와 같은 uuid 난수 기반 헤더와 함께 요청을 식별하는데 쓰이는 경우가 많은 것 같다.

로그 시스템과 통합되어 있기도 하고, 쓰레드로컬에 직접 사용하는 것보다 더 편리한 몇가지 기능들을 제공한다.

다만 초기화를 잘 해줘야하는데, 초기화가 안된경우 적게는 메모리누수부터(...) 크게는 다른 요청에서 직전 요청과 관련된 값을 이용하게 될 수 있다.


## 어떠한 값을 식별값으로 두는게 좋을까?
---

### PII와 관련된 개인정보 보안 측면에서
그 다음으로 고민 한 것은 어떠한 값을 식별값으로 두는게 좋을지, 더 정확하게는 어떠한 값을 식별값으로 둬도 될지 였다.

보통은 리버스프록시쪽에 `x-trace=id`와 같은 식별값을 인프라레벨에서 붙이는 모양인데, 내가 보고싶었던 것은 연속성 있는 사용자에 대한 식별정보였다.

우리는 세션을 이용한 로그인 방식을 채택하고 있었고, 세션 클러스터링도 지원하고 있어서 처음에는 아주 쉽게 session_id를 식별값으로 두는게 낫다는 생각을 하고 있었다.

다만 다른 케이스들을 찾아보고 적용예시들을 찾아봐도 세션아이디를 직접적으로 이용하는 경우를 찾아 볼 수 없었다.

생각으로는 세션아이디가 가장 편리한 식별값인데도 왜 사용하지 않을까 생각해서 우리 프로젝트에서도 검색해봤는데, 세션아이디를 직접적으로 로깅하는 부분은 하나도 찾을 수 없었다. 

결국 관련해서 검색하다보니 세션아이디가 pii일 수 있다는 논의를 보게 되었다. [링크](https://news.ycombinator.com/item?id=37056010)

여기도 논의를 요약하면
1. 비로그인한 사용자의 세션아이디를 사용하는건 "개인정보 저장 및 처리에 대한 동의"를 구하지 않은것이고
2. 로그인한 사용자의 세션아이디를 사용하는건 개인을 식별 할 수 있는 값으로 쓰일 수 있다는 것이다.

결론적으로 세션아이디를 직접 사용하는건 최소 논쟁적일 여지가 충분하다는 생각이 들어서 조금 더 고민을 했다.


### 성능과 리소스 측면에서
물론 커스텀 헤더 하나와 uuid 생성하는 정도의 비용이 크지는 않지만, 연속성 있게 식별하기 위해서 값을 추가로 설정하는 측면에서 생각하면 분명히 생각해봐야 할 문제였고, 기존의 메인 백엔드 서버가 워낙 비대하고 성능이슈가 많은 부분이라서, 보수적으로 접근해야 머지할 수 있을 것 같았다.

실제로 관련해서 팀장님과 이야기를 나누었을 때, 운영팀에서 분명히 성능 걱정을 할 수 있을것이라는 우려를 들었다.

그래서 관점을 기존에 사용하던 값 혹은 어쩔 수 없이 쓰고 있던 값을 기준으로 찾아보게 되었다.


### 식별값 결론
위와 같은 관점으로 고민하다 보니, 이미 사용하고 있던 적합한 값을 찾게 되었다.
프론트의 첫 요청(익명 사용자의 세션이 발급된 시점과 거의 동일하게)에 생성되는 특정 난수값이 있었다.
해당 난수값의 특징은 아래와 같았다.
1. 원래 용도는 cloudfront 람다에서 사용하기 위한 키값이고 이미 사용하고 있음
2. 람다에서 캐시를 식별하기 위한 최소한의 정보 + sessionId 를 암호화한 해쉬값

그래서 프론트에서 이 해쉬부분만 잘라서 사용한다면, 이 값을 사용하는데 있어 추가적인 리소스를 거의 사용하지 않고, pii와 관련된 이슈도 없어서 매우 적합하다는 생각이 되었다.(세션아이디를 마스킹하거나 해쉬하면 사용가능하다고 한다) 

## 로그 관련 작업 시작
---

### 기존 프로젝트, 환경 검토

**메인 백엔드 서버**
1. 사용하고 있는 Hybris라는 솔루션에서, 로그 관련 설정을 래핑해서 구현체를 제공하고 있었다.
2. 그리고 실제로도 솔루션의 그 설정등을 그대로 이용하고 있다.
3. [Hybris-Log](https://help.sap.com/docs/SAP_COMMERCE/d0224eca81e249cb821f2cdf45a82ace/8c07853c866910148a00baf81ea1669e.html) 링크를 검토했을 때 래핑해서 몇가지 편의사항을 제공하기는 했지만, 특이한 건 없었다.

**프론트엔드 서버**
1. 최근 새로 프로젝트 자체를 전부 리뉴얼하면서 `fetchClient`가 잘 관리되고 있었다.
2. 백엔드 서버로 보내는 요청을 잘 한곳에서 관리하도록 되어있어 특정 헤더를 보내는건 매우 쉬웠다.

**인프라**
1. 인프라 업무를 보는 동료에게 도움을 요청해서 확인한 바로는 그라파나에 일단 기본적인 Loki설정은 되어있다고 했다.
2. 서버 설정과 연관되어 있는 이야기인데 기본적으로 파일로그는 `fluentbit`이라는 것을 설정해서, 사용하고 있었다. 쿠버네티스, eks환경에서 간단하게 사용하고 싶을때 많이 사용하는 것 같았다.
3. 반면 콘솔로그는 로키와 그라파나에서 볼 수 있도록 기본적인 설정들은 잘 되어있었다. 다만 메트릭 자체가 설정되어있거나 한건 아주 기본적인 부분 외에는 없었다.

추가적으로 fluentbit으로 관리되는 파일로그와, 콘솔로그는 기본적으로 레이아웃을 별도로 설정해서 사용하고 있었다.

```
# 약간 이런식
log4j2.logger.fluentbit.layout = %d{yyyy-MM-dd'T'HH:mm:ss.SSSZ} [%-5p] [%24F:%L] - %m%n
log4j2.logger.console.layout = [%-5p] [%24F:%L] - %m%n
```

### 작업내용, 순서 정리

1. 프론트엔드 서버가 아까 말한 요청을 식별하는 hash값을 별도의 커스텀 헤더에 추가해서 발송.
	- 모든 요청에서 해당 헤더를 보낼 수 있도록 fetch를 래핑한 client구현체에 추가
	- next.js 서버가 직접 요청을 포워드하는 특정 서버 컴포넌트들이 있어 관련한 middleware 로직 추가
2. 메인 백엔드 로그 관련 작업 (mdc, 로그보완 등)
3. grafana에 인증관련 대시보드, 메트릭 추가

## Impl and Touble Shootings
---

### 레거시 로그 버전의 레이아웃이 잘 설정 안되는 이슈

먼저, mdc 구현체를 사용하는것, 시큐리티 인증 필터의 가장 앞단에 헤더에 있는 trace-id값을 추가하는 것 등은 아주 문제 없이 잘 되었다.


```java
@Component
public class OurNewTraceIdFilter extends OncePerRequestFilter {

    private static final String TRACE_ID_HEADER = "X-Trace-Id";
    private static final String DEFAULT_TRACE_ID = "N/A";

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String traceId = Collections.list(request.getHeaderNames()).stream()
                .filter(header -> TRACE_ID_HEADER.equalsIgnoreCase(header))
                .findFirst()
                .map(request::getHeader)
                .filter(value -> !value.isEmpty())
                .orElse(DEFAULT_TRACE_ID);

        MDC.put("TraceId", traceId);

        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.remove("TraceId");
        }
    }
}
```

그리고 이걸 간단하게 아래처럼 레이아웃을 수정해서 사용하려고 했는데,
```
log4j2.logger.console.layout = [%-5p] [%X{TraceId}] [%24F:%L] - %m%n
```

레이아웃 포매팅이 잘 되지 않았다.

확인해봤을때 우리 프로젝트가 완전 레거시라.. Log4J 1.2.x 버전을 사용하고 있었고,
해당 버전에서는 포매팅등 설정하는게 제한적이었다.
(정확히는 레이아웃 설정은 가능한데 조건부 생략과 같은 것들은 잘 안됐다)

관련해서 EnhancedPatternLayout이라는 구현체를 썼을 때 조금 더 유동적인 포매팅을 레이아웃으로 추가 할 수 있기는 했지만, 조건부로 생략되어도 괄호가 남아있는등 설정이 여의치 않았다.

이것도 찾아보니까 별도의 레이아웃 구현체를 설정하는 방법이 있어서 해당 방법으로 추가했다.

```java

public class CustomPatternLayout extends EnhancedPatternLayout {
    private static final String TRACE_ID_KEY = "TraceId";
    private static final String TRACE_ID_PLACEHOLDER = "N/A";

    @Override

    public String format(LoggingEvent event) {
        String traceId = Optional.ofNullable((String) event.getMDC(TRACE_ID_KEY))
                                 .filter(id -> !id.isEmpty() && !TRACE_ID_PLACEHOLDER.equals(id))
                                 .orElse(null);

        String baseLog = super.format(event);
        return (traceId != null) 
	          ? baseLog.replaceFirst(event.getLevel()
	          .toString(), event.getLevel() + " [" + traceId + "]") 
              : baseLog;
    }

}
```

```
log4j.appender.CONSOLE = org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.layout = ourpackage.util.CustomPatternLayout
```

그러나 여기서 오버헤드에 대한 걱정이 되어 replaceFirst()를 봤더니 정규식으로 처리하길래 약간의 수정을 더했다.

```java
public class CustomPatternLayout extends EnhancedPatternLayout {
    private static final String TRACE_ID_KEY = "TraceId";
    private static final String TRACE_ID_PLACEHOLDER = "N/A";

    @Override
    public String format(LoggingEvent event) {
        String traceId = (String) event.getMDC(TRACE_ID_KEY);
        if (traceId == null || traceId.isEmpty() || TRACE_ID_PLACEHOLDER.equals(traceId)) {
            return super.format(event);
        }

        StringBuilder formattedLog = new StringBuilder(super.format(event));
        int levelIndex = formattedLog.indexOf(event.getLevel().toString());

        if (levelIndex != -1) {
            formattedLog.insert(levelIndex + event.getLevel().toString().length(), " [" + traceId + "]");

        }
        return formattedLog.toString();
    }
}
```
## 추가작업 : 로그와 메트릭은 조금 더 과감하게 추가해도 괜찮을 것 같다.
---
