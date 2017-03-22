SELECT 'ALTER ' || TRIM(REPLACE(REPLACE(SEGMENT_TYPE, 'SUBPARTITION', ''), 'PARTITION', '')) || ' ' || SEGMENT_NAME || ' MOVE ' || TRIM(REPLACE(REPLACE(SEGMENT_TYPE, 'INDEX', ''), 'TABLE', '')) || PARTITION_NAME || ' TABLESPACE &MOVE_TO;' "--CMD"
FROM (
SELECT OWNER, SEGMENT_NAME, PARTITION_NAME, SEGMENT_TYPE, SUM(BLOCKS) BLOCKS, SUM(BYTES) /1024 / 1024 "MBYTES"
FROM   DBA_SEGMENTS
WHERE  TABLESPACE_NAME = '&TABLESPACE_NAME'
GROUP BY OWNER, SEGMENT_NAME, PARTITION_NAME
, SEGMENT_TYPE
ORDER BY MBYTES desc, BLOCKS)
WHERE ROWNUM < 10
/
