---
title: untitle
summary: 
date: 2025-05-07 22:30:43 +0900
lastmod: 2025-05-07 22:33:51 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
## Solution
- [rust soulution](https://github.com/SmallzooDev/coding_interview_rust/blob/main/src/bin/l_generate_parentheses.rs)
## Memo
- 릿코드 dp문제
- 근데 왜 이게 dp지..

```rust
// LeetCode - generate-parentheses  
// https://leetcode.com/problems/generate-parentheses/description/?envType=problem-list-v2&envId=dynamic-programming  
/**  
Given n pairs of parentheses, write a function to generate all combinations of well-formed parentheses.  
Example 1:  
Input: n = 3  
Output: ["((()))","(()())","(())()","()(())","()()()"]  
Example 2:  
Input: n = 1  
Output: ["()"]  
*/  
struct Solution;  
  
impl Solution {  
    fn new() -> Self {  
        Solution  
    }  
  
    pub fn generate_parenthesis(n: i32) -> Vec<String> {  
        let mut result = Vec::new();  
        let mut current = String::new();  
  
        Self::backtrack(&mut result, &mut current, 0, 0, n as usize);  
  
        result  
    }  
  
    fn backtrack(result: &mut Vec<String>, current: &mut String, open: usize, close: usize, max: usize) {  
        if current.len() == max * 2 {  
            result.push(current.clone());  
            return;  
        }  
        if open < max {  
            current.push('(');  
            Self::backtrack(result, current, open + 1, close, max);  
            current.pop();  
        }  
        if close < open {  
            current.push(')');  
            Self::backtrack(result, current, open, close + 1, max);  
            current.pop();  
        }    }}  
  
fn main() {}
```
