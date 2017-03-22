--total cursors open, by session
SELECT a.VALUE
      ,s.USERNAME
      ,s.SID
      ,s.SERIAL#
FROM   V$SESSTAT  a
      ,V$STATNAME b
      ,V$SESSION  s
WHERE  a.STATISTIC# = b.STATISTIC#
AND    s.SID        = a.SID
AND    b.NAME       = 'opened cursors current';