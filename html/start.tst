PL/SQL Developer Test script 3.0
38
-- Created on 07.09.09 by Kravchenko A.V.
declare 
  -- Local variables here
 l_xml_config sys.xmltype;
 anonymous_already_set exception;
 pragma exception_init(anonymous_already_set,-30936); 
begin


  dbms_xdb.sethttpport(8080);
  dbms_epg.create_dad('OVC', '/OVC/*');
 
  dbms_epg.set_dad_attribute(dad_name => 'OVC',
                             attr_name => 'database-username',
                             attr_value => 'ORA_VER');
                             
  dbms_epg.authorize_dad(dad_name => 'OVC',user => 'ORA_VER');

  dbms_epg.set_dad_attribute(dad_name => 'OVC',
                             attr_name => 'error-style',
                             attr_value => 'DebugStyle');

  dbms_epg.set_dad_attribute(dad_name => 'OVC',
                             attr_name => 'nls-language',
                             attr_value => 'american_america.al32utf8');

  --dbms_epg.delete_dad_attribute('dad','database-username'); 
/* 
  select insertchildxml(xdburitype('/xdbconfig.xml').getxml(),'/xdbconfig/sysconfig/protocolconfig/httpconfig','allow-repository-anonymous-access',
      xmltype('true'),
      'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') into l_xml_config from dual;

  dbms_xdb.cfg_update(l_xml_config);
*/
  commit;
exception when anonymous_already_set then
  null;
end;  
0
0
