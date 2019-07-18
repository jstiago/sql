SELECT *
FROM   (SELECT a.INST_ID
              ,a.SQL_ID
              ,SUBSTR(a.SQL_TEXT,1,50)                                   "SQL_TEXT"
              ,TRUNC(a.DISK_READS/DECODE(a.EXECUTIONS,0,1,a.EXECUTIONS)) "READS_PER_EXECUTION"
              ,a.CPU_TIME
              ,a.ELAPSED_TIME
              ,ROUND(a.CPU_TIME/DECODE(a.ELAPSED_TIME, 0, 1, a.ELAPSED_TIME), 2)                       "CPU_PER_SEC"
              ,a.BUFFER_GETS
              ,a.DISK_READS
              ,a.EXECUTIONS
              ,a.SORTS
              ,a.ADDRESS
        FROM   GV$SQLAREA a
        ORDER BY READS_PER_EXECUTION DESC)
WHERE  ROWNUM <= 10
/

