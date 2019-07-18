select DISTINCT 'GRANT ' || DECODE(REFERENCED_TYPE, 'FUNCTION', ' EXECUTE ', ' SELECT ') || 'ON ' || REFERENCED_OWNER || '.' || REFERENCED_NAME || ' TO EGL_TOM;' 
from   user_dependencies
where  name like '%TOM%'
and    referenced_name not like '%TOM%'
and    referenced_owner not in ('PUBLIC', 'SYS')
and    referenced_name not in ('DUAL', 'USER_TAB_COLS')
AND    REFERENCED_TYPE <> 'NON-EXISTENT'
ORDER BY 1


GRANT  SELECT ON EGLPRU.PAM_FINCAD_DATA TO EGL_TOM;
GRANT  SELECT ON EGLPRU.TS_ORDER TO EGL_TOM;
GRANT  SELECT ON EGLPRU.TS_ORDER_ALLOC TO EGL_TOM;