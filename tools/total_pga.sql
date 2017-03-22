SELECT
   c.name, sum(b.value/1024/1024) AS MB
FROM
   v$session a,
   v$sesstat b,
   v$statname c
WHERE
   a.sid = b.sid
AND
   b.statistic# = c.statistic#
AND
   c.name in ('session pga memory', 'session uga memory')
AND
   a.program IS NOT NULL
group by c.name
ORDER BY mb DESC
/
