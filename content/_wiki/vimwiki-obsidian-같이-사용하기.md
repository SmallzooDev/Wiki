---
title: vimwiki obsidian 같이 사용하기
summary: 
date: 2025-01-17 19:45:31 +0900
lastmod: 2025-01-18 23:50:30 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
## 00. Why..? 😬
---
일단 vimwiki 자체는 매우 만족하면서 잘 쓰고 있다.
다만 vimwiki는 몇몇 플러그인들과 호환성이 좋지 않거나, 설정이 변경되면 신경쓰이거나, 긴 마크다운을 편집할때 성능적으로 아쉬운 점이 많다.


사실 대부분은 [[Vim이-느리다면-해볼-것들]] 와 같이 디버깅을 하면 심각한건 해결이 되는데, 긴 글이나 특정한 플러그인과는 호환성이 좋지는 않은 것 같다.


이런게 다 관리포인트라고 생각해서 고민하다가 옵시디언으로 기존 vimwiki가 관리하던 디렉토리를 열어봤는데, 너무 잘 호환이 되고 있었다.

일단 당연하게도 기존에 사용하던 frontmatter 같은 것들은 예쁘게 잘 보여지고 있었고, 우연히인지 원래 마크다운 표준인지는 모르겠지만 


빔위키에서 사용하던 internal link의 태그가 obsidian에서도 internal link로 인식되어 관리되고 있었다.


그래서 마이그레이션이라고 할 것 도 없이 바로 몇몇가지 설정을 추가하고 병용 가능하도록 작업을 했다.


## 01. vimwiki에서 해주던 일들 🤔
---
일단 기본적으로 vimwiki를 사용하면서 가장 필수적이라고 느꼈던 것들을 추려보면 아래와 같다.

1. 자동 프론트매터 삽입 (vimscript)
2. 자동으로 마지막 수정일자 업데이트 (vimscript)
3. 링크 생성과 관리
4. 홈(인덱스) 페이지 관리 및 자동 이동
5. vim 이다!

이것들이 가장 필수적이라고 느꼈고, 이게 가장 시급한 건데 이것들을 금방 대체 할 수 있는지를 찾아봤고 결과는 전부 가능하다였다.


### 1번의 프론트매터는 templater라는 옵시디언의 플러그인이 있어서 매우 간단하게 해결했다.

```
      function! NewTemplate()
        let l:current_path = expand('%:p:h')
        if l:current_path !~ expand(g:vimwiki_primary_path) && l:current_path !~ expand(g:vimwiki_secondary_path)
          return
        endif

        if line("$") > 1
          return
        endif

        " 템플릿
        let l:template = [
          \ '---',
          \ 'title: ',
          \ 'summary: ',
          \ 'date: ' . strftime('%Y-%m-%d %H:%M:%S +0900'),
          \ 'lastmod: ' . strftime('%Y-%m-%d %H:%M:%S +0900'),
          \ 'tags: ',
          \ 'categories: ',
          \ 'description: ',
          \ 'showToc: true',
          \ 'tocOpen: true',
          \ '---',
          \ '',
          \ '# '
        \ ]
        call setline(1, l:template)
        normal! G$
      endfunction

```

요런 프론트매터를 붙여줬어야 하는데, templater로 간단하게 해결했다.


### 2번은 억지로(?) 해결..
사실 이부분도 업데이트 시간을 체크해주는 플러그인이 있기는 한데, 해당 플러그인 업데이트가 엄청 오래전인데다가 마음에 들지 않는 부분도 있었다.

그래서 글 수정시점 말고 커밋하고 푸시하는 시점으로 lastmod를 수정하도록 간단한 git pre-commit hook을 만들어서 등록해뒀다.

```bash
#!/bin/bash

echo "Starting pre-commit hook..."

# 스테이징된 마크다운 파일들을 찾습니다
files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$')

# 파일 목록 출력
echo "Found files: $files"

for file in $files; do
    echo "Processing file: $file"
    
    current_time=$(date '+%Y-%m-%d %H:%M:%S +0900')
    echo "Current time: $current_time"
    
    tmp_file=$(mktemp)
    cat "$file" > "$tmp_file"
    
    awk -v time="$current_time" '
    /^lastmod:/ {print "lastmod: " time; next}
    {print}
    ' "$tmp_file" > "$file"
    
    rm "$tmp_file"
    
    git add "$file"
    echo "Updated and staged: $file"
done

echo "Pre-commit hook completed"
exit 0 

```

스크립트를 조금 더 깔끔하게 할 수 있었는데, 이게 스테이징된 파일을 추적하는게 잘 안됐고 이런저런 이슈가 있어서 임시방편으로 아래와 같이 했다. 수정 할 예정이다.



### 3번은 살짝 귀찮게 되긴 했는데, 방법을 찾아봐야 할 것 같다.

기존에는 vim 커서 아래에 대상을 두고 엔터를 치면 간단하게 연결이 되었다.
하지만 obsidian에는 당연하게도 그런 기능은 제공하지 않아서 내가 링크할 파일을 직접 선택해야 한다.
다만 뒤로가기 같은 것들과 다음 링크로 이동하는 것 자체는 기본적으로 몇가지 단축키와 함께 해결이 가능하고,
링크 생성하는 것 자체는 gui와 자체 검색기능을 제공해줘서 참고 쓸 수 있는 범주인 것 같다.


### 4번 역시 플러그인이 있다.

home이라는 플러그인을 사용하면, 언제든지 인덱스 페이지로 이동이 가능하며, home탭을 고정시켜둘 수 있어서 매우 편하게 사용이 가능하긴 하다.


### 5번은 놀랍게도 obsidian은 vim keymapping을 지원한다.

물론 퓨어 vim 수준의 아주 간단한 정도로 지원하지만, 이게 은근히 단점이 아니었던 부분이 여러가지가 있는데,
내가 실제 neovim을 사용 할 때 사용하는 커맨드들이나 매크로 등 몇몇 기능을 원래 vimwiki를 사용할 때도 잘 사용하지 않았던 것 같다. (아마도 '한글' '문서'를 편집하거나 작성 할 때 확 효용이 떨어지는 플러그인들이 많았어서 그런 것 같다. 코드와 영어는 대체 불가능하겠지만..)

그래서 기본적, 습관적으로 사용하는 커서 이동, 문서 편집 단축키들이 잘 동작하는것만으로도 상당히 감지덕지였다.


## 02. 생각하지 못했던 좋은 점들 🥸
---
1. 마크다운을 편집하는 중에도 인라인 코드블럭 하이라이팅이 됨.. (vimwiki는 안됨)
2. catppucin, nord, tokyo night등 유명한 ide 컬러스킴들이 이미 있음
3. nerdfont 지원함
4. editor 관련 설정들이 매우 상세하면서도 잘 구조화 되어있음.

## 03. 후기
---
아마도 성능과 관련한 부분에 있어서 특히, 그리고 점점 신경쓸 건덕지가 떨어진다는 점에서 obsidian을 한동안 편하게 사용 할 것 같다. 지금은 러너스하이 관련해서 진행했던 업무를 정리해야하는데, 주렁주렁 큰 블럭이 많은 문서들을 작성하게 될 것이라서 obsidian을 위주로 사용해보고 만약 사용감이 좋다면 추가적으로 옵시디언을 사용하게 될 것 같다.
