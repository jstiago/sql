CREATE MATERIALIZED VIEW "GS_DW"."FT_MV_EXP_TYP" ("NOTFCN_CRTE_TMS", "INPUT_MSG_TYP", "TRN_USR_STAT_TYP", "EXCP_TYP", "NOTFCN_SHORT_TXT", "USR_CAT_TYP", "NLS_CDE", "NOTFCN_ID", "MSG_STAT_TYP", "BASE_PRTY_PT_NUM", "MSG_SEVERITY_CDE", "SOURCE_ID", "APPL_ID", "PART_ID", "CNT") USING ("FT_MV_EXP_TYP", (10, 'ESDWHP', 4, 0, 0, "GS_DW", "FT_T_MSGV", '2017-04-03 15:45:58', 262152, 93441, '2017-04-
24-MAY-18 18:14:14.677: ORA-31685: Object type MATERIALIZED_VIEW:"GS_DW"."FT_MV_TRID_STAT" failed due to insufficient privileges. Failing sql is:
CREATE MATERIALIZED VIEW "GS_DW"."FT_MV_TRID_STAT" ("TRID_UPD_DTE", "INPUT_MSG_TYP", "CRRNT_TRN_STAT_TYP", "TRN_USR_STAT_TYP", "CRRNT_SEVERITY_CDE", "CNT") USING ("FT_MV_TRID_STAT", (10, 'ESDWHP', 1, 0, 0, "GS_DW", "FT_T_TRID", '2017-04-03 15:46:00', 262408, 93312, '2017-04-12 04:29:52', '', 1, '380404', 0, 0, NULL), 1589313, 10, ('1950-01-01 12:00:00', 2, 0, 0, 0, 0, 0, 0, 36, NULL, NUL


DROP TABLE FT_MV_TRID_STAT 
/
CREATE MATERIALIZED VIEW FT_MV_EXP_TYP
  LOGGING
  TABLESPACE dw_data
  PCTFREE 10
  INITRANS 1
  STORAGE
  (
    BUFFER_POOL DEFAULT
  )
  NOCOMPRESS
  NOCACHE
  PARALLEL AS
  SELECT   TRUNC (ft_t_msgv.notfcn_crte_tms) AS notfcn_crte_tms,
           ft_t_trid.input_msg_typ, ft_t_trid.trn_usr_stat_typ,
           ft_t_ntdf.excp_typ, ft_t_ntxt.notfcn_short_txt,
           ft_t_ntxt.usr_cat_typ, ft_t_ntxt.nls_cde, ft_t_msgv.notfcn_id,
           ft_t_msgv.msg_stat_typ, ft_t_msgv.base_prty_pt_num,
           ft_t_msgv.msg_severity_cde, ft_t_msgv.source_id, ft_t_msgv.appl_id,
           ft_t_msgv.part_id, COUNT (*) cnt
      FROM ft_t_trid, ft_t_ntdf, ft_t_ntxt, ft_t_msgv
     WHERE ft_t_msgv.notfcn_id = ft_t_ntdf.notfcn_id
       AND ft_t_msgv.part_id = ft_t_ntdf.part_id
       AND ft_t_msgv.appl_id = ft_t_ntdf.appl_id
       AND ft_t_ntdf.notfcn_id = ft_t_ntxt.notfcn_id
       AND ft_t_ntdf.part_id = ft_t_ntxt.part_id
       AND ft_t_ntdf.appl_id = ft_t_ntxt.appl_id
       AND ft_t_msgv.trn_id = ft_t_trid.trn_id
  GROUP BY TRUNC (ft_t_msgv.notfcn_crte_tms),
           ft_t_trid.input_msg_typ,
           ft_t_trid.trn_usr_stat_typ,
           ft_t_ntdf.excp_typ,
           ft_t_ntxt.notfcn_short_txt,
           ft_t_ntxt.usr_cat_typ,
           ft_t_ntxt.nls_cde,
           ft_t_msgv.notfcn_id,
           ft_t_msgv.msg_stat_typ,
           ft_t_msgv.base_prty_pt_num,
           ft_t_msgv.msg_severity_cde,
           ft_t_msgv.source_id,
           ft_t_msgv.appl_id,
           ft_t_msgv.part_id
/
DROP TABLE FT_MV_TRID_STAT 
/
CREATE MATERIALIZED VIEW GS_DW.FT_MV_TRID_STAT 
LOGGING 
TABLESPACE DW_DATA
PCTFREE 10 
INITRANS 2 
STORAGE 
( 
  INITIAL 65536 
  NEXT 1048576 
  MINEXTENTS 1 
  MAXEXTENTS UNLIMITED 
  PCTINCREASE 0 
  BUFFER_POOL DEFAULT 
) 
NOCOMPRESS 
NOCACHE 
PARALLEL 
BUILD DEFERRED 
USING INDEX 
REFRESH ON DEMAND 
FORCE 
USING DEFAULT LOCAL ROLLBACK SEGMENT 
ENABLE QUERY REWRITE AS 
SELECT trunc(last_upd_tms) trid_upd_dte, input_msg_typ, crrnt_trn_stat_typ,trn_usr_stat_typ,crrnt_severity_cde, count(*) cnt
					    FROM ft_t_trid
					GROUP BY trunc(last_upd_tms),input_msg_typ,crrnt_trn_stat_typ,trn_usr_stat_typ,crrnt_severity_cde
/




