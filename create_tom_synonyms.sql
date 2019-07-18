DECLARE
    v_sql  VARCHAR2(2000);
BEGIN
    FOR obj IN (SELECT 'CREATE OR REPLACE SYNONYM ' || object_name || ' FOR ' || OWNER || '.' || OBJECT_NAME ||';'
                FROM   dba_objects
                WHERE  owner IN ('CRTS_TOM', 'EGL_TOM')
                AND    object_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION', 'VIEW', 'TABLE'))
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_sql)
        
        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/
