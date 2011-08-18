PL/SQL Developer Test script 3.0
28
DECLARE
  c  utl_tcp.connection;  -- TCP/IP connection to the Web server
  ret_val pls_integer; 
BEGIN
  c := utl_tcp.open_connection(remote_host => '192.168.100.2',
                               remote_port =>  8084,
                               charset     => 'US7ASCII');  -- open connection
  --ret_val := utl_tcp.write_line(c, 'OPTIONS /svn/ORA_VER/trunk/$svn/act/exp/ HTTP/1.1');    -- send HTTP request
  ret_val := utl_tcp.write_line(c, 'CHECKOUT /svn/ORA_VER/trunk/exp/EXP.log HTTP/1.1');  
 --MKACTIVITY http://www.example.com/repos/foo/$svn/act/01234567-89ab-cdef-0123-45789abcdef
  ret_val := utl_tcp.write_line(c, 'Host: 192.168.100.2');    -- send HTTP request
  ret_val := utl_tcp.write_line(c, 'Authorization: Basic bWFkY2FwOkdmaGprbTgy');    -- send HTTP request
    ret_val := utl_tcp.write_line(c, 'Content-Length: 0');    -- send HTTP request

  ret_val := utl_tcp.write_line(c);
  --CHECKOUT /his/12/ver/V3 HTTP/1.1
  --Host: repo.webdav.org
  --Content-Length: 0
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
