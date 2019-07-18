select REPLACE(REPLACE(REPLACE('ALTER TABLE %table_name% ADD PARTITION %partition_name% values (%CLIENT_NO%);', '%table_name%', TABLE_NAME), '%partition_name%', SUBSTR(PARTITION_NAME, 1, length(partition_name) - 3) || :new_client_no), '%CLIENT_NO%', :new_client_no')
from user_tab_partitions
where substr(partition_name, length(partition_name) - 3 + 1, 3) = :old_client_no

select REPLACE(REPLACE('ALTER TABLE %table_name% DROP PARTITION %partition_name%;', '%table_name%', TABLE_NAME), '%partition_name%', PARTITION_NAME)
from user_tab_partitions
where substr(partition_name, length(partition_name) - 3 + 1, 3) = :old_client_no --350

select REPLACE(REPLACE(REPLACE('ALTER TABLE %TABLE% ADD PARTITION %PARTITION%P%CLIENT_NO% VALUES(%CLIENT_NO%);', '%TABLE%', TABLE_NAME), '%PARTITION%', SUBSTR(TABLE_NAME, 1, INSTR(TABLE_NAME, '_') - 1)), '%CLIENT_NO%', '304')
from   user_tables
where  partitioned = 'YES'
and    TABLE_NAME not IN (select table_name from user_tab_partitions where substr(partition_name, length(partition_name) - 3 + 1, 3) = '304')
