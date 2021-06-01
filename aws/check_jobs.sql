col owner_name for a15
col job_name for a30
col state for a20

select owner_name, job_name, state 
from dba_datapump_jobs
/
