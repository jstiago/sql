CREATE DATABASE LINK EAGLE_LINK
CONNECT TO EAGLE_LINK IDENTIFIED BY TDBLNT03
USING 'TDBLNT03';


CREATE DATABASE LINK TMOLINK
CONNECT TO TMOLINK IDENTIFIED BY TDBLNT03
USING 'TDBLNT03';

CREATE DATABASE LINK TDBLNT02
CONNECT TO TDB IDENTIFIED BY TDBLNT02
USING 'TDBLNT02';


CREATE public DATABASE LINK TMOLNT04_TES
CONNECT TO TES IDENTIFIED BY TMOLNT04
USING 'TMOLNT04';

CREATE DATABASE LINK TMOLINK
CONNECT TO TDB IDENTIFIED BY TDBLND20
USING 'TDBLND20';



CREATE DATABASE LINK dbl_crts
CONNECT TO crts_tom IDENTIFIED BY crts_tom
USING 'CRDBTOM2';


drop database link dbl_eagle;

CREATE DATABASE LINK dbl_eagle
CONNECT TO egl_tom IDENTIFIED BY egl_tom
USING 'EGLTOM2';




CREATE DATABASE LINK dbl_eagle
CONNECT TO egl_tom IDENTIFIED BY egl_tom
USING 'EGLDLY';
