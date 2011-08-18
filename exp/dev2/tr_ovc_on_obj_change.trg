CREATE OR REPLACE TRIGGER ORA_VER.TR_OVC_ON_OBJ_CHANGE
  BEFORE DDL
  ON database  
declare 
begin
  if ora_dict_obj_name like 'P_OVC_%' then 
    return ;
  end if;  

  p_ovc_engine.process_event(p_ora_dict_obj_type => ora_dict_obj_type,
                             p_ora_dict_obj_owner => ora_dict_obj_owner,
                             p_ora_dict_obj_name => ora_dict_obj_name,
                             p_ora_login_user => ora_login_user,
                             p_ora_sysevent => ora_sysevent
                            );

end ;
/

