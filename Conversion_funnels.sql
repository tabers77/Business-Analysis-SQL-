USE mavenfuzzyfactory;
-- 1 Select all pageviews for relevant sessions 
-- 2 Indentify each relevant pageview as the specific funnel step 
-- 3 Create the sesssion level conversion funnel view 
-- 4 aggregate the data to asses the funnel 
-- I will count all sesions and all specific sessions that went through the funnel
-- 11-5-12 , g search users , from lander-1 to the funnel and click rates

with t1 as (
select
website_session_id,
MAX(mr_fuzzy_page) as mr_fuzzy_page,
MAX(product_page) as p_page, 
MAX(cart_page) as cart_page,
MAX(shipping_page) as shipping_page,
MAX(billing_page) as billing_page,
MAX(thankyou_page) as thank_you_page


from
(
select 
ws.website_session_id,
wp.pageview_url, 
wp.created_at, 
-- This step is unesessary 
case when wp.pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end  as mr_fuzzy_page,
case when wp.pageview_url = '/products' then 1 else 0 end  as product_page,
case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping_page,
case when wp.pageview_url = '/billing' then 1 else 0 end as billing_page,
case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page,
case when wp.pageview_url = '/cart' then 1 else 0 end  as cart_page

from website_sessions ws 
LEFT JOIN website_pageviews wp on ws.website_session_id = wp.website_session_id
where ws.created_at between '2012-08-05' and '2012-09-05'
and ws.utm_source = 'gsearch'
and ws.utm_campaign = 'nonbrand'
order by ws.website_session_id,wp.created_at
) as pageview_level

 group by 1
)

select

count(distinct website_session_id) as total_sessions,
count(distinct case when mr_fuzzy_page = 1 then website_session_id else null end)  as mr_fuzzy_page_sessions,
count(distinct case when  p_page = 1 then website_session_id else null end)   as product_page_step, 
count(distinct case when cart_page = 1 then website_session_id else null end)  as cart_step,
count(distinct case when shipping_page = 1 then website_session_id else null end)   as shipping_step,
count(distinct case when billing_page = 1 then website_session_id else null end) as billing_step,
count(distinct case when thank_you_page = 1 then website_session_id else null end)  as order_step


from 
t1 