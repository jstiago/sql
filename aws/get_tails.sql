DECLARE
  v_txt VARCHAR2(32000);
BEGIN
  FOR fil IN (select lf.filename
              from   table (rdsadmin.rds_file_util.listdir(p_directory => 'DATA_PUMP_DIR')) lf
              where  lf.filename like '%.log')
  LOOP
    select text
    into   v_txt
    from (select text from (select rownum myrow, f.* from table (
      rdsadmin.rds_file_util.read_text_file(
        p_directory => 'DATA_PUMP_DIR'
       ,p_filename  => fil.filename)  ) f )
    order by myrow desc) where rownum = 1;

    DBMS_OUTPUT.PUT_LINE(fil.filename || ':' || v_txt);
  END LOOP;
END;
/
