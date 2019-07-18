select * from ft_T_fldf where fld_nme  like '%Factor%';  


select * from ft_T_cldf where lower(logl_nme) like '%transaction%'
order by 1, 2


select * from ft_wf_wfri where instance_id = '++6L+u2GgZjzq2pZ';


select jblg.*,trid.*,ntel.*  from ft_t_jblg jblg 
inner join ft_T_trid trid on jblg.job_id=trid.job_id
inner join ft_t_ntel ntel on trid.trn_id=ntel.last_chg_trn_id



select n.*, t.*, l.*
from   fT_t_jblg l, ft_t_trid t, ft_t_ntel n
WHERE  l.job_msg_typ = '&MESSAGE_TYPE'
AND    l.job_id ='&JOB_ID'
AND    l.job_id = t.job_id
AND    t.trn_id = n.last_chg_trn_id
order by l.job_start_tms desc





select job_id,job_stat_typ,job_start_tms,job_end_tms,task_tot_cnt,task_cmpltd_cnt,task_success_cnt,task_failed_cnt,
task_partial_cnt,task_filtered_cnt,job_msg_typ,
job_tme_txt,job_tps_cnt,job_input_txt
from fT_t_jblg 
--WHERE job_stat_typ <> 'CLOSED'
order by job_start_tms desc


select * from fT_cfg_pub1 where start_tms > sysdate - 0.5 order by start_tms desc;



select * from dba_role_privs

select * from user_users


016OOce0gZhjq0Xc


To find the subscription 
======================== 
SELECT * FROM FT_CFG_SBDF WHERE SBDF_OID='++6KyKCmgZjzq019' 

To find the Downstream 
====================== 
SELECT ds.downstream_sys_nme, ds.downstream_sys_desc, loc.*
FROM   ft_t_dwds loc ,ft_t_dwdf ds 
WHERE  loc.DWDF_OID = ds.DWDF_OID

select sbdf.subscription_nme, dwds.* --downstream_dest_val_txt                        
from   ft_cfg_sbdf sbdf                                        
      ,ft_cfg_sbdp sbdp                                        
      ,ft_t_dwds   dwds                                        
where  sbdf.subscription_nme = 'EIS_DMP_TO_BRS_POSITION_FX_SUB'
and    sbdf.sbdf_oid = sbdp.sbdf_oid                           
and    sbdp.dwds_oid = dwds.dwds_oid


select sbdf.subscription_nme, dwds.* --downstream_dest_val_txt                        
from   ft_cfg_sbdf sbdf                                        
      ,ft_cfg_sbdp sbdp                                        
      ,ft_t_dwds   dwds                                        
where  sbdf.sbdf_oid = sbdp.sbdf_oid                           
and    sbdp.dwds_oid = dwds.dwds_oid
