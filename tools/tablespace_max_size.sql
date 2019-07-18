select TABLESPACE_NAME, sum(decode(AUTOEXTENSIBLE, 'YES', MAXBYTES, BYTES)) / 1024 / 1024 / 1024 MAX_GB
from   DBA_DATA_FILES
group  by TABLESPACE_NAME
/