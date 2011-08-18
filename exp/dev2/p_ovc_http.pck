create or replace package ora_ver.P_OVC_HTTP is

  -- Author  : KRAVCHAV
  -- Created : 25.05.10 16:50:05
  -- Purpose : Web интерфейс
  
  -- Главная страница приложения
  procedure main_page;
  
  -- Возвращает меню для навигации (XML)
  procedure get_navigation_tree(node in varchar2 default null);
  
  -- Возвращает таблицу изменений в БД (XML)
  procedure get_timelife_table(p_start varchar2 default '0',
                               p_limit varchar2 default '50',
                               p_filter varchar2 default '',
                               p_hide_alter varchar2 default 'F');
  
  --Возвращает исходники по id изменения
  procedure get_change_source(p_change_id varchar2 default null);                               


  --Возвращает внесенные изменения в исходники по id изменения
  -- p_prev_change_id номер изенения с которым сравнивать если не задан то с предидущим
  --                  -1 c текущей версией из базы
  -- p_only_diff выводить только разность
  -- p_ignore_case игнорировать регистр
  -- p_ignore_space игнорировать изменения в пропусках
  procedure get_change_diff_source(p_change_id varchar2 default null,
                                   p_prev_change_id varchar2 default null,
                                   p_only_diff varchar2 default 'T',
                                   p_ignore_case varchar2 default 'T',
                                   p_ignore_trailing_space varchar2 default 'T',
                                   p_ignore_leading_space varchar2 default 'T',
                                   p_ignore_space varchar2 default 'T');

  -- Возвращает историю изменений для объекта по ID изменения (XML)
  -- p_change_id ID изменения объекта по которому возвращается вся история изменений
  -- p_show_alter показывать ALTER  для программ (компиляция)
  -- p_only_source только с исходными кодами
  procedure get_change_history_table(p_change_id varchar2 default null,
                                     p_hide_alter varchar2 default 'F',
                                     p_only_source varchar2 default 'F');


  -- Возвращает лог ошибок (XML)
  procedure get_errorlog_table(p_start varchar2 default '0',
                               p_limit varchar2 default '50',
                               p_filter varchar2 default '');

  -- Возвращает таблицу с типами обектов (XML)
  procedure get_objecttype_table(p_start varchar2 default '0',
                                 p_limit varchar2 default '50',
                                 p_filter varchar2 default '');


  -- Возвращает таблицу фильтрами (XML)
  procedure get_filter_table(p_start varchar2 default '0',
                             p_limit varchar2 default '50',
                             p_filter varchar2 default '');
  
  -- Возвращает таблицу c линками (XML)
  procedure get_dblink_table(p_start varchar2 default '0',
                             p_limit varchar2 default '50',
                             p_filter varchar2 default '');                       
  
  -- Обертка для выполнения команд (ХП)
  procedure exec_command(p_command in varchar2,
                         p_params in varchar2);
  
  --Возвращает пути реестра в виде дерева (XML)
  procedure get_registry_tree(node in varchar2 default null);

  -- Возвращает таблицу c параметрами (XML)
  procedure get_registry_table(p_start varchar2 default '0',
                               p_limit varchar2 default '50',
                               p_filter varchar2 default '',
                               p_path  varchar2 default '');

  -- Возвращает таблицу c блокировками (XML)
  procedure get_lock_table(p_start varchar2 default '0',
                           p_limit varchar2 default '50',
                           p_filter varchar2 default '');

  --Возвращает проекты в виде дерева (XML)
  procedure get_project_tree(node in varchar2 default null);
                               
  -- Возвращает таблицу c проектами (XML)
  procedure get_project_table(p_start varchar2 default '0',
                              p_limit varchar2 default '50',
                              p_filter varchar2 default '');
  
  -- Возвращает статус системы (JSON)
  procedure get_status;
                               
end P_OVC_HTTP;
/

create or replace package body ora_ver.P_OVC_HTTP is

  -- Local variables here
  type TParam is record (
    rn pls_integer,
    position pls_integer,
    name varchar2(100),
    defaulted varchar2(1), --Y/N
    direct varchar2(6), --IN/OUT    
    is_set varchar2(1), --Y/N
    param_type varchar2(3),  --STR INT NUM DAT BOL(0,1)
    value varchar2(4000),
    value_int pls_integer,
    value_num number,
    value_dat date,
    value_bol pls_integer
    
);
  
  type TParams  is table of TParam index by pls_integer;

-- Главная страница приложения
procedure main_page
is
  m_clob clob;
begin
   m_clob := dbms_xdb.getContentClob(abspath => '/ovc_data/index.html');
   htp.p(m_clob);
end;

-- Возвращает меню для навигации (XML)
procedure get_navigation_tree(node in varchar2 default null)
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_navigation XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  m_ctxh := 
    dbms_xmlgen.newcontextFromHierarchy(
      'select 
         level,
         xmlelement("name",xmlattributes(code as "code", code as "id", description as "description", name as "text", xtype as "xtype", level as "level", icon as "iconCls", ''true'' as "expanded"))
       from 
         ovc_navigation n
       start with n.perent_id is null
       connect by prior n.id=n.perent_id
       order siblings by order_code'
        );
  dbms_xmlgen.setRowSetTag(m_ctxh, 'root');
  m_navigation := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  htp.p(m_navigation.GetClobVal);
end;

-- Возвращает таблицу изменений в БД (XML)
procedure get_timelife_table(p_start varchar2 default '0',
                             p_limit varchar2 default '50',
                             p_filter varchar2 default '',
                             p_hide_alter varchar2 default 'F')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('
      select
        v.totalrows,
        v.rn,
        v.id,
        v.obj_type,
        v.obj_owner,
        v.modify_date,
        v.obj_name,
        v.modify_user,
        v.modify_terminal,
        v.modify_os_user,
        v.modify_type,
        v.revision_id,
        v.revision_code,
        v.revision_desc
      from
        (select
           count(v.id) over () totalrows,
           row_number() over (order by v.modify_date, v.id) rn,
           v.id,
           v.obj_type,
           v.obj_owner,
           to_char(v.modify_date,''DD.MM.YYYY HH24:MI:SS'') modify_date,
           v.modify_date modify_date_dat,
           v.obj_name,
           v.modify_user,
           v.modify_terminal,
           v.modify_os_user,
           v.modify_type,
           v.revision_id,
           v.revision_code,
           v.revision_desc
         from
          (
            select 
              co.id,
              co.obj_type,
              co.obj_owner,
              co.modify_date,
              co.obj_name,
              co.modify_user,
              co.modify_terminal,
              co.modify_os_user,
              co.modify_type,
              co.revision_id,
              r.code revision_code,
              r.description revision_desc
            from 
              ovc_change_object co,
              ovc_revision r
            where
              co.revision_id = r.id(+) and
              not (co.obj_type in (''PACKAGE'',''PACKAGE BODY'',''FUNCTION'',''PROCEDURE'',''TYPE'') and  co.modify_type=''ALTER'' and :p_hide_alter = ''T'') 
            ) v
         where
           1=1
           '||p_filter||'   
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1) 
      order by v.modify_date_dat, v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_hide_alter',
                           bindValue => p_hide_alter);
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then 
    null;
  else  
    htp.prn(m_xml_table.GetClobVal);                                
  end if;                                
end;                             

--Возвращает исходники по id изменения
procedure get_change_source(p_change_id varchar2 default null)
is
begin
  htp.p('<pre class="brush: plsql;">');
  for c_list_source in (select
                          p_ovc_str_utils.encode_web_str(cs.text) text
                        from
                          ovc_change_source cs
                        where
                          cs.change_object_id = p_change_id
                        order by cs.line  
                       )
  loop
   htp.prn(c_list_source.text);
  end loop;                       
  htp.p('</pre>');
end;

--Возвращает внесенные изменения в исходники по id изменения
-- p_prev_change_id номер изенения с которым сравнивать если не задан то с предидущим
--                  -1 c текущей версией из базы
-- p_only_diff выводить только разность
-- p_ignore_case игнорировать регистр
-- p_ignore_space игнорировать изменения в пропусках
procedure get_change_diff_source(p_change_id varchar2 default null,
                                 p_prev_change_id varchar2 default null,
                                 p_only_diff varchar2 default 'T',
                                 p_ignore_case varchar2 default 'T',
                                 p_ignore_trailing_space varchar2 default 'T',
                                 p_ignore_leading_space varchar2 default 'T',
                                 p_ignore_space varchar2 default 'T')
is
  m_obj_source_1 t_source_table;
  m_obj_source_2 t_source_table;
  
  m_change_object_info ovc_change_object%rowtype;
  
  m_compare_int p_ovc_diff.TCompareRecInt;
  m_ch varchar2(10);      
begin
  
  if p_prev_change_id is not null then
    
    -- Получаем исходники и его хеши для сравнени
    m_obj_source_1 := t_source_table();
    m_obj_source_2 := t_source_table();
     
    --То что было
    if p_prev_change_id = -1 then
      
      m_change_object_info := p_ovc_dbobject.get_change_object_info(p_change_id => p_change_id);
      
      --берем исходники из базы
      m_obj_source_1 := p_ovc_source.get_db_source_array(p_type => m_change_object_info.obj_type,
                                                         p_owner => m_change_object_info.obj_owner,
                                                         p_name => m_change_object_info.obj_name); 
    else
      m_obj_source_1 := p_ovc_source.get_change_source_array(p_change_id => p_prev_change_id);
    end if;
    
    --То что есть
    m_obj_source_2 := p_ovc_source.get_change_source_array(p_change_id => p_change_id);
    
    --Сравниваем
    p_ovc_diff.compare(p_sour_1 =>  m_obj_source_1, 
                       p_sour_2 =>  m_obj_source_2,
                       p_ignore_case => p_ignore_case,
                       p_ignore_leading_space => p_ignore_leading_space,
                       p_ignore_trailing_space => p_ignore_trailing_space);
    --Вывод
    htp.p('<pre class="brush: ovcdiff;">');
    for i in 0..p_ovc_diff.Get_Compare_Count-1 
    loop
      m_compare_int := p_ovc_diff.Get_Compare_Int(i);
     
      select decode(m_compare_int.Kind,p_ovc_diff.ckNone,'None',p_ovc_diff.ckAdd,'Add',p_ovc_diff.ckDelete,'Delete',p_ovc_diff.ckModify,'Modify',' ') into m_ch from dual;
     
      if m_compare_int.Kind in (p_ovc_diff.ckAdd, p_ovc_diff.ckModify) or (p_only_diff = 'F' and m_compare_int.Kind in (p_ovc_diff.ckNone)) then
      
        htp.prn(rpad(m_ch,6,' ')||'      '||lpad(to_char(m_compare_int.OldIndex2),6,' ')||' '|| p_ovc_str_utils.encode_web_str(m_obj_source_2(m_compare_int.OldIndex2).text));
      
      elsif m_compare_int.Kind in (p_ovc_diff.ckDelete) then

        htp.prn(rpad(m_ch,6,' ')||lpad(to_char(m_compare_int.OldIndex1),6,' ')||'      '||' '||p_ovc_str_utils.encode_web_str(m_obj_source_1(m_compare_int.OldIndex1).text));      

      else
        null;
      end if;  
    end loop;                            
    htp.p('</pre>');    
    
    p_ovc_diff.ClearCompare;
    
  else
    htp.p('<p>No previous source found.</p>');
  end if;  
end;

-- Возвращает историю изменений для объекта по ID изменения (XML)
-- p_change_id ID изменения объекта по которому возвращается вся история изменений
-- p_show_alter показывать ALTER  для программ (компиляция)
-- p_only_source только с исходными кодами
procedure get_change_history_table(p_change_id varchar2 default null,
                                   p_hide_alter varchar2 default 'F',
                                   p_only_source varchar2 default 'F')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('
     select
      pco.id,
      to_char(pco.modify_date,''DD.MM.YYYY HH24:MI:SS'') modify_date,
      pco.modify_date modify_date_ts,
      pco.modify_user,
      pco.modify_terminal,
      pco.modify_type,
      decode(pco.id,:p_change_id,''T'',''F'') is_current,
      p_ovc_dbobject.can_compare(pco.obj_type,modify_type) can_compare
    from
      ovc_change_object pco,
      (select
         co.id,
         co.modify_date,
         co.obj_type,
         co.obj_owner,
         co.obj_name
       from
         ovc_change_object co
       where
         co.id = :p_change_id) lco
    where
      pco.obj_type = lco.obj_type and
      (pco.obj_owner = lco.obj_owner or (lco.obj_owner is null and pco.obj_owner is null)) and
      pco.obj_name = lco.obj_name and
      not (pco.modify_type = ''ALTER'' and :p_hide_alter=''T'')
    union all
    select
      -1 id,
      ''Database'' modify_date,
      null modify_date_ts,
      null modify_user,
      null modify_terminal,
      null modify_type,
      ''F'',
      p_ovc_dbobject.can_compare(co.obj_type,''CREATE'') can_compare
    from
      ovc_change_object co,
      all_objects o
    where
      co.id = :p_change_id and
      co.obj_type = o.object_type and
      co.obj_owner = o.owner and
      co.obj_name = o.object_name  
    order by modify_date_ts nulls last'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_change_id',
                           bindValue =>  p_change_id);
                           
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_hide_alter',
                           bindValue =>  p_hide_alter);
                           

  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  
  if m_xml_table is null then 
    null;
  else  
    htp.prn(m_xml_table.GetClobVal);                                
  end if;  
end;                             

-- Возвращает лог ошибок (XML)
procedure get_errorlog_table(p_start varchar2 default '0',
                             p_limit varchar2 default '50',
                             p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('
      select
        v.totalrows,
        v.rn,
        v.id,
        v.error_time,
        v.code,
        v.message,
        v.terminal,
        v.os_user,
        v.change_object_id
      from
        (
         select
            count(v.id) over () totalrows,
            row_number() over (order by v.error_time, v.id) rn,
            v.id,
            to_char(v.error_time,''DD.MM.YYYY HH24:MI:SS'') error_time,
            v.code,
            v.message,
            v.terminal,
            v.os_user,
            v.change_object_id
         from
          (
            select 
              el.id,
              el.error_time,
              el.code,
              el.message,
              el.terminal,
              el.os_user,
              el.change_object_id
            from 
              ovc_error_log el
           ) v  
         where
           1=1  
           '||p_filter||'
            
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1) 
      order by v.error_time, v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

-- Возвращает таблицу с типами обектов (XML)
procedure get_objecttype_table(p_start varchar2 default '0',
                               p_limit varchar2 default '50',
                               p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.rn,
        v.id,
        v.type,
        v.metadata_type,
        v.get_function,
        v.is_program,
        v.is_compare
      from
        (
         select
           count(v.id) over () totalrows,
           row_number() over (order by v.id) rn,
           v.id,
           v.type,
           v.metadata_type,
           v.get_function,
           v.is_program,
           v.is_compare  
         from
           (
            select 
              ot.id,
              ot.type,
              ot.metadata_type,
              ot.get_function,
              ot.is_program,
              ot.is_compare
            from 
              ovc_object_type ot ) v
         where
           1=1     
          '||p_filter||'         
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1) 

      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

-- Возвращает таблицу фильтрами (XML)
procedure get_filter_table(p_start varchar2 default '0',
                           p_limit varchar2 default '50',
                           p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.rn,
        v.id,
        v.name,
        v.obj_type,
        v.obj_owner,
        v.obj_name,
        v.modify_user,
        v.modify_terminal,
        v.modify_os_user,
        v.ignore
      from
        ( 
         select
           count(v.id) over () totalrows,
           row_number() over (order by v.id) rn,
           v.id,
           v.name,
           v.obj_type,
           v.obj_owner,
           v.obj_name,
           v.modify_user,
           v.modify_terminal,
           v.modify_os_user,
           v.ignore           
         from
          (
           select 
             f.id,
             f.name,
             f.obj_type,
             f.obj_owner,
             f.obj_name,
             f.modify_user,
             f.modify_terminal,
             f.modify_os_user,
             f.ignore
           from 
             ovc_filter_template f )v
         where
           1=1   
           '||p_filter||'           
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1) 
      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

-- Возвращает таблицу c линками (XML)
procedure get_dblink_table(p_start varchar2 default '0',
                           p_limit varchar2 default '50',
                           p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.rn,
        v.id,
        v.name,
        v.description,
        v.type
      from
        (
         select
            count(v.id) over () totalrows,
            row_number() over (order by v.id) rn,
            v.id,
            v.name,
            v.description,
            v.type
         from
          (
          select 
            f.id,
            f.name,
            f.description,
            f.type
          from 
            ovc_dblink f) v
          where
            1=1  
            '||p_filter||'            
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1) 

      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;


--Проверяет команда является функцие или процедурой
function is_command_func(p_schema in varchar2,
                         p_part1 in varchar2,
                         p_part2 in varchar2) return varchar2
is
  m_is_func varchar2(1);
begin

  select 
    decode(count(aas.OWNER) ,0,'F','T') into m_is_func 
  from 
    all_arguments aas 
  where                  
    aas.POSITION=0 and     
    ((aas.PACKAGE_NAME = p_part1) or  (p_part1 is null and aas.PACKAGE_NAME is null)) and
    aas.OBJECT_NAME = p_part2 and
    aas.OWNER = p_schema;

  return m_is_func;
    
end;

--Формирует ответ сервера об ошибке в формете json 
function format_json_error(p_error_title in varchar2,
                           p_error_message in varchar2) return varchar2
is
  m_json_err varchar2(4000) := '{success: false, errors: {title: "ORA%s" }, errormsg: "%s" }';
begin
  return p_ovc_str_utils.format_string(m_json_err,replace(p_error_title,'"','\"'),replace(p_error_message,'"','\"'));
end;  

--Формирует ответ сервера c с параметрами в формете json 
function format_json_params(p_params in TParams) return varchar2
is
  m_json varchar2(4000):='{success: true, data:{%S}}';
  m_data varchar2(4000);
  m_f varchar2(1) := 'F';
begin
  if p_params.count>0 then
    for i in p_params.first..p_params.last
    loop
      if p_params(i).direct in ('IN/OUT','OUT') then
        if m_f = 'F' then
          m_f := 'T';
        else
          m_data := m_data||','||p_ovc_str_utils.CRLF;  
        end if; 
        m_data := m_data||'"'||p_params(i).name||'":"'||replace(p_params(i).value,'"','\"')||'"';  
      end if;  
    end loop;
  end if;
  return p_ovc_str_utils.format_string(m_json,m_data);
end;  

--Парсит строку параметров и в возвражает и виде курсора
--Строка параметров
--         <#>param_name1<@>param_type1<@>param_value1<#><#>param_name2<@>param_type2<@>param_value2<#>
--         param_type : STR - varchar2
--                      INT - pls_integer
--                      NUM - number
--                      DAT - date (DD.MM.YYYY HH24:MI:SS)     
--                      BOL - (boolean)pls_integer (1/0)                              
procedure parse_params(p_params in varchar2, 
                       p_schema in varchar2,
                       p_part1 in varchar2,
                       p_part2 in varchar2,
                       p_param_table out TParams)
is
begin
  select
    arg.rn,
    arg.position,
    arg.argument_name param_name,
    arg.defaulted defaulted,
    arg.in_out direct,
    case 
      when arg.argument_name = 'M_RESULT_FUNC' then 'Y'
      when par.rn is null then 'N'
      else 'Y'
    end is_set,  
    case 
      when param_type is null and  
      arg.data_type in ('CHAR',
                        'NCHAR',
                        'NVARCHAR2',
                        'VARCHAR2') then 'STR'

      when param_type is null and  
      arg.data_type in ('BINARY_DOUBLE',
                        'BINARY_FLOAT',
                        'FLOAT',
                        'NUMBER') then 'NUM'    
                        
      when param_type is null and  
      arg.data_type in ('BINARY_INTEGER') then 'INT'                          

      when param_type is null and  
      arg.data_type in ('DATE') then 'DAT'                          

      when param_type is null and  
      arg.data_type in ('PL/SQL BOOLEAN') then 'BOL'                          
      when param_type is null then 'NOT'
      else par.param_type
      --'BFILE' 'BLOB' 'CLOB' 'NCLOB' 'INTERVAL DAY TO SECOND' 'INTERVAL YEAR TO MONTH' 'LONG' 'LONG RAW' 'MLSLABEL' 'OBJECT' 'PL/SQL RECORD' 'PL/SQL TABLE' 'RAW' 'REF' 'REF CURSOR' ROWID' 'TABLE' TIME' 'TIME WITH TIME ZONE' 'TIMESTAMP' TIMESTAMP WITH LOCAL TIME ZONE' 'TIMESTAMP WITH TIME ZONE' 'UNDEFINED' 'UROWID' 'VARRAY'
    end param_type,
    param_value,
    param_value_int,
    param_value_num,
    param_value_dat,
    param_value_bol
  bulk collect into 
    p_param_table
  from 
   (
    select
      case when aa.ARGUMENT_NAME is null and aa.POSITION=0 then 'M_RESULT_FUNC'
      else aa.ARGUMENT_NAME end ARGUMENT_NAME,
      aa.in_out,
      aa.SEQUENCE,
      aa.pls_type,
      aa.POSITION,
      count(aa.OWNER) over () count_arg,
      row_number() over (order by aa.POSITION) rn,
      aa.DATA_TYPE,
      aa.DEFAULTED
    from
     all_arguments aa
    where
     ((aa.PACKAGE_NAME = p_part1) or  (p_part1 is null and aa.PACKAGE_NAME is null)) and
     aa.OBJECT_NAME = p_part2 and
     aa.OWNER = p_schema and
     aa.DATA_LEVEL = 0 and
     (aa.OVERLOAD is null or aa.OVERLOAD = 1)
    ) arg,
   (                     
    select
      rn,
      param_str,
      upper(param_name) param_name,
      null direct,
      param_type,  
      param_value,
      case
        when param_type='INT' then to_number(param_value,'FM9999999999999999999')
        else null
      end param_value_int,

      case
        when param_type='NUM' then to_number(param_value,'FM9999999999999999999D00009999999','nls_numeric_characters = ''. ''')
        else null
      end param_value_num,

      case
        when param_type='DAT' then to_date(param_value,'DD.MM.YYYY HH24:MI:SS')
        else null
      end param_value_dat,

      case
        when param_type='BOL' and upper(param_value)='TRUE' then 1
        when param_type='BOL' and upper(param_value)='FALSE' then 0
        else null
      end param_value_bol     

    from
      (
        select
          rn,
          param_str,
          substr(param_str,1,instr(param_str,'<@>',1,1)-1) param_name,
          substr(param_str,instr (param_str,'<@>',1,1)+3,instr (param_str,'<@>',1,2)-instr (param_str,'<@>',1,1)-3) param_type,  
          substr(param_str,instr (param_str,'<@>',1,2)+3,length(param_str)-instr(param_str,'<@>',1,2)-2) param_value
        from
          (
            select 
              level rn,
              substr(p_params,instr (p_params,'<#>',1,level*2-1)+3,instr (p_params,'<#>',1,level*2)-instr (p_params,'<#>',1,level*2-1)-3) param_str
            from 
              dual
            connect by level<=p_ovc_str_utils.SymbolCount(p_params,'<#>')/2
          ) p_str
      ) p
   ) par
  where
    arg.ARGUMENT_NAME = par.param_name(+)
  order by arg.rn;
        
end;

-- Обертка для выполнения команд (ХП)
procedure exec_command(p_command in varchar2,
                       p_params in varchar2)
is
   
  m_command_str varchar2(32000);
  m_schema varchar2(50);
  m_part1 varchar2(50);
  m_part2 varchar2(50);
  m_dblink varchar2(50);
  m_part1_type varchar2(50);
  m_object_number varchar2(50);
  m_offset_str pls_integer;
  m_is_func varchar2(1);
  m_cur pls_integer;
  m_rows pls_integer;
  m_param_table Tparams;
  m_result pls_integer;
  m_is_open varchar2(1) := 'F';
begin
  --Разбираем команду на части
  dbms_utility.name_resolve(name => p_command,
                            context => '1',
                            schema => m_schema,
                            part1 => m_part1,
                            part2 => m_part2,
                            dblink => m_dblink,
                            part1_type => m_part1_type,
                            object_number => m_object_number);

  --Признак функция или процедура
  m_is_func := is_command_func(m_schema, m_part1, m_part2);  
  
  --Парсим параметры и заполняем структуру всеми параметрами операции
  p_ovc_http.parse_params(p_params, m_schema, m_part1, m_part2, m_param_table);
 

  --p_ovc_exception.raise_common_exception(m_param_table.count);
  --Функция
  if m_is_func='T' then
      if m_param_table(m_param_table.first).param_type = 'BOL' then
        m_command_str := 'declare'||p_ovc_str_utils.CRLF||
                         '  m_result_bool boolean;'||p_ovc_str_utils.CRLF||
                         'begin'||p_ovc_str_utils.CRLF||
                         '  m_result_bool := '||p_command;
      else
        m_command_str := 'begin'||p_ovc_str_utils.CRLF||
                         '  :M_RESULT_FUNC := '||p_command;
      end if;  
      m_offset_str:= 20;
  --Процедура
  else 
    m_command_str := 'begin'||p_ovc_str_utils.CRLF||
                     '  '||p_command;
    m_offset_str:= 3; 
  end if;  
  
  if m_param_table.count>0 then 
    for i in m_param_table.first..m_param_table.last
    loop

      --Если есть параметры
      if m_param_table(i).name <> 'M_RESULT_FUNC' then     
        --Параметры передали с клиента
        if m_param_table(i).is_set = 'Y' then
          --На первом отркрываем скобку
          if m_is_open = 'F'  then   
            m_command_str := m_command_str||'(';
            m_is_open := 'T';
          --Добавляем запятую и делаем выравнивание 
          else
            m_command_str := m_command_str||','||p_ovc_str_utils.CRLF||rpad('  ',length(p_command)+m_offset_str,' '); 
          end if;  
           
          if m_param_table(i).param_type = 'BOL' then
            m_command_str := m_command_str||m_param_table(i).name||' => sys.diutil.int_to_bool(:'||m_param_table(i).name||')';
          else  
            m_command_str := m_command_str||m_param_table(i).name||' => :'||m_param_table(i).name;
          end if;  
       
        --Параметр не передали с клиента но он дефолтный  
        elsif m_param_table(i).is_set = 'N' and  m_param_table(i).defaulted='Y' then 
          null;
        else
          p_ovc_exception.raise_common_exception('Value not found! Parametr: %s',m_param_table(i).name);
        end if;  
      end if;
    end loop;
  end if;
  
  --Если открывали скобки для параметров, то надо бы из и закрыть
  if m_is_open = 'T' then
    m_command_str := m_command_str||')';
  end if;
    
  if m_is_func='T' then
    if m_param_table(m_param_table.first).param_type='BOL' then
      m_command_str := m_command_str||';'||p_ovc_str_utils.CRLF||
      '  :M_RESULT_FUNC := sys.diutil.bool_to_int(m_result_bool);'||p_ovc_str_utils.CRLF||
      'end;';
    end if;  
  else
    m_command_str := m_command_str||';'||p_ovc_str_utils.CRLF||'end;';
  end if;
  
  --dbms_output.put_line(m_command_str);                     
 
  m_cur := dbms_sql.open_cursor;
 
  dbms_sql.parse(m_cur, m_command_str, dbms_sql.native);
 
  --Устанавляваем занчения переменных
  if m_param_table.count>0 then
    for i in m_param_table.first..m_param_table.last
    loop
      if m_param_table(i).is_set = 'Y' then
        if m_param_table(i).param_type = 'INT' then
          dbms_sql.bind_variable(m_cur,m_param_table(i).name,m_param_table(i).value_int);
        elsif m_param_table(i).param_type = 'NUM' then
          dbms_sql.bind_variable(m_cur,m_param_table(i).name,m_param_table(i).value_num);   
        elsif m_param_table(i).param_type = 'DAT' then     
          dbms_sql.bind_variable(m_cur,m_param_table(i).name,m_param_table(i).value_dat);   
        elsif m_param_table(i).param_type = 'BOL' then
          dbms_sql.bind_variable(m_cur,m_param_table(i).name,m_param_table(i).value_bol);   
        else
          dbms_sql.bind_variable(m_cur,m_param_table(i).name,m_param_table(i).value);
        end if;
      end if;  
    end loop;
  end if;  

  m_rows :=dbms_sql.execute(m_cur);

  --Забираем значения
  if m_param_table.count>0 then
    for i in m_param_table.first..m_param_table.last
    loop
      if m_param_table(i).direct in ('IN/OUT','OUT') then
        
        if m_param_table(i).param_type = 'INT' then
          dbms_sql.variable_value(m_cur,m_param_table(i).name,m_param_table(i).value_int);
          m_param_table(i).value := to_char(m_param_table(i).value_int,'FM9999999999999999999');
        
        elsif m_param_table(i).param_type = 'NUM' then
          dbms_sql.variable_value(m_cur,m_param_table(i).name,m_param_table(i).value_num);   
          m_param_table(i).value := to_char(m_param_table(i).value_num,'FM9999999999999999999D00009999999','nls_numeric_characters = ''. ''');      
        
        elsif m_param_table(i).param_type = 'DAT' then     
          dbms_sql.variable_value(m_cur,m_param_table(i).name,m_param_table(i).value_dat);   
          m_param_table(i).value := to_char(m_param_table(i).value_dat,'DD.MM.YYYY HH24:MI:SS');
        
        elsif m_param_table(i).param_type = 'BOL' then
          dbms_sql.variable_value(m_cur,m_param_table(i).name,m_param_table(i).value_bol);   
          case 
            when m_param_table(i).value_bol = 1 then  m_param_table(i).value := 'true';
             when m_param_table(i).value_bol = 0 then  m_param_table(i).value := 'false';
          end case;   
        
        else
          dbms_sql.variable_value(m_cur,m_param_table(i).name,m_param_table(i).value);
        end if;
        
      end if;  
    end loop;
  end if;
  
  dbms_sql.close_cursor(m_cur);

  --dbms_output.put_line(format_json_params(m_param_table));
  htp.prn(format_json_params(m_param_table));
  
exception when others then
  --dbms_output.put_line(format_json_error(sqlcode,substr(sqlerrm,1,200)));
  htp.prn(format_json_error(sqlcode,substr(sqlerrm,1,255)));
end;

--Возвращает пути реестра в виде дерева (XML)
procedure get_registry_tree(node in varchar2 default null)
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_navigation XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  m_ctxh := 
    dbms_xmlgen.newcontextFromHierarchy(
      '       select
         2, 
         xmlelement("path", xmlattributes(n.path as "id", n.path as "code", n.path_name as "text", 2 as "level", ''icon_folder_open'' as "iconCls"))
       from 
         ovc_registry_path n
       order by n.path'
        );
  dbms_xmlgen.setRowSetTag(m_ctxh, 'root');
  m_navigation := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  htp.p(m_navigation.GetClobVal);
end;

-- Возвращает таблицу c параметрами (XML)
procedure get_registry_table(p_start varchar2 default '0',
                             p_limit varchar2 default '50',
                             p_filter varchar2 default '',
                             p_path  varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.id,
        v.path,
        v.param,
        v.value,
        v.description,
        v.type,
        v.path_name,
        v.read_only
      from
        (
          select
            count(v.id) over () totalrows,
            row_number() over (order by v.id) rn,
            v.id,
            v.path,
            v.param,
            v.value,
            v.description,
            v.type,
            v.path_name,
            v.read_only
          from
          (
            select 
              f.id,
              p.path,
              f.param,
              f.value,
              f.description,
              f.type,
              p.path_name,
              f.read_only
            from 
              ovc_registry f,
              ovc_registry_path p
            where
              f.path_id = p.id and
              p.path = :p_path
            ) v
          where 
            1=1      
            '||p_filter||'
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1)
        
      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_path',
                           bindValue => p_path);
                           
                           
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

-- Возвращает таблицу c блокировками (XML)
procedure get_lock_table(p_start varchar2 default '0',
                         p_limit varchar2 default '50',
                         p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.rn,
        v.id,
        v.obj_type,
        v.obj_owner,
        v.obj_name,
        v.lock_user,
        v.lock_terminal,
        v.lock_os_user,
        v.lock_time,
        v.is_full,
        v.note
      from
        (
          select
            count(v.id) over () totalrows,
            row_number() over (order by v.id) rn,
            v.id,
            v.obj_type,
            v.obj_owner,
            v.obj_name,
            v.lock_user,
            v.lock_terminal,
            v.lock_os_user,
            to_char(v.lock_time,''DD.MM.YYYY HH24:MI:SS'') lock_time,
            v.is_full,
            v.note
          from
          (
            select
              l.id,
              l.obj_type,
              l.obj_owner,
              l.obj_name,
              l.lock_user,
              l.lock_terminal,
              l.lock_os_user,
              l.lock_time,
              l.is_full,
              l.note
            from
              ovc_lock_object l
            ) v
          where 
            1=1      
            '||p_filter||'
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1)
        
      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
                          
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

--Возвращает проекты в виде дерева (XML)
procedure get_project_tree(node in varchar2 default null)
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_navigation XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  m_ctxh := 
    dbms_xmlgen.newcontextFromHierarchy(
      'select
        level,
        xmlelement("name",xmlattributes(id as "code", id as "id", name as "text", level as "level", icon as "iconCls", expanded as "expanded"))
      from
      (
       select
         to_char(n.id) id,
         to_char(null) perent_id,
         n.name,
         ''icon_package'' icon,
         ''false'' expanded
       from 
         ovc_project n
       union all
       select
         f.code||to_char(n.id) id,
         to_char(n.id) perent_id,
         f.name,
         f.icon,
         ''false'' expanded
       from
        ovc_project n,
        (select ''Object'' name, ''o'' code, ''icon_folder_open'' icon from dual
        union
         select ''Filter'' name, ''f'' code, ''icon_folder_open'' icon from dual) f
       union all
       select
         to_char(po.id) id,
         ''o'' || to_char(po.project_id) project_id,
         po.obj_name,
         ''icon_objects'' icon,
         ''false'' expanded
       from  
         ovc_project_object po
       union all
       select
         to_char(s.id) id,
         ''f''||s.project_id,
         to_char(s.filter_id),
         ''icon_filter'' icon,
         ''false'' expanded
       from
         ovc_filter_set s
       where
         s.project_id is not null) v
       start with v.perent_id is null
       connect by prior v.id = v.perent_id'
        );
  dbms_xmlgen.setRowSetTag(m_ctxh, 'root');
  m_navigation := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  htp.p(m_navigation.GetClobVal);
end;


-- Возвращает таблицу c проектами (XML)
procedure get_project_table(p_start varchar2 default '0',
                            p_limit varchar2 default '50',
                            p_filter varchar2 default '')
is
  m_ctxh dbms_xmlgen.ctxhandle;
  m_xml_table XMLType;
begin
  owa_util.mime_header(ccontent_type => 'text/xml');
  
  m_ctxh := dbms_xmlgen.newContext('      
      select
        v.totalrows,
        v.rn,
        v.id,
        v.name,
        v.description,
        v.open_date,
        v.close_date
      from
        (
          select
            count(v.id) over () totalrows,
            row_number() over (order by v.id) rn,
            v.id,
            v.name,
            v.description,
            to_char(v.open_date,''DD.MM.YYYY HH24:MI:SS'') open_date,
            to_char(v.close_date,''DD.MM.YYYY HH24:MI:SS'') close_date
          from
          (
            select
              p.id,
              p.name,
              p.description,
              p.open_date,
              p.close_date 
            from
              ovc_project p
            ) v
          where 
            1=1      
            '||p_filter||'
        ) v
      where
        v.rn >= :p_start and v.rn <= (:p_start + :p_limit - 1)
        
      order by v.id'); 
       
  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_limit',
                           bindValue =>  p_limit);

  dbms_xmlgen.setBindValue(ctx => m_ctxh,
                           bindName => 'p_start',
                           bindValue => p_start);
                           
                          
  m_xml_table := dbms_xmlgen.getxmltype(m_ctxh);
  dbms_xmlgen.closecontext(m_ctxh);
  if m_xml_table is null then
    null;
  else 
    htp.p(m_xml_table.GetClobVal);                                
  end if;  

end;

-- Возвращает статус системы (JSON)
procedure get_status
is
  cursor c_get_status
  is
    select 
      '{success: true, data:{'||wm_concat(param||':'||'"'||value||'"')||'}}' str
    from
      (
       select
         'STATUS' param,
         decode(p_ovc_registry.get_value('SYSTEM','IS_MONITORING'),'T','SERVICE RUNNING','SERVICE STOPPED') value
       from
         dual
       union all 
       select  
         'TIME' param,
         to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') value
       from dual
       union all  
       select  
         'START_TIME' param,
         case p_ovc_registry.get_value('SYSTEM','IS_MONITORING')
           when 'T' then p_ovc_registry.get_value('SYSTEM','START_TIME') 
           else ''
         end value
       from dual
       union all 
       select  
         'STOP_TIME' param,
         case p_ovc_registry.get_value('SYSTEM','IS_MONITORING')
           when 'T' then ''
           else p_ovc_registry.get_value('SYSTEM','STOP_TIME') 
         end value
       from dual
       union all 
       select  
         'UP_TIME' param,
         case p_ovc_registry.get_value('SYSTEM','IS_MONITORING')
            when 'T' then
              EXTRACT(DAY FROM (sysdate - p_ovc_registry.get_value_dat('SYSTEM','START_TIME') ) DAY TO SECOND )
              || ' days '
              || EXTRACT(HOUR FROM (sysdate - p_ovc_registry.get_value_dat('SYSTEM','START_TIME')) DAY TO SECOND )
              || ' hours ' 
              || EXTRACT(MINUTE FROM (sysdate - p_ovc_registry.get_value_dat('SYSTEM','START_TIME')) DAY TO SECOND )
              || ' minute ' 
              || EXTRACT(SECOND FROM (sysdate - p_ovc_registry.get_value_dat('SYSTEM','START_TIME')) DAY TO SECOND )
              || ' seconds' 
            else ''
         end value  
       from dual
       union all
       select 
         'ERROR_COUNT' param,
         to_char(count(*)) value  
       from 
         ovc_error_log 
       union all 
       select  
         'ICON' param,
         case p_ovc_registry.get_value('SYSTEM','IS_MONITORING')
           when 'T' then 'icon_traffic_green'
           else 'icon_traffic_red'
         end value  
       from dual
       union all 
       select  
         'DATABASE' param,
          v.NAME value  
       from v$database v       
      );
  m_result varchar2(4000);    
begin
  -- Status: {STATUS}
  -- Start time: {START_TIME}
  -- Stop time: {STOP_TIME}
  -- Up time: {UP_TIME}
  -- Errors: {ERROR_COUNT}
  -- Database {DATABASE}
  open c_get_status;
  fetch c_get_status into m_result;
  close c_get_status;
  
  htp.prn(m_result);
end;
end P_OVC_HTTP;
/

