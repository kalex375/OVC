PL/SQL Developer Test script 3.0
12
declare
  m_start_time timestamp;
begin
  m_start_time:= systimestamp;
  -- Call the procedure
  p_diff.compare(p_str_1 => :pchrs1,
                 p_str_2 => :pchrs2);
  p_diff.Debug_Show_Compares;
  dbms_output.put_line('');
  dbms_output.put_line('Out Executed in '||regexp_replace(to_char(LOCALTIMESTAMP-m_start_time), '^(\+|(-))[0 :]*(.*?\d\.\d+?)0*$', '\2\3')||' seconds.');
 
end;
2
pchrs1
1
3123
5
pchrs2
1
4124
5
0
