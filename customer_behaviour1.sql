drop database customer_behaviour;
create database customer_behaviour;
use customer_behaviour;
create table brands
(
 brand_id int ,
brand_name varchar(50),
primary key(brand_id)
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/brands.csv"
into table brands 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table categories
(
category_id int,
category_name varchar(50),
primary key (category_id)
 );
 
 load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/categories.csv"
into table categories 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

 create table customer
 ( customer_id int primary key ,
 first_name varchar(50),
 last_name varchar(50),
 email varchar(100),
 city varchar(50),
 state varchar(20)
 );
 
 load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers.csv"
into table customer 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table products(
 product_id int,
 product_name varchar(255),
 brand_id int,
 category_id int,
 model_year year,
 list_price int,
 primary key(product_id),
 foreign key(brand_id) references brands(brand_id),
 foreign key(category_id) references categories(category_id)
 );
 
 load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/product.csv"
into table products 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table stocks(
 store_id int,
 product_id int,
 quantity int,
 foreign key(product_id) references products(product_id)
 );
 
 load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stocks.csv"
into table stocks 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table orders(
 order_id int ,
 customer_id int,
 store_id int  ,
 primary key(order_id),
 foreign key(customer_id) references customer(customer_id)
 );
 
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_n.csv"
into table orders 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table order_item(
 order_id int ,
 item_id int,
 product_id int,
 quantity int,
 list_price int,
 discount float,
 primary key (order_id,item_id),
 foreign key (order_id) references orders(order_id),
 foreign key (product_id) references products(product_id)
 );
 
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_items.csv"
into table order_item 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table store(
store_id int primary key,
store_name varchar(50),
email varchar(100),
city varchar(50),
state varchar(50)
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/store.csv"
into table store 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

SET sql_mode = (SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- Customer Profile & Segmentation

-- Customer behaviour

-- Top 5 cutomers with highest order price
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as price
from customer as c join orders as o on c.customer_id=o.customer_id
join order_item as ot on ot.order_id=o.order_id
join products as p on p.product_id=ot.product_id
group by customer_name 
order by price desc limit 5; 

-- average money spend by each customer
select concat(c.first_name,' ' ,c.last_name) as customer_name,
avg(ot.quantity*ot.list_price) as avg_spending_of_Buyer
from customer as c join orders as o on c.customer_id=o.customer_id
join order_item as ot on ot.order_id=o.order_id
join products as p on p.product_id=ot.product_id
group by customer_name 
order by avg_spending_of_Buyer desc;

-- Number Of Items Order Per customer
select concat(c.first_name,' ' ,c.last_name) as customer_name,
count(ot.order_id) as count_of_order
from customer as c join orders as o on c.customer_id=o.customer_id
join order_item as ot on ot.order_id=o.order_id
join products as p on p.product_id=ot.product_id
group by customer_name 
order by count_of_order desc;

-- customers single vs Repeat buyers 
select concat(c.first_name,' ' ,c.last_name) as customer_name,
count(o.customer_id) as order_count,
case when count(o.customer_id)>1 then 'Repeat_Order'
when count(o.customer_id)=1 then 'Single_Buyer'
else 'NO_Purchase'
end as Buyer_Type 
from customer c join orders o on c.customer_id=o.customer_id
group by customer_name;

-- spending and purchase behaviour

-- Customers Purchasinge High Value Product
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as spending_by_person
from customer as c join orders as o on c.customer_id=o.customer_id
join order_item as ot on ot.order_id=o.order_id
join products as p on p.product_id=ot.product_id
group by customer_name 
having spending_by_person>1000 ;

-- Totall purchase,No of orders & AVG purchase of each customer 
select concat(c.first_name,' ',c.last_name) as customer_name, 
sum(ot.quantity*ot.list_price*(1-ot.discount)) as totall_order_price,
count(ot.order_id) as order_count,
avg(ot.quantity*ot.list_price*(1-ot.discount)) as avg_order_price
from customer c join orders o on c.customer_id=o.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name 
order by avg_order_price desc; 

-- Customers Buying multiple items per order
select concat(c.first_name,' ' ,c.last_name) as customer_name,
count(ot.product_id) as count_of_items_per_customer 
from customer c join orders o on o.customer_id=c.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name 
having count(ot.product_id)>1 
order by count_of_items_per_customer desc;
 
-- Product Purchase

-- Products Purchased By Each Customer
select concat(c.first_name,' ' ,c.last_name) as customer_name,
p.product_name from customer c 
join orders o on c.customer_id=o.customer_id
join order_item ot on o.order_id=ot.order_id
join products p on p.product_id=ot.product_id; 

-- Top 5 most sold products
with product_sales as (
  select p.product_name,count(ot.product_id) as totall_sales
  from orders o join order_item ot on o.order_id=ot.order_id
  join products p on p.product_id=ot.product_id
  group by p.product_name),
ranked_products as(
select product_name,
totall_sales,
rank() over(
order by totall_sales desc
) as product_rank
from product_sales)
select * from ranked_products
where product_rank<=5 
order by product_rank asc;

/* Product demand according to the number of times product ordered 
dividing into three categories 
as Low Demand,Average Demand & High Demand */
select p.product_name,
count(ot.product_id) as no_of_times_ordered,
case when count(ot.product_id)>=0 and count(ot.product_id)<40 then 'Low Demand'
when count(ot.product_id)>=40 and count(ot.product_id)<100 then 'Average Demand'
else 'High Demand'
end as product_demand
from customer c join orders o on c.customer_id = o.customer_id
join order_item ot on o.order_id=ot.order_id
join products p on p.product_id=ot.product_id
group by p.product_id; 

-- Brand Analysis

-- Popular products for each brand with rank 
select b.brand_name,p.product_name,
sum(ot.quantity) as quantity_sold,
rank() over (
partition by b.brand_name order by sum(ot.quantity) desc
) as Product_Rank
from orders o join order_item ot on o.order_id= ot.order_id
join products p on p.product_id=ot.product_id
join brands b on p.brand_id=b.brand_id 
group by b.brand_name,p.product_name;

-- Ranking Brands based on the sales
select b.brand_name,
sum(ot.quantity*ot.list_price*(1-ot.discount))as sales_by_brand,
dense_rank() over(
order by sum(ot.quantity*ot.list_price*(1-ot.discount)) desc
) as brand_rank
from order_item ot join products p on ot.product_id=p.product_id
join brands b on p.brand_id=b.brand_id
group by b.brand_id;
-- From above table we can say Trek is the best selling brand

-- Ranking Categories based on the sales 
select co.category_name,
sum(ot.quantity*ot.list_price*(1-ot.discount))as sales_by_category,
 dense_rank() over(
order by sum(ot.quantity*ot.list_price*(1-ot.discount)) desc
) as category_rank
from order_item ot join products p on ot.product_id=p.product_id
join categories co on co.category_id=p.category_id
group by co.category_name;
-- from table we can see that Mountain Bikes are the best selling category


-- Location based

-- Ranking Top 3 Customers of each state by Totall Purchase
with ranked_customer as(
select c.state,concat(c.first_name,' ',c.last_name) as customer_name,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as totall_purchase,
rank() over(
partition by c.state 
order by sum(ot.quantity*ot.list_price*(1-ot.discount)) desc
) as purchase_rank
from customer c join orders o on c.customer_id = o.customer_id
join order_item ot on o.order_id=ot.order_id
group by c.state ,customer_name)
select *  from ranked_customer
where purchase_rank<=3;

-- Revenue per state
select c.state,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as Revenue,
dense_rank() over(
order by sum(ot.quantity*ot.list_price*(1-ot.discount)) desc
) as state_rank
from customer c join orders o on c.customer_id=o.customer_id
join order_item ot on o.order_id=ot.order_id 
group by c.state
order by Revenue desc; 
-- From table NY is the state with highest Revenue

-- Discount Behaviour

-- Discount Avail Per Customer
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price) as Totall_purchase,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as price_after_discount,
sum(ot.quantity*ot.list_price*ot.discount) as discount_per_customer
from customer c join orders o on o.customer_id=c.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name
order by discount_per_customer desc;

-- Discount Avail Per  High Spending Customer
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price) as Totall_purchase,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as price_after_discount,
sum(ot.quantity*ot.list_price*ot.discount) as discount_per_customer
from customer c join orders o on o.customer_id=c.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name 
having Totall_purchase>5000
order by discount_per_customer desc;

-- Customer Ranking

-- Ranking The customers based on the total money they spent
with total_purchase as (
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as total_spend
from customer c join orders o on c.customer_id=o.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name
),
ranked_customer as (
select customer_name,
total_spend,
dense_rank() over(
order by total_spend desc)
as customer_rank
from total_purchase)
select * from ranked_customer
order by customer_rank asc; 

 -- Grouping customers according to their spending behaviour as High,Medium & Low
select concat(c.first_name,' ' ,c.last_name) as customer_name,
sum(ot.quantity*ot.list_price*(1-ot.discount)) as total_spent,
case when sum(ot.quantity*ot.list_price*(1-ot.discount))>0 
and sum(ot.quantity*ot.list_price*(1-ot.discount))<=2000 
then 'Low Spending'
when sum(ot.quantity*ot.list_price*(1-ot.discount))>2000 
and sum(ot.quantity*ot.list_price*(1-ot.discount))<5000
then 'Medium spending'
else 'High Spending'
end as spending_behaviour
from customer c join orders o on c.customer_id=o.customer_id
join order_item ot on o.order_id=ot.order_id
group by customer_name;
show databases;