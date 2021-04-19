insert into bookCollections (directoryPath, name, normalizedName, updateDate, rootBookCollectionId, parentBookCollectionId, numberOfBookCollections, numberOfBooks, number) values ('', 'DEFAULT', 'default', current_timestamp, null, null, 0, 0, 1);
insert into users (name, passwordHash, updateDate, rootBookCollectionId) values ('administrator', '$2a$12$msu32WtSMaQVCJsIDKCxkOTVOGRrncBjUe5x63GbY/RizCJ/zyFPC', current_timestamp, 1);
insert into userRoles (userId, role) values (1, 'ADMINISTRATOR');
insert into userRoles (userId, role) values (1, 'USER');