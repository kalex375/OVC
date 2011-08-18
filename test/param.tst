PL/SQL Developer Test script 3.0
114
select
  arg.rn,
  arg.argument_name param_name,
  arg.defaulted defaulted,
  arg.in_out direct,
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
      


from 
 (
  select
    case when aa.ARGUMENT_NAME is null and aa.POSITION=0 then 'M_RESULT'
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
   ((aa.PACKAGE_NAME = :m_part1) or  (:m_part1 is null and aa.PACKAGE_NAME is null)) and
   aa.OBJECT_NAME = :m_part2 and
   aa.OWNER = :m_schema and
   aa.DATA_LEVEL = 0
   
                       --and aa.POSITION>0
                      ) arg,
                     --order by aa.POSITION
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
            substr(:p_params,instr (:p_params,'<#>',1,level*2-1)+3,instr (:p_params,'<#>',1,level*2)-instr (:p_params,'<#>',1,level*2-1)-3) param_str
          from 
            dual
          connect by level<=p_ovc_str_utils.SymbolCount(:p_params,'<#>')/2
        ) p_str
    ) p
 ) par
where
  arg.ARGUMENT_NAME = par.param_name(+)
order by arg.rn
        
4
p_params
1
<#>P_oBJ_tYPE<@>STR<@>SYSTEM<#><#>P_OBJ_OWNER<@>STR<@>SYSTEM<#><#>P_OBJ_NAME<@>STR<@>SYSTEM<#><#>P_IS_FULL<@>STR<@>SYSTEM<#><#>P_LOCK_USER<@>STR<@>SYSTEM<#><#>P_LOCK_TERMINAL<@>STR<@>SYSTEM<#><#>P_LOCK_OS_USER<@>STR<@>SYSTEM<#><#>P_CHECK_EXISTS<@>BOL<@>FALSE<#>
5
m_part1
1
P_OVC_LOCK
5
m_part2
1
CHECK_LOCK
5
m_schema
1
ORA_VER
5
0
