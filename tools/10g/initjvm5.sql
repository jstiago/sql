-- subscript for initjvm.sql and ilk

-- Triggers to run startup and shutdown Java code

create or replace trigger aurora$server$startup after startup on database call dbms_java.server_startup
/
create or replace trigger aurora$server$shutdown before shutdown on database call dbms_java.server_shutdown
/
-- These were heavily used by JIS, and as far as we know not by anyone else. 
-- So to avoid problems with running Java code during startup and shutdown
-- We have disabled them. However, we are leaving all of them in place so
-- they can be enabled easily if it turns out a customer (or anyone else) is
-- actually using them.
alter trigger aurora$server$startup disable;
alter trigger aurora$server$shutdown disable;

-- create USER|DBA|ALL_JAVA_* views
@@catjvm.sql

-- SQLJ initialization
@@initsqlj

-- XA JSP initialization
@@initxa

-- Load some stuff that is mostly jars we got from sun
-- These used to be loaded by initjis, but that has gone away

begin if initjvmaux.startstep('LOAD_JIS_JARS') then
  -- noverify is suppressing a warning.
  dbms_java.loadjava('-noverify -resolve -synonym -grant PUBLIC lib/activation.jar lib/mail.jar javavm/lib/security/jar.security');
  initjvmaux.endstep;
end if; end;
/
