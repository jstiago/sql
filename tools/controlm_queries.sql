--ctrlm/ctrlm1406@ctm4p301
--ctrlm/ctrlm1406@ctm5p101
select trim(nodeid) nodeid
      ,trim(schedtab) schedtab
      ,trim(jobname) jobname
      ,to_char(to_date(TRIM(startrun), 'yyyymmddhh24miss'), 'dd-mon-yyyy hh24:mi:ss') STARTRUN
      ,to_chaR(to_date(TRIM(endrun), 'yyyymmddhh24miss'), 'dd-mon-yyyy hh24:mi:ss')  ENDRUN
from   CMR_AJF
where  NODEID = 'bdhp4430'
and    SCHEDTAB like 'ADWGZFK2%'
and    TRIM(STARTRUN) is not null