/*
 * Copyright (c) 2018-2019 Spotfire AB,
 * Första Långgatan 26, SE-413 28 Göteborg, Sweden.
 * All rights reserved.
 *
 * This software is the confidential and proprietary information
 * of Spotfire AB ("Confidential Information"). You shall not
 * disclose such Confidential Information and may not use it in any way,
 * absent an express written license agreement between you and Spotfire AB
 * or TIBCO Software Inc. that authorizes such use.
 */

-- ================================
--  Report errors
-- ================================

\set ON_ERROR_STOP on

-- ================================
--	Insert Base Data
-- ================================

insert into SN_VERSION (SPOTFIRE_VERSION, SCHEMA_VERSION) values ('61.0', '409');

-- Special groups
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('19e7e430-9997-11da-fbc4-0010ac110215', 'Everyone', 'SPOTFIRE', 'Everyone', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('fed6b2b0-a9e1-11da-8ed2-0010ac110222', 'Administrator', 'SPOTFIRE', 'Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('a92097e0-07a7-11db-fd44-0010c0a8019b', 'Library Administrator', 'SPOTFIRE', 'Library Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('96b90a10-1d4d-11de-283a-00100a64216b', 'Scheduled Updates Users', 'SPOTFIRE', 'Scheduled Updates Users', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('5071c63a-b6ca-4f37-aeee-b141be843dda', 'Deployment Administrator', 'SPOTFIRE', 'Deployment Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('5bd69e2b-6685-4dd6-9858-8990c46c522b', 'Diagnostics Administrator', 'SPOTFIRE', 'Diagnostics Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('4dd3fc65-c727-474b-976c-96b807f36bd6', 'Web Player Administrator', 'SPOTFIRE', 'Web Player Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('5f1879fa-2cca-4d03-b47b-ef03e55d927e', 'Scheduling and Routing Administrator', 'SPOTFIRE', 'Scheduling and Routing Administrator', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('6c677f0f-3cbe-4615-85be-8366c7ce3181', 'Script Author', 'SPOTFIRE', 'Script Author', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('2cbe823f-1507-4b56-a822-621f431ee061', 'Custom Query Author', 'SPOTFIRE', 'Custom Query Author', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('3bf79f12-1842-41d5-9002-fa1d70ce071c', 'Anonymous User', 'SPOTFIRE', 'Anonymous User', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('5a544e10-f305-408b-ae0c-a602eec4ed4f', 'System Account', 'SPOTFIRE', 'System Account', false);
insert into GROUPS (GROUP_ID, GROUP_NAME, DOMAIN_NAME, DISPLAY_NAME, CONNECTED)
  values ('6dc28196-994b-45a9-a289-ac1b9dca9208', 'Automation Services Users', 'SPOTFIRE', 'Automation Services Users', false);
insert into GROUP_MEMBERS (GROUP_ID) values ('19e7e430-9997-11da-fbc4-0010ac110215');

-- Create the ANONYMOUS\guest account for use with Anonymous Authentication (disabled by default)
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) 
  values ('6679bcea-758d-4b72-8d50-32dfa6621239', 'guest', 'ANONYMOUS', 'Guest', false);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) 
  values ('3bf79f12-1842-41d5-9002-fa1d70ce071c', '6679bcea-758d-4b72-8d50-32dfa6621239');

-- Create the System Accounts
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) values 
  ('be1277ba-3c2d-4bbb-b4c5-8096c4961e51','nodemanager','SPOTFIRESYSTEM', 'Node Manager System Account', true);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('5a544e10-f305-408b-ae0c-a602eec4ed4f', 'be1277ba-3c2d-4bbb-b4c5-8096c4961e51');
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) values 
  ('3ab9a272-8803-4a2c-85f1-95d9916c9f4c','scheduledupdates','SPOTFIRESYSTEM', 'Scheduled Updates System Account', true);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('5a544e10-f305-408b-ae0c-a602eec4ed4f', '3ab9a272-8803-4a2c-85f1-95d9916c9f4c');
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('96b90a10-1d4d-11de-283a-00100a64216b', '3ab9a272-8803-4a2c-85f1-95d9916c9f4c');
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) values 
  ('2e738d87-8a69-4e08-b899-ed30acb2ad9c','sbdfcache','SPOTFIRESYSTEM', 'SBDF Cache System Account', true);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('5a544e10-f305-408b-ae0c-a602eec4ed4f', '2e738d87-8a69-4e08-b899-ed30acb2ad9c');
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) values 
  ('341b1e0c-6943-4292-b96a-60de220c0186','monitoring','SPOTFIRESYSTEM', 'Monitoring System Account', true);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('5a544e10-f305-408b-ae0c-a602eec4ed4f', '341b1e0c-6943-4292-b96a-60de220c0186');
insert into USERS (USER_ID, USER_NAME, DOMAIN_NAME, DISPLAY_NAME, ENABLED) values 
  ('ba65162e-4958-4fa8-a744-87e003770944','automationservices','SPOTFIRESYSTEM', 'Automation Services System Account', true);
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('5a544e10-f305-408b-ae0c-a602eec4ed4f', 'ba65162e-4958-4fa8-a744-87e003770944');
insert into GROUP_MEMBERS (GROUP_ID, MEMBER_USER_ID) values 
  ('6dc28196-994b-45a9-a289-ac1b9dca9208', 'ba65162e-4958-4fa8-a744-87e003770944');

-- Deployment areas
insert into DEP_AREAS_DEF (AREA_ID, DEP_AREA_NAME, IS_DEFAULT_AREA) 
	values ('2d71f811-19f6-f4ac-c985-3da501193f54','Production', '1');

-- Item type constants
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd41-71b5-11dd-050e-00100a64217d', 'folder', 'spotfire', 'folder', 1, null, null);

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd43-71b5-11dd-050e-00100a64217d', 'analysis', 'spotfire', 'analysis', 0, null, 'application/spotfire.sfs');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd44-71b5-11dd-050e-00100a64217d', 'poster', 'spotfire', 'poster', 0, null, 'application/spotfire.sfp');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd45-71b5-11dd-050e-00100a64217d', 'guide', 'spotfire', 'guide', 0, null, 'application/spotfire.sfg');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd46-71b5-11dd-050e-00100a64217d', 'custom', 'spotfire', 'custom', 0, null, 'application/octet-stream');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('4f83cd47-71b5-11dd-050e-00100a64217d', 'dxp', 'spotfire', 'dxp', 1, 'dxp', 'application/vnd.spotfire.dxp');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('aec78e32-b5f7-48d6-99ae-97f931202497', 'column', 'spotfire', 'column', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 'filter', 'spotfire', 'filter', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('947059cf-b48b-4245-8547-316621e15cc3', 'join', 'spotfire', 'join', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 'procedure', 'spotfire', 'procedure', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('783545a2-514f-4c90-acee-649e2df362f0', 'query', 'spotfire', 'query', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 'datasource', 'spotfire', 'datasource', 0, null, 'application/xml');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('04a1dc4d-6794-4c49-b91b-063de8a77450', 'analysisstate', 'spotfire', 'analysisstate', 0, null, 'application/octet-stream');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('587870d1-ffc4-4ad7-9dd0-533f14414a58', 'task', 'spotfire', 'task', 0, null, 'text/xml');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 'bookmark', 'spotfire', 'Bookmark', 0, null, 'application/octet-stream');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 'embeddedresource', 'spotfire', 'Embedded Resource', 0, null, 'application/octet-stream');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 'analyticitem', 'spotfire', 'Analytic Item', 0, null, 'application/octet-stream');  
	
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 'datafunction', 'spotfire', 'Data Function', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 'dxpscript', 'spotfire', 'Analysis Script', 0, 'dxpscript', 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
	values ('9ca21d20-b598-11de-5915-00100a64216c', 'colorscheme', 'spotfire', 'Color Scheme', 0, 'dxpcolor', 'application/xml');
	
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 'connectiondatasource', 'spotfire', 'Connection Data Source', 0, null, 'application/xml');
insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 'dataconnection', 'spotfire', 'Data Connection', 0, null, 'application/xml');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 'sbdf', 'spotfire', 'Spotfire Binary Data Format', 0, 'sbdf', 'application/octet-stream');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 'analyticmodel', 'spotfire', 'Analytic Model', 0, 'rds', 'application/xml');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE) 
  values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 'asjob', 'spotfire', 'Automation Job', 0, 'asjob', 'application/xml');

insert into LIB_ITEM_TYPES (TYPE_ID, LABEL, LABEL_PREFIX, DISPLAY_NAME, IS_CONTAINER, FILE_SUFFIX, MIME_TYPE)
  values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 'mod', 'spotfire', 'Mod', 0, 'mod', 'application/octet-stream');

-- Library content type constants
insert into LIB_CONTENT_TYPES values (1, 'text/xml');
insert into LIB_CONTENT_TYPES values (2, 'application/octet-stream');
insert into LIB_CONTENT_TYPES values (3, 'application/xml');
insert into LIB_CONTENT_TYPES values (4, 'application/spotfire.sfs');
insert into LIB_CONTENT_TYPES values (5, 'application/spotfire.sfg');
insert into LIB_CONTENT_TYPES values (6, 'application/spotfire.sfp');
insert into LIB_CONTENT_TYPES values (7, 'application/vnd.spotfire.dxp');

-- Library content encoding constants
insert into LIB_CONTENT_ENCODINGS values (1, 'none');
insert into LIB_CONTENT_ENCODINGS values (2, 'gzip');

-- Library character encoding constants
insert into LIB_CHARACTER_ENCODINGS values (1, 'utf-8');

-- Library root item
insert into LIB_ITEMS values ('6b67ec30-712e-11dd-7434-00100a64217d', 'root', null, '4f83cd41-71b5-11dd-050e-00100a64217d', '11.0', null, CURRENT_TIMESTAMP, null, CURRENT_TIMESTAMP, null, 0, null, '0');

-- Give the Everyone group read and execute permissions on the root by default
insert into LIB_ACCESS values ('6b67ec30-712e-11dd-7434-00100a64217d', null, '19e7e430-9997-11da-fbc4-0010ac110215', 'R');
insert into LIB_ACCESS values ('6b67ec30-712e-11dd-7434-00100a64217d', null, '19e7e430-9997-11da-fbc4-0010ac110215', 'X');

-- RelatedItems library hidden folder
insert into LIB_ITEMS values ('4dad81b0-4e2b-44ff-9a6d-ff7b5c862649', 'RelatedItems', null, '4f83cd41-71b5-11dd-050e-00100a64217d', '11.0', null, CURRENT_TIMESTAMP, null, CURRENT_TIMESTAMP, null, 0, '6b67ec30-712e-11dd-7434-00100a64217d', '1');

-- AnalysisStates library hidden folder (Everyone)
insert into LIB_ITEMS values ('864d749e-794c-477f-87ea-03be54fded87', 'AnalysisStates', null, '4f83cd41-71b5-11dd-050e-00100a64217d', '11.0', null, CURRENT_TIMESTAMP, null, CURRENT_TIMESTAMP, null, 0, '4dad81b0-4e2b-44ff-9a6d-ff7b5c862649', '1');

insert into LIB_ACCESS values ('864d749e-794c-477f-87ea-03be54fded87', null, '19e7e430-9997-11da-fbc4-0010ac110215', 'R');
insert into LIB_ACCESS values ('864d749e-794c-477f-87ea-03be54fded87', null, '19e7e430-9997-11da-fbc4-0010ac110215', 'W');

-- Tasks library hidden folder (Web Player Administrator and Scheduled Updates Users)
insert into LIB_ITEMS values ('6fdbc6a1-a719-465b-b6ef-94261459a497', 'Tasks', null, '4f83cd41-71b5-11dd-050e-00100a64217d', '11.0', null, CURRENT_TIMESTAMP, null, CURRENT_TIMESTAMP, null, 0, '4dad81b0-4e2b-44ff-9a6d-ff7b5c862649', '1');

insert into LIB_ACCESS values ('6fdbc6a1-a719-465b-b6ef-94261459a497', null, '4dd3fc65-c727-474b-976c-96b807f36bd6', 'R');
insert into LIB_ACCESS values ('6fdbc6a1-a719-465b-b6ef-94261459a497', null, '4dd3fc65-c727-474b-976c-96b807f36bd6', 'W');

insert into LIB_ACCESS values ('6fdbc6a1-a719-465b-b6ef-94261459a497', null, '96b90a10-1d4d-11de-283a-00100a64216b', 'R');
insert into LIB_ACCESS values ('6fdbc6a1-a719-465b-b6ef-94261459a497', null, '96b90a10-1d4d-11de-283a-00100a64216b', 'W');

-- Library Applications
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (1, 'server.downloadable.library_service');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (2, 'server.downloadable.http');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (3, 'client.export.all_items');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (4, 'client.export.analysis_files');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (5, 'client.export.information_model');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (6, 'client.import.all_items');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (7, 'client.import.analysis_files');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (8, 'client.import.information_model');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (9, 'client.administrator.show.all');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (10, 'client.administrator.show.containers');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (11, 'client.web.show.all');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (12, 'client.web.show.files');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (13, 'client.dxp.open');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (14, 'client.information_elements.all');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (15, 'client.export.datafunctions');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (16, 'client.export.colorschemes');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (17, 'client.import.datafunctions');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (18, 'client.import.colorschemes');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (19, 'server.bookmark_service.all');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (20, 'server.must_have_content');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (21, 'server.public-api');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (22, 'client.export.data_access');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (23, 'client.import.data_access');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (24, 'client.export.data_files');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (25, 'client.import.data_files');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (26, 'client.export.automation_job');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (27, 'client.import.automation_job');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (28, 'client.export.mod');
insert into LIB_APPLICATIONS (APPLICATION_ID, APPLICATION_NAME) values (29, 'client.import.mod');

-- dxp
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 2);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 4);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 7);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 11);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 12);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 13);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd47-71b5-11dd-050e-00100a64217d', 21);

-- folder
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 4);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 7);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 10);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 11);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 15);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 16);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 17);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 18);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 22);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 23);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 24);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 25);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 26);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 27);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 28);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd41-71b5-11dd-050e-00100a64217d', 29);

-- analysis
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd43-71b5-11dd-050e-00100a64217d', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd43-71b5-11dd-050e-00100a64217d', 20);

-- poster
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd44-71b5-11dd-050e-00100a64217d', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd44-71b5-11dd-050e-00100a64217d', 20);

-- guide
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd45-71b5-11dd-050e-00100a64217d', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd45-71b5-11dd-050e-00100a64217d', 20);

-- custom
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd46-71b5-11dd-050e-00100a64217d', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('4f83cd46-71b5-11dd-050e-00100a64217d', 20);

-- filter
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('365d0d4b-63c3-4bb3-ac88-7e71c98e343e', 21);

-- join
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('947059cf-b48b-4245-8547-316621e15cc3', 21);

-- procedure
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b2cdbe7b-20a3-427a-8d9e-367b34184827', 21);

-- query
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 11);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 12);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 13);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('783545a2-514f-4c90-acee-649e2df362f0', 21);

-- datasource
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e3fd5644-07a1-4a09-b05b-1d148f1f6786', 21);

-- analysisstate
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('04a1dc4d-6794-4c49-b91b-063de8a77450', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('04a1dc4d-6794-4c49-b91b-063de8a77450', 20);

-- bookmark
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 4);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 7);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 19);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('debd56cd-50bb-47b0-a458-84a2fccf3ca0', 20);

-- embeddedresource
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 4);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 7);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 19);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('3f4fc3cd-dfc0-4e5a-b48e-7729769e411e', 20);

-- analyticitem
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 4);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 7);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 19);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('5b8d0632-5747-4e9c-a5e4-3900cc7590a1', 20);

-- task
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('587870d1-ffc4-4ad7-9dd0-533f14414a58', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('587870d1-ffc4-4ad7-9dd0-533f14414a58', 20);

-- column
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 5);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 8);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 14);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('aec78e32-b5f7-48d6-99ae-97f931202497', 21);

-- datafunction
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 15);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 17);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9b7bad20-9eb0-11de-6b11-00100a64216c', 21);

-- dxpscript
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b5db3b90-9eb0-11de-91ac-00100a64216c', 21);

-- colorscheme
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 16);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 18);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('9ca21d20-b598-11de-5915-00100a64216c', 21);

-- connectiondatasource
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 22);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('e4e19ae7-003e-402f-9c35-95c16bfd74c9', 23);

-- dataconnection
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 22);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('8d900bfc-d15b-4dbc-a371-6681a1b9b2ff', 23);

-- sbdf
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 11);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 12);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 13);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 24);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('6cb16049-2fc7-43b7-916a-6d49551b54c9', 25);

-- analyticmodel
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 15);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 17);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('96abfc38-506a-48c9-bfb4-f39fc8cd20c8', 21);

-- asjob
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 26);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('b34c8235-40fc-4bcf-9be5-418106c1b16c', 27);

-- mod
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 1);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 3);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 6);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 9);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 20);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 21);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 28);
insert into LIB_VISIBLE_TYPES (TYPE_ID, APPLICATION_ID) values ('eea7fff3-14a0-4ac3-9c33-8c58294273e3', 29);

-- node manager service types
INSERT INTO NODE_SERVICE_TYPES (ID, SERVICE_TYPE) values (0,'DefaultServiceConfiguration');
INSERT INTO NODE_SERVICE_TYPES (ID, SERVICE_TYPE) values (1,'ServiceConfiguration');

-- Default site
insert into SITES (SITE_ID, NAME) values ('5c2c7b84-e1f4-4187-9799-85a2a48f0ebc', 'Default');

