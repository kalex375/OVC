PL/SQL Developer Test script 3.0
28
begin
  dbms_network_acl_admin.create_acl (
    acl         => 'utl_http.xml',
    description => 'HTTP Access',
    principal   => 'ORA_VER',
    is_grant    => TRUE,
    privilege   => 'connect',
    start_date  => null,
    end_date    => null
  );

  dbms_network_acl_admin.add_privilege (
    acl        => 'utl_http.xml',
    principal  => 'ORA_VER',
    is_grant   => TRUE,
    privilege  => 'resolve',
    start_date => null,
    end_date   => null
  );

  dbms_network_acl_admin.assign_acl (
    acl        => 'utl_http.xml',
    host       => '192.168.100.2',
    lower_port => 80,
    upper_port => 9000
  );
  commit;
end;
0
0
