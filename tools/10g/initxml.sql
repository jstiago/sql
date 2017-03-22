Rem
Rem $Header: initxml.sql 23-mar-2005.14:18:30 kmuthiah Exp $
Rem
Rem initxml.sql
Rem
Rem Copyright (c) 1999, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      initxml.sql - INITialize (load) XML components in JServer
Rem
Rem    DESCRIPTION
Rem      Loads xml components into the JServer
Rem
Rem    NOTES
Rem
Rem MODIFIED (MM/DD/YY)
Rem kmuthiah  03/23/05 - check for errors in xquery 
Rem kmuthiah  02/23/05 - load xquery.jar
Rem kkarun    05/31/04 - update for unified dom
Rem kkarun    05/12/04 - update for 10g 
Rem mjaeger   09/18/03 - bug 3015638: load XSU jar, check XSU classes
Rem kkarun    06/05/03 - fix bug 2973904
Rem kkarun    04/16/03 - update pkg list
Rem kkarun    03/25/03 - add -install
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    11/12/02 - update version
Rem kkarun    09/26/02 - remove classgen
Rem kkarun    05/30/02 - remove plsql
Rem tyu       03/18/02 - call dbmsxsu.sql after xsu12.jar.
Rem bcchang   03/15/02 - Create xsu packages.
Rem kkarun    02/13/02 - update version
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    05/18/01 - update xsu path
Rem kkarun    04/04/01 - add xsu
Rem kkarun    01/29/01 - Fix paths
Rem kkarun    04/07/00 - update initxml.sql
Rem nramakri  10/21/99 - Created
Rem

EXECUTE dbms_registry.loading('XML', 'Oracle XDK', 'xmlvalidate');

-- The following is a kludge, because the servlet.jar and xdb.jar files
-- are part of the XDB component, and they shouldn't get loaded
-- by the XML component (aka XDK).
-- But the problem is that XSU (part of XDK)
-- depends on the XMLType, and that is part of XDB.
-- Ideally what we want is a separate jar file
-- to load the XMLType and nothing else,
-- so that we don't have to load the entire XDB here.
-- As of rdbms version 10.1.0.2, this bit of the XDB
-- will _not_ get loaded again when catjava.sql calls catxdbj.sql
-- (it has been commented out).
-- Please note that in rdbms version 9.2.0,
-- we loaded servlet.jar and xdb.jar in file initxml.sql,
-- so it _is_ a proven method.
-- xmlparserv2.jar depends on XMLType.jar from xdb.jar

EXECUTE dbms_java.loadjava('-v -r -grant PUBLIC -s rdbms/jlib/servlet.jar');
EXECUTE dbms_java.loadjava('-v -r -install -grant PUBLIC -s lib/xmlparserv2.jar rdbms/jlib/xdb.jar');

EXECUTE dbms_java.loadjava('-v -r -grant PUBLIC -s lib/xsu12.jar');
-- Load the XSU PL/SQL packages, including grants and synonyms.
@@dbmsxsu.sql

-- Load XQuery
call sys.dbms_java.loadjava('-v -r -f -grant PUBLIC -synonym jlib/xquery.jar');

EXECUTE dbms_registry.loaded('XML');

create or replace procedure xmlvalidate is
  p_num NUMBER;
begin
  SELECT COUNT(*) INTO p_num
  FROM obj$
  WHERE type# = 29 AND owner# = 0 AND status <> 1
    AND ( 1=0
        OR name like 'javax/xml%'
        OR name like 'javax/xml/namespace%'
        OR name like 'javax/xml/parsers%'
        OR name like 'javax/xml/transform%'
        OR name like 'javax/xml/transform/dom%'
        OR name like 'javax/xml/transform/sax%'
        OR name like 'javax/xml/transform/stream%'
        OR name like 'oracle/xml/async%'
        OR name like 'oracle/xml/comp%'
        OR name like 'oracle/xml/jaxp%'
        OR name like 'oracle/xml/jdwp%'
        OR name like 'oracle/xml/mesg%'
        OR name like 'oracle/xml/parser%'
        OR name like 'oracle/xml/sql%'
        OR name like 'oracle/xml/util%'
        OR name like 'oracle/xml/xpath%'
        OR name like 'oracle/xml/xqxp%'
        OR name like 'oracle/xml/xslt%'
        OR name like 'org/w3c/dom%'
        OR name like 'org/xml/sax%'
        OR name like 'OracleXML%'
        OR name like 'oracle/xquery%'
    );
  IF p_num != 0 THEN
    dbms_registry.invalid('XML');
  ELSE
    dbms_registry.valid('XML');
  END IF;
  EXCEPTION WHEN no_data_found THEN
    dbms_registry.valid('XML');
end xmlvalidate;
/

EXECUTE xmlvalidate;

