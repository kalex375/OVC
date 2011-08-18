PL/SQL Developer Test script 3.0
21
-- Created on 20.04.10 by Kravchenko A.V.
declare 
  procedure p(s varchar2)
  is
  begin
    dbms_output.put_line(s);
  end;
  
begin
  -- Test statements here
  for c_list_col in (select c.* from all_tab_columns c where c.OWNER = :P_OWNER and c.TABLE_NAME = :P_TABLE_NAME order by c.COLUMN_ID)
  loop
  if c_list_col.column_name = 'ID' then
   p('  -- Создать 
  procedure create'||lower(substr(:P_TABLE_NAME,4,length(:P_TABLE_NAME)))||'(p_id in out '||lower(:P_TABLE_NAME)||'.'||lower(c_list_col.column_name)||'%type,');
  else
   p('      p_'||lower(c_list_col.column_name)||' in '||lower(:P_TABLE_NAME)||'.'||lower(c_list_col.column_name)||'%type,');
  end if;
  end loop;
  p(');');
end;
2
P_OWNER
1
ORA_VER
5
P_TABLE_NAME
1
OVC_FILTER
5
0
