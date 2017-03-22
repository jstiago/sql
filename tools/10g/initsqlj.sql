--
-- CREATE SQLJUTL PACKAGE
--
create or replace package sqljutl as

   -- The following is required at translate-time for SQLJ
   function has_default(oid number,
                        proc char,
                        seq number,
                        ovr number) return number;

   -- The following is required at translate-time for JPublisher
   procedure get_typecode(tid raw, code OUT number,
                          class OUT varchar2, typ OUT number);

   -- The following might be used at runtime for converting
   -- between SQL and PL/SQL types 
   function bool2int(b boolean) return integer;
   function int2bool(i integer) return boolean;
   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR;
   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED;
   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR;
   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED;
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2;
end sqljutl;
/

create or replace package sqljutl2 AUTHID CURRENT_USER as

   -- The following APIs are used for native invocation of
   -- server-side Java code
   FUNCTION evaluate(args LONG RAW) RETURN LONG RAW;
   FUNCTION invoke(handle NUMBER, class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW;
   FUNCTION invoke(class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW;
   FUNCTION reflect(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN LONG;
   FUNCTION reflect2(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN CLOB;

end sqljutl2;
/

create or replace package body sqljutl is

   function has_default(oid number,
                        proc char,
                        seq number,
                        ovr number) return number is
            def number;
   begin
      if proc IS NULL
      then
         select DEFAULT# INTO def FROM ARGUMENT$
                WHERE PROCEDURE$ IS NULL AND OBJ# = oid
                      AND SEQUENCE# = seq AND OVERLOAD# = ovr;
      else 
         select DEFAULT# INTO def FROM ARGUMENT$
                WHERE PROCEDURE$ = proc AND OBJ# = oid
                      AND SEQUENCE# = seq AND OVERLOAD# = ovr;
      end if;

      if def IS NULL
      then return 0;
      else return 1;
      end if;
   end has_default;


   procedure get_typecode
               (tid raw, code OUT number,
                class OUT varchar2, typ OUT number) is
      m NUMBER;
   begin
      SELECT typecode, externname, externtype INTO code, class, typ
      FROM TYPE$ WHERE toid = tid;
   exception
      WHEN TOO_MANY_ROWS
      THEN
      begin
        SELECT max(version#) INTO m FROM TYPE$ WHERE toid = tid;
        SELECT typecode, externname, externtype INTO code, class, typ
        FROM TYPE$ WHERE toid = tid AND version# = m;
      end;
   end get_typecode;

   function bool2int(b BOOLEAN) return INTEGER is
   begin if b is null then return null;
         elsif b then return 1;
         else return 0; end if;
   end bool2int;

   function int2bool(i INTEGER) return BOOLEAN is
   begin if i is null then return null;
         else return i<>0;
         end if;
   end int2bool;

   function ids2char(iv DSINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(19);
   begin
      res := iv;
   end ids2char;

   function char2ids(ch CHAR) return DSINTERVAL_UNCONSTRAINED is
      iv DSINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2ids;

   function iym2char(iv YMINTERVAL_UNCONSTRAINED) return CHAR is
      res CHAR(9);
   begin
      res := iv;
   end iym2char;

   function char2iym(ch CHAR) return YMINTERVAL_UNCONSTRAINED is
      iv YMINTERVAL_UNCONSTRAINED;
   begin
      iv := ch;
      return iv;
   end char2iym;

   -- SYS.URITYPE and VARCHAR2
   function uri2vchar(uri SYS.URITYPE) return VARCHAR2 is
   begin
      return uri.geturl;
   end uri2vchar;

end sqljutl;
/

create or replace package body sqljutl2 as

   FUNCTION evaluate(args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.evaluate(byte[]) return byte[]';

   FUNCTION invoke(handle NUMBER, class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.invoke(java.lang.Long,java.lang.String,java.lang.String,java.lang.String,byte[]) return byte[]';

   FUNCTION invoke(class VARCHAR2, name VARCHAR2, sig VARCHAR2, args LONG RAW) RETURN LONG RAW
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.invoke(java.lang.String,java.lang.String,java.lang.String,byte[]) return byte[]';

   FUNCTION reflect(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN LONG
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.reflect(java.lang.String,int) return java.lang.String';

   FUNCTION reflect2(class_Or_Package VARCHAR2, only_Declared NUMBER) RETURN CLOB 
   AS LANGUAGE JAVA
   NAME 'oracle.jpub.reflect.Server.reflect2(java.lang.String,int) return oracle.sql.CLOB';

end sqljutl2;
/

grant execute on sqljutl to public ;
grant execute on sqljutl2 to public ;

--
-- CREATE UTL_DBWS PACKAGE
--
create or replace package utl_dbws as

 -------------------------------------------
 -------------------------------------------
 ---                                     ---
 --- Handling of qualified names (QName) ---
 ---                                     ---
 -------------------------------------------
 -------------------------------------------

 SUBTYPE QNAME      IS VARCHAR2(4096);
 TYPE    QNAME_LIST IS TABLE OF QNAME INDEX BY BINARY_INTEGER;

 -- Construct a qualified name
 --   namespaceURI - Namespace URI for the QName, null if none.
 --      localPart - Local part of the QName
 function to_QName(name_Space VARCHAR2, name VARCHAR2) RETURN QNAME;

 -- Return the namespace URI of a qualified name, null if none.
 function get_namespace_URI(name QNAME) RETURN VARCHAR2;

 -- Return the local part of a qualified name
 function get_local_part(name QNAME) RETURN VARCHAR2;
 
 -- The following is a list of predefined namespaces that may be
 -- used in the name_Space parameter of to_QName
 -- 'NSURI_SCHEMA_XSD','xsd'        - Namespace URI for XML Schema XSD
 -- 'NSURI_SCHEMA_XSI','xsi'        - Namespace URI for XML Schema XSI
 -- 'NSURI_SOAP_ENCODING','soapenc' - Namespace URI for SOAP 1.1 Encoding
 -- 'NSURI_SOAP_ENVELOPE','soapenv' - Namespace URI for SOAP 1.1 Envelope
 -- 'NSURI_SOAP_NEXT_ACTOR'         - Namespace URI for SOAP 1.1 next actor role


 -------------------------------------------
 -------------------------------------------
 ---                                     ---
 --- Service instantiation based on WSDL ---
 ---                                     ---
 -------------------------------------------
 -------------------------------------------

 SUBTYPE SERVICE IS NUMBER;

 -- Create a Service instance.
 --   serviceName - QName for the service
 --   Returns a handle to the Service instance.
 function create_service(service_Name QNAME) RETURN SERVICE; 

 -- Create a Service instance.
 --   wsdlDocumentLocation - URL for the WSDL document location for the service
 --   serviceName - QName for the service
 --   Returns a handle to the Service instance.
 function create_service(wsdl_Document_Location URITYPE, service_Name QNAME) RETURN SERVICE;

 -- List the qualified names of all of the ports in a service.
 --    service_Handle - Service instance whose ports are returned
 function get_ports(service_Handle SERVICE) RETURN QNAME_LIST;

 -- List the qualified names of all of the operations on a particular
 --    service port.
 --    service_Handle - Service instance whose operations are returned
 --    port           - Qualified name of a service port. NULL if the
 --                     first port of the service is to be used.
 function get_operations(service_Handle SERVICE, port QNAME) RETURN QNAME_LIST;

 -- Release a particular Service instance. This will implicitly
 -- release all Call instances that have been created for this
 -- service instance.
 --    service_Handle - Service instance that is to be released
 procedure release_service(service_Handle SERVICE);

 -- Release all Service instances.
 procedure release_all_services;


 ---------------------------------------------
 ---------------------------------------------
 ---                                       ---
 --- Call instantiation based on a service ---
 ---     port and an operation name        ---
 ---                                       ---
 ---------------------------------------------
 ---------------------------------------------

 SUBTYPE CALL IS NUMBER;

 TYPE ANYDATA_LIST IS TABLE OF ANYDATA INDEX BY BINARY_INTEGER;

 
 -- Set the proxy address 
 --   proxy - the http proxy address, e.g., www-proxy.us.acme.com:80 
 procedure set_http_proxy(httpProxy VARCHAR2); 

-- Create a Call instance.
--   serviceHandle - the service instance that is to be called.
 function create_call(service_Handle SERVICE) RETURN CALL;

 -- Create a Call instance.
 --   serviceHandle - the service instance that is to be called.
 --   portName - qualified name for the port. Use first port if this is NULL.
 --   operationName - qualified name for the operation
 function create_call(service_Handle SERVICE, port_Name QNAME, operation_Name QNAME)
                      RETURN CALL;

 -- Release a particular Call instance.
 --    call_Handle - Call instance that is to be released
 procedure release_call(call_Handle CALL);

 -- Set the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   endpoint   - the endpoint for the call
 procedure set_target_endpoint_address(call_Handle CALL, endpoint VARCHAR2); 

 -- Manipulation of call properties. The following are supported keys
 -- and default settings for standard Call properties.
 --
 -- Key                 - Explanation of Value, Default value.
 -- 'USERNAME'          - User name for authentication 
 -- 'PASSWORD'          - Password for authentication 
 -- 'ENCODINGSTYLE_URI' - Encoding style specified as a namespace URI.
 --                       The default value is the SOAP 1.1 encoding
 --                       'http://schemas.xmlsoap.org/soap/encoding/'
 -- 'OPERATION_STYLE'   - Standard property for operation style.
 --                       Set to 'rpc' if the operation style is rpc;
 --                       'document' if the operation style is document. 
 -- 'SESSION_MAINTAIN'  - This boolean property is used by a service client to indicate whether or
 --                       not it wants to participate in a session with a service endpoint.
 --                       If this property is set to 'true', the service client indicates that it
 --                       wants the session to be maintained. If set to 'false', the session is
 --                       not maintained. The default value for this property is 'false'. 
 -- 'SOAPACTION_USE'    - This boolean property indicates whether or not SOAPAction
 --                       is to be used. The default value of this property is 'false'.
 -- 'SOAPACTION_URI'    - Indicates the SOAPAction URI if the SOAPACTION_USE property
 --                       is set to 'true'. 

 -- Return the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 --   Returns the value of the property or null if not set.
 function  get_property(call_Handle CALL, key VARCHAR2) RETURN VARCHAR2; 

 -- Set the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 --   value      - the value for the property
 procedure set_property(call_Handle CALL, key VARCHAR2, value VARCHAR2); 

 -- Clear the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 procedure remove_property(call_Handle CALL, key VARCHAR2); 

 -------------------------------------------------------------------
 -------------------------------------------------------------------
 -- The following list describes the supported XML types
 --
 -- XML Type                       SQL Type
 -------------------------------------------------------------------
 --
 -- xsd:string                     VARCHAR2
 -- soapenc:string
 --
 -- xsd:int, xsd:long, xsd:short,  NUMBER (no NULL permitted)
 -- xsd:float, xsd:double,         and related SQL types
 -- xsd:boolean
 -- soapenc:boolean, soapenc:float,
 -- soapenc:double, soapenc:int,
 -- soapenc:short, soapenc:byte,
 --
 -- xsd:integer, xsd:decimal,      NUMBER (NULL permitted)
 -- soapenc:decimal                and related SQL types
 -- 
 -- xsd:QName                      VARCHAR2
 --
 -- xsd:dateTime                   DATE, TIMESTAMP,
 --                                TIMESTAMP WITH TIMEZONE
 --                                TIMESTAMP WITH LOCAL TIMEZONE
 --
 -- xsd:base64Binary,              RAW
 -- xsd:hexBinary,
 -- soapenc:base64
 --
 -------------------------------------------------------------------
 -------------------------------------------------------------------
 
 -- List the XML type that is returned by the given call.
 --    call_Handle - Service instance whose return type is returned.
 function get_return_type(call_Handle CALL) RETURN QNAME;

 -- List the XML type of the input parameters of the given call.
 --    call_Handle - Service instance whose input types are returned.
 function get_in_parameter_types(call_Handle CALL) RETURN QNAME_LIST;

 -- List the XML type of the output parameters of the given call.
 --    call_Handle - Service instance whose output types are returned.
 function get_out_parameter_types(call_Handle CALL) RETURN QNAME_LIST;

 -- Invokes a specific operation using a synchronous request-response
 -- interaction mode.
 --   callHandle - the instance of the call
 --   inputParams - The input parameters for this invocation.
 --   Returns the return value or null.
 function invoke(call_Handle CALL, input_Params ANYDATA_LIST) return ANYDATA;

 -- Invokes a document-style webservices in a synchronous 
 -- request-response interaction mode.
 --   callHandle - the instance of the call
 --   request - a SOAPElement request
 --   Returns a SOAPElement response
 function invoke(call_Handle CALL, request SYS.XMLTYPE) return SYS.XMLTYPE;

 -- Obtain the output arguments after a call invocation
 --   callHandle - the instance of the call
 --   Returns the output arguments in order. 
 function get_output_values(call_Handle CALL) return ANYDATA_LIST;

 -- Set the type of a parameter of a Call.
 --   callHandle - the instance of the call
 --   xml_name - the xml name of the parameter type 
 --   q_name - the QNAME for the parameter type 
 --   mode - the ParameterMode mode constant 
 procedure add_parameter(call_Handle CALL, xml_name VARCHAR2, q_name QNAME, p_mode VARCHAR2); 

 -- Set the return type of a Call.
 --   callHandle - the instance of the call
 --   retType - the qname of the return type 
 procedure set_return_type(call_Handle CALL, ret_type QNAME);

end utl_dbws;
/

create or replace package body utl_dbws is

 --- Forward Declarations ---

 function invoke_proxy return VARCHAR2;
 function invoke_proxy(request SYS.XMLTYPE) return SYS.XMLTYPE;
 function create_service_proxy(wsdl_Document_Location VARCHAR2, service_Name VARCHAR2) return SERVICE;
 function get_services_proxy(wsdl_Document_Location VARCHAR2) RETURN VARCHAR2;
 function get_ports_proxy(service_Handle SERVICE) RETURN VARCHAR2;
 function get_operations_proxy(service_Handle SERVICE, port QNAME) RETURN VARCHAR2;
 function get_return_proxy(call_Handle CALL) RETURN VARCHAR2;
 function get_in_parameters_proxy(call_Handle CALL) RETURN VARCHAR2;
 function get_out_parameters_proxy(call_Handle CALL) RETURN VARCHAR2;
 procedure set_call(call_Handle CALL);
 function output_values(call_Handle CALL) return VARCHAR2;

 function split_string(s VARCHAR2) RETURN QNAME_LIST;
 function get_any(ch VARCHAR2) RETURN ANYDATA;
 function get_char RETURN VARCHAR2;
 function get_number RETURN NUMBER;
 function get_raw RETURN RAW;
 function get_date RETURN DATE;
 function get_timestamp RETURN TIMESTAMP;
 function get_timestamp_tz RETURN TIMESTAMP WITH TIME ZONE;
 function get_timestamp_ltz RETURN TIMESTAMP WITH LOCAL TIME ZONE;
 function get_boolean RETURN NUMBER;
 function get_byte RETURN NUMBER;
 function get_short RETURN NUMBER;
 function get_integer RETURN NUMBER;
 function get_long RETURN NUMBER;
 function get_float RETURN NUMBER;
 function get_double RETURN NUMBER;
 function get_clob RETURN CLOB;
 function get_blob RETURN BLOB;
 function get_bfile RETURN BFILE;
 function get_rowid RETURN ROWID;
 function get_xmltype RETURN XMLTYPE;

 procedure set_any(obj ANYDATA);
 procedure set_null;
 procedure set_null(c VARCHAR2);
 procedure set_char(c VARCHAR2);
 procedure set_number(n NUMBER);
 procedure set_raw(r RAW);
 procedure set_date(d DATE);
 procedure set_boolean(b NUMBER);
 procedure set_blob(b BLOB);
 procedure set_clob(c CLOB);
 procedure set_bfile(b BFILE);
 procedure set_rowid(r ROWID);
 procedure set_timestamp(d TIMESTAMP);
 procedure set_timestamp_tz(d TIMESTAMP WITH TIME ZONE);
 procedure set_timestamp_ltz(d TIMESTAMP WITH LOCAL TIME ZONE);
 procedure set_xmltype(x XMLTYPE);

 --- End Forward Declarations ---


 -------------------------------------------
 -------------------------------------------
 ---                                     ---
 --- Handling of qualified names (QName) ---
 ---                                     ---
 -------------------------------------------
 -------------------------------------------

 -- Construct a qualified name
 --   namespaceURI - Namespace URI for the QName, null if none.
 --      localPart - Local part of the QName
 function to_QName(name_Space VARCHAR2, name VARCHAR2) RETURN QNAME IS
 BEGIN
   if name_Space IS NULL or name_Space = ''
      then return name; 
   elsif name_Space = 'xsd' OR name_Space = 'NSURI_SCHEMA_XSD'
      then return '{http://www.w3.org/2001/XMLSchema}' || name;
   elsif name_Space = 'xsi' OR name_Space = 'NSURI_SCHEMA_XSI'
      then return '{http://www.w3.org/2001/XMLSchema-instance}' || name;
   elsif name_Space = 'soapenc' OR name_Space = 'NSURI_SOAP_ENCODING'
      then return '{http://schemas.xmlsoap.org/soap/encoding/}' || name;
   elsif name_Space = 'soapenv' OR name_Space = 'NSURI_SOAP_ENVELOPE'
      then return '{http://schemas.xmlsoap.org/soap/envelope/}' || name;
   elsif name_Space = 'NSURI_SOAP_NEXT_ACTOR'
      then return '{http://schemas.xmlsoap.org/soap/actor/next}' || name;
   else
      return '{' || name_Space || '}' || name;
   end if;
 END to_QName;

 -- Return the namespace URI of a qualified name, null if none.
 function get_namespace_URI(name QNAME) RETURN VARCHAR2 IS
   pos INTEGER;
 BEGIN
   pos := INSTR(name, '}');
   if pos = 0
      then return null;
      else return SUBSTR(name,2,pos-1);
   end if;
 END get_namespace_URI;

 -- Return the local part of a qualified name
 function get_local_part(name QNAME) RETURN VARCHAR2 IS
   pos INTEGER;
 BEGIN
   pos := INSTR(name, '}');
   if pos = 0
      then return name;
      else return SUBSTR(name,pos+1);
   end if;
 END get_local_part;
 
 -- The following is a list of predefined namespaces that may be
 -- used in the nameSpace parameter of to_QName
 -- 'NSURI_SCHEMA_XSD', 'xsd'        - Namespace URI for XML Schema XSD
 -- 'NSURI_SCHEMA_XSI', 'xsi'        - Namespace URI for XML Schema XSI
 -- 'NSURI_SOAP_ENCODING', 'soapenc' - Namespace URI for SOAP 1.1 Encoding
 -- 'NSURI_SOAP_ENVELOPE', 'soapenv' - Namespace URI for SOAP 1.1 Envelope
 -- 'NSURI_SOAP_NEXT_ACTOR'          - Namespace URI for SOAP 1.1 next actor role


 -------------------------------------------
 -------------------------------------------
 ---                                     ---
 --- Service instantiation based on WSDL ---
 ---                                     ---
 -------------------------------------------
 -------------------------------------------

 -- List the qualified names of all the services in a WSDL document
 --   wsdlDocumentLocation - URL for the WSDL document
 function get_services(wsdl_Document_Location URITYPE)
   RETURN QNAME_LIST
 IS
 BEGIN
   return split_string(get_services_proxy(wsdl_Document_Location.GETURL()));
 END get_services;

 function get_services_proxy(wsdl_Document_Location VARCHAR2) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getServices(java.lang.String) return java.lang.String';

 -- Create a Service instance.
 --   serviceName - QName for the service
 --   Returns a handle to the Service instance.
 function create_service(service_Name QNAME)
  RETURN SERVICE 
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.createService(java.lang.String) return long';

 -- Create a Service instance.
 --   wsdlDocumentLocation - URL for the WSDL document location for the service
 --   serviceName - QName for the service
 --   Returns a handle to the Service instance.
 function create_service(wsdl_Document_Location URITYPE, service_Name QNAME)
  RETURN SERVICE IS
 BEGIN
  RETURN create_service_proxy(wsdl_Document_Location.GETURL(), service_Name);
 END create_service;

 function create_service_proxy(wsdl_Document_Location VARCHAR2, service_Name VARCHAR2) return SERVICE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.createService(java.lang.String,java.lang.String) return long';


 -- Split a string into a list of QNAMES using ";" as separator.
 --    string - the string to be split
 function split_string(s VARCHAR2) RETURN QNAME_LIST
 IS
   res   QNAME_LIST;
   pos   INTEGER;
   idx   BINARY_INTEGER;
   strg  VARCHAR2(8128);
 BEGIN
   strg := s;

   pos := INSTR(strg,';');
   idx := 1;

   while (pos > 0)
   loop
     res(idx) := SUBSTR(strg,1,pos-1);
     idx := idx + 1; 
     strg := SUBSTR(strg,pos+1);
     pos := INSTR(strg,';');
   end loop;

   if strg IS NOT NULL
      then res(idx) := strg;
   end if;

   return res;
 END split_string;

 -- Set the proxy address 
 --   proxy - the http proxy address, e.g., www-proxy.us.acme.com:80 
 procedure set_http_proxy(httpProxy VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setHttpProxy(java.lang.String)';

 -- List the qualified names of all of the ports in a service.
 --    service_Handle - Service instance whose ports are returned
 function get_ports(service_Handle SERVICE)
   RETURN QNAME_LIST
 IS
 BEGIN
   return split_string(get_ports_proxy(service_Handle));
 END get_ports;

 function get_ports_proxy(service_Handle SERVICE) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getPorts(long) return java.lang.String';

 function get_operations(service_Handle SERVICE, port QNAME)
   RETURN QNAME_LIST
 IS
   res QNAME_LIST;
 BEGIN
   return split_string(get_operations_proxy(service_Handle,port));
   return res;
 END get_operations;

 function get_operations_proxy(service_Handle SERVICE, port QNAME) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getOperations(long,java.lang.String) return java.lang.String';


 -- Release a particular Service instance. This will implicitly
 -- release all Call instances that have been created for this
 -- service instance.
 --    service_Handle - Service instance that is to be released
 procedure release_service(service_Handle SERVICE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.releaseService(long)';

 -- Release all Service instances.
 procedure release_all_services
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.releaseAllServices()';


 ---------------------------------------------
 ---------------------------------------------
 ---                                       ---
 --- Call instantiation for document style ---
 ---                                       ---
 ---------------------------------------------
 ---------------------------------------------

 -- Create a Call instance.
 --   serviceHandle - the service instance that is to be called.
 function create_call(service_Handle SERVICE) RETURN CALL
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.createCall(long) return long';

 ---------------------------------------------
 ---------------------------------------------
 ---                                       ---
 --- Call instantiation based on a service ---
 ---     port and an operation name        ---
 ---                                       ---
 ---------------------------------------------
 ---------------------------------------------

 -- Create a Call instance.
 --   serviceHandle - the service instance that is to be called.
 --   portName - qualified name for the port. Use first port if this is NULL.
 --   operationName - qualified name for the operation
 function create_call(service_Handle SERVICE, port_Name QNAME, operation_Name QNAME) RETURN CALL
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.createCall(long,java.lang.String,java.lang.String) return long';

 -- Release a particular Call instance.
 --    call_Handle - Call instance that is to be released
 procedure release_call(call_Handle CALL)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.releaseCall(long)';

 -- Set the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   endpoint   - the endpoint for the call
 procedure set_target_endpoint_address(call_Handle CALL, endpoint VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setTargetEndpointAddress(long,java.lang.String)';

 -- Manipulation of call properties. The following are supported keys
 -- and default settings for standard Call properties.
 --
 -- Key                 - Explanation of Value, Default value.
 -- 'USERNAME'          - User name for authentication 
 -- 'PASSWORD'          - Password for authentication 
 -- 'ENCODINGSTYLE_URI' - Encoding style specified as a namespace URI.
 --                       The default value is the SOAP 1.1 encoding
 --                       'http://schemas.xmlsoap.org/soap/encoding/'
 -- 'OPERATION_STYLE'   - Standard property for operation style.
 --                       Set to 'rpc' if the operation style is rpc;
 --                       'document' if the operation style is document. 
 -- 'SESSION_MAINTAIN'  - This boolean property is used by a service client to indicate whether or
 --                       not it wants to participate in a session with a service endpoint.
 --                       If this property is set to 'true', the service client indicates that it
 --                       wants the session to be maintained. If set to 'false', the session is
 --                       not maintained. The default value for this property is 'false'. 
 -- 'SOAPACTION_USE'    - This boolean property indicates whether or not SOAPAction
 --                       is to be used. The default value of this property is 'false'.
 -- 'SOAPACTION_URI'    - Indicates the SOAPAction URI if the SOAPACTION_USE property
 --                       is set to 'true'. 

 -- Return the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 --   Returns the value of the property or null if not set.
 function  get_property(call_Handle CALL, key VARCHAR2) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getProperty(long,java.lang.String) return java.lang.String';

 -- Set the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 --   value      - the value for the property
 procedure set_property(call_Handle CALL, key VARCHAR2, value VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setProperty(long,java.lang.String,java.lang.String)';

 -- Clear the value of a particular property on a Call.
 --   callHandle - the instance of the call
 --   key        - the key for the property
 procedure remove_property(call_Handle CALL, key VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.removeProperty(long,java.lang.String,java.lang.String)';

 -- Return the XML type of the call's return value
 --   callHandle - the instance of the call
 function get_return_type(call_Handle CALL) RETURN QNAME IS
 BEGIN
   return get_return_proxy(call_Handle);
 END get_return_type;

 function get_return_proxy(call_Handle CALL) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getReturnTypeProxy(long) return java.lang.String';

 -- Return the XML types of the call's input parameters
 --   callHandle - the instance of the call
 function get_in_parameter_types(call_Handle CALL) RETURN QNAME_LIST IS
 BEGIN
   return split_string(get_in_parameters_proxy(call_Handle));
 END get_in_parameter_types;

 function get_in_parameters_proxy(call_Handle CALL) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getInParametersProxy(long) return java.lang.String';

 -- Return the XML types of the call's output parameters
 --   callHandle - the instance of the call
 function get_out_parameter_types(call_Handle CALL) RETURN QNAME_LIST IS
 BEGIN
   return split_string(get_out_parameters_proxy(call_Handle));
 END get_out_parameter_types;

 function get_out_parameters_proxy(call_Handle CALL) RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getOutParametersProxy(long) return java.lang.String';

 -- Invokes a specific operation using a synchronous request-response
 -- interaction mode.
 --   callHandle - the instance of the call
 --   inputParams - The input parameters for this invocation.
 --   Returns the return value or null.
 function invoke(call_Handle CALL, input_Params ANYDATA_LIST) return ANYDATA
 IS 
   idx BINARY_INTEGER;
 BEGIN
   set_call(call_Handle);

   if input_Params.COUNT != 0
   then
     idx := input_Params.FIRST;
     set_any(input_Params(idx));
     while idx != input_Params.LAST
     loop
       idx := input_Params.NEXT(idx);
       set_any(input_Params(idx));
     end loop;
   end if;

   return get_any(invoke_proxy);
 END invoke;

 function invoke_proxy return VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.invokeProxy() return java.lang.String';


 -- Invokes a Document-style webservices in a synchronous 
 -- request-response interaction mode.
 --   callHandle - the instance of the call
 --   request - a SOAPElement request
 --   Returns a SOAPElement response
 function invoke(call_Handle CALL, request SYS.XMLTYPE) return SYS.XMLTYPE IS
 BEGIN
   set_call(call_Handle);
   return invoke_proxy(request);
 END invoke;

 function invoke_proxy (request SYS.XMLTYPE) return SYS.XMLTYPE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.invokeProxy(oracle.xdb.XMLType) return oracle.xdb.XMLType';

 -- Obtain the output arguments after a call invocation
 --   callHandle - the instance of the call
 --   Returns the output arguments in order. 
 function get_output_values(call_Handle CALL) return ANYDATA_LIST
 IS
   res   ANYDATA_LIST;
   len   INTEGER;
   cnt   INTEGER;
   outs  VARCHAR2(4096);
   ch    VARCHAR2(1);
 BEGIN
   cnt := 1;
   outs := output_values(call_Handle);
   len := LENGTH(outs);
   while cnt <= len
   loop
     ch := SUBSTR(outs,len,1);
     res(cnt) := get_any(ch);
     cnt := cnt+1;
   end loop;
   return res;
 END get_output_values;

 function get_any(ch VARCHAR2) RETURN ANYDATA IS
 BEGIN
   if (ch = null) OR (ch = 'Z')
      then return NULL;
   elsif ch = 'N'
      then return ANYDATA.ConvertNumber(get_number());
   elsif ch = 'C'
      then return ANYDATA.ConvertVarchar2(get_char());
   elsif ch = 'D'
      then return ANYDATA.ConvertDate(get_date());
   elsif ch = 'R'
      then return ANYDATA.ConvertRaw(get_raw());
   elsif ch = 'B'
      then return ANYDATA.ConvertBlob(get_blob());
   elsif ch = 'L'
      then return ANYDATA.ConvertClob(get_clob());
   elsif ch = 'F'
      then return ANYDATA.ConvertBfile(get_bfile());

   elsif ch = 'Y'
      then return ANYDATA.ConvertNumber(get_byte());
   elsif ch = 'S'
      then return ANYDATA.ConvertNumber(get_short());
   elsif ch = 'I'
      then return ANYDATA.ConvertNumber(get_integer());
   elsif ch = 'G'
      then return ANYDATA.ConvertNumber(get_long());
   elsif ch = 'O'
      then return ANYDATA.ConvertNumber(get_float());
   elsif ch = 'P'
      then return ANYDATA.ConvertNumber(get_double());

   /*
   elsif ch = 'O'
      then return ANYDATA.ConvertObject(get_object());
   elsif ch = '^'
      then return ANYDATA.ConvertRef(get_ref());
   elsif ch = '@'
      then return ANYDATA.ConvertCollection(get_collection());
   */
   end if;

   return NULL; -- Should throw an exception?!
 END get_any;

 procedure set_any(obj ANYDATA) IS
  nr NUMBER;
  v2 VARCHAR2(32767);
  de DATE;
  rw RAW(32767);
  bb BLOB;
  cb CLOB;
  be BFILE;
  cr CHAR;
  vr VARCHAR(32767);
  name VARCHAR2(32767);
 BEGIN
   if obj IS NULL
   then set_null;
   else
     name := obj.GetTypeName;
     if name = 'SYS.NUMBER'
        then  set_number(obj.accessNumber);
     elsif name = 'SYS.VARCHAR2'
        then  set_char(obj.accessVarchar2);
     elsif name = 'SYS.DATE'
        then  set_date(obj.accessDate);
     elsif name = 'SYS.RAW'
        then  set_raw(obj.accessRaw);
     elsif name = 'SYS.BLOB'
        then  set_blob(obj.accessBlob);
     elsif name = 'SYS.CLOB'
        then  set_clob(obj.accessClob);
     elsif name = 'SYS.BFILE'
        then  set_bfile(obj.accessBfile);
     elsif name = 'SYS.CHAR'
        then  set_char(obj.accessChar);
     elsif name = 'SYS.VARCHAR'
        then  set_char(obj.accessVarchar);
     else
        set_null(name);
     /*
     elsif name = <OBJECT>
       then
     elsif name = <REF>
       then
     elsif name = <COLLECTION>
       then
     */
     end if;
   end if;
 END set_any;

 function output_values(call_Handle CALL) return VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.outputValues(long) return java.lang.String';

 -- Set the type of a parameter of a Call.
 --   callHandle - the instance of the call
 --   xml_name - the xml name of the parameter type 
 --   q_name - the QNAME for the parameter type 
 --   mode - the ParameterMode mode constant 
 procedure add_parameter(call_Handle CALL, xml_name VARCHAR2, q_name QNAME, p_mode VARCHAR2)
 as language java
 name 'oracle.jpub.runtime.dbws.DbwsProxy.addParameter(long,java.lang.String, java.lang.String,java.lang.String)';

 -- Set the return type of a Call.
 --   callHandle - the instance of the call
 --   retType - the qname of the return type 
 procedure set_return_type(call_Handle CALL, ret_type QNAME)
 as language java
 name 'oracle.jpub.runtime.dbws.DbwsProxy.setReturnType(long,java.lang.String)';


 --------------------
 -- Initialization --
 --------------------

 procedure set_call(call_Handle CALL)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setCall(long)';
 
 -------------
 -- Setters --
 -------------

 procedure set_null
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setNull()';

 procedure set_null(c VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setNull(java.lang.String)';

 procedure set_char(c VARCHAR2)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setChar(java.lang.String)';

 procedure set_number(n NUMBER)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setBigDecimal(java.math.BigDecimal)';

 procedure set_raw(r RAW)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setRaw(byte[])';

 procedure set_date(d DATE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setDate(oracle.sql.DATE)';

 procedure set_boolean(b NUMBER)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setBoolean(int)';

 procedure set_blob(b BLOB)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setBlob(oracle.sql.BLOB)';

 procedure set_clob(c CLOB)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setClob(oracle.sql.CLOB)';

 procedure set_bfile(b BFILE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setBfile(oracle.sql.BFILE)';

 procedure set_rowid(r ROWID)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setRowid(oracle.sql.ROWID)';

 procedure set_timestamp(d TIMESTAMP)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setTimestamp(oracle.sql.TIMESTAMP)';

 procedure set_timestamp_tz(d TIMESTAMP WITH TIME ZONE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setTimestampTZ(oracle.sql.TIMESTAMPTZ)';

 procedure set_timestamp_ltz(d TIMESTAMP WITH LOCAL TIME ZONE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setTimestampLTZ(oracle.sql.TIMESTAMPLTZ)';

 procedure set_xmltype(x XMLTYPE)
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.setXmltype(oracle.sql.OPAQUE)';

 -------------
 -- Getters --
 -------------
 function get_char RETURN VARCHAR2
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getChar() return java.lang.String';

 function get_number RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getBigDecimal() return java.math.BigDecimal';

 function get_raw RETURN RAW
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getRaw() return byte[]';

 function get_date RETURN DATE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getDate() return oracle.sql.DATE';

 function get_timestamp RETURN TIMESTAMP
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getTimestamp() return oracle.sql.TIMESTAMP';

 function get_timestamp_tz RETURN TIMESTAMP WITH TIME ZONE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getTimestampTZ() return oracle.sql.TIMESTAMPTZ';

 function get_timestamp_ltz RETURN TIMESTAMP WITH LOCAL TIME ZONE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getTimestampLTZ() return oracle.sql.TIMESTAMPLTZ';

 function get_boolean RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getBoolean() return int';

 function get_byte RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getByte() return Byte';

 function get_short RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getShort() return Short';

 function get_integer RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getInteger() return Integer';

 function get_long RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getLong() return Long';

 function get_float RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getFloat() return Float';

 function get_double RETURN NUMBER
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getDouble() return Double';


 function get_blob RETURN BLOB
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getBlob() return oracle.sql.BLOB';

 function get_clob RETURN CLOB
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getClob() return oracle.sql.CLOB';

 function get_bfile RETURN BFILE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getBfile() return oracle.sql.BFILE';

 function get_rowid RETURN ROWID
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getRowid() return oracle.sql.ROWID';

 function get_xmltype RETURN XMLTYPE
 as language java
    name 'oracle.jpub.runtime.dbws.DbwsProxy.getXmltype() return oracle.sql.OPAQUE';

end utl_dbws;
/

grant execute on utl_dbws to public ;

