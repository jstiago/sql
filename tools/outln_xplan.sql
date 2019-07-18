select distinct
   lpad(' ',2*(level-1))||hint_text hint,
   hint#,
   table_tin,
   stage#
from
   outln.ol$hints
start with
   hint#=1
connect by prior
   hint# = hint#-1
and
   ol_name = upper('&1')
order by
   stage#,
   hint#
;
