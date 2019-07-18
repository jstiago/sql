select a.name from v$latchname a, v$latch b
where b.addr = '&addr'
and b.latch#=a.latch#
/
