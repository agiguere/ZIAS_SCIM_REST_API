INTERFACE zif_ias_group_api
  PUBLIC.
  CONSTANTS: BEGIN OF custom_extension,
               json_name TYPE string VALUE 'urn:sap:cloud:scim:schemas:extension:custom:2.0:Group',
               abap_name TYPE string VALUE 'groupExt',
             END   OF custom_extension.

  TYPES: BEGIN OF ty_meta,
           location      TYPE string,
           resource_type TYPE string,
           version       TYPE string,
         END   OF ty_meta.

  TYPES: BEGIN OF ty_member,
           value   TYPE string,
           ref     TYPE string,
           display TYPE string,
         END   OF ty_member.

  TYPES: tt_member TYPE STANDARD TABLE OF ty_member.

  TYPES: BEGIN OF ty_assign_member,
           value TYPE string,
         END   OF ty_assign_member.

  TYPES: tt_assign_member TYPE STANDARD TABLE OF ty_assign_member.

  TYPES: BEGIN OF ty_group_extension,
           name        TYPE string,
           description TYPE string,
           group_id    TYPE string,
         END   OF ty_group_extension.

  TYPES: BEGIN OF ty_group,
           id           TYPE string,
           display_name TYPE string,
           schemas      TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           members      TYPE STANDARD TABLE OF ty_member WITH DEFAULT KEY,
           group_ext    TYPE ty_group_extension,
           meta         TYPE ty_meta,
         END   OF ty_group.

  TYPES: BEGIN OF ty_create_group,
           display_name TYPE string,
           members      TYPE STANDARD TABLE OF ty_assign_member WITH DEFAULT KEY,
           group_ext    TYPE ty_group_extension,
         END   OF ty_create_group.

  TYPES: BEGIN OF ty_update_group,
           id           TYPE string,
           display_name TYPE string,
           members      TYPE STANDARD TABLE OF ty_assign_member WITH DEFAULT KEY,
           group_ext    TYPE ty_group_extension,
         END   OF ty_update_group.

  TYPES: BEGIN OF ty_groups,
           schemas        TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
           total_results  TYPE i,
           items_per_page TYPE i,
           start_index    TYPE i,
           resources      TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY,
         END   OF ty_groups.

  METHODS create_group
    IMPORTING
      !group         TYPE ty_create_group
    RETURNING
      VALUE(r_group) TYPE ty_group
    RAISING
      zcx_ias_scim_rest_api.

  METHODS get_group
    IMPORTING
      !id          TYPE string
    RETURNING
      VALUE(group) TYPE ty_group
    RAISING
      zcx_ias_scim_rest_api.

  METHODS update_group
    IMPORTING
      !group TYPE ty_update_group
    RAISING
      zcx_ias_scim_rest_api.

  METHODS delete_group
    IMPORTING
      !id TYPE string
    RAISING
      zcx_ias_scim_rest_api.

  METHODS search_groups
    IMPORTING
      count         TYPE i OPTIONAL
      start_index   TYPE i OPTIONAL
    RETURNING
      VALUE(groups) TYPE ty_groups
    RAISING
      zcx_ias_scim_rest_api.

  METHODS serialize_create_group
    IMPORTING
      !group      TYPE ty_create_group
    RETURNING
      VALUE(json) TYPE string.

  METHODS serialize_update_group
    IMPORTING
      !group      TYPE ty_update_group
    RETURNING
      VALUE(json) TYPE string.

  METHODS deserialize_group
    IMPORTING
      !json        TYPE string
    RETURNING
      VALUE(group) TYPE ty_group.

  METHODS deserialize_groups
    IMPORTING
      !json         TYPE string
    RETURNING
      VALUE(groups) TYPE ty_groups.

ENDINTERFACE.
