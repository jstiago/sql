Rem
Rem $Header: rdbmsup.sql 16-jun-2006.23:08:16 yuli Exp $
Rem
Rem rdbmsup.sql
Rem
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rdbmsup.sql - RDBMS UPgrade file for ODMA
Rem
Rem    DESCRIPTION
Rem      This file is used by the Oracle Database Upgrade 
Rem      Assistant (DBUA) to identify the original release being 
Rem      upgraded and to provide upgrade information to DBUA.
Rem
Rem    NOTES
Rem      This script is run in the context of the OLD release,
Rem      NOT the current release.  The SQL and PL/SQL must be
Rem      compatible with the oldest release supported for upgrade.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yuli        06/16/06 - bump to 10.2.0.3 
Rem    rburns      09/22/05 - add 10.2 patch release 
Rem    rburns      05/31/05 - check patch version for supported upgrades 
Rem    rburns      03/31/05 - load sqlplus help 
Rem    rburns      12/14/04 - more error numbers 
Rem    npamnani    08/20/04 - test for DBUA dummy upgrade 
Rem    rburns      07/20/04 - add FATAL and RECOVER errors, rerun tests
Rem    rburns      05/11/04 - add 10.1 upgrade, remove 806, use catupgrd.sql
Rem    rburns      03/01/04 - ignore ORDVIR 
Rem    tbgraves    12/19/03 - Upgrade re-run part 2 
Rem    tbgraves    08/28/03 - upgrade re-run
Rem    tbgraves    02/20/03 - remove OLS checks for 8.1.7, 9.0.1, 9.2 
Rem    tbgraves    10/14/02 - don't bounce for 8.0.6, 8.1.7, 9.0.1, 9.2
Rem    rburns      08/07/02 - update for 10i upgrade
Rem    rburns      02/21/02 - convert to same oracle home possible
Rem    rburns      02/04/02 - remove expected errors
Rem    rburns      12/21/01 - special case for OLS
Rem    rburns      12/06/01 - remove releases, add cmpdbmig.sql
Rem    rburns      11/10/01 - Add MIGRATE
Rem    rburns      10/05/01 - Merged rburns_component_registry_3 
Rem    rburns      10/04/01 - Created
Rem

SET SERVEROUTPUT ON;

DECLARE
   rdbmsup_version CONSTANT v$instance.version%type := '10.2.0.3';
   vers            v$instance.version%type;
   ptch_version    v$instance.version%type;   
   inst_version    v$instance.version%type := NULL;
   dict_version    v$instance.version%type := NULL;
   prev_version    v$instance.version%type := NULL;
   rerun           BOOLEAN := FALSE;
   inplace         BOOLEAN := FALSE;
   dbua_test       NUMBER;

BEGIN
   SELECT version INTO inst_version FROM v$instance;
   vers := SUBSTR(inst_version,1,6);          -- three digits
   ptch_version := SUBSTR(inst_version,1,8);  -- four digits (patch release)

   SELECT COUNT(*) INTO dbua_test FROM obj$   -- testing dbua
   WHERE owner#=0 AND type#=2 AND name='PUIU$DBUA';

   DBMS_OUTPUT.NEW_LINE;

   IF ptch_version = rdbmsup_version THEN  -- instance is target version 
      BEGIN  -- inplace upgrade or rerunning an upgrade
         EXECUTE IMMEDIATE 'SELECT version, prv_version FROM registry$ 
         WHERE cid = ''CATPROC'''
         INTO dict_version, prev_version;
         IF dict_version = inst_version THEN  -- catproc upgraded, rerun 
            rerun := TRUE;
            vers := substr(prev_version,1,6);   -- use prev catproc version 
            ptch_version := substr(prev_version,1,8);
         ELSIF substr(dict_version,1,6) IN ('10.1.0', '10.2.0') THEN
            inplace := TRUE;
            vers := substr(dict_version,1,6);   -- use CATPROC version 
            ptch_version := substr(dict_version,1,8);
         END IF;
         
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
           rerun := TRUE;  -- registry$ exists, but no CATPROC entry
         WHEN OTHERS THEN
            IF SQLCODE = -942 THEN  
               rerun := TRUE;  -- registry$ does not exist
            ELSE
              RAISE;
            END IF;
      END;
   END IF;

   IF SUBSTR(vers,6,1) = '.' THEN
      vers := SUBSTR(vers,1,5);
   END IF;
   IF SUBSTR(ptch_version,8,1) = '.' THEN
      ptch_version := SUBSTR(ptch_version,1,7);
   END IF;

   IF ptch_version IN ('8.1.7.4','9.0.1.4','9.0.1.5') OR
      (vers = '9.2.0' AND 
           ptch_version NOT IN ('9.2.0.1', '9.2.0.2','9.2.0.3')) OR
      vers IN ('10.1.0', '10.2.0') THEN
           NULL;  -- is a supported version
   ELSE
      -- version is some unsupported version
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:EXIT:NOT_INSTALLED:');
      RETURN;
   END IF;

   IF rerun THEN  -- no MIGRATE_SID directive; ignore re-run errors
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:VERSION:'||ptch_version);
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:00001:');   
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:00955:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01400:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01418:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01543:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01927:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01951:'); 
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:01952:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02033:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02260:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02264:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02273:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02441:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:04043:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:06512:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:06550:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:22308:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:22319:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:22324:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:22328:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:31085:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:PLS:IGNORE:00305:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:PLS:IGNORE:00410:');
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:PLS:IGNORE:00719:');
   ELSIF inplace THEN  -- Same Oracle Home
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:VERSION:'|| ptch_version);
   ELSE  -- Need to move to new Oracle Home
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:VERSION:'|| ptch_version);
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:MIGRATE_SID:');
   END IF;

   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:29558:'); -- NCOMP
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:06512:'); -- PL/SQL line number
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:00600:'); -- internal error
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01012:'); -- not logged on
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01031:'); -- permission denied
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01034:'); -- ORACLE no available
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01078:'); -- failure in processing system parameters
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01092:'); -- ORACLE instance terminated
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01109:'); -- database not open 
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01119:'); -- error creating database vile
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01507:'); -- database not mounted
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:01722:'); -- invalid number (upgrade script check)
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:03113:'); -- end-of-file on communications channel
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:03114:'); -- not connected to ORACLE
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:07445:'); -- exception encountered
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:FATAL:12560:'); -- TNS:protocol adapter error 
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01650:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01651:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01652:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01653:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01654:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_TBS:01655:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_ROLL:01562:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:RECOVER_INIT:04031:');

   IF inplace OR rerun THEN
      DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:BOUNCE_DATABASE:UPGRADE:UPGRADE:');
   END IF;
  
   IF dbua_test > 0 THEN -- running in test mode
      DBMS_OUTPUT.PUT_LINE
           ('ODMA_DIRECTIVE:SCRIPT:UPGRADE:work/catupgrd.sql:');
   ELSE
      DBMS_OUTPUT.PUT_LINE
           ('ODMA_DIRECTIVE:SCRIPT:UPGRADE:rdbms/admin/catupgrd.sql:');
   END IF;

   -- install sqlplus help files
   IF  NOT inplace THEN  -- don't install on patch upgrade
      DBMS_OUTPUT.PUT_LINE
      ('ODMA_DIRECTIVE:SCRIPT:UPGRADE:sqlplus/admin/help/hlpbld.sql helpus.sql:');
   END IF;

END;
/
