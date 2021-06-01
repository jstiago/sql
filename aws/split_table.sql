select min(object_id)
      ,max(object_id)
      ,count(*)
      ,nt 
from ( select object_id, ntile(8) over (order by object_id) nt 
       from all_objects)
group by nt;



select min(id)
      ,max(id)
      ,count(*)
      ,nt 
from ( select id, ntile(8) over (order by id) nt 
       from services.i3_doc_store)
group by nt;



select '["' || max(id) || '"],'
from ( select id, ntile(64) over (order by id) nt
       from services.i3_doc_store)
group by nt
order by max(id);

select '["' || max(id) || '"],'
from ( select id, ntile(32) over (order by id) nt
       from titling.dealing_workfile)
group by nt
order by max(id);



select '["' || max(id) || '"],'
from ( select /*+ PARALLEL(32) */ id, ntile(8) over (order by id) nt
       from NEC_BULK.MESSAGE_PAYLOAD)
group by nt
order by max(id);


select '["' || max(id) || '"],'
from ( select /*+ PARALLEL(32) */ id, ntile(64) over (order by id) nt
       from NEC_BULK.MESSAGE_PAYLOAD)
group by nt
order by max(id);


select '["' || max(id) || '"],'
from ( select /*+ PARALLEL(32) */ id, ntile(64) over (order by id) nt
       from logging.i3_request)
group by nt
order by max(id);

select '["' || max(id) || '"],'
from ( select /*+ PARALLEL(32) */ id, ntile(8) over (order by id) nt
       from logging.i3_exception)
group by nt
order by max(id);