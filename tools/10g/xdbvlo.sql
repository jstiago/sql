Rem
Rem $Header: xdbvlo.sql 01-nov-2004.13:09:20 pnath Exp $
Rem
Rem xdbvlo.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbvlo.sql - Xml DB VaLidate all Objects after upgrade
Rem
Rem    DESCRIPTION
Rem      Makes sure XML DB objects are valid after an upgrade.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    08/23/03 - 
Rem    spannala    08/21/03 - adding revalidation of invalid schemas 
Rem    njalali     04/03/03 - njalali_xdbupg_catmet_main
Rem    njalali     04/02/03 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- Some implementations have these operators defined, and some don't.
-- Regardless, they are unused in 9.2.0.2 and should be dropped.
begin
  execute immediate 'drop indextype xdb.path_index';
exception
  when others then
    commit;
end;
/
begin
  execute immediate 'drop operator xdb.xdbpi_noop';
exception
  when others then
    commit;
end;
/


alter package sys.dbms_regxdb compile;
alter package xdb.DBMS_XMLSCHEMA compile;
alter package xdb.dbms_xdbz0 compile;
alter package xdb.dbms_xdbz compile;
alter trigger xdb.XDB_PI_TRIG compile;
alter package xdb.DBMS_XDBUTIL_INT compile;
alter procedure xdb.xdb$patchupdeleteschema compile;
alter procedure xdb.XDB$PATCHUPSCHEMA compile;
alter type xdb.XDB$RESLOCK_ARRAY_T compile;
alter procedure xdb.XDB$INITXDBSCHEMA compile;
alter package xdb.dbms_xdbt compile;
alter type xdb.XDB$ENUM2_T compile;
alter type xdb.XDB$ENUM_VALUES_T compile;
alter type xdb.XDB$EXTRA_LIST_T compile;
alter type xdb.XDB$NLOCKS_T compile;
alter procedure xdb.XDB_DATASTORE_PROC compile;
alter type xdb."privilegeNameType1_T" compile;
alter package xdb.dbms_xdbt compile;
alter procedure xdb.XDB_DATASTORE_PROC compile;


Rem Recompile invalidated schemas
declare
  cur             INTEGER;
  rc              INTEGER;
  schema_url      VARCHAR2(2000);
  stmt            VARCHAR2(2000);
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur,
       'select x.qual_schema_url from dba_xml_schemas x, dba_objects o where o.object_type = ''XML SCHEMA'' and o.status != ''VALID'' and o.object_name = x.int_objname',
    dbms_sql.native);
  dbms_sql.define_column(cur, 1, schema_url, 2000);
  rc := dbms_sql.execute(cur);
  LOOP
    IF dbms_sql.fetch_rows(cur) > 0 THEN
      dbms_sql.column_value(cur, 1, schema_url);
      dbms_output.put_line('Recompiling invalid schema with URL: ' ||
                           schema_url);
      dbms_xmlschema.compileschema(schema_url);
    ELSE
      exit;
    END IF;
  END LOOP;
  dbms_sql.close_cursor(cur);
  commit;
end;
/

Rem Clean up invalidated triggers
declare
  cur             INTEGER;
  rc              INTEGER;
  obj_name        VARCHAR2(2000);
  stmt            VARCHAR2(2000);
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(
    cur, 
    'select object_name from dba_objects where owner = ''XDB'' and status != ''VALID'' and object_type = ''TRIGGER''',
    dbms_sql.native);
  dbms_sql.define_column(cur, 1, obj_name, 2000);
  rc := dbms_sql.execute(cur);
  LOOP
    IF dbms_sql.fetch_rows(cur) > 0 THEN
      dbms_sql.column_value(cur, 1, obj_name);
      stmt := 'alter trigger XDB."' || obj_name || '" compile';
      execute immediate stmt;
    ELSE
      exit;
    END IF;
  END LOOP;
  dbms_sql.close_cursor(cur);
  commit;
end;
/

Rem Reset XDB version
execute dbms_registry.loaded('XDB');

Rem Set XDB to a valid state.
Rem We cannot use sys.dbms_regxdb.validatexdb() because 
Rem resource_view is unusable until the DB is restarted.
execute sys.dbms_registry.valid('XDB');

