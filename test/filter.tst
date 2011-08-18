PL/SQL Developer Test script 3.0
66
    select
      cf.id,
      cf.project_id,
      cf.is_auto_lock,
      p.name project_name,
      filter.*
    from
      ovc_change_filter cf,
      ovc_filter f,
      ovc_project p,
      (select
         upper(:p_obj_type) obj_type,
         upper(:p_obj_owner) obj_owner,
         upper(:p_obj_name) obj_name,
         upper(:p_modify_user) modify_user,
         upper(:p_modify_terminal) modify_terminal,
         upper(:p_modify_os_user) modify_os_user
       from
         ovc_change_filter cf,
         ovc_filter f
       where
         cf.filter_id = f.id and
         cf.type = :p_type and
         cf.enabled='T' and
         f.ignore= 'F' and
         (upper(:p_obj_type) like f.obj_type or (:p_obj_type is null and f.obj_type='%'))and
         (upper(:p_obj_owner) like f.obj_owner or (:p_obj_owner is null and f.obj_owner='%')) and
         (upper(:p_obj_name) like f.obj_name or (:p_obj_name is null and f.obj_name='%')) and
         (upper(:p_modify_user) like f.modify_user or (:p_modify_user is null and f.modify_user='%')) and
         (upper(:p_modify_terminal) like f.modify_terminal or (:p_modify_terminal is null and f.modify_terminal='%')) and
         (upper(:p_modify_os_user) like f.modify_os_user or (:p_modify_os_user is null and f.modify_os_user='%'))
       minus     
       select
         upper(:p_obj_type) obj_type,
         upper(:p_obj_owner) obj_owner,
         upper(:p_obj_name) obj_name,
         upper(:p_modify_user) modify_user,
         upper(:p_modify_terminal) modify_terminal,
         upper(:p_modify_os_user) modify_os_user
       from
         ovc_change_filter cf,
         ovc_filter f
       where
         cf.filter_id = f.id and
         cf.type = :p_type and
         cf.enabled='T' and
         f.ignore= 'T' and
         (upper(:p_obj_type) like f.obj_type or (:p_obj_type is null and f.obj_type='%'))and
         (upper(:p_obj_owner) like f.obj_owner or (:p_obj_owner is null and f.obj_owner='%')) and
         (upper(:p_obj_name) like f.obj_name or (:p_obj_name is null and f.obj_name='%')) and
         (upper(:p_modify_user) like f.modify_user or (:p_modify_user is null and f.modify_user='%')) and
         (upper(:p_modify_terminal) like f.modify_terminal or (:p_modify_terminal is null and f.modify_terminal='%')) and
         (upper(:p_modify_os_user) like f.modify_os_user or (:p_modify_os_user is null and f.modify_os_user='%'))
       ) filter
    where
      cf.filter_id = f.id and
      cf.project_id = p.id(+) and
      cf.type = :p_type and      
      cf.enabled='T' and
      f.ignore= 'F' and
      (filter.obj_type like f.obj_type or (filter.obj_type is null and f.obj_type='%'))and
      (filter.obj_owner like f.obj_owner or (filter.obj_owner is null and f.obj_owner='%')) and
      (filter.obj_name like f.obj_name or (filter.obj_name is null and f.obj_name='%')) and
      (filter.modify_user like f.modify_user or (filter.modify_user is null and f.modify_user='%')) and
      (filter.modify_terminal like f.modify_terminal or (filter.modify_terminal is null and f.modify_terminal='%')) and
      (filter.modify_os_user like f.modify_os_user or (filter.modify_os_user is null and f.modify_os_user='%'))
7
p_obj_type
0
5
p_obj_owner
0
5
p_obj_name
1
P_GL
5
p_modify_user
0
5
p_modify_terminal
0
5
p_modify_os_user
0
5
p_type
1
PROJECT
5
0
