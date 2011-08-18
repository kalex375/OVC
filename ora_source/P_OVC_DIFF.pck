create or replace package P_OVC_DIFF is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 14.01.09 16:12:23
   Purpose : Сравнение строк, поиск LCS
  
  */
  
  ckNone constant pls_integer := 0;
  ckAdd constant pls_integer := 1;
  ckDelete constant pls_integer := 2;
  ckModify constant pls_integer := 3;
    
  type TCompareRecChr is record ( 
         Kind pls_integer,
         OldIndex1 pls_integer,
         OldIndex2 pls_integer,
         Chr1 varchar2(1),
         Chr2 varchar2(1)
         );

  type TCompareRecInt is record ( 
         Kind pls_integer,
         OldIndex1 pls_integer,
         OldIndex2 pls_integer,
         Int1 pls_integer,
         Int2 pls_integer
         );

  type TDiffStats is record ( 
         Matches   pls_integer,       
         Modifies  pls_integer,
         Adds      pls_integer,
         Deletes   pls_integer
         );         
  
  type TIntArray is table of pls_integer index by pls_integer;
    
  -- Сравнить строки
  procedure Compare(p_str_1 varchar2, 
                    p_str_2 varchar2);
  
  --Сравнить массивы
  procedure Compare(p_ints_1 TIntArray, 
                    p_ints_2 TIntArray);

  --Возвращает после сравнения кол-во изменений
  function Get_Compare_Count return pls_integer;

  --Возвращает статистику после сравнения
  function Stat_Diff return TDiffStats;
  
  --Возвращает элемент из списка сравнения
  function Get_Compare_Chr(p_index pls_integer) return TCompareRecChr;
  
  --Возвращает элемент из списка сравнения
  function Get_Compare_Int(p_index pls_integer) return TCompareRecInt;

  --Очистить списки сравнения
  procedure ClearCompare;

  --Вывод списка в dbms_output после сравнения
  procedure Debug_Show_Compares;

end P_OVC_DIFF;
/
create or replace package body P_OVC_DIFF is

  type TChrArray is table of varchar2(1) index by pls_integer;
  type TDiags is table of pls_integer index by pls_integer;
  type TCompareListChr is table of TCompareRecChr index by pls_integer;
  type TCompareListInt is table of TCompareRecInt index by pls_integer;

  type TDiffVars is record (
         offset1  pls_integer,
         offset2  pls_integer,
         len1     pls_integer,
         len2     pls_integer
         );

  type TDiffList is table of TDiffVars index by pls_integer;

  fCompareListChr TCompareListChr;
  fCompareListInt TCompareListInt;

  fDiffList TDiffList;  
    
  fCompareInts boolean; 

  DiagF TDiags;
  DiagB TDiags;

  Ints1 TIntArray;
  Ints2 TIntArray;

  Chrs1 TChrArray;
  Chrs2 TChrArray;
    
  fDiffStats TDiffStats;
  fLastCompareRecChr TCompareRecChr;
  fLastCompareRecInt TCompareRecInt;
 
  MAXINT constant pls_integer := 2147483647;

--Возвращает статистику после сравнения
function Stat_Diff return TDiffStats
is
begin
  return fDiffStats;
end;

function Get_Compare_Count return pls_integer
is
begin
  if fCompareInts then
    return fCompareListInt.count;
  else
    return fCompareListChr.count;
  end if;  
end;

--Вывод списка после сравнения
procedure Debug_Show_Compares
is
  m_ch varchar2(20);
  m_stat TDiffStats;
  m_compare_chr TCompareRecChr;
  m_compare_int TCompareRecInt;
begin
  dbms_output.put_line('');
  if not fCompareInts then
    dbms_output.put_line('---------------------------------------');
    dbms_output.put_line('|Kind  |OldInd_1 |OldInd_2 |Chr1 |Chr2 |');
    for i in 0..Get_Compare_Count-1 
    loop
     m_compare_chr := fCompareListChr(i);  
     select decode(m_compare_chr.Kind,0,'None',1,'Add',2,'Delete',3,'Modify',' ') into m_ch from dual;
     dbms_output.put_line('|'||rpad(m_ch,6,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_chr.OldIndex1),' '),9,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_chr.OldIndex2),' '),9,' ')||'|'
                             ||rpad(nvl(m_compare_chr.Chr1,' '),5,' ')||'|'
                             ||rpad(nvl(m_compare_chr.Chr2,' '),5,' ')||'|');
    end loop;
    
  else  
    dbms_output.put_line('--------------------------------------------------');
    dbms_output.put_line('|Kind  |OldInd_1 |OldInd_2 |Int1      |Int2      |');
    for i in 0..Get_Compare_Count-1 
    loop
     m_compare_int := fCompareListInt(i);
     select decode(m_compare_int.Kind,0,'None',1,'Add',2,'Delete',3,'Modify',' ') into m_ch from dual;
     dbms_output.put_line('|'||rpad(m_ch,6,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_int.OldIndex1),' '),9,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_int.OldIndex2),' '),9,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_int.Int1),' '),10,' ')||'|'
                             ||rpad(nvl(to_char(m_compare_int.Int2),' '),10,' ')||'|');
    end loop;  
  end if;
  dbms_output.put_line('');
  dbms_output.put_line('Count Diff: '||to_char(Get_Compare_Count));
  dbms_output.put_line('');
  m_stat := fDiffStats;
  dbms_output.put_line('Matches: '||to_char(m_stat.Matches)||' Modifies: '||to_char(m_stat.Modifies)||' Adds: '||to_char(m_stat.Adds)||' Deletes: '||to_char(m_stat.Deletes));  
end;

procedure PushDiff(offset1 pls_integer, 
                   offset2 pls_integer, 
                   len1 pls_integer, 
                   len2 pls_integer)
is
  DiffVars TDiffVars;
begin
  
  DiffVars.offset1 := offset1;
  DiffVars.offset2 := offset2;
  DiffVars.len1 := len1;
  DiffVars.len2 := len2;
  fDiffList(fDiffList.Count):=DiffVars;
end;

function SnakeIntB(k pls_integer,
                   offset1 pls_integer,
                   offset2 pls_integer,
                   len1 pls_integer,
                   len2 pls_integer) return boolean
is
  result boolean;
  x pls_integer;
  y pls_integer;
begin
  if DiagB(k-1) < DiagB(k+1) then
    y := DiagB(k-1);
  else
    y := DiagB(k+1)-1;
  end if;
    
  x := y - k;
  while (x >= 0) and (y >= 0) and (Ints1(offset1+x) = Ints2(offset2+y))
  loop
    x := x - 1; 
    y := y - 1;
  end loop;
  
  DiagB(k) := y;
  
  result := DiagB(k) <= DiagF(k);
  if not result then 
    return result;
  end if;

  x := x + 1; 
  y := y + 1;
  PushDiff(offset1+x, offset2+y, len1-x, len2-y);
  PushDiff(offset1, offset2, x, y);

  return result;
end;

function SnakeIntF(k pls_integer, 
                   offset1 pls_integer,
                   offset2 pls_integer,
                   len1 pls_integer,
                   len2 pls_integer) return boolean
is 
  result boolean;                
  x pls_integer;
  y pls_integer;
begin
  if DiagF(k+1) > DiagF(k-1) then
    y := DiagF(k+1);
  else
    y := DiagF(k-1)+1;
  end if;
    
  x := y - k;
  while (x < len1-1) and (y < len2-1) and
    (Ints1(offset1+x+1) = Ints2(offset2+y+1)) 
  loop
    x := x + 1; 
    y := y + 1;
  end loop;
  
  DiagF(k) := y;
  result := DiagF(k) >= DiagB(k);
  
  if not result then 
    return result;
  end if;

  x := x + 1; 
  y := y + 1;
  
  PushDiff(offset1+x, offset2+y, len1-x, len2-y);
  PushDiff(offset1, offset2, x, y);
  return result;   
end;

function SnakeChrB(k pls_integer,
                   offset1 pls_integer,
                   offset2 pls_integer,
                   len1 pls_integer,
                   len2 pls_integer) return boolean
is 
  result boolean;
  x pls_integer; 
  y pls_integer;
begin
  if DiagB(k-1) < DiagB(k+1) then
    y := DiagB(k-1);
  else
    y := DiagB(k+1)-1;
  end if;
    
  x := y - k;
  while (x >= 0) and (y >= 0) and (Chrs1(offset1+x) = Chrs2(offset2+y)) 
  loop
    x := x - 1; 
    y := y - 1;
  end loop;
  
  DiagB(k) := y;
  result := DiagB(k) <= DiagF(k);
  
  if not result then 
    return result;
  end if;

  x := x + 1; 
  y := y + 1;
  PushDiff(offset1+x, offset2+y, len1-x, len2-y);
  PushDiff(offset1, offset2, x, y);
  return result;
end;

function SnakeChrF(k pls_integer,
                   offset1 pls_integer,
                   offset2 pls_integer,
                   len1 pls_integer,
                   len2 pls_integer) return boolean
is
  result boolean;
  x pls_integer;
  y pls_integer;
  
begin
  if DiagF(k+1) > DiagF(k-1) then
    y := DiagF(k+1);
  else
    y := DiagF(k-1)+1;
  end if;
    
  x := y - k;
  
  while (x < len1-1) and (y < len2-1) and
    (Chrs1(offset1+x+1) = Chrs2(offset2+y+1)) 
  loop
  
    x := x + 1; 
    y := y + 1;
  end loop;
  
  DiagF(k) := y;
  result := (DiagF(k) >= DiagB(k));
  
  if not result then 
    return result;
  end if;

  x := x + 1; 
  y := y + 1;
  PushDiff(offset1+x, offset2+y, len1-x, len2-y);
  PushDiff(offset1, offset2, x, y);
  return result;
end;
    
procedure InitDiagArrays(len1 pls_integer, 
                         len2 pls_integer)
is 
  i  pls_integer;
begin
  
  for i in - (len1+1) .. (len2+1) 
  loop 
    DiagF(i) := -MAXINT;
  end loop;
    
  DiagF(1) := -1;

  for i in - (len1+1) .. (len2+1) 
  loop 
    DiagB(i) := MAXINT;
  end loop;
  
  DiagB(len2-len1+1) := len2;
end;

procedure AddChangeInt(offset1 pls_integer, 
                       range  pls_integer,
                       ChangeKind pls_integer)
is
  i pls_integer;
  j pls_integer;
  compareRec TCompareRecInt;
begin
  
  while (fLastCompareRecInt.oldIndex1 < offset1 -1) 
  loop
    fLastCompareRecInt.Kind := ckNone;
    fLastCompareRecInt.oldIndex1 := fLastCompareRecInt.oldIndex1 + 1;
    fLastCompareRecInt.oldIndex2 := fLastCompareRecInt.oldIndex2 + 1;
    fLastCompareRecInt.int1 := Ints1(fLastCompareRecInt.oldIndex1);
    fLastCompareRecInt.int2 := Ints2(fLastCompareRecInt.oldIndex2);


    compareRec := fLastCompareRecInt;
    fCompareListInt(fCompareListInt.Count) := compareRec;
    fDiffStats.matches := fDiffStats.matches + 1;
  end loop;

  case ChangeKind 
    when ckNone then
      for i in 1..range
      loop
        fLastCompareRecInt.Kind := ckNone;
        fLastCompareRecInt.oldIndex1 := fLastCompareRecInt.OldIndex1 + 1;
        fLastCompareRecInt.oldIndex2 := fLastCompareRecInt.OldIndex2 + 1;
        fLastCompareRecInt.int1 := Ints1(fLastCompareRecInt.oldIndex1);
        fLastCompareRecInt.int2 := Ints2(fLastCompareRecInt.oldIndex2);
        compareRec := fLastCompareRecInt;
        fCompareListInt(fCompareListInt.Count) := compareRec;
        fDiffStats.matches := fDiffStats.matches + 1;
      end loop;
    when ckAdd then 
        for i in 1 .. range 
        loop
          
          if fLastCompareRecInt.Kind = ckDelete then
            
            j := fCompareListInt.Count - 1;
            while (j > 0) and (fCompareListInt(j-1).Kind = ckDelete) 
            loop
              j:= j -1;
            end loop;
                
            fCompareListInt(j).Kind := ckModify;
            fDiffStats.deletes := fDiffStats.deletes - 1;
            fDiffStats.modifies := fDiffStats.modifies + 1;
            fLastCompareRecInt.oldIndex2 := fLastCompareRecInt.oldIndex2 + 1;
            fCompareListInt(j).oldIndex2 := fLastCompareRecInt.oldIndex2;
            fCompareListInt(j).int2 := Ints2(fLastCompareRecInt.oldIndex2);
            if j = fCompareListInt.Count-1 then 
              fLastCompareRecInt.Kind := ckModify;
            end if;
 
          else

            fLastCompareRecInt.Kind := ckAdd;
            fLastCompareRecInt.int1 := null;
            fLastCompareRecInt.oldIndex2 := fLastCompareRecInt.oldIndex2 + 1;
            fLastCompareRecInt.int2 := Ints2(fLastCompareRecInt.oldIndex2); --ie what we added
          
            compareRec := fLastCompareRecInt;
            fCompareListInt(fCompareListInt.Count) := compareRec;
            fDiffStats.adds := fDiffStats.adds + 1;
          end if;
        end loop;

    when ckDelete then 
      
        for i in 1 .. range 
        loop
          
          if fLastCompareRecInt.Kind = ckAdd then
            
            j := fCompareListInt.Count -1;
            while (j > 0) and (fCompareListInt(j-1).Kind = ckAdd)
            loop
              j := j - 1;
            end loop;  
            fCompareListInt(j).Kind := ckModify;
            fDiffStats.adds := fDiffStats.adds - 1;
            fDiffStats.modifies := fDiffStats.modifies + 1;
            fLastCompareRecInt.oldIndex1 := fLastCompareRecInt.oldIndex1 + 1;
            fCompareListInt(j).oldIndex1 := fLastCompareRecInt.oldIndex1;
            fCompareListInt(j).int1 := Ints1(fLastCompareRecInt.oldIndex1);
            if j = fCompareListInt.Count-1 then 
              fLastCompareRecInt.Kind := ckModify; 
            end if;
              
          else 

            fLastCompareRecInt.Kind := ckDelete;
            fLastCompareRecInt.int2 := null;
            fLastCompareRecInt.oldIndex1 := fLastCompareRecInt.oldIndex1 + 1;
            fLastCompareRecInt.int1 := Ints1(fLastCompareRecInt.oldIndex1); --ie what we deleted

            compareRec := fLastCompareRecInt;
            fCompareListInt(fCompareListInt.Count) := compareRec;
            fDiffStats.deletes := fDiffStats.deletes + 1;
          end if;
        end loop;
  end case;
end;

procedure AddChangeChr(offset1 pls_integer,
                       range pls_integer,
                       ChangeKind pls_integer)
is 
  i pls_integer;
  j pls_integer;
  compareRec TCompareRecChr;
begin
  
  while (fLastCompareRecChr.oldIndex1 < offset1 -1) 
  loop
    fLastCompareRecChr.Kind := ckNone;
    fLastCompareRecChr.oldIndex1 := fLastCompareRecChr.oldIndex1 + 1;
    fLastCompareRecChr.oldIndex2 := fLastCompareRecChr.oldIndex2 + 1;
    fLastCompareRecChr.chr1 := Chrs1(fLastCompareRecChr.oldIndex1);
    fLastCompareRecChr.chr2 := Chrs2(fLastCompareRecChr.oldIndex2);
    
    compareRec := fLastCompareRecChr;
    
    fCompareListChr(fCompareListChr.Count):= compareRec;
    fDiffStats.matches := fDiffStats.matches + 1;
  end loop;

  case ChangeKind 
    when ckNone then 
      for i in 1..range
      loop
        fLastCompareRecChr.Kind := ckNone;
        fLastCompareRecChr.oldIndex1 := fLastCompareRecChr.OldIndex1 + 1;
        fLastCompareRecChr.oldIndex2 := fLastCompareRecChr.OldIndex2 + 1;
        fLastCompareRecChr.chr1 := Chrs1(fLastCompareRecChr.oldIndex1);
        fLastCompareRecChr.chr2 := Chrs2(fLastCompareRecChr.oldIndex2);
  
        compareRec := fLastCompareRecChr;
  
        fCompareListChr(fCompareListChr.Count) := compareRec;
        fDiffStats.matches := fDiffStats.matches + 1;
      end loop;
    when ckAdd then
        for i in 1..range
        loop
          
          if fLastCompareRecChr.Kind = ckDelete then
            
            j := fCompareListChr.Count -1;
            while (j > 0) and (fCompareListChr(j-1).Kind = ckDelete) 
            loop  
              j := j - 1;
            end loop;
                  
            fCompareListChr(j).Kind := ckModify;
            fDiffStats.deletes := fDiffStats.deletes - 1;
            fDiffStats.modifies := fDiffStats.modifies + 1;
            fLastCompareRecChr.oldIndex2 := fLastCompareRecChr.oldIndex2 + 1;
            fCompareListChr(j).oldIndex2 := fLastCompareRecChr.oldIndex2;
            fCompareListChr(j).chr2 := Chrs2(fLastCompareRecChr.oldIndex2);
            if j = fCompareListChr.Count-1 then fLastCompareRecChr.Kind := ckModify; end if;
          else
            fLastCompareRecChr.Kind := ckAdd;
            fLastCompareRecChr.chr1 := null;
            fLastCompareRecChr.oldIndex2 := fLastCompareRecChr.oldIndex2 + 1;
            fLastCompareRecChr.chr2 := Chrs2(fLastCompareRecChr.oldIndex2); --ie what we added
          
          
            compareRec := fLastCompareRecChr;
            fCompareListChr(fCompareListChr.Count):= compareRec;
            fDiffStats.adds := fDiffStats.adds + 1;
          end if;
        end loop;

    when ckDelete then 

        for i in 1..range
        loop
            
            if fLastCompareRecChr.Kind = ckAdd then
              j := fCompareListChr.Count -1;
              while (j > 0) and (fCompareListChr(j-1).Kind = ckAdd) 
              loop  
                j := j - 1;
              end loop;  
              fCompareListChr(j).Kind := ckModify;
              fDiffStats.adds := fDiffStats.adds - 1;
              fDiffStats.modifies := fDiffStats.modifies + 1;
              fLastCompareRecChr.oldIndex1 := fLastCompareRecChr.oldIndex1 + 1;
              fCompareListChr(j).oldIndex1 := fLastCompareRecChr.oldIndex1;
              fCompareListChr(j).chr1 := Chrs1(fLastCompareRecChr.oldIndex1);
              if j = fCompareListChr.Count-1 then fLastCompareRecChr.Kind := ckModify; end if;
            else
              fLastCompareRecChr.Kind := ckDelete;
              fLastCompareRecChr.chr2 := null;
              fLastCompareRecChr.oldIndex1 := fLastCompareRecChr.oldIndex1 + 1;
              fLastCompareRecChr.chr1 := Chrs1(fLastCompareRecChr.oldIndex1); --ie what we deleted
           
              compareRec := fLastCompareRecChr;
              fCompareListChr(fCompareListChr.Count) := compareRec;
              fDiffStats.deletes := fDiffStats.deletes + 1;
            end if;
        end loop;
    
  end case;
end;

procedure DiffInt(p_offset1 pls_integer, 
                  p_offset2 pls_integer,
                  p_len1 pls_integer,
                  p_len2 pls_integer)
is
  p pls_integer;
  k pls_integer;
  delta pls_integer;
  
  offset1 pls_integer; 
  offset2 pls_integer;
  len1 pls_integer;
  len2 pls_integer;
begin
  offset1 := p_offset1; 
  offset2 := p_offset2; 
  len1 := p_len1; 
  len2 := p_len2;
  
  while (len1 > 0) and (len2 > 0) and (Ints1(offset1) = Ints2(offset2)) 
  loop
    offset1 := offset1 + 1; 
    offset2 := offset2 + 1; 
    len1 := len1 - 1; 
    len2 := len2 - 1;
  end loop;

  while (len1 > 0) and (len2 > 0) and (Ints1(offset1+len1-1) = Ints2(offset2+len2-1))
  loop
    len1 := len1 - 1; 
    len2 := len2 - 1;
  end loop;

  if (len1 = 0) then
    AddChangeInt(offset1 ,len2, ckAdd);
    return;

  elsif (len2 = 0) then
    AddChangeInt(offset1 ,len1, ckDelete);
    return;

  elsif (len1 = 1) and (len2 = 1) then

    AddChangeInt(offset1, 1, ckDelete);
    AddChangeInt(offset1, 1, ckAdd);
    return;
  end if;

  p := -1;
  delta := len2 - len1;
  InitDiagArrays(len1, len2);
  if delta < 0 then

    while true
    loop
      p := p + 1;

      for k in reverse delta +1..p
      loop
        if SnakeIntF(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;  
      
      for k in -p + delta .. delta-1 
      loop
        if SnakeIntF(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;
        
      for k in delta -p .. -1
      loop
        if SnakeIntB(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;  
      
      for k in reverse 1..p
      loop
        if SnakeIntB(k,offset1,offset2,len1,len2) then 
          return;
        end if;
      end loop;  
      
      if SnakeIntF(delta,offset1,offset2,len1,len2) then 
        return; 
      end if;
      if SnakeIntB(0,offset1,offset2,len1,len2) then 
        return; 
      end if;
    end loop;
  else
  
    while true
    loop
      p := p + 1;

      for k in -p .. delta -1 
      loop
        if SnakeIntF(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;
        
      for k in reverse delta +1..p + delta
      loop
        if SnakeIntF(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;
        
      for k in reverse 1..delta + p
      loop
        if SnakeIntB(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;
        
      for k in -p .. -1 
      loop
        if SnakeIntB(k,offset1,offset2,len1,len2) then 
          return;
        end if;
      end loop;  
      
      if SnakeIntF(delta,offset1,offset2,len1,len2) then 
        return; 
      end if;
      
      if SnakeIntB(0,offset1,offset2,len1,len2) then 
        return; 
      end if;
    end loop;
  end if;
end;

procedure DiffChr(p_offset1 pls_integer, 
                  p_offset2 pls_integer, 
                  p_len1 pls_integer, 
                  p_len2 pls_integer)
is
  p pls_integer; 
  k pls_integer;
  delta pls_integer;
 
  offset1 pls_integer; 
  offset2 pls_integer;
  len1 pls_integer; 
  len2 pls_integer;
  
begin
  offset1 := p_offset1; 
  offset2 := p_offset2; 
  len1 := p_len1; 
  len2 := p_len2;
  
  while (len1 > 0) and (len2 > 0) and (Chrs1(offset1) = Chrs2(offset2)) 
  loop
    offset1 := offset1 + 1; 
    offset2 := offset2 + 1; 
    len1 := len1 -1; 
    len2 := len2 -1;
  end loop;

  while (len1 > 0) and (len2 > 0) and (Chrs1(offset1+len1-1) = Chrs2(offset2+len2-1))
  loop
    len1 := len1 -1; 
    len2 := len2 -1;
  end loop;

  if (len1 = 0) then
    AddChangeChr(offset1 ,len2, ckAdd);
    return;

  elsif (len2 = 0) then
    AddChangeChr(offset1, len1, ckDelete);
    return;
  elsif (len1 = 1) and (len2 = 1) then
    AddChangeChr(offset1, 1, ckDelete);
    AddChangeChr(offset1, 1, ckAdd);
    return;
  end if;

  p := -1;
  delta := len2 - len1;
  InitDiagArrays(len1, len2);
  if delta < 0 then
    while true
    loop  
      p := p + 1;

      for k in reverse delta+1..p
      loop  
        if SnakeChrF(k,offset1,offset2,len1,len2) then 
          return;
        end if;  
      end loop;
        
      for k in -p + delta..delta-1
      loop  
        if SnakeChrF(k,offset1,offset2,len1,len2) then 
          return; 
        end if;
      end loop;
        
      for k in delta -p..-1
      loop  
        if SnakeChrB(k,offset1,offset2,len1,len2) then 
          return;
        end if;  
      end loop;
        
      for k in reverse 1..p
      loop  
        if SnakeChrB(k,offset1,offset2,len1,len2) then 
          return;
        end if;  
      end loop;  
      
      if SnakeChrF(delta,offset1,offset2,len1,len2) then 
        return;
      end if;
        
      if SnakeChrB(0,offset1,offset2,len1,len2) then 
        return;
      end if;  
    end loop;
  else
 
   while true 
   loop
     p := p + 1;

     for k in -p..delta -1
     loop
       if SnakeChrF(k,offset1,offset2,len1,len2) then 
         return;
       end if;  
     end loop;
        
     for k in reverse delta +1 .. p + delta
     loop  
       if SnakeChrF(k,offset1,offset2,len1,len2) then 
         return;
       end if;
     end loop;
        
     for k in reverse 1 .. delta + p
     loop  
       if SnakeChrB(k,offset1,offset2,len1,len2) then 
         return;
       end if;
     end loop;
      
     for k in -p..-1
     loop  
       if SnakeChrB(k,offset1,offset2,len1,len2) then 
         return;
       end if;
     end loop;
      
     if SnakeChrF(delta,offset1,offset2,len1,len2) then 
       return;
     end if;
        
     if SnakeChrB(0,offset1,offset2,len1,len2) then 
       return;
     end if;
   end loop;
    
  end if;
end;


function  PopDiff return boolean
is
  result boolean;
  DiffVars TDiffVars;
  idx pls_integer;
begin
  
  idx := fDiffList.Count - 1;
  result := idx >= 0;
  
  if not result then 
    return result;
  end if;
    
  DiffVars := fDiffList(idx);
  
  if fCompareInts then
    DiffInt(DiffVars.offset1, DiffVars.offset2, DiffVars.len1, DiffVars.len2);
  else
    DiffChr(DiffVars.offset1, DiffVars.offset2, DiffVars.len1, DiffVars.len2);
  end if;
    
  for i in idx..fDiffList.Count - 2 
  loop
    fDiffList(i):=fDiffList(i+1);
  end loop;
  fDiffList.Delete(fDiffList.Count - 1);
    
  return result;
  
end;

procedure Clear
is
begin
  Ints1.Delete; 
  Ints2.Delete;
  
  Chrs1.Delete; 
  Chrs2.Delete;
  
  DiagF.Delete;
  DiagB.Delete;
  
  fDiffList.Delete;
end;

procedure ClearCompare
is
begin
 
  fDiffStats.matches := 0;
  fDiffStats.adds := 0;
  fDiffStats.deletes :=0;
  fDiffStats.modifies :=0;
    
  fCompareListChr.Delete;
  fCompareListInt.Delete;
  
  fLastCompareRecChr.Kind := ckNone;
  fLastCompareRecChr.oldIndex1 := 0;
  fLastCompareRecChr.oldIndex2 := 0;
  
  fLastCompareRecInt.Kind := ckNone;
  fLastCompareRecInt.oldIndex1 := 0;
  fLastCompareRecInt.oldIndex2 := 0;
end;

procedure Compare(p_str_1 varchar2, 
                  p_str_2 varchar2)
is
  Len1Minus1 pls_integer;
  len1 pls_integer; 
  len2 pls_integer;
begin
  fCompareInts := false;
  
  Clear;
  ClearCompare;

  len1 := nvl(length(p_str_1),0); 
  len2 := nvl(length(p_str_2),0);

  Len1Minus1 := len1 - 1;

  for i in 1..len1
  loop
    Chrs1(i) := substr(p_str_1,i,1);
  end loop;
    
  for i in 1..len2
  loop
    Chrs2(i) := substr(p_str_2,i,1);
  end loop;
   
  PushDiff(1, 1, len1, len2);
    
  while PopDiff 
  loop
    null;
  end loop;    

  for i in 0..Get_Compare_Count-1 
  loop  
    if (fCompareListChr(i).Kind = ckModify) and (fCompareListChr(i).chr1 = fCompareListChr(i).chr2) then
      fCompareListChr(i).Kind := ckNone;
      fDiffStats.modifies:= fDiffStats.modifies - 1;
      fDiffStats.matches := fDiffStats.matches + 1;
    end if;
 
    if fCompareListChr(i).Kind = ckAdd then
      fCompareListChr(i).OldIndex1 := null;
    end if;  
       
    if fCompareListChr(i).Kind = ckDelete then
      fCompareListChr(i).OldIndex2 := null;
    end if;  

  end loop;    

  AddChangeChr(fLastCompareRecChr.oldIndex1,len1Minus1-fLastCompareRecChr.oldIndex1, ckNone);

  Clear;
end;

procedure Compare(p_ints_1 TIntArray, 
                  p_ints_2 TIntArray)
is
  Len1Minus1  pls_integer;
  len1 pls_integer;
  len2 pls_integer;
begin
  
  fCompareInts := True;
    
  Clear;
  ClearCompare;

  len1 := p_ints_1.Count;
  len2 := p_ints_2.Count;
    
  Len1Minus1 := len1 -1;
  
  Ints1 := p_ints_1;
  Ints2 := p_ints_2;
    
  PushDiff(1, 1, len1, len2);

  while PopDiff 
  loop
    null;
  end loop;

  for i in 0..Get_Compare_Count-1 
  loop
    if (fCompareListInt(i).Kind = ckModify) and (fCompareListInt(i).int1 = fCompareListInt(i).int2) then
      fCompareListInt(i).Kind := ckNone;
      fDiffStats.modifies := fDiffStats.modifies - 1;
      fDiffStats.matches := fDiffStats.matches + 1;
    end if; 
      
    if fCompareListInt(i).Kind = ckAdd then
      fCompareListInt(i).OldIndex1 := null;
    end if;  
       
    if fCompareListInt(i).Kind = ckDelete then
      fCompareListInt(i).OldIndex2 := null;
    end if;  
      
  end loop; 
  
  AddChangeInt(fLastCompareRecInt.oldIndex1,len1Minus1-fLastCompareRecInt.oldIndex1, ckNone);
  
  Clear;
end;

--Возвращает элемент из списка сравнения
function Get_Compare_Chr(p_index pls_integer) return TCompareRecChr
is
begin
  return fCompareListChr(p_index);
end;

--Возвращает элемент из списка сравнения
function Get_Compare_Int(p_index pls_integer) return TCompareRecInt
is
begin
  return fCompareListInt(p_index);
end;

end P_OVC_DIFF;
/
