select s.sid, s.serial#, s.event, s.status, o.object_name, o.subobject_name, s.row_wait_obj#
from   v$session s, v$px_session p, dba_objects o
where  p.qcsid = &1
AND    s.SID                    = p.SID
AND    s.SERIAL#                = p.SERIAL#
and    s.row_wait_obj# = o.object_id
/
