SELECT sid, serial#, username, client_info, module, action
FROM   v$session
WHERE  process = '&1'
/
