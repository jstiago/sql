--this will only work for ADW because it has historical CPU stored on ADW_UTL.SYSTEM_RESOURCES
SELECT   asr.INST_ID,
         asr.SID,
         asr.SERIAL#,
         asr.USERNAME,
         asr.MACHINE,
         asr.OSUSER,
         asr.PROCESS,
         MAX(asr.value) - MIN(asr.VALUE)   AS CPU,
         MIN(DATETIME) START_SAMPLE_TIME,
         MAX(DATETIME) END_SAMPLE_TIME
FROM     ADW_UTL.SYSTEM_RESOURCES asr
WHERE    asr.INST_ID = &INST_ID
AND      asr.DATETIME >= (SYSDATE - 1/24) --1 hour
GROUP BY asr.INST_ID,
         asr.SID,
         asr.SERIAL#,
         asr.USERNAME,
         asr.MACHINE,
         asr.OSUSER,
         asr.PROCESS
ORDER BY CPU DESC
/
