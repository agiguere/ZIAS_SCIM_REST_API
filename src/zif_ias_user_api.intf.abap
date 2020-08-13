 INTERFACE zif_ias_user_api
  PUBLIC.
   CONSTANTS: BEGIN OF custom_extension,
                json_name TYPE string VALUE 'urn:sap:cloud:scim:schemas:extension:custom:2.0:User',
                abap_name TYPE string VALUE 'customExt',
              END   OF custom_extension.

   CONSTANTS: BEGIN OF enterprise_extension,
                json_name TYPE string VALUE 'urn:ietf:params:scim:schemas:extension:enterprise:2.0:User',
                abap_name TYPE string VALUE 'enterpriseExt',
              END   OF enterprise_extension.

   TYPES: BEGIN OF ty_custom_attribute,
            name  TYPE string,
            value TYPE string,
          END   OF ty_custom_attribute.

   TYPES: BEGIN OF ty_custom_extension,
            attributes TYPE STANDARD TABLE OF ty_custom_attribute WITH DEFAULT KEY,
          END   OF ty_custom_extension.

   TYPES: BEGIN OF ty_terms_of_use,
            time_of_acceptance TYPE string,
            name               TYPE string,
            id                 TYPE string,
            locale             TYPE string,
            version            TYPE string,
          END   OF ty_terms_of_use.

   TYPES: BEGIN OF ty_privacy_policy,
            time_of_acceptance TYPE string,
            name               TYPE string,
            id                 TYPE string,
            locale             TYPE string,
            version            TYPE string,
          END   OF ty_privacy_policy.

   TYPES: BEGIN OF ty_phone_number,
            type  TYPE string,
            value TYPE string,
          END   OF ty_phone_number.

   TYPES: BEGIN OF ty_meta,
            created       TYPE string,
            location      TYPE string,
            last_modified TYPE string,
            version       TYPE string,
            resource_type TYPE string,
          END   OF ty_meta.

   TYPES: BEGIN OF ty_group,
            display TYPE string,
            value   TYPE string,
            ref     TYPE string,
          END   OF ty_group.

   TYPES: BEGIN OF ty_manager,
            display_name TYPE string,
            value        TYPE string,
            ref          TYPE string,
          END   OF ty_manager.

   TYPES: BEGIN OF ty_employee_info,
            division        TYPE string,
            organization    TYPE string,
            department      TYPE string,
            employee_number TYPE string,
            cost_center     TYPE string,
            manager         TYPE ty_manager,
          END   OF ty_employee_info.

   TYPES: BEGIN OF ty_user_name,
            given_name       TYPE string,
            family_name      TYPE string,
            middle_name      TYPE string,
            honorific_prefix TYPE string,
          END   OF ty_user_name.

   TYPES: BEGIN OF ty_address,
            type           TYPE string,
            street_address TYPE string,
            locality       TYPE string,
            region         TYPE string,
            postal_code    TYPE string,
            country        TYPE string,
          END   OF ty_address.

   TYPES: BEGIN OF ty_company_info,
            company      TYPE string,
            department   TYPE string,
            industry_crm TYPE string,
          END   OF ty_company_info.

   TYPES: BEGIN OF ty_email,
            value TYPE string,
          END   OF ty_email.

   TYPES: BEGIN OF ty_user,
            id                             TYPE string,
            user_uuid                      TYPE string,
            active                         TYPE abap_bool,
            user_type                      TYPE string,
            name                           TYPE ty_user_name,
            user_name                      TYPE string,
            display_name                   TYPE string,
            company                        TYPE string,
            department                     TYPE string,
            industry_crm                   TYPE string,
            login_time                     TYPE string,
            otp_failed_login_attempts      TYPE string,
            password_status                TYPE string,
            password_policy                TYPE string,
            password_set_time              TYPE string,
            password_login_time            TYPE string,
            password_failed_login_attempts TYPE string,
            groups                         TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY,
            addresses                      TYPE STANDARD TABLE OF ty_address WITH DEFAULT KEY,
            emails                         TYPE STANDARD TABLE OF ty_email WITH DEFAULT KEY,
            phone_numbers                  TYPE STANDARD TABLE OF ty_phone_number WITH DEFAULT KEY,
            telephone_verified             TYPE string,
            mail_verified                  TYPE string,
            locale                         TYPE string,
            time_zone                      TYPE string,
            enterprise_ext                 TYPE ty_employee_info,
            custom_ext                     TYPE ty_custom_extension,
            terms_of_use                   TYPE ty_terms_of_use,
            privacy_policy                 TYPE ty_privacy_policy,
            meta                           TYPE ty_meta,
            schemas                        TYPE STANDARD TABLE OF string WITH DEFAULT KEY,
          END   OF ty_user.

   TYPES: BEGIN OF ty_create_user,
            active                         TYPE abap_bool,
            send_mail                      TYPE string,
            user_type                      TYPE string,
            name                           TYPE ty_user_name,
            user_name                      TYPE string,
            display_name                   TYPE string,
            company                        TYPE string,
            department                     TYPE string,
            industry_crm                   TYPE string,
            otp_failed_login_attempts      TYPE string,
            password                       TYPE string,
            password_status                TYPE string,
            password_policy                TYPE string,
            password_failed_login_attempts TYPE string,
            addresses                      TYPE STANDARD TABLE OF ty_address WITH DEFAULT KEY,
            emails                         TYPE STANDARD TABLE OF ty_email WITH DEFAULT KEY,
            phone_numbers                  TYPE STANDARD TABLE OF ty_phone_number WITH DEFAULT KEY,
            telephone_verified             TYPE string,
            mail_verified                  TYPE string,
            locale                         TYPE string,
            time_zone                      TYPE string,
            enterprise_ext                 TYPE ty_employee_info,
            custom_ext                     TYPE ty_custom_extension,
            terms_of_use                   TYPE ty_terms_of_use,
            privacy_policy                 TYPE ty_privacy_policy,
          END   OF ty_create_user.

   TYPES: BEGIN OF ty_update_user,
            id                             TYPE string,
            active                         TYPE abap_bool,
            user_type                      TYPE string,
            name                           TYPE ty_user_name,
            user_name                      TYPE string,
            display_name                   TYPE string,
            company                        TYPE string,
            department                     TYPE string,
            industry_crm                   TYPE string,
            otp_failed_login_attempts      TYPE string,
            password                       TYPE string,
            password_status                TYPE string,
            password_policy                TYPE string,
            password_failed_login_attempts TYPE string,
            addresses                      TYPE STANDARD TABLE OF ty_address WITH DEFAULT KEY,
            emails                         TYPE STANDARD TABLE OF ty_email WITH DEFAULT KEY,
            phone_numbers                  TYPE STANDARD TABLE OF ty_phone_number WITH DEFAULT KEY,
            telephone_verified             TYPE string,
            mail_verified                  TYPE string,
            locale                         TYPE string,
            time_zone                      TYPE string,
            enterprise_ext                 TYPE ty_employee_info,
            custom_ext                     TYPE ty_custom_extension,
            terms_of_use                   TYPE ty_terms_of_use,
            privacy_policy                 TYPE ty_privacy_policy,
          END   OF ty_update_user.

   TYPES: tt_user TYPE STANDARD TABLE OF ty_user.

   TYPES: BEGIN OF ty_users,
            total_results  TYPE i,
            items_per_page TYPE i,
            resources      TYPE STANDARD TABLE OF ty_user WITH DEFAULT KEY,
          END   OF ty_users.

   METHODS create_user
     IMPORTING
       !user         TYPE ty_create_user
     RETURNING
       VALUE(r_user) TYPE ty_user
     RAISING
       zcx_ias_scim_rest_api.

   METHODS get_user
     IMPORTING
       !id         TYPE string
     RETURNING
       VALUE(user) TYPE ty_user
     RAISING
       zcx_ias_scim_rest_api.

   METHODS update_user
     IMPORTING
       !user TYPE ty_update_user
     RAISING
       zcx_ias_scim_rest_api.

   METHODS delete_user
     IMPORTING
       !id TYPE string
     RAISING
       zcx_ias_scim_rest_api.

   METHODS search_users
     IMPORTING
       filter       TYPE string
     RETURNING
       VALUE(users) TYPE ty_users
     RAISING
       zcx_ias_scim_rest_api.

 ENDINTERFACE.
