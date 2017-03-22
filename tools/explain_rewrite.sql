DECLARE
l_stmt VARCHAR2 (4000);
BEGIN

l_stmt :=
   ' select  ''PH'' || LT1.PROD_9_ID ,     '
|| ' ''CA9900000001'' ,                    '
|| ' ''G5'' || LT4.GEO_5_ID ,              '
|| '  ''R1'' || LT5.PROFT_CTR_1_ID ,       '
|| '   ''D190'' , ''T3'' || LT8.MTH_SKID , '
|| ' SUM(FT11.MSU_SH) FROM RAMGP_SA0M_V2.OSA_SA0M_SHPMT_HIST_FCT_V1 FT11, RAMGP_SA0M_V2.OSA_SA0M_GEO_705_VW LT4, RAMGP_SA0M_V2.OSA_SA0M_PROD_5005_000_VW LT1, '
|| ' RAMGP_SA0M_V2.OSA_SA0M_PROFT_CTR_064_VW LT5, RAMGP_SA0M_V2.OSA_SA0M_TIME_660_VW LT8
|| ' where FT11.PROD_SOLD_SKID = LT1.PROD_SKID     '
|| ' AND LT4.GEO_SKID = FT11.GEO_SKID              '
|| ' AND LT5.PROFT_CTR_SKID = FT11.PROFT_CTR_SKID  '
|| ' AND LT8.CAL_MASTR_SKID = FT11.DAY_SKID        '
--|| ' AND LT1.PROD_9_ID in ( ''1100261142'' ,       '
--|| ' ''1100337253'' ,                              '
--|| ' ''1100337255'' ,                              '
--|| ' ''1100337260'' ,                              '
--|| ' ''1100337276'' ,                              '
--|| '  ''1100337312'' ,                             '
--|| '   ''1100337320'' ,                            '
--|| '    ''1100337329'' ,                           '
--|| '    ''1100337339'' ,                           '
--|| '    ''1100337346'' ,                           '
--|| '    ''1100337354'' ,                           '
--|| '    ''1100337367'' ,                           '
--|| '    ''1100337398'' , ''1100337418'' ,          '
--|| '    ''1100337452'' , ''1100337483'' ,          '
--|| '    ''1100337485'' , ''1100337527'' ,          '
--|| '    ''1100337540'' , ''1100337596'' ,          '
--|| '    ''1100337614'' , ''1100337621'' ,          '
--|| '     ''1100337725'' , ''1100370658'' ,         '
--|| '     ''1100441951'' , ''1100474039'' ,         '
--|| '     ''1100480498'' , ''1100499590'' ,         '
--|| '     ''1100523663'' , ''1100523665'' ,         '
--|| '     ''1100523667'' , ''1100523838'' ,         '
--|| '     ''1100524104'' , ''1100524106'' ,         '
--|| '     ''110052412'')                            '
|| ' GROUP BY ''PH'' || LT1.PROD_9_ID ,            '
|| ' ''CA9900000001'' ,                            '
|| ' ''G5'' || LT4.GEO_5_ID ,                      '
|| '  ''R1'' || LT5.PROFT_CTR_1_ID ,               '
|| '   ''D190'' , ''T3'' || LT8.MTH_SKID           ';


sys.xrw(null, 'COSTS, PASS, REWRITTEN_TXT, QUERY_BLOCK_NO', l_stmt);
END;
/