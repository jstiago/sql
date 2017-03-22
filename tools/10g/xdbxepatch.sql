Rem
Rem $Header: xdbxepatch.sql 18-jul-2006.14:44:00 mrafiq Exp $
Rem
Rem xdbxepatch.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbxepatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mrafiq      07/18/06 - xdb upgrade from XE to 10.2.0.3 
Rem    mrafiq      07/18/06 - Created
Rem

-- Get utility functions
@@xdbuuc.sql

--this proedure drops and attr type and catches an exception if one occurs
CREATE OR REPLACE PROCEDURE ALT_TYPE_DROP_ATTRIBUTE_OWN(
						   type_owner IN varchar2,
                                                   type_name IN varchar2,
                                                   attr_string IN varchar2) as
  sqlstr varchar2(1000);
  attr_does_not_exists  EXCEPTION;
  PRAGMA EXCEPTION_INIT(attr_does_not_exists,-22324);
BEGIN
  sqlstr := 'alter type "' || type_owner || '"."' || type_name ||
            '" drop attribute (' || attr_string || ') cascade';
  EXECUTE IMMEDIATE sqlstr;
EXCEPTION
   when attr_does_not_exists then
     NULL;
END;
/
show errors;

create or replace procedure remove_from_config_seq(
                              config_schema_ref IN REF XMLTYPE,
                              config_schema_url IN VARCHAR2,
                              config_name       IN varchar2,
                              name              IN varchar2,
                              pd                IN varchar2) as
  config_seq_ref         REF XMLTYPE;
  elem_arr               XDB.XDB$XMLTYPE_REF_LIST_T;
  last_elem_ref          REF XMLTYPE;
  last_elem_name         varchar2(100);
  conf_type              varchar2(100);
  conf_type_owner        varchar2(100);
begin

  -- select the sequence kid corresponding to the config type
  select c.xmldata.sequence_kid into config_seq_ref from
    xdb.xdb$complex_type c where ref(c)= 
      (select e.xmldata.cplx_type_decl from xdb.xdb$element e
        where e.xmldata.property.name = config_name and
        e.xmldata.property.parent_schema = config_schema_ref);

  -- select the sequence elements
  select m.xmldata.elements into elem_arr from xdb.xdb$sequence_model m
   where ref(m) = config_seq_ref;
    
  -- Look at the name of the last element
  last_elem_ref := elem_arr(elem_arr.last);
  select e.xmldata.property.name into last_elem_name from xdb.xdb$element e
    where ref(e) = last_elem_ref;

  -- If the name matches give-name then remove the element
  if last_elem_name = name then
    -- remove last element
    dbms_output.put_line('upgrading ' || name);
    delete_elem_by_ref(elem_arr(elem_arr.last), true);
    elem_arr.trim(1);

    -- update the table with the extended sequence and new pd
    update xdb.xdb$sequence_model m 
    set m.xmldata.elements = elem_arr,
        m.xmldata.sys_xdbpd$ = XDB.XDB$RAW_LIST_T(pd)
    where ref(m) = config_seq_ref;
    commit;
  end if;
    -- fetch the type and owner of the element
    element_type(config_schema_url, config_name, conf_type_owner,
                 conf_type);

    -- alter type drop attribute
    alt_type_drop_attribute_own(conf_type_owner, conf_type, '"'||name||'"');
 
end;
/
show errors;

create or replace procedure upgrade_config_schema as
  CONFIG_SCHEMA_URL      CONSTANT VARCHAR2(100) := 
                           'http://xmlns.oracle.com/xdb/xdbconfig.xsd';
  PN_RES_TOTAL_PROPNUMS   CONSTANT INTEGER := 139;
  sch_ref                 REF SYS.XMLTYPE;
  numprops                number;
begin  

-- get the Resource schema's REF
  select ref(s) into sch_ref from xdb.xdb$schema s where  
  s.xmldata.schema_url = CONFIG_SCHEMA_URL;

-- Has the property already been deleted
  select s.xmldata.num_props into numprops from xdb.xdb$schema s 
  where ref(s) = sch_ref;

  IF (numprops != PN_RES_TOTAL_PROPNUMS) THEN

    dbms_output.put_line('upgrading config schema');

    remove_from_config_seq(sch_ref, CONFIG_SCHEMA_URL,
                         'httpconfig', 'http2-host', '230200000081801107');
  
    remove_from_config_seq(sch_ref, CONFIG_SCHEMA_URL,
                         'httpconfig', 'http-host', '230200000081801107');

    update xdb.xdb$schema s
    set s.xmldata.num_props = PN_RES_TOTAL_PROPNUMS
    where ref(s) = sch_ref;
    commit;
  END IF;

  dbms_output.put_line('config schema upgraded');
end;
/
show errors;

-- This function removes TWO elements from xmlconfig.xml
-- as part of upgrade. This is done to remove PD information
create or replace procedure remove_xdbconfig_data_elements as
  configxml sys.xmltype;
  doc       dbms_xmldom.DOMDocument;
  dn        dbms_xmldom.DOMNode;
  de        dbms_xmldom.DOMElement;
  nl        dbms_xmldom.DOMNodeList;
  sysn      dbms_xmldom.DOMNode;
  syse      dbms_xmldom.DOMElement;
  cn        dbms_xmldom.DOMNode;
  begin
-- Select the resource and set it into the config
  select sys_nc_rowinfo$ into configxml from xdb.xdb$config ;

  doc  := dbms_xmldom.newDOMDocument(configxml);
  dn   := dbms_xmldom.makeNode(doc);
  dn   := dbms_xmldom.getFirstChild(dn);
  de   := dbms_xmldom.makeElement(dn);

  nl   := dbms_xmldom.getChildrenByTagName(de, 'sysconfig');
  sysn := dbms_xmldom.item(nl, 0);
  syse := dbms_xmldom.makeElement(sysn);

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'protocolconfig');
  sysn := dbms_xmldom.item(nl, 0);
  syse := dbms_xmldom.makeElement(sysn);

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'httpconfig');
  sysn := dbms_xmldom.item(nl, 0);
  syse := dbms_xmldom.makeElement(sysn);

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'http2-host');

  if not(dbms_xmldom.isNull(nl)) then
    cn := dbms_xmldom.item(nl, 0);
    if not(dbms_xmldom.isNull(cn)) then
      cn := dbms_xmldom.removeChild(sysn, cn);
    end if;
  end if;

  nl   := dbms_xmldom.getChildrenByTagName(syse, 'http-host');

  if not(dbms_xmldom.isNull(nl)) then
    cn := dbms_xmldom.item(nl, 0);
    if not(dbms_xmldom.isNull(cn)) then
      cn := dbms_xmldom.removeChild(sysn, cn);
    end if;
  end if;

  dbms_xdb.cfg_update(configxml);
  commit;

end;
/

show errors;

-- Remove extra data elements from xdbconfig first
call remove_xdbconfig_data_elements();

-- upgrade config schema
call upgrade_config_schema();

drop procedure remove_xdbconfig_data_elements;
drop procedure upgrade_config_schema;
drop procedure remove_from_config_seq;
drop procedure alt_type_drop_attribute_own;

-- drop utility functions
@@xdbuud.sql
