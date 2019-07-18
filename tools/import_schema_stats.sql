BEGIN
  DBMS_STATS.import_schema_stats(
        ownname => 'TDB',
        stattab => 'TDB_REFRESH_STATS',
        statid => 'STAT20110701120017',
        statown => 'TDB',
        no_invalidate => FALSE,
        force  => TRUE);
END;
/
