DECLARE
  /* This script copies the statistics stores in the v_STAT_TAB table to the actual table.     
  */
  v_USER            VARCHAR2(30) := 'TDB'; --'TES'
  v_OWNER           VARCHAR2(30) := 'TDB';
  v_TABLE_NAME      VARCHAR2(30) := '&TABLE_NAME';
  v_STAT_TAB        VARCHAR2(30) := 'TDB_REFRESH_STATS';
  v_STAT_ID         VARCHAR2(30) := 'DEV11_STATS';
  
  
  NO_PART_EXCEPTION EXCEPTION;
  PRAGMA EXCEPTION_INIT(NO_PART_EXCEPTION, -20000); 
BEGIN

  --gather the table stats first
  BEGIN
    FOR rec IN (SELECT OWNER, TABLE_NAME
                FROM   DBA_TABLES
                WHERE  OWNER = v_USER
                AND    TABLE_NAME LIKE v_TABLE_NAME)
    LOOP
      DBMS_OUTPUT.PUT_LINE('Table ' || rec.TABLE_NAME);  
      DBMS_STATS.IMPORT_TABLE_STATS (
         ownname       => rec.OWNER, 
         tabname       => rec.TABLE_NAME,
         stattab       => v_STAT_TAB, 
         statid        => v_STAT_ID,
         cascade       => TRUE,
         statown       => v_OWNER,
         force         => TRUE);    
    
    END LOOP;

  --IGNORE THE ERRORS FOR NON-EXISTING PARTITIONS
  EXCEPTION
    WHEN NO_PART_EXCEPTION THEN
      dbms_output.put_linE('Missing Partition Found: ' || SQLERRM );
  END;

  FOR rec IN (SELECT TABLE_OWNER OWNER, TABLE_NAME, PARTITION_NAME 
              FROM   DBA_TAB_PARTITIONS
              WHERE  TABLE_OWNER = v_USER
              AND    TABLE_NAME LIKE v_TABLE_NAME)
  LOOP
    DBMS_OUTPUT.PUT_LINE('Table ' || rec.TABLE_NAME || '.' || rec.PARTITION_NAME); 
    DBMS_STATS.IMPORT_TABLE_STATS (
       ownname       => rec.OWNER, 
       tabname       => rec.TABLE_NAME,
       partname      => rec.PARTITION_NAME,
       stattab       => v_STAT_TAB, 
       statid        => v_STAT_ID,
       cascade       => TRUE,
       statown       => v_OWNER,
       force         => TRUE);    
  
  END LOOP;


  --
  --
  --FOR rec IN (SELECT OWNER, INDEX_NAME
  --            FROM   DBA_INDEXES
  --            WHERE  OWNER = v_USER
  --            AND    TABLE_NAME LIKE v_TABLE_NAME)
  --LOOP
  --  DBMS_OUTPUT.PUT_LINE('Index ' || rec.INDEX_NAME);
  --  DBMS_STATS.IMPORT_INDEX_STATS (
  --     ownname       => rec.OWNER, 
  --     indname       => rec.INDEX_NAME,
  --     stattab       => v_STAT_TAB, 
  --     statid        => v_STAT_ID,
  --     statown       => v_OWNER,
  --     force         => TRUE);    
  --
  --END LOOP;
    
  COMMIT; --just in case this does not commit ;)
    
END;
/
