begin
  FOR REC IN (SELECT i.OWNER, i.INDEX_NAME, '' PART_NAME, i.TABLESPACE_NAME, '' SEGMENT_TYPE
              FROM   DBA_INDEXES i
              WHERE  i.STATUS = 'UNUSABLE'
              union all
              SELECT i.OWNER, i.INDEX_NAME, sp.SUBPARTITION_NAME, sp.TABLESPACE_NAME, 'SUBPARTITION'
                            FROM   DBA_IND_SUBPARTITIONS sp
                                  ,DBA_INDEXES i
                            WHERE  i.INDEX_NAME = sp.INDEX_NAME
                            AND    sp.STATUS = 'UNUSABLE'
              union all
              SELECT i.OWNER, i.INDEX_NAME, sp.PARTITION_NAME, sp.TABLESPACE_NAME, 'PARTITION'
                            FROM   DBA_IND_PARTITIONS sp
                                  ,DBA_INDEXES i
                            WHERE  i.INDEX_NAME = sp.INDEX_NAME
                            AND    sp.STATUS = 'UNUSABLE')
  loop
    dbms_output.put_line(REC.PART_NAME);
    EXECUTE IMMEDIATE 'alter index ' || rec.OWNER || '.' || rec.INDEX_NAME || ' rebuild ' || REC.SEGMENT_TYPE || ' ' || REC.PART_NAME;
  end loop;
end;
/
