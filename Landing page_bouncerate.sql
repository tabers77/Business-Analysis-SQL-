
-- STEP 1 Find the first page view 
-- STEP 2 Identifying the landing page for each session
-- STEP 3 Counting pageview for each session
-- STEP 4 Summarizing by counting total sessions and bounced sessions 

--  STEP 1 Here I only take the first pageviews:
CREATE TEMPORARY TABLE firstPageviews
select
website_session_id,
# Observe that min gives me the first page
min(website_pageview_id) as first_pageview
from
website_pageviews 
where
created_at < '2012-06-14' 
group by
1;

--  STEP 2 I join back the first table to obtain the url. Here I only extract the first pageviews with the join
CREATE TEMPORARY TABLE landing_page_sessions
select 
fp.website_session_id, 
wp.pageview_url as landing_page

from
firstPageviews fp 
left join website_pageviews wp on  wp.website_pageview_id = fp.first_pageview
where wp.pageview_url = '/home';

--  STEP 3 I join back teh table to obtain the total number of page viewed
CREATE TEMPORARY TABLE bounced_sessions_final
select 
lp.website_session_id, 
lp.landing_page as landing_page,
count(distinct wp.website_pageview_id) as count_of_page_viewed -- total number of page viewed
from
landing_page_sessions lp
left join website_pageviews wp on  wp.website_session_id = lp.website_session_id

group by 
1,2
having
count(distinct wp.website_pageview_id) = 1;

select

lp.website_session_id  as website_session,
bs.website_session_id as bounced_session_id
from landing_page_sessions lp
left join  bounced_sessions_final bs
on lp.website_session_id = bs.website_session_id 
