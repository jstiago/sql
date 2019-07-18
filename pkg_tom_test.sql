CREATE OR REPLACE PACKAGE BODY pkg_tom_test AS

    TYPE TYP_VALUE IS TABLE OF VARCHAR2(4000)
    INDEX BY VARCHAR2(30);
    
    g_DATA TYP_VALUE;

    FUNCTION replace_var_with_value (p_str IN VARCHAR2, p_var IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        IF INSTR(p_str, ':' || p_var) > 0 THEN
            RETURN REPLACE(p_str, ':' || p_var, '''' || g_DATA(p_var) || '''');
        ELSE 
            RETURN p_str;
        END IF;
    END replace_var_with_value;

    FUNCTION replace_all_vars_in_sql (p_sql IN VARCHAR2) RETURN VARCHAR2 IS
        col   VARCHAR2(50);  
        v_sql VARCHAR2(32000) := p_sql;
    BEGIN
        col := g_DATA.FIRST;
        
        WHILE (col IS NOT NULL)
        LOOP
            v_sql := replace_var_with_value(v_sql, col);
            col := g_DATA.NEXT(col);
        END LOOP;
        
        RETURN v_sql;

    END replace_all_vars_in_sql;

    FUNCTION is_equal(p_var1 IN VARCHAR2, p_var2 IN VARCHAR2) RETURN BOOLEAN
    IS
    BEGIN
        IF p_var1 IS NULL and p_var2 IS NOT NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NOT NULL and p_var2 IS NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NULL and p_var2 IS NULL THEN
            RETURN TRUE;
        ELSE 
            RETURN p_var1 = p_var2;
        END IF;
    END is_equal;

    FUNCTION is_equal(p_var1 IN DATE, p_var2 IN DATE) RETURN BOOLEAN
    IS
    BEGIN
        IF p_var1 IS NULL and p_var2 IS NOT NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NOT NULL and p_var2 IS NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NULL and p_var2 IS NULL THEN
            RETURN TRUE;
        ELSE 
            RETURN p_var1 = p_var2;
        END IF;
    END is_equal;

    FUNCTION is_equal(p_var1 IN NUMBER, p_var2 IN NUMBER) RETURN BOOLEAN
    IS
    BEGIN
        IF p_var1 IS NULL and p_var2 IS NOT NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NOT NULL and p_var2 IS NULL THEN
            RETURN FALSE;
        ELSIF p_var1 IS NULL and p_var2 IS NULL THEN
            RETURN TRUE;
        ELSE 
            RETURN p_var1 = p_var2;
        END IF;
    END is_equal;    
    
    
    
    PROCEDURE erase_row IS
    BEGIN
        NULL;
    END erase_row;


    FUNCTION get_data_type (p_type in BINARY_INTEGER)
    RETURN VARCHAR2
    IS
    BEGIN
        IF  p_type = g_VARCHAR2_TYPE THEN
            RETURN 'VARCHAR2';
        ELSIF p_type = g_NUMBER_TYPE THEN 
            RETURN 'NUMBER';
        ELSIF p_type = g_DATE_TYPE   THEN
            RETURN 'DATE';
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Unsupported data type ' || p_type || '. See http://www.toadworld.com/platforms/oracle/w/wiki/3328.dbms-sql-describe-columns');
        END IF;

    END get_data_type;


    FUNCTION build_columns(p_interface VARCHAR2) RETURN VARCHAR2 IS
        v_column_list VARCHAR2(4000);
    BEGIN
        --FOR col IN (SELECT validation_name COLUMN_NAME
        --            FROM   tom_test_interface_validation
        --            WHERE  interface_name = p_interface
        --            AND    validation_name not in ('Count'))
        --LOOP
        --    IF v_column_list IS NOT NULL THEN
        --        v_column_list := v_column_list || ',';
        --    END IF;
        --    
        --    v_column_list := v_column_list || col.column_name;
        --END LOOP;
        --
        --RETURN v_column_list;
        
        RETURN ' * ';

    END build_columns;



    PROCEDURE test_extract(p_interface VARCHAR2) IS
        v_table_name   VARCHAR2(50);
        v_where_clause VARCHAR2(2000);
        v_column_list  VARCHAR2(2000);
        v_sql          VARCHAR2(32767);
        
        v_key1         VARCHAR2(100);
        v_key2         VARCHAR2(100);
        v_key3         VARCHAR2(100);
        
        i_cursor       INTEGER := DBMS_SQL.OPEN_CURSOR;
        n_col_count    NUMBER(10);
        t_tab          DBMS_SQL.DESC_TAB;
        i_status       INTEGER;
        i_row_count    INTEGER := 0;
        
        v_value        VARCHAR2(4000);
        
    BEGIN
        --cleardown the table
        DELETE FROM tom_unit_test_results
        WHERE  source = p_interface;
    
        SELECT table_name 
              ,where_clause
        INTO   v_table_name
              ,v_where_clause
        FROM   tom_test_interface
        WHERE  interface_name = p_interface;
        
        v_column_list := build_columns(p_interface);
        
        v_sql :=           'SELECT ' || v_column_list
              || CHR(10) || 'FROM   ' || v_table_name;
              
        IF v_where_clause IS NOT NULL THEN
            v_sql := v_sql 
              || CHR(10) || 'WHERE  ' || v_where_clause;
        END IF;
              
        
        DBMS_OUTPUT.PUT_LINE(v_sql);
        
        DBMS_SQL.PARSE(i_cursor, v_sql, DBMS_SQL.NATIVE);
        DBMS_SQL.DESCRIBE_COLUMNS(i_cursor, n_col_count, t_tab);
        
        
        DBMS_OUTPUT.PUT_LINE('Initializing the columns');
        FOR i IN 1 .. n_col_count
        LOOP
            DBMS_OUTPUT.PUT_LINE('Column ' || t_tab(i).col_name || ' ' || get_data_type(t_tab(i).col_type));
            g_DATA(t_tab(i).col_name) := ''; 
            DBMS_SQL.DEFINE_COLUMN( i_cursor, i, v_value, 4000 ); 
        END LOOP;
        
        --because we want to keep track of this just initialize to simplify logic
        g_DATA('KEY1') := ''; 
        g_DATA('KEY2') := ''; 
        g_DATA('KEY3') := ''; 
        
        i_status := DBMS_SQL.EXECUTE(i_cursor);

        --loop through the rows        
        WHILE ( dbms_sql.fetch_rows(i_cursor) > 0 ) loop
        
            --DBMS_OUTPUT.PUT_LINE('working on a row'); 

            --loop through the columns to populate g_DATA completely
            FOR i IN 1 .. n_col_count
            LOOP
                --put the values into g_DATA, cast the value as a VARCHAR2
                DBMS_SQL.COLUMN_VALUE( i_cursor, i, v_value ); 
                g_DATA(t_tab(i).col_name) :=  v_value;         
            END LOOP;

            --determine the keys and put the values for the keys
            FOR val IN (SELECT validation_name, validation_sql
                        FROM   tom_test_interface_validation
                        WHERE  interface_name = p_interface
                        AND    validation_sql IN ('KEY1', 'KEY2', 'KEY3'))
            LOOP
                g_DATA(val.validation_sql) := g_DATA(val.validation_name);
            END LOOP;
            
            --now to validate
            FOR val IN (SELECT validation_name, validation_sql
                        FROM   tom_test_interface_validation
                        WHERE  interface_name = p_interface
                        AND    validation_name <> 'Count')
            LOOP
                --IF the 1st row, then inform the validation that is going to be done
                IF i_row_count = 0 THEN 
                    DBMS_OUTPUT.PUT_LINE('Validation performed: ' || val.validation_name);
                END IF;
                validate_data(p_interface, v_table_name, val.validation_name, val.validation_sql);
            END LOOP;
            
            i_row_count := i_row_count + 1;

        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Validated ' || i_row_count || ' rows.');

        DBMS_SQL.CLOSE_CURSOR(i_cursor);
        
        BEGIN
            SELECT validation_sql
            INTO   v_sql 
            FROM   tom_test_interface_validation
            WHERE  interface_name = p_interface
            AND    validation_name = 'Count';
            
            validate_data(p_interface, v_table_name, 'Count', v_sql);
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                NULL;
        END;
        
        COMMIT;

       
    END test_extract;


    PROCEDURE validate_data(p_interface      IN VARCHAR2
                           ,p_table_name     IN VARCHAR2
                           ,p_validation     IN VARCHAR2
                           ,p_validation_sql IN VARCHAR2
                         )
    IS
        v_sql        VARCHAR2(32000);
        v_expected   VARCHAR2(4000);
        v_value      VARCHAR2(4000);
        
        TYPE cur_type IS REF CURSOR;
        cur          cur_type;

    BEGIN
        --DBMS_OUTPUT.PUT_LINE('Validating ' || p_validation);
        
        --if a count validation
        IF p_validation = 'Count' THEN
            --get the actual value
            v_sql := 'SELECT COUNT(1) FROM ' || p_table_name;
            EXECUTE IMMEDIATE v_sql INTO v_value;
            
            
            --get the expected value
            v_sql := replace_all_vars_in_sql(p_validation_sql);

            BEGIN
                EXECUTE IMMEDIATE v_sql INTO v_expected; 
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error on this SQL');
                    DBMS_OUTPUT.PUT_LINE(v_sql);
                    RAISE;
            END;
            
            
            INSERT INTO tom_unit_test_results (source        , column_name         , actual_value, expected_value      , matched)
            VALUES                            (p_interface   , p_validation        , v_value     , v_expected          , DECODE(v_value, v_expected, g_MATCH, g_NOT_MATCH));
            
            
         --else it's a column validation
         ELSE
            v_value := g_DATA(p_validation);
            
            IF p_validation_sql IN ('KEY1', 'KEY2', 'KEY3') THEN
                NULL;
            
            ELSIF p_validation_sql = 'IS NOT NULL' THEN
                IF v_value IS NULL THEN
                    INSERT INTO tom_unit_test_results (source        , p_key1        , p_key2         , p_key3          , column_name         , actual_value, expected_value      , matched)
                    VALUES                            (p_interface   , g_DATA('KEY1'), g_DATA('KEY2') , g_DATA('KEY3')  , p_validation        , v_value     , 'should not be null', g_NOT_MATCH);
                END IF;
            ELSIF p_validation_sql = 'IS NULL' THEN
                IF v_value IS NOT NULL THEN
                    INSERT INTO tom_unit_test_results (source        , p_key1        , p_key2         , p_key3          , column_name         , actual_value, expected_value      ,matched)
                    VALUES                            (p_interface   , g_DATA('KEY1'), g_DATA('KEY2') , g_DATA('KEY3')  , p_validation        , v_value     , 'should be null'    , g_NOT_MATCH);
                END IF;
            ELSIF p_validation_sql like '''%''' THEN  --literal value is expected
                v_expected := REPLACE(p_validation_sql, '''', '');
                
                IF NOT is_equal(v_expected, v_value) THEN
                    INSERT INTO tom_unit_test_results (source        , p_key1        , p_key2         , p_key3          , column_name         , actual_value, expected_value      ,matched)
                    VALUES                            (p_interface   , g_DATA('KEY1'), g_DATA('KEY2') , g_DATA('KEY3')  , p_validation        , v_value     , v_expected          ,g_NOT_MATCH);            
                END IF;
                
                
            --expecting a select statement to execute and give 1 row
            ELSE
                --replace the possible variables in the query
                v_sql := replace_all_vars_in_sql(p_validation_sql);
                
                BEGIN
                    --EXECUTE IMMEDIATE v_sql INTO v_expected; 
                    --do a single fetch to handle multiple rows
                    OPEN cur FOR v_sql;
                    FETCH cur INTO v_expected;
                    CLOSE cur;
                END;
                
                IF NOT is_equal(v_expected, v_value) THEN
                    DBMS_OUTPUT.PUT_LINE(v_sql);
                    INSERT INTO tom_unit_test_results (source        , p_key1        , p_key2         , p_key3          , column_name          , actual_value, expected_value      ,matched)
                    VALUES                            (p_interface   , g_DATA('KEY1'), g_DATA('KEY2') , g_DATA('KEY3')  , p_validation         , v_value     , v_expected          ,g_NOT_MATCH);            
                END IF;
            
            END IF;
        END IF;
        
    END validate_data;


END pkg_tom_test;
/
