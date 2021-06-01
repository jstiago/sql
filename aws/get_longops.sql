select username, sid, serial#, opname, sofar, totalwork, round(time_remaining / 60, 2) mins_remaining, context, message
from v$session_longops
where sofar < totalwork;