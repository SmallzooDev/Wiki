---
title: Vim이 느린 경우 Trouble Shootings
summary: 
date: 2024-04-01 15:52:53 +0900
lastmod: 2024-04-01 15:52:53 +0900
tags: 
categories: 
public: true
parent: 
description: 
showToc: true
---


```

:profile start profile.log
:profile func *
:profile file *
" At this point do slow actions
:profile pause
:noautocmd qall!

```

출처 : https://stackoverflow.com/questions/12213597/how-to-see-which-plugins-are-making-vim-slow

