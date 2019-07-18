--this will only work for ADW because it has historical CPU stored on ADW_UTL.SYSTEM_RESOURCES
SELECT    a.INST_ID
         ,a.SID
         ,a.SERIAL#
         ,a.USERNAME
         ,a.MACHINE
         ,a.OSUSER
         ,a.PROCESS
         ,SUM(a.CPU) CPU_USED
FROM     (SELECT    stat.INST_ID
                   ,sess.SID
                   ,sess.SERIAL#
                   ,sess.USERNAME
                   ,sess.MACHINE
                   ,sess.OSUSER
                   ,sess.PROCESS
                   ,stat.VALUE   AS CPU
          FROM      GV$SESSTAT stat
                   ,GV$SESSION sess
          WHERE     stat.STATISTIC# IN (SELECT STATISTIC# FROM V$STATNAME WHERE NAME = 'CPU used by this session')
          AND       sess.SID = stat.SID
          AND       sess.INST_ID = stat.INST_ID
          UNION ALL
          SELECT    asr.INST_ID
                   ,asr.SID
                   ,asr.SERIAL#
                   ,asr.USERNAME
                   ,asr.MACHINE
                   ,asr.OSUSER
                   ,asr.PROCESS
                   ,-MAX(asr.value) AS CPU
          FROM      ADW_UTL.SYSTEM_RESOURCES asr
          WHERE     asr.DATETIME >= (SYSDATE - 30/24/60)
          GROUP BY  asr.INST_ID
                   ,asr.SID
                   ,asr.SERIAL#
                   ,asr.USERNAME
                   ,asr.MACHINE
                   ,asr.OSUSER
                   ,asr.PROCESS) a
WHERE     a.INST_ID = &INST_ID
GROUP BY  a.INST_ID
         ,a.SID
         ,a.SERIAL#
         ,a.USERNAME
         ,a.MACHINE
         ,a.OSUSER
         ,a.PROCESS
HAVING    SUM(a.CPU) > 100 * 30 --this value is centiseconds * 60 seconds * 15 mins - at least 1 CPU for 30 seconds
ORDER BY  CPU_USED DESC
/
