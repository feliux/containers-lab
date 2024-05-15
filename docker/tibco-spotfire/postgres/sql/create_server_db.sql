/*
 * Copyright (c) 2019-2020 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB (Confidential Information). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */


-- ================================
--  Report errors
-- ================================

\set ON_ERROR_STOP on

-- ================================
--      Create Database Schema
-- ================================


/* ----------------- Server version and encryption canary --------------------- */

create table SN_VERSION (
    SPOTFIRE_VERSION varchar(20) not null,
    SCHEMA_VERSION varchar(20) not null,
    ENCRYPTION_CANARY varchar(400) null,
    CLUSTER_ID char(36) null
);

/* ----------------- Configuration --------------------- */

create table SERVER_CONFIGURATIONS (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE timestamp(0) not null,
    CONFIG_VERSION varchar(50) not null,
    CONFIG_DESCRIPTION varchar(1000) not null,
    CONFIG_CONTENT bytea not null,
    constraint PK_SERVER_CONFIGURATIONS primary key (CONFIG_HASH)
);

create table CONFIG_HISTORY (
    CONFIG_HASH char(40) not null,
    CONFIG_DATE timestamp(0) not null,
    CONFIG_COMMENT varchar(1000) not null,
    constraint PK_CONFIG_HISTORY primary key (CONFIG_HASH, CONFIG_DATE),
    constraint FK_CONFIG_HISTORY_CONFIG_HASH foreign key (CONFIG_HASH)
        references SERVER_CONFIGURATIONS (CONFIG_HASH) on delete cascade
);

/* ----------------- Licenses and preferences --------------------- */

create table LICENSE_NAMES (
    LICENSE_NAME varchar(256) not null,
    LICENSE_DISPLAY_NAME varchar(400) null,
    constraint LICENSE_NAMES_PK primary key (LICENSE_NAME)
);

create table PREFERENCE_KEYS (
    CATEGORY_NAME varchar(250) not null,
    PREFERENCE_NAME varchar(250) not null,
    CLASS_TYPE varchar(250) not null,
    PREFERENCE_ID char(36) not null,
    constraint PREFERENCE_KEYS_PK primary key (PREFERENCE_ID)
);

create table PREFERENCE_OBJECTS (
    CLASS_NAME varchar(250) not null,
    OBJECT_NAME varchar(250) not null,
    LAST_MODIFIED timestamp null,
    USER_ID char(36) null,
    GROUP_ID char(36) null,
    IS_DEFAULT boolean null,
    OBJECT_VALUE varchar(4000) null,
    OBJECT_BLOB_VALUE bytea null,
    constraint PREFERENCE_OBJECTS_PK primary key (CLASS_NAME, OBJECT_NAME)
);

create table LICENSE_ORIGIN (
    PACKAGE_ID char(36) null,
    ASSEMBLY_QUALIFIED_NAME varchar(400) not null,
    LICENSE_FUNCTION_ID char(36) not null
);

create table EXCLUDED_FUNCTIONS (
    CUSTOMIZED_LICENSE_ID char(36) not null,
    LICENSE_FUNCTION_ID char(36) not null,
    constraint EXCLUDED_FUNCTIONS_PK primary key (CUSTOMIZED_LICENSE_ID, LICENSE_FUNCTION_ID)
);

create table CUSTOMIZED_LICENSES (
    CUSTOMIZED_LICENSE_ID char(36) not null,
    GROUP_ID char(36) not null,
    LICENSE_NAME varchar(256) null,
    constraint CUSTOMIZED_LICENSES_PK primary key (CUSTOMIZED_LICENSE_ID)
);

create table LICENSE_FUNCTIONS (
    LICENSE_FUNCTION_ID char(36) not null,
    LICENSE_NAME varchar(256) not null,
    LICENSE_FUNCTION_NAME varchar(50) not null,
    LICENSE_FUNCTION_DISPLAY_NAME varchar(400) null,
    constraint LICENSE_FUNCTIONS_PK primary key (LICENSE_FUNCTION_ID),
    constraint LICENSE_FUNCTIONS_UC1 unique (LICENSE_FUNCTION_NAME, LICENSE_NAME)
);

create table PREFERENCE_VALUES (
    PREFERENCE_VALUE varchar(8000) null,
    LAST_MODIFIED timestamp not null,
    USER_ID char(36) null,
    GROUP_ID char(36) null,
    PREFERENCE_ID char(36) not null,
    PREFERENCE_BLOB_VALUE bytea null
);

create unique index PREFERENCE_VALUES_GRP_IDX on PREFERENCE_VALUES (
	GROUP_ID, PREFERENCE_ID
) where USER_ID IS NULL;

create unique index PREFERENCE_VALUES_USR_IDX on PREFERENCE_VALUES (
	USER_ID, PREFERENCE_ID
) where GROUP_ID IS NULL;

/* ----------------- Users and Groups --------------------- */

create table GROUP_MEMBERS (
    GROUP_ID char(36) not null,
    MEMBER_USER_ID char(36) null,
    MEMBER_GROUP_ID char(36) null
);

create unique index GROUP_MEMBER_REVERSE_USER_IX on GROUP_MEMBERS (MEMBER_USER_ID, GROUP_ID);

create unique index GROUP_MEMBER_REVERSE_GRP_IX on GROUP_MEMBERS (MEMBER_GROUP_ID, GROUP_ID);

create table USERS (
    USER_ID char(36) not null,
    USER_NAME varchar(200) not null,
    DOMAIN_NAME varchar(200) not null,
    EXTERNAL_ID varchar(450) null,
    PRIMARY_GROUP_ID char(36) null,
    LAST_MODIFIED_MEMBERSHIP timestamp null,
    PASSWORD varchar(150) null,
    DISPLAY_NAME varchar(450) not null,
    EMAIL varchar(450) null,
    ENABLED boolean not null,
    LOCKED_UNTIL timestamp null,
    LAST_LOGIN timestamp null,
    constraint USERS_PK primary key (USER_ID)
);

create view GROUP_MEMBERS_VIEW as
    select GROUP_ID, MEMBER_USER_ID, MEMBER_GROUP_ID from GROUP_MEMBERS
    union all
    select '19e7e430-9997-11da-fbc4-0010ac110215' as GROUP_ID, u.USER_ID as MEMBER_USER_ID, null as MEMBER_GROUP_ID
    from USERS u where u.DOMAIN_NAME !=  N'ANONYMOUS';

create table GROUPS (
    GROUP_ID char(36) not null,
    GROUP_NAME varchar(200) not null,
    DOMAIN_NAME varchar(200) not null,
    EXTERNAL_ID varchar(450) null,
    PRIMARY_GROUP_ID char(36) null,
    DISPLAY_NAME varchar(450) not null,
    EMAIL varchar(450) null,
    CONNECTED boolean not null,
    constraint GROUPS_PK primary key (GROUP_ID)
);

/* ----------------- Deployments --------------------- */

create table DEP_AREAS_DEF (
    AREA_ID char(36) not null,
    DEP_AREA_NAME varchar(50) not null,
    IS_DEFAULT_AREA char(1) not null,
    constraint DEP_AREAS_DEF_PK primary key (AREA_ID),
    constraint DEP_AREAS_DEF_UC1 unique (DEP_AREA_NAME)
);

create table DEP_AREAS (
    AREA_ID char(36) not null,
    DISTRIBUTION_ID char(36) not null,
    DEPLOYMENT_TIME timestamp not null,
    STATE smallint null,
    URL varchar(50) null,
    constraint DEP_AREAS_PK primary key (AREA_ID)
);

create table DEP_DISTRIBUTION_CONTENTS (
    PACKAGE_ID char(36) not null,
    DISTRIBUTION_ID char(36) not null,
    constraint DEP_DISTRIBUTION_CONTENTS_PK primary key (PACKAGE_ID, DISTRIBUTION_ID)
);

create table DEP_DISTRIBUTIONS (
    DISTRIBUTION_ID char(36) not null,
    NAME varchar(200) not null,
    MODIFIED_DATE DATE not null,
    VERSION varchar(50) null,
    ADDINS_XML bytea null,
    MANIFEST_XML bytea null,
    DESCRIPTION varchar(400) null,
    METADATA_XML bytea null,
    constraint DEP_DISTRIBUTIONS_PK primary key (DISTRIBUTION_ID)
);

create table DEP_AREA_ALLOWED_GRP (
    AREA_ID char(36) not null,
    GROUP_ID char(36) not null,
    constraint DEP_AREA_ALLOWED_GRP_PK primary key (GROUP_ID)
);

create index DEP_AREA_ALWD_GRP_AREA_ID_IDX on DEP_AREA_ALLOWED_GRP(AREA_ID);

create table DEP_PACKAGES (
    PACKAGE_ID char(36) not null,
    SERIE_ID char(36) not null,
    NAME varchar(200) not null,
    ZIP oid not null,
    MODIFIED_DATE date not null,
    VERSION varchar(32) not null,
    DESCRIPTION varchar(400) null
);


alter table GROUP_MEMBERS add constraint GROUP_MEMBERS_XOR check (
    (MEMBER_USER_ID is null and MEMBER_GROUP_ID is not null)
    or
    (MEMBER_USER_ID is not null and MEMBER_GROUP_ID is null)
    or
    (GROUP_ID = '19e7e430-9997-11da-fbc4-0010ac110215')
);

create unique index USERS_NAME_DOMAIN_UIDX2 on USERS (USER_NAME, DOMAIN_NAME);

alter table USERS add constraint USERS_NAME_DOMAIN_UIDX unique (USER_NAME, DOMAIN_NAME);

create unique index USERS_NAME_DOMAIN_U_UIDX on USERS (upper(USER_NAME), upper(DOMAIN_NAME));

create unique index GROUPS_NAME_DOMAIN_UIDX2 on GROUPS (GROUP_NAME, DOMAIN_NAME);

alter table GROUPS add constraint GROUPS_NAME_DOMAIN_UIDX unique (GROUP_NAME, DOMAIN_NAME);

create unique index GROUPS_NAME_DOMAIN_U_UIDX on GROUPS (upper(GROUP_NAME), upper(DOMAIN_NAME));

create index GROUPS_PRIMARY_GROUP_ID_IDX on GROUPS (PRIMARY_GROUP_ID);

create index USERS_PRIMARY_GROUP_ID_IDX on USERS (PRIMARY_GROUP_ID);

create unique index DEP_PACKAGES_PK on DEP_PACKAGES (PACKAGE_ID);

alter table DEP_PACKAGES add constraint DEP_PACKAGES_PK_UC1 unique (
    PACKAGE_ID);

create or replace function usp_dep_packagesDelTrig()
returns trigger as
$$
begin
    if old.zip is not null
           and not exists (select 1 from DEP_PACKAGES d where d.zip = old.zip)
           and exists (select 1 from pg_catalog.pg_largeobject_metadata where oid = old.zip)
    then
        perform lo_unlink(old.zip);
    end if;
    return new;
end;
$$
language plpgsql;

create or replace function usp_dep_packagesUpdTrig()
returns trigger as
$$
begin
    if old.zip is not null and old.zip != new.zip
           and not exists (select 1 from DEP_PACKAGES d where d.zip = old.zip)
           and exists (select 1 from pg_catalog.pg_largeobject_metadata where oid = old.zip)
    then
        perform lo_unlink(old.zip);
    end if;
    return new;
end;
$$
language plpgsql;

create trigger dep_packages_del_tr after delete on dep_packages
    for each row execute procedure usp_dep_packagesDelTrig();

create trigger dep_packages_upd_tr after update on dep_packages
    for each row execute procedure usp_dep_packagesUpdTrig();

alter table PREFERENCE_KEYS add constraint PREFERENCE_KEYS_UC1 unique (
    CATEGORY_NAME,
    PREFERENCE_NAME,
    CLASS_TYPE
);

alter table PREFERENCE_OBJECTS
    add constraint GROUPS_PREFERENCE_OBJECTS_FK1 foreign key (
        GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete cascade;

alter table PREFERENCE_OBJECTS
    add constraint USERS_PREFERENCE_OBJECTS_FK1 foreign key (
        USER_ID)
    references USERS (
        USER_ID) on delete cascade;

alter table LICENSE_ORIGIN
    add constraint DEP_PKGS_LIC_ORIGIN_FK1 foreign key (
        PACKAGE_ID)
    references DEP_PACKAGES (
        PACKAGE_ID) on delete set null;

alter table LICENSE_ORIGIN
    add constraint LIC_FUNS_LIC_ORIGIN_FK1 foreign key (
        LICENSE_FUNCTION_ID)
    references LICENSE_FUNCTIONS (
        LICENSE_FUNCTION_ID) on delete cascade;

alter table EXCLUDED_FUNCTIONS
    add constraint CUSTOMIZED_LIC_EXCLUDED_FN_FK1 foreign key (
        CUSTOMIZED_LICENSE_ID)
    references CUSTOMIZED_LICENSES (
        CUSTOMIZED_LICENSE_ID) on delete cascade;

alter table EXCLUDED_FUNCTIONS
    add constraint LIC_FUNS_EXCL_FUNS_FK1 foreign key (
        LICENSE_FUNCTION_ID)
     references LICENSE_FUNCTIONS (
        LICENSE_FUNCTION_ID) on delete cascade;

alter table CUSTOMIZED_LICENSES
    add constraint GROUPS_CUSTOMIZED_LICENSES_FK1 foreign key (
        GROUP_ID)
     references GROUPS (
        GROUP_ID) on delete cascade;

alter table CUSTOMIZED_LICENSES
    add constraint LICENSE_NAMES_CUST_LIC_FK1 foreign key (
        LICENSE_NAME)
    references LICENSE_NAMES (
        LICENSE_NAME) on delete cascade;

alter table LICENSE_FUNCTIONS
    add constraint LICENSE_NAMES_LIC_FUNS_FK1 foreign key (
        LICENSE_NAME)
    references LICENSE_NAMES (
        LICENSE_NAME) on delete cascade;

alter table PREFERENCE_VALUES
    add constraint GROUPS_PREFERENCE_VALUES_FK1 foreign key (
        GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete cascade;

alter table PREFERENCE_VALUES
    add constraint USERS_PREFERENCE_VALUES_FK1 foreign key (
        USER_ID)
    references USERS (
        USER_ID) on delete cascade;

alter table PREFERENCE_VALUES
    add constraint PREFERENCE_KEY_VALUES_FK1 foreign key (
        PREFERENCE_ID)
     references PREFERENCE_KEYS (
        PREFERENCE_ID) on delete cascade;

alter table DEP_AREA_ALLOWED_GRP
    add constraint GROUPS__GROUP_ID_FK1 foreign key (
        GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete cascade;

alter table DEP_AREA_ALLOWED_GRP
    add constraint DEP_AREAS_AREA_ID_FK1 foreign key (
        AREA_ID)
    references DEP_AREAS_DEF (
        AREA_ID) on delete cascade;

alter table GROUP_MEMBERS
    add constraint GROUP_MEMBERS_FK1 foreign key (
        MEMBER_GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete cascade;

alter table GROUP_MEMBERS
    add constraint GROUP_ID_FK2 foreign key (
        GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete cascade;

alter table GROUP_MEMBERS
    add constraint USERS_GROUP_MEMBERS_FK1 foreign key (
        MEMBER_USER_ID)
    references USERS (
        USER_ID) on delete cascade;

alter table USERS
    add constraint GROUPS_USERS_FK1 foreign key (
        PRIMARY_GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete set null;

alter table GROUPS
    add constraint GROUPS_GROUPS_FK1 foreign key (
        PRIMARY_GROUP_ID)
    references GROUPS (
        GROUP_ID) on delete set null;

alter table DEP_AREAS
    add constraint DEP_DIST_AREA_DIST_ID_FK1 foreign key (
        DISTRIBUTION_ID)
    references DEP_DISTRIBUTIONS (
        DISTRIBUTION_ID) on delete cascade;

alter table DEP_AREAS
    add constraint DEP_AREAS_DEF_FK1 foreign key (
        AREA_ID)
    references DEP_AREAS_DEF(
        AREA_ID) on delete cascade;

alter table DEP_DISTRIBUTION_CONTENTS
    add constraint DEP_DISTRIBUTIONS_DIST_ID_FK1 foreign key (
        DISTRIBUTION_ID)
    references DEP_DISTRIBUTIONS (
        DISTRIBUTION_ID) on delete cascade;

alter table DEP_DISTRIBUTION_CONTENTS
    add constraint DEP_PACKAGES_PACKAGE_ID_FK1 foreign key (
        PACKAGE_ID)
    references DEP_PACKAGES (
        PACKAGE_ID) on delete cascade;

create view UTC_TIME as select now() at time zone 'utc' as TS;

/* ----------------- Library --------------------- */

create table LIB_ITEM_TYPES (
    TYPE_ID char(36) not null,
    LABEL varchar(255) not null,
    LABEL_PREFIX varchar(255) not null,
    DISPLAY_NAME varchar(255) not null,
    IS_CONTAINER char(1) not null,
    FILE_SUFFIX varchar(255) null,
    MIME_TYPE varchar(255) null,
    constraint PK_LIB_ITEM_TYPES primary key (TYPE_ID),
    constraint LIB_ITEM_TYPES_CONSTRAINT unique (LABEL, LABEL_PREFIX)
);

create table LIB_CONTENT_TYPES (
    TYPE_ID decimal(2,0) not null,
    CONTENT_TYPE varchar(50) not null,
    constraint PK_LIB_CONTENT_TYPES primary key (TYPE_ID)
);

create table LIB_CONTENT_ENCODINGS (
    ENCODING_ID decimal(2,0) not null,
    CONTENT_ENCODING varchar(50) not null,
    constraint PK_LIB_CONTENT_ENCODINGS primary key (ENCODING_ID)
);

create table LIB_CHARACTER_ENCODINGS (
    ENCODING_ID decimal(2,0) not null,
    CHARACTER_ENCODING varchar(50) not null,
    constraint PK_LIB_CHARACTER_ENCODINGS primary key (ENCODING_ID)
);

create table LIB_ITEMS (
    ITEM_ID char(36) not null,
    TITLE varchar(256) not null,
    DESCRIPTION varchar(1000) null,
    ITEM_TYPE char(36) not null,
    FORMAT_VERSION varchar(50) null,
    CREATED_BY char(36) null,
    CREATED timestamp(6) not null,
    MODIFIED_BY char(36) null,
    MODIFIED timestamp(6) not null,
    ACCESSED timestamp(6) null,
    CONTENT_SIZE bigint default 0 not null,
    PARENT_ID char(36) null,
    HIDDEN boolean not null,
    constraint PK_ITEM_ID primary key (ITEM_ID),
    constraint FK_LIB_ITEM_ITEM_TYPE foreign key (ITEM_TYPE)
            references LIB_ITEM_TYPES (TYPE_ID),
    constraint LIB_ITEM_USER_FK1 foreign key (CREATED_BY)
            references USERS (USER_ID) on delete set null,
    constraint LIB_ITEM_USER_FK2 foreign key (MODIFIED_BY)
            references USERS (USER_ID) on delete set null,
    constraint FK_LIB_ITEM_PARENT_ID foreign key (PARENT_ID)
            references LIB_ITEMS (ITEM_ID) on delete cascade
);

alter table LIB_ITEMS add constraint LIB_ITEMS_PARENT_NEQ_ITEM
    check (ITEM_ID != PARENT_ID);

create index LIB_ITEM_INDEX1 on LIB_ITEMS (CREATED_BY);

create index LIB_ITEM_INDEX2 on LIB_ITEMS (MODIFIED_BY);

create index LIB_ITEM_INDEX3 on LIB_ITEMS (ITEM_TYPE);

create index LIB_ITEM_INDEX4 on LIB_ITEMS (upper(TITLE));

create index LIB_ITEM_INDEX5 on LIB_ITEMS (PARENT_ID);

create table LIB_DATA (
    ITEM_ID char(36) not null,
    CONTENT_TYPE decimal(2,0) null,
    CONTENT_ENCODING decimal(2,0) null,
    CHARACTER_ENCODING decimal(2,0) null,
    DATA oid not null,
    constraint PK_LIB_DATA_ITEM_ID primary key (ITEM_ID),
    constraint FK_LIB_DATA_ITEM_ID foreign key (ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade,
    constraint FK_LIB_DATA_CONTENT_TYPE foreign key (CONTENT_TYPE)
        references LIB_CONTENT_TYPES (TYPE_ID),
    constraint FK_LIB_DATA_CONTENT_ENCODING foreign key (CONTENT_ENCODING)
        references LIB_CONTENT_ENCODINGS (ENCODING_ID),
    constraint FK_LIB_DATA_CHARACTER_ENCODING foreign key (CHARACTER_ENCODING)
        references LIB_CHARACTER_ENCODINGS (ENCODING_ID)
);

create or replace function usp_lib_dataDelTrig()
returns trigger as
$$
begin
    if old.data is not null
           and not exists (select 1 from LIB_DATA d where d.data = old.data)
           and exists (select 1 from pg_catalog.pg_largeobject_metadata where oid = old.data)
    then
        perform lo_unlink(old.data);
    end if;
    return new;
end;
$$
language plpgsql;

create or replace function usp_lib_dataUpdTrig()
returns trigger as
$$
begin
    if old.data is not null and old.data != new.data
           and not exists (select 1 from LIB_DATA d where d.data = old.data)
           and exists (select 1 from pg_catalog.pg_largeobject_metadata where oid = old.data)
    then
        perform lo_unlink(old.data);
    end if;
    return new;
end;
$$
language plpgsql;

create trigger lib_data_del_tr after delete on lib_data
    for each row execute procedure usp_lib_dataDelTrig();

create trigger lib_data_upd_tr after update on lib_data
    for each row execute procedure usp_lib_dataUpdTrig();

create table LIB_PROPERTIES (
    ITEM_ID char(36) not null,
    PROPERTY_NAME varchar(150) not null,
    PROPERTY_VALUE varchar(256) not null,
    PROPERTY_BLOB_VALUE bytea null,
    constraint FK_LIB_PROPERTIES_LIB_ITEM foreign key (ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade
);

create index LIB_PROP_IX1
    on LIB_PROPERTIES (ITEM_ID, upper(PROPERTY_NAME), upper(PROPERTY_VALUE));

create index LIB_PROPERTIES_INDEX2
    on LIB_PROPERTIES (upper(PROPERTY_NAME), upper(PROPERTY_VALUE), ITEM_ID);

create table LIB_PRINCIPAL_PROPS (
    ITEM_ID char(36) not null,
    USER_ID char(36) null,
    GROUP_ID char(36) null,
    PROPERTY_NAME varchar(150) not null,
    PROPERTY_VALUE_JSON bytea null,
    constraint FK_LPP_LIB_ITEMS foreign key (ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade,
    constraint FK_LPP_USERS foreign key (USER_ID)
        references USERS (USER_ID) on delete cascade,
    constraint FK_LPP_GROUPS foreign key (GROUP_ID)
        references GROUPS (GROUP_ID) on delete cascade
);

create unique index LPP_IDX on LIB_PRINCIPAL_PROPS (
	ITEM_ID,
	COALESCE(USER_ID, '00000000-0000-0000-0000-000000000000'),
	COALESCE(GROUP_ID, '00000000-0000-0000-0000-000000000000'),
	PROPERTY_NAME
);

create index LIB_PRINCIPAL_PROPS_IX2 on LIB_PRINCIPAL_PROPS (
  USER_ID,
  PROPERTY_NAME,
  ITEM_ID);

create index LIB_PRINCIPAL_PROPS_IX3 on LIB_PRINCIPAL_PROPS (
  GROUP_ID,
  PROPERTY_NAME,
  ITEM_ID);

alter table LIB_PRINCIPAL_PROPS add constraint LIB_PRINCIPAL_PROPS_XOR check (
  (USER_ID is null and GROUP_ID is not null)
  or
  (USER_ID is not null and GROUP_ID is null)
);

create table LIB_WORDS (
    ITEM_ID char(36) not null,
    PROPERTY varchar(150) not null,
    WORD varchar(256) not null,
    constraint FK_LIB_WORDS_LIB_ITEM foreign key (ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade
);

create index LIB_WORDS_IX1 on LIB_WORDS (ITEM_ID, upper(PROPERTY), upper(WORD));

create table LIB_ACCESS (
    ITEM_ID char(36) not null,
    USER_ID char(36) null,
    GROUP_ID char(36) null,
    PERMISSION char(1) not null,
    constraint FK_LIB_ACCESS_LIB_ITEM foreign key (ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade,
    constraint FK_LIB_ACCESS_USER foreign key (USER_ID)
        references USERS (USER_ID) on delete cascade,
    constraint FK_LIB_ACCESS_GROUPS foreign key (GROUP_ID)
        references GROUPS (GROUP_ID) on delete cascade
);

create unique index LIB_ACCESS_IDX on LIB_ACCESS (
	ITEM_ID, 
	COALESCE(USER_ID, '00000000-0000-0000-0000-000000000000'), 
	COALESCE(GROUP_ID, '00000000-0000-0000-0000-000000000000'), 
	PERMISSION
);

alter table LIB_ACCESS add constraint LIB_ACCESS_XOR check (
    (USER_ID is null and GROUP_ID is not null)
    or
    (USER_ID is not null and GROUP_ID is null)
);

create index LIB_ACCESS_INDEX1 on LIB_ACCESS (USER_ID);

create index LIB_ACCESS_INDEX2 on LIB_ACCESS (GROUP_ID);

create table LIB_RESOLVED_DEPEND (
    DEPENDENT_ID char(36) not null,
    REQUIRED_ID char(36) not null,
    DESCRIPTION varchar(1000) null,
    CASCADING_DELETE boolean not null,
    ORIGINAL_REQUIRED_ID char(36) null,
    constraint LIB_RESOLVED_DEPEND_PK primary key (DEPENDENT_ID, REQUIRED_ID),
    constraint LIB_RESOLVED_DEPEND_FK1 foreign key (DEPENDENT_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade,
    constraint LIB_RESOLVED_DEPEND_FK2 foreign key (REQUIRED_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade
);

alter table LIB_RESOLVED_DEPEND add constraint RESOLVED_DEP_NEQ_REQ
        check (DEPENDENT_ID != REQUIRED_ID);

create index LIB_RESOLVED_INDEX1 on LIB_RESOLVED_DEPEND (REQUIRED_ID);

create index LIB_RESOLVED_INDEX2 on LIB_RESOLVED_DEPEND (DEPENDENT_ID);

create table LIB_UNRESOLVED_DEPEND (
    DEPENDENT_ID char(36) not null,
    REQUIRED_ID char(36) not null,
    DESCRIPTION varchar(1000) null,
    CASCADING_DELETE boolean not null,
    ORIGINAL_REQUIRED_ID char(36) null,
    constraint LIB_UNRESOLVED_DEPEND_PK primary key (DEPENDENT_ID, REQUIRED_ID),
    constraint LIB_UNRESOLVED_DEPEND_FK1 foreign key (DEPENDENT_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade
);

alter table LIB_UNRESOLVED_DEPEND add constraint UNRESOLVED_DEP_NEQ_REQ
    check (DEPENDENT_ID != REQUIRED_ID);

create index LIB_UNRESOLVED_INDEX1 on LIB_UNRESOLVED_DEPEND (REQUIRED_ID);

create index LIB_UNRESOLVED_INDEX2 on LIB_UNRESOLVED_DEPEND (DEPENDENT_ID);

create table LIB_APPLICATIONS (
    APPLICATION_ID decimal(5) not null,
    APPLICATION_NAME varchar(256) not null,
    constraint PK_APPLICATIONS primary key (APPLICATION_ID)
);

create unique index UK_LIB_APPLICATIONS_IDX on LIB_APPLICATIONS(APPLICATION_NAME);

create table LIB_VISIBLE_TYPES (
    TYPE_ID char(36) not null,
    APPLICATION_ID decimal(5) not null,
    constraint PK_VISIBLE_TYPES primary key (TYPE_ID, APPLICATION_ID),
    constraint FK_LIB_VISIBLE_TYPES01 foreign key (TYPE_ID)
        references LIB_ITEM_TYPES (TYPE_ID) on delete cascade,
    constraint FK_LIB_VISIBLE_TYPES02 foreign key (APPLICATION_ID)
        references LIB_APPLICATIONS (APPLICATION_ID) on delete cascade
);

create or replace function usp_copyItem(
    oldId in LIB_ITEMS.ITEM_ID%type,
    newId in LIB_ITEMS.ITEM_ID%type,
    parentId in LIB_ITEMS.PARENT_ID%type,
    caller in LIB_ITEMS.MODIFIED_BY%type,
    newTitle in LIB_ITEMS.TITLE%type)
returns void as $$
declare
    timeOfUpdate timestamp(6);
begin
    select now() at time zone 'utc' into timeOfUpdate;

    if (newTitle is null) then
        insert into LIB_ITEMS (
            ITEM_ID,
            TITLE,
            DESCRIPTION,
            ITEM_TYPE,
            FORMAT_VERSION,
            CREATED_BY,
            CREATED,
            MODIFIED_BY,
            MODIFIED,
            CONTENT_SIZE,
            PARENT_ID,
            HIDDEN)
        select
            newId as ITEM_ID,
            TITLE,
            DESCRIPTION,
            ITEM_TYPE,
            FORMAT_VERSION,
            CREATED_BY,
            CREATED,
            caller as MODIFIED_BY,
            timeOfUpdate as MODIFIED,
            CONTENT_SIZE,
            parentId as PARENT_ID,
            HIDDEN
        from LIB_ITEMS original
        where original.ITEM_ID = oldId;
    else
        insert into LIB_ITEMS (
            ITEM_ID,
            TITLE,
            DESCRIPTION,
            ITEM_TYPE,
            FORMAT_VERSION,
            CREATED_BY,
            CREATED,
            MODIFIED_BY,
            MODIFIED,
            CONTENT_SIZE,
            PARENT_ID,
            HIDDEN)
        select newId as ITEM_ID,
            newTitle as TITLE,
            DESCRIPTION,
            ITEM_TYPE,
            FORMAT_VERSION,
            CREATED_BY,
            CREATED,
            caller as MODIFIED_BY,
            timeOfUpdate as MODIFIED,
            CONTENT_SIZE,
            parentId as PARENT_ID,
            HIDDEN
        from LIB_ITEMS original
        where original.ITEM_ID = oldId;
      end if;

    insert into LIB_COPY_MAPPING (ORIGINAL_ID, COPY_ID) values (oldId, newId);

end;
$$ language plpgsql;

create or replace function usp_moveItem(
    itemId LIB_ITEMS.ITEM_ID%type,
    newParentId LIB_ITEMS.PARENT_ID%type,
    caller LIB_ITEMS.MODIFIED_BY%type,
    newTitle LIB_ITEMS.TITLE%type)
returns void as $$
declare
    timeOfUpdate timestamp(6);
begin
    select now() at time zone 'utc' into timeOfUpdate;

    if (newTitle is null) then
        update LIB_ITEMS
        set
            MODIFIED_BY = caller,
            MODIFIED = timeOfUpdate,
            PARENT_ID = newParentId
        where ITEM_ID = itemId;
    else
        update LIB_ITEMS
        set
            TITLE = newTitle,
            MODIFIED_BY = caller,
            MODIFIED = timeOfUpdate,
            PARENT_ID = newParentId
        where ITEM_ID = itemId;
    end if;
end;
$$ language plpgsql;


create or replace function usp_finishCopy()
returns table(
    ITEM_ID LIB_ITEMS.ITEM_ID%type,
    TITLE LIB_ITEMS.TITLE%type ,
    DESCR LIB_ITEMS.DESCRIPTION%type,
    ITEM_TYPE LIB_ITEMS.ITEM_TYPE%type,
    FORMAT_VERSION LIB_ITEMS.FORMAT_VERSION%type,
    CREATED_BY LIB_ITEMS.CREATED_BY%type,
    CREATED LIB_ITEMS.CREATED%type,
    MODIFIED_BY LIB_ITEMS.MODIFIED_BY%type,
    MODIFIED LIB_ITEMS.MODIFIED%type,
    ACCESSED LIB_ITEMS.ACCESSED%type,
    CONTENT_SIZE LIB_ITEMS.CONTENT_SIZE%type,
    PARENT_ID LIB_ITEMS.PARENT_ID%type,
    HIDDEN LIB_ITEMS.HIDDEN%type) as $$
begin

    -- Content
    insert into LIB_DATA (
        ITEM_ID,
        CONTENT_TYPE,
        CONTENT_ENCODING,
        CHARACTER_ENCODING,
        DATA)
    select
        cm.COPY_ID as ITEM_ID,
        CONTENT_TYPE,
        CONTENT_ENCODING,
        CHARACTER_ENCODING,
        DATA
    from LIB_DATA original, LIB_COPY_MAPPING cm
    where original.ITEM_ID = cm.ORIGINAL_ID;

    -- Properties
    insert into LIB_PROPERTIES (
        ITEM_ID,
        PROPERTY_NAME,
        PROPERTY_VALUE,
        PROPERTY_BLOB_VALUE)
    select
        cm.COPY_ID as ITEM_ID,
        PROPERTY_NAME,
        PROPERTY_VALUE,
        PROPERTY_BLOB_VALUE
    from LIB_PROPERTIES original, LIB_COPY_MAPPING cm
    where original.ITEM_ID = cm.ORIGINAL_ID;

    -- Permissions
    insert into LIB_ACCESS (
        ITEM_ID,
        USER_ID,
        GROUP_ID,
        PERMISSION)
    select
        cm.COPY_ID as ITEM_ID,
        USER_ID,
        GROUP_ID,
        PERMISSION
    from LIB_ACCESS original, LIB_COPY_MAPPING cm
    where original.ITEM_ID = cm.ORIGINAL_ID;

    -- Words
    insert into LIB_WORDS (
        ITEM_ID,
        PROPERTY,
        WORD)
    select
        cm.COPY_ID as ITEM_ID,
        PROPERTY,
        WORD
    from LIB_WORDS original, LIB_COPY_MAPPING cm
    where original.ITEM_ID = cm.ORIGINAL_ID;

    -- Unresolved dependencies
    insert into LIB_UNRESOLVED_DEPEND (
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID)
    select
        cm.COPY_ID as DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID
    from LIB_UNRESOLVED_DEPEND original, LIB_COPY_MAPPING cm
    where original.DEPENDENT_ID = cm.ORIGINAL_ID;

    -- Resolved dependencies where the required items also have been copied and there is no original required ID
    insert into LIB_RESOLVED_DEPEND (
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID)
    select
        dep.COPY_ID as DEPENDENT_ID,
        req.COPY_ID as REQUIRED_ID,
        original.DESCRIPTION,
        original.CASCADING_DELETE,
        original.REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep, LIB_COPY_MAPPING req
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
        and original.REQUIRED_ID = req.ORIGINAL_ID
        and ORIGINAL_REQUIRED_ID is null;

    -- Resolved dependencies where the required items also have been copied and there is an original required ID
    insert into LIB_RESOLVED_DEPEND (
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID)
    select
        dep.COPY_ID as DEPENDENT_ID,
        req.COPY_ID as REQUIRED_ID,
        original.DESCRIPTION,
        original.CASCADING_DELETE,
        original.ORIGINAL_REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep, LIB_COPY_MAPPING req
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
        and original.REQUIRED_ID = req.ORIGINAL_ID
        and ORIGINAL_REQUIRED_ID is not null;

    -- Resolved dependencies where the required items has not been copied
    insert into LIB_RESOLVED_DEPEND (
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID)
    select
        dep.COPY_ID as DEPENDENT_ID,
        original.REQUIRED_ID,
        original.DESCRIPTION,
        original.CASCADING_DELETE,
        original.ORIGINAL_REQUIRED_ID
    from LIB_RESOLVED_DEPEND original, LIB_COPY_MAPPING dep
    where original.DEPENDENT_ID = dep.ORIGINAL_ID
        and not exists (select 1
                        from LIB_COPY_MAPPING
                        where ORIGINAL_ID = original.REQUIRED_ID);

    -- Return all copied items
    return query
        select
            i.ITEM_ID,
            i.TITLE,
            i.DESCRIPTION,
            i.ITEM_TYPE,
            i.FORMAT_VERSION,
            i.CREATED_BY,
            i.CREATED,
            i.MODIFIED_BY,
            i.MODIFIED,
            i.ACCESSED,
            i.CONTENT_SIZE,
            i.PARENT_ID,
            i.HIDDEN
        from LIB_ITEMS i, LIB_COPY_MAPPING cm
        where i.ITEM_ID = cm.COPY_ID;
end;
$$
language plpgsql;


create or replace function usp_insertDepencency(
    dependentId in LIB_RESOLVED_DEPEND.DEPENDENT_ID%type,
    requiredId in LIB_RESOLVED_DEPEND.REQUIRED_ID%type,
    description in LIB_RESOLVED_DEPEND.DESCRIPTION%type,
    cascadingDelete in LIB_RESOLVED_DEPEND.CASCADING_DELETE%type,
    originalRequiredId in LIB_RESOLVED_DEPEND.ORIGINAL_REQUIRED_ID%type)
returns void as $$
declare
  cnt decimal;
begin
    select count(*) into cnt from LIB_ITEMS where ITEM_ID = requiredId;

    if (cnt > 0) then
        insert into LIB_RESOLVED_DEPEND (
            DEPENDENT_ID,
            REQUIRED_ID,
            DESCRIPTION,
            CASCADING_DELETE,
            ORIGINAL_REQUIRED_ID)
        values (
            dependentId,
            requiredId,
            description,
            cascadingDelete,
            originalRequiredId);
    else
        insert into LIB_UNRESOLVED_DEPEND (
            DEPENDENT_ID,
            REQUIRED_ID,
            DESCRIPTION,
            CASCADING_DELETE,
            ORIGINAL_REQUIRED_ID)
        values (
            dependentId,
            requiredId,
            description,
            cascadingDelete,
            originalRequiredId);
    end if;
end;
$$
language plpgsql;

create or replace function usp_verifyAccess(
    itemId LIB_ACCESS.ITEM_ID%type,
    caller LIB_ACCESS.USER_ID%type,
    requiredPermission LIB_ACCESS.PERMISSION%type,
    administrationEnabled boolean)
returns boolean as $$
begin

    create temp table if not exists GROUP_MEMBERSHIPS
    on commit drop
    as with recursive ALL_GROUPS_CTE (GROUP_ID) as (
        select gmv.GROUP_ID
        from GROUP_MEMBERS_VIEW gmv
        where gmv.MEMBER_USER_ID = caller
        union all
        select gmv.GROUP_ID
        from GROUP_MEMBERS_VIEW gmv, ALL_GROUPS_CTE cte
        where gmv.MEMBER_GROUP_ID = cte.GROUP_ID
    ) select distinct GROUP_ID from ALL_GROUPS_CTE;

    if (administrationEnabled)
        and exists (
            select 1
            from GROUP_MEMBERSHIPS
            where GROUP_ID in (
                select GROUP_ID
                from GROUPS
                where GROUP_NAME in (N'Library Administrator', N'Administrator')
                    and DOMAIN_NAME = N'SPOTFIRE'
            )
        ) then
        return true;
    else
        return exists (
        with recursive PERMISSIONS_ON_ITEM_CTE as (
            select ITEM_ID as PARENT_ID
            from LIB_ITEMS
            where ITEM_ID = itemId
            union all
            select li.PARENT_ID
            from PERMISSIONS_ON_ITEM_CTE poi, LIB_ITEMS li
            where poi.PARENT_ID = li.ITEM_ID
            and not exists (select 1 from LIB_ACCESS acl where acl.ITEM_ID = poi.PARENT_ID)
        )
        select 1
        from LIB_ACCESS acl, PERMISSIONS_ON_ITEM_CTE cte, GROUP_MEMBERSHIPS gr
        where acl.ITEM_ID = cte.PARENT_ID
           and (acl.USER_ID = caller or acl.GROUP_ID = gr.GROUP_ID)
           and acl.PERMISSION = requiredPermission);
    end if;
end;
$$
language plpgsql;

create or replace function usp_verifyWriteOnDescendants(
    Itemid LIB_ITEMS.ITEM_ID%type,
    caller LIB_ITEMS.MODIFIED_BY%type,
    administrationEnabled boolean)
returns void as $$
declare
    descendant char(36);
    hasAccess int;
begin

    -- Determine all group memberships

    create temp table if not exists GROUP_MEMBERSHIPS
    on commit drop as
    with recursive ALL_GROUPS_CTE (GROUP_ID) as (
        select gmv.GROUP_ID
        from GROUP_MEMBERS_VIEW gmv
        where gmv.MEMBER_USER_ID = caller
        union all
        select gmv.GROUP_ID
        from GROUP_MEMBERS_VIEW gmv, ALL_GROUPS_CTE cte
        where gmv.MEMBER_GROUP_ID = cte.GROUP_ID
    ) select distinct GROUP_ID from ALL_GROUPS_CTE;

    if (administrationEnabled)
        and exists (
            select 1 from GROUP_MEMBERSHIPS
            where GROUP_ID in (
                select GROUP_ID from GROUPS
                where GROUP_NAME in (N'Library Administrator', N'Administrator')
                    and DOMAIN_NAME = N'SPOTFIRE'
            )
        ) then
        return;
    end if;

    for descendant in
        -- All parents of the item
        with recursive ITEM_PARENT_CTE (ITEM_ID, PARENT_ID) as (
            select
                ITEM_ID,
                PARENT_ID
            from LIB_ITEMS
            where ITEM_ID = itemId
            union all
            select
                li.ITEM_ID,
                li.PARENT_ID
            from LIB_ITEMS li, ITEM_PARENT_CTE cte
            where li.PARENT_ID = cte.ITEM_ID
        )
        select PARENT_ID from ITEM_PARENT_CTE
    loop
        hasAccess := 0;

        with recursive PERMISSIONS_ON_ITEM_CTE as (
            select ITEM_ID as PARENT_ID
            from LIB_ITEMS
            where ITEM_ID = descendant
            union all
            select i.PARENT_ID
            from PERMISSIONS_ON_ITEM_CTE poi, LIB_ITEMS i
            where poi.PARENT_ID = i.ITEM_ID
                and not exists (select 1 from LIB_ACCESS acl where acl.ITEM_ID = poi.PARENT_ID)
        )
        select 1 into hasAccess
        from LIB_ACCESS acl, PERMISSIONS_ON_ITEM_CTE apa, GROUP_MEMBERSHIPS gr
        where acl.ITEM_ID = apa.PARENT_ID
            and (acl.USER_ID = caller or acl.GROUP_ID = gr.GROUP_ID)
            and acl.PERMISSION = 'W';

        if (hasAccess is null) then
            raise exception 'ERR-10002 - Insufficient access';
        end if;

    end loop;

end;
$$
language plpgsql;

create or replace function usp_insertItem(
    newItemId  LIB_ITEMS.ITEM_ID%type,
    newTitle  LIB_ITEMS.TITLE%type,
    newDescription  LIB_ITEMS.DESCRIPTION%type,
    newItemType  LIB_ITEMS.ITEM_TYPE%type,
    newFormatVersion  LIB_ITEMS.FORMAT_VERSION%type,
    newContentSize  LIB_ITEMS.CONTENT_SIZE%type,
    newParentId  LIB_ITEMS.PARENT_ID%type,
    newHidden  LIB_ITEMS.HIDDEN%type,
    caller  LIB_ITEMS.CREATED_BY%type,
    verifyAccess  boolean,
    administrationEnabled  boolean)
returns void as $$
declare
    hasAccess boolean;
    timeOfInsertion timestamp(6);
    cnt bigint;
    isContainer char(1);
    dirDepth int;
begin

    select count(1) into cnt from LIB_ITEMS where ITEM_ID = newParentId;
    if (cnt = 0) then
        raise exception 'ERR-10005 - Parent item % does not exist', newParentId;
    end if;

    -- Verify that the parent is a container item
    select it.IS_CONTAINER
    into isContainer
    from LIB_ITEM_TYPES it, LIB_ITEMS i
    where i.ITEM_TYPE = it.TYPE_ID
        and i.ITEM_ID = newParentId;

    if (isContainer = '0') then
        raise exception 'ERR-10004 - Invalid parent item';
    end if;

    -- Verify access
    if (verifyAccess) then
        select *
        from usp_verifyAccess(newParentId, caller, 'W', administrationEnabled)
        into hasAccess;

        if (hasAccess = false) then
            raise exception 'ERR-10002 - Insufficient access';
        end if;
    end if;

    -- Verify that the ID is unique
    select count(1)
    into cnt
    from LIB_ITEMS
    where ITEM_ID = newItemId;

    if (cnt > 0) then
        raise exception 'ERR-10001 - Item already exists';
    end if;

    -- Verify that the title-type-parent combination is unique
    select count(1)
    into cnt
    from LIB_ITEMS
    where upper(TITLE) = upper(newTitle)
        and ITEM_TYPE = newItemType
        and PARENT_ID = newParentId;

    if (cnt > 0) then
        raise exception 'ERR-10001 - Item already exists';
    end if;

    -- Verify that the maximum folder depth is not exceeded
    with recursive CTE (LVL, ITEM_ID) as (
        select
            1 as LVL,
            PARENT_ID
        from LIB_ITEMS
        where ITEM_ID = newParentId
        union all
        select
            c.LVL + 1,
            i.PARENT_ID
        from LIB_ITEMS i, CTE c
        where c.ITEM_ID = i.ITEM_ID
    )
    select max(LVL)
    from CTE
    into dirDepth;

    if (dirDepth > 99) then
        raise exception 'ERR-10003 - Maximum folder depth exceeded. Maximum allowed is 100.';
    end if;

    -- Store the current timestamp
    select now() at time zone 'utc' into timeOfInsertion;

    -- Insert the item
    insert into LIB_ITEMS (
        ITEM_ID,
        TITLE,
        DESCRIPTION,
        ITEM_TYPE,
        FORMAT_VERSION,
        CREATED_BY,
        CREATED,
        MODIFIED_BY,
        MODIFIED,
        CONTENT_SIZE,
        PARENT_ID,
        HIDDEN)
    values (
        newItemId,
        newTitle,
        newDescription,
        newItemType,
        newFormatVersion,
        caller,
        timeOfInsertion,
        caller,
        timeOfInsertion,
        newContentSize,
        newParentId,
        newHidden);

    -- Move any unresolved dependencies upon the inserted item into the set of resolved dependencies
    insert into LIB_RESOLVED_DEPEND (
          DEPENDENT_ID,
          REQUIRED_ID,
          DESCRIPTION,
          CASCADING_DELETE,
          ORIGINAL_REQUIRED_ID)
    (select
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID
    from LIB_UNRESOLVED_DEPEND
    where REQUIRED_ID = newItemId);

    delete from LIB_UNRESOLVED_DEPEND
    where REQUIRED_ID = newItemId;

end;
$$
language plpgsql;

create or replace function usp_updateItem(
    itemId LIB_ITEMS.ITEM_ID%type,
    newTitle LIB_ITEMS.TITLE%type,
    newDescription LIB_ITEMS.DESCRIPTION%type,
    newFormatVersion LIB_ITEMS.FORMAT_VERSION%type,
    newHidden LIB_ITEMS.HIDDEN%type,
    caller LIB_ITEMS.MODIFIED_BY%type,
    verifyAccess boolean,
    administrationEnabled boolean)
returns void as $$
declare
    parentId char(36);
    itemType char(36);
    hasAccess boolean;
    contentSize decimal;
    timeOfUpdate timestamp(6);
    cnt decimal;
begin
    -- Verify that the item exists
    select count(1) into cnt from LIB_ITEMS where ITEM_ID = itemId;
    if (cnt = 0) then
        raise exception 'ERR-10005 - Item does not exist';
    end if;

    -- Fetch and store the parent ID, the item type and the current timestamp
    select
        PARENT_ID,
        ITEM_TYPE,
        now() at time zone 'utc'
    into
        parentId,
        itemType,
        timeOfUpdate
    from LIB_ITEMS
    where ITEM_ID = itemId;

    -- Fetch the content size, if present (0 otherwise)
    select count(1)
    into cnt
    from LIB_DATA
    where LIB_DATA.ITEM_ID = itemId;

    if (cnt = 1) then
        select octet_length(lo_get(DATA))
        into contentSize
        from LIB_DATA
        where LIB_DATA.ITEM_ID = itemId;
    else
        contentSize := 0;
    end if;

    -- Verify access
    if (verifyAccess) then
        select * from usp_verifyAccess(parentId, caller, 'W', administrationEnabled)
        into hasAccess;

        if (hasAccess = false) then
            raise exception 'ERR-10002 - Insufficient access';
        end if;
    end if;

    -- Verify that the title-type-parent combination is unique
    select count(1)
    into cnt
    from LIB_ITEMS
    where upper(TITLE) = upper(newTitle)
        and ITEM_TYPE = itemType
        and PARENT_ID = parentId
        and ITEM_ID != itemId;

    if (cnt > 0) then
        raise exception 'ERR-10001 - Item already exists';
    end if;

    -- Update the item
    update LIB_ITEMS
    set
        TITLE = newTitle,
        DESCRIPTION = newDescription,
        FORMAT_VERSION = newFormatVersion,
        MODIFIED_BY = caller,
        MODIFIED = timeOfUpdate,
        CONTENT_SIZE = contentSize,
        HIDDEN = newHidden
    where ITEM_ID = itemId;

 end;
$$
language plpgsql;

create or replace function usp_updateExternallyStoredItem(
    itemId LIB_ITEMS.ITEM_ID%type,
    newTitle LIB_ITEMS.TITLE%type,
    newDescription LIB_ITEMS.DESCRIPTION%type,
    newFormatVersion LIB_ITEMS.FORMAT_VERSION%type,
    newHidden LIB_ITEMS.HIDDEN%type,
    caller LIB_ITEMS.MODIFIED_BY%type,
    verifyAccess boolean,
    administrationEnabled boolean,
    contentSize in out decimal) AS $$
declare
    parentId char(36);
    itemType char(36);
    hasAccess boolean;
    timeOfUpdate timestamp(6);
    cnt decimal;
begin
    -- Verify that the item exists
    select count(1) into cnt from LIB_ITEMS where ITEM_ID = itemId;
    if (cnt = 0) then
        raise exception 'ERR-10005 - Item does not exist';
    end if;

    -- Fetch and store the parent ID, the item type and the current timestamp
    select
        PARENT_ID,
        ITEM_TYPE,
        now() at time zone 'utc'
    into
        parentId,
        itemType,
        timeOfUpdate
    from LIB_ITEMS
    where ITEM_ID = itemId;

    -- Verify access
    if (verifyAccess) then
        select * from usp_verifyAccess(parentId, caller, 'W', administrationEnabled)
        into hasAccess;

        if (hasAccess = false) then
            raise exception 'ERR-10002 - Insufficient access';
        end if;
    end if;

    -- Verify that the title-type-parent combination is unique
    select count(1)
    into cnt
    from LIB_ITEMS
    where upper(TITLE) = upper(newTitle)
        and ITEM_TYPE = itemType
        and PARENT_ID = parentId
        and ITEM_ID != itemId;

    if (cnt > 0) then
        raise exception 'ERR-10001 - Item already exists';
    end if;

    -- Update the item
    if (contentSize = 0) then
        update LIB_ITEMS
        set
            TITLE = newTitle,
            DESCRIPTION = newDescription,
            FORMAT_VERSION = newFormatVersion,
             MODIFIED_BY = caller,
             MODIFIED = timeOfUpdate,
             HIDDEN = newHidden
         where ITEM_ID = itemId;
    else
        update LIB_ITEMS
        set
            TITLE = newTitle,
            DESCRIPTION = newDescription,
            FORMAT_VERSION = newFormatVersion,
            MODIFIED_BY = caller,
            MODIFIED = timeOfUpdate,
            CONTENT_SIZE = contentSize,
            HIDDEN = newHidden
        where ITEM_ID = itemId;
    end if;
end;
$$
language plpgsql;

-- Stored procedure used for deleting items
create or replace function usp_deleteItem(
    itemId LIB_ITEMS.ITEM_ID%type,
    caller LIB_ITEMS.MODIFIED_BY%type,
    verifyAccess boolean,
    administrationEnabled boolean,
    allowUnresolvedDependencies boolean)
returns void as $$
declare
    dependentItem char(36);
    cnt decimal;
    parentId LIB_ITEMS.PARENT_ID%type;
    timeOfDeletion LIB_ITEMS.MODIFIED%type;
begin
    -- If the item has already been deleted there is nothing more to do
    select count(1)
    into cnt
    from LIB_ITEMS
    where ITEM_ID = itemId;
    if (cnt = 0) then
        return;
    end if;

    -- Verify access
    if (verifyAccess) then
        perform usp_verifyWriteOnDescendants(itemId, caller, administrationEnabled);
    end if;

    -- Fetch the parent ID and verify that it's not null (cannot delete the root item)
    select
        PARENT_ID,
        (select now() at time zone 'utc')
    into parentId, timeOfDeletion
    from LIB_ITEMS
    where ITEM_ID = itemId;

    if (parentId is null) then
        raise exception 'ERR-10004 - Cannot delete the root item';
    end if;

    -- Fetch all descendants
    insert into LIB_TEMP_DESCENDANTS (
        ANCESTOR_ID,
        DESCENDANT_ID)
    with recursive cte (ITEM_ID, PARENT_ID) as (
        select
            ITEM_ID,
            PARENT_ID
        from LIB_ITEMS
        where ITEM_ID = itemId
        union all
        select item.ITEM_ID, item.PARENT_ID
        from LIB_ITEMS item, cte parent
        where item.PARENT_ID = parent.ITEM_ID
      ) select itemId, ITEM_ID from cte;

    -- If creating dangling references is disallowed we need to verify that no dependencies upon the items
    -- being deleted exists.
    if (allowUnresolvedDependencies = false) then
        select count(1)
        into cnt
        from LIB_RESOLVED_DEPEND rd, LIB_TEMP_DESCENDANTS ds
        where rd.CASCADING_DELETE = '0'
            and rd.REQUIRED_ID = ds.DESCENDANT_ID
            and ds.ANCESTOR_ID = itemId;

        if (cnt > 0) then
            raise exception 'ERR-10006 - Dependencies without cascading delete found';
        end if;
    end if;

    -- Move any dependency declarations, with non-cascading delete, upon the item being deleted
    -- and all of its descendants from the set of resolved dependencies to the set of unresolved
    -- dependencies.
    insert into LIB_UNRESOLVED_DEPEND (
        DEPENDENT_ID,
        REQUIRED_ID,
        DESCRIPTION,
        CASCADING_DELETE,
        ORIGINAL_REQUIRED_ID)
    (select
        rd.DEPENDENT_ID,
        rd.REQUIRED_ID,
        rd.DESCRIPTION,
        rd.CASCADING_DELETE,
        rd.ORIGINAL_REQUIRED_ID
    from LIB_RESOLVED_DEPEND rd, LIB_TEMP_DESCENDANTS ds
    where rd.CASCADING_DELETE = '0'
        and rd.REQUIRED_ID = ds.DESCENDANT_ID
        and ds.ANCESTOR_ID = itemId
    );

    -- Delete all dependent items with cascading delete
    for dependentItem in
        select DEPENDENT_ID
        from LIB_RESOLVED_DEPEND
        where CASCADING_DELETE = '1'
            and REQUIRED_ID in (
                select DESCENDANT_ID
                from LIB_TEMP_DESCENDANTS
                where ANCESTOR_ID = itemId)
        except (
            select DESCENDANT_ID
            from LIB_TEMP_DESCENDANTS
            where ANCESTOR_ID = itemId)
    loop
        perform usp_deleteItem(dependentItem, caller, verifyAccess, administrationEnabled, allowUnresolvedDependencies);
    end loop;

    -- Delete all declarations of depencencies upon the item and all of its descendants
    delete from LIB_RESOLVED_DEPEND
    where REQUIRED_ID in (
        select DESCENDANT_ID
        from LIB_TEMP_DESCENDANTS
        where ANCESTOR_ID = itemId);

    -- Delete the item itself and any descendants
    delete from LIB_ITEMS
    where ITEM_ID in (
        select DESCENDANT_ID
        from LIB_TEMP_DESCENDANTS
        where ANCESTOR_ID = itemId);

    -- Touch the parent
    update LIB_ITEMS
    set
        MODIFIED_BY = caller,
        MODIFIED = timeOfDeletion
    where ITEM_ID = parentId;

end;
$$
language plpgsql;

create or replace function usp_finishDelete()
returns setof char as $$
begin
    return query select DESCENDANT_ID from LIB_TEMP_DESCENDANTS;
    drop table LIB_TEMP_DESCENDANTS;
end;
$$
language plpgsql;


/* ----------------- JMX --------------------- */

create table JMX_USERS (
    USER_NAME varchar(200) not null,
    PASSWORD_HASH varchar(150) not null,
    ACCESS_LEVEL varchar(20) not null,
    constraint JMX_USERS_PK primary key (USER_NAME)
);

/* ------------------ nodes ------------------ */

create table SITES (
    SITE_ID char(36) not null,
    NAME varchar(200) not null,
    PROPERTIES_JSON bytea null,
    constraint PK_SITES primary key (SITE_ID)
);

create unique index SITES_NAME_INDEX on SITES(upper(NAME));

create table NODES(
    ID char(36) not null,
    DEPLOYMENT_AREA char(36),
    IS_ONLINE smallint,
    PLATFORM varchar(36),
    PORT varchar(5) not null,
    CLEAR_TEXT_PORT varchar(5) default 0,
    PRIMUS_CAPABLE smallint,
    BUNDLE_VERSION varchar(200),
    PRODUCT_VERSION varchar(200),
    SITE_ID char(36) not null,
    constraint PK_NODES primary key (ID),
    constraint FK_NODES_SITE_ID foreign key (SITE_ID) references SITES (SITE_ID)
);

alter table NODES add constraint FK_NODES_AREA_ID foreign key (DEPLOYMENT_AREA)
    references DEP_AREAS_DEF(AREA_ID) on delete set null;

create index NODES_PRIMUS_CAPABLE on NODES (PRIMUS_CAPABLE);

create index NODES_PRIMUS_CAPABLE_ONLINE on NODES (PRIMUS_CAPABLE, IS_ONLINE);

create index NODES_ONLINE on NODES (IS_ONLINE);

create index NODES_SITES on NODES (SITE_ID);

create table NODE_SERVER_INFO(
    NODE_ID char(36) not null,
    SERVERNAME varchar(200) not null,
    PRIORITY smallint
);

alter table NODE_SERVER_INFO add constraint FK_NODE_SERVER_INFO_ID_NODES foreign key(NODE_ID)
    references NODES(ID) on delete cascade;

create index NODE_SERVER_INFO_NODE_ID on NODE_SERVER_INFO (NODE_ID);

create index NODE_SERVER_INFO_ID_PRIO on NODE_SERVER_INFO (NODE_ID, PRIORITY);

/* ----------------- server life cycle events --------------------- */

create table LIFECYCLE_EVENTS (
    SERVER_NAME varchar(250) not null,
    SERVER_IP varchar(100) not null,
    SERVER_VERSION varchar(250) not null,
    EVENT_DATE timestamp(0) not null,
    EVENT_NAME varchar(250) not null,
    IS_PRIMUS boolean not null,
    IS_SITE_PRIMUS boolean not null,
    NODE_ID char(36) null,
    constraint PK_LIFECYCLE_EVENTS primary key ( EVENT_NAME, EVENT_DATE, SERVER_NAME ),
    constraint FK_LIFECYCLE_EVENTS_NODE_ID foreign key (NODE_ID) references NODES (ID) on delete set null
);

create index LIFECYCLE_EVENTS_PRIMUS on LIFECYCLE_EVENTS (IS_PRIMUS);

create index LIFECYCLE_EVENTS_SITE_PRIMUS on LIFECYCLE_EVENTS (IS_SITE_PRIMUS);

create index LIFECYCLE_EVENTS_EVENT_NAME on LIFECYCLE_EVENTS (EVENT_NAME);

create index LIFECYCLE_EVENT_NODE_EVENT on LIFECYCLE_EVENTS (NODE_ID, EVENT_NAME);

/* ------------------ types of services provided by the node manager ------------------ */

create table NODE_SERVICE_TYPES(
    ID smallint not null,
    SERVICE_TYPE char(36),
    constraint PK_NODE_SERVICE_TYPES primary key (ID)
);

/* ------------------ services managed by the node manager ------------------ */

create table NODE_SERVICES(
    ID char(36) not null,
    NODE_ID char(36) not null,
    SERVICE_TYPE smallint not null,
    SERVICENAME varchar(200) not null,
    SERVICEVERSION varchar(100) not null,
    WORKING_DIR varchar(255),
    CAPABILITIES varchar(200) not null,
    EXTERNALLY_MANAGED smallint null,
    EXTERNALLY_STARTED smallint null,
    ON_STOP_STATUS varchar(36) not null,
    RESTART_ON_STOP varchar(36) not null,
    SERVICE_MANAGER varchar(200),
    STARTUP_COMMAND varchar(255),
    DEPLOYMENT_AREA char(36),
    REPLACED_BY_ID char(36),
    STATUS varchar(36) not null,
    NEXT_STATUS varchar(36) not null,
    URL varchar(200) null,
    BUNDLE_VERSION varchar(200),
    VERSIONHASH varchar(64),
    TECHVERSION varchar(64),
    constraint PK_NODE_SERVICES primary key(ID)
);

alter table NODE_SERVICES add constraint FK_NODE_SERVICES_AREA_ID foreign key(DEPLOYMENT_AREA)
    references DEP_AREAS_DEF(AREA_ID) on delete set null;

create table NODE_SERVICES_PKGS (
    ID char(36) not null,
    SERVICE_ID char(36) not null,
    PACKAGE_ID char(36) not null,
    NAME varchar(200) not null,
    VERSION varchar(32) not null,
    INTENDED_CLIENT varchar(32) not null,
    INTENDED_PLATFORM varchar(32) not null,
    LAST_MODIFIED timestamp default CURRENT_TIMESTAMP,
    constraint PK_NODE_SERVICES_PKGS primary key(ID)
);

alter table NODE_SERVICES_PKGS add constraint FK_NSPKGS_NODE_SERVICES_ID foreign key(SERVICE_ID)
    references NODE_SERVICES(ID) on delete cascade;

create table SERVICE_CONFIGS (
    CONFIG_ID char(36) not null,
    CONFIG_NAME varchar(200) not null,
    CAPABILITY varchar(200) not null,
    PKG_ID char(36) not null,
    PKG_VERSION varchar(32) not null,
    IS_DEFAULT boolean not null,
    MODIFICATION_DATE timestamp(0) not null,
    DATA bytea not null,
    CONFIG_VERSION varchar(50) default '1' not null,
    constraint PK_SERVICE_CONFIGS primary key (CONFIG_ID)
);

create unique index SERVICE_CONFIGS_CONFIG_NAME_IX on SERVICE_CONFIGS (CONFIG_NAME);

create table ACTIVE_SERVICE_CONFIGS (
    SERVICE_ID char(36) not null,
    CONFIG_ID char(36) not null,
    CONFIG_VERSION varchar(50) default '1' not null,
    constraint PK_ACTIVE_SERVICE_CONFIGS primary key (SERVICE_ID, CONFIG_ID),
    constraint FK_A_S_C_SERVICE_ID foreign key (SERVICE_ID)
        references NODE_SERVICES (ID) on delete cascade,
    constraint FK_A_S_C_CONFIG_ID foreign key (CONFIG_ID)
        references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
);

create table SITE_SERVICE_CONFIGS (
    SITE_ID char(36) not null,
    CAPABILITY varchar(200) not null,
    CONFIG_ID char(36) not null,
    constraint PK_SITE_SERVICE_CONFIGS primary key (CAPABILITY),
    constraint FK_SSC_SITE_ID foreign key (SITE_ID)
        references SITES (SITE_ID) on delete cascade,
    constraint FK_SSC_CONFIG_ID foreign key (CONFIG_ID)
        references SERVICE_CONFIGS (CONFIG_ID) on delete cascade
);

alter table NODE_SERVICES add constraint FK_NODE_ID_NODES foreign key(NODE_ID)
    references NODES(ID) on delete cascade;

alter table NODE_SERVICES add constraint FK_SERVICE_TYPE_NODE_SVCS_TYPE foreign key(SERVICE_TYPE)
    references NODE_SERVICE_TYPES(ID);

create index NODE_SERVICES_NODE_ID on NODE_SERVICES (NODE_ID);

create index NODE_SERVICES_N_ID_W_DIR_TYPE on NODE_SERVICES (NODE_ID,WORKING_DIR,SERVICE_TYPE);

create index NODE_SERVICES_N_ID_W_DIR on NODE_SERVICES (NODE_ID,WORKING_DIR);

create index NODE_SERVICES_N_ID_TYPE on NODE_SERVICES (NODE_ID,SERVICE_TYPE);

create index NODE_SERVICES_TYPE_REPLACED on NODE_SERVICES (SERVICE_TYPE, REPLACED_BY_ID);

create table NODE_AUTH_REQUEST(
    ID char(36) not null,
    CSR bytea not null,
    LAST_MODIFIED timestamp null,
    FINGERPRINT varchar(128) null,
    constraint PK_NODE_AUTH_REQUEST primary key(ID)
);

alter table NODE_AUTH_REQUEST add constraint FK_ID_NODES foreign key(ID)
    references NODES(ID) on delete cascade;

create table NODE_EVENT_BUS(
    ID char(36) not null,
    NODE_ID char(36) not null,
    COMMAND_ID char(36) not null,
    USER_ID char(36) default null,
    EVENT_TYPE smallint not null,
    EVENT_SUB_TYPE char(36) not null,
    EVENT_DATA text,
    LAST_MODIFIED timestamp default current_timestamp,
    constraint PK_NODE_EVENT_BUS primary key(ID)
);

alter table NODE_EVENT_BUS add constraint FK_NODE_ID_EVENT_BUS foreign key(NODE_ID)
    references NODES(ID) on delete cascade;

alter table NODE_EVENT_BUS add constraint FK_USERS_ID_EVENT_BUS foreign key(USER_ID)
    references USERS(USER_ID) on delete set null;

create index NODE_EVENT_BUS_NODE_IDX on NODE_EVENT_BUS (NODE_ID);

create index NODE_EVENT_BUS_COMMAND_IDX on NODE_EVENT_BUS (COMMAND_ID);

create index NODE_EVENT_BUS_INDEX_CID on NODE_EVENT_BUS (COMMAND_ID,LAST_MODIFIED);

create index NODE_EVENT_BUS_INDEX_NID on NODE_EVENT_BUS (NODE_ID,LAST_MODIFIED);

create index NODE_EVENT_BUS_INDEX_NID_EST on NODE_EVENT_BUS (COMMAND_ID,EVENT_SUB_TYPE,LAST_MODIFIED);

create index NODE_EVENT_BUS_COMMAND_TYPE on NODE_EVENT_BUS (COMMAND_ID, EVENT_TYPE);

create index NODE_EVENT_BUS_N_E_STYPE on NODE_EVENT_BUS (NODE_ID, EVENT_SUB_TYPE);

create table NODE_STATUS (
    ID char(36) not null,
    FROM_ID char(36) not null,
    TO_ID char(36) not null,
    SERVICE_ID char(36) default null,
    CAN_COMMUNICATE smallint default 0,
    STATUS_CODE smallint,
    MESSAGE varchar(1000),
    SINCE timestamp default CURRENT_TIMESTAMP,
    LAST_MODIFIED timestamp default CURRENT_TIMESTAMP,
    constraint PK_NODE_STATUS primary key(ID)
);

alter table NODE_STATUS add constraint FK_FROM_ID_NODE_STATUS foreign key(FROM_ID)
    references NODES(ID) on delete cascade;


alter table NODE_STATUS add constraint FK_TO_ID_NODE_STATUS foreign key(TO_ID)
    references NODES(ID) on delete cascade;


alter table NODE_STATUS add constraint FK_SERVICE_ID_NODE_STATUS foreign key(SERVICE_ID)
    references NODE_SERVICES(ID) on delete cascade;

create index NODE_STATUS_INDEX_TO_ID on NODE_STATUS (TO_ID);

create index NODE_STATUS_INDEX_FROM_ID on NODE_STATUS (FROM_ID);

create index NODE_STATUS_TO_SERVICE on NODE_STATUS (TO_ID, SERVICE_ID);

create index NODE_STATUS_TO_FROM on NODE_STATUS (TO_ID, FROM_ID);

create index NODE_STATUS_INDEX_SERVICE_ID on NODE_STATUS (SERVICE_ID);

create index NODE_STATUS_IDX_TO_FROM_SRVC on NODE_STATUS (TO_ID,FROM_ID,SERVICE_ID);

create unique index NODE_STATUS_ITEM on NODE_STATUS (
  FROM_ID, TO_ID, COALESCE(SERVICE_ID, '00000000-0000-0000-0000-000000000000')
);


create table CERTIFICATES (
    SERIAL_NUMBER varchar(40) not null,
    NODE_ID char(36) null,
    SUBJECT_DN varchar(400) not null,
    STATUS varchar(10) not null,
    EXPIRATION_DATE timestamp null,
    REVOCATION_DATE timestamp null,
    KEYSTORE bytea null,
    constraint CERTIFICATES_PK primary key (SERIAL_NUMBER)
);

alter table CERTIFICATES add constraint FK_CERTIFICATES_NODE_ID_NODES foreign key(NODE_ID) references NODES(ID) on delete set null;


create index CERTIFICATES_STATUS on CERTIFICATES (NODE_ID,STATUS);

/* ------------------ Code Trust ------------------ */

create table KEYSTORE_PASSWORDS (
  KEYSTORE varchar(40) not null,
  PASSWORD varchar(400) not null,
  constraint KEYSTORE_PASSWORDS_PK primary key (KEYSTORE)
);

create table CT_CERTS (
  USER_ID char(36) null,
  SERIAL_NUMBER varchar(40) not null,
  SUBJECT_DN varchar(400) not null,
  STATUS varchar(10) not null,
  VALID_FROM timestamp null,
  EXPIRATION_DATE timestamp null,
  REVOCATION_DATE timestamp null,
  KEYSTORE bytea null,
  constraint CT_CERTS_PK primary key (SERIAL_NUMBER),
  constraint FK_CT_CERTS_USER foreign key (USER_ID)
    references USERS (USER_ID) on delete set null
);

create index CT_CERTS_USER_IDX
  on CT_CERTS (USER_ID);

create index CT_CERTS_SERIAL_NUMBER_IDX 
  on CT_CERTS (SERIAL_NUMBER);

create table CT_EXTCERTS (
  ISSUER varchar(400) not null,
  SERIAL_NUMBER varchar(40) not null,
  SUBJECT_DN varchar(400) not null,
  STATUS varchar(10) not null,
  ADDED_DATE timestamp null,
  KEYSTORE bytea null,
  constraint CT_EXTCERTS_PK primary key (ISSUER, SERIAL_NUMBER)
);

create table CT_CODE_ENTITIES (
  TYPE varchar(60) not null,
  HASH varchar(180) not null,
  STATUS varchar(10) not null,
  ADDED_DATE timestamp null,
  METADATA_JSON bytea not null,
  constraint CT_CODE_ENTITIES_PK primary key (TYPE, HASH)
);

create table TRUSTED_CODE_ENTITIES (
  TRUSTED_TYPE varchar(60) not null,
  TRUSTED_HASH varchar(180) not null,
  TRUSTING_USER_ID char(36) null,
  TRUSTING_GROUP_ID char(36) null,
  ADDED_DATE timestamp null,
  USED_DATE timestamp null,
  constraint FK_TRUSTED_CODE_ENTITIES1 foreign key (TRUSTED_TYPE, TRUSTED_HASH)
    references CT_CODE_ENTITIES (TYPE, HASH) on delete cascade,
  constraint FK_TRUSTED_CODE_ENTITIES2 foreign key (TRUSTING_USER_ID)
    references USERS (USER_ID) on delete cascade,
  constraint FK_TRUSTED_CODE_ENTITIES3 foreign key (TRUSTING_GROUP_ID)
    references GROUPS (GROUP_ID) on delete cascade
);

create unique index TRUSTED_CODE_ENTITIES_IX on TRUSTED_CODE_ENTITIES (
  TRUSTED_TYPE,
  TRUSTED_HASH,
  COALESCE(TRUSTING_USER_ID, ''),
  COALESCE(TRUSTING_GROUP_ID, '')
);

create index TRUSTED_CODE_ENTITIES_IDX1
  on TRUSTED_CODE_ENTITIES (TRUSTING_USER_ID);

create index TRUSTED_CODE_ENTITIES_IDX2
  on TRUSTED_CODE_ENTITIES (TRUSTING_GROUP_ID);

alter table TRUSTED_CODE_ENTITIES add constraint TRUSTED_CODE_ENTITIES_XOR check (
  (TRUSTING_USER_ID is null and TRUSTING_GROUP_ID is not null)
  or
  (TRUSTING_USER_ID is not null and TRUSTING_GROUP_ID is null)
);

create table TRUSTED_CERTS (
  TRUSTED_ISSUER varchar(400) not null,
  TRUSTED_SERIAL_NUMBER varchar(40) not null,
  TRUSTING_USER_ID char(36) null,
  TRUSTING_GROUP_ID char(36) null,
  ADDED_DATE timestamp null,
  USED_DATE timestamp null,
  constraint FK_TRUSTED_CERTS1 foreign key (TRUSTED_ISSUER, TRUSTED_SERIAL_NUMBER)
    references CT_EXTCERTS (ISSUER, SERIAL_NUMBER) on delete cascade,
  constraint FK_TRUSTED_CERTS2 foreign key (TRUSTING_USER_ID)
    references USERS (USER_ID) on delete cascade,
  constraint FK_TRUSTED_CERTS3 foreign key (TRUSTING_GROUP_ID)
    references GROUPS (GROUP_ID) on delete cascade
);

create unique index TRUSTED_CERTS_IX on TRUSTED_CERTS (
  TRUSTED_ISSUER,
  TRUSTED_SERIAL_NUMBER,
  COALESCE(TRUSTING_USER_ID, ''),
  COALESCE(TRUSTING_GROUP_ID, '')
);

alter table TRUSTED_CERTS add constraint TRUSTED_CERTS_XOR check (
  (TRUSTING_USER_ID is null and TRUSTING_GROUP_ID is not null)
  or
  (TRUSTING_USER_ID is not null and TRUSTING_GROUP_ID is null)
);

create table TRUSTED_USERS (
  TRUSTED_USER_ID char(36) not null,
  TRUSTING_USER_ID char(36) null,
  TRUSTING_GROUP_ID char(36) null,
  constraint FK_TRUSTED_USERS1 foreign key (TRUSTED_USER_ID)
    references USERS (USER_ID) on delete cascade,
  constraint FK_TRUSTED_USERS2 foreign key (TRUSTING_USER_ID)
    references USERS (USER_ID) on delete cascade,
  constraint FK_TRUSTED_USERS3 foreign key (TRUSTING_GROUP_ID)
    references GROUPS (GROUP_ID) on delete cascade
);

alter table TRUSTED_USERS add constraint TRUSTED_USERS_XOR check (
  (TRUSTING_USER_ID is null and TRUSTING_GROUP_ID is not null)
  or
  (TRUSTING_USER_ID is not null and TRUSTING_GROUP_ID is null)
);

create unique index TRUSTED_USERS_IX on TRUSTED_USERS (
  TRUSTED_USER_ID,
  COALESCE(TRUSTING_USER_ID, ''),
  COALESCE(TRUSTING_GROUP_ID, '')
);

create table CT_THIRD_PARTY_ROOTCERTS (
  ISSUER varchar(400) not null,
  SERIAL_NUMBER varchar(40) not null,
  SUBJECT_DN varchar(400) not null,
  ADDED_DATE timestamp null,
  KEYSTORE bytea null,
  constraint THIRD_PARTY_ROOTCERTS_PK primary key (ISSUER, SERIAL_NUMBER)
);

create index TRUSTED_USERS_IX1 on TRUSTED_USERS (TRUSTING_GROUP_ID);

create index TRUSTED_USERS_IX2 on TRUSTED_USERS (TRUSTING_USER_ID);

create index TRUSTED_CERTS_IX1 on TRUSTED_CERTS (TRUSTING_GROUP_ID);

create index TRUSTED_CERTS_IX2 on TRUSTED_CERTS (TRUSTING_USER_ID);

create table CT_BLOCKED_USERS (
  USER_ID char(36) not null,
  BLOCKED_DATE timestamp not null,
  constraint CT_BLOCKED_USERS_PK primary key (USER_ID),
  constraint FK_CT_BLOCKED_USERS foreign key (USER_ID)
    references USERS (USER_ID) on delete cascade
);

/* ------------------ OAuth2 Authorization Server ------------------ */

create table OAUTH2_CLIENTS (
    CLIENT_ID varchar(100) not null,
    JSON bytea not null,
    constraint OAUTH2_CLIENTS_PK primary key (CLIENT_ID)
);

create table OAUTH2_AUTH_CODES (
    CODE varchar(200) not null,
    EXPIRES_AT timestamp(0) not null,
    JSON bytea not null,
    constraint OAUTH2_AUTH_CODES_PK primary key (CODE)
);

create table OAUTH2_ACCESS_TOKENS (
    ACCESS_TOKEN varchar(200) not null,
    ACCESS_TOKEN_EXP_AT timestamp(0) not null,
    JSON bytea not null,
    constraint OAUTH2_ACCESS_TOKENS_PK primary key (ACCESS_TOKEN)
);

create table OAUTH2_REFRESH_TOKENS (
    REFRESH_TOKEN varchar(200) not null,
    REFRESH_TOKEN_EXP_AT timestamp(0) not null,
    USER_ID char(36) not null,
    CLIENT_ID varchar(100) not null,
    JSON bytea not null,
    constraint OAUTH2_REFRESH_TOKENS_PK primary key (REFRESH_TOKEN),
    constraint OAUTH2_REFRESH_TOKENS_FK1 foreign key (USER_ID) references USERS (USER_ID) on delete cascade,
    constraint OAUTH2_REFRESH_TOKENS_FK2 foreign key (CLIENT_ID) references OAUTH2_CLIENTS (CLIENT_ID) on delete cascade
);

create index REFRESH_TOKENS_IX1 on OAUTH2_REFRESH_TOKENS (USER_ID);

create index REFRESH_TOKENS_IX2 on OAUTH2_REFRESH_TOKENS (CLIENT_ID);

create table OAUTH2_KEYS (
    KEY_ID varchar(200) not null,
    EXP_AT timestamp(0) not null,
    REV_AT timestamp(0) null,
    JSON bytea not null,
    constraint OAUTH2_KEYS_PK primary key (KEY_ID)
);

create table OAUTH2_CONSENT (
    USER_ID char(36) not null,
    CLIENT_ID varchar(100) not null,
    JSON bytea not null,
    constraint OAUTH2_CONSENT_PK primary key (USER_ID, CLIENT_ID),
    constraint OAUTH2_CONSENT_FK1 foreign key (USER_ID) references USERS (USER_ID) on delete cascade,
    constraint OAUTH2_CONSENT_FK2 foreign key (CLIENT_ID) references OAUTH2_CLIENTS (CLIENT_ID) on delete cascade
);

create index OAUTH2_CONSENT_IX1 on OAUTH2_CONSENT (USER_ID);

create index OAUTH2_CONSENT_IX2 on OAUTH2_CONSENT (CLIENT_ID);


/* ------------------ static routing tables ------------------ */

create table ROUTING_RULES (
    ID char(36) not null,
    NAME varchar(256) not null,
    ENTITY_VALUE text null,
    ENTITY_TYPE smallint null,
    LIB_ITEM_ID char(36) null,
    GROUP_ID char(36) null,
    USER_ID char(36) null,
    RESOURCE_POOL_ID char(36) null,
    SITE_ID char(36) null,
    PRIORITY integer not null,
    STATUS smallint not null,
    TYPE char(1) DEFAULT('R') not null,
    LAST_MODIFIED timestamp null,
    LAST_MODIFIED_BY char(36) null,
    SCHEDULING_STATUS smallint null,
    SCHEDULED_BY_NODE char(36) null,
    CAPABILITY varchar(200),
    constraint PK_ROUTING_RULES primary key (ID),
    constraint ROUTING_RULES_UC1 unique(PRIORITY, SITE_ID) DEFERRABLE INITIALLY IMMEDIATE
);

create index ROUTING_RULES_SITES on ROUTING_RULES (SITE_ID);

create index IX_RR_RESOURCE_POOL_ID on ROUTING_RULES (RESOURCE_POOL_ID);

create index IX_ROUTING_RULES_TYPE on ROUTING_RULES (TYPE);

create index IX_RR_TYPE_SITE on ROUTING_RULES (TYPE, SITE_ID);

create index IX_RR_TYPE_SITE_STATUS on ROUTING_RULES (TYPE, SITE_ID, STATUS);

create index IX_RR_SITE_CAPABILITY on ROUTING_RULES (SITE_ID, CAPABILITY);

create index IX_RR_TYPE_CA on ROUTING_RULES (TYPE, CAPABILITY);

create index IX_RR_TYPE_SITE_CA on ROUTING_RULES (TYPE, SITE_ID, CAPABILITY);

create index IX_RR_TYPE_SITE_ENTITY_CA on ROUTING_RULES (TYPE, SITE_ID, ENTITY_TYPE, CAPABILITY);

create index IX_RR_TYPE_SITE_STATUS_CA on ROUTING_RULES (TYPE, SITE_ID, STATUS, CAPABILITY);

create index IX_ROUTING_RULES_ITEM_CA on ROUTING_RULES (TYPE, SITE_ID, ENTITY_TYPE, STATUS, CAPABILITY);

create table SERVICE_ATTRIBUTES(
    ID char(36) not null,
    ATTRIBUTE_TYPE varchar(64) not null,
    ATTRIBUTE_KEY varchar(32),
    VALUE varchar(256) not null,
    constraint PK_SERVICE_ATTRIBUTES primary key (ID)
);

create index SERVICE_ATTRIBUTES_TYPE_IDX on SERVICE_ATTRIBUTES (ATTRIBUTE_TYPE);

create index SERVICE_ATTRIBUTES_T_VAL_IDX on SERVICE_ATTRIBUTES (ATTRIBUTE_TYPE, VALUE);

create table NODE_SERVICES_ATTRIBUTES(
    ATTRIBUTE_ID char(36) not null,
    SERVICE_ID char(36) not null,
    constraint PK_NODE_SERVICES_ATTRIBUTES primary key (ATTRIBUTE_ID, SERVICE_ID)
);

create table RESOURCE_POOLS(
    ID char(36) not null,
    NAME varchar(256) not null,
    SITE_ID char(36) not null,
    constraint PK_RESOURCE_POOLS primary key (ID),
    constraint RESOURCE_POOLS_UC1 unique (NAME, SITE_ID),
    constraint FK_RESOURCE_POOLS_SITES foreign key (SITE_ID) references SITES(SITE_ID)
);

create index RESOURCE_POOLS_SITES on RESOURCE_POOLS (SITE_ID);

create table NODE_SERVICES_RESOURCE_POOLS(
    SERVICE_ID char(36) not null,
    RESOURCE_POOL_ID char(36) not null,
    constraint PK_NODES_RESOURCE_POOLS primary key (SERVICE_ID, RESOURCE_POOL_ID),
    constraint FK_NSRP_NS foreign key (SERVICE_ID) references NODE_SERVICES (ID) on delete cascade,
    constraint FK_NSRP_RP foreign key (RESOURCE_POOL_ID) references RESOURCE_POOLS (ID) on delete cascade
);

create index IX_NSRP_SERVICE_ID on NODE_SERVICES_RESOURCE_POOLS (SERVICE_ID);

create index IX_NSRP_RESOURCE_POOL_ID on NODE_SERVICES_RESOURCE_POOLS (RESOURCE_POOL_ID);

alter table ROUTING_RULES add constraint FK_ROUT_RULES_LIB_ITEMS foreign key(LIB_ITEM_ID)
    references LIB_ITEMS(ITEM_ID) on delete set null;

alter table ROUTING_RULES add constraint FK_ROUT_RULES_GROUPS foreign key(GROUP_ID)
    references GROUPS(GROUP_ID) on delete set null;

alter table ROUTING_RULES add constraint FK_ROUT_RULES_USERS foreign key(USER_ID)
    references USERS(USER_ID) on delete set null;

alter table ROUTING_RULES add constraint FK_ROUT_RULES_RES_POOLS foreign key(RESOURCE_POOL_ID)
    references RESOURCE_POOLS(ID);

ALTER TABLE ROUTING_RULES ADD CONSTRAINT FK_ROUTING_RULES_SITE_ID FOREIGN KEY (SITE_ID)
    REFERENCES SITES(SITE_ID);

alter table ROUTING_RULES add constraint ROUTING_RULES_STATUS check (
    (STATUS = 0)
    or
    (STATUS = 1)
    or
    (STATUS = 2)
    or
    (STATUS = 3)
);

alter table ROUTING_RULES add constraint ROUTING_RULES_TYPES check (
    (TYPE = 'R')
    or
    (TYPE = 'D')
);

alter table NODE_SERVICES_ATTRIBUTES add constraint FK_NSA_SA foreign key(ATTRIBUTE_ID)
    references SERVICE_ATTRIBUTES (ID) on delete cascade;

alter table NODE_SERVICES_ATTRIBUTES  add constraint FK_NSA_NS foreign key(SERVICE_ID)
    references NODE_SERVICES (ID) on delete cascade;

create or replace function routingRules_updatePriority(
    ruleId ROUTING_RULES.ID%type,
    newPriority integer)
returns void as $$
declare
    direction char(4);
    siteId char(36);
begin

    select
        case
            when newPriority > PRIORITY then 'DOWN'
            else 'UP'
        end
    into direction
    from ROUTING_RULES
    where ID = ruleId;

    select SITE_ID
    into siteId
    from ROUTING_RULES
    where ID = ruleId;

    update ROUTING_RULES R
    set
        PRIORITY = -1 + (
            select NEW_PRIORITY from (
            select
                ID,
                row_number()
            over (
                order by
                    case
                        when type = 'R' then
                            case
                                when STATUS <> 2 then 'A'
                                else 'B'
                            end
                        else 'C'
                    end,
                    case
                        when ID = ruleId then newPriority
                        when PRIORITY < newPriority then PRIORITY - 1
                        when PRIORITY = newPriority and direction = 'DOWN' then PRIORITY - 1
                        when PRIORITY = newPriority and direction = 'UP' then PRIORITY + 1
                        when PRIORITY >= newPriority then PRIORITY + 1
                    end
                asc)
            as NEW_PRIORITY
            from ROUTING_RULES
            where SITE_ID = siteId) U
        where U.ID = R.ID)
    where R.SITE_ID = siteId;
end;
$$
language plpgsql;

create or replace function routingRules_deleteRule(
    ruleId ROUTING_RULES.ID%type)
returns void as $$
declare
    siteId char(36);
begin

    select SITE_ID
    into siteId
    from ROUTING_RULES
    where ID = ruleId;

    -- delete
    delete from ROUTING_RULES
    where ID = ruleId;

    -- update priority
    update ROUTING_RULES R
    set PRIORITY = -1 + (
        select NEW_PRIORITY
        from (
            select
                ID,
                row_number()
            over (
                order by
                case
                    when type = 'R' then
                        case
                            when status <> 2 then 'A'
                            else 'B'
                        end
                    else 'C'
                end,
                PRIORITY) NEW_PRIORITY
            from ROUTING_RULES
            where SITE_ID = siteId) U
        where U.ID = R.ID)
    where R.SITE_ID = siteId;

end;
$$
language plpgsql;

create or replace function usp_findRoutingRules(
    current_user_id USERS.USER_ID%type,
    current_library_item_id LIB_ITEMS.ITEM_ID%type,
    current_site_id SITES.SITE_ID%type)
returns table(
    ID ROUTING_RULES.ID%type,
    NAME ROUTING_RULES.NAME%type,
    LIB_ITEM_ID ROUTING_RULES.LIB_ITEM_ID%type,
    GROUP_ID ROUTING_RULES.GROUP_ID%type,
    USER_ID ROUTING_RULES.USER_ID%type,
    RESOURCE_POOL_ID ROUTING_RULES.RESOURCE_POOL_ID%type,
    PRIORITY ROUTING_RULES.PRIORITY%type,
    STATUS ROUTING_RULES.STATUS%type,
    TYPE ROUTING_RULES.TYPE%type) as $$
begin
    if (current_user_id is null or current_site_id is null) then
        raise exception 'Invalid arguments: user_id or site_id can not be null.';
    end if;
    return query
        with recursive ALL_USER_GROUPS (GROUP_ID) as (
            select gm.GROUP_ID
            from GROUP_MEMBERS_VIEW gm
            where gm.MEMBER_USER_ID = coalesce(current_user_id,'')
            union all
            select gm.GROUP_ID
            from GROUP_MEMBERS_VIEW gm, ALL_USER_GROUPS cte
            where cte.GROUP_ID = gm.MEMBER_GROUP_ID
        ),
        ALL_PARENTS (ITEM_ID) as (
            select PARENT_ID from LIB_ITEMS
            WHERE ITEM_ID = coalesce(current_library_item_id,'')
            union all
            select items.PARENT_ID
            from LIB_ITEMS items, ALL_PARENTS cte
            where items.ITEM_ID = cte.ITEM_ID
        )
        select
            rules.ID,
            rules.NAME,
            rules.LIB_ITEM_ID,
            rules.GROUP_ID,
            rules.USER_ID,
            rules.RESOURCE_POOL_ID,
            rules.PRIORITY,
            rules.STATUS,
            rules.TYPE
        from ROUTING_RULES rules
        left join ALL_PARENTS parents on rules.LIB_ITEM_ID = parents.ITEM_ID
        left join ALL_USER_GROUPS groups on rules.GROUP_ID = groups.GROUP_ID
        where rules.STATUS = 1
            and rules.SITE_ID = current_site_id
            and((coalesce(rules.LIB_ITEM_ID,'') <> '' and rules.LIB_ITEM_ID = coalesce(current_library_item_id,'')) --direct match
                or (coalesce(rules.LIB_ITEM_ID,'') <> '' and coalesce(parents.ITEM_ID,'') <> '') --parent folder match
                or (coalesce(rules.GROUP_ID, '') <> '' and coalesce(groups.GROUP_ID, '') <> '') --group match
                or (coalesce(rules.USER_ID, '') = current_user_id) --user match
                or rules.TYPE = 'D' --default rules
            )
        order by rules.PRIORITY asc;
end;
$$
language plpgsql;

create or replace function usp_recalculateRulePriorities(
    siteId in SITES.SITE_ID%type)
returns void as $$
begin

    -- update priorities: first scheduled updates, then everything else
    update ROUTING_RULES R
    set PRIORITY = -1 + (
        select NEW_PRIORITY
        from (
            select ID, row_number()
            over(
                order by
                    case
                        when TYPE = 'R' then
                            case
                                when CAPABILITY='"WEB_PLAYER"' then 'A'
                                else 'B'
                            end
                        else 'C'
                    end,
                PRIORITY
            ) NEW_PRIORITY
        from ROUTING_RULES) U
    where U.ID = R.ID);
end;
$$
language plpgsql;


/* ------------------ scheduler schema ------------------ */

create table JOB_SCHEDULES (
    ID char(36) not null,
    NAME varchar(32) null,
    START_TIME decimal(19) null,
    END_TIME decimal(19) null,
    WEEK_DAYS varchar(200) null,
    LAST_MODIFIED timestamp null,
    LAST_MODIFIED_BY char(36) null,
    IS_JOB_SPECIFIC boolean null,
    RELOAD_FREQUENCY smallint null,
    RELOAD_UNIT varchar(16) null,
    TIMEZONE varchar(64) null,
    SITE_ID char(36) null,
    SCHEDULE_TYPE smallint default 0 not null,
    EXPRESSION varchar(128) null,
    constraint PK_JOB_SCHEDULES primary key (ID),
    constraint FK_JOB_SCHEDULES_SITE_ID foreign key (SITE_ID) references SITES(SITE_ID)
);

create index JOB_SCHEDULES_SITES on JOB_SCHEDULES (SITE_ID);

create table SCHEDULED_UPDATES_SETTINGS (
    ROUTING_RULE_ID char(36) not null,
    INSTANCES_COUNT smallint null,
    CLIENT_UPDATE_MODE varchar(32) null,
    ALLOW_CACHED_DATA boolean null,
    PRECOMPUTE_RELATIONS boolean null,
    PRECOMPUTE_VISUALIZATIONS boolean null,
    PRECOMPUTE_ACTIVE_PAGE boolean null,
    constraint PK_SCHEDULED_UPDATES_SETTINGS primary key (ROUTING_RULE_ID)
);

create table RULES_SCHEDULES (
    ROUTING_RULE_ID char(36) not null,
    SCHEDULE_ID char(36) not null,
    constraint PK_RULES_SCHEDULES primary key (ROUTING_RULE_ID, SCHEDULE_ID)
);

create table JOB_INSTANCES (
    INSTANCE_ID char(36) not null,
    TYPE char(1) default('S') not null,
    STATUS smallint null,
    CREATED timestamp null,
    LAST_MODIFIED timestamp null,
    NEXT_FIRE_TIME decimal(19) null,
    ROUTING_RULE_ID char(36) null,
    LIB_ITEM_ID char(36) null,
    SCHEDULE_ID char(36) null,
    SITE_ID char(36) null,
    JOB_CONTENT text null,
    ERROR_MESSAGE varchar(1024) null,
    EXECUTION_TYPE smallint null,
    EXECUTED_BY char(36) null,
    constraint PK_JOB_INSTANCES primary key (INSTANCE_ID),
    constraint FK_JI_LI foreign key (LIB_ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete set null,
    constraint FK_JI_U foreign key (EXECUTED_BY)
        references USERS (USER_ID) on delete set null
);

alter table JOB_INSTANCES add constraint JOB_INSTANCES_TYPES check (
    (TYPE = 'S')
    or
    (TYPE = 'A')
);

alter table JOB_INSTANCES add constraint FK_JOB_INSTANCES_SCHEDULES
    foreign key(SCHEDULE_ID) references JOB_SCHEDULES (ID);

create index JOB_INSTANCES_RULE_IDX on JOB_INSTANCES (ROUTING_RULE_ID);

create index JOB_INSTANCES_STATUS_IDX on JOB_INSTANCES (STATUS);

create index JOB_INSTANCES_TYPE_STATUS_IDX on JOB_INSTANCES (TYPE, EXECUTION_TYPE, STATUS);

create index JOB_INSTANCES_TYPE_IDX on JOB_INSTANCES (TYPE);

create index JOB_INSTANCES_TYPE_STAT_IDX on JOB_INSTANCES (TYPE, STATUS);

create index JOB_INSTANCES_SITES on JOB_INSTANCES (SITE_ID);

create index JOB_INSTANCES_LIB_IDX on JOB_INSTANCES (LIB_ITEM_ID);

create index JOB_INSTANCES_USER_IDX on JOB_INSTANCES (EXECUTED_BY);

create table JOBS_LATEST (
    INSTANCE_ID char(36) not null,
    LIB_ITEM_ID char(36) not null,
    constraint PK_JOBS_LATEST primary key (LIB_ITEM_ID),
    constraint FK_JL_JI foreign key (INSTANCE_ID)
        references JOB_INSTANCES (INSTANCE_ID) on delete cascade,
    constraint FK_JL_LI foreign key (LIB_ITEM_ID)
        references LIB_ITEMS (ITEM_ID) on delete cascade
);

create index JOBS_LATEST_JOB_IDX on JOBS_LATEST (INSTANCE_ID);

create table JOB_TASKS (
    TASK_ID char(36) not null,
    JOB_ID char(36) not null,
    STATUS smallint null,
    MESSAGE varchar(1024) null,
    TASK_EXTERNAL_ID varchar(36) null,
    SERVICE_ID char(36) null,
    DESTINATION varchar(512) null,
    CREATED timestamp null,
    LAST_MODIFIED timestamp null,
    constraint PK_JOB_TASKS primary key (TASK_ID)
);

create index JOB_TASKS_JOB_ID_IDX on JOB_TASKS (JOB_ID);

alter table SCHEDULED_UPDATES_SETTINGS add constraint FK_SUS_RR foreign key(ROUTING_RULE_ID) references ROUTING_RULES (ID) on delete cascade;

alter table RULES_SCHEDULES add constraint FK_RS_RR foreign key(ROUTING_RULE_ID) references ROUTING_RULES (ID) on delete cascade;

alter table RULES_SCHEDULES add constraint FK_RS_JS foreign KEY(SCHEDULE_ID) references JOB_SCHEDULES (ID) on delete cascade;

alter table JOB_INSTANCES add constraint FK_JOBS_ROUTING_RULES foreign key(ROUTING_RULE_ID) references ROUTING_RULES (ID) on delete set null;

alter table JOB_INSTANCES add constraint FK_JOB_INSTANCES_SITE_ID FOREIGN KEY (SITE_ID) REFERENCES SITES (SITE_ID);
alter table JOB_TASKS  add  constraint FK_JOB_TASKS_JOBS foreign key(JOB_ID) references JOB_INSTANCES (INSTANCE_ID) on delete cascade;

create view JOB_INSTANCES_DETAIL_VIEW as
select
    JOB.INSTANCE_ID,
    JOB.TYPE,
    JOB.STATUS,
    JOB.CREATED,
    JOB.LAST_MODIFIED,
    JOB.ROUTING_RULE_ID,
    JOB.JOB_CONTENT,
    JOB.ERROR_MESSAGE,
    JOB.EXECUTION_TYPE,
    JOB.SITE_ID,
    ROUTING_RULES.NAME,
    coalesce(U.TOTAL_TASKS_COUNT,0) TOTAL_TASKS_COUNT,
    coalesce(U.COMPLETED_TASKS_COUNT,0) COMPLETED_TASKS_COUNT,
    coalesce(U.FAILED_TASKS_COUNT,0) FAILED_TASKS_COUNT,
    coalesce(U.IN_PROGRESS_TASKS_COUNT,0) IN_PROGRESS_TASKS_COUNT
from JOB_INSTANCES JOB
left join ROUTING_RULES on JOB.ROUTING_RULE_ID = ROUTING_RULES.ID
left join (
    select
        JOB_ID,
        count(*) AS TOTAL_TASKS_COUNT,
        sum(case when STATUS = 5 THEN 1 ELSE 0 END) AS COMPLETED_TASKS_COUNT,
        sum(case when STATUS = 3 OR STATUS = 2 THEN 1 ELSE 0 END) AS FAILED_TASKS_COUNT,
        sum(case when STATUS = 1 THEN 1 ELSE 0 END) AS IN_PROGRESS_TASKS_COUNT
    from JOB_TASKS
    group by JOB_ID
) U on JOB.INSTANCE_ID = U.JOB_ID;

create view RESOURCE_POOLS_SERVICES_VIEW as
with A as (
    select
        NSRP.SERVICE_ID,
        RP.ID as RESOURCE_POOL_ID,
        RP.NAME as RESOURCE_POOL_NAME
    from NODE_SERVICES_RESOURCE_POOLS NSRP
    inner join RESOURCE_POOLS RP on NSRP.RESOURCE_POOL_ID = RP.ID
),
B as (
    select
        NS.ID,
        NS.SERVICE_TYPE,
        NS.NODE_ID,
        NS.WORKING_DIR,
        NS.URL,
        NS.CAPABILITIES,
        A.RESOURCE_POOL_ID,
        A.RESOURCE_POOL_NAME,
        NS.DEPLOYMENT_AREA,
        NS.STATUS
    from NODE_SERVICES NS
    left join A on NS.ID = A.SERVICE_ID
    where NS.CAPABILITIES like '%WEB_PLAYER%'
)
select
    B.ID,
    B.SERVICE_TYPE,
    B.NODE_ID,
    B.WORKING_DIR,
    B.URL,
    B.CAPABILITIES,
    B.RESOURCE_POOL_ID,
    B.RESOURCE_POOL_NAME,
    B.DEPLOYMENT_AREA,
    B.STATUS,
    DAD.DEP_AREA_NAME,
    NSI.SERVERNAME,
    N.SITE_ID
from B
left join DEP_AREAS_DEF DAD on B.DEPLOYMENT_AREA = DAD.AREA_ID
inner join NODES N on B.NODE_ID = N.ID
inner join NODE_SERVER_INFO NSI on NSI.NODE_ID = N.ID and NSI.PRIORITY = 1;

/* ----------------- Persistent Sessions (remember me) --------------------- */

create table PERSISTENT_SESSIONS (
    SESSION_ID varchar(100) not null,
    USER_ID char(36) not null,
    TOKEN_HASH varchar(150) not null,
    VALID_UNTIL timestamp not null,
    constraint PERSISTENT_SESSIONS_PK primary key (SESSION_ID),
    constraint FK_USERS_USER_ID foreign key (USER_ID)
        references USERS (USER_ID) on delete cascade
);

/* ----------------- Invitations  --------------------- */

create table INVITES (
    SENDER_ID char(36) not null,
    ITEM_ID char(36) not null,
    INVITE_TOKEN varchar(200) not null,
    CREATED timestamp(0) not null,
    EMAIL varchar(255) not null,
    constraint PK_INVITES primary key (SENDER_ID, ITEM_ID, EMAIL),
    constraint FK_INVITES_USERS foreign key (SENDER_ID) references USERS (USER_ID) on delete cascade,
    constraint FK_INVITES_LIB_ITEMS foreign key (ITEM_ID) references LIB_ITEMS (ITEM_ID) on delete cascade
);

create index INVITES_ITEM_ID_IDX on INVITES (ITEM_ID);

/* ----------------- Additional indices on FK constraints --------------------- */

create index ACTIVE_SERVICE_CFG_CFG_ID_IDX on ACTIVE_SERVICE_CONFIGS (CONFIG_ID);

create index CUSTOM_LIC_GROUP_ID_IDX on CUSTOMIZED_LICENSES (GROUP_ID);

create index CUSTOM_LIC_LIC_NAME_IDX on CUSTOMIZED_LICENSES (LICENSE_NAME);

create index DEP_AREAS_DISTRIBUTION_ID_IDX on DEP_AREAS (DISTRIBUTION_ID);

create index DEP_DISTR_CONT_DISTR_ID_IDX on DEP_DISTRIBUTION_CONTENTS (DISTRIBUTION_ID);

create index EXCLUDED_FUNC_LIC_FUNC_ID_IDX on EXCLUDED_FUNCTIONS (LICENSE_FUNCTION_ID);

create index JOB_INSTANCES_SCHEDULE_ID_IDX on JOB_INSTANCES (SCHEDULE_ID);

create index LIB_DATA_CHAR_ENCODING_IDX on LIB_DATA (CHARACTER_ENCODING);

create index LIB_DATA_CONTENT_TYPE_IDX on LIB_DATA (CONTENT_TYPE);

create index LIB_DATA_CONTENT_ENCODING_IDX on LIB_DATA (CONTENT_ENCODING);

create index LIB_VISIBLE_TYPES_APP_ID_IDX on LIB_VISIBLE_TYPES (APPLICATION_ID);

create index LIC_FUNC_LIC_NAME_IDX on LICENSE_FUNCTIONS (LICENSE_NAME);

create index LIC_ORIGIN_PACKAGE_ID_IDX on LICENSE_ORIGIN (PACKAGE_ID);

create index LIC_ORIGIN_LIC_FUNCTION_ID_IDX on LICENSE_ORIGIN (LICENSE_FUNCTION_ID);

create index NODE_EVENT_BUS_USER_ID_IDX on NODE_EVENT_BUS (USER_ID);

create index NODE_SERVICES_DEPL_AREA_IDX on NODE_SERVICES (DEPLOYMENT_AREA);

create index NODE_SERVICES_ATTR_SRV_ID_IDX on NODE_SERVICES_ATTRIBUTES (SERVICE_ID);

create index NODE_SERVICES_PKGS_SRV_ID_IDX on NODE_SERVICES_PKGS (SERVICE_ID);

create index NODES_DEPLOYMENT_AREA_IDX on NODES (DEPLOYMENT_AREA);

create index PRSTNT_SESSIONS_USER_ID_IDX on PERSISTENT_SESSIONS (USER_ID);

create index PREF_OBJECTS_GROUP_ID_IDX on PREFERENCE_OBJECTS (GROUP_ID);

create index PREF_OBJECTS_USER_ID_IDX on PREFERENCE_OBJECTS (USER_ID);

create index PREF_VALUES_PREFERENCE_ID_IDX on PREFERENCE_VALUES (PREFERENCE_ID);

create index PREF_VALUES_USER_ID_IDX on PREFERENCE_VALUES (USER_ID);

create index ROUTING_RULES_GROUP_ID_IDX on ROUTING_RULES (GROUP_ID);

create index ROUTING_RULES_LIB_ITEM_ID_IDX on ROUTING_RULES (LIB_ITEM_ID);

create index ROUTING_RULES_USER_ID_IDX on ROUTING_RULES (USER_ID);

create index RULES_SCHD_SCHEDULE_ID_IDX on RULES_SCHEDULES (SCHEDULE_ID);

create index SITE_SRV_CONF_CONFIG_ID_IDX on SITE_SERVICE_CONFIGS (CONFIG_ID);

create index SITE_SRV_CONF_SITE_ID_IDX on SITE_SERVICE_CONFIGS (SITE_ID);

