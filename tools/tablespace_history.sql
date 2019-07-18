select RDATE
      ,USED_SIZE
      ,lead(USED_SIZE, 1) over (order by RDATE) - USED_SIZE
from   (select t.TSNAME
              ,to_char(to_date(substr(RTIME, 1, 10), 'mm/dd/yyyy'), 'mm/dd/yyyy day') RDATE
              ,max(TABLESPACE_SIZE * 8192) / 1024 / 1024 / 1024                       TABLESPACE_SIZE
              ,max(TABLESPACE_MAXSIZE * 8192) / 1024 / 1024 / 1024                    MAX_SIZE
              ,max(TABLESPACE_USEDSIZE * 8192) / 1024 / 1024 / 1024                   USED_SIZE
        from   DBA_HIST_TBSPC_SPACE_USAGE u, DBA_HIST_TABLESPACE_STAT t
        where  u.SNAP_ID = t.SNAP_ID
        and    u.DBID = t.DBID
        and    u.TABLESPACE_ID = t.TS#
        and    t.TSNAME = '&TABLESPACE_NAME'
        group by t.TSNAME , substr(RTIME, 1, 10)
       )
order by RDATE
/
