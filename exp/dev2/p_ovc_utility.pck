create or replace package ora_ver.P_OVC_UTILITY is

  -- Author  :  Kravchenko A.V.        
  -- Created : 15.10.09 17:50:35
  -- Purpose : ��������������� ������� � ���������
  
  --���������� ��� ��������� ������
  function get_client_terminal_name return varchar2;
  
  --���������� ��� ������������ ��
  function get_client_os_user return varchar2;
  
  --���������� ���������� ����������� ������������
  function get_user_uid(p_user in ovc_lock_object.lock_user%type default null,
                        p_terminal in ovc_lock_object.lock_terminal%type default null,
                        p_os_user in ovc_lock_object.lock_os_user%type default null) return pls_integer;

end P_OVC_UTILITY;
/

create or replace package body ora_ver.P_OVC_UTILITY is
  /*
   
   ******************************
   *           -OVC-            *
   * Oracle Control Version (c) *
   ******************************
   
   Author  :  Kravchenko A.V.        
   Created : 15.10.09 17:50:35
   Purpose : ��������������� ������� � ���������
  
  */

function get_client_terminal_name return varchar2
is
begin
  return userenv('TERMINAL');
end;

function get_client_os_user return varchar2
is
  m_os_user varchar2(100);
begin

 select sys_context ('USERENV', 'OS_USER') into m_os_user from dual;
 return m_os_user;
 
exception when NO_DATA_FOUND then
  return null; 
end;  
                   
--���������� ���������� ����������� ������������
function get_user_uid(p_user in ovc_lock_object.lock_user%type default null,
                      p_terminal in ovc_lock_object.lock_terminal%type default null,
                      p_os_user in ovc_lock_object.lock_os_user%type default null) return pls_integer
is
begin
  return dbms_utility.get_hash_value(upper(p_user)||upper(p_terminal)||upper(p_os_user),1,65536);
end;

end P_OVC_UTILITY;
/

