  CREATE OR REPLACE VIEW "GS_VD"."FT_V_UIWA" ("TOKEN_ID", "REFERENCEID", "WORKFLOW_NME", "WF_USER_NME", "WF_USER_GRP_NME", "SLA_BREACH_DAYS_CNT", "SLA_DAYS_CNT", "USR_TASK_NME", "PREV_TOKEN_ID", "INSTANCE_ID", "CREATED_TMS", "USR_TASK_ID", "USR_SUBTASK_ID", "MAIN_CROSS_REF_ID", "MAIN_ENTITY_ID", "MAIN_ENTITY_NME", "ASGN_AUSR_OID", "ASGN_USR_GRP_OID", "USER_INSTRUC_TXT", "MODL_ID", "ENTITY_KEY_TXT", "MAIN_ENTITY_ID_CTXT_TYP", "MAIN_ENTITY_TBL_ID", "RESULT_CDE", "SUSPENDED_IND", "SUSPEND_CMNT_TXT", "PAY_LOAD_CLOB", "SUPERVISOR_AUSR_OID", "SUPERVISOR_USR_GRP_OID", "PREV_COMMENTS", "PREV_USR_SUBTASK_ID", "PREV_TASK_ACTION_CDE", "LAST_CHG_USR", "PREV_USR_GRP", "PREV_RESULT_CDE", "OLD_CMPLT_LEVEL_CDE", "REASGN_AUSR_OID", "REASGN_USR_GRP_OID", "LAST_CHG_USR_ID", "CREATED_USR_ID", "USER_ACTION_CDE", "SUBMIT_ACTION_CDE", "CMPLT_LEVEL_CDE", "WORKFLOW_STATUS", "ORIG_CREATED_TMS") AS
  SELECT   FT_WF_UIWA."TOKEN_ID",
            FT_WF_UIWA."REFERENCEID",
            FT_WF_UIWA."WORKFLOW_NME",
                        FT_WF_UIWA."WF_USER_NME",
            FT_WF_UIWA."WF_USER_GRP_NME",
            FT_WF_UIWA."SLA_BREACH_DAYS_CNT",
            FT_WF_UIWA."SLA_DAYS_CNT",
            FT_WF_UIWA."USR_TASK_NME",
            FT_WF_UIWA."PREV_TOKEN_ID",
            FT_WF_UIWA."INSTANCE_ID",
            FT_WF_UIWA."CREATED_TMS",
            FT_WF_UIWA."USR_TASK_ID",
            FT_WF_UIWA."USR_SUBTASK_ID",
            FT_WF_UIWA."MAIN_CROSS_REF_ID",
            FT_WF_UIWA."MAIN_ENTITY_ID",
            FT_WF_UIWA."MAIN_ENTITY_NME",
            FT_WF_UIWA."ASGN_AUSR_OID",
            FT_WF_UIWA."ASGN_USR_GRP_OID",
            FT_WF_UIWA."USER_INSTRUC_TXT",
            FT_WF_UIWA."MODL_ID",
            FT_WF_UIWA."ENTITY_KEY_TXT",
            FT_WF_UIWA."MAIN_ENTITY_ID_CTXT_TYP",
            FT_WF_UIWA."MAIN_ENTITY_TBL_ID",
            FT_WF_UIWA."RESULT_CDE",
            FT_WF_UIWA."SUSPENDED_IND",
            FT_WF_UIWA."SUSPEND_CMNT_TXT",
            FT_WF_UIWA."PAY_LOAD_CLOB",
            FT_WF_UIWA."SUPERVISOR_AUSR_OID",
            FT_WF_UIWA."SUPERVISOR_USR_GRP_OID",
            FT_WF_UIWA."PREV_COMMENTS",
            FT_WF_UIWA."PREV_USR_SUBTASK_ID",
            FT_WF_UIWA."PREV_TASK_ACTION_CDE",
            FT_WF_UIWA."LAST_CHG_USR",
            FT_WF_UIWA."PREV_USR_GRP",
            FT_WF_UIWA."PREV_RESULT_CDE",
            FT_WF_UIWA."OLD_CMPLT_LEVEL_CDE",
            FT_WF_UIWA."REASGN_AUSR_OID",
            FT_WF_UIWA."REASGN_USR_GRP_OID",
            FT_WF_UIWA."LAST_CHG_USR_ID",
            FT_WF_UIWA."CREATED_USR_ID",
            FT_WF_UIWA."USER_ACTION_CDE",
            FT_WF_UIWA."SUBMIT_ACTION_CDE",
            FT_WF_UIWA."CMPLT_LEVEL_CDE",
            CASE
               WHEN RESULT_CDE = 0 AND PREV_RESULT_CDE = 1
               THEN
                  'REJECTED_PENDING'
               WHEN RESULT_CDE = 0 AND PREV_RESULT_CDE = 5
               THEN
                  'REASSIGNED_PENDING'
               WHEN RESULT_CDE = 0
                    AND (PREV_RESULT_CDE = 2 OR PREV_RESULT_CDE IS NULL)
               THEN
                  'PENDING'
               WHEN RESULT_CDE = 4
               THEN
                  'CLOSED'
               WHEN (RESULT_CDE = 0 OR RESULT_CDE IS NULL)
                    AND PREV_RESULT_CDE = 4
               THEN
                  'UNKNOWN_ERROR'
               WHEN RESULT_CDE = 0 AND PREV_RESULT_CDE = 3
               THEN
                  'SUSPENDED_PENDING'
               WHEN RESULT_CDE = 2
               THEN
                  'COMPLETED'
            END
               AS WORKFLOW_STATUS,
               ORIG_CREATED_TMS
     FROM   (SELECT   F.TOKEN_ID,
                      F.TOKEN_ID AS REFERENCEID,
                      D.WORKFLOW_NME,
                                          F.WF_USER_NME,
                      F.WF_USER_GRP_NME,
                      (SELECT   B.SLA_BREACH_DAYS_CNT
                         FROM   FT_WF_USBH B
                        WHERE   B.TOKEN_ID = F.TOKEN_ID
                                AND B.START_TMS =
                                      (SELECT   MAX (START_TMS)
                                         FROM   FT_WF_USBH BH
                                        WHERE   BH.TOKEN_ID = F.TOKEN_ID
                                                AND ROWNUM = 1)
                                AND ROWNUM = 1)
                         AS SLA_BREACH_DAYS_CNT,
                      (SELECT   SLA_ASSIGN_DAYS_CNT
                         FROM   FT_WF_USLA USLA
                        WHERE   USLA.USR_TASK_ID = F.USR_TASK_ID
                                AND (USLA.SUB_TASK_ID IS NULL
                                     OR USLA.SUB_TASK_ID = F.USR_SUBTASK_ID)
                                AND ROWNUM = 1)
                         AS SLA_DAYS_CNT,
                      U.USR_TASK_NME,
                      F.PREV_TOKEN_ID,
                      F.INSTANCE_ID,
                      F.CREATED_TMS,
                      F.USR_TASK_ID,
                      F.USR_SUBTASK_ID,
                      F.MAIN_CROSS_REF_ID,
                      F.MAIN_ENTITY_ID,
                      F.MAIN_ENTITY_NME,
                      F.ASGN_AUSR_OID,
                      F.ASGN_USR_GRP_OID,
                      F.USER_INSTRUC_TXT,
                      F.MODL_ID,
                      F.ENTITY_KEY_TXT,
                      F.MAIN_ENTITY_ID_CTXT_TYP,
                      F.MAIN_ENTITY_TBL_ID,
                      F.RESULT_CDE,
                      F.SUSPENDED_IND,
                      F.SUSPEND_CMNT_TXT,
                      F.PAY_LOAD_CLOB,
                      F.SUPERVISOR_AUSR_OID,
                      F.SUPERVISOR_USR_GRP_OID,
                      (SELECT   UW.USER_INSTRUC_TXT
                         FROM   FT_WF_UIWA UW
                        WHERE   UW.TOKEN_ID = F.PREV_TOKEN_ID)
                         AS PREV_COMMENTS,
                      (SELECT   UW.USR_SUBTASK_ID
                         FROM   FT_WF_UIWA UW
                        WHERE   UW.TOKEN_ID = F.PREV_TOKEN_ID)
                         AS PREV_USR_SUBTASK_ID,
                      (SELECT   UW.RESULT_CDE
                         FROM   FT_WF_UIWA UW
                        WHERE   UW.TOKEN_ID IN
                                      (SELECT   PREV_TOKEN_ID
                                         FROM   FT_WF_UIWA UV
                                        WHERE   UV.TOKEN_ID = F.PREV_TOKEN_ID))
                         AS PREV_TASK_ACTION_CDE,
                      NVL ( (SELECT   LAST_CHG_USR_ID
                               FROM   FT_WF_UIWA UW
                              WHERE   UW.TOKEN_ID = F.PREV_TOKEN_ID),
                           (SELECT   CREATED_USR_ID
                              FROM   FT_WF_UIWA UW
                             WHERE   UW.TOKEN_ID = F.TOKEN_ID))
                         AS LAST_CHG_USR,
                      NVL (
                         (SELECT   USR_GRP_ID
                            FROM   FT_T_AUGR
                           WHERE   USR_GRP_OID IN
                                         (SELECT   UW.ASGN_USR_GRP_OID
                                            FROM   FT_WF_UIWA UW
                                           WHERE   UW.TOKEN_ID =
                                                      F.PREV_TOKEN_ID)),
                         (SELECT   USR_GRP_ID
                            FROM   FT_T_AUGR
                           WHERE   USR_GRP_OID IN
                                         (SELECT   UW.ASGN_USR_GRP_OID
                                            FROM   FT_WF_UIWA UW
                                           WHERE   UW.TOKEN_ID = F.TOKEN_ID
                                                   AND PREV_TOKEN_ID IS NOT NULL))
                      )
                         AS PREV_USR_GRP,
                      (SELECT   RESULT_CDE
                         FROM   FT_WF_UIWA UW
                        WHERE   TOKEN_ID = F.PREV_TOKEN_ID)
                         AS PREV_RESULT_CDE,
                      (SELECT   CMPLT_LEVEL_CDE
                         FROM   FT_WF_UIWA UW
                        WHERE   TOKEN_ID = F.PREV_TOKEN_ID)
                         AS OLD_CMPLT_LEVEL_CDE,
                      F.REASGN_AUSR_OID,
                      F.REASGN_USR_GRP_OID,
                      F.LAST_CHG_USR_ID,
                      F.CREATED_USR_ID,
                      F.USER_ACTION_CDE,
                      F.SUBMIT_ACTION_CDE,
                      NVL (F.CMPLT_LEVEL_CDE, 1) CMPLT_LEVEL_CDE,
                      FT_F_GET_ORIG_CREATED_TMS(F.TOKEN_ID, 1) AS ORIG_CREATED_TMS
               FROM   FT_WF_UIWA F,
                      FT_WF_WFRI W,
                      FT_WF_WFDF D,
                      FT_WF_UTSK U
              WHERE       F.INSTANCE_ID = W.INSTANCE_ID
                      AND D.WORKFLOW_ID = W.WORKFLOW_ID
                      AND F.USR_TASK_ID = U.USR_TASK_ID
                      AND 1 = 1) FT_WF_UIWA
/

























