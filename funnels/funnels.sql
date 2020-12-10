with t1 as (
SELECT
fullvisitorid, 
concat(fullvisitorid,cast(visitstarttime as string)) as session_id, -- I do a count distinct ,
page.pagepath as page_path, 
device.devicecategory as deviceCat,

--FUNNEL:
#1
case 
when page.pagepath = '/' or page.pagepath = '/se' then 1 else 0 end as home_page,
#2
case 
when page.pagepath like '%/hitta-din-resa%' then 1 else 0 end as search_page,

#3
case 
when page.pagepath like '%boka-resa%' then 1 else 0 end as product_page,


visitid,
timestamp_seconds(visitstarttime) as timestamp


FROM `15332469.ga_sessions_*` ga,
UNNEST(ga.hits) h

where 
_table_suffix = '20200411'
--_table_suffix between '20200411' and '20200413'
--parse_date('%Y%m%d', date )between DATE_sub(current_date(),interval 15 day) and DATE_sub(current_date(),interval 1 day) 

), 

t2 as (
SELECT
fullvisitorid, 
visitid,
transaction.transactionid as t_id

FROM `15332469.ga_sessions_*` ga,
UNNEST(ga.hits) h

where 
_table_suffix = '20200411'
--_table_suffix between '20200411' and '20200413'

)

select 
deviceCat,
count(distinct session_id ) as total_sessions,
count(distinct case when search_page = 1 then session_id else null end  ) / count(distinct session_id ) * 100 as search_sessions_pct, 
count(distinct case when product_page = 1 then session_id else null end  ) / count(distinct session_id ) * 100 as product_sessions_pct, 


from t1 left join t2 on t1.fullvisitorid = t2.fullvisitorid and  t1.visitid = t2.visitid

group by 1
order by count(distinct session_id ) desc
