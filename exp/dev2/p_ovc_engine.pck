create or replace package ora_ver.P_OVC_ENGINE is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 09.10.09 17:50:35
  Purpose : Главный пакет обработки событий в базе данных

  */

  -- Создать запись в таблице измененй
  procedure create_change_object(p_id in out ovc_change_object.id%type,
                                 p_obj_type in ovc_change_object.obj_type%type,
                                 p_obj_owner in ovc_change_object.obj_owner%type,
                                 p_obj_name in ovc_change_object.obj_name%type,
                                 p_modify_date in ovc_change_object.modify_date%type default null,
                                 p_modify_user in ovc_change_object.modify_user%type default null,
                                 p_modify_terminal in ovc_change_object.modify_terminal%type default null,
                                 p_modify_os_user in ovc_change_object.modify_os_user%type default null,
                                 p_modify_type in ovc_change_object.modify_type%type default null,
                                 p_revision_id in ovc_change_object.revision_id%type default null);
                                 
  --Включить мониторинг
  procedure start_process;

  --Выключить мониторинг
  procedure stop_process;
  
  --Обработка события в базе данных
  procedure process_event(p_ora_dict_obj_type   in varchar2,
                          p_ora_dict_obj_owner  in varchar2,
                          p_ora_dict_obj_name   in varchar2,
                          p_ora_login_user      in varchar2,
                          p_ora_sysevent        in varchar2);

end P_OVC_ENGINE;
/

create or replace package body ora_ver.P_OVC_ENGINE is

-- Создать запись в таблице измененй
procedure create_change_object(p_id in out ovc_change_object.id%type,
                               p_obj_type in ovc_change_object.obj_type%type,
                               p_obj_owner in ovc_change_object.obj_owner%type,
                               p_obj_name in ovc_change_object.obj_name%type,
                               p_modify_date in ovc_change_object.modify_date%type default null,
                               p_modify_user in ovc_change_object.modify_user%type default null,
                               p_modify_terminal in ovc_change_object.modify_terminal%type default null,
                               p_modify_os_user in ovc_change_object.modify_os_user%type default null,
                               p_modify_type in ovc_change_object.modify_type%type default null,
                               p_revision_id in ovc_change_object.revision_id%type default null)
is
begin
  if p_id is null then
    select ovc_change_object_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_change_object(id,
                                obj_type,
                                obj_owner,
                                obj_name,
                                modify_date,
                                modify_user,
                                modify_terminal,
                                modify_os_user,
                                modify_type,
                                revision_id
                                )
                         values (p_id,
                                 p_obj_type,
                                 p_obj_owner,
                                 p_obj_name,
                                 nvl(p_modify_date,systimestamp),
                                 nvl(p_modify_user,user),
                                 nvl(p_modify_terminal,p_ovc_utility.get_client_terminal_name),
                                 nvl(p_modify_os_user,p_ovc_utility.get_client_os_user),
                                 p_modify_type,
                                 p_revision_id);
                            
end;    
  
--Включить мониторинг
procedure start_process
is
begin
  if p_ovc_registry.get_value('SYSTEM','IS_MONITORING')='F' then
    
    p_ovc_registry.set_value(p_path => 'SYSTEM',
                            p_param => 'IS_MONITORING',
                            p_value => 'T');

    p_ovc_registry.set_value(p_path => 'SYSTEM',
                            p_param => 'START_TIME',
                            p_value => sysdate);
  else
    p_ovc_exception.raise_common_exception('Процесс уже запущен.');                      
  end if;                    
                      
end;

--Выключить мониторинг
procedure stop_process
is
begin
  if p_ovc_registry.get_value('SYSTEM','IS_MONITORING')='T' then
    
    p_ovc_registry.set_value(p_path => 'SYSTEM',
                            p_param => 'IS_MONITORING',
                            p_value => 'F');

    p_ovc_registry.set_value(p_path => 'SYSTEM',
                            p_param => 'STOP_TIME',
                            p_value => sysdate);
  else
    p_ovc_exception.raise_common_exception('Процесс не запущен.');                      
  end if;                    
end;

--Сохранение текста изменения
procedure save_event_text(p_object_change_id in ovc_change_object.id%type)
is
  m_sql_text ora_name_list_t;
  m_count pls_integer;

  m_text varchar2(2000);
  m_line pls_integer;   
begin

  m_count := ora_sql_txt(m_sql_text);
    
  if m_count > 0 then
    m_line := 1;
    m_text := null;
    for i in 1..m_count 
    loop
      m_text := m_text||m_sql_text(i);
      while instr(m_text,p_ovc_str_utils.LF)<>0 
      loop
        
        insert into ovc_change_source(id,
                                      change_object_id,
                                      line,
                                      text) 
                              values(
                                     ovc_change_source_seq.nextval,
                                     p_object_change_id,
                                     m_line,
                                     substr(m_text,1,instr(m_text,p_ovc_str_utils.LF)));
         m_line := m_line + 1;                            
         m_text := substr(m_text,instr(m_text,p_ovc_str_utils.LF)+1);                               
      end loop;                              

    end loop;  
  end if;    

end;
                          

--Обработка события в базе данных
procedure process_event(p_ora_dict_obj_type   in varchar2,
                        p_ora_dict_obj_owner  in varchar2,
                        p_ora_dict_obj_name   in varchar2,
                        p_ora_login_user      in varchar2,
                        p_ora_sysevent        in varchar2)
is
  cursor c_get_event(p_obj_type varchar2,
                     p_modify_type varchar2)
  is
    select
      e.*
    from
      ovc_event_db e
    where
      e.obj_type = p_obj_type and
      e.modify_type = p_modify_type and
      e.enabled='T';          
  
  cursor c_get_filter(p_type varchar2,
                      p_obj_type varchar2,
                      p_obj_owner varchar2,
                      p_obj_name varchar2,
                      p_modify_user varchar2,
                      p_modify_terminal varchar2,
                      p_modify_os_user varchar2)
  is   
    select
      cf.id,
      cf.project_id,
      cf.is_auto_lock,
      p.name project_name,
      filter.*
    from
      ovc_filter_set cf,
      ovc_filter_template f,
      ovc_project p,
      (select
         upper(p_obj_type) obj_type,
         upper(p_obj_owner) obj_owner,
         upper(p_obj_name) obj_name,
         upper(p_modify_user) modify_user,
         upper(p_modify_terminal) modify_terminal,
         upper(p_modify_os_user) modify_os_user
       from
         ovc_filter_set cf,
         ovc_filter_template f
       where
         cf.filter_id = f.id and
         cf.type = p_type and
         cf.enabled='T' and
         f.ignore= 'F' and
         (upper(p_obj_type) like f.obj_type or (p_obj_type is null and f.obj_type='%'))and
         (upper(p_obj_owner) like f.obj_owner or (p_obj_owner is null and f.obj_owner='%')) and
         (upper(p_obj_name) like f.obj_name or (p_obj_name is null and f.obj_name='%')) and
         (upper(p_modify_user) like f.modify_user or (p_modify_user is null and f.modify_user='%')) and
         (upper(p_modify_terminal) like f.modify_terminal or (p_modify_terminal is null and f.modify_terminal='%')) and
         (upper(p_modify_os_user) like f.modify_os_user or (p_modify_os_user is null and f.modify_os_user='%'))
       minus     
       select
         upper(p_obj_type) obj_type,
         upper(p_obj_owner) obj_owner,
         upper(p_obj_name) obj_name,
         upper(p_modify_user) modify_user,
         upper(p_modify_terminal) modify_terminal,
         upper(p_modify_os_user) modify_os_user
       from
         ovc_filter_set cf,
         ovc_filter_template f
       where
         cf.filter_id = f.id and
         cf.type = p_type and
         cf.enabled='T' and
         f.ignore= 'T' and
         (upper(p_obj_type) like f.obj_type or (p_obj_type is null and f.obj_type='%'))and
         (upper(p_obj_owner) like f.obj_owner or (p_obj_owner is null and f.obj_owner='%')) and
         (upper(p_obj_name) like f.obj_name or (p_obj_name is null and f.obj_name='%')) and
         (upper(p_modify_user) like f.modify_user or (p_modify_user is null and f.modify_user='%')) and
         (upper(p_modify_terminal) like f.modify_terminal or (p_modify_terminal is null and f.modify_terminal='%')) and
         (upper(p_modify_os_user) like f.modify_os_user or (p_modify_os_user is null and f.modify_os_user='%'))
       ) filter
    where
      cf.filter_id = f.id and
      cf.project_id = p.id(+) and
      cf.type = p_type and      
      cf.enabled='T' and
      f.ignore= 'F' and
      (filter.obj_type like f.obj_type or (filter.obj_type is null and f.obj_type='%'))and
      (filter.obj_owner like f.obj_owner or (filter.obj_owner is null and f.obj_owner='%')) and
      (filter.obj_name like f.obj_name or (filter.obj_name is null and f.obj_name='%')) and
      (filter.modify_user like f.modify_user or (filter.modify_user is null and f.modify_user='%')) and
      (filter.modify_terminal like f.modify_terminal or (filter.modify_terminal is null and f.modify_terminal='%')) and
      (filter.modify_os_user like f.modify_os_user or (filter.modify_os_user is null and f.modify_os_user='%'));
 
  m_lock_object ovc_lock_object%rowtype;     
  m_event c_get_event%rowtype;              
  m_filter c_get_filter%rowtype;

  m_change_id ovc_change_object.id%type;
  m_raise_error boolean;
  
  m_modify_terminal ovc_change_object.modify_terminal%type;
  m_modify_os_user ovc_change_object.modify_os_user%type;
  
begin
  m_raise_error := false;  
  
  if p_ovc_registry.get_value('SYSTEM','IS_MONITORING')<>'T' then 
    return;
  end if;

  m_modify_terminal := p_ovc_utility.get_client_terminal_name;
  m_modify_os_user := p_ovc_utility.get_client_os_user;

  --Проверка полной блокировки
  if p_ovc_registry.get_value_bol('LOCKS','FULL_LOCK') then
    m_raise_error := true;
    p_ovc_exception.raise_common_exception('Включена полная блокировка БД! (LOCKS\FULL_LOCK)');
  end if;
  
  --Проверка блокировок на объекте
  if p_ovc_registry.get_value_bol('LOCKS','LOCK_ENABLED') then
    -- Проверка на ALTER программы
    if not (p_ovc_registry.get_value_bol('LOCKS','IS_ALTER_PROGRAM') = true and 
            p_ora_sysevent='ALTER' and 
            p_ora_dict_obj_type in ('PACKAGE',
                                    'PACKAGE BODY',
                                    'PROCEDURE',
                                    'FUNCTION',
                                    'TYPE',
                                    'TYPE BODY')) then
      -- Блокировки по объектам
      m_lock_object := p_ovc_lock.check_lock(p_ora_dict_obj_type, p_ora_dict_obj_owner, p_ora_dict_obj_name);
      
      if m_lock_object.id is not null then
    
        if m_lock_object.is_full = 'F' and 
          p_ovc_utility.get_user_uid(m_lock_object.lock_user,
                                     m_lock_object.lock_terminal,
                                     m_lock_object.lock_os_user) =
          p_ovc_utility.get_user_uid(ora_login_user,
                                     m_modify_terminal,
                                     m_modify_os_user) 
        then 
          null;
        else  
        
          m_raise_error := true;
          p_ovc_exception.raise_common_exception('Объект %s заблокирован.'||chr(10)
                                                 ||'Время: %s; '||chr(10)
                                                 ||'пользователь: %s;'||chr(10)
                                                 ||'терминал: %s;'||chr(10)
                                                 ||'пользователь ОС: %s.'||chr(10)
                                                 ||'%s',
                                                 m_lock_object.obj_owner||'.'||m_lock_object.obj_name,
                                                 to_char(m_lock_object.lock_time,'DD.MM.YYYY HH24:MI:SS'),
                                                 m_lock_object.lock_user,
                                                 m_lock_object.lock_terminal,
                                                 m_lock_object.lock_os_user,
                                                 m_lock_object.note);  
        end if;                                     
      end if;                                     
    end if;  
  end if;
  
  if not p_ovc_registry.get_value_bol('SYSTEM','SAVE_ALL_CHANGES') then
    --Проверка на события
    open c_get_event(p_ora_dict_obj_type,p_ora_sysevent);
    fetch c_get_event into m_event;
    close c_get_event;
    
    if m_event.id is null then
      return;
    end if;
    
    --Фильтр
    open c_get_filter('SYSTEM',
                      p_ora_dict_obj_type,
                      p_ora_dict_obj_owner,
                      p_ora_dict_obj_name,
                      p_ora_login_user,
                      m_modify_terminal,
                      m_modify_os_user);
                      
    fetch c_get_filter into m_filter;
    close c_get_filter;
    
    if m_filter.id is null then
      return;
    end if;
  end if;
  
  --Регестируем событие
  create_change_object(p_id => m_change_id,
                       p_obj_type => p_ora_dict_obj_type,
                       p_obj_owner => p_ora_dict_obj_owner,
                       p_obj_name => p_ora_dict_obj_name,
                       p_modify_user => p_ora_login_user,
                       p_modify_terminal => m_modify_terminal,
                       p_modify_os_user => m_modify_os_user,
                       p_modify_type => p_ora_sysevent);
  
  -- Сохроняем текст команд 
  if m_event.save_text='T' or p_ovc_registry.get_value_bol('SYSTEM','SAVE_ALL_CHANGES') then
    save_event_text(p_object_change_id => m_change_id);
  end if; 

  -- Авто добавление объектов в проекты по фильтрам проектов 
  if p_ovc_registry.get_value('PROJECT','IS_AUTO_FILTER')='T' then
    m_filter := null;
    
    open c_get_filter('PROJECT',
                      p_ora_dict_obj_type,
                      p_ora_dict_obj_owner,
                      p_ora_dict_obj_name,
                      p_ora_login_user,
                      m_modify_terminal,
                      m_modify_os_user);
    loop
    fetch c_get_filter into m_filter;
    exit when c_get_filter%notfound;
      merge into ovc_project_object opo
      using (select
               p.id project_id,
               p_ora_dict_obj_type obj_type,
               p_ora_dict_obj_owner obj_owner,
               p_ora_dict_obj_name obj_name,                 
               'T' is_auto
             from
               ovc_project p
             where
               p.id = m_filter.project_id and
               p.close_date is null and
               not exists (select 
                             null 
                           from
                             ovc_project_object po
                           where
                             po.project_id = p.id and
                             po.obj_type = p_ora_dict_obj_type and
                             po.obj_owner = p_ora_dict_obj_owner and
                             po.obj_name = p_ora_dict_obj_name)) proj
      on (opo.id = -1)                       
      when matched then update set
        is_auto = 'T'           
      when not matched then insert (id, 
                                    project_id, 
                                    obj_type, 
                                    obj_owner, 
                                    obj_name, 
                                    is_auto)
                             values
                                   (ovc_project_object_seq.nextval,
                                    proj.project_id,
                                    proj.obj_type, 
                                    proj.obj_owner, 
                                    proj.obj_name, 
                                    proj.is_auto);
                                    
      if m_filter.is_auto_lock = 'T' then 
        p_ovc_lock.set_object_lock(p_obj_type => p_ora_dict_obj_type,
                                   p_obj_owner => p_ora_dict_obj_owner,
                                   p_obj_name => p_ora_dict_obj_name,
                                   p_is_full => 'F',
                                   p_lock_user => p_ora_login_user,
                                   p_lock_terminal => m_modify_terminal,
                                   p_lock_os_user => m_modify_os_user,
                                   p_note => 'Автоблокировка при добавлении в проект '||m_filter.project_name,
                                   p_check_exists => false);
      end if;
    end loop;                  
    close c_get_filter;
  end if;
  
--Обработчик ошибок  
exception when others then
  if  m_raise_error then
    raise;
  else  
    p_ovc_exception.raise_system_exception(p_change_object_id => m_change_id,
                                           p_message => sqlerrm);
  end if;                                     
end;                        

end P_OVC_ENGINE;
/

