USE mavenfuzzyfactory;
-- 1  I join sessions and pageviews to obtain the sesison id and the min session id 
-- 2 I join the table back to obtain the landing page URL and the created at 
-- 3 From this final table I group by week , show the first date of the week, count sessions and pageviews

with first_test_pageviews as (
select
wp.website_session_id,
min(wp.website_pageview_id) as first_pageview_id, 
count(wp.website_pageview_id) as count_pageviews -- total number of pageviews 

from website_sessions ws 
left join website_pageviews wp on ws.website_session_id = wp.website_session_id  

where
ws.created_at between '2012-06-01' and  '2012-08-31'
and ws.utm_source ='gsearch'
and ws.utm_campaign = 'nonbrand'

group by wp.website_session_id -- Observe that the group by is important

), 

sessions_lander as(
select
fp.website_session_id,
fp.first_pageview_id,
fp.count_pageviews,
wp.pageview_url as landing_page, -- Here I am obtaining the url only with first pageview
wp.created_at 

from  first_test_pageviews fp 
left join website_pageviews wp  on fp.first_pageview_id = wp.website_pageview_id

)
-- Final selection

select
-- YEARWEEK(created_at) as week_count,
min(created_at) as min_week,
-- count(distinct website_session_id) as total_sessions,
-- count(distinct case when count_pageviews = 1 then website_session_id else null end) as bounced_sessions,
count(distinct case when count_pageviews = 1 then website_session_id else null end)
/ count(distinct website_session_id) *100 as bounce_rate,
count(distinct case when landing_page = '/home' then website_session_id else null end) as home_sessions,
count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_sessions

from sessions_lander 

group by 
YEARWEEK(created_at) 




