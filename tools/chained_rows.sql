ANALYZE TABLE GL_CURRENT_POSTINGS PARTITION (FISS_LONDON_EARLY) LIST CHAINED ROWS INTO CHAINED_ROWS; 


create table CHAINED_ROWS (
owner_name         varchar2(30),
table_name         varchar2(30),
cluster_name       varchar2(30),
partition_name     varchar2(30),
subpartition_name  varchar2(30),
head_rowid         rowid,
analyze_timestamp  date
);


