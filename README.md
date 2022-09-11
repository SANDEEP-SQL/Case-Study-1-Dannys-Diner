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

## Case Study Questions

## [Question #1](#case-study-questions)
> What is the total amount each customer spent at the restaurant?
```sql
SELECT
	s.customer_id,
	SUM(m.price) AS total_sales
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id;
```
| customer_id  | total_sales |
|--------------|-------------|
|      A       |    76       |
|      B       |    74       |
|      C       |    36       |

## [Question #2](#case-study-questions)
> How many days has each customer visited the restaurant?
```sql
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS Customer_Visit
FROM dannys_diner.sales
GROUP BY customer_id;
```
| customer_id  | Customer_Visit |
|--------------|----------------|
|      A       |        4       |
|      B       |        6       |
|      C       |        2       |

## [Question #3](#case-study-questions)
> What was the first item(s) from the menu purchased by each customer?
```sql
SELECT
	T.customer_id,
	T.product_name
FROM
(
	SELECT
		s.customer_id,
		m.product_name,
		RANK() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn
	FROM dannys_diner.sales s
	INNER JOIN dannys_diner.menu m
		ON s.product_id = m.product_id
) AS T
WHERE T.rn = 1;
```
| customer_id  |  product_name  |
|--------------|----------------|
|      A       |     sushi      |
|      A       |     curry      |
|      B       |     curry      |
|      c       |     ramen      |
|      c       |     ramen      |

## [Question #4](#case-study-questions)
> What is the most purchased item on the menu and how many times was it purchased by all customers?
```sql
SELECT
	TOP 1
	m.product_name,
	COUNT(s.product_id) AS purchased
FROM dannys_diner.sales s
INNER JOIN dannys_diner.menu m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY purchased DESC;
```
| product_name  |  purchased   |
|-------------- |--------------|
|      ramen    |     8        |


