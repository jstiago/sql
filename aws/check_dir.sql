col filename for a50
col filesize for 9999999999
select filename, filesize, to_char(mtime, 'dd/MON/yyyy hh24:mi:ss') from table ( 
  rdsadmin.rds_file_util.listdir(
    p_directory => 'DATA_PUMP_DIR'))
order by mtime desc;
/
