DECLARE
  v_DB_NAME V$DATABASE.NAME%TYPE;
BEGIN
  SELECT NAME
  INTO   v_DB_NAME
  FROM   V$DATABASE;


  DBMS_OUTPUT.PUT_LINE(v_DB_NAME);
  DBMS_OUTPUT.PUT_LINE('START DATE/TIME: ' || to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss'));

  DBMS_OUTPUT.PUT(       'USER'       );
  DBMS_OUTPUT.PUT('~' || 'TABLE'      );
  DBMS_OUTPUT.PUT('~' || 'SEGMENT'    );
  DBMS_OUTPUT.PUT('~' || 'BYTES'      );
  DBMS_OUTPUT.PUT('~' || 'BLOCKS'     );
  DBMS_OUTPUT.PUT('~' || 'EXTENTS'    );
  DBMS_OUTPUT.PUT('~' || 'PART'       );
  DBMS_OUTPUT.PUT('~' || 'INDEX'      );
  DBMS_OUTPUT.PUT('~' || 'COLUMN'     );
  DBMS_OUTPUT.PUT('~' || 'TABLESPACE' );
  DBMS_OUTPUT.NEW_LINE;


  FOR rec IN (SELECT OWNER            "USER_NAME"
                    ,SEGMENT_NAME     "TABLE_NAME"
                    ,SEGMENT_TYPE     "SEGMENT_TYPE"
                    ,SUM(BYTES)       "BYTES"
                    ,SUM(BLOCKS)      "BLOCKS"
                    ,SUM(EXTENTS)     "EXTENTS"
                    ,NULL             "PART"
                    ,NULL             "INDEX_NAME"
                    ,NULL             "COLUMN_NAME"
                    ,TABLESPACE_NAME  "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS
              WHERE  SEGMENT_TYPE = 'TABLE'
              GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME
              UNION ALL
              -- PARTITION.
              SELECT OWNER            "USER"
                    ,SEGMENT_NAME     "TABLE"
                    ,SEGMENT_TYPE     "TYPE"
                    ,SUM(BYTES)       "BYTES"
                    ,SUM(BLOCKS)      "BLOCKS"
                    ,SUM(EXTENTS)     "EXTENTS"
                    ,PARTITION_NAME   "PART"
                    ,NULL             "INDEX"
                    ,NULL             "COLUMN"
                    ,TABLESPACE_NAME  "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS
              WHERE  SEGMENT_TYPE IN ('TABLE PARTITION', 'TABLE SUBPARTITION')
              GROUP BY OWNER, SEGMENT_NAME, SEGMENT_TYPE, PARTITION_NAME, TABLESPACE_NAME
              UNION ALL
              -- INDEX.
              SELECT a.OWNER           "USER"
                    ,b.TABLE_NAME      "TABLE"
                    ,a.SEGMENT_TYPE    "TYPE"
                    ,SUM(a.BYTES)      "BYTES"
                    ,SUM(a.BLOCKS)     "BLOCKS"
                    ,SUM(a.EXTENTS)    "EXTENTS"
                    ,NULL              "PART"
                    ,a.SEGMENT_NAME    "INDEX"
                    ,NULL              "COLUMN"
                    ,a.TABLESPACE_NAME "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS a,
                     DBA_INDEXES b
              WHERE  SEGMENT_TYPE = 'INDEX'
                AND  a.SEGMENT_NAME = b.INDEX_NAME
                AND  a.OWNER = b.OWNER
              GROUP BY a.OWNER, b.TABLE_NAME, a.SEGMENT_TYPE, a.SEGMENT_NAME, a.TABLESPACE_NAME
              UNION ALL
              -- INDEX PARTITION.
              SELECT a.OWNER           "USER"
                    ,b.TABLE_NAME      "TABLE"
                    ,a.SEGMENT_TYPE    "TYPE"
                    ,SUM(a.BYTES)      "BYTES"
                    ,SUM(a.BLOCKS)     "BLOCKS"
                    ,SUM(a.EXTENTS)    "EXTENTS"
                    ,a.PARTITION_NAME  "PART"
                    ,a.SEGMENT_NAME    "INDEX"
                    ,NULL              "COLUMN"
                    ,a.TABLESPACE_NAME "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS a,
                     DBA_INDEXES b
              WHERE  SEGMENT_TYPE IN ('INDEX PARTITION', 'INDEX SUBPARTITION')
                AND  a.SEGMENT_NAME = b.INDEX_NAME
              GROUP BY a.OWNER, b.TABLE_NAME, a.SEGMENT_TYPE, a.SEGMENT_NAME, a.PARTITION_NAME, a.TABLESPACE_NAME
              UNION ALL
              -- LOB INDEX.
              SELECT a.OWNER           "USER"
                    ,b.TABLE_NAME      "TABLE"
                    ,a.SEGMENT_TYPE    "TYPE"
                    ,SUM(a.BYTES)      "BYTES"
                    ,SUM(a.BLOCKS)     "BLOCKS"
                    ,SUM(a.EXTENTS)    "EXTENTS"
                    ,NULL              "PART"
                    ,NULL              "INDEX"
                    ,b.COLUMN_NAME     "COLUMN"
                    ,a.TABLESPACE_NAME "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS a,
                     DBA_LOBS b
              WHERE  a.SEGMENT_TYPE = 'LOBINDEX'
                AND  a.SEGMENT_NAME = b.INDEX_NAME
              GROUP BY a.OWNER, b.TABLE_NAME, a.SEGMENT_TYPE, a.SEGMENT_NAME, b.COLUMN_NAME, a.TABLESPACE_NAME
              UNION ALL
              -- LOB SEGMENT.
              SELECT a.OWNER           "USER"
                    ,b.TABLE_NAME      "TABLE"
                    ,a.SEGMENT_TYPE    "TYPE"
                    ,SUM(a.BYTES)      "BYTES"
                    ,SUM(a.BLOCKS)     "BLOCKS"
                    ,SUM(a.EXTENTS)    "EXTENTS"
                    ,NULL              "PART"
                    ,NULL              "INDEX"
                    ,b.COLUMN_NAME     "COLUMN"
                    ,a.TABLESPACE_NAME "TABLESPACE_NAME"
              FROM   DBA_SEGMENTS a,
                     DBA_LOBS b
              WHERE  a.SEGMENT_TYPE = 'LOBSEGMENT'
                AND  a.SEGMENT_NAME = b.SEGMENT_NAME
              GROUP BY a.OWNER, b.TABLE_NAME, a.SEGMENT_TYPE, a.SEGMENT_NAME, b.COLUMN_NAME, a.TABLESPACE_NAME)
  LOOP
    DBMS_OUTPUT.PUT(       rec.USER_NAME       );
    DBMS_OUTPUT.PUT('~' || rec.TABLE_NAME      );
    DBMS_OUTPUT.PUT('~' || rec.SEGMENT_TYPE    );
    DBMS_OUTPUT.PUT('~' || rec.BYTES           );
    DBMS_OUTPUT.PUT('~' || rec.BLOCKS          );
    DBMS_OUTPUT.PUT('~' || rec.EXTENTS         );
    DBMS_OUTPUT.PUT('~' || rec.PART            );
    DBMS_OUTPUT.PUT('~' || rec.INDEX_NAME      );
    DBMS_OUTPUT.PUT('~' || rec.COLUMN_NAME     );
    DBMS_OUTPUT.PUT('~' || rec.TABLESPACE_NAME );
    DBMS_OUTPUT.NEW_LINE;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('END DATE/TIME: ' || to_char(sysdate, 'mm-dd-yyyy hh24:mi:ss'));
END;
/
spool off
