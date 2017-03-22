ALTER SESSION SET tracefile_identifier = 'tbs_gcp';

ALTER SESSION SET EVENTS '10053 trace name context forever, level 1';


ALTER SESSION SET EVENTS '10053 trace name context off';

