---
title: Neovim 마이그레이션(?) 하기 
summary: 
date: 2024-04-05 17:59:28 +0900
lastmod: 2024-04-05 17:59:28 +0900
tags: 
categories: 
description: 
showToc: true
---

![Welcome To my New Neovim](https://github.com/SmallzooDev/NeovimConfig/assets/121675217/0153f5a4-323d-4ee0-b270-fb47f991f994)

## 01. 왜 마이그레이션을 하게 되었을까?
> 사실 마이그레이션을 하려고 하지는 않았고, 기존 Neovim 설정에서 마음에 안드는 부분들이 조금 있어서 그부분만 수정하려고 했다.
> 그러다 지난번 설정을 따라했었던 유튜버가 2024년 설정이라는 영상으로 기존 [Neovim 설정 가이드 영상을 리뉴얼](https://www.josean.com/posts/how-to-setup-neovim-2024)했다.
> packer나 lsp-saga와 같이 기존에 불편하던 부분들을 귀신같이 뺀 영상임을 확인하고 바로 마이그레이션을 하게 되었다.


- 마이그레이션이라고 하기는 사실 애매하고 완전 새롭게 설정을 하고, 기존 설정을 새로운 설정에 덧붙였다고 보는게 맞을 것 같다.
- 해당 설정을 다시 하면서 추가된 내용에 대한 약간의 내용정리와, 간단한 설명을 덧붙여 포스팅을 해보려고 한다.


## 02. 기존에 불편했던 것들 packer, lsp-saga
- `packer`는 아주 약간 아쉬운점이 있었다.
  1. 콘솔이 훨씬 덜 직관적이다.
  2. 상대적으로 무거운 플러그인들도 사실상 무조건 로드되어야 한다.(Lazy Loading이 안되는 것으로 알고 있다)
  3. 플러그인을 추가하거나 삭제할때마다 `:PackerSync`를 해줘야 하는데, Lazy처럼 접근성 좋은 대시보드를 제공하지는 않아서 불편했다.
  4. 사실 Mason과 비슷하게 믓찌게 생긴 `Lazy.vim` 대시보드를 사용하고 싶었다.

- `lsp-saga`는 아주 약간 많이 아쉬운점이 있었다.
  1. 업데이트나 플러그인을 추가 할 때 마다 에러가 발생했다.
  2. Neovim이 버전업되면, 혹은 아주 오래 쉬다가 새로운 lsp-saga release가 나오면, 에러에 시달려서 내려놨던 경우가 많았다.
  3. 현실적으로 lsp와 그 친구들이 neovim으로 넘어와서 애매한 프로젝트가 되어있는게 보였다.

## 03. [Josean의 2024 Neovim 설정](https://www.josean.com/posts/how-to-setup-neovim-2024)
> 기본적으로 위의 블로그와 유튜브 영상을 참고하면 누구나 쉽게 설정을 할 수 있다.
> 유튜브와 포스팅의 코드들을 보면서 설정을 하면 거의 영상의 러닝타임 내로 설정을 마칠 수 있다.

- 다만 포스팅만 보거나 해당 소스코드를 그냥 pull 받는 것 보다는 영상을 시청하면서 따라하는것을 추천한다.

- 플러그인을 설정하는 것에 더해서, 플러그인들의 기본적인 사용법과 꿀팁들을 설명하고 보여주기 때문이다.

- 개인적으로는 lazyvim이나 lunarvim같은 distro를 사용하는 것 보다 위의 영상을 보고 직접 설정하는게 훨씬 재미있으면서도, 실제 사용법을 알 수 있어 좋다고 생각한다.

- 무엇보다 매우 재미있다.


## 04. 위 영상을 보기 전에 알면 좋은 내용들.

1. `lua` 언어에 대한 기본적인 지식이 필요하다.
  - `lua`는 neovim의 설정파일을 작성할 때 사용되는 스크립트 언어이다.
  - `lua`의 기본적인 문법과, `neovim`에서 사용되는 `lua`의 특수한 문법들을 알면 좋다.(간단한 스크립트 언어로 lua cheet sheet 정도만 찾아봐도 위의 영상을 따라하는데는 충분하다.)
2. `neovim`의 기본적인 설정파일에 대한 이해가 필요하다.
  - 먼저 `init.lua`는 모든 설정파일의 시작점이자 끝점이다.
   
  - 기본적으로 `init.lua`에 모든 설정을 작성해도 되지만 `lua`의 특성상 모듈화를 해서 `init.lua`에 init하는 방식으로 설정한다.
  ```lua
  -- 실제 내 설정파일의 init.lua 의 예시
  require("smallzooDev.core")
  require("smallzooDev.lazy")
  ```

  - 위와 같이 `require`를 사용해서 모듈화를 하고, `init.lua`에서 `require`를 통해 모듈을 불러온다.
  - 실제 프로젝트의 구조는 아래와 같다.
  ![project structure](https://github.com/SmallzooDev/NeovimConfig/assets/121675217/ef84b6db-90ab-4279-9a92-2b313102452c)
  - packer, lazy.vim들과 같은 플러그인들로, 외부 레포에서 플러그인들을 가져오고, 모듈화를 해서 `init.lua`에서 불러오는 방식이다.

  - 즉 나의 프로젝트를 기준으로 설명하면, smallzooDev.core(모듈화 한 코어설정)와 smallzooDev.lazy(외부 플러그인 모듈화 해둔 설정)을 불러오는 방식이다.

