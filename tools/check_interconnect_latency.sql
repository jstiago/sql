select inst_id, (sum(decode(name, 'gc cr block receive time', value)) + sum(decode(name, 'gc current block receive time', value)) * 10)
      /(sum(decode(name, 'gc cr blocks received', value)) + sum(decode(name, 'gc current blocks received', value))) "Interconnect Latency"
from   gv$sysstat
where  name in ('gc cr block receive time'
               ,'gc current block receive time'
               ,'gc cr blocks received'
               ,'gc current blocks received')
group by inst_id
/
