
PROMPT Create the Partitioned TABLE my_schema.bkp_my_table 
CREATE TABLE my_schema.bkp_my_table 
TABLESPACE SDATA_TS 
PARTITION BY HASH (column1) 
    (PARTITION dummy TABLESPACE SDATA_TS) 
AS 
SELECT * 
FROM   my_schema.my_table 
WHERE 1 = 0
/

PROMPT Insert the updated version of records into my_schema.bkp_my_table, add parallel hints if needed
INSERT INTO my_schema.bkp_my_table 
SELECT pk_key
      ,column1
      ,column2
      ,column3
      ,column4
      ,encrypt_function(column5) 
FROM   my_schema.my_table
/
COMMIT;

PROMPT Drop the PKs and drop the functional index
ALTER TABLE my_schema.my_table DROP CONSTRAINT my_table_pk;
DROP INDEX my_schema.my_table_pk;



PROMPT Perform the partition exchange
PROMPT If this fails with ORA-14097: column type or size mismatch in ALTER TABLE EXCHANGE PARTITION, extended stats needs to be dropped using script drop_extended_stats.sql
ALTER TABLE my_schema.bkp_my_table 
EXCHANGE PARTITION dummy
WITH TABLE my_schema.my_table 
EXCLUDING INDEXES
WITHOUT VALIDATION
/

PROMPT Create the PK
ALTER TABLE my_schema.my_table 
ADD CONSTRAINT my_table_pk 
PRIMARY KEY (pk_key)
USING INDEX TABLESPACE mindex_ts
/


PROMPT Rebuild the unusable indexes
ALTER INDEX my_schema.my_table_idx1 REBUILD;
ALTER INDEX my_schema.my_table_idx2 REBUILD;

PROMPT after rebuilding the indexes, run the following query using my_schema_READ to make sure there are no unusable indexes left
PROMPT select index_name from dba_indexes where status = 'UNUSABLE'

PROMPT Drop the table my_schema.bkp_my_table 
DROP TABLE my_schema.bkp_my_table PURGE;

