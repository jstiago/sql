DECLARE
   v_sql VARCHAR2(2000);
   b_error BOOLEAN := FALSE;
BEGIN
    FOR rec IN (SELECT    object_name, object_type 
                FROM      user_objects
                WHERE     object_type IN ('PACKAGE', 'PROCEDURE', 'PACKAGE BODY', 'FUNCTION', 'VIEW')
                AND       status      <> 'VALID'
                ORDER BY  DECODE(object_type, 'FUNCTION'    , 1
                                            , 'VIEW'        , 2
                                            , 'PACKAGE'     , 3
                                            , 'PROCEDURE'   , 4
                                            , 'PACKAGE BODY', 5))
    LOOP
        IF rec.object_type <> 'PACKAGE BODY' THEN
            v_sql := 'ALTER ' || rec.object_type || ' ' || rec.object_name || ' compile';
        ELSE
            v_sql := 'ALTER ' || rec.object_type || ' ' || rec.object_name || ' compile body';
        END IF;
        
        BEGIN
            DBMS_OUTPUT.PUT_LINE(v_sql);
            EXECUTE IMMEDIATE v_sql;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error: ' || v_sql || ' : ' || SQLERRM);
                b_error := TRUE;
                --RAISE; --yeah just do this on adhoc stuff. Uncomment this if not on a proc
        END;
    END LOOP;
    
    IF b_error THEN
       RAISE_APPLICATION_ERROR(-20001, 'Some objects could not be compiled');
    END IF;
END;
/
