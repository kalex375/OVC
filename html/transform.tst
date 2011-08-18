PL/SQL Developer Test script 3.0
22
-- Created on 27.05.10 by Kravchenko A.V.
declare 
  -- Local variables here
  i integer;
  m xmltype;
  s xmltype;
  p xmltype;
begin
  --m := xmltype.createXML(:p_xml);
  
  s := xmltype.createXML(:p_xsl);
  
  select 
   xmlelement("ROOT",xmlagg(xmlelement("ROW", XMLForest(o.id,o.type)))) into m
  from
    ovc_object_type o
  where
    1=1;
  
  select XMLTRANSFORM(m,s) into p from dual;
  :p_html := p.GetClobVal;
end;
3
p_xml
1
<CLOB>
-4208
p_xsl
1
<CLOB>
4208
p_html
1
<CLOB>
4208
0
