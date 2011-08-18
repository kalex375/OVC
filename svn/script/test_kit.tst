PL/SQL Developer Test script 3.0
5
begin
  -- Call the procedure
  dbms_java.set_output(5000);
  ora_ver.p_ovc_svn_api.test_commit;
end;
0
0
