rem
rem NAME
rem   csminst.sql
rem DESCRIPTION
rem   Create tables for Database Character Set Migration Utility
rem NOTE
rem   This script must be run while connected as SYS
rem MODIFIED
rem   ywu       07/14/04 - up version
rem   fayang    04/23/04 - add column UNNESTED in CSM$TABLES 
rem   fayang    04/06/04 - add SCNCOL# in EXTABLES and add a view for EXTABLES 
rem   ywu       02/19/04 - fix bug 3434808, delete hard code passwd.
rem   ywu       07/29/03 - grant privilege to system for external table
rem   ywu       05/30/03 - add a table for data dictionary
rem   ywu       05/09/03 - add led parameter to csm$errors
rem   ywu       10/22/02 - add another error for codepoint exceed
rem   ywu       08/30/02 - up version
rem   ywu       07/01/02 - add size information
rem   ywu       07/02/02 - add resumable 
rem   plinsley  01/24/02 - add include/exclude
rem   plinsley  04/02/01 - up version
rem   plinsley  03/23/01 - #1509940
rem   plinsley  03/26/01 - update views
rem   plinsley  12/15/00 - remove order by from view
rem   plinsley  11/03/00 - Add converter process column
rem   plinsley  10/04/00 - split tables that cross files
rem   plinsley  09/21/00 - Long ROWIDs in id
rem   plinsley  08/09/00 - Adding constraint dependency handling
rem   mtozawa   06/29/00 - add csmv$ views
rem   mtozawa   06/27/00 - add browid to csm$columns
rem   mtozawa   06/02/00 - specify the storage clause for csm$errors
rem   mtozawa   05/26/00 - bug1314547:optimize split mechanism, add blocks
rem   mtozawa   05/19/00 - Change table names from SCN$* to CSM$*
rem   mtozawa   03/08/00 - add SPLIT support
rem   mtozawa   12/21/99 - add property column to SCN$TABLES for IOT
rem   mtozawa   11/05/99 - remove storage params from SCN$ERRORS
rem   mtozawa   11/04/99 - add maxsiz to SCN$COLUMNS
rem   mtozawa   09/26/99 - Creation
rem

rem *****************************************************************
rem Grant READ privilege to SYSTEM to access external table
rem *****************************************************************
grant READ on directory log_file_dir to system
/
grant READ on directory data_file_dir to system
/
rem *****************************************************************
rem  The user CSMIG owns tables and procedures of Database Scanner
rem *****************************************************************
drop user csmig cascade
/
Prompt Please create password for user CSMIG:
create user csmig identified by &csmig_passwd
/
grant connect, resource to csmig
/
grant create public synonym to csmig
/
grant drop public synonym to csmig
/
grant select on sys.obj$ to csmig
/
grant select on sys.col$ to csmig
/
grant select on sys.icol$ to csmig
/
grant select on sys.ind$ to csmig
/
grant select on sys.cdef$ to csmig
/
grant select on sys.con$ to csmig
/
grant select on sys.trigger$ to csmig
/
rem *****************************************************************
rem  DBA MUST ASSIGN PROPER TABLESPACE TO CSMIG
rem *****************************************************************
alter user csmig default tablespace SYSTEM
/
rem *****************************************************************
rem  Add version information for csm$* schema
rem  The schema version must be bumped up as csm$* schema get updated.
rem  VERSION HISTORY:
rem    1 ... 8.1.7
rem *****************************************************************
insert into sys.props$
select 'NLS_CSMIG_SCHEMA_VERSION', 'x',
       'Character set migration utiltiy schema version #'
  from dual
 where not exists
       (select 'x' from sys.props$ where name = 'NLS_CSMIG_SCHEMA_VERSION')
/
update sys.props$ set value$ = 5 where name = 'NLS_CSMIG_SCHEMA_VERSION'
/
rem *****************************************************************
rem  Database Scanner leaves the last scan parameters in CSM$PARAMETERS
rem  Each background process will read scan parameters from here.
rem *****************************************************************
create table csmig.csm$parameters
( name      varchar2(30) not null,                         /* paraneter name */
  value     varchar2(80) not null                        /* parameter value */
)
/
drop public synonym csm$parameters
/
create public synonym csm$parameters for csmig.csm$parameters
/
grant select on csmig.csm$parameters to public
/
rem *****************************************************************
rem  Database Scanner saves the query string in CSM$QUERY
rem *****************************************************************
create table csmig.csm$query
( 
  value    clob not null                       /* query value */
)
/
drop public synonym csm$query
/
create public synonym csm$query for csmig.csm$query
/
grant select on csmig.csm$query to public
/
rem *****************************************************************
rem  Database Scanner enumerate all tables need to be scanned
rem  Each background process will pick up a row from here for table to scan
rem *****************************************************************
create table csmig.csm$tables
( usr#      number not null,                   /* user id of the table owner */
  obj#      number not null,                       /* object id of the table */
  minrowid  rowid,          /* Minimum rowid of the split range of the table */
  maxrowid  rowid,          /* Maximum rowid of the split range of the table */
  property  number,                                        /* table property */
  blocks    number,                   /* number of blocks used by this table */
  files     number,                    /* number of files used by this table */
  who       number,              /* internal thread id who scanned the table */
  whoconv   number,            /* internal thread id who converted the table */
  lngconv   number,             /* internal thread id who converted long col */
  scnstart  date,                                 /* time table scan started */
  scnend    date,                               /* time table scan completed */
  scncols   number,                       /* number of columns to be scanned */
  scnrows   number,                                /* number of rows scanned */
  cnvstart  date,                              /* time table convert started */
  cnvend    date,                            /* time table convert completed */
  lngstart  date,                         /* time table convert long started */
  lngend    date,                       /* time table convert long completed */
  cnvcols   number,                     /* number of columns to be converted */
  cnvrows   number,                        /* number of rows to be converted */
  lngrows   number,               /* number of rows  of long to be converted */
  addsize   number,
  lastupd   rowid,                                      /* ROWID lastupdated */
  pstcvrows number,                      /* how many rows have been converted */
  lastupdlg rowid,                                      /* ROWID lastupdated */
  pstcvrowslg  number,                   /* how many rows have been converted */
  unnested  number                       /* if this table is unnested or not */
)
/
drop public synonym csm$tables
/
create public synonym csm$tables for csmig.csm$tables
/
grant select on csmig.csm$tables to public
/
rem *****************************************************************
rem  CSM$COLUMNS contains statistic information of column data
rem *****************************************************************
create table csmig.csm$columns
( usr#       number not null,                  /* user id of the table owner */
  obj#       number not null,                      /* object id of the table */
  browid     rowid,                        /* rowid of the row in csm$tables */
  col#       number not null,                                   /* column id */
  intcol#    number not null,                /* internal column id (for ADT) */
  dty#       number not null,                            /* column data type */
  frm#       number not null,                          /* character set form */
  numrows    number not null,                /* number of rows in this table */
  nulcnt     number not null,                    /* number of null cell data */
  cnvcnt     number not null,    /* number of cell data that need to convert */
  errcnt     number not null,      /* number of cell data that has exception */
  sizerr     number not null, /* number of cell data that exceed column size */
  cnverr     number not null, /* number of cell data that undergo lossy conv.*/
  maxsiz     number not null,               /* max post conversion data size */
  chrsiz     number not null,            /* truncation due to char semantics */
  cnvsuc     number,                         /* cells converted successfully */
  cnvtrn     number,                      /* cells converted with truncation */
  cnvlos     number,                    /* cells converted with lossy result */
  cnvfai     number                               /* cells failed to convert */
)
/
drop public synonym csm$columns
/
create public synonym csm$columns for csmig.csm$columns
/
grant select on csmig.csm$columns to public
/
rem *****************************************************************
rem  CSM$EXTABLES contains exception tables
rem *****************************************************************
create table csmig.csm$extables
( usr#       number not null,                  /* user id of the table owner */
  obj#       number not null,                      /* object id of the table */
  col#       number,                                            /* column id */
  intcol#    number,                         /* internal column id (for ADT) */
  dty#       number,                                     /* column data type */
  frm#       number,                                   /* character set form */
  property   number default 0 not null,                   /* property of row */
  scncol#    number                                /* column id to be scaned */
)
/
drop public synonym csm$extables
/
create public synonym csm$extables for csmig.csm$extables
/
grant select on csmig.csm$extables to public
/
rem *****************************************************************
rem  CSM$ERRORS contains individual exception information
rem *****************************************************************
create table csmig.csm$errors
( err#       number not null,                              /* exception type */
  usr#       number not null,            /* user id of the object/data owner */
  obj#       number not null,                                  /* object id  */
  col#       number,                                 /* column id / position */
  intcol#    number,                         /* internal column id (for ADT) */
  typ#       number,                       /* column data type / object type */
  frm#       number,                                   /* character set form */
  cnvsize    number,                            /* post conversion data size */
  id$        varchar2(1000),              /* rowid / name to identify object */
  csidleds   number,                      /* number of charset id from led   */
  csidled1   number,                      /* first charset id from led       */
  csidled2   number,                      /* second charset id from led      */
  csidled3   number,                      /* third charset id from led       */
  langidleds number,                      /* number of language id from led  */
  langidled1 number,                      /* first language id from led      */
  langidled2 number,                      /* second language id from led     */
  langidled3 number                        /* third language id from led     */
)
pctfree 0 pctused 99
storage(next 100K maxextents unlimited pctincrease 0)
/
drop public synonym csm$errors
/
create public synonym csm$errors for csmig.csm$errors
/
grant select on csmig.csm$errors to public
/
rem *****************************************************************
rem  CSM$LANGID contains summary information
rem *****************************************************************
create table csmig.csm$langid
( obj#       number not null,                                  /* object id  */
  langid     number,                                 /* language id from led */
  count      number
)
/
drop public synonym csm$langid
/
create public synonym csm$langid for csmig.csm$langid
/
grant select on csmig.csm$langid to public
/
rem *****************************************************************
rem  CSM$CHARSETID contains summary information
rem *****************************************************************
create table csmig.csm$charsetid
( obj#       number not null,                                  /* object id  */
  csid       number,                                 /* language id from led */
  count      number
)
/
drop public synonym csm$charsetid
/
create public synonym csm$charsetid for csmig.csm$charsetid
/
grant select on csmig.csm$charsetid to public
/
rem *****************************************************************
rem  CSM$INDEXES lists indexes to be disabled
rem *****************************************************************
create table csmig.csm$indexes
( obj#       number not null                       /* object id of the index */
)
/
drop public synonym csm$indexes
/
create public synonym csm$indexes for csmig.csm$indexes
/
grant select on csmig.csm$indexes to public
/
rem *****************************************************************
rem  CSM$CONSTRAINTS lists constraints to be disabled
rem *****************************************************************
create table csmig.csm$constraints
( 
  rid        number not null,                   /* root constraint id         */
  lvl        number,                            /* constraint level           */
  con#       number not null                    /* internal constraint number */
)
/
drop public synonym csm$constraints
/
create public synonym csm$constraints for csmig.csm$constraints
/
grant select on csmig.csm$constraints to public
/
rem *****************************************************************
rem  CSM$TRIGGERS lists triggers to be disabled
rem *****************************************************************
create table csmig.csm$triggers
( obj#       number not null                     /* object id of the trigger */
)
/
drop public synonym csm$triggers
/
create public synonym csm$triggers for csmig.csm$triggers
/
grant select on csmig.csm$triggers to public
/
rem *****************************************************************
rem  CSM$DICTUSERS lists triggers to be disabled
rem *****************************************************************
create table csmig.csm$dictusers
( user#       number not null,                /* usre id for all data dictionary */
  username    varchar2(30)
)
/
drop public synonym csm$dictusers
/
create public synonym csm$dictusers for csmig.csm$dictusers
/
grant select on csmig.csm$dictusers to public
/
insert into csmig.csm$dictusers 
  select distinct u.user_id, u.username from all_users u, sys.ku_noexp_view k
  where (k.OBJ_TYPE='USER' and k.name=u.username) or (u.username='SYSTEM')
/
rem
rem  define CSMV$ views
rem
rem *****************************************************************
rem  CSMV$TABLES lists tables (to be) scanned
rem *****************************************************************
create or replace view csmig.csmv$tables
      (owner_id, owner_name, table_id, table_name, MIN_ROWID, MAX_ROWID,
       BLOCKS, SCAN_COLUMNS, SCAN_ROWS, SCAN_START, SCAN_END)
    as
select c.usr#, u.username, c.obj#, o.name,
       rowidtochar(c.minrowid), rowidtochar(c.maxrowid),
       c.blocks, c.scncols, c.scnrows,
       to_char(c.scnstart,'hh24:mi:ss'), to_char(c.scnend,'hh24:mi:ss')
  from csm$tables c, all_users u, sys.obj$ o
 where c.usr#=u.user_id and c.obj#=o.obj#
/
drop public synonym csmv$tables
/
create public synonym csmv$tables for csmig.csmv$tables
/
rem *****************************************************************
rem  CSMV$COLUMNS lists columns scanned
rem *****************************************************************
create or replace view csmig.csmv$columns
     (owner_id, owner_name, table_id, table_name, column_id, column_intid,
      column_name, column_type, total_rows, null_rows, conv_rows, error_rows,
      exceed_size_rows, data_loss_rows, cs_exceed_size_rows, max_post_convert_size)
    as
select c.usr#, u.username, c.obj#, o.name, c.col#, c.intcol#, co.name,
       decode(c.frm#, 2, 'N', '') ||
       decode(c.dty#, 1, 'VARCHAR2', 8, 'LONG', 96, 'CHAR', 112, 'CLOB',''),
       c.numrows, c.nulcnt, c.cnvcnt, c.errcnt, c.sizerr, c.cnverr, c.chrsiz, c.maxsiz
  from csm$columns c, all_users u, sys.obj$ o, sys.col$ co
 where c.usr#=u.user_id and c.obj#=o.obj# and c.obj#=co.obj#
   and c.col#=co.col# and c.intcol#=co.intcol#
/
drop public synonym csmv$columns
/
create public synonym csmv$columns for csmig.csmv$columns
/
rem *****************************************************************
rem  CSMV$ERRORS lists exceptional data cell information
rem *****************************************************************
create or replace view csmig.csmv$errors
      (owner_id, owner_name, table_id, table_name,
       column_id, column_intid, column_name, data_rowid,
       column_type, error_type)
    as
select e.usr#, u.username, e.obj#, o.name,
       e.col#, e.intcol#, c.name, e.id$,
       decode(e.frm#, 2, 'N', '') ||
       decode(e.typ#, 1, 'VARCHAR2', 8, 'LONG', 96, 'CHAR', 112, 'CLOB'),
       decode(e.err#, 0, 'CONVERTIBLE', 1, 'EXCEED_SIZE', 2, 'DATA_LOSS', 
                      3, 'CS_EXCEED_SIZE')
  from csm$errors e, all_users u, sys.obj$ o, sys.col$ c
 where e.usr#=u.user_id and e.obj#=o.obj#
   and e.obj#=c.obj# and e.col#=e.col# and e.intcol#=c.intcol#
/
drop public synonym csmv$errors
/
create public synonym csmv$errors for csmig.csmv$errors
/
rem *****************************************************************
rem  CSMV$INDEXES lists all indexes to be disabled
rem *****************************************************************
create or replace view csmig.csmv$indexes
      (index_owner_id, index_owner_name, index_id, index_name,
       index_status#, index_status,
       table_owner_id, table_owner_name, table_id, table_name,
       column_id, column_intid, column_name)
    as
select iu.user_id, iu.username, io.obj#, io.name, id.flags,
       decode(bitand(id.flags,1), 1, 'UNUSABLE', 'VALID'),
       bu.user_id, bu.username, bo.obj#, bo.name,
       cl.col#, cl.intcol#, cl.name
  from csm$indexes ci, sys.icol$ ic, sys.ind$ id, all_users iu,
       sys.obj$ io, all_users bu, sys.obj$ bo, sys.col$ cl
 where ci.obj#=ic.obj# and ci.obj#=id.obj#
   and ci.obj#=io.obj# and io.owner#=iu.user_id
   and ic.bo# =bo.obj# and bo.owner#=bu.user_id
   and ic.bo#=cl.obj# and ic.col#=cl.col# and ic.intcol#=cl.intcol#
/
drop public synonym csmv$indexes
/
create public synonym csmv$indexes for csmig.csmv$indexes
/
rem *****************************************************************
rem  CSMV$CONSTRAINTS lists all constraints to be disabled
rem *****************************************************************
create or replace view csmig.csmv$constraints
      (owner_id, owner_name, constraint_id, constraint_name,
       constraint_type#, constraint_type, table_id, table_name, 
       constraint_rid, constraint_level)
    as
select c.owner#, u.username, c.con#, c.name, cd.type#,
       decode(cd.type#, 1, 'CHECK', 2, 'PRIMARY_KEY', 3, 'UNIQUE',
                        4, 'REFERENTIAL', 'UNKNOWN'),
       o.obj#, o.name, cc.rid, cc.lvl
  from csm$constraints cc, sys.cdef$ cd, sys.con$ c, all_users u, sys.obj$ o
 where cc.con#=cd.con# and cc.con#=c.con#
   and c.owner#=u.user_id and cd.obj#=o.obj#
/
drop public synonym csmv$constraints
/
create public synonym csmv$constraints for csmig.csmv$constraints
/
rem *****************************************************************
rem  CSMV$TRIGGERS lists all triggers to be disabled
rem *****************************************************************
create or replace view csmig.csmv$triggers
      (trigger_owner_id, trigger_owner_name, trigger_id, trigger_name,
       table_owner_id, table_owner_name, table_id, table_name)
    as
select ru.user_id, ru.username, tr.obj#, ro.name, bu.user_id,
       bu.username, tr.baseobject, bo.name
  from csm$triggers ct, sys.trigger$ tr, all_users ru, sys.obj$ ro,
       all_users bu, sys.obj$ bo
 where ct.obj#=tr.obj# and ct.obj#=ro.obj# and ro.owner#=ru.user_id
   and tr.baseobject=bo.obj# and bu.user_id=bo.owner#
/
drop public synonym csmv$triggers
/
create public synonym csmv$triggers for csmig.csmv$triggers
/
rem *****************************************************************
rem  CSMV$EXTABLES lists all distinct objects to be scaned
rem *****************************************************************
create or replace view csmig.csmv$extables
      (obj#, usr#, property)
    as
select  distinct(obj#), usr#, property
  from csm$extables where property=0;
/
commit
/
exit;

