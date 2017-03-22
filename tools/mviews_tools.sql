-------------------------------------------------------------------------------
--Analyzing MVIEW Capabilities
-------------------------------------------------------------------------------
  exec DBMS_MVIEW.EXPLAIN_MVIEW('schema.MVIEW', 'statement_id');

  -- CREATE TABLE MV_CAPABILITIES_TABLE
  --(STMT_ID           VARCHAR(30),   -- client-supplied unique statement identifier
  -- MV                VARCHAR(30),   -- NULL for SELECT based EXPLAIN_MVIEW
  -- CAPABILITY_NAME   VARCHAR(30),   -- A descriptive name of particular
  --                                  -- capabilities, such as REWRITE.
  --                                  -- See Table 8-7
  -- POSSIBLE          CHARACTER(1),  -- Y = capability is possible
  --                                  -- N = capability is not possible
  -- RELATED_TEXT      VARCHAR(2000), -- owner.table.column, and so on related to
  --                                  -- this message
  -- RELATED_NUM       NUMBER,        -- When there is a numeric value
  --                                  -- associated with a row, it goes here.
  -- MSGNO             INTEGER,       -- When available, message # explaining
  --                                  -- why disabled or more details when
  --                                  -- enabled.
  -- MSGTXT            VARCHAR(2000), -- Text associated with MSGNO
  -- SEQ               NUMBER);       -- Useful in ORDER BY clause when
                                  -- selecting from this table.


--------------------------------------------------------------------------------
--Estimating Size
--------------------------------------------------------------------------------
DECLARE
  v_ROWS NUMBER(10);
  v_BYTES NUMBER(10);
BEGIN
  DBMS_MVIEW.ESTIMATE_MVIEW_SIZE('statement_id', 'select clause', v_ROWS, v_BYTES);
END;
/



--------------------------------------------------------------------------------

--------------------------------------------------------------------------------




