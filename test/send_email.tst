PL/SQL Developer Test script 3.0
33
DECLARE
  c utl_smtp.connection;
 
  PROCEDURE send_header(name IN VARCHAR2, header IN VARCHAR2) AS
  BEGIN
    utl_smtp.write_data(c, name || ': ' || header || utl_tcp.CRLF);
  END;
 
BEGIN
  c := utl_smtp.open_connection('smtp.fcbank.com.ua');
  utl_smtp.helo(c, 'fcbank.com.ua');
  utl_smtp.mail(c, 'alexandr.kravchenko@fcbank.com.ua');
  utl_smtp.rcpt(c, 'alexandr.kravchenko@fcbank.com.ua');
  utl_smtp.open_data(c);
  send_header('From',    '"SRSEP2" <-alexandr.kravchenko@fcbank.com.ua>');
  send_header('To',      '"Kravchenko A.V." <alexandr.kravchenko@fcbank.com.ua>');
  send_header('Subject', 'From Oracle Server');
  utl_smtp.write_data(c, utl_tcp.CRLF || 'Hello, world!');
  utl_smtp.close_data(c);
  utl_smtp.quit(c);
EXCEPTION
  WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
    BEGIN
      utl_smtp.quit(c);
    EXCEPTION
      WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        NULL; -- When the SMTP server is down or unavailable, we don't have
              -- a connection to the server. The quit call will raise an
              -- exception that we can ignore.
    END;
    raise_application_error(-20000,
      'Failed to send mail due to the following error: ' || sqlerrm);
END;
0
0
