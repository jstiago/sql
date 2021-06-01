select table_name, round(pg_relation_size(quote_ident(table_name))::DECIMAL / 1024 / 1024, 2) "Table (MB)", round(pg_indexes_size(quote_ident(table_name))::DECIMAL / 1024 / 1024, 2) "Indexes (MB)"
from information_schema.tables
where table_schema = 'public'
order by 2;



SELECT relname, indexrelname, round(pg_relation_size(indexrelname::text)::DECIMAL / 1024 / 1024, 2) "Index (MB)"
    FROM pg_stat_all_indexes 
    WHERE schemaname = 'public'
    order by 1;