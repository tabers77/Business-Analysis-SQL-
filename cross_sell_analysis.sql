USE mavenfuzzyfactory;
-- ex 1
/*
select 
o.primary_product_id, 

count( distinct o.order_id ) as orders , 
count(distinct case when oi.product_id = '1' then o.order_id else null end ) as cross_sell_product1,
count(distinct case when oi.product_id = '2' then o.order_id else null end ) as cross_sell_product2,
count(distinct case when oi.product_id = '3' then o.order_id else null end ) as cross_sell_product3,
count(distinct case when oi.product_id = '4' then o.order_id else null end ) as cross_sell_product4

from 
orders o left join order_items oi on o.order_id = oi.order_id
and oi.is_primary_item = 0 -- cross sell only 

group by 
1
*/


-- CROSS SELL ANALYSIS: 

-- STEP 1 select cart sessions 
-- STEP 2 create a second table to join pageviews greater than the first table pageview 
-- sep 25 2013 , month before and after 

-- T1 
with cart_sessions  as (
select 
-- pre and post
case
when created_at between '2013-08-25' and '2013-09-25' then 'pre_cross_sell'
when created_at between '2013-09-25' and '2013-10-25' then 'post_cross_sell'
else null end as time_period,

website_session_id as cart_session_id,

website_pageview_id

from 
website_pageviews 
where 
pageview_url ='/cart'

), 
-- T2
cart_sessions_seeing_another_page as (

select 
time_period,
cart_session_id,
min(wp.website_pageview_id) as p_id_after_cart

from 
cart_sessions cs left join website_pageviews wp on wp.website_session_id = cs.cart_session_id and  wp.website_pageview_id > cs.website_pageview_id 

group by 1,2

having min(wp.website_pageview_id) is not null -- observe that this part is important to eliminate the nulls 
),
-- T3
pre_post_sessions_orders as (
select 
cs.time_period,
cs.cart_session_id,
o.order_id, 
o.items_purchased, 
o.price_usd

from 
cart_sessions cs inner join orders o on cs.cart_session_id  =  o.website_session_id -- observe that I inner join to remove all the session with no cart placements 

),final as (
-- Final
select 
cs.time_period,
cs.cart_session_id,
case when co.cart_session_id is not null then 1 else 0 end as clicked_to_another_page, 
case when po.order_id is not null then 1 else 0 end as placed_order, 
po.items_purchased,
po.price_usd

from 
cart_sessions cs 
left join  cart_sessions_seeing_another_page co on cs.cart_session_id = co.cart_session_id 
left join  pre_post_sessions_orders po on cs.cart_session_id = po.cart_session_id 

where cs.time_period is not null
)
select 

time_period,
count(distinct cart_session_id) as cart_sessions,
sum(clicked_to_another_page),
sum(clicked_to_another_page) / count(distinct cart_session_id) as cart_ctr,
sum(items_purchased) / sum(placed_order) products_per_order ,
sum(price_usd) /sum(placed_order) aov,
round(sum(price_usd),0) /sum(items_purchased)  revenue_per_order,
sum(price_usd) / count(distinct cart_session_id) revenue_per_cart_session 

from final

group by 1
