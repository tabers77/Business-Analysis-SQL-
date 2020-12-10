-- /billing page vs /billing_2 
-- metrics : page , sessions, orders, billing to order 
-- when did the test went live ? 
with t1 as (

select
pageview_url,
website_session_id as s_id,
max(billing_2) as billing2,
max(billing) as billing, 
max(orders) as orders

from 

(
select
wp.pageview_url,
website_pageview_id as firstp_id, 
wp.website_session_id, 
case when wp.pageview_url = '/billing-2' then 1 else 0 end as billing_2, 
case when wp.pageview_url = '/billing' then 1 else 0 end as billing,
-- case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as orders
case when o.items_purchased = 1 then 1 else 0 end as orders
from website_pageviews wp left join orders o  on wp.website_session_id = o.website_session_id
where
wp.website_pageview_id >= 53550 -- by identifying the pageviewid I know excatly how many pages to count and when the test started 
and wp.created_at < '2012-11-10' -- notice the  date you use 
and wp.pageview_url in ('/billing-2','/billing')  
) as pageviews
 group by 1,2
)

select 

pageview_url,
count(distinct s_id) as total_sessions,
-- count(distinct case when billing = 1 then s_id else null end ) as billing,
-- count(distinct case when billing2 = 1 then s_id else null end ) as billing2,
count(distinct case when orders = 1 then s_id else null end ) as orders,
count(distinct case when orders = 1 then s_id else null end ) / count(distinct s_id) *100 as cvr

from 
t1 
group by 1 
