create or replace package P_OVC_REVISION is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 20.04.10 15:19:47
   Purpose : Работа с ревизиями
  
  */
  
  -- Тип изменения в change_object
  g_revision_modify_type constant varchar2(8) := 'REVISION';
  
  -- Создать ревизию
  procedure create_revision(p_id in out ovc_revision.id%type,
                            p_code in ovc_revision.code%type default null,
                            p_description in ovc_revision.description%type default null,
                            p_project_id in ovc_revision.project_id%type default null,
                            p_type in ovc_revision.type%type default 'SOFT',
                            p_revision_template_id in ovc_revision.revision_template_id%type default null);

  -- Изменить ревизию
  procedure update_revision(p_id in ovc_revision.id%type,
                            p_code in ovc_revision.code%type,
                            p_description in ovc_revision.description%type);
  
  -- Удалить ревизию
  procedure delete_revison(p_id in ovc_revision.id%type);
   
end P_OVC_REVISION;
/
create or replace package body P_OVC_REVISION is

-- Непосредственная запись массива с исходниками в таблицу изменений
procedure save_source_array(p_change_object_id ovc_change_source.change_object_id%type,
                            p_source_array t_source_table)
is
begin
    insert into ovc_change_source (id,
                                   change_object_id,
                                   line,
                                   text)
                             select
                               ovc_change_source_seq.nextval,
                               p_change_object_id,
                               t.line,
                               t.text
                             from
                               table(p_source_array) t;
      
end;                        

-- Заглушка для объектов которые не поддерживаются
procedure save_no_support(p_change_object_id in ovc_change_object.id%type)
is
begin
    insert into ovc_change_source (id,
                                   change_object_id,
                                   line,
                                   text)
                             values
                                   (ovc_change_source_seq.nextval,
                                    p_change_object_id,
                                    1,
                                    '/* OVC not support type */');      

end;

-- Сохранить исходный код объекта
procedure save_object_source(p_change_object_id in ovc_change_object.id%type)
is
  m_change_object_info ovc_change_object%rowtype;
  m_source_array t_source_table;

  m_func_name ovc_object_type.get_function%type;  
begin

  m_change_object_info := p_ovc_dbobject.get_change_object_info(p_change_object_id);

  m_func_name := p_ovc_dbobject.get_object_function(m_change_object_info.obj_type);
  
  if m_func_name is not null then
    m_source_array := p_ovc_source.get_db_source_array(p_type => m_change_object_info.obj_type,
                                                       p_owner => m_change_object_info.obj_owner,
                                                       p_name => m_change_object_info.obj_name);
    
    save_source_array(p_change_object_id => p_change_object_id,
                      p_source_array => m_source_array);    
                                       
  else
    null;
    --Это будет мешать при сравнение или надо обрабатывать при сравнение
    --save_no_support(p_change_object_id);  
  end if;                                     
                                                      
end;

-- Построить ревизию по объектам проекта
procedure build_project_revision(p_id ovc_revision.id%type)
is
  m_change_id ovc_change_object.id%type;
begin
  for c_list_obj in (select
                       p.obj_type,
                       p.obj_owner,
                       p.obj_name
                     from
                       ovc_revision r,
                       ovc_project_object p
                     where
                       r.project_id = p.project_id and
                       r.id = p_id)
  loop
    m_change_id := null;
    
    -- Запись в таблице изменений
    p_ovc_engine.create_change_object(p_id => m_change_id,
                                      p_obj_type => c_list_obj.obj_type,
                                      p_obj_owner => c_list_obj.obj_owner,
                                      p_obj_name => c_list_obj.obj_name,
                                      p_modify_type => g_revision_modify_type,
                                      p_revision_id => p_id);
                                      
    -- Сохраняем исходный код объекта                               
    save_object_source(p_change_object_id => m_change_id);

                                      
  end loop;                     
end;

-- Построить ревизию по объектам проекта
procedure build_system_revision(p_id ovc_revision.id%type,
                                p_revision_template_id ovc_revision_template.id%type)
is
  m_change_id ovc_change_object.id%type;
begin
  for c_list_obj in ( select
                        cf.id,
                        rt.code rev_temp_code,
                        rt.name rev_temp_name,
                        rt.description rev_temp_desc,
                        filter.*
                      from
                        ovc_filter_set cf,
                        ovc_filter_template f,
                        ovc_revision_template rt,
                        (select
                           o.OBJECT_TYPE obj_type,
                           o.OWNER obj_owner,
                           o.OBJECT_NAME obj_name
                         from
                           ovc_filter_set cf,
                           ovc_filter_template f,
                           all_objects o
                         where
                           cf.revision_template_id = p_revision_template_id and       
                           cf.filter_id = f.id and
                           cf.type = 'REVISION' and
                           cf.enabled='T' and
                           f.ignore= 'F' and
                           (o.OBJECT_TYPE like f.obj_type or (o.OBJECT_TYPE is null and f.obj_type='%'))and
                           (o.OWNER like f.obj_owner or (o.OWNER is null and f.obj_owner='%')) and
                           (o.OBJECT_NAME like f.obj_name or (o.OBJECT_NAME is null and f.obj_name='%')) 
                         minus     
                         select
                           o.OBJECT_TYPE obj_type,
                           o.OWNER obj_owner,
                           o.OBJECT_NAME obj_name
                         from
                           ovc_filter_set cf,
                           ovc_filter_template f,
                           all_objects o
                         where
                           cf.revision_template_id = p_revision_template_id and
                           cf.filter_id = f.id and
                           cf.type = 'REVISION' and
                           cf.enabled='T' and
                           f.ignore= 'T' and
                           (o.OBJECT_TYPE like f.obj_type or (o.OBJECT_TYPE is null and f.obj_type='%'))and
                           (o.OWNER like f.obj_owner or (o.OWNER is null and f.obj_owner='%')) and
                           (o.OBJECT_NAME like f.obj_name or (o.OBJECT_NAME is null and f.obj_name='%')) 
                         ) filter
                      where
                        rt.id = p_revision_template_id and    
                        cf.filter_id = f.id and
                        cf.revision_template_id = rt.id and
                        cf.type = 'REVISION' and      
                        cf.enabled='T' and
                        f.ignore= 'F' and
                        (filter.obj_type like f.obj_type or (filter.obj_type is null and f.obj_type='%'))and
                        (filter.obj_owner like f.obj_owner or (filter.obj_owner is null and f.obj_owner='%')) and
                        (filter.obj_name like f.obj_name or (filter.obj_name is null and f.obj_name='%'))
      )
  loop
    m_change_id := null;
    
    -- Запись в таблице изменений
    p_ovc_engine.create_change_object(p_id => m_change_id,
                                      p_obj_type => c_list_obj.obj_type,
                                      p_obj_owner => c_list_obj.obj_owner,
                                      p_obj_name => c_list_obj.obj_name,
                                      p_modify_type => g_revision_modify_type,
                                      p_revision_id => p_id);
                                      
    -- Сохраняем исходный код объекта                               
    save_object_source(p_change_object_id => m_change_id);

                                      
  end loop;                     
end;


-- Создать ревизию
procedure create_revision(p_id in out ovc_revision.id%type,
                          p_code in ovc_revision.code%type default null,
                          p_description in ovc_revision.description%type default null,
                          p_project_id in ovc_revision.project_id%type default null,
                          p_type in ovc_revision.type%type default 'SOFT',
                          p_revision_template_id in ovc_revision.revision_template_id%type default null)
is
  m_code ovc_revision.code%type;
begin
  if p_id is null then
    select ovc_revision_seq.nextval into p_id from dual;
  end if;
  
  if p_code is null then
    m_code := p_id;
  else  
    m_code := p_code;
  end if;
  
  insert into ovc_revision (id,
                            code,
                            description,
                            project_id,
                            type,
                            revision_template_id)
                      values
                           (p_id,
                            m_code,
                            p_description,
                            p_project_id,
                            p_type,
                            p_revision_template_id);

 --Сохроняем исходники если ХАРД
 if p_project_id is not null and p_type='HARD' then
   --Построение ревизии по объектам проекта
   build_project_revision(p_id);
 elsif p_revision_template_id is not null and p_type='HARD' then
   --Построение ревизии по объектам БД
   build_system_revision(p_id, p_revision_template_id);
 end if;                          
end;                          

-- Изменить ревизию
procedure update_revision(p_id in ovc_revision.id%type,
                          p_code in ovc_revision.code%type,
                          p_description in ovc_revision.description%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID ревизии');
  end if;
  
  update ovc_revision r set
    r.code = p_code,
    r.description = p_description
  where
    r.id = p_id;  
end;                          
    
-- Удалить ревизию
procedure delete_revison(p_id in ovc_revision.id%type)
is
begin
  if p_id is null then
    p_ovc_exception.raise_common_exception('Не задан ID ревизии');
  end if;
  
  delete from ovc_revision r where r.id = p_id;
end;


end P_OVC_REVISION;
/
