select s.sid, s.serial#, s.event, s.status, o.object_name, o.subobject_name, s.row_wait_obj#
from   v$session s, dba_objects o
where  s.SID                    = &1
and    s.row_wait_obj# = o.object_id
/
