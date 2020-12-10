--Time Lag -- 

#Add path tocuhes 
# improve the query 
#min , max day count for a fullvisitor id and conversion 

with t1 as (
select
fullvisitorid,
visitid, 
date

FROM `203214124.ga_sessions_*` ga
WHERE 
_TABLE_SUFFIX BETWEEN '20191201' AND  '20191231'

), 

t2  as ( #Transactions 
select
fullvisitorid,
visitid,
transaction.transactionid as t_id,
transaction.transactionrevenue as revenue

FROM `203214124.ga_sessions_*` ga,
unnest(ga.hits)h 
WHERE 
_TABLE_SUFFIX BETWEEN '20191201' AND  '20191231'

),
t3 as (
select
t1.fullvisitorid,
#count per user
date_diff(max(parse_date('%Y%m%d',date)),min(parse_date('%Y%m%d',date)),DAY) as days_diff,
count(distinct t2.t_id) as transactions,
sum(t2.revenue)/1000000 as revenue

from
t1 
#Here I join transactions 
left join t2 on t1.fullvisitorid = t2.fullvisitorid and  t1.visitid = t2.visitid

group by 1

having 
count(distinct t2.t_id) >0

order by days_diff desc 
)
select 
days_diff,
sum(transactions) as transactions, 
sum(revenue) as revenue

from
t3

group by 
1
order by days_diff asc


