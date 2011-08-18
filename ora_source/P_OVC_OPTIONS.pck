create or replace package P_OVC_OPTIONS is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 15.04.10 15:51:01
   Purpose : ��������� �������
  
  */

  -- ������ ��� ���������� ��������� � ����� ����.
  g_param_date_fmt constant varchar2(21) := 'DD.MM.YYYY HH24:MI:SS';

  -- ������ ��� ���������� ��������� � ����� ����� 
  g_param_int_fmt constant char(21) := 'FM9999999999999999999';

  -- ������ ��� ���������� ��������� � ����� ����� � ��������� ������.
  g_param_num_fmt constant char(33) := 'FM9999999999999999999D00009999999';

  -- ������ ��� ���������� ��������� � ����� ����� � ��������� ������.
  -- ���������������� ������ (��� �����������).
  g_param_num_nls_fmt constant char(31) := 'nls_numeric_characters = ''. ''';
  
  -- �������� �������� �� ��������� �������
  function get_value(p_path  in ovc_options.path%type,
                     p_param in ovc_options.param%type) return varchar2;                             

  -- �������� �������� �� ���������� ������� (����)
  function get_value_dat(p_path  in ovc_options.path%type,
                         p_param in ovc_options.param%type) return date;

  -- �������� �������� �� ���������� ������� (����� �����)
  function get_value_int(p_path  in ovc_options.path%type,
                         p_param in ovc_options.param%type) return pls_integer;

  -- �������� �������� �� ���������� ������� (����� � ��������� ������)
  function get_value_num(p_path  in ovc_options.path%type,
                         p_param in ovc_options.param%type) return number;


  -- �������� �������� �� ���������� ������� (����������)
  function get_value_bol(p_path  in ovc_options.path%type,
                         p_param in ovc_options.param%type) return boolean;

  -- ���������� �������� ��������� ������� (������)
  procedure set_value(p_path  in ovc_options.path%type,
                      p_param in ovc_options.param%type,
                      p_value in ovc_options.value%type);

  -- ���������� �������� ��������� ������� (����)
  procedure set_value(p_path  in ovc_options.path%type,
                      p_param in ovc_options.param%type,
                      p_value in date);
                      
  -- ���������� �������� ��������� ������� (����� � ��������� ������)
  procedure set_value(p_path  in ovc_options.path%type,
                      p_param in ovc_options.param%type,
                      p_value in number);

  -- ���������� �������� ��������� ������� (����� �����)
  procedure set_value(p_path  in ovc_options.path%type,
                      p_param in ovc_options.param%type,
                      p_value in pls_integer);
                      
  -- ���������� �������� ��������� ������� (����������)
  procedure set_value(p_path  in ovc_options.path%type,
                      p_param in ovc_options.param%type,
                      p_value in boolean);  

end P_OVC_OPTIONS;
/
create or replace package body P_OVC_OPTIONS is

-- �������� �������� �� ��������� �������
function get_value(p_path  in ovc_options.path%type,
                   p_param in ovc_options.param%type)
return varchar2
is
  cursor c_get_value(p_path  in ovc_options.path%type,
                     p_param in ovc_options.param%type)
  is
    select
      o.value,
      count(*) over () val_count
    from
      ovc_options o
    where                   
      o.path = upper(p_path) and
      o.param = upper(p_param);
      
  m_value c_get_value%rowtype;                  
begin
  open c_get_value(p_path, p_param);
  fetch c_get_value into m_value;
  close c_get_value;
  
  if m_value.val_count is null then
    p_ovc_exception.raise_common_exception('�� ������ �������� %S\%S',p_path,p_param);  
  end if;
  
  return m_value.value;
end;                           

-- �������� �������� �� ���������� ������� (����)
function get_value_dat(p_path  in ovc_options.path%type,
                       p_param in ovc_options.param%type)
return date
is
begin
  return to_date(get_value(p_path => p_path,
                           p_param => p_param),
                 g_param_date_fmt);
end;

-- �������� �������� �� ���������� ������� (����� �����)
function get_value_int(p_path  in ovc_options.path%type,
                       p_param in ovc_options.param%type)
return pls_integer
is
begin
  return to_number(get_value(p_path => p_path,
                             p_param => p_param),
                   g_param_int_fmt);
end;


-- �������� �������� �� ���������� ������� (����� � ��������� ������)
function get_value_num(p_path  in ovc_options.path%type,
                       p_param in ovc_options.param%type)
return number
is
begin
  return to_number(get_value(p_path => p_path,
                             p_param => p_param),
                   g_param_num_fmt, 
                   g_param_num_nls_fmt);
end;

--�������� �������� �� ���������� ������� (����������)
function get_value_bol(p_path  in ovc_options.path%type,
                       p_param in ovc_options.param%type)
return boolean
is
begin
  return (get_value(p_path => p_path,
                    p_param => p_param)) = 'T';
end;

-- ���������� �������� ��������� �������
procedure set_value(p_path  in ovc_options.path%type,
                    p_param in ovc_options.param%type,
                    p_value in ovc_options.value%type)
is
begin
  update ovc_options o set
    o.value = p_value
  where
    o.path = upper(p_path) and
    o.param = upper(p_param);
    
  if sql%notfound then
    p_ovc_exception.raise_common_exception('�� ������ �������� %S\%S',p_path,p_param);
  end if;    
  
end;

-- ���������� �������� ��������� ������� (����)
procedure set_value(p_path  in ovc_options.path%type,
                    p_param in ovc_options.param%type,
                    p_value in date)
is
begin
 
  set_value(p_path => p_path,
            p_param => p_param,
            p_value => to_char(p_value,g_param_date_fmt));
end;

-- ���������� �������� ��������� ������� (����� � ��������� ������)
procedure set_value(p_path  in ovc_options.path%type,
                    p_param in ovc_options.param%type,
                    p_value in number)
is
begin
  set_value(p_path => p_path,
            p_param => p_param,
            p_value => to_char(p_value,g_param_num_fmt, g_param_num_nls_fmt));
end;

-- ���������� �������� ��������� ������� (����� �����)
procedure set_value(p_path  in ovc_options.path%type,
                    p_param in ovc_options.param%type,
                    p_value in pls_integer)
is
begin
  set_value(p_path => p_path,
            p_param => p_param,
            p_value => to_char(p_value,g_param_int_fmt));
end;

-- ���������� �������� ��������� ������� (����������)
procedure set_value(p_path  in ovc_options.path%type,
                    p_param in ovc_options.param%type,
                    p_value in boolean)
is
begin

  set_value(p_path => p_path,
            p_param => p_param,
            p_value => case when p_value then 'T' when not p_value then 'F' else null end);
end;

end P_OVC_OPTIONS;
/
