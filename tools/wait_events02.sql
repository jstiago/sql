select inst_id, event, state, count(*) from gv$session_wait group by inst_id, event, state order by 3 desc;