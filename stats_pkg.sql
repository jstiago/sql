CREATE OR REPLACE PACKAGE BODY stats_pkg AS

    PROCEDURE gather_table_stats(i_table_name IN VARCHAR2
                                ,i_partition_name IN VARCHAR2 DEFAULT NULL)
    IS
    BEGIN
        DBMS_STATS.GATHER_TABLE_STATS('GS_GC'
                                     ,i_table_name 
                                     ,i_partition_name
                                     ,cascade => true);     
    END gather_table_stats;

END stats_pkg;
/
