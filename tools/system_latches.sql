select c.name,a.addr,a.gets,a.misses,a.sleeps,
a.immediate_gets,a.immediate_misses,b.pid
from v$latch a, v$latchholder b, v$latchname c
where a.addr = b.laddr(+)
and a.latch# = c.latch#
order by a.latch#
/
