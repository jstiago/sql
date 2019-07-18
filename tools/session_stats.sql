select  nvl(ss.USERNAME,'ORACLE PROC') username,
    se.SID,
    sn.NAME stastic,
    VALUE usage
from     v$session ss,
    v$sesstat se,
    v$statname sn
where      se.STATISTIC# = sn.STATISTIC#
and      se.SID = &SID
and      se.SID = ss.SID
and    se.VALUE > 0
order BY     se.VALUE desc
/
