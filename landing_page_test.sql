USE mavenfuzzyfactory;
-- STEP 1 final the initial pageview
-- STEP 2 find the website url with min pageviewid 
-- Using the first query we can isolate the reuslts 
-- Use with instead of temporary 

/*select
min(created_at),
min(website_session_id)
from website_pageviews 
-- where pageview_url = '/lander-1'
-- and */

with first_test_pageviews as (
select
-- wp.created_at,
wp.website_session_id,
min(wp.website_pageview_id) as first_page_id 
from website_pageviews wp
INNER JOIN
website_sessions ws on wp.website_session_id = ws.website_session_id -- To limit to the specific traffic
and ws.created_at < '2012-07-28'
and wp.website_pageview_id > 23504
and utm_source ='gsearch'
and utm_campaign = 'nonbrand'

group by wp.website_session_id -- Observe that the group by is important

), 

non_brand_landing_p_sessions as(
select
fp.website_session_id,
wp.pageview_url as landing_page -- Here I am obtaining the url only with first pageview

from  first_test_pageviews fp 
left join website_pageviews wp  on fp.first_page_id  = wp.website_pageview_id
where
wp.pageview_url in ('/home','/lander-1')

), 

bounced_sessions as (
select
lp.website_session_id,
lp.landing_page,
count(distinct wp.website_pageview_id ) as page_views

from non_brand_landing_p_sessions lp 
left join website_pageviews wp on lp.website_session_id = wp.website_session_id

group by 
lp.website_session_id,
lp.landing_page

having
count(distinct wp.website_pageview_id ) = 1
)

select 
lp.landing_page, 
count(distinct lp.website_session_id) as sessions, -- this is are the normal session id
count(bs.website_session_id) as bounced_sessions,-- this are the sessions with 1 pageviews an therfore I join
count(bs.website_session_id) / count(distinct lp.website_session_id) * 100 as bounce_rate

from non_brand_landing_p_sessions lp -- from the table I only have the lander and home
left join bounced_sessions bs on lp.website_session_id = bs.website_session_id

group by 
lp.landing_page


