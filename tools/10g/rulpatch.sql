Rem
Rem $Header: rulpatch.sql 07-oct-2004.07:41:07 ayalaman Exp $
Rem
Rem rulpatch.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rulpatch.sql - Patch script for the Rule Manager component
Rem
Rem    DESCRIPTION
Rem      This script reloads the rule manager implementations for 
Rem      and installed the patches. 
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    06/22/04 - remove set echo on 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/02/04 - Created
Rem


WHENEVER SQLERROR EXIT
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

REM
REM Running as sysdba : set current schema to EXFSYS
REM
ALTER SESSION SET CURRENT_SCHEMA =EXFSYS;

EXECUTE sys.dbms_registry.loading('RUL','Oracle Rule Manager');

REM
REM Create the Java library in EXFSYS schema
REM
prompt .. loading the Expression Filter/BRM Java library
@@initexf.sql

REM
REM Public PL/SQL package specifications should not be changed
REM in patches.
REM

REM
REM Reload the view definitions
REM
@@rulview.sql

REM
REM Create package/type implementations
REM
prompt .. creating Rule Manager package/type implementations
@@rulimpvs.plb

@@ruleipvs.plb

EXECUTE sys.dbms_registry.loaded('RUL');

EXECUTE sys.validate_rul;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

