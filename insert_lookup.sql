        INSERT INTO TOM_LOOKUP_CRTS_SECURITY_ID
            (
              CRTS_SECURITY_ID,
              SEC_CLASS_TYPE
            )
        SELECT DISTINCT x.SEC_ID, x.SEC_CLASS_TYPE FROM
        (
          SELECT 
             S.SEC_ID AS SEC_ID
            ,F.ACCT_CD
            ,'TRADEABLE' AS SEC_CLASS_TYPE
          FROM tm_dev.cs_position P
            INNER JOIN tm_dev.cs_fund F ON P.ACCT_CD = F.ACCT_CD  AND F.INACTIVE='N' AND F.ACCT_TYP_CD IN('F','M')
            INNER JOIN tm_dev.csm_security S ON P.SEC_ID = S.SEC_ID
          WHERE
              (((S.SEC_TYP_CD IN ('SWAP','IRSWAP','CSWP','IDSP','ESWP') AND SUBSTR(S.SEDOL,LENGTH(SEDOL),1)='R') OR S.SEC_TYP_CD IN ('TRS')) OR S.SEC_TYP_CD NOT IN ('SWAP','IRSWAP','CSWP','IDSP','ESWP'))
          AND UPPER(TRIM(SEC_NAME)) NOT LIKE 'NONTRADEABLE%'
          AND S.SEC_TYP_CD NOT IN ('CFWD','LFWD')
          AND UPPER(F.ACCT_NAME) NOT LIKE '%DUMM%'
          AND UPPER(F.ACCT_CD) NOT LIKE '%DUMMY%'
          AND F.ACCT_CD NOT LIKE 'I%'
          UNION
         SELECT 
             S.SEC_ID AS SEC_ID
            ,F.ACCT_CD
            ,'NONTRADEABLE' AS SEC_CLASS_TYPE
          FROM tm_dev.CS_POSITION P
            INNER JOIN tm_dev.CS_FUND F ON P.ACCT_CD = F.ACCT_CD  AND F.INACTIVE='N' AND F.ACCT_TYP_CD IN('F','M')
            INNER JOIN tm_dev.CSM_SECURITY S ON P.SEC_ID = S.SEC_ID
          WHERE
              UPPER(TRIM(SEC_NAME)) LIKE 'NONTRADEABLE%'
          AND S.SEC_TYP_CD NOT IN ('CFWD','LFWD','CCO','CPO')
          AND UPPER(F.ACCT_NAME) NOT LIKE '%DUMM%'
          AND UPPER(F.ACCT_CD) NOT LIKE '%DUMMY%'
          AND F.ACCT_CD NOT LIKE 'I%'
        ) X INNER JOIN TOM_LOOKUP_PORTFOLIO_INCLUSION PF ON x.ACCT_CD = PF.ACCT_CD AND INCLUSION_FLAG='Y'
/
