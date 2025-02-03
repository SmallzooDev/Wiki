---
title: untitle
summary: 
date: 2025-02-03 17:53:08 +0900
lastmod: 2025-02-03 18:42:24 +0900
tags: 
categories: 
description: 
showToc: true
tocOpen: true
---

## Leetcode

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
