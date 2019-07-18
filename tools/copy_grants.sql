BEGIN
  FOR rec IN (SELECT grantee, table_name, PRIVILEGE
              FROM   dba_tab_privs@tdblnd20
              WHERE  grantee IN ('TDB_UPDATE_ROLE', 'TDB_QUERY_ROLE'))
  LOOP
    BEGIN
      EXECUTE IMMEDIATE    'GRANT '
                        || rec.PRIVILEGE
                        || ' ON '
                        || rec.table_name
                        || ' TO '
                        || rec.grantee;
    EXCEPTION
      WHEN OTHERS
      THEN
        NULL;
    END;
  END LOOP;
END;
/
