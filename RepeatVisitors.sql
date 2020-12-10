-- Repeat visitors: 

-- how many repeat sessions each user has 

with new_s as(
select 
user_id,
website_session_id as new_session_id
from
website_sessions 

where
is_repeat_session = 0 

), repeat_s as (

select 
user_id,
website_session_id as repeat_session_id
from
website_sessions 

where
is_repeat_session = 1

),t1 as(

select 
n.user_id,
count(distinct n.new_session_id) as new_sessions,
count(distinct r.repeat_session_id) as repeat_sessions

from new_s n 
left join repeat_s r on n.user_id = r.user_id

group by 1
order by repeat_sessions desc
)
select 
repeat_sessions,
count(distinct user_id) as total_users 

from t1

group by 1 

order by  total_users  desc

