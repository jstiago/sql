Rem
Rem $Header: catbsln.sql 21-feb-2005.12:38:21 jsoule Exp $
Rem
Rem catbsln.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbsln.sql - Baseline schema creation.
Rem
Rem    DESCRIPTION
Rem      Creates the EM baseline feature schema components
Rem
Rem    NOTES
Rem      Called by catsnmp.sql during database creation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      02/16/05 - use .plb instead of plaintext 
Rem    jberesni    08/19/04 - remove jobs 
Rem    jsoule      08/06/04 - rename scripts with uppercase 
Rem    jberesni    08/01/04 - add jobs 
Rem    jberesni    07/28/04 - add dml 
Rem    jberesni    07/15/04 - candidate1
Rem    jberesni    07/15/04 - Created
Rem

@@bsln_types.sql
@@bsln_tables.sql
@@bsln_pkgdef.sql
@@prvtbsln.plb
@@bsln_dmldb.sql
