select * from table (
  rdsadmin.rds_file_util.read_text_file(
    p_directory => 'DATA_PUMP_DIR'
   ,p_filename  => '&1'))
/
