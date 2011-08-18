PL/SQL Developer Test script 3.0
69
DECLARE
  c  utl_tcp.connection;  -- TCP/IP connection to the Web server
  ret_val pls_integer; 
BEGIN
--    OPTIONS to start ra_session
--     PROPFINDs to discover various opaque URIs
--     MKACTIVITY to create a transaction
--     try:
--       for each changed object:
--        CHECKOUT object to get working resource
--         PUT/PROPPATCH/DELETE/COPY working resource
--         MKCOL to create new directories
--       MERGE to commit the transaction
--     finally:
--       DELETE the activity
  
  
  c := utl_tcp.open_connection(remote_host => '10.1.71.57',
                               remote_port =>  80);  -- open connection

  ret_val := utl_tcp.write_line(c, 'OPTIONS /svn/TEST_SVN/trunk HTTP/1.1');    -- send HTTP request                               
  ret_val := utl_tcp.write_text(c,
'User-Agent: SVN/1.6.9 (r901367)/TortoiseSVN-1.6.7.18415 neon/0.29.3'||chr(13)||chr(10)||
'Keep-Alive: '||chr(13)||chr(10)||
'Connection: TE, Keep-Alive'||chr(13)||chr(10)||
'TE: trailers'||chr(13)||chr(10)||
'Host: 10.1.71.57'||chr(13)||chr(10)||
'Content-Type: text/xml'||chr(13)||chr(10)||
'Accept-Encoding: gzip'||chr(13)||chr(10)||
'DAV: http://subversion.tigris.org/xmlns/dav/svn/depth'||chr(13)||chr(10)||
'DAV: http://subversion.tigris.org/xmlns/dav/svn/mergeinfo'||chr(13)||chr(10)||
'DAV: http://subversion.tigris.org/xmlns/dav/svn/log-revprops'||chr(13)||chr(10)||
'Content-Length: 104'||chr(13)||chr(10)||
'Accept-Encoding: gzip'||chr(13)||chr(10)||
'Authorization: Basic a3JhdmNoYXY6R2ZoamttODk='||chr(13)||chr(10)||
chr(13)||chr(10)||
'<?xml version="1.0" encoding="utf-8"?><D:options xmlns:D="DAV:"><D:activity-collection-set/></D:options>'
  );
--  ret_val := utl_tcp.write_line(c,'Keep-Alive: ');
--  ret_val := utl_tcp.write_line(c,'Connection: TE, Keep-Alive');
--  ret_val := utl_tcp.write_line(c,'Accept-Encoding: gzip');
--  ret_val := utl_tcp.write_line(c,);
--  ret_val := utl_tcp.write_line(c,'DAV: http://subversion.tigris.org/xmlns/dav/svn/mergeinfo');
--  ret_val := utl_tcp.write_line(c,'DAV: http://subversion.tigris.org/xmlns/dav/svn/log-revprops');
--  ret_val := utl_tcp.write_line(c,'Content-Length: '||length(:p_request));
--  ret_val := utl_tcp.write_line(c,'Accept-Encoding: gzip');
--  ret_val := utl_tcp.write_line(c,'Authorization: Basic a3JhdmNoYXY6R2ZoamttODk=');
--  ret_val := utl_tcp.write_line(c,'');
  --UTL_TCP.FLUSH(c);
--  ret_val := utl_tcp.WRITE_LINE(c, chr(13)||chr(10)); 
  --UTL_TCP.FLUSH(c);
--  ret_val := utl_tcp.write_line(c,:p_request);
 --UTL_TCP.FLUSH(c);
 -- put  ret_val := utl_tcp.write_line(c, 'This is the end');
 -- ret_val := utl_tcp.write_line(c,'<S:update-report send-all="true" xmlns:S="svn:">');
 -- ret_val := utl_tcp.write_line(c,'  <S:src-path>http://10.1.71.31:8081/svn/TEST_SVN/</S:src-path>');
 --  ret_val := utl_tcp.write_line(c,'  <S:target-revision>2</S:target-revision>');
 --  ret_val := utl_tcp.write_line(c,'  <S:entry rev="2"  start-empty="true"></S:entry>');
 --  ret_val := utl_tcp.write_line(c,'</S:update-report>');
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
1
p_request
1
<?xml version="1.0" encoding="utf-8"?><D:options xmlns:D="DAV:"><D:activity-collection-set/></D:options>
-5
0
