Rem
Rem $Header: cattrans.sql 03-oct-2003.16:17:51 wesmith Exp $
Rem
Rem cattrans.sql
Rem
Rem Copyright (c) 2000, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      cattrans.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     10/03/03 - register DBMS_TRANSFORM_EXIMP for instance-level 
Rem                           export procedural action
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    nbhatt      01/23/02 - add the type names to dictionary
Rem    rburns      10/28/01 - remove constraint error
Rem    nbhatt      11/29/00 - add the DBMS_TRANSFORM_EXIMP package to exppkgobj
Rem    nbhatt      09/26/00 - add views, comments
Rem    nbhatt      09/19/00 - replace colon with slash
Rem    nbhatt      08/28/00 - add version information in dictionary
Rem    nbhatt      07/31/00 - transformation dictionary tables
Rem    nbhatt      07/31/00 - Created
Rem

--
-- Table that stores the transformations
create table transformations$(
  transformation_id    number        not null primary key,
  owner                varchar2(30)  not null,
  name                 varchar2(30)  not null,
  from_schema          varchar2(30),
  from_type            varchar2(30),
  from_toid            raw(16)       not null,
  from_version         number        not null,
  to_schema            varchar2(30),
  to_type              varchar2(60),
  to_toid              raw(16)       not null,
  to_version           number        not null);

--
-- Table that stores the attribute mappings
create table attribute_transformations$(
  transformation_id    number,
                          constraint attribute_transformations_fk
                          foreign key (transformation_id)
                          references transformations$ on delete cascade,
  attribute_number     number,
                          constraint attribute_transformations_pk
                          primary key(transformation_id, attribute_number),
  sql_expression       varchar2(4000),
  xsl_transformation   CLOB);


--
-- Sequence for transformation id
--
CREATE SEQUENCE sys.aq$_trans_sequence START WITH 1;

--
-- User_transformations
--
create or replace view USER_TRANSFORMATIONS
(transformation_id, name, from_type, to_type)
as
SELECT t.transformation_id,  t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type
FROM transformations$ t, sys.user$ u
WHERE u.user# = USERENV('SCHEMAID')
and u.name = t.owner
/

--
-- User transformation attributes
--

Create or replace view USER_ATTRIBUTE_TRANSFORMATIONS
(transformation_id, name, from_type, to_type, 
attribute, attribute_transformation)
as
SELECT t.transformation_id,  t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type,
       at.attribute_number,
       at.sql_expression
FROM transformations$ t, attribute_transformations$ at, sys.user$ u
WHERE u.user# = USERENV('SCHEMAID')
and u.name = t.owner and t.transformation_id = at.transformation_id
/

--
-- DBA_transformations

create or replace view DBA_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type)
as
SELECT t.transformation_id, u.name, t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type
FROM transformations$ t, sys.user$ u
WHERE  u.name = t.owner
/


--
-- DBA transformation attributes
--

Create or replace view DBA_ATTRIBUTE_TRANSFORMATIONS
(transformation_id, owner, name, from_type, to_type, attribute, attribute_transformation)
as
SELECT t.transformation_id, u.name, t.name, 
       t.from_schema||'.'||t.from_type, t.to_schema||'.'||t.to_type,
       at.attribute_number,
       at.sql_expression
FROM transformations$ t, attribute_transformations$ at, sys.user$ u
WHERE  u.name = t.owner and t.transformation_id = at.transformation_id
/


create or replace public synonym user_transformations for user_transformations
/

grant select on user_transformations to PUBLIC with grant option
/


create or replace public synonym user_attribute_transformations
   for user_attribute_transformations
/

grant select on user_attribute_transformations to PUBLIC with grant option
/

grant select on dba_attribute_transformations to select_catalog_role
/

grant select on dba_transformations to select_catalog_role
/

delete from sys.exppkgact$ 
where package = 'DBMS_TRANSFORM_EXIMP' and schema='SYS';

insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_TRANSFORM_EXIMP', 'SYS', 2, 1000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_TRANSFORM_EXIMP', 'SYS', 3, 1000)
/
