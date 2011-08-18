 cursor c_get_prev_id(p_change_id ovc_change_object.id%type)
  is
    select
      max(pco.id) keep (dense_rank last order by pco.modify_date) id
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
         co.id=p_change_id) lco
    where
      pco.modify_type = 'CREATE' and
      pco.obj_type = lco.obj_type and
      pco.obj_owner = lco.obj_owner and
      pco.obj_name = lco.obj_name and
      pco.modify_date < lco.modify_date;
