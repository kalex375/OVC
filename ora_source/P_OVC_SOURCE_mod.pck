create or replace package P_OVC_SOURCE is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 21.04.10 11:41:22
   Purpose : Работа с исходниками
  
  */
  type t_row   is record (line number(10),
                          text varchar2(4000));
  
  type t_table is table of t_row index by pls_integer;
              
  -- Передает clob в массив
  function clob_to_array(p_clob clob) return p_ovc_gateway.t_table@orcl11;

  -- Передает  массив в clob
  function array_to_clob(p_array p_ovc_gateway.t_table@orcl11) return clob;

end P_OVC_SOURCE;
/
create or replace package body P_OVC_SOURCE is
-- Передает clob в массив
function clob_to_array(p_clob clob) return p_ovc_gateway.t_table@orcl11
is
  m_table p_ovc_gateway.t_table@orcl11;
  m_offset pls_integer;
  m_ins pls_integer;
  m_nth pls_integer;
  m_amount pls_integer;
  m_str varchar2(4000);
begin
--  m_table := t_source_table();
  
  m_amount := 1;
  m_offset := 1;
  m_nth := 1;
  m_ins := dbms_lob.instr(lob_loc => p_clob,
                          pattern => p_ovc_str_utils.LF,
                          nth => m_nth
                          );
                 
  while m_ins <> 0 and m_ins is not null 
  loop
    m_amount := m_ins - m_offset;
    --m_table.extend(1);
    m_table(m_nth).line := m_nth;
    m_table(m_nth).text := dbms_lob.substr(p_clob,m_amount,m_offset);
    m_offset := m_ins+1;

    m_nth := m_nth + 1;    
    m_ins := dbms_lob.instr(lob_loc => p_clob,
                            pattern => p_ovc_str_utils.LF,
                            nth => m_nth
                          );


  end loop;
  m_str := null;
  m_str := dbms_lob.substr(p_clob,dbms_lob.getlength(p_clob)-m_offset+1,m_offset);
  if m_str is not null then
      
    m_table(m_nth).line := m_nth;
    m_table(m_nth).text := m_str;
  end if;    
  return m_table;
end;

-- Передает  массив в clob
function array_to_clob(p_array p_ovc_gateway.t_table@orcl11) return clob
is
  m_result clob;
begin
  
  for i in p_array.first..p_array.last
  loop
    m_result := m_result||to_clob(p_array(i).text)||p_ovc_str_utils.LF;
  end loop;
  
  return m_result;
end;

end P_OVC_SOURCE;
/
