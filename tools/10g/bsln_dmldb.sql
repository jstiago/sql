Rem
Rem $Header: bsln_dmldb.sql 27-jan-2005.03:39:48 jberesni Exp $
Rem
Rem bsln_dmldb.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      bsln_dmldb.sql - baseline DML for database
Rem
Rem    DESCRIPTION
Rem      Loads eligible metrics for Oracle 10g deployments
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jberesni    01/27/05 - remove registration
Rem    jberesni    09/27/04 - add 2123 and 2121 
Rem    jberesni    09/10/04 - rdbms lrg 1739821 
Rem    jberesni    08/13/04 - default baselines 
Rem    jberesni    07/30/04 - jberesni_dailycompute
Rem    jberesni    07/28/04 - Created
Rem


declare
   -------------------------------------------------------------
   -- table of metric_ids to register
   -- NOTE: need to add 2123 and 2121 when server supports them
   -------------------------------------------------------------
   type mid_tbl_t is table of integer;
   mid_tbl mid_tbl_t := mid_tbl_t(2106,2109,2031,2045,2066
                                 ,2072,2003,2026,2103,2004
                                 ,2006,2058,2016,2123,2121);
begin
   for i in mid_tbl.FIRST..mid_tbl.LAST
   loop
      begin
      --------------------------------
      -- insert into eligible metrics 
      --------------------------------
      insert into mgmt_bsln_metrics
         (METRIC_UID
         ,TAIL_ESTIMATOR
         ,THRESHOLD_METHOD_DEFAULT
         ,NUM_OCCURRENCES_DEFAULT
         ,WARNING_PARAM_DEFAULT
         ,CRITICAL_PARAM_DEFAULT
         )
      values
         (mgmt_bsln.metric_uid(mid_tbl(i))
         ,'EXPTAIL'
         ,mgmt_bsln.K_METHOD_SIGLVL
         ,mgmt_bsln.K_DEFAULT_NUM_OCCURS
         ,mgmt_bsln.K_SIGLVL_999
         ,mgmt_bsln.K_SIGLVL_9999
         );
      exception 
         -------------------------------
         -- ignore duplicates
         -------------------------------
         when DUP_VAL_ON_INDEX
         then null;
      end;
   end loop;
   commit;

end;
/



