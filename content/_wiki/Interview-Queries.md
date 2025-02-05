---
title: Coding Interview SQL
summary: 
date: 2025-02-03 17:53:08 +0900
lastmod: 2025-02-05 20:30:28 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---
## 2024-02-03
---
### 197. Rising Temperature
[LeetcodeLink](https://leetcode.com/problems/rising-temperature/?envType=study-plan-v2&envId=top-sql-50)

처음쿼리 2000ms
```sql
select W1.id 
from Weather W1
join Weather W2
on DATEDIFF(W1.recordDate, W2.recordDate) = 1
where W1.temperature > W2.temperature;
```

인덱스 타도록 개선 800ms
```sql
select W1.id
from Weather W1
join Weather W2
on W1.recordDate = W2.recordDate + INTERVAL 1 DAY
where W1.temperature > W2.temperature;
```

> 다른 사람들의 쿼리들도 봤는데, 날짜 제한같은 편법들을 이용한거 외에는 고성능 쿼리는 없는 것 같다. 셀프조인이나 셀프조인과 다름없는 쿼리들과 비슷한 맥락


### 1661. Average Time of Process per Machine
[LeetcodeLink](https://leetcode.com/problems/average-time-of-process-per-machine/?envType=study-plan-v2&envId=top-sql-50)

```sql
select a1.machine_id, ROUND(AVG(a2.timestamp - a1.timestamp),3) as processing_time
from Activity a1
join Activity a2
on a1.process_id = a2.process_id
and a1.machine_id = a2.machine_id
and a1.timestamp < a2.timestamp
group by a1.machine_id;
```

> 서브쿼리로도 풀 수 있긴 한데, 이게 차라리 깔끔한 것 같다. 근데 왜 easy지..


### 577. Employee Bonus
[LeetcodLink](https://leetcode.com/problems/employee-bonus/description/?envType=study-plan-v2&envId=top-sql-50)

```sql
select name, bonus
from Employee
left join Bonus
on Employee.empId = Bonus.empId
where bonus < 1000 or bonus is null;
```


> 바로 다음 문제인데, 왜 이것들이 같이 묶여있는지 모르겠다. 이런건 스킵해야겠다.


## 2025-02-05
---
[LeecodeLink](https://leetcode.com/problems/students-and-examinations/submissions/1532223359/?envType=study-plan-v2&envId=top-sql-50)

```sql
select 
    s.student_id, 
    s.student_name, 
    sub.subject_name, 
    coalesce(count(e.student_id), 0) as attended_exams
from 
    students s
join 
    subjects sub on 1=1
left join 
    examinations e on s.student_id = e.student_id and sub.subject_name = e.subject_name
group by 
    s.student_id, 
    s.student_name, 
    sub.subject_name
order by 
    s.student_id, 
    sub.subject_name;
```

- students 테이블과 subjects 테이블을 on 1=1로 단순하게 조인하여 모든 학생과 모든 과목의 조합을 생성
- 생성된 학생-과목 쌍을 examinations 테이블과 left join으로 연결
- coalesce(count(e.student_id), 0)을 사용하여 참석 기록이 없는 경우 0으로 반환

> 1번을 cross join을 이용해서 가능하다고 하는데, cross join을 쓰는게 생각이 안났다.


```sql
select
m.name
from
employee e
join
employee m on e.managerId = m.id
group by
m.id, m.name
having
count(e.id) >= 5;
```
> 이건 왜 medium일까

