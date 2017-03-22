--
-- $Header: dbmsawex.sql 09-sep-2004.14:14:02 esoyleme Exp $
--
-- dbmsawex.sql
--
--  Copyright (c) Oracle Corporation 2004. All Rights Reserved.
--
--    NAME
--      dbmsawex.sql
--
--    DESCRIPTION
--      Provides the DBMS_AW_EXP package
--
--    NOTES
--      None
--
--    MODIFIED   (MM/DD/YY)
--      esoyleme  07/20/04 - callout-based transport
--      cchiappa  07/13/04 - Move DBMS_AW_EXP to dbmsawex.sql (again) 
--      cchiappa  07/02/04 - Backout split
--      cchiappa  06/30/04 - Move DBMS_AW_EXP here
--      cchiappa  04/06/04 - Created dummy file
--


CREATE OR REPLACE PACKAGE dbms_aw_exp AUTHID CURRENT_USER AS

  EIF_LOB_SIZE_OUT_OF_RANGE EXCEPTION;
  INVALID_AW_VERSION NUMBER := -20004;
  CROSS_PLATFORM_TRANSPORT NUMBER := -20005;
  AW_TOO_MANY_OBJECTS NUMBER := -20006;

  PROCEDURE alter_lob_size(  newsize     IN   NUMBER);

  PROCEDURE import_begin100( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk100( amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish100(schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_begin92(  schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);
  PROCEDURE import_chunk92(  amt         IN   BINARY_INTEGER,
                             stream      IN   VARCHAR2);
  PROCEDURE import_finish92( schema      IN   VARCHAR2,
                             name        IN   VARCHAR2);

  -- Transportable tablespace support
  PROCEDURE trans_begin102(  awname       IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER);

  PROCEDURE trans_chunk102( amt         IN     BINARY_INTEGER,
                            stream      IN     VARCHAR2);

  PROCEDURE trans_finish102( awname      IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER);

  FUNCTION  schema_info_exp( schema      IN   VARCHAR2,
                             prepost     IN   PLS_INTEGER,
                             isdba       IN   PLS_INTEGER,
                             version     IN   VARCHAR2,
                             new_block   OUT  PLS_INTEGER)
     RETURN VARCHAR2;

  FUNCTION  instance_extended_info_exp(
                             name        IN   VARCHAR2,
                             schema      IN   VARCHAR2,
                             namespace   IN   PLS_INTEGER,
                             type        IN   PLS_INTEGER,
                             prepost     IN   PLS_INTEGER,
                             exp_user    IN   VARCHAR2,
                             isdba       IN   PLS_INTEGER,
                             version     IN   VARCHAR2,
                             new_block   OUT  PLS_INTEGER)
     RETURN VARCHAR2;


  TYPE rawvec_t      IS TABLE OF      RAW(31744);
  TYPE varchar2vec_t IS TABLE OF VARCHAR2(31744);
  FUNCTION  lob_write(       wlob IN OUT NOCOPY BLOB,
                             pos  IN            BINARY_INTEGER,
                             data IN            rawvec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_writeappend( wlob IN OUT NOCOPY BLOB,
                             data IN            rawvec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_write(       wlob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                             pos  IN            BINARY_INTEGER,
                             data IN            varchar2vec_t)
     RETURN BINARY_INTEGER;

  FUNCTION  lob_writeappend( wlob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                             data IN            varchar2vec_t)
     RETURN BINARY_INTEGER;

END dbms_aw_exp;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_aw_exp FOR sys.dbms_aw_exp
/
GRANT EXECUTE ON dbms_aw_exp TO PUBLIC
/
