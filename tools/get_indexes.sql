DECLARE
    v_TABLE_NAME VARCHAR2(30);
BEGIN
    FOR ind IN (SELECT i.OWNER, i.INDEX_NAME, i.INDEX_TYPE, i.UNIQUENESS
                FROM   DBA_INDEXES i
                WHERE  i.TABLE_NAME LIKE '&1'
                ORDER BY i.OWNER, i.INDEX_NAME)
    LOOP
    
        DBMS_OUTPUT.PUT_LINE('INDEX ' || ind.OWNER || '.' || ind.INDEX_NAME || ' ' || ind.INDEX_TYPE || ' ' || ind.UNIQUENESS);
    
        FOR col IN (SELECT c.COLUMN_NAME, DECODE(c.DESCEND, 'ASC', NULL, c.DESCEND) DESCEND
                    FROM   DBA_IND_COLUMNS c
                    WHERE  c.INDEX_OWNER  =  ind.OWNER
                    AND    c.INDEX_NAME   =  ind.INDEX_NAME
                    ORDER BY c.COLUMN_POSITION) 
        LOOP
            DBMS_OUTPUT.PUT_LINE('    ' || col.COLUMN_NAME || ' ' || col.DESCEND);
        END LOOP;
    END LOOP;
END;
/
