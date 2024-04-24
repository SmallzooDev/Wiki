---
title: Vim Improve Sheet 🦅
summary: 
date: 2024-04-23 19:37:38 +0900
lastmod: 2024-04-23 19:37:38 +0900
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


