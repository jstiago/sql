DELETE FROM FT_BE_OCOP WHERE OCDF_OID in (SELECT OCDF_OID FROM FT_BE_OCDF WHERE OCCUR_NME = 'EIS_FIP1_MIXR' AND   OCCUR_NMESPC_NME='GSC');

DELETE FROM FT_BE_OCFP WHERE OCDF_OID in (SELECT OCDF_OID FROM FT_BE_OCDF WHERE OCCUR_NME = 'EIS_FIP1_MIXR' AND   OCCUR_NMESPC_NME='GSC');



DELETE FROM FT_BE_OCOP WHERE OCDF_OID in (SELECT PRNT_OCDF_OID FROM FT_BE_OCDF WHERE OCCUR_NME = 'EIS_FIP1_MIXR' AND   OCCUR_NMESPC_NME='GSC');

DELETE FROM FT_BE_OCFP WHERE OCDF_OID in (SELECT PRNT_OCDF_OID FROM FT_BE_OCDF WHERE OCCUR_NME = 'EIS_FIP1_MIXR' AND   OCCUR_NMESPC_NME='GSC');


DELETE FROM FT_BE_OCDF
WHERE OCCUR_NME = 'EIS_FIP1_MIXR'
AND   OCCUR_NMESPC_NME='GSC';

