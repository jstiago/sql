Rem
Rem $Header: dbmslcr.sql 09-jun-2004.15:17:38 liwong Exp $
Rem
Rem dbmslcr.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmslcr.sql - Logical Change Record
Rem
Rem    DESCRIPTION
Rem      Has opaque type definitions for
Rem       - sys.lcr$_row_record
Rem       - sys.lcr$_ddl_record
Rem       - sys.lcr$_procedure_record
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    liwong      06/09/04  - Add get_source_time 
Rem    liwong      02/21/04  - Fast column value evaluation 
Rem    lkaplan     06/04/03  - LONG to LOB
Rem    nshodhan    04/07/03  - add constructor for lcr$_row_unit
Rem    nshodhan    03/21/03  - modify lcr$_row_unit for longs.
Rem    nshodhan    03/11/03  - Expose LONG columns
Rem    liwong      01/20/03  - Support compatible
Rem    alakshmi    10/02/02  - grant privileges with grant option
Rem    liwong      07/22/02  - Extended attributes
Rem    alakshmi    06/19/02  - Add signature for get_commit_scn
Rem    alakshmi    04/29/02  - Bug 2346481: add use_old to get methods
Rem    rvenkate    01/28/02  - re-order parameters
Rem    liwong      01/25/02  - Suppress errors during eval ctx creation
Rem    alakshmi    02/04/02  - Lob API changes
Rem    liwong      12/18/01  - Support fast method eval
Rem    weiwang     12/10/01  - change reference to sys.re$variable_type
Rem    liwong      11/16/01  - Unify evaluation contexts
Rem    liwong      11/14/01  - Grant streams$_evaluation_context to PUBLIC
Rem    liwong      11/13/01  - Unifying evaluation contexts
Rem    alakshmi    11/08/01  - Merged alakshmi_apicleanup
Rem    lkaplan     10/29/01 -  API - dml hdlr, lcr.execute, set key options
Rem    liwong      10/31/01 - Hack evaluation context for partial rule
Rem                         - evaluation
Rem    elu         10/27/01 - modify eval ctx
Rem    alakshmi    10/29/01 - use clob for ddl_text
Rem    rvenkate    10/24/01 - remove is_present
Rem    alakshmi    10/24/01 - DEFAULT_USER => CURRENT_SCHEMA in ddl lcr
Rem    liwong      10/23/01 - API cleanup
Rem    lkaplan     10/14/01 - lcr.execute
Rem    alakshmi    10/13/01 - lcr API changes
Rem    elu         10/12/01 - add eval ctx
Rem    alakshmi    10/08/01 - Add redo_tag  APIs
Rem    rvenkate    10/01/01 - combine int/ext lcrs
Rem    alakshmi    10/05/01 - lcr interface changes
Rem    rvenkate    10/01/01 - combine int/ext lcrs
Rem    alakshmi    10/01/01 - get_publication=>is_null_redo_tag
Rem    rvenkate    09/12/01 - add map fn, remove rba, thread
Rem    alakshmi    09/12/01 - changes to object_type/command_type
Rem    rvenkate    09/12/01 - add map fn, remove rba, thread
Rem    rvenkate    08/30/01 - add internal lcr header struct
Rem    liwong      08/31/01 - Add streams$_evaluation_context
Rem    alakshmi    09/07/01 - change object_type to ub1 in XDLCR
Rem    arrajara    08/14/01 - Merged arrajara_external_ddl_lcr
Rem    arrajara    08/10/01 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_lcr AS

  -- Constants for LOBs
  not_a_lob          CONSTANT NUMBER := 1;
  null_lob           CONSTANT NUMBER := 2;
  inline_lob         CONSTANT NUMBER := 3;
  empty_lob          CONSTANT NUMBER := 4;
  lob_chunk          CONSTANT NUMBER := 5;
  last_lob_chunk     CONSTANT NUMBER := 6;

  -- Constants for LONGs
  not_a_long         CONSTANT NUMBER := 1;
  null_long          CONSTANT NUMBER := 2;
  inline_long        CONSTANT NUMBER := 3;
  long_chunk         CONSTANT NUMBER := 4;
  last_long_chunk    CONSTANT NUMBER := 5;

END dbms_lcr;
/
show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_lcr FOR dbms_lcr
/

GRANT EXECUTE ON dbms_lcr TO PUBLIC
/

CREATE OR REPLACE LIBRARY lcr_row_lib TRUSTED IS STATIC;
/

CREATE OR REPLACE TYPE lcr$_row_unit AS OBJECT (
  column_name        VARCHAR2(4000),
  data               SYS.ANYDATA,
  lob_information    NUMBER,
  lob_offset         NUMBER,
  lob_operation_size NUMBER,
  long_information   NUMBER,
  -- as we are adding a new attribute, create a constructor for
  -- older type def to preserve backwards compatibility.
  CONSTRUCTOR FUNCTION lcr$_row_unit(
    column_name        VARCHAR2,
    data               SYS.ANYDATA,
    lob_information    NUMBER,
    lob_offset         NUMBER,
    lob_operation_size NUMBER)
    RETURN SELF AS RESULT   
  );
/
CREATE OR REPLACE TYPE BODY lcr$_row_unit AS
  CONSTRUCTOR FUNCTION lcr$_row_unit(
    column_name        VARCHAR2,
    data               SYS.ANYDATA,
    lob_information    NUMBER,
    lob_offset         NUMBER,
    lob_operation_size NUMBER) 
    RETURN SELF AS RESULT 
  AS
  BEGIN
    SELF.column_name        := column_name;
    SELF.data               := data;
    SELF.lob_information    := lob_information;
    SELF.lob_offset         := lob_offset;
    SELF.lob_operation_size := lob_operation_size;
    SELF.long_information   := dbms_lcr.not_a_long;  
    RETURN;
  END;
END;
/

GRANT EXECUTE ON LCR$_ROW_UNIT TO PUBLIC WITH GRANT OPTION
/

CREATE OR REPLACE TYPE lcr$_row_list AS TABLE OF sys.lcr$_row_unit;
/
GRANT EXECUTE ON LCR$_ROW_LIST TO PUBLIC WITH GRANT OPTION
/
CREATE OR REPLACE TYPE lcr$_row_record OID '00000000000000000000000000020013'
AS OPAQUE VARYING (*)
USING LIBRARY lcr_row_lib
(
   -- Constructor
   STATIC FUNCTION construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL
   )  RETURN lcr$_row_record,

   MAP MEMBER FUNCTION map_lcr RETURN NUMBER,

   ---------------## Accessors for lcr$_row_record.source_database_name
   -- Returns the source database name
   MEMBER FUNCTION get_source_database_name RETURN varchar2,

   -- Sets the source database name
   MEMBER PROCEDURE set_source_database_name
   (self in out nocopy lcr$_row_record, source_database_name IN varchar2),

   --------------## Accessors for lcr$_row_record.command_type
   -- Returns the command type of the LCR
   MEMBER FUNCTION get_command_type RETURN VARCHAR2,

   -- Sets the command type
   MEMBER PROCEDURE set_command_type (self in out nocopy lcr$_row_record,
                                      command_type IN VARCHAR2),
   --------------## Accessors for lcr$_row_record.object_owner
   -- Sets the object owner
   MEMBER procedure set_object_owner
    (self in out nocopy lcr$_row_record, object_owner IN VARCHAR2),

   -- Returns the object owner
   MEMBER FUNCTION get_object_owner RETURN varchar2,

   --------------## Accessors for lcr$_row_record.object_name
   -- Returns the object name
   MEMBER FUNCTION get_object_name RETURN varchar2,

   -- Sets the object name
   MEMBER procedure set_object_name
    (self in out nocopy lcr$_row_record, object_name IN VARCHAR2),

   --------------## Accessors for the the column values
   -- This FUNCTION returns the old or new value for the corresponding column.
   -- value_type can only be 'OLD' or 'NEW'.
   -- If the value is NULL, then a sys.AnyData instance with a NULL
   -- value inside is returned. If no value for such a column exists, 
   -- NULL is returned.
   -- If use_old is 'Y' and value_type is NEW, and no new value exists then
   -- returns the corresponding old value. If N and value_type is new, then 
   -- does not return the old value if new value does not exist.
   -- If the value_type is old or if the command_type of the row LCR is not
   -- UPDATE, then the value of the use_old parameter is ignored.
   MEMBER FUNCTION get_value(
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y') RETURN Sys.AnyData,

   -- Overwrites the old or new value for the specified column
   MEMBER procedure set_value(self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        column_value        IN Sys.AnyData),

   -- Returns long information for the column. Could be one of the following
   --    dbms_lcr.not_a_long
   --    dbms_lcr.null_long
   --    dbms_lcr.inline_long
   --    dbms_lcr.long_chunk
   --    dbms_lcr.last_long_chunk
   -- If use_old is 'Y' and value_type is NEW, and no new value exists then
   -- returns the corresponding old value. If N and value_type is new, then 
   -- does not return the old value if new value does not exist.
   -- If the value_type is old or if the command_type of the row LCR is not
   -- UPDATE, then the value of the use_old parameter is ignored.
   MEMBER FUNCTION get_long_information(
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y') RETURN NUMBER,

   -- Returns lob information for the column. Could be one of the following
   --    dbms_lcr.not_a_lob
   --    dbms_lcr.null_lob
   --    dbms_lcr.inline_lob
   --    dbms_lcr.empty_lob
   --    dbms_lcr.lob_chunk
   --    dbms_lcr.last_lob_chunk
   -- If use_old is 'Y' and value_type is NEW, and no new value exists then
   -- returns the corresponding old value. If N and value_type is new, then 
   -- does not return the old value if new value does not exist.
   -- If the value_type is old or if the command_type of the row LCR is not
   -- UPDATE, then the value of the use_old parameter is ignored.
   MEMBER FUNCTION get_lob_information(
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y') RETURN NUMBER,

   -- Sets lob information for the column. An exception is raised if
   -- column doesn't exist. Valid values for lob_information
   --    dbms_lcr.not_a_lob
   --    dbms_lcr.null_lob
   --    dbms_lcr.inline_lob
   --    dbms_lcr.empty_lob
   --    dbms_lcr.lob_chunk
   --    dbms_lcr.last_lob_chunk
   MEMBER PROCEDURE set_lob_information(self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        lob_information     IN NUMBER),

   -- Returns lob offset for the column. value_type can only be 'OLD' or 
   -- 'NEW'. If no value exists for the column
   -- or if there is no lob offset for the column, NULL is returned
   MEMBER FUNCTION get_lob_offset(
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2) RETURN NUMBER,

   -- Sets lob offset for the column. An exception is raised if
   -- column doesn't exist
   MEMBER PROCEDURE set_lob_offset(self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        lob_offset          IN NUMBER),

   -- Returns operation size for the lob column. value_type can only be 
   -- 'OLD' or 'NEW'. If no value exists for the column
   -- or if this is not an out-of-line lob column 
   -- or if the LCR operation is not LOB_ERASE or LOB_TRIM, 
   -- NULL is returned
   MEMBER FUNCTION get_lob_operation_size(
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2) RETURN NUMBER,

   -- Sets the operation size for the lob column. An exception is raised if
   -- column doesn't exist.
   -- Applicable to lob_erase and lob_trim only
   MEMBER PROCEDURE set_lob_operation_size(self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        column_name         IN VARCHAR2,
        lob_operation_size  IN NUMBER),

   -- Returns a list of old or new values, depending on the value type
   -- specified
   -- If use_old is 'Y' and value_type is NEW, then returns a list of all
   -- new values in the LCR. If a new value does not exist in the list, then
   -- returns the corresponding old value. Therefore, the returned list 
   -- contains all existing new values and old values for the new values that
   -- do not exist. If N and value_type is new, then returns a list of all
   -- new values in the LCR without returning any old values.
   -- If the value_type is old or if the command_type of the row LCR is not
   -- UPDATE, then the value of the use_old parameter is ignored.
   MEMBER FUNCTION get_values(
        value_type          IN VARCHAR2,
        use_old             IN VARCHAR2  DEFAULT 'Y')
        return sys.lcr$_row_list,

   -- Replaces all the old values or all the new values for the LCR,
   -- depending on the value type specified
   MEMBER procedure set_values(self in out nocopy lcr$_row_record,
        value_type          IN VARCHAR2,
        value_list          IN sys.lcr$_row_list),

   -- Deletes the old or new values depending on the value type
   -- specified. An exception is raised if the column doesn't exist
   -- value_type is last in order to let default be useful
   MEMBER procedure delete_column(self in out nocopy lcr$_row_record,
       column_name    IN varchar2,
       value_type     IN varchar2 DEFAULT '*'),

   -- Adds the value as old or new, depending on the value type
   -- specified, for the column
   MEMBER procedure add_column(self in out nocopy lcr$_row_record,
       value_type     IN varchar2,
       column_name    IN varchar2,
       column_value   IN Sys.AnyData),

   --  This procedure renames the old column, new column or
   --  both (default) depending on the value type specified
   -- value_type is last in order to let default be useful
   MEMBER procedure rename_column(self in out nocopy lcr$_row_record,
       from_column_name  IN varchar2,
       to_column_name    IN varchar2,
       value_type        IN varchar2  DEFAULT '*'),

   --------------## Accessors for lcr$_row_record.source_database_name
   -- This function returns the transaction ID of the LCR.
   MEMBER FUNCTION get_transaction_id       RETURN VARCHAR2,

   -- This function returns the system change NUMBER (SCN) of the LCR.
   MEMBER FUNCTION get_scn RETURN NUMBER,

   --------------------------------------------## Methods for tag
   -- This function sets the tag for the LCR
   MEMBER PROCEDURE set_tag(self in out nocopy lcr$_row_record,
       tag    IN RAW),

   -- This function gets the tag for the LCR
   MEMBER FUNCTION get_tag      RETURN RAW,

   -- This function returns 'Y' or 'N' depending on whether or not
   -- tag for the LCR is NULL
   MEMBER FUNCTION is_null_tag  RETURN VARCHAR2,

   -- This procedure constructs and applys the statement from the row lcr
   MEMBER procedure execute(self in lcr$_row_record,
                            conflict_resolution in boolean),
   -- This function returns the system change NUMBER (SCN) of the commit lcr
   -- for the transaction to which this lcr belongs.
   -- FOR INTERNAL USE ONLY
   MEMBER FUNCTION get_commit_scn RETURN NUMBER,

   -- This FUNCTION returns the value for the corresponding optional attribute.
   -- If the value is NULL, then a sys.AnyData instance with a NULL
   -- value inside is returned. If no value for such an attribute exists, 
   -- NULL is returned.
   MEMBER FUNCTION get_extra_attribute(
        attribute_name         IN VARCHAR2) RETURN Sys.AnyData,

   -- Overwrites the attribute value for the specified attribute
   MEMBER procedure set_extra_attribute(self in out nocopy lcr$_row_record,
        attribute_name         IN VARCHAR2,
        attribute_value        IN Sys.AnyData),

   -- Returns the minimum compatible setting when such LCR is supported
   -- by Streams.
   MEMBER FUNCTION get_compatible RETURN NUMBER,

   -- Replaces LONG/LONG RAW chunks to fixed width CLOB/BLOB chunks
   -- in the given LCR.
   MEMBER PROCEDURE convert_long_to_lob_chunk(
     self in out nocopy lcr$_row_record),

   -- Returns the creation/redo generation time of the lcr
   MEMBER FUNCTION get_source_time RETURN DATE
)
/

show errors
GRANT EXECUTE ON LCR$_ROW_RECORD TO PUBLIC WITH GRANT OPTION
/

-------------------------------------------------------------------------
-- External DDL LCR : lcr$_ddl_record
-------------------------------------------------------------------------
CREATE OR REPLACE LIBRARY lcr_ddl_lib TRUSTED IS STATIC;
/
CREATE OR REPLACE TYPE lcr$_ddl_record OID '00000000000000000000000000020014'
AS OPAQUE VARYING (*)
USING LIBRARY lcr_ddl_lib
(
   -- Constructor
   STATIC FUNCTION construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     object_type                in varchar2,
     ddl_text                   in clob,
     logon_user                 in varchar2,
     current_schema             in varchar2,
     base_table_owner           in varchar2,
     base_table_name            in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL
   )
   RETURN lcr$_ddl_record,

   MAP MEMBER FUNCTION map_lcr RETURN NUMBER,

   ---------------## Accessors for lcr$_ddl_record.source_database_name
   -- This function returns the source database name. If there is
   -- no source database name, NULL is returned.
   MEMBER FUNCTION get_source_database_name RETURN varchar2,

   -- Sets the name of the source database
   MEMBER PROCEDURE set_source_database_name
   (self in out nocopy lcr$_ddl_record,
    source_database_name IN varchar2),

   --------------## Accessors for lcr$_ddl_record.command_type
   -- This FUNCTION returns command type.
   MEMBER FUNCTION get_command_type RETURN varchar2,

   -- This procedure sets command type. If an input command_type
   -- does not make sense, an exception will be raised. For example,
   -- changing INSERT to GRANT.
   MEMBER PROCEDURE set_command_type (self in out nocopy lcr$_ddl_record,
                                      command_type IN varchar2),
   --------------## Accessors for lcr$_ddl_record.object_owner
   -- This FUNCTION returns the owner of the object.
   MEMBER FUNCTION get_object_owner RETURN varchar2,

   -- This procedure sets the owner of the object.
   MEMBER PROCEDURE set_object_owner
    (self in out nocopy lcr$_ddl_record, object_owner IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.object_name
   -- This FUNCTION returns the name of the object.
   MEMBER FUNCTION get_object_name RETURN varchar2,

   -- This procedure sets the name of the object.
   MEMBER PROCEDURE set_object_name
    (self in out nocopy lcr$_ddl_record, object_name IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.transaction_id
   -- This function returns the transaction ID of the LCR.
   MEMBER FUNCTION get_transaction_id       RETURN VARCHAR2,

   -- This function returns the system change NUMBER (SCN) of the LCR.
   MEMBER FUNCTION get_scn RETURN NUMBER,

   --------------## Accessors for lcr$_ddl_record.object_type
   -- This FUNCTION returns the type of the object.
   MEMBER FUNCTION get_object_type RETURN varchar2,

   -- This procedure sets the type of the object.
   MEMBER PROCEDURE set_object_type
    (self in out nocopy lcr$_ddl_record, object_type IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.logon_user
   -- This FUNCTION returns the logon user name
   MEMBER FUNCTION get_logon_user RETURN varchar2,

   -- This procedure sets the logon user name
   MEMBER PROCEDURE set_logon_user
    (self in out nocopy lcr$_ddl_record, logon_user IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.current_schema
   -- This FUNCTION returns the current schema
   MEMBER FUNCTION get_current_schema RETURN varchar2,

   -- This procedure sets the current schema
   MEMBER PROCEDURE set_current_schema
    (self in out nocopy lcr$_ddl_record, current_schema IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.base_table_owner
   -- This FUNCTION returns the base owner name
   MEMBER FUNCTION get_base_table_owner RETURN varchar2,

   -- This procedure sets the base owner name
   MEMBER PROCEDURE set_base_table_owner
    (self in out nocopy lcr$_ddl_record, base_table_owner IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.base_table_name
   -- This FUNCTION returns the base table name
   MEMBER FUNCTION get_base_table_name RETURN varchar2,

   -- This procedure sets the base table name
   MEMBER PROCEDURE set_base_table_name
    (self in out nocopy lcr$_ddl_record, base_table_name IN VARCHAR2),

   --------------## Accessors for lcr$_ddl_record.ddl_text
   -- This FUNCTION returns ddl text
   MEMBER PROCEDURE get_ddl_text 
    (self in lcr$_ddl_record, ddl_text IN OUT NOCOPY CLOB),

   -- This procedure sets ddl text
   MEMBER PROCEDURE set_ddl_text
    (self in out nocopy lcr$_ddl_record, ddl_text IN CLOB),

   --------------------------------------------## Methods for tag
   -- This function sets the tag for the LCR
   MEMBER PROCEDURE set_tag(self in out nocopy lcr$_ddl_record,
       tag    IN RAW),

   -- This function gets the tag for the LCR
   MEMBER FUNCTION get_tag      RETURN RAW,

   -- This function returns 'Y' or 'N' depending on whether or not
   -- tag for the LCR is NULL
   MEMBER FUNCTION is_null_tag  RETURN VARCHAR2,

   -- This procedure constructs and applys the statement from the ddl lcr
   MEMBER procedure execute(self in lcr$_ddl_record),

   -- This function returns the system change NUMBER (SCN) of the commit lcr
   -- for the transaction to which this lcr belongs.
   -- FOR INTERNAL USE ONLY
   MEMBER FUNCTION get_commit_scn RETURN NUMBER,

   --------------## Accessors for the the optional attributes
   -- This FUNCTION returns the value for the corresponding optional attribute.
   -- If the value is NULL, then a sys.AnyData instance with a NULL
   -- value inside is returned. If no value for such an attribute exists, 
   -- NULL is returned.
   MEMBER FUNCTION get_extra_attribute(
        attribute_name         IN VARCHAR2) RETURN Sys.AnyData,

   -- Overwrites the attribute value for the specified attribute
   -- If value is NULL, the existing attribute will be removed.
   MEMBER procedure set_extra_attribute(self in out nocopy lcr$_ddl_record,
        attribute_name         IN VARCHAR2,
        attribute_value        IN Sys.AnyData),

   -- Returns the minimum compatible setting when such LCR is supported
   -- by Streams.
   MEMBER FUNCTION get_compatible RETURN NUMBER,

   -- Returns the creation/redo generation time of the lcr
   MEMBER FUNCTION get_source_time RETURN DATE
)
/
show errors

GRANT EXECUTE ON LCR$_DDL_RECORD TO PUBLIC WITH GRANT OPTION
/

--------------------------
-- Rule evaluation context
--------------------------
-- {ROW,DDL}_VARIABLE_VALUE_FUNCTION converts AnyData to its LCR type
-- evaluation_context_function handles bookkeeping information, e.g.,
-- source data dictionary, commit/rollback.
DECLARE
  vt sys.re$variable_type_list;
BEGIN
  vt := sys.re$variable_type_list(
    sys.re$variable_type('DML', 'SYS.LCR$_ROW_RECORD', 
       'SYS.DBMS_STREAMS_INTERNAL.ROW_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.ROW_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type('DDL', 'SYS.LCR$_DDL_RECORD',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type(NULL, 'SYS.ANYDATA',
       NULL,
       'SYS.DBMS_STREAMS_INTERNAL.ANYDATA_FAST_EVAL_FUNCTION'));

  dbms_rule_adm.create_evaluation_context(
    evaluation_context_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
    variable_types=>vt,
    evaluation_function=>
      'SYS.DBMS_STREAMS_INTERNAL.EVALUATION_CONTEXT_FUNCTION');
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -24145 THEN
    -- suppress evaluation context already exists error to minimize
    -- unwanted noise during upgrade.
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

begin
dbms_rule_adm.grant_object_privilege(
   privilege=>dbms_rule_adm.EXECUTE_ON_EVALUATION_CONTEXT,
   object_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
   grantee=>'PUBLIC', grant_option=>FALSE);
end;
/

--------------------------
-- END Rule evaluation context
--------------------------
