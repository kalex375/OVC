PL/SQL Developer Test script 3.0
8
-- Created on 08.11.10 by Kravchenko A.V.
declare 
  -- Local variables here
  i integer;
begin
  -- Test statements here
  dbms_java.grant_permission( 'ORA_VER', 'SYS:java.util.logging.LoggingPermission', 'control', '' );
end;
0
0
