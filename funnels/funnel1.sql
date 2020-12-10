-- Users who went from one page to another 

WITH p1 AS (

SELECT 
format_date('%m' , parse_date('%Y%m%d' , date)) as month ,

fullvisitorid ,
visitid,
page.pagepath as page

FROM `data-mind-679.203214124.ga_sessions_*`,
UNNEST(hits) h

WHERE
date  > '20200101'

AND( page.pagepath LIKE '%/hitta-din-resa?%' )

) ,

p2  AS(
SELECT 

fullvisitorid ,
visitid,
page.pagepath as page

FROM 
`data-mind-679.203214124.ga_sessions_*`, 
UNNEST(hits) h

WHERE
date  > '20200101'
AND( page.pagepath LIKE '%/mina-favoriter%')

) , 

transactions AS (
SELECT 

fullvisitorid ,
visitid,
page.pagepath as page ,
transaction.transactionid as t_id,


FROM 
`data-mind-679.203214124.ga_sessions_*`, 
UNNEST(hits) h

WHERE
date  > '20200101'

)

SELECT 
month, 
COUNT(DISTINCT p1.fullvisitorid) as step1 ,
COUNT(DISTINCT p2.fullvisitorid)as step2 ,
COUNT(DISTINCT p2.fullvisitorid) / COUNT(DISTINCT p1.fullvisitorid) *100 as step1_pct ,
COUNT(DISTINCT t.t_id ) as conversions , 
COUNT(DISTINCT t.t_id ) / COUNT(DISTINCT p2.fullvisitorid)* 100 as step2_pct 
FROM
p1
LEFT JOIN p2 ON p1.fullvisitorid  = p2.fullvisitorid  AND p1.visitid  = p2.visitid

LEFT JOIN transactions as t ON p2.fullvisitorid  = t.fullvisitorid AND p2.visitid  = t.visitid
GROUP BY 1
ORDER BY 1 asc

