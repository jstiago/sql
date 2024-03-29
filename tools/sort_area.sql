SELECT to_number(decode(SID, 65535, NULL, SID)) sid,
       operation_type OPERATION,
       trunc(EXPECTED_SIZE/1024/1024) ESIZE_MB,
       trunc(ACTUAL_MEM_USED/1024/1024) MEM_MB,
       trunc(MAX_MEM_USED/1024/1024) MAX_MEM_MB,
       NUMBER_PASSES PASS,
       trunc(TEMPSEG_SIZE/1024/1024) TSIZE_MB
  FROM V$SQL_WORKAREA_ACTIVE
 ORDER BY MEM_MB desc
/
