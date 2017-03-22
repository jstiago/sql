select * from dba_audit_trail
where owner = 'ADWGP_IVC_RSTMT'
and   obj_name = 'ORG_DERIV_IVC_AS_STG2_PLC'
order by timestamp desc



select * from dba_audit_trail
where obj_name = 'OSA_FIVCAS_CUST_898_000'
order by timestamp desc


select OS_USERNAME
,USERNAME
,USERHOST
,TERMINAL
,TIMESTAMP
,OWNER
,OBJ_NAME
,ACTION from dba_audit_trail
where owner like 'RAMGP_FIVCAR%'
order by timestamp desc



col OS_USERNAME FOR A30
col USERNAME    FOR A30
col USERHOST    FOR A30
col TERMINAL    FOR A30
col OWNER       FOR A30
col OBJ_NAME    FOR A30
col ACTION      FOR A30


