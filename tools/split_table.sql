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



select
      max(id)
from ( select id, ntile(8) over (order by id) nt
       from services.i3_doc_store)
group by nt
ORDER BY 1;