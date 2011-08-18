create or replace package P_OVC_SVN_API is

  -- Author  : KRAVCHAV
  -- Created : 08.11.10 14:31:01
  -- Purpose : SVNKit API
  
  procedure test_commit;

  
end P_OVC_SVN_API;
/
create or replace package body P_OVC_SVN_API is

  procedure test_commit
    as language java
    name 'Commit.main_proc()';
    
end P_OVC_SVN_API;
/
