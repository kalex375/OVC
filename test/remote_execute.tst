PL/SQL Developer Test script 3.0
8
declare
  m p_ovc_source.t_table;
begin
  
  m := p_ovc_source.clob_to_array(:p_command);
  -- Call the procedure
  p_ovc_gateway.execute_command@orcl11(p_command => m);
end;
1
p_command
1
<CLOB>
4208
0
