variable jvmrmaction varchar2(30)
execute :jvmrmaction := 'FULL_REMOVAL';
@@jvmrmdbj

create or replace package dbms_java authid current_user as

  PROCEDURE server_startup;

  PROCEDURE server_shutdown;

  PROCEDURE notify_at_startup(user_schema VARCHAR2, classname VARCHAR2);

  PROCEDURE notify_at_shutdown(user_schema VARCHAR2, classname VARCHAR2);

  PROCEDURE remove_from_startup(user_schema VARCHAR2, classname VARCHAR2);

  PROCEDURE remove_from_shutdown(user_schema VARCHAR2, classname VARCHAR2);

  -- for use in jvmrm for downgrade
  PROCEDURE aurora_shutdown;

  PROCEDURE kprb_value;

  PROCEDURE start_btl;

  PROCEDURE stop_btl;

  PROCEDURE terminate_btl;

  FUNCTION init_btl(files_prefix VARCHAR2, type NUMBER,
                    sample_limit NUMBER, exclude_java NUMBER) return NUMBER;
  pragma restrict_references(init_btl, wnds, wnps);

  FUNCTION get_endpoint_status(host_name VARCHAR2, port NUMBER, pres VARCHAR2) return NUMBER;

  FUNCTION unregister_endpoint(host_name VARCHAR2, port NUMBER, pres VARCHAR2) return NUMBER;

  FUNCTION unique_table_name (prefix VARCHAR2) return VARCHAR2;
  pragma restrict_references(unique_table_name, wnds, wnps);

  FUNCTION longname (shortname VARCHAR2) return VARCHAR2;
  pragma restrict_references(longname, wnds, wnps);

  FUNCTION shortname (longname VARCHAR2) RETURN VARCHAR2;
  pragma restrict_references(shortname, wnds, wnps);

  -- functions and procedures to manipulate the compiler option table
  -- what refers to a source name, package or class depending
  
  -- determine the option value for option optionName applied to 
  -- what
  FUNCTION get_compiler_option(what VARCHAR2, optionName VARCHAR2)
    return varchar2 ;
  pragma restrict_references (get_compiler_option, wnds, wnps);

  -- set the option value to value for option optionName applied to
  -- what.  And depending upon the characteristics of optionName 
  -- it may apply to "descendants" of what as well.
  PROCEDURE set_compiler_option(what VARCHAR2, optionName VARCHAR2, value VARCHAR2);

  -- reset the option value. That is, undo an action performed by
  -- set_compiler_option
  PROCEDURE reset_compiler_option(what VARCHAR2, optionName VARCHAR2);
  

  FUNCTION initGetSourceChunks (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
    RETURN NUMBER;
  pragma restrict_references(initGetSourceChunks, wnds);

  FUNCTION getSourceChunk RETURN VARCHAR2;
  pragma restrict_references(getSourceChunk, wnds);

  FUNCTION resolver (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2;
  pragma restrict_references(resolver, wnds);
 
  FUNCTION derivedFrom (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2;
  pragma restrict_references(derivedFrom, wnds);
 
  FUNCTION fixed_in_instance (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN NUMBER;
  pragma restrict_references(fixed_in_instance, wnds);

  PROCEDURE set_fixed_in_instance (name VARCHAR2, owner VARCHAR2,
                                   type VARCHAR2, value NUMBER);

  PROCEDURE set_output (buffersize NUMBER);

  -- import/export interface --
  function start_export(short_name in varchar2, 
                        schema in varchar2, 
                        flags in number,
                        type in number,
                        properties out number,
                        raw_chunk_count out number, 
                        total_raw_byte_count out number,
                        text_chunk_count out number, 
                        total_text_byte_count out number)
         return number;
  pragma restrict_references(start_export, wnds);

  function export_raw_chunk(chunk out raw, length out number)
           return number;
  pragma restrict_references(export_raw_chunk, wnds);

  function export_text_chunk(chunk out varchar2, length out number)
           return number;
  pragma restrict_references(export_text_chunk, wnds);


  function end_export return number;
  pragma restrict_references(end_export, wnds);


  function start_import(long_name in varchar2, 
                        flags in number,
                        type in number,
                        properties in number,
                        raw_chunk_count in number, 
                        total_raw_byte_count in number,
                        text_chunk_count in number)
         return number;
  pragma restrict_references(start_import, wnds);


  function import_raw_chunk(chunk in raw, length in number)
           return number;
  pragma restrict_references(import_raw_chunk, wnds);


  function import_text_chunk(chunk in varchar2, length in number)
           return number;
  pragma restrict_references(import_text_chunk, wnds);


  function end_import return number;
  pragma restrict_references(end_import, wnds);


  procedure set_streams(buffer_size in number);


  -- debugging interface -- 
  procedure start_debugging(host varchar2, port number, timeout number);
  procedure stop_debugging;
  procedure restart_debugging(timeout number);

  -- Put this first to defeat a bug that shows up when the SQL string
  -- following as language java name in some method spec is longer than
  -- that in the first method spec

  -- grant or revoke execute via Handle methods.  Needed with system class
  -- loading since SQL grant/revoke can't manipulate permanently kept objects
  procedure set_execute_privilege(object_name   varchar2,
                                  object_schema varchar2,
                                  object_type   varchar2,
                                  grantee_name  varchar2,
                                  grant_if_nonzero number)
  as language java name
  'oracle.aurora.rdbms.DbmsJava.setExecutePrivilege(java.lang.String,
                                                    oracle.sql.CHAR,
                                                    java.lang.String,
                                                    oracle.sql.CHAR,
                                                    boolean)';
                                    
  -- convenience functions to support development environments --
  -- There procedures allow PL/SQL to get at Java Schem Objects.
  -- There are a lot of them, but they can be understood from the
  -- grammar
  --     export_<what>(name, [schema,] lob)
  --
  -- <what> is either source, class or resource
  -- name a varchar argument that is the name of the java schema object
  -- schema is an optional argument, if it is present it is a varchar that
  --   names a schema, if it ommitted the current schema is used
  -- lob is either a BLOB or CLOB.  The contents of the object are placed
  --   into it. CLOB's are allowed only for source and resource (i.e. not
  --   for class). Note that the internal representation of source uses
  --   UTF8 and that is what is stored into the BLOB
  --
  -- If the java schema object does not exist an ORA-29532 (Uncaught Java
  -- exception) will occur.


  procedure export_source(name varchar2, schema varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_source(name varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, oracle.sql.BLOB)';

  procedure export_source(name varchar2, schema varchar2, clob CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, java.lang.String, oracle.sql.CLOB)';

  procedure export_source(name varchar2, CLOB clob)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportSource(java.lang.String, oracle.sql.CLOB)';

  procedure export_class(name varchar2, schema varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportClass(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_class(name varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportClass(java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, schema varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, blob BLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, oracle.sql.BLOB)';

  procedure export_resource(name varchar2, schema varchar2, clob CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, java.lang.String, oracle.sql.CLOB)';

  procedure export_resource(name varchar2, clob CLOB)
  as language java name 
  'oracle.aurora.rdbms.ExportSchemaObjects.exportResource(java.lang.String, oracle.sql.CLOB)';

  procedure loadjava(options varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String)';

  procedure loadjava(options varchar2, resolver varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String, java.lang.String)';

  procedure loadjava(options varchar2, resolver varchar2, status OUT number)
  as language java name
  'oracle.aurora.server.tools.loadjava.LoadJavaMain.serverMain(java.lang.String, java.lang.String, int[])';

  procedure dropjava(options varchar2)
  as language java name
  'oracle.aurora.server.tools.loadjava.DropJavaMain.serverMain(java.lang.String)';

  -- handleMd5 accesses information about schema objects that 
  -- is needed by loadjava
  function handleMd5(s varchar2, name varchar2, type number) return raw
  as language java name
  'oracle.aurora.server.tools.loadjava.HandleMd5.get
     (java.lang.String,java.lang.String,int) return oracle.sql.RAW';

  -- variant that looks in current schema
  function handleMd5(name varchar2, type number) return raw
  as language java name
  'oracle.aurora.server.tools.loadjava.HandleMd5.get
     (java.lang.String,int) return oracle.sql.RAW';

  -- interface to manage Security Policy Table

  -- create an active row in the policy table granting the Permission
  -- as specified to grantee.  If a row already exists granting the
  -- exact Permission specified then the table is unmodifed. 
  -- If a row exists but is disabled then it is enabled.
  -- Finally if no row exists one is inserted.
  --
  -- the table 
  -- grantee is the name of a schema
  -- permission_type is the fully qualified name of a class that
  --    extends java.lang.security.Permission.  If the class does
  --    not have a public synonymn then the name should be prefixed
  --    by <schema>:.  For example 'myschema:scott.MyPermission'.
  -- permission_name is the name of the permission
  -- permission_action is the action of the permission
  -- key is set to the key of the created row or to -1 if an
  --    error occurs.
  --
  -- See ... for more details of the Security Policy Table

  procedure grant_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2,
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grant(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';

  -- similar to grant except create a restrict row.
  procedure restrict_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2,
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.restrict(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';


  
  -- special case for granting PolicyTablePermission's.  The name of
  -- a PolicyTablePermission allows updates of rows relating to
  -- a particular type (i.e. class that extends Permission) to 
  -- specify the class you must specify the schema containing the
  -- class. In the table that is stored as the user number, but this
  -- procedure lets it be specified via a name.
  procedure grant_policy_permission(
        grantee varchar2, 
        permisssion_schema varchar2, permission_type varchar2, 
        permission_name varchar2, 
        key OUT number)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grantPolicyPermission(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String, long[])';

  -- The follwing versions of grant_permission, restrict_permission
  -- and grant_policy permission are identical to the previous
  -- versions except that they do not have the key OUT parameter.

  procedure grant_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grant(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  procedure restrict_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.restrict(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  procedure grant_policy_permission(
        grantee varchar2, 
        permisssion_schema varchar2, permission_type varchar2, 
        permission_name varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.grantPolicyPermission(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';

  -- revoke disables any permissions that might have been granted
  procedure revoke_permission(
        grantee varchar2, permission_type varchar2, 
        permission_name varchar2, permission_action varchar2)
  as language java name 
  'oracle.aurora.rdbms.security.PolicyTableManager.revoke(
       java.lang.String, java.lang.String, java.lang.String, 
       java.lang.String)';
 
  -- enable the existing row with specified key
  procedure enable_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.enable(long)';

  -- disable the existing row with specified key
  procedure disable_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.disable(long)';
  
  -- delete the existing row with specified key
  -- the row must be diabled, if it is still active then this
  -- procedure does nothing.
  procedure delete_permission(key number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.delete(long)';

  -- set debugging level 
  procedure set_permission_debug(level number)
  as language java name
  'oracle.aurora.rdbms.security.PolicyTableManager.setDebugLevel(int)';
    
  -- turn byte code verifier on or off for current session
  -- 0 is off, 1 is on
  -- you need JServerPermission("Verifier") to do this operation
  procedure set_verifier(flag number) 
  as language java name
  'oracle.aurora.rdbms.Compiler.sessionOptionController(int)';
  
  function option_controller(opt number, action number) return number
  as language java name
  'oracle.aurora.rdbms.Compiler.optionController(int, int) return boolean';
  
  -- turn system class loading on or off for current session
  -- 0 is off, 1 is on
  -- you need to be running as SYS to do this operation
  procedure set_system_class_loading(flag number);

  -- The following functions are used by loadjava

  -- starts the actions of copying a file to the server.
  -- b is used repeatedly to copy chuncks.
  procedure deploy_open(filename varchar, b out BLOB) 
  as language java name 
  'oracle.aurora.server.tools.loadjava.Deploy.open(java.lang.String, oracle.sql.BLOB[])' ;

  -- copys a chunk out of the BLOB
  procedure deploy_copy(b BLOB) 
  as language java name 'oracle.aurora.server.tools.loadjava.Deploy.copy(oracle.sql.BLOB)';

  -- closes file and BLOB
  procedure deploy_close
  as language java name 'oracle.aurora.server.tools.loadjava.Deploy.close()';

  -- invokes the a deployed class
  function deploy_invoke(schema varchar, classname varchar) return varchar
  as language java name 'oracle.aurora.server.tools.loadjava.Deploy.invoke(java.lang.String, java.lang.String) return java.lang.String' ;

  -- Send command chunks to shell
  procedure send_command (chunk long raw);

  -- Get reply chunks  from shell
  function get_reply return long raw;

  -- add a preference to the database
  -- user     user schema name
  -- type     U for user or S for system
  -- abspath  absolute path of the preference
  -- key      key for value lookup
  -- value    value to be stored (string) 
  procedure set_preference(user varchar2,type varchar2, abspath varchar2,
                           key varchar2, value varchar2);

  function ncomp_status_msg return VARCHAR2 as language java name
  'oracle.aurora.rdbms.DbmsJava.ncompEnabledMsg() return java.lang.String';

  function full_ncomp_enabled return VARCHAR2;

end;
/

create or replace package body dbms_java as

  PROCEDURE server_startup as language java name
    'oracle.aurora.rdbms.Server.serverStartup()' ;

  PROCEDURE server_shutdown as language java name
    'oracle.aurora.rdbms.Server.serverShutdown()' ;

  PROCEDURE notify_at_startup(user_schema VARCHAR2, classname VARCHAR2)
    as language java name
    'oracle.aurora.rdbms.Server.notify_at_startup(java.lang.String, java.lang.String)';

  PROCEDURE notify_at_shutdown(user_schema VARCHAR2, classname VARCHAR2)
    as language java name
    'oracle.aurora.rdbms.Server.notify_at_shutdown(java.lang.String, java.lang.String)';

  PROCEDURE remove_from_startup(user_schema VARCHAR2, classname VARCHAR2)
    as language java name
    'oracle.aurora.rdbms.Server.remove_from_startup(java.lang.String, java.lang.String)';

  PROCEDURE remove_from_shutdown(user_schema VARCHAR2, classname VARCHAR2)
    as language java name
    'oracle.aurora.rdbms.Server.remove_from_shutdown(java.lang.String, java.lang.String)';

  -- for use in jvmrm for downgrade
  PROCEDURE aurora_shutdown
    as language java name
    'oracle.aurora.net.DynamicRegistration.aurora_shutdown()';


  PROCEDURE kprb_value as language java name
    'oracle.aurora.rdbms.DbmsJava.kprb_value()' ;

  PROCEDURE start_btl as language java name
    'oracle.aurora.perf.OracleBTL.startBTL()';

  PROCEDURE stop_btl as language java name
    'oracle.aurora.perf.OracleBTL.stopBTL()';

  PROCEDURE terminate_btl as language java name
    'oracle.aurora.perf.OracleBTL.terminateBTL()';

  FUNCTION init_btl(files_prefix VARCHAR2, type NUMBER,
                    sample_limit NUMBER, exclude_java NUMBER) return NUMBER as language java name
  'oracle.aurora.perf.OracleBTL.initBTL(java.lang.String, int, long, boolean)
          return boolean';

  FUNCTION get_endpoint_status(host_name VARCHAR2, port number, pres VARCHAR2) return NUMBER as language java name
  'oracle.aurora.net.DynamicRegistration.getEndpointStatus(java.lang.String, short, java.lang.String)
          return int';

  FUNCTION unregister_endpoint(host_name VARCHAR2, port number, pres VARCHAR2) return NUMBER as language java name
  'oracle.aurora.net.DynamicRegistration.unregisterEndpoint(java.lang.String, short, java.lang.String)
          return int';

-- This function generates a server wide unique name
-- using the prefix provided
  FUNCTION unique_table_name (prefix varchar2) RETURN VARCHAR2 as language java name
  'oracle.aurora.rdbms.DbmsJava.uniqueTableName(java.lang.String)
          return java.lang.String';

  FUNCTION longname (shortname VARCHAR2) RETURN VARCHAR2 as language java name
    'oracle.aurora.rdbms.DbmsJava.longNameForSQL(java.lang.String)
          return java.lang.String';

  FUNCTION shortname (longname VARCHAR2) RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.shortName(java.lang.String)
           return java.lang.String';

  FUNCTION get_compiler_option(what VARCHAR2, optionName VARCHAR2)
    RETURN varchar2
    as language java name 
    'oracle.aurora.jdkcompiler.CompilerOptions.get(java.lang.String, java.lang.String) return java.lang.String' ;

  PROCEDURE set_compiler_option(what VARCHAR2, optionName VARCHAR2, value VARCHAR2)
  as language java name
  'oracle.aurora.jdkcompiler.CompilerOptions.set(java.lang.String, java.lang.String, java.lang.String)' ;


  PROCEDURE reset_compiler_option(what VARCHAR2, optionName VARCHAR2)
  as language java name
  'oracle.aurora.jdkcompiler.CompilerOptions.reset(java.lang.String, java.lang.String)' ;


  FUNCTION initGetSourceChunks (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
    RETURN NUMBER as language java name
     'oracle.aurora.rdbms.DbmsJava.initGetSourceChunks(java.lang.String,
                                                       oracle.sql.CHAR,
                                                       java.lang.String)
           return int';

  FUNCTION getSourceChunk RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.getSourceChunk() return oracle.sql.CHAR';

  FUNCTION resolver (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.resolver(java.lang.String,
                                            oracle.sql.CHAR,
                                            java.lang.String)
             return oracle.sql.CHAR';
 
  FUNCTION derivedFrom (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN VARCHAR2 as language java name
     'oracle.aurora.rdbms.DbmsJava.derivedFrom(java.lang.String,
                                               oracle.sql.CHAR,
                                               java.lang.String)
             return java.lang.String';

  FUNCTION fixed_in_instance (name VARCHAR2, owner VARCHAR2, type VARCHAR2)
     RETURN NUMBER as language java name
     'oracle.aurora.rdbms.DbmsJava.fixedInInstance(java.lang.String,
                                                   oracle.sql.CHAR,
                                                   java.lang.String)
             return boolean';

  PROCEDURE set_fixed_in_instance (name VARCHAR2, owner VARCHAR2,
                                   type VARCHAR2, value NUMBER)
     as language java name
     'oracle.aurora.rdbms.DbmsJava.setFixedInInstance(java.lang.String,
                                                      oracle.sql.CHAR,
                                                      java.lang.String,
                                                      boolean)';

  PROCEDURE set_output (buffersize NUMBER) as language java name
     'oracle.aurora.rdbms.DbmsJava.setOutput (int)';

  -- import/export interface --
  function start_export(short_name in varchar2, 
                        schema in varchar2, 
                        flags in number,
                        type in number,
                        properties out number,
                        raw_chunk_count out number, 
                        total_raw_byte_count out number,
                        text_chunk_count out number, 
                        total_text_byte_count out number)
         return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         startExport(oracle.sql.CHAR, oracle.sql.CHAR,
                                     int, int, int[], int[], int[], int[],
                                     int[])
                                  return int';

  function export_raw_chunk(chunk out raw, length out number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         exportRawChunk(byte[][], int[]) return int';

  function export_text_chunk(chunk out varchar2, length out number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         exportTextChunk(oracle.sql.CHAR[], int[]) return int';

  function end_export return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.endExport() return int';

  function start_import(long_name in varchar2, 
                        flags in number,
                        type in number,
                        properties in number,
                        raw_chunk_count in number, 
                        total_raw_byte_count in number,
                        text_chunk_count in number)
         return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         startImport(oracle.sql.CHAR,
                                     int, int, int, int, int, int)
                                    return int';
  function import_raw_chunk(chunk in raw, length in number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         importRawChunk(byte[], int) return int';

  function import_text_chunk(chunk in varchar2, length in number)
           return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.
                         importTextChunk(oracle.sql.CHAR, int) return int';

  function end_import return number
  as language java name 'oracle.aurora.rdbms.DbmsJava.endImport() return int';

  procedure set_streams(buffer_size in number) 
  as language java name 'oracle.aurora.rdbms.DbmsJava.setStreams(int)';


  -- debugging interface --
  
  procedure start_debugging(host varchar2, port number, timeout number)
  as language java name 'oracle.aurora.debug.OracleAgent.start
                         (java.lang.String, int, long)';

  procedure stop_debugging
  as language java name 'oracle.aurora.debug.OracleAgent.stop()';

  procedure restart_debugging(timeout number)
  as language java name 'oracle.aurora.debug.OracleAgent.restart(long)';

  -- Send command chunks to shell
  procedure send_command (chunk long raw)
  as language java name
  'oracle.aurora.server.tools.shell.ShellStoredProc.receive_command (byte[])';

  -- Get reply chunks from shell
  function get_reply return long raw
  as language java name
  'oracle.aurora.server.tools.shell.ShellStoredProc.get_reply () return byte[]';

  -- set a preference for the database
  procedure set_preference(user varchar2,type varchar2, abspath varchar2,
                           key varchar2, value varchar2)
  as language java name 
  'java.util.prefs.OraclePreferences.DbmsSetPreference(
        java.lang.String, java.lang.String, java.lang.String,
        java.lang.String, java.lang.String)';

  -- turn system class loading on or off for current session
  -- 0 is off, 1 is on
  -- you need to be running as SYS to do this operation
  procedure set_system_class_loading(flag number)
  as 
  x number := 3;
  begin
    if flag = 1 then x := 2; end if;
    x := option_controller(4, x);
  exception
  when others then
  if sqlcode not in (-29549) then raise; end if;
  end;

  function full_ncomp_enabled return VARCHAR2
  as
  foo exception;
  x varchar2(100) := ncomp_status_msg;
  pragma exception_init(foo,-29558);
  begin
    if x = 'NComp status: DISABLED' then raise foo; end if;
    return 'OK';
  end;

end;
/

CREATE PUBLIC SYNONYM dbms_java FOR dbms_java;

GRANT EXECUTE ON dbms_java TO PUBLIC;

--- The following is redundant but needed for the time being by existing
--- code, so leave it alone:

create or replace
FUNCTION dbj_long_name (shortname VARCHAR2) RETURN VARCHAR2 
as language java name
    'oracle.aurora.rdbms.DbmsJava.longNameForSQL(java.lang.String)
          return java.lang.String';
/

create or replace function "NameFromLastDDL" (longp number) return varchar2 as 
language java name 'oracle.aurora.rdbms.DbmsJava.NameFromLastDDL(boolean) return oracle.sql.CHAR';
/

CREATE PUBLIC SYNONYM "NameFromLastDDL" FOR sys."NameFromLastDDL";

GRANT EXECUTE ON "NameFromLastDDL" TO PUBLIC;


create or replace FUNCTION dbj_short_name (longname VARCHAR2)
  return VARCHAR2 as
begin
  return dbms_java.shortname(longname);
end dbj_short_name;
/

CREATE PUBLIC SYNONYM dbj_short_name FOR dbj_short_name;

GRANT EXECUTE ON dbj_short_name TO PUBLIC;



