-- Fix tablespace issue for Oracle XE
-- Run this as SYS user to increase tablespace size

-- Check current tablespace usage
SELECT
    tablespace_name,
    file_name,
    bytes/1024/1024 as size_mb,
    maxbytes/1024/1024 as max_size_mb,
    autoextensible
FROM dba_data_files
WHERE tablespace_name = 'USERS';

-- Enable autoextend on USERS tablespace
ALTER DATABASE DATAFILE '/opt/oracle/oradata/XE/XEPDB1/users01.dbf'
AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- Add a new datafile to USERS tablespace (if needed)
-- ALTER TABLESPACE USERS ADD DATAFILE
-- '/opt/oracle/oradata/XE/XEPDB1/users02.dbf'
-- SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- Verify the changes
SELECT
    tablespace_name,
    file_name,
    bytes/1024/1024 as size_mb,
    maxbytes/1024/1024 as max_size_mb,
    autoextensible
FROM dba_data_files
WHERE tablespace_name = 'USERS';
