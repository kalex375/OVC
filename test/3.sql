select
  sum(DBMS_UTILITY.get_hash_value(s.line,
                                  1,
                                  65536)
      + 2*DBMS_UTILITY.get_hash_value(s.text,
                                      1,
                                      65536))from
  all_source s
where
  s.owner='ORA_VER' and
  s.type ='PACKAGE' and
  s.name ='OVC_MAIN' and
  1=1 
union all
select
  sum(DBMS_UTILITY.get_hash_value(t.line, 1, 65536)
      + 2*DBMS_UTILITY.get_hash_value(t.text, 1, 65536))
from
  ovc_backup_source t
where   
--  t.owner='SR_BANK' and
--  t.type ='PACKAGE' and
--  t.name ='FC_GB_LOSS_KORR' and
  t.change_id=103 and
  1=1
  
