PL/SQL Developer Test script 3.0
115
-- Created on 13.07.10 by Kravchenko A.V.
declare 
  -- Local variables here
  type t_param is record (
    rn pls_integer,
    param_str varchar2(4000),
    param_name varchar2(100),
    param_type varchar2(3),  
    param_value varchar2(255),
    param_value_int pls_integer,
    param_value_num number,
    param_value_dat date);
    
  m_command_str varchar2(32000);
  m_schema varchar2(50);
  m_part1 varchar2(50);
  m_part2 varchar2(50);
  m_dblink varchar2(50);
  m_part1_type varchar2(50);
  m_object_number varchar2(50);
  m_offset_str pls_integer;
  m_is_func boolean;
  m_cur pls_integer;
  m_rows pls_integer;
  c_params sys_refcursor;
  m_param t_param;
  m_result pls_integer;
begin
  dbms_utility.name_resolve(name => :p_command,
                            context => '1',
                            schema => m_schema,
                            part1 => m_part1,
                            part2 => m_part2,
                            dblink => m_dblink,
                            part1_type => m_part1_type,
                            object_number => m_object_number);
  
  m_command_str := 'begin'||p_ovc_str_utils.CRLF;
  for c_list_arg in (select
                        aa.ARGUMENT_NAME,
                        aa.in_out,
                        aa.SEQUENCE,
                        aa.pls_type,
                        aa.POSITION,
                        count(aa.OWNER) over () count_arg,
                        row_number() over (order by aa.POSITION) rn,
                        decode((select count(aas.OWNER) from all_arguments aas where                       
                        ((aas.PACKAGE_NAME = m_part1) or  (m_part1 is null and aas.PACKAGE_NAME is null)) and
                       aas.OBJECT_NAME = m_part2 and
                       aas.OWNER = m_schema ),0,'F','T') is_func
                     from
                       all_arguments aa
                     where
                       ((aa.PACKAGE_NAME = m_part1) or  (m_part1 is null and aa.PACKAGE_NAME is null)) and
                       aa.OBJECT_NAME = m_part2 and
                       aa.OWNER = m_schema 
                       --and aa.POSITION>0
                       
                     order by aa.POSITION)
 loop
   --�������
   if c_list_arg.rn = 1 and c_list_arg.is_func='T' then
     m_command_str := m_command_str||'  :m_result := '||:p_command;
     m_offset_str:= 16;
     m_is_func := true;
   --���������
   elsif c_list_arg.rn = 1 and c_list_arg.is_func='F'  then
     m_command_str := m_command_str||'  '||:p_command;
     m_offset_str:= 3; 
     m_is_func := false;    
   end if;     
   
   --���� ���� ���������
   if c_list_arg.position  > 0  then     
     --�� ������ ���������� ������
     if c_list_arg.position = 1  then   
       m_command_str := m_command_str||'(';
     --��������� ������� � ������ ������������ 
     else
       m_command_str := m_command_str||','||p_ovc_str_utils.CRLF||rpad('  ',length(:p_command)+m_offset_str,' '); 
     end if;  
       

     m_command_str := m_command_str||c_list_arg.argument_name||' => :'||c_list_arg.argument_name;
     
     --���� ��������� �������� ��������� ������
     if c_list_arg.rn = c_list_arg.count_arg then
       m_command_str := m_command_str||')';
     end if;
   end if;


 end loop;

 m_command_str := m_command_str||';'||p_ovc_str_utils.CRLF||'end;';
  
 dbms_output.put_line(m_command_str);                     
 
 m_cur := dbms_sql.open_cursor;
 dbms_sql.parse(m_cur, m_command_str, dbms_sql.native);
 p_ovc_http.parse_params(:p_params,c_params);
 loop
   fetch c_params into m_param;
   exit when c_params%notfound;
   dbms_sql.bind_variable(m_cur,m_param.param_name,m_param.param_value);
 end loop;
 if m_is_func then
   dbms_sql.bind_variable(m_cur,'m_result',m_result);
 end if;  
 m_rows :=dbms_sql.execute(m_cur);
 if m_is_func then
   dbms_sql.variable_value(m_cur,'m_result',m_result);
 end if;  
 dbms_output.put_line(m_result);
end;
2
p_command
1
p_ovc_utility.get_user_uid
5
p_params
0
5
0
