
TRUNCATE TABLE TOM_TEST_INTERFACE;

INSERT INTO  TOM_TEST_INTERFACE
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', ' rownum < 10' );


DELETE FROM  tom_test_interface_validation;

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'Count'          ,
q'[SELECT SUM(cnt)
FROM (SELECT   count(1) cnt
      FROM     TS_ORDER       o
              ,TS_ORDER_ALLOC a
              ,CSM_SECURITY   s
              ,CS_FUND        f
              ,TOM_LOOKUP_PORTFOLIO_INCLUSION t
              ,SECURITYDBO.XREFERENCE@DBL_EAGLE x
              ,TOM_LOOKUP_PORTFOLIO_MASKING m
      WHERE    o.status = 'ACCT'
      AND      o.settle_date           > TO_DATE(UDF_TOM_GET_REFERENCE_DATA@DBL_EAGLE('DATE'), 'YYYYMMDD')
      AND      o.order_id              = a.order_id
      AND      o.sec_id                = s.sec_id
      AND      s.sec_typ_cd           IN ('CFWD', 'CURR') --CFWD was the 1st union, CURR was the 2nd union
      AND      NVL(s.new_sec_cd, ' ') <> '6'
      AND      a.acct_cd               = f.acct_cd
      AND      f.inactive              = 'N'
      AND      f.acct_typ_cd           = 'F'
      AND      f.acct_cd               NOT LIKE 'BM%'
      AND      f.acct_cd               NOT LIKE 'I%'
      AND      UPPER(f.acct_name)      NOT LIKE '%DUMM%'
      AND      UPPER(f.acct_cd)        NOT LIKE '%DUMMY%'
      AND      f.acct_cd               = t.acct_cd
      AND      t.inclusion_flag        = 'Y'
      AND      TO_CHAR(o.sec_id)       = TRIM(x.xref_security_id)
      AND      x.xref_type             = 'CRTS_SEC_ID'
      AND      a.acct_cd               = m.original_acct_cd
      UNION ALL
      SELECT LEAST(COUNT(PAY_COUNT), COUNT(RCV_COUNT))
      FROM  (SELECT   DECODE(SUBSTR(ticker,8,1), 'P', 1) PAY_COUNT
                     ,DECODE(SUBSTR(ticker,8,1), 'R', 1) RCV_COUNT
             FROM     TS_ORDER       o
                     ,TS_ORDER_ALLOC a
                     ,CSM_SECURITY   s
                     ,CS_FUND        f
                     ,TOM_LOOKUP_PORTFOLIO_INCLUSION t
                     ,SECURITYDBO.XREFERENCE@DBL_EAGLE x
                     ,TOM_LOOKUP_PORTFOLIO_MASKING m
             WHERE    o.status = 'ACCT'
             AND      o.settle_date           > TO_DATE(UDF_TOM_GET_REFERENCE_DATA@DBL_EAGLE('DATE'), 'YYYYMMDD')
             AND      o.order_id              = a.order_id
             AND      o.sec_id                = s.sec_id
             AND      s.sec_typ_cd           IN ('LFWD') --longforwards
             AND      NVL(s.new_sec_cd, ' ') <> '6'
             AND      a.acct_cd               = f.acct_cd
             AND      f.inactive              = 'N'
             AND      f.acct_typ_cd           = 'F'
             AND      f.acct_cd               NOT LIKE 'BM%'
             AND      f.acct_cd               NOT LIKE 'I%'
             AND      UPPER(f.acct_name)      NOT LIKE '%DUMM%'
             AND      UPPER(f.acct_cd)        NOT LIKE '%DUMMY%'
             AND      f.acct_cd               = t.acct_cd
             AND      t.inclusion_flag        = 'Y'
             AND      TO_CHAR(o.sec_id)       = TRIM(x.xref_security_id)
             AND      x.xref_type             = 'CRTS_SEC_ID'
             AND      a.acct_cd               = m.original_acct_cd
             GROUP BY s.ticker
                     ,o.trans_type
                     ,CASE WHEN t.mask_flag='Y' THEN m.masked_acct_cd ELSE a.acct_cd END
                     ,o.exec_broker
                     ,s.sec_id
                     ,TRUNC(o.trade_date)
                     ,TRUNC(s.mature_date)
                     ,TRUNC(settle_date)
                     ,s.loc_crrncy_cd
                     ,a.prin_settle_crrncy
                     ,s.sec_name)
)]'
);


INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'CLIENT_ID'      , 'KEY1'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'PORTFOLIO'      , 'KEY2'
);


INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'SM_SEC_GROUP'   , '''FX''');


INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'SM_SEC_TYPE'   ,
q'[SELECT CASE WHEN s.sec_typ_cd='CURR' THEN 'SPOT'
                    WHEN s.sec_typ_cd IN ('CFWD', 'LFWD') THEN 'FWRD'
       END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'POS_DATE'      ,
q'[SELECT udf_tom_get_reference_data@dbl_eagle('DATE')
FROM   DUAL]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'TRD_TRADE_DATE'    ,
q'[SELECT TO_CHAR(o.trade_date, 'YYYYMMDD')
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
where x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                    END]'
);



INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'TRD_SETTLE_DATE'    ,
q'[SELECT TO_CHAR(o.settle_date, 'YYYYMMDD')
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
where x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                    END]'
);


INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'MATURITY'    ,
q'[SELECT TO_CHAR(CASE WHEN s.sec_typ_cd='CURR' THEN o.settle_date
                       WHEN s.sec_typ_cd IN ('CFWD', 'LFWD') THEN s.mature_date
                  END, 'YYYYMMDD')
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN T.SHORT_ACCT_CD
                         WHEN t.mask_flag='Y' THEN M.MASKED_ACCT_CD
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id ]'
);


INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'TICKER'    ,
q'[SELECT CASE WHEN s.sec_typ_cd <> 'LFWD' AND o.FROM_CRRNCY = a.PRIN_SETTLE_CRRNCY THEN o.TO_CRRNCY
            WHEN s.sec_typ_cd <> 'LFWD' AND o.TO_CRRNCY   = a.PRIN_SETTLE_CRRNCY THEN o.FROM_CRRNCY
            WHEN s.sec_typ_cd = 'LFWD' THEN s.LOC_CRRNCY_CD
       END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN T.SHORT_ACCT_CD
                         WHEN t.mask_flag='Y' THEN M.MASKED_ACCT_CD
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id ]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'POS_FACE'    ,
q'[SELECT CASE WHEN s.sec_typ_cd  = 'CFWD' THEN
                   CASE WHEN SUBSTR(TRIM(s.sec_name),1,4) IN ('Sell') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty * - 1 ELSE a.exec_amt END
                        WHEN SUBSTR(TRIM(s.sec_name),1,3) IN ('Buy') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt * - 1 ELSE a.exec_qty END
                   END
               WHEN s.sec_typ_cd  = 'CURR' THEN
                   CASE WHEN o.trans_type = 'SELLL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty * - 1 ELSE a.exec_amt END
                        WHEN o.trans_type = 'BUYL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt * - 1 ELSE a.exec_qty END
                   END
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'SELL%' THEN a.exec_amt * -1
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'BUY%'  THEN a.exec_amt
               END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
where x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN T.SHORT_ACCT_CD
                         WHEN t.mask_flag='Y' THEN M.MASKED_ACCT_CD
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id ]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'POS_CUR_PAR'    ,
q'[SELECT CASE WHEN s.sec_typ_cd  = 'CFWD' THEN
                   CASE WHEN SUBSTR(TRIM(s.sec_name),1,4) IN ('Sell') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty * - 1 ELSE a.exec_amt END
                        WHEN SUBSTR(TRIM(s.sec_name),1,3) IN ('Buy') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt * - 1 ELSE a.exec_qty END
                   END
               WHEN s.sec_typ_cd  = 'CURR' THEN
                   CASE WHEN o.trans_type = 'SELLL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty * - 1 ELSE a.exec_amt END
                        WHEN o.trans_type = 'BUYL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt * - 1 ELSE a.exec_qty END
                   END
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'SELL%' THEN a.exec_amt * -1 --this might be wrong
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'BUY%'  THEN a.exec_amt
          END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
where x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN T.SHORT_ACCT_CD
                         WHEN t.mask_flag='Y' THEN M.MASKED_ACCT_CD
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id ]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'CURRENCY'   ,
q'[SELECT CASE WHEN s.sec_typ_cd  IN ('CFWD', 'CURR') THEN
                   CASE WHEN o.to_crrncy = a.prin_settle_crrncy THEN o.to_crrncy
                        ELSE o.from_crrncy
                   END
               WHEN s.sec_typ_cd  = 'LFWD' THEN
                   s.loc_crrncy_cd
          END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'TRD_PRINCIPAL'   ,
q'[SELECT CASE WHEN s.sec_typ_cd  = 'CFWD' THEN
                   CASE WHEN SUBSTR(TRIM(s.sec_name),1,4) IN ('Sell') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt ELSE a.exec_qty * - 1 END
                        WHEN SUBSTR(TRIM(s.sec_name),1,3) IN ('Buy') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty ELSE a.exec_amt * - 1 END
                   END
               WHEN s.sec_typ_cd  = 'CURR' THEN
                   CASE WHEN o.trans_type = 'SELLL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt ELSE a.exec_qty * - 1 END
                        WHEN o.trans_type = 'BUYL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty ELSE a.exec_amt * - 1 END
                   END
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'SELL%' THEN a.exec_amt  --this might be wrong
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'BUY%'  THEN a.exec_amt * -1
          END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'TRD_PRINCIPAL'   ,
q'[SELECT CASE WHEN s.sec_typ_cd  = 'CFWD' THEN
                   CASE WHEN SUBSTR(TRIM(s.sec_name),1,4) IN ('Sell') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt ELSE a.exec_qty * - 1 END
                        WHEN SUBSTR(TRIM(s.sec_name),1,3) IN ('Buy') THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty ELSE a.exec_amt * - 1 END
                   END
               WHEN s.sec_typ_cd  = 'CURR' THEN
                   CASE WHEN o.trans_type = 'SELLL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_amt ELSE a.exec_qty * - 1 END
                        WHEN o.trans_type = 'BUYL' THEN
                            CASE WHEN o.to_crrncy  = a.prin_settle_crrncy THEN a.exec_qty ELSE a.exec_amt * - 1 END
                   END
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'SELL%' THEN a.exec_amt  --this might be wrong
               WHEN s.sec_typ_cd  = 'LFWD' AND o.trans_type like 'BUY%'  THEN a.exec_amt * -1
          END
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                         WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                         ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id = s.sec_id]'
);

INSERT INTO  tom_test_interface_validation
VALUES ('Position FX', 'TOM_INTERFACE_POSITION_FX', 'ANNOUNCE_DT'   ,
q'[SELECT TO_CHAR(CASE WHEN s.sec_typ_cd  = 'CFWD' THEN
                      CASE WHEN FN_ISNDFCURR@DBL_TMS(TMS.BUY_CURR_ID)='Y' AND FN_ISNDFCURR@DBL_TMS(TMS.SELL_CURR_ID)='N' THEN TMS.SETTLE_DATE+GETFIXINGDATE@DBL_TMS(TMS.BUY_CURR_ID)
                           WHEN FN_ISNDFCURR@DBL_TMS(TMS.BUY_CURR_ID)='N' AND FN_ISNDFCURR@DBL_TMS(TMS.SELL_CURR_ID)='Y' THEN TMS.SETTLE_DATE+GETFIXINGDATE@DBL_TMS(TMS.SELL_CURR_ID)
                      END
                   END
                 ,'YYYYMMDD')
FROM   SECURITYDBO.XREFERENCE@DBL_EAGLE X
      ,TS_ORDER                         O
      ,TS_ORDER_ALLOC                   A
      ,CS_FUND                          F
      ,TOM_LOOKUP_PORTFOLIO_INCLUSION   T
      ,TOM_LOOKUP_PORTFOLIO_MASKING     M
      ,CSM_SECURITY                     S
      ,TMS_T_TRADE@DBL_TMS              TMS
WHERE x.security_alias   = :CLIENT_ID
AND   x.xref_type        = 'CRTS_SEC_ID'
AND   TO_CHAR(o.sec_id)  = TRIM(x.xref_security_id)
AND   o.order_id         = a.order_id
AND   o.status           = 'ACCT'
AND   a.acct_cd          = f.acct_cd
AND   m.original_acct_cd = a.acct_cd
AND   f.acct_cd          = t.acct_cd
AND   t.inclusion_flag   = 'Y'
AND   :PORTFOLIO = CASE WHEN TRIM(f.acct_cd) LIKE 'PRU_FM%' THEN t.short_acct_cd
                        WHEN t.mask_flag='Y' THEN m.masked_acct_cd
                        ELSE TRIM(f.acct_cd)
                   END
AND   o.sec_id           = s.sec_id
AND   a.trade_id         = tms.trade_id]'
);


COMMIT;

