DECLARE
  my_file_name VARCHAR2(2048) := '&1';
  my_directory VARCHAR2(30) := 'DATA_PUMP_DIR';
  my_row PLS_INTEGER;

  ind NUMBER;              -- Loop index
  h1 NUMBER;               -- Data Pump job handle
  percent_done NUMBER;     -- Percentage of job complete
  job_state VARCHAR2(30);  -- To keep track of job state
  le ku$_LogEntry;         -- For WIP and error messages
  js ku$_JobStatus;        -- The job status from get_status
  jd ku$_JobDesc;          -- The job description from get_status
  sts ku$_Status;          -- The status object returned by get_status
BEGIN

-- Create a (user-named) Data Pump job to do a "full" import (everything
-- in the dump file without filtering).

  h1 := DBMS_DATAPUMP.OPEN('IMPORT','SCHEMA',NULL,'IMPDP_' || REPLACE(my_file_name, '.dmp') || to_char(sysdate, 'yyyymmddmmss'));

-- Specify the single dump file for the job (using the handle just returned)
-- and directory object, which must already be defined and accessible
-- to the user running this procedure. This is the dump file created by
-- the export operation in the first example.

  DBMS_DATAPUMP.ADD_FILE(handle    => h1,
                         filename  => my_file_name,
                         directory => my_directory);


  DBMS_DATAPUMP.ADD_FILE(handle    => h1,
                         filename  => REPLACE(my_file_name, '.dmp', '.log'),
                         directory => my_directory,
                         filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE,
                         reusefile => 1);

  --DBMS_DATAPUMP.METADATA_FILTER(h1, 'SCHEMA_LIST', '''' || my_schema_name || '''');

-- A metadata remap will map all schema objects from HR to BLAKE.

--  DBMS_DATAPUMP.METADATA_REMAP(h1,'REMAP_TABLESPACE','HR','BLAKE');

-- If a table already exists in the destination schema, skip it (leave
-- the preexisting table alone). This is the default, but it does not hurt
-- to specify it explicitly.
  DBMS_DATAPUMP.SET_PARAMETER(handle => h1
                             ,name => 'PARTITION_OPTIONS'
                             ,value => 'MERGE');

  DBMS_DATAPUMP.SET_PARAMETER(handle => h1
                             ,name => 'TABLE_EXISTS_ACTION'
                             ,value => 'APPEND');

-- Start the job. An exception is returned if something is not set up properly.

  DBMS_DATAPUMP.START_JOB(h1);

-- The import job should now be running. In the following loop, the job is 
-- monitored until it completes. In the meantime, progress information is 
-- displayed. Note: this is identical to the export example.
 
 percent_done := 0;
  job_state := 'UNDEFINED';
  while (job_state != 'COMPLETED') and (job_state != 'STOPPED') loop
    dbms_datapump.get_status(h1,
           dbms_datapump.ku$_status_job_error +
           dbms_datapump.ku$_status_job_status +
           dbms_datapump.ku$_status_wip,-1,job_state,sts);
    js := sts.job_status;

-- If the percentage done changed, display the new value.

     if js.percent_done != percent_done
    then
      dbms_output.put_line('*** Job percent done = ' ||
                           to_char(js.percent_done));
      percent_done := js.percent_done;
    end if;

-- If any work-in-progress (WIP) or Error messages were received for the job,
-- display them.

       if (bitand(sts.mask,dbms_datapump.ku$_status_wip) != 0)
    then
      le := sts.wip;
    else
      if (bitand(sts.mask,dbms_datapump.ku$_status_job_error) != 0)
      then
        le := sts.error;
      else
        le := null;
      end if;
    end if;
    if le is not null
    then
      ind := le.FIRST;
      while ind is not null loop
        dbms_output.put_line(le(ind).LogText);
        ind := le.NEXT(ind);
      end loop;
    end if;
  end loop;

-- Indicate that the job finished and gracefully detach from it. 

  dbms_output.put_line('Job has completed');
  dbms_output.put_line('Final job state = ' || job_state);
  dbms_datapump.detach(h1);

-- EXCEPTION
--   WHEN OTHERS THEN
--     dbms_datapump.get_status(NULL, 8, 0, job_state, sts);
--     le := sts.error;
 
--     my_row := le.FIRST;
--     LOOP
--       EXIT WHEN my_row IS NULL;
--       dbms_output.put_line('logLineNumber=' || le(my_row).logLineNumber);
--       dbms_output.put_line('errorNumber=' || le(my_row).errorNumber);
--       dbms_output.put_line('LogText=' || le(my_row).LogText);
--       my_row := le.NEXT(my_row);
--     END LOOP;
--     RAISE;
END;
/