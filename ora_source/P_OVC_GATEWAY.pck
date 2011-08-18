create or replace package P_OVC_GATEWAY is

  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 14.04.2010 15:50:35
   Purpose : Пакет для работы с удаленными БД

  */
                        
  -- Создать линк на другу базу
  procedure create_dblink(p_id in out ovc_dblink.id%type,
                          p_name in ovc_dblink.name%type,
                          p_description in ovc_dblink.description%type,
                          p_type in ovc_dblink.type%type);

  -- Изменить линк на другу базу
  procedure update_dblink(p_id in ovc_dblink.id%type,
                          p_name in ovc_dblink.name%type,
                          p_description in ovc_dblink.description%type,
                          p_type in ovc_dblink.type%type);

  -- Удалить линк на другу базу
  procedure delete_dblink(p_id in ovc_dblink.id%type);

  -- Выполнить команду через dbms_sql
  procedure execute_local(p_command in clob);


  -- Выполнить команду на удалленом сервере 
  procedure execute_remote(p_db_link_name in ovc_dblink.name%type,
                           p_command in clob);

end P_OVC_GATEWAY;
/
create or replace package body P_OVC_GATEWAY is

type t_row   is record (line number(10),
                        text varchar2(4000));
  
type t_table is table of t_row index by pls_integer;

-- Передает clob в массив
function clob_to_array(p_clob clob) return t_table
is
  m_table t_table;
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
function array_to_clob(p_array t_table) return clob
is
  m_result clob;
begin
  
  for i in p_array.first..p_array.last
  loop
    m_result := m_result||to_clob(p_array(i).text)||p_ovc_str_utils.LF;
  end loop;
  
  return m_result;
end;
  
-- Создать линк на другу базу
procedure create_dblink(p_id in out ovc_dblink.id%type,
                        p_name in ovc_dblink.name%type,
                        p_description in ovc_dblink.description%type,
                        p_type in ovc_dblink.type%type)
is
begin
  
  if p_id is null then 
    select ovc_dblink_seq.nextval into p_id from dual; 
  end if;
  
  insert into ovc_dblink(id,
                         name,
                         description,
                         type)
                   values   
                         (p_id,
                          p_name,
                          p_description,
                          p_type);
end;                        

-- Изменить линк на другу базу
procedure update_dblink(p_id in ovc_dblink.id%type,
                        p_name in ovc_dblink.name%type,
                        p_description in ovc_dblink.description%type,
                        p_type in ovc_dblink.type%type)
is
begin
  
  if p_id is null then 
    p_ovc_exception.raise_common_exception('Не задан ID'); 
  end if;
  
  update ovc_dblink d set
    d.name = p_name,
    d.description = p_description,
    d.type = p_type
  where d.id = p_id;
      
end;                        

-- Удалить линк на другу базу
procedure delete_dblink(p_id in ovc_dblink.id%type)
is
begin
  if p_id is null then 
    p_ovc_exception.raise_common_exception('Не задан ID'); 
  end if;
  
  delete from ovc_dblink d where d.id = p_id;
end;

-- Выполнить команду через dbms_sql
procedure execute_local(p_command in clob)
is
  m_cur_id number;
  m_e number;
begin
  
  m_cur_id := dbms_sql.open_cursor;
  
  dbms_sql.parse(c => m_cur_id,
                 statement => p_command,
                 language_flag => dbms_sql.native);
                 
  m_e := dbms_sql.execute(m_cur_id);
  dbms_sql.close_cursor(m_cur_id);
                 
end;

-- Выполнить команду через dbms_sql
procedure execute_local(p_command in t_table)
is
begin
  execute_local(p_command => array_to_clob(p_array => p_command));
end;                          
                     

-- ВЫполнить команду на удалленом сервере 
procedure execute_remote(p_db_link_name in ovc_dblink.name%type,
                         p_command in clob)
is                         
begin
  execute immediate '
  declare
    m p_ovc_gateway.t_table@'||p_db_link_name||';
  begin
    
    m := p_ovc_source.clob_to_array(:p_command);
    -- Call the procedure
    p_ovc_gateway.execute_local@'||p_db_link_name||'(p_command => m);
  end;
  ' using in p_command;
end;


end P_OVC_GATEWAY;
/
