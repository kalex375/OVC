PL/SQL Developer Test script 3.0
93
declare
  -- Non-scalar parameters require additional processing 
  p_ints_1 p_diff.TIntArray;
  p_ints_2 p_diff.TIntArray;
  p_intss_1 p_temp.TListInt;
  p_intss_2 p_temp.TListInt;
  
  m_compare p_temp.TCompareRecInt;
  m_str_1 varchar2(60);
  m_str_2 varchar2(60);
  m_ch varchar2(60);
  m_start_time timestamp;

begin
  
  select
    --t.line,
    DBMS_UTILITY.get_hash_value(t.text, 1, 65536), 
    DBMS_UTILITY.get_hash_value(t.text, 1, 65536)
    bulk collect into p_ints_1, p_intss_1
  from
    ovc_change_text t
  where   
    t.change_object_id=3196 and
    1=1
  order by t.line;

  select
  --  s.line,
    DBMS_UTILITY.get_hash_value(s.text, 1, 65536),
    DBMS_UTILITY.get_hash_value(s.text, 1, 65536)    
  bulk collect into p_ints_2, p_intss_2
  from
    all_source s
  where
    s.owner='ORA_VER' and
    s.type ='PACKAGE BODY' and
    s.name ='P_TEMP'
  order by s.line;
  --p_ints_1.delete(300,p_ints_1.count);
  --p_ints_2.delete(300,p_ints_2.count);
  m_start_time:= systimestamp;

  p_diff.compare(pints1 =>  p_ints_1, 
                 pints2 =>  p_ints_2,
                 len1 => p_ints_1.Count,
                 len2 => p_ints_2.Count);
 
  dbms_output.put_line('');
  dbms_output.put_line('Out Executed in '||regexp_replace(to_char(LOCALTIMESTAMP-m_start_time), '^(\+|(-))[0 :]*(.*?\d\.\d+?)0*$', '\2\3')||' seconds.');

  m_start_time:= systimestamp;
  
--  p_temp.Set_Debug(1);
--  p_temp.compare(p_intss_1,  p_intss_2);
--
--  dbms_output.put_line('');
--  dbms_output.put_line('Out Executed in '||regexp_replace(to_char(LOCALTIMESTAMP-m_start_time), '^(\+|(-))[0 :]*(.*?\d\.\d+?)0*$', '\2\3')||' seconds.');
 
 /* for i in 0..p_temp.Count_Diff-1
  loop
    m_compare := p_temp.Get_Diff_Int(i);
    select rpad(decode(m_compare.Kind,0,'None',1,'Add',2,'Delete',3,'Modify',' '),7,' ') into m_ch from dual;
    if m_compare.oldindex1 is not null then 

      select
        rpad(nvl(substr(t.text,1,50),' '),50,' ') into m_str_1
      from
        ovc_change_text t
      where   
        t.change_object_id=3196 and
        t.line = m_compare.oldindex1;
    
    else
      m_str_1 := rpad(' ',50,' ');
    end if;      

    if m_compare.oldindex2 is not null then 
      select
        rpad(nvl(substr(s.text,1,50),' '),50,' ') into m_str_2 
      from
        all_source s
      where
        s.owner='ORA_VER' and
        s.type ='PACKAGE BODY' and
        s.name ='P_TEMP' and
        s.line = m_compare.oldindex2;
    else
      m_str_2 := rpad(' ',50,' ');
    end if;      
    dbms_output.put_line(replace(rpad(to_char(i),4,' ')||m_ch||'|'||m_str_1||' |'||m_str_2,chr(10),' '));
  end loop;*/
end;
0
2
g_FromInt
g_ToInt
