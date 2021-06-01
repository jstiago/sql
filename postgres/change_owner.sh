#!/bin/bash -ex

schema=${1}
newowner=${2}

echo change table ownerships
for obj in $( psql -qAt \
                  -c "select schemaname || '.' || tablename from pg_tables where schemaname = '$schema';" \
              )
do  
  psql -q -c "alter table ${obj} owner to ${newowner}"
done

echo change sequence ownerships
for obj in $( psql -qAt \
                  -c "select sequence_schema || '.' || sequence_name from information_schema.sequences where sequence_schema = '$schema';" \
              )
do  
  psql -q -c "alter sequence ${obj} owner to ${newowner}"
done

echo change view ownerships
for obj in $( psql -qAt \
                  -c "select table_schema || '.' || table_name from information_schema.views where table_schema = '$schema';" \
              )
do  
  psql -q -c "alter view ${obj} owner to ${newowner}"
done


echo change function ownerships
IFS=$'\n' 
for obj in $( psql -qAt \
                  -c "SELECT n.nspname || '.' || p.proname || '(' || pg_catalog.pg_get_function_identity_arguments(p.oid) || ')' \
                      FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace \
                      WHERE n.nspname = '$schema';" \
              )
do  
  psql -q -c "alter function ${obj} owner to ${newowner}"
done

echo change schema ownership
psql -q -c "alter schema ${schema} owner to ${newowner}"