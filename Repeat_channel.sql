-- repeat customers, averare days from first to second session, min days from first to second session, maxdays from first to second session

-- STEP 1: Create a base query 

-- with t1 as(
-- select
-- utm_source,
-- utm_campaign,
-- http_referer,
-- count(distinct case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
-- count(distinct case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions

-- from
-- website_sessions

-- where 
-- created_at between '2014-01-01' and '2014-11-05' 

-- group by
-- 1,2,3
-- )

-- select
-- utm_source,
-- utm_campaign,
-- http_referer,
-- case
-- when utm_source is null and utm_campaign is null and http_referer is null then 'Direct'
-- when (http_referer like '%bsearch%' or http_referer like '%gsearch%')  and utm_source is null then 'Organic'
-- when utm_campaign = 'brand'   then 'Paid_brand'
-- when utm_campaign = 'nonbrand'   then 'Paid_non_brand'
-- when utm_source = 'socialbook'  then 'Paid_Social'
-- else 'Other' end as channels, 
-- sum(new_sessions), 
-- sum(repeat_sessions)

-- from 
-- t1

-- group by 1

-- new vs repeat conversion rates 
select
ws.is_repeat_session,
count(distinct ws.website_session_id) as sessions,
count(distinct o.order_id) as orders,
count(distinct o.order_id) / count(distinct ws.website_session_id) as cvr,
sum(o.price_usd) / count(distinct ws.website_session_id) as revenue_per_session
-- repeat vs new, sessions, cvr, revenue per session
from
website_sessions ws left join orders o on ws.website_session_id = o.website_session_id

where ws.created_at between  '2014-01-01' and '2014-11-08' 
group by 1 
