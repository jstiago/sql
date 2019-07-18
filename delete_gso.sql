

DELETE FROM FT_BE_DGDP WHERE dgdf_oid IN (SELECT dgdf.dgdf_oid 
                                          FROM   ft_be_betd betd
                                          INNER JOIN FT_BE_DGDF dgdf ON betd.BETD_OID = dgdf.betd_oid
                                          where  betd.bus_entity_typ_nme = 'EISPerformanceFixedIncome'
                                          UNION ALL
                                          SELECT dgdf.PRNT_DGDF_OID 
                                          FROM   ft_be_betd betd
                                          INNER JOIN FT_BE_DGDF dgdf ON betd.BETD_OID = dgdf.betd_oid
                                          where  betd.bus_entity_typ_nme = 'EISPerformanceFixedIncome'                                          
                                          )
/

DELETE from FT_BE_DGDF where BETD_OID IN (SELECT BETD_OID FROM ft_be_betd where bus_entity_typ_nme = 'EISPerformanceFixedIncome')
/

DELETE from FT_BE_DGDF where BETD_OID IN (SELECT BETD_OID FROM ft_be_betd where bus_entity_typ_nme = 'EISPerformanceFixedIncome')
/

DELETE from ft_be_betd where bus_entity_typ_nme = 'EISPerformanceFixedIncome'
/

