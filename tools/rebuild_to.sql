begin
  FOR REC IN (SELECT i.INDEX_NAME, '' PART_NAME, i.TABLESPACE_NAME, '' SEGMENT_TYPE
              FROM   USER_INDEXES i
              WHERE  i.STATUS = 'UNUSABLE'
              union all
              SELECT i.INDEX_NAME, sp.SUBPARTITION_NAME, sp.TABLESPACE_NAME, 'SUBPARTITION'
                            FROM   USER_IND_SUBPARTITIONS sp
                                  ,USER_INDEXES i
                            WHERE  i.INDEX_NAME = sp.INDEX_NAME
                            AND    sp.STATUS = 'UNUSABLE'
              union all
              SELECT i.INDEX_NAME, sp.PARTITION_NAME, sp.TABLESPACE_NAME, 'PARTITION'
                            FROM   USER_IND_PARTITIONS sp
                                  ,USER_INDEXES i
                            WHERE  i.INDEX_NAME = sp.INDEX_NAME
                            AND    sp.STATUS = 'UNUSABLE')
  loop
    dbms_output.put_line(REC.PART_NAME);
    EXECUTE IMMEDIATE 'alter index ' || rec.INDEX_NAME || ' rebuild ' || REC.SEGMENT_TYPE || ' ' || REC.PART_NAME || ' tablespace &1';
  end loop;
end;
/
