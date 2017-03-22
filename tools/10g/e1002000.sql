Rem
Rem $Header: e1002000.sql 18-oct-2006.07:32:57 rburns Exp $
Rem
Rem e1002000.sql
Rem
Rem Copyright (c) 2005, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      e1002000.sql - 10.2 patch release backout script
Rem
Rem    DESCRIPTION
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      needed to downgrade from the current 10.2 patch release to 
Rem      prior 10.2 patch releases
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      10/18/06 - EM downgrade actions
Rem    cdilling    07/12/06 - add support for SDO downgrade script 5176457
Rem    mxu         07/10/06 - Drop htmldb_system package 
Rem    juyuan      06/28/06 - drop dbms_reco_script_lib 
Rem    rburns      11/07/05 - add JAVAVM downgrade 
Rem    tcruanes    10/19/05 - support bug fix control 
Rem    rburns      09/21/05 - patch downgrade 
Rem    rburns      09/21/05 - Created
Rem

Rem *************************************************************************
Rem BEGIN e1002000.sql
Rem *************************************************************************

Rem=========================================================================
Rem Drop new fixed views here
Rem=========================================================================

Rem Remove bug control service views
drop public synonym v$session_fix_control;
drop view v_$session_fix_control;
drop public synonym gv$session_fix_control;
drop view gv_$session_fix_control;
drop public synonym v$system_fix_control;
drop view v_$system_fix_control;
drop public synonym gv$system_fix_control;
drop view gv_$system_fix_control;


Rem=========================================================================
Rem JAVAVM actions for jvmrelod.sql
Rem=========================================================================

BEGIN
  EXECUTE IMMEDIATE '
    UPDATE java$jvm$status SET action=''DOWNGRADE'', inprogress = ''N'',
         punting=''FALSE''
    ';
  COMMIT;
EXCEPTION 
  WHEN OTHERS THEN NULL;
END;
/

Rem==========================================================================
Rem Drop new libraries
Rem==========================================================================

Rem BEGIN dropping recoverable scripts packages

DROP PACKAGE dbms_reco_script_int;
DROP PACKAGE dbms_reco_script_invok;
DROP PACKAGE dbms_recoverable_script;
DROP LIBRARY dbms_reco_script_lib;

Rem END dropping recoverable scripts packages

Rem=========================================================================
Rem Drop new packages
Rem=========================================================================

Rem Drop htmldb_system package
drop library sys.wwv_flow_val_lib; 
drop package sys.htmldb_system;
drop public synonym htmldb_system;

Rem Setup component script filename variable
COLUMN dbdwg_name NEW_VALUE dbdwg_file NOPRINT;

Rem ======================================================================
Rem Downgrade Spatial
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('SDO') AS dbdwg_name FROM DUAL;
@&dbdwg_file 
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EM
Rem ======================================================================

BEGIN
 IF dbms_registry.is_loaded('EM') IS NOT NULL THEN
   EXECUTE IMMEDIATE
     'ALTER SESSION SET CURRENT_SCHEMA=SYSMAN';
   EXECUTE IMMEDIATE
     'BEGIN
       MGMT_LOADER.deregister_pre_load_callback(''ECM_CT.PRELOAD_CALLBACK'');
       MGMT_LOADER.deregister_post_load_callback(''ECM_CT.POSTLOAD_CALLBACK'');
       COMMIT;
      END;';
   EXECUTE IMMEDIATE 
     'DROP PACKAGE MGMT_LOADER';
 END IF;
END;
 /

ALTER SESSION SET CURRENT_SCHEMA=SYS;

Rem *************************************************************************
Rem END e1002000.sql
Rem *************************************************************************
