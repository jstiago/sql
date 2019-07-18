col client_info for a30
col username for a20
col module for a30
SELECT
   a.client_info,
   NVL(a.username,'(oracle)') AS username,
   a.module,
   Trunc(b.value/1024/1024) AS PGA_MB
FROM
   v$session a,
   v$sesstat b,
   v$statname c
WHERE
   a.sid = b.sid
AND
   b.statistic# = c.statistic#
AND
   c.name = 'session pga memory'
AND
   a.program IS NOT NULL
ORDER BY b.value DESC
/
