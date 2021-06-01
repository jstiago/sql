select t.owner as schema_name,
       t.table_name
from sys.dba_tables t
left join sys.dba_constraints c
          on t.owner = c.owner
          and t.table_name = c.table_name
          and c.constraint_type = 'P'
where c.constraint_type is null
and   t.owner NOT IN ('SYS', 'SYSTEM', 'SPATIAL_INTEGRATION', 'OUTLN', 'ORDDATA', 'GSMADMIN_INTERNAL', 'LBACSYS', 'XDB', 'WMSYS', 'MDSYS', 'OJVMSYS', 'DBSNMP', 'CTXSYS', 'APPQOSSYS', 'APEX_040200', 'SCT_SPATIAL', 'DVSYS')
and   EXISTS (select 1
                 from   dba_lobs l 
                 where  l.table_name = t.table_name
                 and    l.owner = t.owner)
order by t.owner,
         t.table_name;