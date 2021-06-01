select opname, target, target_desc, sofar, time_remaining from v$session_longops where sid = &1
/
