select 'v_' || COLUMN_NAME || ' ' || TABLE_NAME || '.' || COLUMN_NAME || '%TYPE;'
from user_tab_columns
where table_NAME = :TABLE_NAME;

select 'PKG_UTILS.IS_CHANGED(v_' || COLUMN_NAME || ', rec.' || COLUMN_NAME || ') OR '
from   user_tab_columns
where table_NAME = :TABLE_NAME;

select ',' || COLUMN_NAME || ' = rec.' || COLUMN_NAME
from   user_tab_columns
where table_NAME = :TABLE_NAME;