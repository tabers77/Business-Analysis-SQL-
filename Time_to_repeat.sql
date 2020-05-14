-- repeat customers, averare days from first to second session, min days from first to second session, maxdays from first to second session

with new_sessions as(
select
created_at
-- days from first to second session

from
website_sessions

where 
is_repeat_session = 0 

and created_at between '2014-01-01' and '2014-11-02' 

), 
repeat_sessions as(

select
created_at as date

from
website_sessions

where is_repeat_session = 1
and created_at between '2014-01-01' and '2014-11-02' 
)

select
*
from
new_sessions -- left join 