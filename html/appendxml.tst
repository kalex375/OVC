PL/SQL Developer Test script 3.0
15
-- Created on 25.05.10 by Kravchenko A.V.
declare 
  -- Local variables here
  m_xml xmltype;
--  m_xml_get xmltype;
begin
--    m_xml_get :=;--dbms_xdb.getContentXMLType(abspath => '/ovc_data/index.html');

    select AppendChildXml(
    xdburitype('/ovc_data/index.html').getxml(),--,
    '/html/body/div[@id="main-copy"]',
    xmltype('<h2>234</h2>'))
    into m_xml from dual;
  :m_clob := m_xml.getClobVal();
end;
1
m_clob
1
<CLOB>
4208
0
