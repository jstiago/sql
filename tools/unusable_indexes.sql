SELECT i.INDEX_NAME, 'NONE' PART_NAME, i.TABLESPACE_NAME
              FROM   USER_INDEXES i
              WHERE  i.STATUS = 'UNUSABLE'
union all
SELECT i.INDEX_NAME, sp.SUBPARTITION_NAME, sp.TABLESPACE_NAME
              FROM   USER_IND_SUBPARTITIONS sp
                    ,USER_INDEXES i
              WHERE  i.INDEX_NAME = sp.INDEX_NAME
              AND    sp.STATUS = 'UNUSABLE'
union all
SELECT i.INDEX_NAME, sp.PARTITION_NAME, sp.TABLESPACE_NAME
              FROM   USER_IND_PARTITIONS sp
                    ,USER_INDEXES i
              WHERE  i.INDEX_NAME = sp.INDEX_NAME
              AND    sp.STATUS = 'UNUSABLE'
/
