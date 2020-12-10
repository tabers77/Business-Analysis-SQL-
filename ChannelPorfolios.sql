-- bsearch , weekly trend volume , august(created at) - nov 29 2012 comprare to gsearch non brand  

/*
select
YEARWEEK(created_at) as start_date, -- remember to first put the week and then the date 
MIN(DATE(created_at)) as week_start_date,
count(distinct case when utm_source= 'bsearch' then website_session_id else null end) as bsearch_sessions,
count(distinct case when utm_source= 'gsearch' then website_session_id else null end) as gsearch_sessions
-- utm_content
from
website_sessions
where 
utm_campaign = 'nonbrand'
and created_at between '2012-08-19' and '2012-11-29' 
and utm_source in ('bsearch','gsearch')
group by 
1
*/

/*
-- Comparing channels , mobile traffic percentange 
select
utm_source,
count(distinct website_session_id) as total_sessions,
-- count(distinct case when device_type= 'mobile' then website_session_id else null end) as mobile_sessions,
round(count(distinct case when device_type= 'mobile' then website_session_id else null end) / count(distinct website_session_id) *100,2) as pct_mobile_sessions,
-- count(distinct case when device_type= 'desktop' then website_session_id else null end) as desktop_sessions,
round(count(distinct case when device_type= 'desktop' then website_session_id else null end) / count(distinct website_session_id) *100,2) as pct_desktop_sessions
from
website_sessions
where 
utm_campaign = 'nonbrand'
and created_at between '2012-08-22' and '2012-11-30' 
and utm_source in ('bsearch','gsearch')
group by 
1
*/
/*
-- Cross channel bid optimization 
select
device_type,
utm_source,
count(distinct ws.website_session_id) as total_sessions,
count(distinct o.order_id) as orders,
round(count(distinct o.order_id) / count(distinct ws.website_session_id) *100,2) as cvr

from
website_sessions ws left join orders o on ws.website_session_id = o.website_session_id
where 
ws.utm_campaign = 'nonbrand'
and ws.created_at between '2012-08-22' and '2012-09-18' 
and ws.utm_source in ('bsearch','gsearch')
group by 
1,2

*/


-- b search as percent ob search 
select
-- yearweek(created_at),
min(created_at) as week_start_date,
count(distinct case when device_type = 'desktop' and utm_source = 'gsearch' then website_session_id else null end) as g_desktop_sessions,
count(distinct case when device_type = 'desktop' and utm_source = 'bsearch' then website_session_id else null end) as b_desktop_sessions,
-- pct
round(count(distinct case when device_type = 'desktop' and utm_source = 'bsearch' then website_session_id else null end) /
count(distinct case when device_type = 'desktop' and utm_source = 'gsearch' then website_session_id else null end)*100,2  ) as b_pct_g_desktop_sessions,

count(distinct case when device_type = 'mobile' and utm_source = 'gsearch' then website_session_id else null end) as g_mobile_sessions,
count(distinct case when device_type = 'mobile' and utm_source = 'bsearch' then website_session_id else null end) as b_mobile_sessions,
-- pct
round(count(distinct case when device_type = 'mobile' and utm_source = 'bsearch' then website_session_id else null end)/
count(distinct case when device_type = 'mobile' and utm_source = 'gsearch' then website_session_id else null end)*100,2 ) as b_pct_g_mobile_sessions

from
website_sessions 

where 
utm_campaign = 'nonbrand'
and created_at between '2012-11-04' and '2012-12-22' 
and utm_source in ('bsearch','gsearch')
group by 
yearweek(created_at)



