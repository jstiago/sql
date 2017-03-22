Rem
Rem $Header: rmxml.sql 23-feb-2005.14:33:58 kmuthiah Exp $
Rem
Rem rmxml.sql
Rem
Rem Copyright (c) 1999, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rmxml.sql - ReMove XML components from JServer
Rem
Rem    DESCRIPTION
Rem      Removes xml components from the JServer
Rem
Rem    NOTES
Rem
Rem MODIFIED (MM/DD/YY)
Rem kmuthiah  02/23/05 - add xquery too
Rem kkarun    05/12/04 - update for 10g 
Rem kkarun    12/11/03 - update packages 
Rem bihan     12/15/03 - add oracle/xml/jdwp
Rem mjaeger   09/18/03 - bug 3015638: add removal of XSU parts
Rem kkarun    04/16/03 - update pkg list
Rem kkarun    03/25/03 - use dbms_registry vars
Rem kkarun    12/12/02 - don't remove jserver system classes
Rem kkarun    11/12/02 - update version
Rem kkarun    09/26/02 - remove classgen
Rem kkarun    10/02/02 - update version
Rem kkarun    10/02/02 - update version
Rem kkarun    05/30/02 - remove plsql
Rem kkarun    12/17/01 - split drop  package v2
Rem kkarun    12/05/01 - update to use registry
Rem kkarun    04/04/01 - add xsu.
Rem kkarun    07/13/00 - fix paths
Rem kkarun    04/07/00 - update rmxml.sql
Rem nramakri  10/21/99 - Created
Rem

EXECUTE dbms_registry.removing('XML');

-- Drop Java Packages
create or replace procedure xdk_drop_package(pkg varchar2) is
   CURSOR classes is select dbms_java.longname(object_name) class_name
      from all_objects
      where object_type = 'JAVA CLASS'
	and dbms_java.longname(object_name) like '%' || pkg || '%';
begin
   FOR class IN classes LOOP
      dbms_java.dropjava('-r -v -synonym ' || class.class_name);
   END LOOP;
end xdk_drop_package;
/

EXECUTE xdk_drop_package('javax/xml');
EXECUTE xdk_drop_package('javax/xml/namespace');
EXECUTE xdk_drop_package('org/w3c/dom/bootstrap');
EXECUTE xdk_drop_package('org/w3c/dom/events');
EXECUTE xdk_drop_package('org/w3c/dom/ls');
EXECUTE xdk_drop_package('org/w3c/dom/ranges');
EXECUTE xdk_drop_package('org/w3c/dom/traversal');
EXECUTE xdk_drop_package('org/w3c/dom/validation');
EXECUTE xdk_drop_package('oracle/xml/async');
EXECUTE xdk_drop_package('oracle/xml/comp');
EXECUTE xdk_drop_package('oracle/xml/jaxp');
EXECUTE xdk_drop_package('oracle/xml/jdwp');
EXECUTE xdk_drop_package('oracle/xml/mesg');
EXECUTE xdk_drop_package('oracle/xml/parser/v2/XML');
EXECUTE xdk_drop_package('oracle/xml/parser/v2');
EXECUTE xdk_drop_package('oracle/xml/parser/schema');
EXECUTE xdk_drop_package('oracle/xml/sql');
EXECUTE xdk_drop_package('oracle/xml/util');
EXECUTE xdk_drop_package('oracle/xml/xpath');
EXECUTE xdk_drop_package('oracle/xml/xqxp');
EXECUTE xdk_drop_package('oracle/xml/xslt');
EXECUTE xdk_drop_package('OracleXML');
EXECUTE xdk_drop_package('oracle/xquery');

BEGIN
 dbms_java.dropjava('.xdk_version_' ||
                    dbms_registry.release_version || '_' ||
                    dbms_registry.release_status);
END;
/

drop procedure xdk_drop_package;

EXECUTE dbms_registry.removed('XML');

