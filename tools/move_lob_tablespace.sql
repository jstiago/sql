  ALTER TABLE TRADE_XML MOVE LOB(XML_PVS) STORE AS lobsegment
  (TABLESPACE LAG_DATA_01);
  
  
ALTER TABLE TRADE_XML MODIFY LOB(XML_PVS) (SHRINK SPACE)  PARALLEL 16;


ALTER TABLE TRADE_XML MODIFY LOB(XML_PVS) (SHRINK SPACE);
ALTER TABLE TRADE_XML MODIFY LOB(XML_TRADE) (SHRINK SPACE);
  

  
BEGIN
  FOR c IN (SELECT  'ALTER TABLE TRADE_XML MOVE PARTITION ' || PARTITION_NAME || ' LOB (' || COLUMN_NAME || ') STORE AS (TABLESPACE GLP_DATA_01) PARALLEL 8' CMD
            FROM    DBA_LOB_PARTITIONS lp
            WHERE   lp.TABLE_OWNER = 'TES'
            AND     lp.TABLE_NAME = 'TRADE_XML'
            AND     lp.TABLESPACE_NAME = 'TES_DATA')
            --AND     lp.COLUMN_NAME     = 'XML_TRADE')
  LOOP
    EXECUTE IMMEDIATE c.CMD;
    --DBMS_OUTPUT.PUT_LINE(c.cmd);
  END LOOP;
END;
/



alter table trade_xml drop partition P_50375;

ALTER TABLE TRADE_XML modify PARTITION P_28376 DEALLOCATE UNUSED
ALTER TABLE TRADE_XML MOVE PARTITION P_28376 COMPRESS