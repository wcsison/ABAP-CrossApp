CLASS zcl_user DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES : BEGIN OF ts_data,
              email    TYPE ad_smtpadr,
              fullname TYPE string,
            END OF ts_data.
    TYPES : BEGIN OF ts_key,
              user TYPE usr01,
            END OF ts_key.

    DATA ms_key TYPE ts_key READ-ONLY .
    DATA ms_data TYPE ts_data.

    METHODS constructor
      IMPORTING
        !is_key TYPE ts_key.
    METHODS get_email
      RETURNING VALUE(rv_email) TYPE ad_smtpadr
      RAISING   zcx_user.
    METHODS get_fullname
      RETURNING VALUE(rv_fullname) TYPE string
      RAISING   zcx_user.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS read_data
      RAISING zcx_user.
ENDCLASS.



CLASS ZCL_USER IMPLEMENTATION.


  METHOD constructor.
    ms_key = is_key.
  ENDMETHOD.


  METHOD get_email.
    read_data( ).
    rv_email = ms_data-email.
  ENDMETHOD.


  METHOD get_fullname.
    read_data( ).
    rv_fullname = ms_data-fullname.
  ENDMETHOD.


  METHOD read_data.

    DATA : ls_address TYPE bapiaddr3.
    DATA : lt_messages TYPE bapiret2_t.
    IF ms_data IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF ms_key-user IS NOT INITIAL.
      "Read the user eamil
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = CONV xubname( ms_key-user )
        IMPORTING
          address  = ls_address
        TABLES
          return   = lt_messages.
      DATA(o_messages) = NEW zcl_messages( )->add_messages( lt_messages ).
      IF o_messages->contains_error( ).
        RAISE EXCEPTION TYPE zcx_user
          EXPORTING
            mo_messages = o_messages.
      ENDIF.

      ms_data-email = ls_address-e_mail.
      ms_data-fullname = |{ ls_address-firstname } { ls_address-lastname }|.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
