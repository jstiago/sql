SELECT
   a.client_info
  ,round(sum(decode(c.name, 'session pga memory', b.value)) / 1024 / 1024) AS PGA_MB
  ,round(sum(decode(c.name, 'session uga memory', b.value)) / 1024 / 1024) AS UGA_MB
  ,round(sum(decode(a.server, 'DEDICATED', decode(c.name, 'session pga memory', b.value )
                            , 'SHARED'   , b.value)
             ) / 1024/ 1024) ACTUAL_MB
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
group by a.client_info
ORDER BY actual_mb DESC 
/
