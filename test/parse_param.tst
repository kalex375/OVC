PL/SQL Developer Test script 3.0
45
--                                                                                                   1    
--         1         2         3         4         5         6         7         8         9         0
--1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890 
--                       1                                               2                         3        
--   1                                          2  3                                         4 5       6
--<#>param_name1<@>param_type1<@>param_value1<#><#>param_name2<@>param_type2<@>param_value2<#>
select
  rn,
  param_str,
  param_name,
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
  end param_value_dat  
    
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
          substr(:p_params,instr (:p_params,'<#>',1,level*2-1)+3,instr (:p_params,'<#>',1,level*2)-instr (:p_params,'<#>',1,level*2-1)-3) param_str
        from 
          dual
        connect by level<=p_ovc_str_utils.SymbolCount(:p_params,'<#>')/2
      ) p_str
  ) p          
1
p_params
1
<#>param_name1<@>INT<@>2342<#><#>param_name2<@>NUM<@>2342.33<#><#>p_3<@>DAT<@>20.02.2010<#>
5
0
