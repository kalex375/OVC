create or replace package P_OVC_PROJECT is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 16.04.10 16:36:52
   Purpose : Проекты
  
  */
  
  -- Создать проект
  procedure create_project(p_id in out ovc_project.id%type,
                           p_name in ovc_project.name%type,
                           p_description in ovc_project.description%type default null,
                           p_open_date in ovc_project.open_date%type default null,
                           p_close_date in ovc_project.close_date%type default null);

  -- Иземенить проект
  procedure update_project(p_id in ovc_project.id%type,
                           p_name in ovc_project.name%type,
                           p_description in ovc_project.description%type,
                           p_open_date in ovc_project.open_date%type,
                           p_close_date in ovc_project.close_date%type);

  -- Удалить проект                          
  procedure delete_project(p_id in ovc_project.id%type);
  
  -- Закрыть проект                           
  procedure close_project(p_id in ovc_project.id%type,
                          p_close_date in ovc_project.close_date%type default null);
  
  -- Добавить объект в проект
  procedure create_object(p_id in out ovc_project_object.id%type,
                          p_project_id in ovc_project_object.project_id%type,                        
                          p_object_type in ovc_project_object.obj_type%type,
                          p_object_owner in ovc_project_object.obj_owner%type,
                          p_object_name in ovc_project_object.obj_name%type,
                          p_is_auto in ovc_project_object.is_auto%type default 'F');

  -- Изменить объект в проекте
  procedure update_object(p_id in ovc_project_object.id%type,
                          p_project_id in ovc_project_object.project_id%type,                        
                          p_object_type in ovc_project_object.obj_type%type,
                          p_object_owner in ovc_project_object.obj_owner%type,
                          p_object_name in ovc_project_object.obj_name%type,
                          p_is_auto in ovc_project_object.is_auto%type);

  -- Удалить объект из проекта
  procedure delete_object(p_id in ovc_project_object.id%type);
                          
end P_OVC_PROJECT;
/
create or replace package body P_OVC_PROJECT is

-- Создать проект
procedure create_project(p_id in out ovc_project.id%type,
                         p_name in ovc_project.name%type,
                         p_description in ovc_project.description%type default null,
                         p_open_date in ovc_project.open_date%type default null,
                         p_close_date in ovc_project.close_date%type default null)
is
begin
  if p_id is null then
    select ovc_project_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_project(id,
                          name, 
                          description, 
                          open_date, 
                          close_date) 
                   values
                          (p_id,
                           p_name,
                           p_description,
                           nvl(p_open_date, sysdate),
                           p_close_date);
                           
end;                         

-- Иземенить проект
procedure update_project(p_id in ovc_project.id%type,
                         p_name in ovc_project.name%type,
                         p_description in ovc_project.description%type,
                         p_open_date in ovc_project.open_date%type,
                         p_close_date in ovc_project.close_date%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID проекта');
  end if;
  
  update ovc_project p set
    p.name = p_name,
    p.description = p_description,
    p.open_date = p_open_date,
    p.close_date = p_close_date
  where
    p.id = p_id;  
  
end;                         
                         

-- Удалить проект                          
procedure delete_project(p_id in ovc_project.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID проекта');
  end if;
  
  delete from ovc_project p where p.id = p_id;
end;                         

    
--Закрыть проект                           
procedure close_project(p_id in ovc_project.id%type,
                        p_close_date in ovc_project.close_date%type default null)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID проекта');
  end if;
  
  update ovc_project p set
    p.close_date = nvl(p_close_date,sysdate)
  where
    p.id = p_id;    
end;                         

-- Добавить объект в проект
procedure create_object(p_id in out ovc_project_object.id%type,
                        p_project_id in ovc_project_object.project_id%type,                        
                        p_object_type in ovc_project_object.obj_type%type,
                        p_object_owner in ovc_project_object.obj_owner%type,
                        p_object_name in ovc_project_object.obj_name%type,
                        p_is_auto in ovc_project_object.is_auto%type default 'F')
is
begin
  
  if p_id is null then 
    select ovc_project_object_seq.nextval into p_id from dual;
  end if;
  
  insert into ovc_project_object (id,
                               project_id,
                               obj_type,
                               obj_owner,
                               obj_name,
                               is_auto) 
                        values
                              (p_id,
                               p_project_id,
                               p_object_type,
                               p_object_owner,
                               p_object_name,
                               p_is_auto);       
end;                        

-- Изменить объект в проекте
procedure update_object(p_id in ovc_project_object.id%type,
                        p_project_id in ovc_project_object.project_id%type,                        
                        p_object_type in ovc_project_object.obj_type%type,
                        p_object_owner in ovc_project_object.obj_owner%type,
                        p_object_name in ovc_project_object.obj_name%type,
                        p_is_auto in ovc_project_object.is_auto%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID объекта');
  end if;
  
  update ovc_project_object po set
    po.project_id = p_project_id,
    po.obj_type = p_object_type,
    po.obj_owner = p_object_owner,
    po.obj_name = p_object_name,
    po.is_auto = p_is_auto
  where
    po.id = p_id;
      
end;                        

-- Удалить объект из проекта
procedure delete_object(p_id in ovc_project_object.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID объекта');
  end if;
  
  delete from ovc_project_object po where po.id = p_id;
  
end;                      
end P_OVC_PROJECT;
/
