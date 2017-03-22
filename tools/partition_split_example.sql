declare 

v_sql   varchar2(2000);
v_fut_high_val_daily integer := 36;
v_fut_high_val_month integer := 16;
v_current_high_val  integer;
tmp varchar2(30);
lv_query   varchar2(2000);
begin 

for cnt in (select table_name , max(partition_name ) partition_name 
    				 from dba_tab_partitions
		  			where table_owner = 'RSR'
							and (partition_name not like 'YEAR%' and  partition_name not like 'QUARTE%')
							and (partition_name  like 'MONTH%'
							)
							and table_name in ('MODEL_MAP_APPROACH',
																	'PHOENIX_BIC_SECTOR_MAPPING',
																	'PHOENIX_NON_SOVEREIGNS',
																	'PHOENIX_FINANCE_LGD'
																)
							group by table_name , substr(partition_name, 1, instr(partition_name, '_')-1) 
							order by 1,2
			   )
loop 
    
     if cnt.partition_name like 'MONTH%'
     then 
          v_current_high_val := substr(cnt.partition_name,instr(cnt.partition_name,'_',1,2)+1 );
          
          v_current_high_val := v_current_high_val+1;  
          loop 
          exit when (v_current_high_val = v_fut_high_val_month);
          tmp:= trim(to_char(v_current_high_val,'09'));        
          v_sql := 'ALTER TABLE '||CNT.TABLE_NAME ||' SPLIT PARTITION QUARTER_END_01  AT ('||''''||'MONTH-END-'||tmp||'-'||''')'
                    ||' INTO (PARTITION MONTH_END_'||tmp||', PARTITION QUARTER_END_01)';
         
          dbms_output.put_line(' value is '||v_sql);
         begin 
          execute immediate  v_sql;
          v_current_high_val := v_current_high_val+1;           
         exception
         when others then 
            dbms_output.put_line(' Failed for table '||cnt.table_name);
         end;
        end loop;
    
     end if;
 
end loop ;

FOR lv_rec IN(SELECT   DISTINCT 'index' as object_type, 
								dbs.partition_name, 
								dbi.table_name, 
								dbs.segment_name, 
								dbs.bytes 
						FROM   dba_segments dbs, dba_indexes dbi 
						WHERE   (dbi.table_name,NVL(dbs.partition_name,' ')) IN 
										( select table_name ,  partition_name 
    				           from  dba_tab_partitions
							  			 where table_owner = 'RSR'
												and (partition_name not like 'YEAR%' and  partition_name not like 'QUARTE%')
												and (--partition_name  like 'DAILY%' or 
												partition_name  like 'MONTH%')
												and table_name in ('MODEL_MAP_APPROACH',
																       	'PHOENIX_BIC_SECTOR_MAPPING',
																	      'PHOENIX_NON_SOVEREIGNS',
																   	    'PHOENIX_FINANCE_LGD'
																					)
								      ) 
															AND   dbi.index_name = dbs.segment_name 
										AND   dbs.owner      = dbi.owner 
										AND   dbs.owner ='RSR'
										) 
LOOP 

IF lv_rec.partition_name IS NOT NULL 
THEN 
lv_query := 'ALTER INDEX '||lv_rec.segment_name||' REBUILD PARTITION '||lv_rec.partition_name; 
ELSE 
lv_query := 'ALTER INDEX '||lv_rec.segment_name||' REBUILD'; 
END IF; 

EXECUTE IMMEDIATE lv_query; 


END LOOP; 


exception
when others
then 

		dbms_output.put_line(' error'||sqlcode||sqlerrm);

end ;
/
  