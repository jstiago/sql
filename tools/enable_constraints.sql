begin
  for rec in (
select TABLE_NAME, CONSTRAINT_NAME from dba_constraints
where owner = 'TDB' AND status = 'DISABLED')
  LOOP
    dbms_output.put_line('ALTER TABLE ' || rec.TABLE_NAME || ' enable constraint ' || rec.constraint_name || ' no validate');
    EXECUTE IMMEDIATE 'ALTER TABLE ' || rec.TABLE_NAME || ' enable novalidate constraint ' || rec.constraint_name;
  end loop;
end;
/
