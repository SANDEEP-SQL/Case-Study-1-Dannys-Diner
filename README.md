# Case-Study 1 Danny's Diner
The following are my solutions to the Case Study 1 Danny's Diner questions in 
[Danny Ma's Serious SQL course](https://www.datawithdanny.com/ "Data With Danny")
<br/>
<br/>
Danny has shared with you 3 key datasets for this case study :
<br/>
- `sales`
- `menu`
- `members`
<br/>
<br/>

## Case Study Questions

## [Question #1](#case-study-questions)
> What is the total amount each customer spent at the restaurant?
```sql
-- Use dannys_diner schema
select
  s.customer_id,
	SUM(m.price) as total_sales
from dannys_diner.sales s
inner join dannys_diner.menu m
	on s.product_id = m.product_id
group by s.customer_id;
```
| customer_id  | total_sales |
|--------------|-------------|
|      A       |    76       |
|      B       |    74       |
|      C       |    36       |

