select
  dbms_java.longname(o.OBJECT_NAME) longname,
  o.*
from
  user_objects o
where
  o.object_type like 'JAVA CLASS' and
  o.status = 'INVALID'
