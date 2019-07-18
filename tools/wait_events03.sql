SELECT
   inst_id,
   event                         "Event Name",
   total_waits                   "Total Waits",
   time_waited / 100             "Wait Time(s)",
   total_timeouts                "Total Timeouts",
   average_wait    /100          "Average Waits(s)"
FROM 
   (select se.*
    from
       gv$system_event se
    where
       se.event not in (
        'dispatcher timer',
        'lock element cleanup',
        'Null event',
        'parallel query dequeue wait',
        'parallel query idle wait - Slaves',
        'pipe get',
        'PL/SQL lock timer',
        'pmon timer',
        'rdbms ipc message',
        'slave wait',
        'smon timer',
        'SQL*Net break/reset to client',
        'SQL*Net message from client',
        'SQL*Net message to client',
        'SQL*Net more data to client',
        'virtual circuit status',
        'WMON goes to sleep',
'rdbms ipc message','smon timer','pmon timer', 
 'SQL*Net message from client','lock manager wait for remote message', 
 'ges remote message', 'gcs remote message',
'gcs for action', 'client message', 
 'pipe get', 'null event', 'PX Idle Wait',
'single-task message', 
 'PX Deq: Execution Msg', 'KXFQ: kxfqdeq - normal deqeue', 
 'listen endpoint status','slave wait','wakeup time manager'
       )
    AND se.event not like 'DFS%'
    AND se.event not like '%done%'
    AND se.event not like '%Idle%'
    AND se.event not like 'KXFX%'
    ORDER by total_waits desc
   )
where rownum <= 10
;
