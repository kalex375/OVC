create or replace function ora_ver.correct_inn(
 p_inn varchar2,            -- �������� ������-���
 p_mode integer default 0   -- �������� ������������� �����:

 ) return boolean
is

begin   

 return p_mode=1;
end correct_inn;
/

