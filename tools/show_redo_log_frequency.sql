SELECT   TRUNC (first_time) DAY,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '00', 1, 0)) H00,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '01', 1, 0)) H01,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '02', 1, 0)) H02,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '03', 1, 0)) H03,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '04', 1, 0)) H04,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '05', 1, 0)) H05,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '06', 1, 0)) H06,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '07', 1, 0)) H07,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '08', 1, 0)) H08,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '09', 1, 0)) H09,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '10', 1, 0)) H10,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '11', 1, 0)) H11,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '12', 1, 0)) H12,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '13', 1, 0)) H13,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '14', 1, 0)) H14,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '15', 1, 0)) H15,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '16', 1, 0)) H16,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '17', 1, 0)) H17,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '18', 1, 0)) H18,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '19', 1, 0)) H19,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '20', 1, 0)) H20,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '21', 1, 0)) H21,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '22', 1, 0)) H22,
         SUM(DECODE (TO_CHAR (first_time, 'HH24'), '23', 1, 0)) H23
FROM     v$log_history
GROUP BY TRUNC (first_time)
order by TRUNC (first_time) desc
/
