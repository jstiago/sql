DECLARE
  /* This script creates a STATISTICS table to store the statistics, then copies the schema STATS from v_USER */
  v_USER            VARCHAR2(30) := 'TDB'; --'TES'
  v_OWNER           VARCHAR2(30) := 'TDB';
  v_STAT_TAB        VARCHAR2(30) := 'BKP_TAB_STATS_DEV11';
  v_TABLESPACE_NAME VARCHAR2(30) := '&TABLESPACE';
  v_STAT_ID         VARCHAR2(30) := 'DEV5_STATS';
BEGIN

  DBMS_STATS.CREATE_STAT_TABLE (
    ownname  => v_USER, 
    stattab  => v_STAT_TAB,
    tblspace => v_TABLESPACE_NAME);

  DBMS_STATS.EXPORT_SYSTEM_STATS (
    stattab  => v_STAT_TAB, 
    statid   => v_STAT_ID,
    statown  => v_OWNER);
    
  DBMS_STATS.EXPORT_SCHEMA_STATS (
    ownname => v_USER,
    stattab => v_STAT_TAB, 
    statid  => v_STAT_ID,
    statown => v_OWNER);


--  DBMS_STATS.EXPORT_SCHEMA_STATS (
--    ownname => 'TES',
--    stattab => v_STAT_TAB, 
--    statid  => v_STAT_ID,
--    statown => v_OWNER);
    
    
  COMMIT; --just in case this does not commit ;)
END;
/
