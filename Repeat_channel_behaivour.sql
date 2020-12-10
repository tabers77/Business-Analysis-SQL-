-- repeat customers, averare days from first to second session, min days from first to second session, maxdays from first to second session

-- STEP 1: Grab only the new sessions
with new_sessions as(
select
created_at as date,
user_id,
website_session_id as new_session_id
-- days from first to second session

from
website_sessions

where 
is_repeat_session = 0 

and created_at between '2014-01-01' and '2014-11-01' 

), 

-- STEP 2: Grab only the repeat sessions
repeat_sessions as(
select
created_at as date,
user_id,
website_session_id as repeat_session_id
from
website_sessions
where 
is_repeat_session = 1
and created_at between '2014-01-01' and '2014-11-01' 
),
t1 as (
select
n.user_id as new_user_id,
r.user_id as repeat_user_id,
n.new_session_id, 
n.date as first_sessions_date,
r.repeat_session_id, 
r.date as second_sessions_date

from
new_sessions n left join repeat_sessions r on n.user_id = r.user_id 

where 
r.user_id  is not null

),
t2 as(
select
repeat_user_id,
first_sessions_date,
second_sessions_date,
new_session_id,
repeat_session_id,
DATEDIFF(second_sessions_date,first_sessions_date) as dd

from t1 
group by 1,2,3,4,5

having DATEDIFF(second_sessions_date,first_sessions_date)>0

order by dd asc

)
select

avg(dd) as avg_days_to_second,
min(dd) as min_days_to_second,
max(dd) as max_days_to_second

from 
t2
