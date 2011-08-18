create or replace package P_OVC_DBOBJECT is

  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 01.07.10 14:19:47
   Purpose : Работа с описанием объектов БД
  
  */
  --Добавить тип объекта БД
  procedure create_object_type(p_id            in out ovc_object_type.id%type,
                               p_type          in ovc_object_type.type%type,
                               p_metadata_type in ovc_object_type.metadata_type%type default null,
                               p_get_function  in ovc_object_type.get_function%type default null,
                               p_is_program    in ovc_object_type.is_program%type,
                               p_is_compare    in ovc_object_type.is_compare%type,
                               p_icon          in ovc_object_type.icon%type);

  --Изменить тип объекта БД
  procedure update_object_type(p_id            in ovc_object_type.id%type,
                               p_type          in ovc_object_type.type%type,
                               p_metadata_type in ovc_object_type.metadata_type%type,
                               p_get_function  in ovc_object_type.get_function%type,
                               p_is_program    in ovc_object_type.is_program%type,
                               p_is_compare    in ovc_object_type.is_compare%type,
                               p_icon          in ovc_object_type.icon%type);                               

  --Удалить тип объекта БД
  procedure delete_object_type(p_id in ovc_object_type.id%type);                               

  -- Возвращает информацию по объекту в таблице изменений
  function get_change_object_info(p_change_id in ovc_change_object.id%type)
         return ovc_change_object%rowtype;
  
  --Возвращает функцию для получения исходников объекта
  function get_object_function(p_object_type ovc_object_type.type%type) return varchar2;

  -- Возвращает информацию по типу объекту 
  function get_object_type_info(p_object_type in ovc_object_type.type%type) return ovc_object_type%rowtype;

  -- Проверка на возможность сравнить исходные коды объекта
  function can_compare(p_object_type in ovc_object_type.type%type,
                       p_modify_type in ovc_event_db.modify_type%type) return varchar2;
         

end P_OVC_DBOBJECT;
/
create or replace package body P_OVC_DBOBJECT is

--Добавить тип объекта БД
procedure create_object_type(p_id            in out ovc_object_type.id%type,
                             p_type          in ovc_object_type.type%type,
                             p_metadata_type in ovc_object_type.metadata_type%type default null,
                             p_get_function  in ovc_object_type.get_function%type default null,
                             p_is_program    in ovc_object_type.is_program%type,
                             p_is_compare    in ovc_object_type.is_compare%type,
                             p_icon          in ovc_object_type.icon%type)
is
begin
  if p_id is null then 
    select ovc_object_type_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_object_type(id,
                              type,
                              metadata_type,
                              get_function,
                              is_program,
                              is_compare,
                              icon)
                         values
                             (p_id,
                              p_type,
                              p_metadata_type,
                              p_get_function,
                              p_is_compare,
                              p_is_compare,
                              p_icon);     

end;                             

--Изменить тип объекта БД
procedure update_object_type(p_id            in ovc_object_type.id%type,
                             p_type          in ovc_object_type.type%type,
                             p_metadata_type in ovc_object_type.metadata_type%type,
                             p_get_function  in ovc_object_type.get_function%type,
                             p_is_program    in ovc_object_type.is_program%type,
                             p_is_compare    in ovc_object_type.is_compare%type,
                             p_icon          in ovc_object_type.icon%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID типа.');
  end if;
  
  update ovc_object_type t set
    t.type = p_type,
    t.metadata_type = p_metadata_type,
    t.get_function = p_get_function,
    t.is_program = p_is_program,
    t.is_compare = p_is_compare,
    t.icon = p_icon
  where
    t.id = p_id;  
end;                             

--Удалить тип объекта БД
procedure delete_object_type(p_id in ovc_object_type.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID типа.');
  end if;
  
  delete from ovc_object_type where id = p_id;
end;
  
-- Возвращает информацию по объекту в таблице изменений
function get_change_object_info(p_change_id in ovc_change_object.id%type)
         return ovc_change_object%rowtype
is
  cursor c_get_object_info(p_change_id ovc_change_object.id%type)
  is
    select
      o.*
    from
      ovc_change_object o
    where
      o.id = p_change_id;

  m_object_info ovc_change_object%rowtype;      
begin
  open c_get_object_info(p_change_id);
  fetch c_get_object_info into m_object_info;
  close c_get_object_info;
  
  if m_object_info.id is null then
    p_ovc_exception.raise_common_exception('Не найден объект в таблице изменений ID=%S',p_change_id);
  end if;
  
  return m_object_info;
end;

--Возвращает функцию для получения исходников объекта
function get_object_function(p_object_type ovc_object_type.type%type) return varchar2
is
  cursor c_get_function(p_object_type ovc_object_type.type%type)
  is
    select
      o.get_function
    from
      ovc_object_type o
    where
      o.type = p_object_type;
      
  m_func_name ovc_object_type.get_function%type;
  
begin
  open c_get_function(p_object_type);
  fetch c_get_function into m_func_name;
  close c_get_function;
  
  return m_func_name;
  
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

-- Проверка на возможность сравнить исходные коды объекта
function can_compare(p_object_type in ovc_object_type.type%type,
                     p_modify_type in ovc_event_db.modify_type%type) return varchar2
is
  m_type_info ovc_object_type%rowtype;
begin
  m_type_info := get_object_type_info(p_object_type);
  
  if m_type_info.is_compare = 'T' and p_modify_type in ('CREATE','REVISION') then
    return 'T';
  end if;
  
  return 'F';
end;

end P_OVC_DBOBJECT;
/
