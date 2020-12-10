-- Week day, 7 day average vs day average sessions 
with t1 as
(
select
date(created_at) as created_date, -- it is import
weekday(created_at) as weekday,
hour(created_at) as hour,
count(distinct website_session_id) as w_sessions
from
website_sessions 

where 
created_at between '2012-09-15' and '2012-11-15' 
group by 1,2,3
)
select 
hour,
round(avg(w_sessions),2),
round(avg(case when weekday = '0' then w_sessions else null end),2) as Monday, -- I cant have 2 counts on the same and therefore we should do the cout for website sessions 

round(avg(case when weekday = '1' then w_sessions else null end),2) as Tues, 
round(avg(case when weekday = '2' then w_sessions else null end),2) as Wed, 
round(avg(case when weekday = '3' then w_sessions else null end),2) as Thu, 
round(avg(case when weekday = '4' then w_sessions else null end),2) as Fri, 
round(avg(case when weekday = '5' then w_sessions else null end),2) as Sat, 
round(avg(case when weekday = '6' then w_sessions else null end),2) as Sun
from 
t1
group by 1
