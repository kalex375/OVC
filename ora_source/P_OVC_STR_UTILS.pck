create or replace package P_OVC_STR_UTILS is

  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 23.07.08 14:47:09
   Purpose : Функции и процедуры для работы со стоками
  
  */

  CR     constant varchar2 (1) := chr (13);
  LF     constant varchar2 (1) := chr (10);
  CRLF   constant varchar2 (2) := chr (13) || chr (10);
  
  G_STANDART_WORD_DELIMS constant varchar2 (4) := ' ' || chr (13) || chr (10) || chr (9);
  
  
  -- возвращает кол-во всех слов в тексте 
  -- WordDelims символы разделяющие слова
  function WordCount(S varchar2,
                     WordDelims varchar2 default G_STANDART_WORD_DELIMS) return pls_integer;

  -- возвращает кол-во указаных слов в тексте
  -- Word слово которое ищем
  -- WordDelims символы разделяющие слова
  function WordInText(S varchar2,
                      Word varchar2,
                      WordDelims varchar2 default G_STANDART_WORD_DELIMS) return pls_integer;
                     
  -- Возвращает номер позиции первого символа слова в тексте
  -- N порядковы номер слова
  -- WordDelims символы разделяющие слова
  function WordPosition(S in varchar2,
                        N in pls_integer,
                        WordDelims in varchar2 default G_STANDART_WORD_DELIMS) return  pls_integer;


  -- возвращает первую позицию символа из набора в тексте
  -- Symbols искомые символы * Symbols := '*/+-'
  function SymbolsPosition(S varchar2,
                           Symbols varchar2) return pls_integer;

  -- возвращает кол-во указаного символа в тексте 
  -- Symbol искомый символ
  function SymbolCount(S varchar2,
                       Symbol char) return pls_integer;                         
                       
  -- Возвращает из текста слово отделеное пробелами и/или другими символами по порядковому номеру
  -- N порядковы номер символа
  -- WordDelims символы разделяющие слова
  function ExtractWord(S in varchar2,
                       N in pls_integer,
                       WordDelims in varchar2 default G_STANDART_WORD_DELIMS) return  varchar2;                        

  -- Возвращает из текста слово отделеное пробелами и/или другими символами по порядковому 
  -- номеру с позицией в тексте
  -- N порядковы номер символа
  -- WordDelims символы разделяющие слова
  -- Pos позиция первого символа слова в тексте
  function ExtractWordPos(S in varchar2,
                          N in pls_integer,
                          WordDelims in varchar2 default G_STANDART_WORD_DELIMS,
                          Pos out pls_integer) return varchar2;
                             
  -- ищет в строке подстраку начинающиюся на p_begin_str и 
  -- заканчивающися на p_end_str и заменяет 
  -- ее на p_replece_str, 
  -- p_set_crlf - оставлять переходы коретки или нет
  function Replace_By_Pair_Str(p_text in varchar2,
                               p_begin_str in varchar2,
                               p_end_str in varchar2,
                               p_replece_str in varchar2 default G_STANDART_WORD_DELIMS,
                               p_set_crlf in boolean default true) return varchar2;

  -- Форматирование строки
  -- символа %S заменяются на параметры
  function format_string (
        p_format in varchar2,
        p_param1 in varchar2 := '',
        p_param2 in varchar2 := '',
        p_param3 in varchar2 := '',
        p_param4 in varchar2 := '',
        p_param5 in varchar2 := '',
        p_param6 in varchar2 := '',
        p_param7 in varchar2 := '',
        p_param8 in varchar2 := '',
        p_param9 in varchar2 := '',
        p_param10 in varchar2 := '',
        p_param11 in varchar2 := '',
        p_param12 in varchar2 := '',
        p_param13 in varchar2 := '',
        p_param14 in varchar2 := '',
        p_param15 in varchar2 := '',
        p_param16 in varchar2 := '',
        p_param17 in varchar2 := '',
        p_param18 in varchar2 := '',
        p_param19 in varchar2 := '',
        p_param20 in varchar2 := ''
        )
        return varchar2;
  
  function clob_replace(p_clob in clob, 
                        p_search_string in varchar2,      
                        p_replacement in clob) return clob;
  
end P_OVC_STR_UTILS;
/
create or replace package body P_OVC_STR_UTILS is

--возвращает кол-во всех слов в тексте
function WordCount(S varchar2,
                   WordDelims varchar2 default G_STANDART_WORD_DELIMS) return pls_integer                 
is
  m_result pls_integer;
  SLen pls_integer;
  I pls_integer;
begin
  m_result := 0;
  I := 1;
  SLen := Length(S);
  while I <= SLen 
  loop
    
    while (I <= SLen) and (instr(WordDelims,substr(S,I,1))<>0) 
    loop
      I := I + 1;
    end loop; 
    
    if I <= SLen then 
     m_result := m_result + 1;
    end if;
    
    while (I <= SLen) and  (instr(WordDelims,substr(S,I,1))=0) 
    loop
      I := I + 1;
    end loop;  
    
  end loop;
  return m_result;
end;

--возвращает кол-во указаных слов в тексте
function WordInText(S varchar2,
                    Word varchar2,
                    WordDelims varchar2 default G_STANDART_WORD_DELIMS) return pls_integer  
is
  m_count pls_integer;
  m_offset pls_integer;
  m_pos pls_integer;
  m_s  varchar2(4000);
begin
  m_count := 0;
  m_offset := 1;
  m_s := substr(WordDelims,1,1)||S||substr(WordDelims,1,1);
  while instr(m_s,word,1,m_offset)<>0 
  loop
    m_pos := instr(m_s,word,1,m_offset);
    if instr(WordDelims,substr(m_s,m_pos-1,1))<>0 and instr(WordDelims,substr(m_s,m_pos+length(Word),1))<>0 then
     m_count := m_count + 1;
    end if;
    m_offset := m_offset + 1;
  end loop;
  return m_count;
end;

--возвращает первую позицию символа из набора в тексте
function SymbolsPosition(S varchar2,
                         Symbols varchar2) return pls_integer
is
  i pls_integer;
  m_result pls_integer;
begin
  i:=1;
  m_result:=0;
  
  while i<=Length(S)
  loop
    if instr(Symbols,substr(s,i,1))<>0 then
      m_result := i;
      exit when true;
    end if;
    i := i + 1; 
  end loop;
  return m_result;
end;
                         
--возвращает кол-во указаных символов в тексте 
function SymbolCount(S varchar2,
                     Symbol char) return pls_integer  
is
  m_offset pls_integer;
begin
  m_offset := 1;
  while instr(S,Symbol,1,m_offset)<>0 
  loop
     m_offset := m_offset + 1;
  end loop;
  return m_offset-1;
end;

--Возвращает порядковый номер слова в тексте отделеное пробелами и/или другими символами
function WordPosition(S in varchar2,
                      N in pls_integer,
                      WordDelims in varchar2 default G_STANDART_WORD_DELIMS) return  pls_integer
is
  m_count pls_integer;
  I pls_integer;
  m_result pls_integer;
begin
  m_count := 0;
  I := 1;
  m_result := 0;
  while (I <= Length(S)) and (m_count <> N) 
  loop
    -- skip over delimiters 
    while (I <= Length(S)) and (instr(WordDelims,substr(S,I,1))<>0)
    loop
      I := I + 1;
    end loop;
    -- if we're not beyond end of S, we're at the start of a word 
    if I <= Length(S) then 
      m_count := m_count + 1;
    end if; 
    -- if not finished, find the end of the current word 
    if m_count <> N then
      while (I <= Length(S)) and (instr(WordDelims,substr(S,I,1))=0)
      loop
        I := I+1;
      end loop;  
    else 
      m_result := I;
    end if;
  end loop;
  return m_result;
end;

--Возвращает из текста слово отделеное пробелами и/или другими символами по порядковому номеру
function ExtractWord(S in varchar2,
                     N in pls_integer,
                     WordDelims in varchar2 default G_STANDART_WORD_DELIMS) return  varchar2
is                     
  I pls_integer;
  m_result varchar2(2000);
begin
  m_result := null;
  I := WordPosition(S, N, WordDelims);
  if I <> 0 then
    -- find the end of the current word 
    while (I <= Length(S)) and (instr(WordDelims,substr(S,I,1))=0) 
    loop
      --{ add the I'th character to result }
      if m_result is not null then
        m_result := m_result||substr(S,I,1);
      else 
        m_result := substr(S,I,1);
      end if;
      I := I + 1;      
    end loop;
  end if;  
  return m_result;
end;

--Возвращает из текста слово отделеное пробелами и/или другими символами по порядковому номеру с позицией в тексте
function ExtractWordPos(S in varchar2,
                        N in pls_integer,
                        WordDelims in varchar2 default G_STANDART_WORD_DELIMS,
                        Pos out pls_integer) return varchar2
is
  I pls_integer;
  m_result varchar2(2000);
begin
  I := WordPosition(S, N, WordDelims);
  Pos := I;
  m_result := null;
  if I <> 0 then
    -- find the end of the current word 
    while (I <= Length(S)) and (instr(WordDelims,substr(S,I,1))=0) 
    loop
      -- add the I'th character to result 
      if m_result is not null then
        m_result := m_result||substr(S,I,1);
      else 
        m_result := substr(S,I,1);
      end if;
      I := I + 1;
    end loop;
  end if;
  return m_result;
end;

-- ищет в строке подстраку начинающиюся на p_begin_str и 
-- заканчивающися на p_end_str и заменяет 
-- ее на p_replece_str, p_set_crlf - оставлять переходы коретки или нет
function replace_by_pair_str(p_text in varchar2,
                             p_begin_str in varchar2,
                             p_end_str in varchar2,
                             p_replece_str in varchar2 default G_STANDART_WORD_DELIMS,
                             p_set_crlf in boolean default true) return varchar2
is
  m_text varchar2(4000);
  
  m_begin_pos pls_integer;
  m_end_pos pls_integer;
  m_len pls_integer;
  m_temp varchar2(4000);
  m_repl varchar2(4000);
  m_count pls_integer;
  m_count_in pls_integer; --для учета вложеных строк замещения например max(avg('d.i'))
  m_next_begin_pos pls_integer;
begin
  m_text := p_text;  
  loop
    m_begin_pos := instr(m_text,p_begin_str);
    m_end_pos := instr(m_text,p_end_str,m_begin_pos+1,1);    
    --счетаем до m_end_pos сколько еше начал
    m_count_in := 1; --пока есть одно вхождение
    m_next_begin_pos := m_begin_pos;
    loop
      m_next_begin_pos := instr(m_text,p_begin_str,m_next_begin_pos+1,1);        
      exit when m_next_begin_pos=0;
      if m_next_begin_pos < m_end_pos then
        m_count_in := m_count_in + 1;
      end if;
    end loop;  
    m_end_pos := instr(m_text,p_end_str,m_begin_pos+1,m_count_in);
    
    m_len := (m_end_pos+length(p_end_str))-m_begin_pos;
    exit when m_begin_pos = 0 or m_end_pos = 0;
        
    if p_set_crlf then 
      m_temp :=substr(m_text,m_begin_pos,m_len);
      --считаем кол-во переходов коретки
      m_repl := '';
      m_count := 1;
      while instr(m_temp,LF,m_count,1)<>0
      loop
        if m_repl is null then 
          m_repl := rpad(p_replece_str,instr(m_temp,LF,m_count,1)-1,p_replece_str)||LF;
        else
          m_repl := rpad(m_repl,instr(m_temp,LF,m_count,1)-1,p_replece_str)||LF;
        end if;  
        m_count := instr(m_temp,LF,m_count,1)+1;
      end loop;   
    end if;
    
    if m_repl is null then 
      m_repl :=rpad(p_replece_str,m_len,p_replece_str);
    else
      m_repl :=rpad(m_repl,m_len,p_replece_str); 
    end if;  

    m_text := substr(m_text,1,m_begin_pos-1)||m_repl||substr(m_text,m_begin_pos+m_len,length(m_text)-(m_begin_pos+m_len)+1);

  end loop;  
  return m_text;
end; 

function format_param (
      param in varchar2,
      expr in out varchar2,
      exprcurrpos in out pls_integer
      )
      return boolean
   is
      fmtpos                        pls_integer;
   begin
      fmtpos := instr (expr, '%S', exprcurrpos);
      if fmtpos = 0
      then
         return false;
      else
         expr :=
            substr (expr, 1, fmtpos - 1) || param || substr (expr, fmtpos + 2);
         exprcurrpos := fmtpos + nvl (length (param), 0);
         return true;
      end if;
   end;

   function format_string (
      p_format in varchar2,
      p_param1 in varchar2 := '',
      p_param2 in varchar2 := '',
      p_param3 in varchar2 := '',
      p_param4 in varchar2 := '',
      p_param5 in varchar2 := '',
      p_param6 in varchar2 := '',
      p_param7 in varchar2 := '',
      p_param8 in varchar2 := '',
      p_param9 in varchar2 := '',
      p_param10 in varchar2 := '',
      p_param11 in varchar2 := '',
      p_param12 in varchar2 := '',
      p_param13 in varchar2 := '',
      p_param14 in varchar2 := '',
      p_param15 in varchar2 := '',
      p_param16 in varchar2 := '',
      p_param17 in varchar2 := '',
      p_param18 in varchar2 := '',
      p_param19 in varchar2 := '',
      p_param20 in varchar2 := ''
      )
      return varchar2
   is
      res                           varchar2(4000);
      currpos                       pls_integer;
      inst_tp constant              char(1) := chr (3);
   begin
      -- Replace %% to %
      res := replace (p_format, '%%', inst_tp);
      res := replace (res, '%s', '%S');
      currpos := 1;
      if not format_param (p_param1, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param2, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param3, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param4, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param5, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param6, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param7, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param8, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param9, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param10, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param11, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param12, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param13, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param14, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param15, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param16, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param17, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param18, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param19, res, currpos)
      then
         goto ret;
      end if;
      if not format_param (p_param20, res, currpos)
      then
         goto ret;
      end if;
      <<ret>>
      return translate (res, inst_tp, '%');
   end;

function clob_replace(p_clob in clob, 
                      p_search_string in varchar2,      
                      p_replacement in clob) return clob
is                      
  m_tmp clob;
  m_part_start number;
  m_part_end number;
  src_length number;
  part_length number;
  src_beginning_length number;
  src_remain_length number;
  replacement_length number;
begin
  
  m_part_start := dbms_lob.instr(p_clob,p_search_string);

  if m_part_start>0 and m_part_start is not null then
  
    m_part_end :=  m_part_start + length(p_search_string);
    
    src_length := dbms_lob.getlength(p_clob); -- длина первоначального CLOB-a
    part_length := m_part_end - m_part_start + 1; -- длина заменяемой части в первоначальном CLOB-е
    src_beginning_length := m_part_start - 1; -- длина остатка в первоначальном CLOB-е
    src_remain_length := src_length - m_part_end; -- длина остатка в первоначальном CLOB-е

    replacement_length := dbms_lob.getlength(p_replacement); -- длина заменяющей части

    -- создаем временный CLOB
    dbms_lob.createtemporary(m_tmp, true);

    -- копируем во временный CLOB начальную часть исходных данных до заменяемого участка
    if src_beginning_length > 0 then 
      dbms_lob.copy(m_tmp, p_clob, src_beginning_length, 1, 1);
    end if;
      
    -- копируем во временный CLOB заменяемый участок
    dbms_lob.copy(m_tmp, p_replacement, replacement_length, m_part_start, 1);
    
    -- копируем во временный CLOB остаток исходных данных после заменяемого участка
    if src_remain_length>0 then
      dbms_lob.copy(m_tmp, p_clob, src_remain_length, src_beginning_length + replacement_length + 1, src_beginning_length + part_length );
    end if;  
    
    return m_tmp;
  end if;
  
  return p_clob;    

end;

end P_OVC_STR_UTILS;
/
