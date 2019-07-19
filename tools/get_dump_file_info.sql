SET VERIFY OFF
SET FEEDBACK OFF
 
DECLARE
  dirName    VARCHAR2(30)   := '&1';
  fileName   VARCHAR2(2048) := '&2';
  ind        NUMBER;
  fileType   NUMBER;
  value      VARCHAR2(2048);
  infoTab    KU$_DUMPFILE_INFO := KU$_DUMPFILE_INFO();
 
BEGIN
  --
  -- Get the information about the dump file into the infoTab.
  --
  BEGIN
    DBMS_DATAPUMP.GET_DUMPFILE_INFO(fileName,dirName,infoTab,fileType);
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Information for file: example1.dmp');
 
    --
    -- Determine what type of file is being looked at.
    --
    CASE fileType
      WHEN 1 THEN
        DBMS_OUTPUT.PUT_LINE(fileName || ' is a Data Pump dump file');
      WHEN 2 THEN
        DBMS_OUTPUT.PUT_LINE(fileName || ' is an Original Export dump file');
      WHEN 3 THEN
        DBMS_OUTPUT.PUT_LINE(fileName || ' is an External Table dump file');
      ELSE
        DBMS_OUTPUT.PUT_LINE(fileName || ' is not a dump file');
        DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
    END CASE;
 
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
      DBMS_OUTPUT.PUT_LINE('Error retrieving information for file: ' ||
                           fileName);
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
      DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
      fileType := 0;
  END;
 
  --
  -- If a valid file type was returned, then loop through the infoTab and 
  -- display each item code and value returned.
  --
  IF fileType > 0
  THEN
    DBMS_OUTPUT.PUT_LINE('The information table has ' || 
                          TO_CHAR(infoTab.COUNT) || ' entries');
    DBMS_OUTPUT.PUT_LINE('---------------------------------------------');
 
    ind := infoTab.FIRST;
    WHILE ind IS NOT NULL
    LOOP
      --
      -- The following item codes return boolean values in the form
      -- of a '1' or a '0'. Display them as 'Yes' or 'No'.
      --
      value := NVL(infoTab(ind).value, 'NULL');
      IF infoTab(ind).item_code IN
         (DBMS_DATAPUMP.KU$_DFHDR_MASTER_PRESENT,
          DBMS_DATAPUMP.KU$_DFHDR_DIRPATH,
          DBMS_DATAPUMP.KU$_DFHDR_METADATA_COMPRESSED,
          DBMS_DATAPUMP.KU$_DFHDR_DATA_COMPRESSED,
          DBMS_DATAPUMP.KU$_DFHDR_METADATA_ENCRYPTED,
          DBMS_DATAPUMP.KU$_DFHDR_DATA_ENCRYPTED,
          DBMS_DATAPUMP.KU$_DFHDR_COLUMNS_ENCRYPTED)
      THEN
        CASE value
          WHEN '1' THEN value := 'Yes';
          WHEN '0' THEN value := 'No';
        END CASE;
      END IF;
 
      --
      -- Display each item code with an appropriate name followed by
      -- its value.
      --
      CASE infoTab(ind).item_code
        --
        -- The following item codes have been available since Oracle
        -- Database 10g, Release 10.2.
        --
        WHEN DBMS_DATAPUMP.KU$_DFHDR_FILE_VERSION   THEN
          DBMS_OUTPUT.PUT_LINE('Dump File Version:         ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_MASTER_PRESENT THEN
          DBMS_OUTPUT.PUT_LINE('Master Table Present:      ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_GUID THEN
          DBMS_OUTPUT.PUT_LINE('Job Guid:                  ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_FILE_NUMBER THEN
          DBMS_OUTPUT.PUT_LINE('Dump File Number:          ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_CHARSET_ID  THEN
          DBMS_OUTPUT.PUT_LINE('Character Set ID:          ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_CREATION_DATE THEN
          DBMS_OUTPUT.PUT_LINE('Creation Date:             ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_FLAGS THEN
          DBMS_OUTPUT.PUT_LINE('Internal Dump Flags:       ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_JOB_NAME THEN
          DBMS_OUTPUT.PUT_LINE('Job Name:                  ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_PLATFORM THEN
          DBMS_OUTPUT.PUT_LINE('Platform Name:             ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_INSTANCE THEN
          DBMS_OUTPUT.PUT_LINE('Instance Name:             ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_LANGUAGE THEN
          DBMS_OUTPUT.PUT_LINE('Language Name:             ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_BLOCKSIZE THEN
          DBMS_OUTPUT.PUT_LINE('Dump File Block Size:      ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_DIRPATH THEN
          DBMS_OUTPUT.PUT_LINE('Direct Path Mode:          ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_METADATA_COMPRESSED THEN
          DBMS_OUTPUT.PUT_LINE('Metadata Compressed:       ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_DB_VERSION THEN
          DBMS_OUTPUT.PUT_LINE('Database Version:          ' || value);
 
        --
        -- The following item codes were introduced in Oracle Database 11g
        -- Release 11.1
        --

        WHEN DBMS_DATAPUMP.KU$_DFHDR_MASTER_PIECE_COUNT THEN
          DBMS_OUTPUT.PUT_LINE('Master Table Piece Count:  ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_MASTER_PIECE_NUMBER THEN
          DBMS_OUTPUT.PUT_LINE('Master Table Piece Number: ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_DATA_COMPRESSED THEN
          DBMS_OUTPUT.PUT_LINE('Table Data Compressed:     ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_METADATA_ENCRYPTED THEN
          DBMS_OUTPUT.PUT_LINE('Metadata Encrypted:        ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_DATA_ENCRYPTED THEN
          DBMS_OUTPUT.PUT_LINE('Table Data Encrypted:      ' || value);
        WHEN DBMS_DATAPUMP.KU$_DFHDR_COLUMNS_ENCRYPTED THEN
          DBMS_OUTPUT.PUT_LINE('TDE Columns Encrypted:     ' || value);
 
        --
        -- For the DBMS_DATAPUMP.KU$_DFHDR_ENCRYPTION_MODE item code a
        -- numeric value is returned. So examine that numeric value
        -- and display an appropriate name value for it.
        --
        WHEN DBMS_DATAPUMP.KU$_DFHDR_ENCRYPTION_MODE THEN
          CASE TO_NUMBER(value)
            WHEN DBMS_DATAPUMP.KU$_DFHDR_ENCMODE_NONE THEN
              DBMS_OUTPUT.PUT_LINE('Encryption Mode:           None');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_ENCMODE_PASSWORD THEN
              DBMS_OUTPUT.PUT_LINE('Encryption Mode:           Password');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_ENCMODE_DUAL THEN
              DBMS_OUTPUT.PUT_LINE('Encryption Mode:           Dual');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_ENCMODE_TRANS THEN
              DBMS_OUTPUT.PUT_LINE('Encryption Mode:           Transparent');
          END CASE;
 
        --
        -- The following item codes were introduced in Oracle Database 12c
        -- Release 12.1
        --
 
        --
        -- For the DBMS_DATAPUMP.KU$_DFHDR_COMPRESSION_ALG item code a
        -- numeric value is returned. So examine that numeric value and
        -- display an appropriate name value for it.
        --
        WHEN DBMS_DATAPUMP.KU$_DFHDR_COMPRESSION_ALG THEN
          CASE TO_NUMBER(value)
            WHEN DBMS_DATAPUMP.KU$_DFHDR_CMPALG_NONE THEN
              DBMS_OUTPUT.PUT_LINE('Compression Algorithm:     None');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_CMPALG_BASIC THEN
              DBMS_OUTPUT.PUT_LINE('Compression Algorithm:     Basic');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_CMPALG_LOW THEN
              DBMS_OUTPUT.PUT_LINE('Compression Algorithm:     Low');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_CMPALG_MEDIUM THEN
              DBMS_OUTPUT.PUT_LINE('Compression Algorithm:     Medium');
            WHEN DBMS_DATAPUMP.KU$_DFHDR_CMPALG_HIGH THEN
              DBMS_OUTPUT.PUT_LINE('Compression Algorithm:     High');
          END CASE;
        ELSE NULL;  -- Ignore other, unrecognized dump file attributes.
      END CASE;
      ind := infoTab.NEXT(ind);
    END LOOP;
  END IF;
END;
/