select * from (select text from (select rownum myrow, f.* from table (
  rdsadmin.rds_file_util.read_text_file(
    p_directory => 'DATA_PUMP_DIR'
   ,p_filename  => '&1')  ) f )
order by myrow desc) where rownum < 5
/
