create table bookCollectionMarks (id bigserial not null, createDate timestamp not null, updateDate timestamp not null, userId int8 not null, bookCollectionId int8 not null, numberOfBookPages int4 not null, bookPage int4 not null, primary key (id));
create table bookCollections (id bigserial not null, directoryPath varchar(4096) not null, name varchar(255) not null, normalizedName varchar(255) not null, createDate timestamp not null, updateDate timestamp not null, rootBookCollectionId int8, parentBookCollectionId int8, numberOfBookCollections int4 not null, numberOfBooks int4 not null, numberOfBookPages int4 not null, number int4 not null, primary key (id));
create table bookMarkReferences (id bigserial not null, bookId int8 not null, bookMarkId int8 not null, primary key (id));
create table bookMarks (id bigserial not null, fileId varchar(64) not null, numberOfPages int4 not null, page int4 not null, createDate timestamp not null, updateDate timestamp not null, userId int8 not null, primary key (id));
create table books (id bigserial not null, fileId varchar(64) not null, filePath varchar(4096) not null, name varchar(255) not null, normalizedName varchar(255) not null, numberOfPages int4 not null, createDate timestamp not null, updateDate timestamp not null, bookCollectionId int8 not null, rootBookCollectionId int8 not null, number int4 not null, primary key (id));
create table userRoles (userId int8 not null, role varchar(255) not null);
create table users (id bigserial not null, name varchar(255) not null, passwordHash varchar(60) not null, createDate timestamp not null, updateDate timestamp not null, rootBookCollectionId int8, primary key (id));

alter table bookCollectionMarks add constraint FKacm12b7i2glkb9bscnsqvd4rb unique (userId, bookCollectionId);
alter table bookCollectionMarks add constraint FKecm1297i2glkb9bssnsqvd4rb foreign key (userId) references users(id);
alter table bookCollectionMarks add constraint FKecm9391i4glkb7bssnsqvd5rb foreign key (bookCollectionId) references bookCollections(id) on delete cascade;
create index bookCollectionMarkCreateDate on bookCollectionMarks (createDate);
create index bookCollectionMarkUpdateDate on bookCollectionMarks (updateDate);

alter table bookCollections add constraint FKiufb5ykonq8jxly61he6muql0 foreign key (rootBookCollectionId) references bookCollections(id) on delete cascade;
alter table bookCollections add constraint FKiufb3ykonq6jxly95he6muql0 foreign key (parentBookCollectionId) references bookCollections(id) on delete cascade;
create index bookCollectionDirectoryPath on bookCollections (directoryPath);
create index bookCollectionNormalizedName on bookCollections (normalizedName);
create index bookCollectionNumber on bookCollections (number);
create index bookCollectionCreateDate on bookCollections (createDate);
create index bookCollectionUpdateDate on bookCollections (updateDate);

alter table bookMarks add constraint FKefm1898i2glgb1dddnshvd3rb unique (userId, fileId);
alter table bookMarks add constraint FKecm1898i2glkb1dddnsqvd3rb foreign key (userId) references users(id);
create index bookMarkFileId on bookMarks (fileId);
create index bookMarkCreateDate on bookMarks (createDate);
create index bookMarkUpdateDate on bookMarks (updateDate);

alter table bookMarkReferences add constraint FKecmi391i4glkbjdddnsqkd5rb unique (bookId, bookMarkId);
alter table bookMarkReferences add constraint FKecm9391i4glkb7dddnsqvd5rb foreign key (bookId) references books(id) on delete cascade;
alter table bookMarkReferences add constraint FKl2ijhkebftw3gdgmlkseo49kp foreign key (bookMarkId) references bookMarks(id) on delete cascade;

alter table books add constraint FKe6gb0v6dtxns6rgtd8bv4ri0h foreign key (bookCollectionId) references bookCollections(id);
alter table books add constraint FKe2gb0v6dtxns3rgtd1bv2ri0h foreign key (rootBookCollectionId) references bookCollections(id);
create index bookNormalizedName on books (normalizedName);
create index bookFileId on books (fileId);
create index bookFilePath on books (filePath);
create index bookNumber on books (number);
create index bookCreateDate on books (createDate);
create index bookUpdateDate on books (updateDate);

alter table userRoles add constraint FKgqpfwr3766gtqga2i0kgmlwlu foreign key (userId) references users(id);

alter table users add constraint FKe9xa0v3dtxasmrgtd7bn5rixh unique (name);
alter table users add constraint FKe9gb0v3dtxns6rgtd7bv5ri1h foreign key (rootBookCollectionId) references bookCollections(id) on delete set null;
create index userCreateDate on users (createDate);
create index userUpdateDate on users (updateDate);