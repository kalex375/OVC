PL/SQL Developer Test script 3.0
19
DECLARE
  c  utl_tcp.connection;  -- TCP/IP connection to the Web server
  ret_val pls_integer; 
BEGIN
  c := utl_tcp.open_connection(remote_host => '10.1.71.57',
                               remote_port =>  80);  -- open connection
  ret_val := utl_tcp.write_line(c, 'GET /svn/TEST_SVN/trunk/test_dir/LICENSE HTTP/1.0');    -- send HTTP request
  ret_val := utl_tcp.write_line(c, 'Authorization: Basic a3JhdmNoYXY6R2ZoamttODk=');    -- send HTTP Auth
  ret_val := utl_tcp.write_line(c);
  BEGIN
    LOOP
      dbms_output.put_line(utl_tcp.get_line(c, TRUE));  -- read result
    END LOOP;
  EXCEPTION
    WHEN utl_tcp.end_of_input THEN
      NULL; -- end of input
  END;
  utl_tcp.close_connection(c);
END;
0
0
