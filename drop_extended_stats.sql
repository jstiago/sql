DECLARE 
    v_USER VARCHAR2(30)       := 'GS_GC';
    v_TABLE_NAME VARCHAR2(30) := 'FT_T_NTEL';
BEGIN
    FOR rec IN (SELECT table_name, extension
                FROM   dba_stat_extensions
                WHERE  owner = v_USER
                AND    table_name = v_TABLE_NAME)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Running DBMS_STATS.DROP_EXTENDED_STATS(''' || v_USER || ''', ''' || rec.table_name || ''', ''' || rec.extension || ''');');
        DBMS_STATS.DROP_EXTENDED_STATS(ownname   => v_USER
                                      ,tabname   => rec.table_name
                                      ,extension => rec.extension);
    END LOOP;
END;
/
