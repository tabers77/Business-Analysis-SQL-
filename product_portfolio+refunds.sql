-- PRODUCT PORTFOLIO 
-- launch decmber 12 2013
-- session/order conversion rate, aov , prodcuts per order, revenue per session


-- with t1 as (
-- select 

-- case 
-- when ws.created_at < '2013-12-12'  then 'pre_launch'
-- when ws.created_at > '2013-12-12' then 'post_launch'
-- else null end as time_period,

-- count(distinct ws.website_session_id) as sessions,
-- count(distinct o.order_id) as orders,
-- count(distinct o.order_id) / count(distinct ws.website_session_id) *100 as cvr,

-- round(sum(o.price_usd) / count(distinct o.order_id),2) as aov,
-- round(sum(o.items_purchased) / count(distinct o.order_id),2) as products_per_order ,
-- round(sum(o.price_usd) / count(distinct ws.website_session_id),2) as revenue_per_session


-- from
-- website_sessions ws
-- left join orders o on ws.website_session_id = o.website_session_id  


-- where ws.created_at between '2013-11-12' and '2014-01-12'
-- group by 1 
-- )

-- select 
-- *
-- from t1 


-- Prodcut refunds
-- there is a clear decrease in refund rate 
with t1 as (
select 
year(o.created_at) as year, 
month(o.created_at) as month, 
count(distinct case when o.primary_product_id = '1' then o.order_id else null end ) as p1_orders, 
round(sum(r.refund_amount_usd) / count(distinct case when o.primary_product_id = '1' then o.order_id else null end ),2) as p1_refund_rate,
count(distinct case when o.primary_product_id = '2' then o.order_id else null end ) as p2_orders,
round(sum(r.refund_amount_usd) / count(distinct case when o.primary_product_id = '2' then o.order_id else null end ),2) as p2_refund_rate,
count(distinct case when o.primary_product_id = '3' then o.order_id else null end ) as p3_orders,
round(sum(r.refund_amount_usd) / count(distinct case when o.primary_product_id = '3' then o.order_id else null end ),2) as p3_refund_rate

from
orders o
left join order_item_refunds r on o.order_id = r.order_id

where o.created_at < '2014-10-15'

group by 1,2 

)

select 
*
from t1 










