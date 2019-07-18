select	s.USERNAME,
        s.MODULE,
        s.CLIENT_INFO,
	io.CONSISTENT_GETS,
        io.BLOCK_GETS,
        io.PHYSICAL_READS,
        ((io.CONSISTENT_GETS+io.BLOCK_GETS-io.PHYSICAL_READS) / (io.CONSISTENT_GETS+io.BLOCK_GETS)) Ratio
from 	v$session s, v$sess_io io
where 	s.SID = io.SID
and 	(io.CONSISTENT_GETS+io.BLOCK_GETS) > 0
and 	s.USERNAME is not null
order	by ((io.CONSISTENT_GETS+io.BLOCK_GETS-io.PHYSICAL_READS) / (io.CONSISTENT_GETS+io.BLOCK_GETS))
/
