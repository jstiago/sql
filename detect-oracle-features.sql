set pages 999

select name||'_'||dbid||'.txt'  filename from v$database;

spool &filename

prompt *******************************************
prompt Get the instance name
prompt *******************************************

select instance_name from v$instance;

prompt *******************************************
prompt checking for options installed
prompt *******************************************
 
col name  format a50 heading "Option"
col value format a10 heading "Installed?" justify center wrap
 
break on value dup skip 1
 
select
   parameter name,
   value
from 
   v$option
order by
   2 desc,
   1;
 
clear breaks
 
prompt *******************************************
prompt Checking for EE features used
prompt *******************************************
 
col c1 heading 'Feature Name'     format a45
col c2 heading 'Detected|Usages'  format 999,999
col c3 heading 'First|Usage|Date' format a10
col c4 heading 'Last|Usage|Date'  format a10
 
select
   name             c1,
    detected_usages  c2,
   first_usage_date c3,
   last_usage_date  c4
from
   dba_feature_usage_statistics
where
   first_usage_date is not null
order by
   name;
prompt *************************************
prompt Details from dba_registry
prompt *************************************

col c1 heading 'Component' format a40
col c2 heading 'Version'   format a12
col c3 heading 'Status'    format a10

select
   comp_name c1,
   version   c2,
   status
from
   dba_registry;

 
prompt *******************************************************
prompt This query goes into more detail on usage
prompt of the tuning pack
prompt *******************************************************
 
col c1 heading 'Feature Name'     format a35
col c2 heading 'Detected|Usages'  format 999,999
col c3 heading 'Last|Usage|Date'  format a10
col c4 heading 'Last|Sample|Date' format a10
 
 
select
   name              c1,
   detected_usages   c2,
   last_usage_date   c3,
   last_sample_date  c4
from 
   dba_feature_usage_statistics
where
name in (
 'ADDM',
 'Automatic SQL Tuning Advisor',
 'Automatic Workload Repository',
 'AWR Baseline',
 'AWR Baseline Template',
 'AWR Report',
 'EM Performance Page',
 'Real-Time SQL Monitoring',
 'SQL Access Advisor',
 'SQL Monitoring and Tuning pages',
 'SQL Performance Analyzer',
 'SQL Tuning Advisor',
 'SQL Tuning Set (system)',
 'SQL Tuning Set (user)'
)
order by name;
 

prompt *******************************************************
prompt This script will detect if Data Guard is being used
prompt *******************************************************
 
col c1 heading 'Data Guard Used' format a20
 
select
   decode(count(*), 0, 'No', 'Yes') c1
from
   v$dataguard_status;
 prompt
prompt ************************************************
prompt Detect data guard redo apply (physical standby)
prompt ************************************************ 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   v$managed_standby;
prompt
prompt **********************************************
prompt Detect data guard SQL Apply (logical standby)
prompt ********************************************** 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   dba_tables
where
   table_name like '%logstdby%';
prompt
prompt **********************************************
prompt Detect active data guard
prompt ********************************************** 
select
   database_role
from
   v$database
where
   database_role <> 'PRIMARY';
 
prompt *******************************************************
prompt This script will count all index types
prompt for non-standard schema owners
prompt *******************************************************
 
set pages 9999
 
col c1 heading 'Owner' format a20
col c2 heading 'Index|type' format a25
col c3 heading 'Count' format 999,999
 
break on c1 skip 1
 
select distinct
   owner c1,
   index_type c2,
   count(*)
from
   dba_indexes
where
   owner not in (
   'APEX_040200',
   'MDSYS',
   'OUTLN',
   'CTXSYS',
   'OLAPSYS',
   'FLOWS_FILES',
   'SYSTEM',
   'DVSYS',
   'AUDSYS',
   'DBSNMP',
   'GSMADMIN_INTERNAL',
   'OJVMSYS',
   'ORDSYS',
   'XDB',
   'ORDDATA',
   'SYS',
   'WMSYS',
   'LBACSYS')
group by
   owner,
   index_type
order by
   owner,
   index_type;
 
clear breaks
 
prompt *******************************************************
prompt This script will show if the database is using AWR
prompt *******************************************************
 
select
   display_value
from
   v$parameter 

where
   name = 'control_management_pack_access';
 
prompt ****************************************
prompt See if Flashback database is being used
prompt ****************************************

select flashback_on from v$database;

 prompt
prompt *******************************************
prompt Is the MTS (shared servers) enabled?
prompt ******************************************* 
col c1 heading 'Shared|Servers' format a20
select
   decode(to_number(value), 1, 'No', 'Yes') c1
from
   v$parameter
where
   name = 'shared_servers';
prompt
prompt *******************************************
prompt Detect for Bitmap join indexes
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from 
   dba_indexes
where
   join_index = 'YES'; 
prompt
prompt *******************************************
prompt Detect Replication schemas/ sites
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from
  sys.dba_repschema;
prompt
prompt *******************************************
prompt Detect 12c multitenant (12c only)
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from
  v$pdbs;
prompt
prompt *******************************************
prompt Count IOT's by schema
prompt ******************************************* 
set feedback on
select 
   owner,
   count(*)
from 
   dba_tables
where
   iot_type = 'IOT'
and owner not in (
   'APEX_040200',                                                                   
   'CTXSYS',                                                                 
   'DBSNMP',                                                                  
   'GSMADMIN_INTERNAL',                                                              
   'SYS',                                                                      
   'WMSYS') 
group by
   owner;
prompt
prompt *******************************************
prompt Is Fine Grained Auditing (FGA) Used?
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from 
   dba_fga_audit_trail;
prompt
prompt *******************************************
prompt Is Instance caging used?
prompt ******************************************* 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   v$rsrcmgrmetric_history
order by
   begin_time;
prompt
prompt *******************************************
prompt Count Materialized Views by Schema
prompt ******************************************* 
col c1 heading 'Schema|Owner' format a15
select
   owner c1,
   count(*)
from
   dba_mviews
group by
   owner;
prompt
prompt *******************************************
prompt Count function-based indexes
prompt ******************************************* 
col c1 heading 'Schema|Owner' format a15
select 
   owner    c1, 
   count(*)
from  
   dba_indexes
where 
   index_type like 'FUNCTION-BASED%'
and 
   owner not in ('XDB','SYS','SYSTEM','APEX_040200','WMSYS')
group by
   owner;
prompt
prompt *******************************************
prompt Count virtual private databases by schema
prompt ******************************************* 
col c1 heading 'Schema|Owner' format a15
select 
   object_owner    c1, 
   count(*)
from  
   dba_policies
where 
   object_owner not in (
   'MDSYS',
   'XDB',
   'SYS',
   'SYSTEM',
   'APEX_040200',
   'WMSYS')
group by
   object_owner;
prompt
prompt **********************************************
prompt Detect parallel query installed
prompt ********************************************** 
select
   decode(count(*), 0, 'No', 'Yes') 
from 
   v$pq_slave;
 
prompt
prompt *******************************************
prompt Count parallel tables and indexes by schema
prompt ******************************************* 
col c1 heading 'Schema|Owner' format a15
select 
   owner    c1,
   degree,
   count(*)
from  
   dba_tables
where 
   ltrim(degree) not in ('1', '0', 'DEFAULT')
group by
   owner,
   degree
UNION
select 
   owner    c1,
   degree,
   count(*)
from  
   dba_indexes
where 
   ltrim(degree) not in ('1', '0', 'DEFAULT')
group by
   owner,
   degree
;
prompt
prompt *******************************************
prompt Detect transportable tablespaces by schema
prompt ******************************************* 
col c1 heading 'Transportable|Tablespace' format a30
select
   t1.tablespace_name c1,
   count(*)
from
   dba_tablespaces t1,
   dba_tables      t2
where
   t1.tablespace_name = t2.tablespace_name 
and
   plugged_in <> 'NO'
group by
   t1.tablespace_name;
prompt
prompt **********************************************
prompt Detect Exadata in-memory features
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes') 
from
   dba_tables
where
   inmemory <> 'DISABLED';
prompt
prompt **********************************************
prompt Detect SQL Plan management
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes') 
from   
    dba_sql_plan_baselines;
prompt
prompt **********************************************
prompt Detect Oracle Streams
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes') 
from   
    dba_queue_tables
where
   owner = 'STRMADMIN';
prompt
prompt **********************************************
prompt Detect Exadata Zone Maps
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes') 
from
   dba_zonemap_measures;
prompt
prompt **********************************************
prompt Detect 12c Adaptive SQL Execution Plans
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes') 
from
   v$parameter
where
   name ='optimizer_adaptive_reporting_only'
and
   value = 'FALSE';
prompt
prompt **********************************************
prompt Detect Result Cache Installed
prompt ********************************************** 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   v$result_cache_objects
where
   type = 'Result';
prompt
prompt **********************************************
prompt Detect Client side query Cache Installed
prompt ********************************************** 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   v$parameter
where
   lower(name) = 'client_result_cache_size'
and
  ltrim(value) <> '0';
prompt
prompt **********************************************
prompt Detect 12c Advanced Index Compression Used
prompt ********************************************** 
select
   decode(count(*), 0, 'No', 'Yes') c1
from
   dba_indexes
where
   compression like 'ADVANCED%';
prompt
prompt **********************************************
prompt Detect 12c cell flash cache used
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes')  
from 
   v$mystat   s, 
   v$statname n 
where 
   n.statistic# = s.statistic# 
and 
   name like '%cell flash%' 
and
   value > 0
order by 1;
prompt
prompt **********************************************
prompt Detect 12c sharded queues
prompt ********************************************** 
select 
   decode(count(*), 0, 'No', 'Yes')  
from 
   dba_queues
where 
   sharded = 'TRUE';
prompt
prompt **********************************************
prompt Detect replication
prompt ********************************************** 
col sname      format a20 head "SchemaName"
col masterdef  format a10 head "MasterDef?"
col oname      format a20 head "ObjectName"
col gname      format a20 head "GroupName"
col object     format a35 trunc
col dblink     format a35 head "DBLink"
col message    format a25
col broken     format a6 head "Broken?"
select 
  sname, 
  masterdef, 
  dblink
from
  sys.dba_repschema;
 
prompt
prompt =====================================================
prompt This detects extra-cost options installed and used
prompt =====================================================
 
 
prompt 
prompt *******************************************************
prompt This script will detect if partitioning is
prompt installed and used
prompt *******************************************************
 
col c1 heading 'Partitioning|Installed' format a20
 
select
   decode(count(*), 0, 'No', 'Yes') Partitioning
from ( select 1
       from
          dba_part_tables
where owner not in ('SYSMAN', 'SH', 'SYS', 'SYSTEM')
and rownum = 1 );
col c1 heading 'Partitioning|Used' format a20
select
   decode(count(*), 0, 'No', 'Yes') c1
from
   dba_tables
where
   partitioned = 'YES'
and
   owner not in ('SYS','SYSTEM','AUDSYS');
 
col name format A30
col detected_usages format 999,999
 
select
   u1.name,
   u1.detected_usages,
   u1.currently_used,
   u1.version,
   decode(count(*), 0, 'No', 'Yes') Partitioning
from
   dba_feature_usage_statistics u1
where
   u1.version = (
   select
      MAX(u2.version)
      from
         dba_feature_usage_statistics u2
      where
         u2.name = u1.name)
and
   u1.detected_usages > 0
and
   u1.dbid = (SELECT dbid FROM v$database)
and
   lower(u1.name) like '%partitioning%'
group by
   u1.name,
   u1.detected_usages,
   u1.currently_used,
   u1.version
   order by
   name;
 
prompt *******************************************************
prompt This script will tell if the database is running RAC
prompt *******************************************************
 
select
   name,
   value
from 
   v$parameter
where
   name='cluster_database';
 prompt
prompt *******************************************
prompt Detect RAC One Node
prompt ******************************************* 
select 
   decode(count(*), 1, 'No', 'Yes') c1
from 
   v$thread;
prompt ****************************************
prompt Count number of RAC nodes
prompt ****************************************

select count(*) from gv$instance;
 
prompt *******************************************
prompt checking for OLAP features installed
prompt *******************************************
 
col c1 heading 'OLAP|Installed' format a20
 
select
   decode(count(*), 0, 'No', 'Yes') c1
from
   v$option
where
   parameter = 'OLAP';
 
prompt *******************************************
prompt checking for OLAP features used
prompt *******************************************
 
col c1 heading 'OLAP|Used' format a20
 
select
   decode(count(*), 0, 'No', 'Yes') c1
from 
   dba_feature_usage_statistics
where
   name like '%OLAP%'
and
   first_usage_date is not null;
 
prompt *******************************************
prompt Checking for Data Mining features installed
prompt *******************************************
col c1 heading 'Data Mining|Installed' format a20
 
select
   decode(count(*), 0, 'No', 'Yes') c1
from
   dba_feature_usage_statistics
where
   lower(name) like '%mining%';
prompt *******************************************
prompt checking for Oracle Spatial installed
prompt *******************************************

select 
   decode(count(*), 0, 'No', 'Yes') Spatial
from ( select 1
       from 
        all_sdo_geom_metadata 
where 
   rownum = 1 );

prompt
prompt *******************************************
prompt Detect for Advanced Compression Option
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from 
   dba_tables
where
   compression <> 'DISABLED'; 
prompt
prompt *******************************************
prompt Is Database Vault Installed?
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from 
   dba_tables
where
owner = 'DVSYS';
prompt
prompt *******************************************
prompt Is Label Security used?
prompt ******************************************* 
select 
   decode(count(*), 0, 'No', 'Yes') 
from 
   dba_sa_user_levels;
prompt
prompt *******************************************
prompt Is Exadata Used?
prompt ******************************************* 
select
   decode(count(*), 0, 'No', 'Yes') 
from
   v$cell_thread_history;
prompt
prompt *******************************************
prompt Is Oracle Spatial Used?
prompt ******************************************* 
col c1 heading 'Schema|Owner' format a15
select
   decode(count(*), 0, 'No', 'Yes') 
from
   user_sdo_geom_metadata;
 
spool off
