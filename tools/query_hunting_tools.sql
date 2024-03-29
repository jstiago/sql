SELECT INSTANCE_NUMBER, SESSION_ID, SESSION_SERIAL#, SQL_ID, SQL_PLAN_HASH_VALUE, USER_ID, MODULE
      ,COUNT(1) record_count, COUNT(DISTINCT SESSION_ID) session_count, MIN(SAMPLE_TIME) start_time, MAX(SAMPLE_TIME) end_time
      ,MAX(SAMPLE_TIME)  - MIN(SAMPLE_TIME) hours_executed
FROM   DBA_HIST_ACTIVE_SESS_HISTORY   
WHERE  SAMPLE_TIME BETWEEN TO_TIMESTAMP(:START_TIME, 'DD-MON-YYYY hh24:mi') AND TO_TIMESTAMP(:END_TIME, 'DD-MON-YYYY hh24:mi')
AND MODULE = :MODULE
GROUP BY INSTANCE_NUMBER, SESSION_ID, SESSION_SERIAL#, SQL_ID, SQL_PLAN_HASH_VALUE, USER_ID, MODULE
ORDER BY START_TIME