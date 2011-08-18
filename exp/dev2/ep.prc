create or replace procedure ora_ver.ep(ed in out number, ec in out number, ef in out date, eg in boolean) is
begin
ed:= ed+1;
ec:= ec+2;
ef:= ef+100;
end ep;
/

