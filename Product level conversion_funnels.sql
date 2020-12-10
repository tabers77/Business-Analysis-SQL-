
-- Solution 1: Product level conversion funnels 
-- Remember that I am interested only on sessions which happens after the customer saw the product 

with base as
(
select
website_session_id,
website_pageview_id, -- why this one? 
pageview_url

from 
website_pageviews 

where
created_at > '2013-01-06' and created_at < '2013-04-10' 
and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')

), funnel as

(select
-- cart, shipping, billing, /thank-you-for-your-order 
website_session_id,
case when pageview_url = '/cart' then website_session_id else null end as cart_sessions,
case when pageview_url = '/shipping' then website_session_id  else null end as shipping_sessions,
case when pageview_url = '/billing-2' then website_session_id  else null end as billing_sessions,
case when pageview_url = '/thank-you-for-your-order' then website_session_id  else null end as thank_you_sessions

from 
website_pageviews 

)
select
b.pageview_url as product_seen,

count(distinct f.cart_sessions ) /  count(distinct b.website_session_id )  as product_ctr,

count(distinct f.shipping_sessions) / count(distinct f.cart_sessions )    as cart_ctr,
count(distinct f.billing_sessions) / count(distinct f.shipping_sessions)                 as shipping_ctr,
count(distinct f.thank_you_sessions) / count(distinct f.billing_sessions)        as billing_ctr,
count(distinct f.thank_you_sessions) / count(distinct b.website_session_id ) as overall_ctr
from base b left join funnel f on b.website_session_id =  f.website_session_id 

group by 1



-- Solution 2:  Product level conversion funnels 

-- 1: select relevant sessions
with 
base as
(
select
website_session_id,
website_pageview_id, -- why this one? 
pageview_url as products_seen

from 
website_pageviews 

where
created_at > '2013-01-06' and created_at < '2013-04-10' 
and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')

), 
-- 2 select page ids greater than the ids in the prior table
urls as

(select
b.website_session_id,
b.products_seen,
wp.pageview_url,

case when wp.pageview_url = '/cart' then 1 else 0 end as cart_sessions, 
case when wp.pageview_url = '/shipping' then 1 else 0 end as shipping_sessions, 
case when wp.pageview_url = '/billing-2' or '/billing' then 1 else 0 end as billing_sessions, 
case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thank_you__sessions

-- Here I will see all the pageviews that hapened after the customer saw the product 
from 
base b left join website_pageviews wp on b.website_session_id =  wp.website_session_id and  wp.website_pageview_id > b.website_pageview_id 

) , 
-- 3 select the max of the funnel steps to summarize. This is a type of group by
flagged_sessions  as (
select
website_session_id,
products_seen,
-- The max will summarize the sessions 
max(cart_sessions) as cart_final,
max(shipping_sessions) as shipping_final,
max(billing_sessions) as billing_final,
max(thank_you__sessions)as thank_you_final


from urls
group by 1,2

)
select
products_seen,
count(distinct website_session_id ) as sessions,
count(distinct case when cart_final = 1 then website_session_id else null end ) cart_sessions, 
count(distinct case when shipping_final = 1 then website_session_id else null end ) shipping_sessions,
count(distinct case when billing_final = 1 then website_session_id else null end ) billing_sessions,
count(distinct case when thank_you_final = 1 then website_session_id else null end ) thank_you_sessions

from 
flagged_sessions

group by 1



