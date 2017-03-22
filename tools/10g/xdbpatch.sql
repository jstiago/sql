Rem
Rem $Header: xdbpatch.sql 21-jul-2006.14:00:13 mrafiq Exp $
Rem
Rem xdbpatch.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbpatch.sql - Branch Specific Minor Version Patch Script for XDB
Rem
Rem    DESCRIPTION
Rem      Patches are minor releases of the database. This script, depending
Rem      on where it is checked in, attempts to migrate all the previous
Rem      minor versions of the database to the version it is checked in to.
Rem      Obviously, this is a no-op for the first major production release
Rem      in any version. In addition, the script is also expected to reload
Rem      all the related PL/SQL packages types when called via catpatch. 
Rem
Rem    NOTES
Rem      Dictionary changes are not supposed to be done in DB Minor versions,
Rem      We should conform to this directive in 10g. Also, several
Rem      irrelevant MODIFIED lines were deleted
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mrafiq      07/21/06 - adding XE to 10.2.0.3 upgrade script 
Rem    mrafiq      11/18/05 - Backport mrafiq_bug-4721297_main from st_rdbms_10.2 
Rem    mrafiq      11/08/05 - calling xdbrelod
Rem    mrafiq      11/08/05 - fix for bug 4721297: calling catxdbv 
Rem    rburns      08/17/04 - conditionally run dbmsxdbt 
Rem    spannala    04/30/04 - revalidate xdb at the end of patch 
Rem    najain      01/28/04 - call prvtxdz0 and prvtxdb0
Rem    spannala    12/16/03 - fix to be correct for main 
Rem    njalali     07/10/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

--this handles xdb upgrade from XE to 10.2.0.3
@@xdbxepatch.sql

--fix for lrg 1957560
--replaced all the other files by xdbrelod as it loads all the files
--which were being loaded before including catxdbv which is needed for fixing 
--lrg 1957560
@@xdbrelod.sql
