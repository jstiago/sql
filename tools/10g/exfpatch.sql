Rem
Rem $Header: exfpatch.sql 18-may-2006.12:00:07 ayalaman Exp $
Rem
Rem exfpatch.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfpatch.sql - Script to patch Expression Filter implementations.
Rem
Rem    DESCRIPTION
Rem      This script patches the Expression filter implementations.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    10/06/05 - bug 4658900 
Rem    ayalaman    02/18/06 - bug 5030164 
Rem    ayalaman    10/15/04 - Use new validation script 
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    07/23/04 - forward merge: compile invalid objects 
Rem    ayalaman    11/23/02 - ayalaman_exf_tests
Rem    ayalaman    11/19/02 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
          
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;
begin
  sys.dbms_registry.loading(comp_id=>'EXF', 
                            comp_name=>'Oracle Expression Filter',
                            comp_proc=>'VALIDATE_EXF');
end;
/

REM 
REM  bug 5030164 - fix column size for a column in dict table. 
REM  use exception handling so that it will not fail on repeated 
REM  execution of the patch script. 
REM 
BEGIN
  EXECUTE IMMEDIATE 'alter table exfsys.exf$attrlist modify (attrtptab VARCHAR2(75))';
EXCEPTION when others then 
  null; 
END;
/

REM
REM Create the Java library in EXFSYS schema
REM
prompt .. loading the Expression Filter Java library
@@initexf.sql

REM
REM Reload the view definitions
REM
@@exfview.sql

REM
REM Create package specifications
REM
@@exfpbs.sql 

REM
REM Create package/type implementations
REM

prompt .. creating Expression Filter package/type implementations
@@exfsppvs.plb

@@exfeapvs.plb

@@exfimpvs.plb

@@exfxppvs.plb

alter indextype expfilter compile;

alter operator evaluate compile;

EXECUTE sys.dbms_registry.loaded('EXF');

EXECUTE sys.validate_exf;

ALTER SESSION SET CURRENT_SCHEMA = SYS;
