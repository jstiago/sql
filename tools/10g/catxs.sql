Rem
Rem $Header: catxs.sql 16-aug-2005.08:49:22 zqiu Exp $
Rem
Rem catxs.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxs.sql - eXpreSs Catalog creation
Rem
Rem    DESCRIPTION
Rem      This loads the catalog for the analytic workspaces
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    zqiu        08/10/05 - Backport zqiu_txn115442 
Rem    zqiu        07/15/04 - more truthful ps{gen,num} count
Rem    cchiappa    06/16/04 - Drop trigger deletes from expdepact$
Rem    dbardwel    05/21/04 - Support for 10.2 aw_version
Rem    dbardwel    03/26/04 - Add missing join to ALL_AWS and ALL_AW_PS
Rem    ckearney    03/17/04 - add AW_VERSION to DBA_AWS & ALL_AWS
Rem    zqiu        10/16/03 - delete from noexp in trigger
Rem    zqiu        10/01/03 - fix redundancy in all_ views
Rem    zqiu        09/23/03 - strip DML priv to public
Rem    zqiu        12/05/02 - remove temp columns in aw_prop$
Rem    zqiu        11/21/02 - modify trigger to delete from aw_*$ table
Rem    zqiu        09/17/02 - bypass select from user_table in aw_drop_proc
Rem    zqiu        09/09/02 - add view all_aws
Rem    zqiu        07/25/02 - use dynamic sql for aw_drop_trigger
Rem    zqiu        06/18/02 - trigger to clean aw$/ps$ when user table dropped
Rem    jcarey      10/18/01 - remove lobtab from aw$
Rem    esoyleme    09/13/01 - views in spec..
Rem    esoyleme    09/10/01 - creation

--create views on aw$

create or replace view DBA_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS)
as
SELECT u.name, a.awseq#, a.awname,
       DECODE(a.version, 0, '9.1', 1, '10.1', 2, '10.2', NULL), n.num, g.gen
FROM aw$ a, user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n 
WHERE   a.owner#=u.user# and a.awseq#=g.awseq# and a.awseq#=n.awseq#
/

comment on table DBA_AWS is
'Analytic Workspaces in the database'
/
comment on column DBA_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column DBA_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/

create or replace view USER_AWS
(AW_NUMBER, AW_NAME, PAGESPACES, GENERATIONS)
as
SELECT a.awseq#, a.awname, n.num, g.gen
FROM aw$ a,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n 
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=g.awseq# and a.awseq#=n.awseq#
/

comment on table USER_AWS is
'Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column USER_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/

create or replace view ALL_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS)
as
SELECT u.name, a.awseq#, a.awname,
       decode(a.version, 0, '9.1', 1, '10.1', 2, '10.2', NULL), n.num, g.gen
FROM aw$ a, sys.obj$ o, sys.user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n   
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=g.awseq# and a.awseq#=n.awseq#
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privilages */
              ( exists (select null from v$enabledprivs
                        where priv_number in (-45 /* LOCK ANY TABLE */,
                                              -47 /* SELECT ANY TABLE */,
                                              -48 /* INSERT ANY TABLE */,
                                              -49 /* UPDATE ANY TABLE */,
                                              -50 /* DELETE ANY TABLE */)
                        )
              )
            )
/

comment on table ALL_AWS is
'Analytic Workspaces accessible to the user'
/
comment on column ALL_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column ALL_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/

--create views on ps$

create or replace view DBA_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u
WHERE   a.owner#=u.user# and a.awseq#=p.awseq#
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table DBA_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column DBA_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column DBA_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column DBA_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

create or replace view USER_AW_PS
(AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=p.awseq#
group by a.awseq#, a.awname, p.psnumber
/

comment on table USER_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column USER_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column USER_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

create or replace view ALL_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u, sys.obj$ o
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=p.awseq#
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privilages */
              ( exists (select null from v$enabledprivs
                        where priv_number in (-45 /* LOCK ANY TABLE */,
                                              -47 /* SELECT ANY TABLE */,
                                              -48 /* INSERT ANY TABLE */,
                                              -49 /* UPDATE ANY TABLE */,
                                              -50 /* DELETE ANY TABLE */)
                        )
              )
            )
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table ALL_AW_PS is
'Pagespaces in Analytic Workspaces accessible to the user'
/
comment on column ALL_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column ALL_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column ALL_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_AWS FOR SYS.DBA_AWS
/
GRANT SELECT ON DBA_AWS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_AW_PS FOR SYS.DBA_AW_PS
/
GRANT SELECT ON DBA_AW_PS to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM USER_AWS FOR SYS.USER_AWS
/
GRANT SELECT ON USER_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM USER_AW_PS FOR SYS.USER_AW_PS
/
GRANT SELECT ON USER_AW_PS to public
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_AWS FOR SYS.ALL_AWS
/
GRANT SELECT ON ALL_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM ALL_AW_PS FOR SYS.ALL_AW_PS
/
GRANT SELECT ON ALL_AW_PS to public
/

CREATE OR REPLACE PROCEDURE aw_drop_proc
  (obj_type IN VARCHAR2, obj_name IN VARCHAR2, obj_owner IN VARCHAR2)
AS 
  DBERR20  EXCEPTION;
    PRAGMA EXCEPTION_INIT(DBERR20, -20025);

  db_name VARCHAR2(50);
  db_awnum  NUMBER;
  db_exist NUMBER;
  db_att   NUMBER;
  del_stmt1 VARCHAR2(100) := 'DELETE FROM ps$ WHERE awseq#=:1';
  del_stmt2 VARCHAR2(100) := 'DELETE FROM aw$ WHERE awseq#=:1';
  del_stmt3 VARCHAR2(100) := 'DELETE FROM aw_prop$ WHERE awseq#=:1';
  del_stmt4 VARCHAR2(100) := 'DELETE FROM aw_obj$ WHERE awseq#=:1';
  del_stmt5 VARCHAR2(100) := 'DELETE FROM noexp$ WHERE owner=:1 AND name=:2';
  del_stmt6 VARCHAR2(200) := 'DELETE FROM expdepact$ WHERE obj#=(SELECT object_id FROM all_objects WHERE owner=:1 AND object_name=:2) AND schema=:3';
BEGIN
-- Check if we are deleting a table prefixed with 'AW$'.
  IF obj_type = 'TABLE' AND obj_name like 'AW$_%' THEN
    -- Count on AW$ and PS$ tables both being there.
    db_name := SUBSTR(obj_name, 4, LENGTH(obj_name));
    SELECT a.awseq# INTO db_awnum FROM aw$ a, user$ u
    WHERE  a.awname = db_name AND
           a.owner# = u.user# and u.name = obj_owner;
    SELECT count(*) INTO db_att FROM gv$aw_olap 
    WHERE aw_number = db_awnum;      
    IF db_att > 0 THEN  -- this is DBERR20 in 10.2
      RAISE_APPLICATION_ERROR(-20025, 
        '(DBERR20) An attached analytic workspace is blocking this command.');
    END IF;
    EXECUTE IMMEDIATE del_stmt1 USING db_awnum;
    EXECUTE IMMEDIATE del_stmt2 USING db_awnum;
    EXECUTE IMMEDIATE del_stmt3 USING db_awnum;
    EXECUTE IMMEDIATE del_stmt4 USING db_awnum;
    EXECUTE IMMEDIATE del_stmt5 USING obj_owner, obj_name;
    EXECUTE IMMEDIATE del_stmt6 USING obj_owner, obj_name, obj_owner;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    NULL; -- aw$ table may already be empty.
  WHEN DBERR20 THEN
    RAISE;
  WHEN OTHERS THEN
    NULL;
END aw_drop_proc;
/
show errors;

CREATE OR REPLACE TRIGGER aw_drop_trg AFTER DROP ON DATABASE
BEGIN
  aw_drop_proc(ora_dict_obj_type, ora_dict_obj_name, ora_dict_obj_owner);
END;
/
show errors;
