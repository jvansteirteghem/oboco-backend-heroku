create table bookCollections (id bigserial not null, directoryPath varchar(4096) not null, name varchar(255) not null, normalizedName varchar(255) not null, createDate timestamp not null, updateDate timestamp not null, rootBookCollectionId int8, parentBookCollectionId int8, numberOfBookCollections int4 not null, numberOfBooks int4 not null, number int4 not null, primary key (id));
create table bookMarkReferences (id bigserial not null, createDate timestamp not null, updateDate timestamp not null, userId int8 not null, bookId int8, bookMarkId int8 not null, bookCollectionId int8 not null, rootBookCollectionId int8 not null, primary key (id));
create table bookMarks (id bigserial not null, fileId varchar(64) not null, page int4 not null, createDate timestamp not null, updateDate timestamp not null, userId int8 not null, primary key (id));
create table books (id bigserial not null, fileId varchar(64) not null, filePath varchar(4096) not null, name varchar(255) not null, normalizedName varchar(255) not null, numberOfPages int4 not null, createDate timestamp not null, updateDate timestamp not null, bookCollectionId int8 not null, rootBookCollectionId int8 not null, number int4 not null, primary key (id));
create table userRoles (userId int8 not null, role varchar(255) not null);
create table users (id bigserial not null, name varchar(255) not null, passwordHash varchar(60) not null, createDate timestamp not null, updateDate timestamp not null, rootBookCollectionId int8, primary key (id));
create table childBookCollections (bookCollectionId int8 not null, childBookCollectionId int8 not null, primary key (bookCollectionId, childBookCollectionId));
create index bookCollectionDirectoryPath on bookCollections (directoryPath);
create index bookCollectionNormalizedName on bookCollections (normalizedName);
create index bookNormalizedName on books (normalizedName);
alter table bookMarkReferences add constraint bookMarkReferenceUserIdBookId unique (userId, bookId);
alter table bookMarks add constraint bookMarkUserIdFileId unique (userId, fileId);
create index bookMarkFileId on bookMarks (fileId);
create index bookFileId on books (fileId);
create index bookFilePath on books (filePath);
create index bookNumber on books (number);
create index bookCollectionNumber on bookCollections (number);
create index bookCreateDate on books (createDate);
create index bookUpdateDate on books (updateDate);
create index bookCollectionCreateDate on bookCollections (createDate);
create index bookCollectionUpdateDate on bookCollections (updateDate);
create index bookMarkReferenceCreateDate on bookMarkReferences (createDate);
create index bookMarkReferenceUpdateDate on bookMarkReferences (updateDate);
create index bookMarkCreateDate on bookMarks (createDate);
create index bookMarkUpdateDate on bookMarks (updateDate);
create index userCreateDate on users (createDate);
create index userUpdateDate on users (updateDate);
alter table users add constraint userName unique (name);
alter table users add constraint FKe9gb0v3dtxns6rgtd7bv5ri1h foreign key (rootBookCollectionId) references bookCollections(id) on delete set null;
alter table bookCollections add constraint FKiufb5ykonq8jxly61he6muql0 foreign key (rootBookCollectionId) references bookCollections(id) on delete cascade;
alter table bookCollections add constraint FKiufb3ykonq6jxly95he6muql0 foreign key (parentBookCollectionId) references bookCollections(id) on delete cascade;
alter table childBookCollections add constraint FKiufb9ykonq1jxly91he9muql0 foreign key (bookCollectionId) references bookCollections(id) on delete cascade;
alter table childBookCollections add constraint FKiufb1ykonq9jxly19he1muql0 foreign key (childBookCollectionId) references bookCollections(id) on delete cascade;
alter table bookMarkReferences add constraint FKecm1297i2glkb9dddnsqvd4rb foreign key (userId) references users(id);
alter table bookMarkReferences add constraint FKecm9391i4glkb7dddnsqvd5rb foreign key (bookId) references books(id);
alter table bookMarkReferences add constraint FKl2ijhkebftw3gdgmlkseo49kp foreign key (bookMarkId) references bookMarks(id);
alter table bookMarkReferences add constraint FKl6ijhkabftw8gdgmlksaa71kp foreign key (bookCollectionId) references bookCollections(id);
alter table bookMarkReferences add constraint FKl6ijhkebftw8gdgmlkseo71kp foreign key (rootBookCollectionId) references bookCollections(id);
alter table books add constraint FKe6gb0v6dtxns6rgtd8bv4ri0h foreign key (bookCollectionId) references bookCollections(id);
alter table books add constraint FKe2gb0v6dtxns3rgtd1bv2ri0h foreign key (rootBookCollectionId) references bookCollections(id);
alter table userRoles add constraint FKgqpfwr3766gtqga2i0kgmlwlu foreign key (userId) references users(id);
alter table bookMarks add constraint FKecm1898i2glkb1dddnsqvd3rb foreign key (userId) references users(id);
