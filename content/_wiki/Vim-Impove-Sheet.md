---
title: Vim Improve Sheet 🦅
summary: 
date: 2024-04-23 19:37:38 +0900
lastmod: 2025-04-21 12:37:30 +0900
tags: 
categories: 
description: 
showToc: true
---

## Vim Improve Sheet 🦅

> Vim Improve Sheet 라고 작성했는데, 사실 안좋은 습관을 고치기 위한 시트라고 생각하면 더 좋을 것 같다.
> 뭔가 분명히 더 나은 방법이 있을 것 같은데, 당장 알아보기 귀찮아서 그냥 넘어가는 습관을 고치기 위한 시트이다.


#### 01. Vim으로 따옴표 씌우기

- nvim-surround 플러그인을 이용한다 ("kylechui/nvim-surround")
- 별 표시된 부분이 커서의 위치를 나타낸다.

    Old text                    Command         New text
--------------------------------------------------------------------------------
    surr*ound_words             ysiw)           (surround_words)
    *make strings               ys$"            "make strings"
    [delete ar*ound me!]        ds]             delete around me!
    remove <b>HTML t*ags</b>    dst             remove HTML tags
    'change quot*es'            cs'"            "change quotes"
    <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>
    delete(functi*on calls)     dsf             function calls

#### 02. [ ] 복사 붙여넣기 남들은 어떻게 편하게 하는지 확인하기


#### 04. 주석 관련 커맨드
- `shift + v` : 블록 선택
- `:` + `norm` + `i//` : 블록 주석 처리
- `:` + `norm` + `x` : 블록 주석 해제 (앞에 글자 삭제)


> 단축키 합치는중
#### Telescope 파일 브라우저

- sf - 현재 버퍼의 경로에서 파일 브라우저 열기
- ;f - 현재 작업 디렉토리의 파일 찾기 (.gitignore 존중)
- <leader>fP - 플러그인 파일 찾기

#### 파일 브라우저 내부 단축키

- N - 새 파일 만들기
- h - 상위 디렉토리로 이동
- / - 검색 모드 시작

- <C-u> - 10개 항목 위로 이동
- <C-d> - 10개 항목 아래로 이동
- <PageUp> - 미리보기 위로 스크롤
- <PageDown> - 미리보기 아래로 스크롤

#### 창 및 탭 관련

- te - 새 탭 열기
- <tab> - 다음 탭으로 이동
- <s-tab> - 이전 탭으로 이동
- ss - 수평 분할
- sv - 수직 분할
- sh - 왼쪽 창으로 이동
- sk - 위쪽 창으로 이동
- sj - 아래쪽 창으로 이동
- sl - 오른쪽 창으로 이동

- <C-w><left> - 창 너비 줄이기
- <C-w><right> - 창 너비 늘리기
- <C-w><up> - 창 높이 늘리기
- <C-w><down> - 창 높이 줄이기

### 검색 관련 단축키

#### Telescope 검색
- ;r - 현재 작업 디렉토리에서 문자열 실시간 검색 (ripgrep, .gitignore 존중)
- ;t - 도움말 태그 검색
- ;; - 이전 텔레스코프 선택기 다시 시작
- ;e - 모든 열린 버퍼 또는 특정 버퍼의 진단 목록 표시
- ;s - Treesitter를 통한 함수명, 변수 등 검색
- ;c - 커서 아래 단어에 대한 LSP 들어오는 호출 목록
- \\ - 열린 버퍼 목록 보기

#### LSP 관련

- gd - 정의로 이동 (Telescope 사용)
- <C-j> - 다음 진단으로 이동

#### 기타 단축키

- <leader>th - 숨겨진 버퍼 닫기
- <leader>tu - 이름 없는 버퍼 닫기
- <leader>z - Zen 모드 토글
