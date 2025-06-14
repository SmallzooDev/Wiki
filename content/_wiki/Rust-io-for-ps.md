---
title: Rust IO for PS (From Bubblers)
summary: 백준 입출력 코드 분석
date: 2025-05-02 18:07:45 +0900
lastmod: 2025-06-14 15:20:13 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
> references : boj - https://www.acmicpc.net/user/bubbler

저분이 백준에서 cpp 스타일 io 템플릿을 구현해두셨는데, 잘 가져다 쓰고 있다. 그러다가 이부분 코드 보고 공부한 내용들을 정리해봤다.

## Intro
```rust
use io::*;  
pub fn main() {  
    let stdin = stdin().lock();  
    let stdout = stdout().lock();  
    let mut io = IO::new(stdin, stdout);  
    solve(&mut io);  
}
```
템플릿에 포함되는 메인함수, 직접 정의한 io모듈에서 IO스트럭트를 std입출력을 전달해서 만들고 실제 알고리즘 로직이 들어가는 solve 함수에 전달.


## mod IO 구성

### 1. struct IO
```rust
    pub(crate) struct IO<R: BufRead, W: Write> {
        ii: I<R>,
        oo: BufWriter<W>,
    }
    impl<R: BufRead, W: Write> IO<R, W> {
        pub(crate) fn new(r: R, w: W) -> Self {
            Self {
                ii: I::new(r),
                oo: BufWriter::new(w),
            }
        }
        pub(crate) fn get<T: Fill>(&mut self, exemplar: T) -> Option<T> {
            self.ii.get(exemplar)
        }
        pub(crate) fn put<T: Print>(&mut self, t: T) -> &mut Self {
            t.print(&mut self.oo);
            self
        }
        pub(crate) fn nl(&mut self) -> &mut Self {
            self.put("\n")
        }
    }
```
- ii : Reader를 한 번 더 래핑한 스트럭트 (후술)
- oo : Writer
- 그리고 그 대상들은 `Fill`, `Print` trait를 구현해야함 (후술)
- exemplar는 타입 추론을 위한 템플릿 값
```rust
let n: usize = io.get(0usize)?;
```

### 2. struct I
```rust
    pub(crate) struct I<R: BufRead> {
        r: R,
        line: String,
        rem: &'static str,
    }
    
    impl<R: BufRead> I<R> {
        pub(crate) fn new(r: R) -> Self {
            Self {
                r,
                line: String::new(),
                rem: "",
            }
        }
        pub(crate) fn next_line(&mut self) -> Option<()> {
            self.line.clear();
            (self.r.read_line(&mut self.line).unwrap() > 0)
                .then(|| {
                    self
                        .rem = unsafe {
                        (&self.line[..] as *const str).as_ref().unwrap()
                    };
                })
        }
        pub(crate) fn get<T: Fill>(&mut self, exemplar: T) -> Option<T> {
            let mut exemplar = exemplar;
            exemplar.fill_from_input(self)?;
            Some(exemplar)
        }
    }
```
- `next_line()`
	- Fill 트레이트에서 사용
	- `line`은 버퍼 역할
	- `rem`은 현재 파싱 위치 역할
```rust
        pub(crate) fn next_line(&mut self) -> Option<()> {
            self.line.clear(); // 다음줄을 읽기위해 현제 버퍼 초기화
            (self.r.read_line(&mut self.line).unwrap() > 0) // 실제로 읽어들인 값이 있으면
                .then(|| {
                    self
                        .rem = unsafe { // .rem도 같이 초기화를 해주는데
                        (&self.line[..] as *const str).as_ref().unwrap() // raw 포인터로 변환을 해준다. 
                    };
                })
        }
```

#### 왜 raw 포인터로 변환을 했을까?
> 사실 이부분이 이해가 안가는 코드라서 해당 포스트를 작성했다.
```rust
// 여기서 rem은 포인터로서, line을 가리키며 지금 어디까지 읽었는지를 나타내줘야한다.
// 즉 로직상으로 line의 또 하나의 참조 역할이다.
struct I<R: BufRead> {
    line: String,
    rem: &'??? str,  // -> line을 가리키는 포인터, 그렇다면 러스트 입장에서는 line보다 짧은 수명을 지정해줘야함
}
```
- 그래서 아래처럼 rem을 line의 참조로 쓰기 위해서 라이프타임을 알려줘야 컴파일 해준다. 

```rust
struct I<'a, R: BufRead> {
    line: String,
    rem: &'a str,  // rem은 line보다 짧은 라이프타임과 하나의 문자열에 대한 두 참조가 필요한 상황을 해결해야한다.
}
```
- 문제는 러스트의 라이프타임을 지키며 위의 코드처럼 하려면 `'a`를 구조체 외부에서 결정해야 한다
- next_line() 함수 내에서 `&self.line`의 라이프타임은 함수 범위인데 실제 `rem`은 구조체가 살아있는 동안 유효해야 한다.

그래서 그냥 raw pointer 사용해서
```rust
self.rem = unsafe {
    (&self.line[..] as *const str).as_ref().unwrap()
};
```
1. `&self.line[..]` → `&str` (일반적인 참조)
2. `as *const str` → raw 포인터로 변환 (라이프타임 정보 제거)
3. `.as_ref().unwrap()` → 다시 참조로 변환하되 `'static` 라이프타임으로

![smart_pointer_img](https://github.com/user-attachments/assets/58205875-4889-4218-9845-f48a6fb19c16)


> 이렇게 안전한 구현을 하면 할수는 있는데, 클로드한테 물어보니 이렇게되면 매번 슬라이싱 연산과 바운드 체크 오버헤드가 발생하고 ps에서는 무시할 수 없을 정도일 것 이라고 한다.
```rust
struct I<R: BufRead> {
    r: R,
    line: String,
    pos: usize,
}

impl<R: BufRead> I<R> {
    fn remaining(&self) -> &str {
        &self.line[self.pos..]
    }
    
    fn advance(&mut self, len: usize) {
        self.pos += len;
    }
}
```
그리고 line.clear()를 앞에 두고 매번 사용하기 때문에 아직까지는 충분히 안전하고 사용용도에도 잘맞는 방식


### 3 trail Fill
그리고 아래처럼 실제로 읽어낸다.
```rust
pub(crate) trait Fill {  
    fn fill_from_input<R: BufRead>(&mut self, i: &mut I<R>) -> Option<()>;  
}  
fn ws(c: char) -> bool {  
    c <= ' '  
}
```

```rust
    impl Fill for String {
        fn fill_from_input<R: BufRead>(&mut self, i: &mut I<R>) -> Option<()> {
	        // 공백 스킵
            i.rem = i.rem.trim_start_matches(ws);
            // 비어있으면 줄바꿔서 스킵
            while i.rem.is_empty() {
                i.next_line()?;
                i.rem = i.rem.trim_start_matches(ws);
            }
            // 토큰 하나 뽑고
            let tok = i.rem.split(ws).next().unwrap();
            // 포인터 밀어주고
            i.rem = &i.rem[tok.len()..];
            *self = tok.to_string();
            Some(())
        }
    }
    impl Fill for Vec<u8> {
        fn fill_from_input<R: BufRead>(&mut self, i: &mut I<R>) -> Option<()> {
            i.rem = i.rem.trim_start_matches(ws);
            while i.rem.is_empty() {
                i.next_line()?;
                i.rem = i.rem.trim_start_matches(ws);
            }
            let tok = i.rem.split(ws).next().unwrap();
            i.rem = &i.rem[tok.len()..];
            self.extend_from_slice(tok.as_bytes());
            Some(())
        }
    }

	// iter로 처리
    impl<T: Fill> Fill for Vec<T> {
        fn fill_from_input<R: BufRead>(&mut self, i: &mut I<R>) -> Option<()> {
            for ii in self.iter_mut() {
                ii.fill_from_input(i)?;
            }
            Some(())
        }
    }
```

```rust
pub(crate) fn get<T: Fill>(&mut self, exemplar: T) -> Option<T> {  
    let mut exemplar = exemplar;  
    exemplar.fill_from_input(self)?;  
    Some(exemplar)  
}
```
