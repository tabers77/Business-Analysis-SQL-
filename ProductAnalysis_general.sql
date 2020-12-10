-- 1 

select 
year(created_at) as year,
month(created_at) as month,
count(distinct order_id) as orders,
round(sum( price_usd),0) as revenue, 
round(sum(price_usd - cogs_usd),0) as margin, 
round(avg(price_usd),2) as aov 
from 
orders
where created_at between '2012-01-01' and '2012-12-31' -- whole year
group by 1,2 
order by year asc, month asc

-- 2 Do you think adding a second product was a good thing? 

select 
year(ws.created_at),
month(ws.created_at), 
count(distinct o.order_id) as orders,
round(count(distinct o.order_id) / count(distinct ws.website_session_id) * 100,2) as cvr,
round(sum(o.price_usd) / count(distinct ws.website_session_id),2) as revenue_per_session,
count(distinct case when o.primary_product_id = '1' then o.order_id else null end) as p1_orders,
count(distinct case  when o.primary_product_id = '2' then o.order_id else null end) as p2_orders

from 
website_sessions ws left join orders o on ws.website_session_id = o.website_session_id

where ws.created_at between '2012-04-01' and '2013-04-05' 

group by 1,2



/*
-- step 1 : select session id and page view id who visited products during that specific period
with products as(
select
website_session_id ,
website_pageview_id ,
created_at,
case 
when created_at < '2013-01-06' then 'pre_product_2'
when created_at >= '2013-01-06' then 'post_product_2'
else null end as time_period

from 
website_pageviews 

where
created_at > '2012-10-06' and created_at < '2013-04-06' 
and pageview_url = '/products' 

-- step 2 : here I grab the pageview id grater than the page id from the prior table 
), next_page_sessions as (
select
products.time_period,
products.website_session_id,
min(wp.website_pageview_id) as min_pageview-- the pageview id that happend after the pageview id the null is when the person abandoned and did not see another page 

from 
products left join website_pageviews wp on products.website_session_id = wp.website_session_id and wp.website_pageview_id > products.website_pageview_id -- only for porducts that hapeneed after the products pageview, this is the next page

group by 1,2


-- step 3 : join to the pageview id again on min pageview to grab the page url
), t3 as (

select
np.time_period,
np.website_session_id,
wp.pageview_url as next_pageview_url

from next_page_sessions np
left join website_pageviews wp on np.min_pageview = wp.website_pageview_id

)
-- step 4 : do the final count
select

time_period, 
count(distinct website_session_id ) as sessions,
count(distinct case when  next_pageview_url is not null then website_session_id else null end ), 
count(distinct case when  next_pageview_url is not null then website_session_id else null end ) / count(distinct website_session_id ) as pct_next_sessions,
count(distinct case when  next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end ) to_mr_fuzzy,
count(distinct case when  next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end ) / count(distinct website_session_id ) to_mr_fuzzy_pct,
count(distinct case when  next_pageview_url = '/the-forever-love-bear' then website_session_id else null end ) to_bear, 
count(distinct case when  next_pageview_url = '/the-forever-love-bear' then website_session_id else null end ) / count(distinct website_session_id ) as to_bear_pct

from t3

group by 1
*/


/*
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
b.pageview_url,
count(distinct b.website_session_id ) as all_sessions,
count(distinct f.cart_sessions ) as cart_sessions,
count(distinct f.shipping_sessions) as shipping_sessions,
count(distinct f.billing_sessions) as billing_sessions,
count(distinct f.thank_you_sessions) as thank_you_sessions

from base b left join funnel f on b.website_session_id =  f.website_session_id 

group by 1
*/

