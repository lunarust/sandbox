\sf+ functionname



-- Get running queries state > 60s 
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  left(query, 50) as query,
  state, 
  usename
FROM pg_stat_activity
WHERE (now() - pg_stat_activity.query_start) > interval '60 seconds'
AND usename != 'rdsrepladmin'
AND state != 'idle'
;



-- blocked queries
select pid, 
       usename, 
       pg_blocking_pids(pid) as blocked_by, 
       query as blocked_query
from pg_stat_activity
where cardinality(pg_blocking_pids(pid)) > 0;
