COLUMN dbid NEW_VALUE DBID
select DBID from v$database;
define inst_num    = '';       -- NULL defaults to current instance
define report_type = 'html';   -- 'text' for TEXT
define begin_time  = '6/7 16:15';
define duration    = '15';      -- time in minutes
define report_name = '/tmp/report_node2.html';
define slot_width  = '';
define target_session_id   = '';
define target_sql_id       = '';
define target_wait_class   = '';
define target_service_hash = '';
define target_module_name  = '';
define target_action_name  = '';
define target_client_id    = '';
define target_plsql_entry  = '';
define target_container    = '';
@$ORACLE_HOME/rdbms/admin/ashrpti

define  inst_num     = 1;
define  num_days     = 1;
define  inst_name    = 'Instance';
define  db_name      = 'Database';
define  dbid         = 3116559863;
define  sql_id       = 'dpvq3ug5kw3m5'; 
define  begin_snap   = 81658;
define  end_snap     = 81660;
define  report_type  = 'html';
define  report_name  = 'F:\temp\cq7471_0721_dpvq3ug5kw3m5.html';
@@?/rdbms/admin/awrsqrpi.sql