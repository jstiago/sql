DECLARE
--This PL/SQL Block grants all the objects of a user to a role specified in v_role variable
--We can run this AD HOC and the regrants will happen
    v_role VARCHAR2(30) := 'GS_GC_READROLE';
    v_sql  VARCHAR2(2000);
BEGIN
    FOR obj IN (SELECT object_name, object_type
                FROM   user_objects
                WHERE  object_type IN ('TABLE'))
    LOOP
        v_sql := 'GRANT SELECT  ON ' || obj.object_name || ' TO ' || v_role;
            
        EXECUTE IMMEDIATE v_sql;
    END LOOP;
END;
/
SPOOL OFF
EXIT
