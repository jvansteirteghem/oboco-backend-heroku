insert into users (name, passwordHash, updateDate) values ('administrator', '$2a$12$msu32WtSMaQVCJsIDKCxkOTVOGRrncBjUe5x63GbY/RizCJ/zyFPC', current_timestamp);
insert into userRoles (userId, role) values (1, 'ADMINISTRATOR');
insert into userRoles (userId, role) values (1, 'USER');