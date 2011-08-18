PL/SQL Developer Test script 3.0
36
-- Created on 21.09.09 by Kravchenko A.V.
declare 
  -- Local variables here
  i integer;
  j integer;
begin
  -- Test statements here
  i:= dbms_metadata.open(object_type => 'TABLE');
  
  dbms_metadata.set_filter(handle => i,
                           name => 'COMMENT',
                           value => 'FC_REDUCED_RATE_ACTION');
   
  j := dbms_metadata.add_transform(handle => i,
                                   name => 'DDL');

  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'PRETTY',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SQLTERMINATOR',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SEGMENT_ATTRIBUTES',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'STORAGE',FALSE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'TABLESPACE',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'REF_CONSTRAINTS',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'SPECIFICATION',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'BODY',TRUE);
  dbms_metadata.set_transform_param(dbms_metadata.session_transform,'CONSTRAINTS',TRUE);                                                            
  

  
--  f := dbms_metadata.fetch_ddl(handle => i);                         
  :c := dbms_metadata.fetch_clob(handle => i); --GET_DDL (object_type => 'PACKAGE',name => 'FC_GB_DEPO_JUR');

  dbms_metadata.close(i);


  
end;
1
c
1
<CLOB>
112
0
