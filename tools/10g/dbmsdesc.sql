rem 
rem $Header: dbmsdesc.sql 23-oct-2003.11:43:56 gviswana Exp $ 
rem 
Rem Copyright (c) 1991, 2003, Oracle Corporation.  All rights reserved.  
Rem    NAME
Rem      dbmsdesc.sql - describe stored procedures and functions
Rem    DESCRIPTION
Rem      Given a stored procedure, return a description of the 
Rem      arguments required to call that procedure.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem     gviswana   10/23/03  - Add datatype descriptions 
Rem     cbarclay   03/12/03  - optionally provide constraints 
Rem                          - on stringy formals
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     ywu        08/24/00 -  length can handle nchar length semantic
Rem     adowning   03/29/94 -  merge changes from branch 1.6.710.1
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     rkooi      11/26/92 -  change some comment 
Rem     rkooi      11/21/92 -  check for top level functions 
Rem     rkooi      11/17/92 -  get rid of database name 
Rem     rkooi      11/12/92 -  change name res stuff 
Rem     mmoore     11/01/92 -  Creation 

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD* ROUTINES MUST NOT BE CALLED
REM DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************
create or replace package dbms_describe is

  ------------
  --  OVERVIEW
  --
  -- This package is used to describe the arguments of a stored 
  -- procedure.  The client specifies an object name and describe returns 
  -- a set of indexed tables with the results.  Full name 
  -- translation is performed and security checking is also
  -- checked on the final object.

  --------
  --  USES
  --
  -- The primary client of this package is ODESSP (Oracle Call 
  -- Interface Describe PRocedure).

  ---------------
  --  LIMITATIONS
  --
  --  Currently describes of remote objects are not supported.  It is
  --  intended to support this at some point in the future.
  -- 
  --  Currently descibes of all procedures/functions within a package
  --  is not supported. We could add a 'describe_package' procedure
  --  that returns the names of all procedures/functions for the named
  --  package and then the client could call 'describe_procedure' for
  --  those in which it has an interest.
 
  ------------
  --  SECURITY
  --
  -- Describe is available to PUBLIC and performs it's own
  -- security checking based on the object being described.

  -----------------------
  --  TYPES AND CONSTANTS
  --
  type varchar2_table is table of varchar2(30) index by binary_integer;
  -- Indexed table type which is used to return the argument names.

  type number_table   is table of number       index by binary_integer;
  -- Indexed table type which is used to return various argument fields.

  ------------
  --  EXAMPLES
  --
  --  External service interface
  ------------------------------
  --
  -- The ODESSP OCI call may be used to call this routine from a user 
  -- program.  (See the Oracle Call Interface guide for a description)  
  -- Also, this routine could be called from other stored procedures 
  -- using the varchar2_table and number_table types.
  --
  --   EXAMPLE :
  --
  --   Client provides -
  --
  --   object_name - SCOTT.ACCOUNTING.ACCOUNT_UPDATE
  --   total_elements - 100
  --   
  --   ACCOUNT_UPDATE is an overloaded function in package ACCOUNTING
  --   with specification :
  --
  --     type number_table is table of number index by binary_integer
  --     table account (account_no number, person_id number,
  --                    balance number(7,2))
  --     table person  (person_id number(4), person_nm varchar2(10))
  --
  --     function ACCOUNT_UPDATE (account number, 
  --       person person%rowtype, amounts number_table,
  --       trans_date date) return account.balance%type;
  --
  --     function ACCOUNT_UPDATE (account number, 
  --       person person%rowtype, amounts number_table,
  --       trans_no number) return account.balance%type;
  --
  --
  --   Values returned -
  --
  --   overload position   argument  level  datatype length prec scale rad
  --   -------------------------------------------------------------------
  --          1        0                0   NUMBER      7    2     0    0
  --          1        1   ACCOUNT      0   NUMBER     22    0     0    0
  --          1        2   PERSON       0   RECORD
  --          1        2     PERSON_ID  1   NUMBER      4    0     0    0
  --          1        2     PERSON_NM  1   VARCHAR2   10
  --          1        3   AMOUNTS      0   TABLE
  --          1        3                1   NUMBER     22    0     0    0
  --          1        4   TRANS_NO     0   NUMBER     22    0     0    0
  --
  --          0        0                0   NUMBER      7    2     0    0
  --          0        1   ACCOUNT      0   NUMBER     22    0     0    0
  --          0        2   PERSON       0   RECORD
  --          0        2    PERSON_ID   1   NUMBER      4    0     0    0
  --          0        2    PERSON_NM   1   VARCHAR2   10
  --          0        3   AMOUNTS      0   TABLE
  --          0        3                1   NUMBER     22    0     0    0
  --          0        4   TRANS_DATE   0   DATE
  --

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure describe_procedure (object_name in varchar2,
    reserved1 in varchar2, reserved2 in varchar2,
    overload out number_table, position out number_table,
    level out number_table, argument_name out varchar2_table,
    datatype out number_table, default_value out number_table,
    in_out out number_table, length out number_table,
    precision out number_table, scale out number_table,
    radix out number_table, spare out number_table,
    include_string_constraints boolean := FALSE);
  --  
  --  Describe pl/sql object with the given name.  Returns the arguments
  --    ordered by overload, position.  The name resolution follows the
  --    rules for SQL.  Top level procedures and functions, as well as
  --    packaged procedures and functions, may be described.  Procedures
  --    and functions in package STANDARD must be prefixed by "STANDARD"
  --    (e.g., 'standard.greatest' will describe function "GREATEST" in
  --    package "STANDARD").
  --  Input parameters:
  --    object_name 
  --      The name of the procedure being described. The form is
  --        [[part1.]part2.]part3[@dblink]
  --      The syntax follows the rules for identifiers in SQL.  The name may
  --      be a synonym and may contain delimited identifiers (double quoted
  --      strings). This parameter is required and may not be null.
  --      The total length of the name is limited to 197 bytes.
  --    reserved1, reserved2
  --      Reserved for future use.  Must be set to null or empty string.
  --    include_string_constraints 
  --      Output the constraints on stringy formal types.
  --  Output parameters:
  --    overload
  --       A unique number assigned to the procedure signature.  If a 
  --       procedure is overloaded, this field will hold a different
  --       value for each version of the procedure.
  --    position
  --       Position of the argument in the parameter list beginning with 1.
  --       Position 0 indicates a function return value.
  --    level
  --       If the argument is a composite type (like record), this
  --       parameter returns the level of datatype.  See example
  --       section for a usage example.
  --    argument_name
  --       The name of the argument.
  --    datatype
  --       Oracle datatype of the parameter. These are:
  --           0 - This row is a placeholder for a procedure with
  --               no arguments.
  --           1 - VARCHAR2
  --           2 - NUMBER
  --           3 - NATIVE INTEGER (BINARY_INTEGER or PLS_INTEGER)
  --           8 - LONG
  --          11 - ROWID
  --          12 - DATE
  --          23 - RAW
  --          24 - LONG RAW
  --          58 - OPAQUE TYPE 
  --          96 - CHAR
  --         100 - BINARY_FLOAT
  --         101 - BINARY_DOUBLE
  --         104 - UROWID
  --         106 - MLSLABEL
  --         112 - CLOB
  --         113 - BLOB
  --         114 - BFILE
  --         121 - OBJECT
  --         122 - NESTED TABLE 
  --         123 - VARRAY 
  --         178 - TIME 
  --         179 - TIME WITH TIME ZONE 
  --         180 - TIMESTAMP 
  --         181 - TIMESTAMP WITH TIME ZONE 
  --         182 - INTERVAL YEAR TO MONTH
  --         183 - INTERVAL DAY TO SECOND
  --         231 - TIMESTAMP WITH LOCAL TIME ZONE 
  --         250 - PL/SQL RECORD (see "Notes:" below)
  --         251 - PL/SQL TABLE
  --         252 - PL/SQL BOOLEAN (see "Notes:" below)
  --    default_value
  --       1 if the parameter has a default value.  0, otherwise.
  --    in_out
  --       0 = IN param, 1 = OUT param, 2 = IN/OUT param
  --    length
  --       The data length of the argument.
  --       For CHAR(N)/VARCHAR2(N), length is N, the number of bytes on the
  --       server. For NCHAR(N)/NVARCHAR2(N), length is N, the number of 
  --       characters on the server (this is different from the number of
  --       bytes required to store the string).
  --       Starting with Oracle 9.0, NCHAR only supports UTF8 and AL16UTF16.
  --    precision
  --       Precision of the argument (if the datatype is number).
  --    scale
  --       Scale of the argument (if the datatype is number).
  --    radix
  --       Radix of the argument (if the datatype is number).
  --    spare
  --       Reserved for future functionality.
  --  Exceptions:
  --    ORA-20000 - A package was specified.  Can only specify top-level
  --      procedure/functions or procedures/functions within a package.
  --    ORA-20001 - The procedure/function does not exist within the package.
  --    ORA-20002 - The object is remote.  This procedure cannot currently 
  --      describe remote objects.
  --    ORA-20003 - The object is invalid.  Invalid objects cannot be
  --      described.
  --    ORA-20004 - A syntax error in the specification of the object's name.
  --  Notes:
  --    There is currently no way from a 3gl to directly bind to an
  --    argument of type 'record' or 'boolean'.  For booleans, there are
  --    the following work-arounds.  Assume function F returns a boolean, G
  --    is a procedure with one IN boolean argument, and H is a procedure
  --    which has one OUT boolean argument. 
  --    Then you can execute these functions, binding in DTYINTs (native
  --    integer) as follows, where 0=>FALSE and 1=>TRUE:
  --
  --      begin :dtyint_bind_var := to_number(f); end;
  --
  --      begin g(to_boolean(:dtyint_bind_var)); end;
  -- 
  --      declare b boolean; begin h(b); if b then :dtyint_bind_var := 1;
  --        else :dtyint_bind_var := 0; end if; end;
  --
  --    Access to procedures with arguments of type 'record' would require 
  --    writing a wrapper similar to that in the 3rd example above (see
  --    function H).
end;
/
create or replace public synonym dbms_describe for sys.dbms_describe
/
grant execute on dbms_describe to public
/
