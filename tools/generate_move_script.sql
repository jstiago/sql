DECLARE
    v_SQL   VARCHAR2(10000);
    v_OWNER VARCHAR2(30) := '&1';
    v_TABLE VARCHAR2(30) := '&2';
    v_NEW_DATA_TABLESPACE   VARCHAR2(30) := '&3';
    v_NEW_INDEX_TABLESPACE  VARCHAR2(30) := '&4';
BEGIN

    --Move the LOBs of this table to the new data tablespace
    FOR rec IN (SELECT column_name, segment_name, index_name
                FROM   dba_lobs
                WHERE  owner = v_OWNER
                AND    table_name = v_TABLE)
    LOOP
        v_SQL := 'ALTER TABLE ' || v_OWNER || '.' || v_TABLE || 
                 '  MOVE LOB(' || rec.column_name || ') STORE AS ' || 
                 rec.segment_name || ' (TABLESPACE ' || v_NEW_DATA_TABLESPACE || ');';
        DBMS_OUTPUT.PUT_LINE(v_SQL);
    END LOOP;
    
    --Move the segments of this table to the new data tablespace
    FOR rec IN (SELECT segment_type, partition_name 
                FROM   dba_segments
                WHERE  owner = v_OWNER 
                AND    segment_name = v_TABLE)
    LOOP
        IF rec.segment_type = 'TABLE' THEN
            v_SQL := 'ALTER TABLE ' || v_OWNER || '.' || v_TABLE || ' MOVE TABLESPACE ' || v_NEW_DATA_TABLESPACE || ';';
        
        ELSIF rec.segment_type = 'TABLE PARTITION' THEN
            v_SQL := 'ALTER TABLE ' || v_OWNER || '.' || v_TABLE || ' MOVE PARTITION ' || rec.partition_name || ' TABLESPACE ' || v_NEW_DATA_TABLESPACE || ';';
        
        ELSIF rec.segment_type = 'TABLE SUBPARTITION' THEN
            v_SQL := 'ALTER TABLE ' || v_OWNER || '.' || v_TABLE || ' MOVE SUBPARTITION ' || rec.partition_name || ' TABLESPACE ' || v_NEW_DATA_TABLESPACE || ';';
        
        END IF;
        
        DBMS_OUTPUT.PUT_LINE(v_SQL);
        
    END LOOP;

    FOR rec IN (SELECT index_name
                FROM   dba_indexes
                WHERE  table_owner = v_OWNER
                AND    table_name  = v_TABLE)
    LOOP
        FOR ind IN (SELECT segment_type, partition_name 
                    FROM   dba_segments
                    WHERE  owner = v_OWNER 
                    AND    segment_name = rec.index_name
                    AND    segment_type like 'INDEX%')
        LOOP
            IF ind.segment_type = 'INDEX' THEN
                v_SQL := 'ALTER INDEX ' || v_OWNER || '.' || rec.index_name || ' REBUILD TABLESPACE ' || v_NEW_INDEX_TABLESPACE || ';';
            
            ELSIF ind.segment_type = 'INDEX PARTITION' THEN
                v_SQL := 'ALTER INDEX ' || v_OWNER || '.' || rec.index_name || ' REBUILD PARTITION ' || ind.partition_name || ' TABLESPACE ' || v_NEW_INDEX_TABLESPACE || ';';
            
            ELSIF ind.segment_type = 'INDEX SUBPARTITION' THEN
                v_SQL := 'ALTER INDEX ' || v_OWNER || '.' || rec.index_name || ' REBUILD SUBPARTITION ' || ind.partition_name || ' TABLESPACE ' || v_NEW_INDEX_TABLESPACE || ';';
            
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(v_SQL);
            
        END LOOP;    
    END LOOP;

END;
/
