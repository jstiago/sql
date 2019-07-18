SET TERMOUT OFF

col user_name new_value user_name
col db_name new_value db_name
col my_prompt new_value my_prompt

select
    USER AS user_name
    ,sys_context('USERENV','CON_NAME') AS db_name
    ,chr(10) ||
    '[' ||
    lower(user) ||
    '@' ||
    SUBSTR(sys_context('USERENV','CON_NAME'), 1, 20) ||
    '(' || sid || ',' || serial# || ')'||
    ']' ||
    chr(10) ||
    'SQL> ' as MY_PROMPT
from v$session s
where audsid = sys_context('USERENV', 'SESSIONID');
SET SQLPROMPT '&&MY_PROMPT'
SET TERMOUT ON
HOST TITLE &&user_name@&&db_name
undefine user_name
undefine db_name



set serveroutput on size unlimited format tru
set feedback on
set pagesize 200
set lines 10000
set timing on
set trimspool on

