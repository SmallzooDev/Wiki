# Smallzoo Dev Wiki
---

- hugo, vimWiki를 이용한 개인 위키 프로젝트 입니다.
- PaperMod 테마를 일부 [수정해서](https://github.com/SmallzooDev/hugo-PaperMod) 사용하고 있습니다.
- neoVim과 vimWiki 플러그인을 이용하고 있습니다!
- 만약 neoVim을 어떻게 사용하는지 보고싶다면 이 [레포](https://github.com/SmallzooDev/nvimConfig)를 확인해주세요!

## Git Hooks 설정

마크다운 파일의 `lastmod` 자동 업데이트를 위한 pre-commit 훅 설정 방법:

```bash
# 1. 실행 권한 부여
chmod +x .hooks/pre-commit

# 2. Git hooks 경로를 로컬에 설정
git config --local core.hooksPath .hooks

# 3. 훅을 건너뛰고 커밋하기 (필요시)
git commit -m "some message" --no-verify
```
