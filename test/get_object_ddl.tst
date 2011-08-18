PL/SQL Developer Test script 3.0
29
-- Created on 29.08.08 by Kravchneko A.V.
declare 
  -- Local variables here
  i integer;
  j integer;
begin
  -- Test statements here
  i:= dbms_metadata.open(object_type => 'PACKAGE');
  
  dbms_metadata.set_filter(handle => i,
                           name => 'NAME',
                           value => 'FC_GB_DEPO_JUR');
   
  j := dbms_metadata.add_transform(handle => i,
                                   name => 'DDL');
                                                            
  dbms_metadata.set_transform_param(transform_handle => j,
                                    name => 'SQLTERMINATOR',
                                    value => True);
 
 dbms_metadata.set_transform_param(transform_handle => j,
                                    name => 'PRETTY',
                                    value => True);
  
--  f := dbms_metadata.fetch_ddl(handle => i);                         
  :c := dbms_metadata.fetch_clob(handle => i); --GET_DDL (object_type => 'PACKAGE',name => 'FC_GB_DEPO_JUR');
  dbms_metadata.close(i);

end;
1
c
1
<CLOB>
112
1
f
