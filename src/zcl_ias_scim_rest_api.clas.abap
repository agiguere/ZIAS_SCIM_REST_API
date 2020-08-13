CLASS zcl_ias_scim_rest_api DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    INTERFACES: zif_ias_user_api, zif_ias_group_api.

    ALIASES create_user
      FOR zif_ias_user_api~create_user.
    ALIASES delete_user
      FOR zif_ias_user_api~delete_user.
    ALIASES get_user
      FOR zif_ias_user_api~get_user.
    ALIASES search_users
      FOR zif_ias_user_api~search_users.
    ALIASES update_user
      FOR zif_ias_user_api~update_user.
    ALIASES ty_user
      FOR zif_ias_user_api~ty_user.
    ALIASES ty_users
      FOR zif_ias_user_api~ty_users.

    ALIASES create_group
      FOR zif_ias_group_api~create_group.
    ALIASES delete_group
      FOR zif_ias_group_api~delete_group.
    ALIASES get_group
      FOR zif_ias_group_api~get_group.
    ALIASES search_groups
      FOR zif_ias_group_api~search_groups.
    ALIASES update_group
      FOR zif_ias_group_api~update_group.
    ALIASES ty_group
      FOR zif_ias_group_api~ty_group.
    ALIASES ty_groups
      FOR zif_ias_group_api~ty_groups.
    ALIASES serialize_create_group
      FOR zif_ias_group_api~serialize_create_group.
    ALIASES serialize_update_group
      FOR zif_ias_group_api~serialize_update_group.
    ALIASES deserialize_group
      FOR zif_ias_group_api~deserialize_group.
    ALIASES deserialize_groups
      FOR zif_ias_group_api~deserialize_groups.

    CLASS-METHODS get_instance
      IMPORTING
        !destination_name TYPE rfcdest
      RETURNING
        VALUE(instance)   TYPE REF TO zcl_ias_scim_rest_api
      RAISING
        zcx_ias_scim_rest_api.

    METHODS close_connection
      RAISING
        zcx_ias_scim_rest_api.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS: BEGIN OF endpoint,
                 users  TYPE string VALUE '/service/scim/Users',
                 groups TYPE string VALUE '/service/scim/Groups',
               END   OF endpoint.

    DATA destination_name TYPE rfcdest.
    DATA http_client TYPE REF TO if_http_client.

    METHODS constructor
      IMPORTING
        !destination_name TYPE rfcdest
        !http_client      TYPE REF TO if_http_client.

    CLASS-METHODS create_connection
      IMPORTING
        !destination_name  TYPE rfcdest
      RETURNING
        VALUE(http_client) TYPE REF TO if_http_client
      RAISING
        zcx_ias_scim_rest_api.

    METHODS send_request
      IMPORTING
        !uri            TYPE string
        !payload        TYPE string OPTIONAL
        !method         TYPE string DEFAULT 'GET'
        !content_type   TYPE string DEFAULT 'application/scim+json'
      RETURNING
        VALUE(response) TYPE REF TO if_http_response
      RAISING
        zcx_ias_scim_rest_api.

    METHODS serialize_user
      IMPORTING
        !user       TYPE ty_user
      RETURNING
        VALUE(json) TYPE string.

    METHODS serialize_create_user
      IMPORTING
        !user       TYPE zif_ias_user_api~ty_create_user
      RETURNING
        VALUE(json) TYPE string.

    METHODS serialize_update_user
      IMPORTING
        !user       TYPE zif_ias_user_api~ty_update_user
      RETURNING
        VALUE(json) TYPE string.

    METHODS deserialize_user
      IMPORTING
        !json       TYPE string
      RETURNING
        VALUE(user) TYPE ty_user.

    METHODS deserialize_users
      IMPORTING
        !json        TYPE string
      RETURNING
        VALUE(users) TYPE ty_users.

ENDCLASS.



CLASS ZCL_IAS_SCIM_REST_API IMPLEMENTATION.


  METHOD close_connection.

    http_client->close(
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid = zcx_ias_scim_rest_api=>close_connection_failed.
    ENDIF.

  ENDMETHOD.


  METHOD constructor.

    super->constructor( ).

    me->http_client = http_client.
    me->destination_name = destination_name.

  ENDMETHOD.


  METHOD create_connection.

    CALL METHOD cl_http_client=>create_by_destination
      EXPORTING
        destination              = destination_name
      IMPORTING
        client                   = http_client
      EXCEPTIONS
        argument_not_found       = 1
        destination_not_found    = 2
        destination_no_authority = 3
        plugin_not_active        = 4
        internal_error           = 5
        OTHERS                   = 6.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid = zcx_ias_scim_rest_api=>create_connection_failed.
    ENDIF.

  ENDMETHOD.


  METHOD deserialize_user.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~custom_extension-json_name
      IN new_json WITH zif_ias_user_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~enterprise_extension-json_name
      IN new_json WITH zif_ias_user_api~enterprise_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = user ).

  ENDMETHOD.


  METHOD deserialize_users.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~custom_extension-json_name
      IN new_json WITH zif_ias_user_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~enterprise_extension-json_name
      IN new_json WITH zif_ias_user_api~enterprise_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = users ).

  ENDMETHOD.


  METHOD get_instance.

    DATA http_client TYPE REF TO if_http_client.

    http_client = create_connection( destination_name ).

    CREATE OBJECT instance
      EXPORTING
        destination_name = destination_name
        http_client      = http_client.

  ENDMETHOD.


  METHOD send_request.

    DATA payload_x TYPE xstring.

    cl_http_utility=>set_request_uri(
      request = http_client->request
      uri     = uri ).

    IF payload IS NOT INITIAL.
      CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
        EXPORTING
          text   = payload
        IMPORTING
          buffer = payload_x.

      http_client->request->set_data( payload_x ).
    ENDIF.

    http_client->request->set_method( method ).
    http_client->request->set_content_type( content_type ).

    http_client->send(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid = zcx_ias_scim_rest_api=>send_request_failed.
    ENDIF.

    http_client->receive(
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3 ).

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid = zcx_ias_scim_rest_api=>receive_response_failed.
    ENDIF.

    response = http_client->response.

  ENDMETHOD.


  METHOD serialize_user.

    json = /ui2/cl_json=>serialize(
      data        = user
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~custom_extension-abap_name
      IN json WITH zif_ias_user_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~enterprise_extension-abap_name
      IN json WITH zif_ias_user_api~enterprise_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD serialize_create_user.

    json = /ui2/cl_json=>serialize(
      data        = user
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~custom_extension-abap_name
      IN json WITH zif_ias_user_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~enterprise_extension-abap_name
      IN json WITH zif_ias_user_api~enterprise_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD serialize_update_user.

    json = /ui2/cl_json=>serialize(
      data        = user
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~custom_extension-abap_name
      IN json WITH zif_ias_user_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF zif_ias_user_api~enterprise_extension-abap_name
      IN json WITH zif_ias_user_api~enterprise_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD zif_ias_group_api~create_group.

    DATA(response) = send_request(
      uri     = endpoint-groups
      payload = serialize_create_group( group )
      method  = 'POST' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 201.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>create_group_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    r_group = deserialize_group( json ).

  ENDMETHOD.


  METHOD zif_ias_group_api~delete_group.

    DATA uri TYPE string.

    uri = endpoint-groups && '/' && id.

    DATA(response) = send_request(
      uri    = uri
      method = 'DELETE' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>delete_group_failed
          group_id    = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_group_api~deserialize_group.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_ias_group_api~custom_extension-json_name
      IN new_json WITH zif_ias_group_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = group ).

  ENDMETHOD.


  METHOD zif_ias_group_api~deserialize_groups.

    DATA new_json TYPE string.

    new_json = json.

    REPLACE ALL OCCURRENCES OF zif_ias_group_api~custom_extension-json_name
      IN new_json WITH zif_ias_group_api~custom_extension-abap_name.

    REPLACE ALL OCCURRENCES OF '"$ref"' IN new_json WITH '"ref"'.

    /ui2/cl_json=>deserialize(
      EXPORTING
        json         = new_json
        pretty_name  = abap_true
        assoc_arrays = abap_true
      CHANGING
        data         = groups ).

  ENDMETHOD.


  METHOD zif_ias_group_api~get_group.

    DATA uri TYPE string.

    uri = endpoint-groups && '/' && id.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code = 200.
      DATA(json) = response->get_cdata( ).

      group = deserialize_group( json ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>get_group_failed
          group_id    = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_group_api~search_groups.

    DATA uri TYPE string VALUE endpoint-groups.

    DATA filter TYPE string.

    IF count IS NOT INITIAL.
      filter = 'count=' && count.
    ENDIF.

    IF start_index IS NOT INITIAL.
      IF count IS NOT INITIAL.
        filter = filter && '&'.
      ENDIF.

      filter = filter && 'startIndex=' && start_index.
    ENDIF.

    IF filter IS NOT INITIAL.
      uri = uri && '?' && filter.
    ENDIF.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code = 200.
      DATA(json) = response->get_cdata( ).

      groups = deserialize_groups( json ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>search_groups_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_group_api~serialize_create_group.

    json = /ui2/cl_json=>serialize(
      data        = group
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_ias_group_api~custom_extension-abap_name
      IN json WITH zif_ias_group_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD zif_ias_group_api~serialize_update_group.

    json = /ui2/cl_json=>serialize(
      data        = group
      compress    = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case ).

    REPLACE ALL OCCURRENCES OF zif_ias_group_api~custom_extension-abap_name
      IN json WITH zif_ias_group_api~custom_extension-json_name.

    REPLACE ALL OCCURRENCES OF '"ref"' IN json WITH '"$ref"'.

  ENDMETHOD.


  METHOD zif_ias_group_api~update_group.

    DATA uri TYPE string.

    uri = endpoint-groups && '/' && group-id.

    DATA(response) = send_request(
      uri     = uri
      method  = 'PUT'
      payload = serialize_update_group( group ) ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>update_group_failed
          group_id    = group-id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_user_api~create_user.

    DATA(response) = send_request(
      uri     = endpoint-users
      payload = serialize_create_user( user )
      method  = 'POST' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 201.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>create_user_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

    DATA(json) = response->get_cdata( ).

    r_user = deserialize_user( json ).

  ENDMETHOD.


  METHOD zif_ias_user_api~delete_user.

    DATA uri TYPE string.

    uri = endpoint-users && '/' && id.

    DATA(response) = send_request(
      uri    = uri
      method = 'DELETE' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 204.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>delete_user_failed
          user_id     = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_user_api~get_user.

    DATA uri TYPE string.

    uri = endpoint-users && '/' && id.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code = 200.
      DATA(json) = response->get_cdata( ).

      user = deserialize_user( json ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>get_user_failed
          user_id     = id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_user_api~search_users.

    DATA uri TYPE string VALUE endpoint-users.

    IF filter IS NOT INITIAL.
      uri = uri && '?' && filter.
    ENDIF.

    DATA(response) = send_request( uri = uri ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code = 200.
      DATA(json) = response->get_cdata( ).

      users = deserialize_users( json ).
    ELSE.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>search_users_failed
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.


  METHOD zif_ias_user_api~update_user.

    DATA uri TYPE string.

    uri = endpoint-users && '/' && user-id.

    DATA(response) = send_request(
      uri     = uri
      payload = serialize_update_user( user )
      method  = 'PUT' ).

    response->get_status(
      IMPORTING
        code   = DATA(status_code)
        reason = DATA(reason) ).

    IF status_code <> 200.
      RAISE EXCEPTION TYPE zcx_ias_scim_rest_api
        EXPORTING
          textid      = zcx_ias_scim_rest_api=>update_user_failed
          user_id     = user-id
          status_code = status_code
          reason      = reason.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
