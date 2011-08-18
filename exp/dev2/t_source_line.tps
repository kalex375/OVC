create or replace type ora_ver.T_SOURCE_LINE as object
(
  line number(10),
  text varchar2(4000),
  line_hash number(10)
)
/

