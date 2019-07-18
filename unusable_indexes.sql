SELECT i.OWNER, i.INDEX_NAME, 'NONE' PART_NAME, i.TABLESPACE_NAME
              FROM   DBA_INDEXES i
              WHERE  i.STATUS = 'UNUSABLE'
union all
SELECT i.OWNER , i.INDEX_NAME, sp.SUBPARTITION_NAME, sp.TABLESPACE_NAME
              FROM   DBA_IND_SUBPARTITIONS sp
                    ,DBA_INDEXES i
              WHERE  i.OWNER = sp.INDEX_OWNER
              AND    i.INDEX_NAME = sp.INDEX_NAME
              AND sp.STATUS = 'UNUSABLE'
union all
SELECT i.OWNER, i.INDEX_NAME, sp.PARTITION_NAME, sp.TABLESPACE_NAME
              FROM   DBA_IND_PARTITIONS sp
                    ,DBA_INDEXES i
              WHERE  i.OWNER = sp.INDEX_OWNER
              AND    i.INDEX_NAME = sp.INDEX_NAME
              AND    sp.STATUS = 'UNUSABLE'
/
