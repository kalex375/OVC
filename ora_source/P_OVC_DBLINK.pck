create or replace package P_OVC_DBLINK is

  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 14.05.2010 17:50:35
   Purpose : Вспомагательный функции и процедуры
  
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
                          

end P_OVC_DBLINK;
/
create or replace package body P_OVC_DBLINK is

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


end P_OVC_DBLINK;
/
