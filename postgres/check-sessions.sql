select pid,
       usename,
       application_name,
       client_addr,
       query_start,
       state_change,
       age(now(), query_start) how_long,
       wait_event_type,
       wait_event,
       state,
       substr(query, 1, 30) query
from   pg_stat_activity
where  state <> 'idle'
order by state_change desc;