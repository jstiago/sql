Rem
Rem $Header: rulrelod.sql 07-oct-2004.07:41:07 ayalaman Exp $
Rem
Rem rulrelod.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rulrelod.sql - Reload Rule Manager objects after downgrade
Rem
Rem    DESCRIPTION
Rem      The top script to reload the Rule Manager objects after 
Rem      downgrade.
Rem
Rem    NOTES
Rem      See documentation
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
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
REM Reload public PL/SQL package specifications
REM
@@rulpbs.sql

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

