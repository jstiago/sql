
PROMPT Set the trace event that will capture the hidden columns
ALTER SESSION SET EVENTS='14529 trace name context forever';

PROMPT Create the Partitioned TABLE gs_gc.bkp_ft_t_ntel 
CREATE TABLE gs_gc.bkp_ft_t_ntel 
TABLESPACE SDATA_TS 
PARTITION BY HASH (source_id) 
    (PARTITION dummy TABLESPACE SDATA_TS) 
AS 
SELECT * 
FROM   gs_gc.ft_t_ntel 
WHERE 1 = 0
/
PROMPT Turn off trace event that will capture the hidden columns
ALTER SESSION SET EVENTS='14529 trace name context off';

PROMPT Insert the required records to keep into gs_gc.bkp_ft_t_ntel 
INSERT INTO gs_gc.bkp_ft_t_ntel 
SELECT * 
FROM   gs_gc.ft_t_ntel
MINUS  
SELECT * 
FROM   gs_gc.ft_t_ntel
WHERE  notfcn_id = '16' 
AND    msg_severity_cde < 40
/
COMMIT;


PROMPT Drop the PKs and drop the functional index
/
ALTER TABLE gs_gc.ft_t_ntel DROP CONSTRAINT ft_t_ntel_pk;
DROP INDEX gs_gc.ft_x_ntel_p001;



PROMPT Perform the partition exchange
PROMPT If this fails with ORA-14097: column type or size mismatch in ALTER TABLE EXCHANGE PARTITION, extended stats needs to be dropped using script drop_extended_stats.sql
ALTER TABLE gs_gc.bkp_ft_t_ntel 
EXCHANGE PARTITION dummy
WITH TABLE gs_gc.ft_t_ntel 
EXCLUDING INDEXES
WITHOUT VALIDATION
/

PROMPT Create the PK
ALTER TABLE gs_gc.ft_t_ntel 
ADD CONSTRAINT ft_t_ntel_pk 
PRIMARY KEY (ntel_oid)
USING INDEX TABLESPACE mindex_ts
/

PROMPT Create the functional index
CREATE INDEX gs_gc.ft_x_ntel_p001 ON gs_gc.ft_t_ntel (UPPER(main_entity_id)) TABLESPACE mindex_ts
/

PROMPT Rebuild the unusable indexes
ALTER INDEX gs_gc.ft_x_ntel_p002 REBUILD;
ALTER INDEX gs_gc.ft_x_ntel_i005 REBUILD;
ALTER INDEX gs_gc.ft_x_ntel_i003 REBUILD;
ALTER INDEX gs_gc.ft_x_ntel_i002 REBUILD;
ALTER INDEX gs_gc.ft_x_ntel_i001 REBUILD;

PROMPT after rebuilding the indexes, run the following query using GS_GC_READ to make sure there are no unusable indexes left
PROMPT select index_name from dba_indexes where status = 'UNUSABLE'

PROMPT Drop the table gs_gc.bkp_ft_t_ntel 
DROP TABLE gs_gc.bkp_ft_t_ntel PURGE;

