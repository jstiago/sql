declare
    x number;
    --http://asktom.oracle.com/pls/asktom/f?p=100:11:7725330506142359::::P11_QUESTION_ID:767025833873
begin
    for x in
    ( select username||'('||sid||','||serial#||
                ') ospid = ' ||  process ||
                ' program = ' || program username,
             to_char(LOGON_TIME,' Day HH24:MI') logon_time,
             to_char(sysdate,' Day HH24:MI') current_time,
             sql_address, LAST_CALL_ET
        from v$session
       where status = 'ACTIVE'
         and rawtohex(sql_address) <> '00'
         and username is not null order by last_call_et )
    loop
        for y in ( select max(decode(piece,0,sql_text,null)) ||
                          max(decode(piece,1,sql_text,null)) ||
                          max(decode(piece,2,sql_text,null)) ||
                          max(decode(piece,3,sql_text,null))
                               sql_text
                     from v$sqltext_with_newlines
                    where address = x.sql_address
                      and piece < 4)
        loop
            if ( y.sql_text not like '%listener.get_cmd%' and
                 y.sql_text not like '%RAWTOHEX(SQL_ADDRESS)%')
            then
                dbms_output.put_line( '--------------------' );
                dbms_output.put_line( x.username );
                dbms_output.put_line( x.logon_time || ' ' ||
                                      x.current_time||
                                      ' last et = ' ||
                                      x.LAST_CALL_ET);
                dbms_output.put_line(
                          substr( y.sql_text, 1, 250 ) );
            end if;
        end loop;
    end loop;
end;
/
