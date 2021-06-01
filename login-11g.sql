SET TERMOUT OFF
define _editor=vi
col user_name new_value user_name
col my_prompt new_value my_prompt
col my_sid new_value my_sid

select sid AS my_sid
from   v$mystat
where  rownum <=1;

select
    USER AS user_name
    ,chr(10) ||
    '[' ||
    lower(user) ||
    '@' ||
    SUBSTR(d.name, 1, 20) ||
    '(' || sid || ',' || serial# || ')'||
    ']' ||
    chr(10) ||
    'SQL> ' as MY_PROMPT
from v$session s,
     v$database d
where s.sid = &my_sid;

SET SQLPROMPT '&&MY_PROMPT'
SET TERMOUT ON
undefine user_name



set serveroutput on size unlimited format tru
set feedback on
set pagesize 200
set lines 10000
set timing on
set trimspool on
