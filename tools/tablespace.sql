select TABLESPACE_NAME,
       Round(Sum(total_space)/1024/1024/1024, 2) "Size GBs",
       Round(Sum(free_space)/1024/1024/ 1024, 2) "Free GBs",
       Round(Sum(used_space)/1024/1024/1024, 2) "Used GBs",
       Round(Sum(free_space)/Sum(total_space)*100, 2) "Free Pct",
       Round(Sum(used_space)/Sum(total_space)*100, 2) "Used Pct",
       Round(Sum(total_space)/1024/1024/1024, 2) "Max GBs"
from   (
        select ds.TABLESPACE_NAME, ds.BYTES used_space, To_Number(Null) free_space, To_Number(Null) total_space
        from   dba_segments ds
        union all
        select dfs.TABLESPACE_NAME, To_Number(Null) used_space, dfs.BYTES free_space, To_Number(Null) total_space
        from   dba_free_space dfs
        union all
        select ddf.TABLESPACE_NAME, To_Number(Null) used_space, To_Number(Null) free_space, ddf.BYTES total_space
        from   dba_data_files ddf)
group by TABLESPACE_NAME
order by 1
/
