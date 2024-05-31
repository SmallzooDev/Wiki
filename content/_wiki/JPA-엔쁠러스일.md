---
title: N + 1 문제와 해결방법 🧊️
summary: 
date: 2024-05-31 22:13:11 +0900
lastmod: 2024-05-31 22:13:11 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

 
## Post 엔티티

```java
@Entity
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String title;
    private String content;

    @OneToMany(mappedBy = "post", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Comment> comments = new ArrayList<>();
}
```


## Comment 엔티티

```java
@Entity
public class Comment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id")
    private Post post;
}
```

일반적으로 이렇게 작성하셨으면, 실제 데이터베이스에는 아래처럼 테이블이 생성됩니다.

## Post 테이블

| 컬럼 이름 | 데이터 타입 | 제약 조건                          |
|-----------|-------------|-------------------------------------|
| id        | BIGINT      | PRIMARY KEY, AUTO_INCREMENT        |
| title     | VARCHAR(255)| NOT NULL                           |
| content   | TEXT        |                                     |

## Comment 테이블

| 컬럼 이름 | 데이터 타입 | 제약 조건                          |
|-----------|-------------|-------------------------------------|
| id        | BIGINT      | PRIMARY KEY, AUTO_INCREMENT        |
| content   | TEXT        |                                    |
| post_id   | BIGINT      | FOREIGN KEY, NOT NULL              |
|           |             |                                    |

## 연관관계의 주인

연관관계 주인을 설정한다는건 외래키를 어디에 두는지 설정하는거고. mappedBy를 설정한다는건 외래키를 가지고 있는 쪽이 아니라, 반대쪽(코멘트쪽!)에 있는 엔티티가 주인이라는 것입니다.
DB관점에서 생각해보면, 

`post_id가 3번인 코멘트를 찾아라!` 와 같이 질문하는 상황이 맞겠죠? (여기를 가장 헷갈려하시는 것 같아요)

예를들어 만약 그럴일 없겠지만, Post에 Comment의 외래키를 일대다로 가지고 싶다면, 외래키의 배열을 가지고 있어야 하는 겁니다.

1번 포스트에 `[3번코멘트, 4번코멘트, 5번 코멘트]` 이런식으로요.

이러한 경우 post를 온전히 조회하려면, 3번 4번 5번 코멘트를 각각 조회해야합니다.(물론 in 쿼리로 한번에 조회할 수 있지만, 비유적인 상황이니까 ..)

결론적으로 `1번 코멘트 찾아라!`, `2번 코멘트 찾아라!`, `3번 코멘트를 찾아라!` 와 같은 어색한 상황이 생기게 됩니다.

그래서 일반적으로 연관관계의 주인, 즉 외래키를 위와 같이 정하는 것 입니다.

## N + 1 문제

그렇다면, 기본적으로 연관관계를 설정해두면 조회가 두번 발생한다는게 자연스럽게 이해가 되실겁니다.

"1번 Post를 찾아줘!", "1번 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!" 이렇게 두번의 쿼리가 발생하게 되는데요.

여기서 문제는 여러건의 Post를 조회할 때 발생합니다.

"Post 5개 찾아줘!"

"첫 번째 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!"

"두 번째 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!"

"세 번째 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!"

"네 번째 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!"

"다섯 번째 Post의 id를 외래키로 가지고 있는 Comment를 찾아줘!"

이렇게 총 (5 + 1) 번의 쿼리가 발생하게 됩니다.


```sql
SELECT c.id, c.content, c.post_id
FROM Comment c
WHERE c.post_id = 1;

SELECT c.id, c.content, c.post_id
FROM Comment c
WHERE c.post_id = 2;

...

SELECT c.id, c.content, c.post_id
FROM Comment c
WHERE c.post_id = 5;
```


## 해결방법 1. fetchType.LAZY

사실 이러한 상황은 fetchType의 기본값인 EAGER 때문에 발생합니다.

EAGER는 즉시로딩이라는 뜻으로, Post를 조회할 때 Comment도 같이 조회하겠다는 의미입니다. (정확하게는 연관된 엔티티를 같이)

반면에 LAZY는 지연로딩이라는 뜻으로, Post를 조회할 때 Comment는 조회하지 않겠다는 의미입니다.

여기서 프록시 객체가 사용되는데요, 프록시는 "우회한다"는 뜻으로, 디비에서 바로 조회하는 대신 프록시 객체를 먼저 조회하고, 실제로 사용할 때 디비에서 조회하는 방식입니다.

조금 더 직관적으로는 "가짜 객체를 만들어두고, 실제로 사용할 때 디비에서 조회한다" 라고 생각하시면 됩니다.

조금 과격한 비유이지만, 가짜 코멘트들을 만들어두고 포스트에 점찍어서 코멘트를 쓸때 실제 디비에서 조회하는 방식이라고 생각하시면 됩니다.

물론 이건 근본적인 해결책은 아니지만, 정말 필요할 경우에만 디비로 쿼리가 나가니 실제로는 N + 1번 쿼리가 발생하지 않는 정도로 퉁칠수 있는 상황이 있습니다.


## 해결방법 2. fetch join

사실 이게 근본적인 해결책인데, 여기서부터는 조금 더 정확한 쿼리를 작성해서 해결하는 방법입니다.

```java
public interface PostRepository extends JpaRepository<Post, Long> {
    @Query("SELECT p FROM Post p JOIN FETCH p.comments WHERE p.id = :postId")
    Post findPostWithComments(@Param("postId") Long postId);
}
```

쿼리를 아까처럼 풀면, (다소 의역) "Post를 조회하면서, Post테이블과  Comment을 붙여서 코멘트도 같이 조회해줘!" 라고 요청하는 쿼리입니다.

## Post 테이블

| id  | title         | content            |
|-----|---------------|--------------------|
| 1   | First Post    | This is the first post. |
| 2   | Second Post   | This is the second post. |
| 3   | Third Post    | This is the third post. |

## Comment 테이블

| id  | content         | post_id |
|-----|-----------------|---------|
| 1   | First comment   | 1       |
| 2   | Second comment  | 1       |
| 3   | Third comment   | 2       |

## 조인된 결과

| Post.id | Post.title  | Post.content           | Comment.id | Comment.content   |
|---------|-------------|------------------------|------------|-------------------|
| 1       | First Post  | This is the first post.| 1          | First comment     |
| 1       | First Post  | This is the first post.| 2          | Second comment    |
| 2       | Second Post | This is the second post.| 3         | Third comment     |

이렇게 쿼리를 작성하면, Post와 Comment를 조인해서 조회하게 되므로, N + 1 문제가 발생하지 않고 단건의 쿼리로 조회가 가능합니다.
