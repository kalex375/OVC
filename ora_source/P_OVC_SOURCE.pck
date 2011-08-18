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

  -- Возвращает исходник таблицы в clob
  function get_table_source_clob(p_type all_source.type%type,
                                 p_owner all_source.owner%type,
                                 p_name all_source.name%type) return clob;

  -- Возвращает исходник таблицы в массив
  function get_table_source_array(p_type all_source.type%type,
                                  p_owner all_source.owner%type,
                                  p_name all_source.name%type) return t_source_table;
  
  -- Возвращает исходные тексты программ в clob
  function get_program_source_clob(p_type all_source.type%type,
                                   p_owner all_source.owner%type,
                                   p_name all_source.name%type) return clob;

  -- Возвращает исходные тексты программ в массив
  function get_program_source_array(p_type all_source.type%type,
                                    p_owner all_source.owner%type,
                                    p_name all_source.name%type) return t_source_table;

  -- Возвращает исходные тексты db link в clob
  function get_dblink_source_clob(p_type all_source.type%type,
                                  p_owner all_source.owner%type,
                                  p_name all_source.name%type) return clob;

  -- Возвращает исходные тексты db link  в массив
  function get_table_dblink_array(p_type all_source.type%type,
                                  p_owner all_source.owner%type,
                                  p_name all_source.name%type) return t_source_table;
                                  

  
end P_OVC_SOURCE;
/
create or replace package body P_OVC_SOURCE is

-- Передает clob в массив
function clob_to_array(p_clob clob) return t_source_table
is
  m_table t_source_table;
  m_offset pls_integer;
  m_ins pls_integer;
  m_nth pls_integer;
  m_amount pls_integer;
  m_str varchar2(4000);
begin
  m_table := t_source_table();
  
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
    m_table.extend;
    m_table(m_nth) := t_source_line(m_nth, dbms_lob.substr(p_clob,m_amount,m_offset));
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
    m_table.extend;  
    m_table(m_nth) := t_source_line(m_nth, m_str);
  end if;    
  return m_table;
end;

-- Передает  массив в clob
function array_to_clob(p_array t_source_table) return clob
is
  m_result clob;
begin
  
  for i in p_array.first..p_array.last
  loop
    m_result := m_result||to_clob(p_array(i).text)||p_ovc_str_utils.LF;
  end loop;
  
  return m_result;
end;

-- Возвращает информацию по объекту в таблице изменений
function get_object_type_info(p_object_type in ovc_object_type.type%type)
         return ovc_object_type%rowtype
is
  cursor c_get_type_info(p_object_type in ovc_object_type.type%type)
  is
    select
      o.*
    from
      ovc_object_type o
    where
      o.type = p_object_type;

  m_type_info ovc_object_type%rowtype;     
begin
  open c_get_type_info(p_object_type);
  fetch c_get_type_info into m_type_info;
  close c_get_type_info;
  
  if m_type_info.id is null then
    p_ovc_exception.raise_common_exception('Не найден тип объекта %S',p_object_type);
  end if;
  
  return m_type_info;
end;


-- Возвращает исходные тексты программ в clob
function get_program_source_clob(p_type all_source.type%type,
                                 p_owner all_source.owner%type,
                                 p_name all_source.name%type) return clob
is
begin
  return array_to_clob(get_program_source_array(p_type,p_owner,p_name));
end;                                                                  

-- Возвращает курсор с исходным текстом программы
function get_program_source_array(p_type all_source.type%type,
                                  p_owner all_source.owner%type,
                                  p_name all_source.name%type) return t_source_table
is
  c_prog_source sys_refcursor;
  m_obj_source t_source_table;
begin
  m_obj_source := t_source_table();
  open c_prog_source for select 
                           t_source_line(s.line,
                                         decode(s.line, 1, 'create or replace '||s.text,s.text))
                         from
                           all_source s
                         where
                           s.type = p_type and
                           s.owner = p_owner and
                           s.name = p_name
                         order by s.line;
  fetch c_prog_source bulk collect into m_obj_source;
  close c_prog_source;


  return m_obj_source;
end;

-- Возвращает исходник таблицы в clob
function get_table_source_clob(p_type all_source.type%type,
                               p_owner all_source.owner%type,
                               p_name all_source.name%type) return clob
is
  m_handle pls_integer;
  m_trans_handle pls_integer;
  m_result clob;
  m_comment clob;
  m_obj_type_info ovc_object_type%rowtype;
begin
  m_result := null;
  m_comment := null;

  m_obj_type_info :=  get_object_type_info(p_type);

  m_handle := dbms_metadata.open(object_type => m_obj_type_info.metadata_type);

  dbms_metadata.set_filter(handle => m_handle,
                           name => 'SCHEMA',
                           value => p_owner);
  
  dbms_metadata.set_filter(handle => m_handle,
                           name => 'NAME',
                           value => p_name);
   
  m_trans_handle := dbms_metadata.add_transform(handle => m_handle,
                                                name => 'DDL');
                                                            
  dbms_metadata.set_transform_param(transform_handle => m_trans_handle,
                                    name => 'SQLTERMINATOR',
                                    value => True);
 
  dbms_metadata.set_transform_param(transform_handle => m_trans_handle,
                                    name => 'PRETTY',
                                    value => True);
                                    
  m_result := dbms_metadata.fetch_clob(handle => m_handle); 

  dbms_metadata.close(m_handle);
  
  --Коментарии к таблице
  if upper(p_type)= 'TABLE' then
    m_handle:= dbms_metadata.open(object_type => 'COMMENT');

    dbms_metadata.set_filter(m_handle,'BASE_OBJECT_NAME', p_name);
    
    dbms_metadata.set_filter(m_handle,'BASE_OBJECT_SCHEMA',p_owner);

    m_trans_handle := dbms_metadata.add_transform(handle => m_handle,
                                     name => 'DDL');
                                                              
    dbms_metadata.set_transform_param(transform_handle => m_trans_handle,
                                      name => 'SQLTERMINATOR',
                                      value => True);
   
    dbms_metadata.set_transform_param(transform_handle => m_trans_handle,
                                      name => 'PRETTY',
                                      value => True);
                                      
    loop
      m_comment := dbms_metadata.fetch_clob(handle => m_handle);
      exit when m_comment is null;
      m_result := m_result||m_comment;  
    end loop;
  end if;
  
  dbms_metadata.close(m_handle);
  
  return m_result;
  
end;

-- Возвращает исходник таблицы в массив
function get_table_source_array(p_type all_source.type%type,
                                p_owner all_source.owner%type,
                                p_name all_source.name%type) return t_source_table
is
begin
  return clob_to_array(get_table_source_clob(p_type,p_owner,p_name));
end;                               

-- Возвращает исходные тексты db link в clob
function get_dblink_source_clob(p_type all_source.type%type,
                                p_owner all_source.owner%type,
                                p_name all_source.name%type) return clob
is
  cursor c_get_owner(p_owner all_db_links.owner%type,
                     p_name all_db_links.db_link%type)
  is
    select                  
     d.owner 
    from
      all_db_links d
    where
      d.DB_LINK = p_name and
      (d.owner = p_owner or d.owner = 'PUBLIC')
    order by decode(d.owner,'PUBLIC',1,0);
      
  m_result clob;
  m_obj_type_info ovc_object_type%rowtype;
  m_owner all_db_links.owner%type;
begin
  m_result := null;

  m_obj_type_info :=  get_object_type_info(p_type);
  
  open c_get_owner(p_owner, p_name);
  fetch c_get_owner into m_owner;
  close c_get_owner;
  
  dbms_metadata.set_transform_param(transform_handle => dbms_metadata.SESSION_TRANSFORM,
                                    name => 'PRETTY',
                                    value => True);

  dbms_metadata.set_transform_param(transform_handle => dbms_metadata.SESSION_TRANSFORM,
                                    name => 'SQLTERMINATOR',
                                    value => True);           

  m_result := dbms_metadata.GET_DDL (object_type => 'DB_LINK',
                                     name => 'SRSEP2',
                                     schema => 'PUBLIC');
                                     
  /*dbms_metadata.get_ddl(object_type => 'DB_LINK',--m_obj_type_info.metadata_type,
                                    name => 'SRSEP2',--p_name,
                                    schema => 'PUBLIC');--m_owner);
                                    */
 return m_result;
                                  
end;


-- Возвращает исходные тексты db link  в массив
function get_table_dblink_array(p_type all_source.type%type,
                                p_owner all_source.owner%type,
                                p_name all_source.name%type) return t_source_table
is
begin
  return clob_to_array(get_dblink_source_clob(p_type,p_owner,p_name));
end;    
end P_OVC_SOURCE;
/
