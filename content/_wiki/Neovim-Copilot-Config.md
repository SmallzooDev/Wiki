---
title: Neovim Copilot 관련 설정 이슈
summary:
date: 2024-03-31 14:02:03 +0900
lastmod: 2024-03-31 14:02:03 +0900
tags: ["Neovim", "Copilot", "Vimwiki"]
categories: 
public: true
parent: 
description: 
showToc: true
---

## Neovim Copilot 관련 설정

### 이슈
- Copilot을 import하고 잘 쓰고 있는데, Vimwiki와 Tab키 충돌이 발생한다.
- Tab키를 누르면, Copilot이 자동완성을 제공하는데, Vimwiki에서는 Tab키를 사용하여 들여쓰기를 한다.
- 뭔가 Vimwiki의 탭이 Copilot의 탭보다 우선순위가 높은 것 같다.
- 처음에는 Copilot의 설정을 변경하여 해결하려고 했지만 Vimwiki의 설정을 변경하는 것이 더 편할 것 같다.

### 해결
- 다행히도 Vimwiki Repository에 이슈가 올라와 있었다.
- [Vimwiki Issue](https://github.com/vimwiki/vimwiki/issues/1227)

```vim
return {
  'vimwiki/vimwiki',
  init = function()
    -- ..
  end,
  config = function()
    vim.g.vimwiki_key_mappings = {
      table_mappings = 0,
    }

    vim.keymap.set('n', '<leader>nl', '<Plug>VimwikiNextLink', { silent = true }) -- For Tab
    vim.keymap.set('n', '<leader>pl', '<Plug>VimwikiPrevLink', { silent = true }) -- For STab
  end
}
```
- 위와 같이 설정을 변경하면, Tab키를 누르면 들여쓰기가 되고, `<leader>nl`을 누르면 다음 링크로 이동한다.
- 내 생각으로는 vimwiki_key_mappings 설정만 변경해도 괜찮았어야 하는데, 저부분만 변경시 제대로 동작하지 않았다.
- 물론 Tab으로 페이지 내의 링크를 이동하는걸 잘 쓰고 있었지만, `<leader>nl`을 쓰는 것도 나쁘지 않아서 적용해봤는데 제대로 동작한다.


### 실제 코드 변경
- [nvimConfig repo commit hash - 921de26](https://github.com/SmallzooDev/nvimConfig/commit/921de2607cd289804f7168d94132debaed3d5101)

```lua
  use({
        "vimwiki/vimwiki",
        config = function()
          vim.g.vimwiki_conceallevel = 0
          vim.g.vimwiki_global_ext = 0
          vim.g.vimwiki_key_mappings = {
                table_mappings = 0,
            }
          vim.keymap.set('n', '<leader>nl', '<Plug>VimwikiNextLink', { silent = true }) -- For Tab
          vim.keymap.set('n', '<leader>pl', '<Plug>VimwikiPrevLink', { silent = true }) -- For STab
          vim.g.vimwiki_list = {
            {
              path = '/Users/joonkyu_kang/wiki/SmallzooDevWiki/content/_wiki',
              ext  = '.md',
              styntax = 'markdown',
              index = 'home'
            },
            {
              path = '/Users/joonkyu_kang/wiki/private_wiki',
              ext  = '.md',
            },
        }
      end
    })
```
- 위와 같이 변경하였다, vimwiki 설정도 plugin 파일로 빼야하는데 귀찮...
- ㅜ퍄ㅡ 
