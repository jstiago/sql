declare
  v_clob clob;
begin
  for r_lob in (select AUSR_CONFIG_BLOB
                from   FT_D_AUSR
                where  GROUP_NAME = 'GoldenCopy')
  loop
    v_clob := UTL_RAW.CAST_TO_VARCHAR2( r_lob.ausr_config_blob );
    
    dbms_output.put_line(v_clob);

  end loop;
end;
/


select UTL_RAW.CAST_TO_VARCHAR2(AUSR_CONFIG_BLOB)
                from   FT_D_AUSR
                where  GROUP_NAME = 'GoldenCopy';
                
select UTL_RAW.CAST_TO_VARCHAR2(DEPLOY_DEST_CONFIG_BLOB)
                from   FT_D_DDST
                where  GROUP_NAME = 'GoldenCopy';

                
select UTL_RAW.CAST_TO_VARCHAR2(AUSR_CONFIG_BLOB)
                from   FT_D_AUSR
                where  GROUP_NAME = 'VendorDetails';                
                
select UTL_RAW.CAST_TO_VARCHAR2(DEPLOY_DEST_CONFIG_BLOB)
                from   FT_D_DDST
                where  GROUP_NAME = 'VendorDetails';                