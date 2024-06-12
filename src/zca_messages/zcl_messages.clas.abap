class ZCL_MESSAGES definition
  public
  final
  create public .

public section.

  data MT_MESSAGES type BAPIRET2_T read-only .
  constants:
    BEGIN OF gc_message_type,
        error     TYPE msgty VALUE 'E',
        warning   TYPE msgty VALUE 'W',
        status    TYPE msgty VALUE 'S',
        abort     TYPE msgty VALUE 'A',
        abend     TYPE msgty VALUE 'X',
        info      TYPE msgty VALUE 'I',
        any_error TYPE string VALUE 'AEX',
      END OF gc_message_type .
  class-data SV_MESSAGE type STRING .

  methods SET_CONTEXT
    importing
      !IV_PARAMETER type BAPI_PARAM
      !IV_FIELD type BAPI_FLD
      !IV_ROW type BAPI_LINE optional
    returning
      value(RO_INSTANCE) type ref to ZCL_MESSAGES .
  class-methods TO_STRING
    importing
      !IS_MESSAGE type BAPIRET2
    returning
      value(RV_MESSAGE_STRING) type STRING .
  methods ADD_MESSAGES
    importing
      !IT_MESSAGES type BAPIRET2_T
    returning
      value(RO_ME) type ref to ZCL_MESSAGES .
  methods ADD_SYSTEM_MESSAGE
    importing
      !IV_PARAMETER type BAPI_PARAM optional
      !IV_FIELD type BAPI_FLD optional
      !IV_ROW type BAPI_LINE optional
    returning
      value(RO_ME) type ref to ZCL_MESSAGES .
  methods CONSTRUCTOR
    importing
      !IT_MESSAGES type BAPIRET2_T optional .
  methods SHOW_AS_LOG
    importing
      !IV_TITLE type BALTITLE default 'Message log'
      !IV_START_COL type BALCOORD default 0
      !IV_START_ROW type BALCOORD default 0
      !IV_END_COL type BALCOORD default 0
      !IV_END_ROW type BALCOORD default 0 .
  methods CONTAINS_ERROR
    returning
      value(RV_RESULT) type ABAP_BOOL .
  methods GET_FIRST_ERROR
    returning
      value(RS_MESSAGE) type BAPIRET2 .
  methods GET_FIRST_MESSAGE
    importing
      !IV_MESSAGE_TYPES type STRING
    returning
      value(RS_MESSAGE) type BAPIRET2 .
  methods CLEAR_MESSAGES
    returning
      value(RO_ME) type ref to ZCL_MESSAGES .
  PROTECTED SECTION.

    CLASS-METHODS fill_message
      IMPORTING
        !iv_msgty         TYPE symsgty DEFAULT sy-msgty
        !iv_msgid         TYPE symsgid DEFAULT sy-msgid
        !iv_msgno         TYPE symsgno DEFAULT sy-msgno
        !iv_msgv1         TYPE symsgv DEFAULT sy-msgv1
        !iv_msgv2         TYPE symsgv DEFAULT sy-msgv2
        !iv_msgv3         TYPE symsgv DEFAULT sy-msgv3
        !iv_msgv4         TYPE symsgv DEFAULT sy-msgv4
        !iv_parameter     TYPE bapi_param OPTIONAL
        !iv_row           TYPE bapi_line OPTIONAL
        !iv_field         TYPE bapi_fld OPTIONAL
      RETURNING
        VALUE(rs_message) TYPE bapiret2 .
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_MESSAGES IMPLEMENTATION.


  METHOD add_messages.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Append messages to message table                                    *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    APPEND LINES OF it_messages TO mt_messages.
    ro_me = me.

  ENDMETHOD.


  METHOD add_system_message.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Create messages object from system message                          *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    " Fill bapiret structure
    DATA(message) = fill_message( ).
    message-parameter = iv_parameter.
    message-field = iv_field.
    message-row = iv_row.

    " Add message to the bapiret table
    APPEND message TO mt_messages.

    ro_me = me.

  ENDMETHOD.


  METHOD clear_messages.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Constructor                                                         *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*
    CLEAR mt_messages.

    ro_me = me.
  ENDMETHOD.


  METHOD constructor.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Constructor                                                         *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*
    mt_messages = it_messages.

  ENDMETHOD.


  METHOD contains_error.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Returns true if the message table contains error                    *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    rv_result = abap_false.
    LOOP AT mt_messages TRANSPORTING NO FIELDS
      WHERE type CA gc_message_type-any_error.
      rv_result = abap_true.
      RETURN.
    ENDLOOP.

  ENDMETHOD.


  METHOD fill_message.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Fill message structure                                              *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*
    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
      EXPORTING
        type      = iv_msgty
        cl        = iv_msgid
        number    = iv_msgno
        par1      = iv_msgv1
        par2      = iv_msgv2
        par3      = iv_msgv3
        par4      = iv_msgv4
        parameter = iv_parameter
        row       = iv_row
        field     = iv_field
      IMPORTING
        return    = rs_message.

  ENDMETHOD.


  METHOD get_first_error.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Returns first error encountered, otherwise blank                    *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    rs_message = get_first_message( gc_message_type-any_error ).

  ENDMETHOD.


  METHOD get_first_message.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Returns first error encountered, otherwise blank                    *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    LOOP AT mt_messages INTO rs_message
      WHERE type CA iv_message_types.
      RETURN.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_context.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Set context information to all items                                *
*   This can be used for context information to pass to ZCL_APP_LOG     *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*
    LOOP AT mt_messages ASSIGNING FIELD-SYMBOL(<message>).
      <message>-parameter = iv_parameter.
      <message>-field = iv_field.
      <message>-row = iv_row.
    ENDLOOP.
    ro_instance = me.
  ENDMETHOD.


  METHOD show_as_log.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   DIsplays messages as application log                                *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    DATA lo_log                 TYPE REF TO  cl_s_aut_bal_log.
    DATA lo_log_bkgrd           TYPE REF TO  if_reca_message_list.
    FIELD-SYMBOLS <ls_bapiret2> LIKE LINE OF mt_messages.

    IF sy-binpt    IS INITIAL AND
       sy-batch    IS INITIAL.

      "   Create a new log handle.
      lo_log = cl_s_aut_bal_log=>create( 'PTU' ).

      LOOP AT mt_messages ASSIGNING FIELD-SYMBOL(<message>).
        CALL METHOD lo_log->add_entry
          EXPORTING
            im_msgtype = <message>-type
            im_msgid   = <message>-id
            im_msgno   = <message>-number
            im_msgv1   = <message>-message_v1
            im_msgv2   = <message>-message_v2
            im_msgv3   = <message>-message_v3
            im_msgv4   = <message>-message_v4.
      ENDLOOP.

*   Show the log.
      lo_log->show( im_title     = iv_title
                    im_start_col = iv_start_col
                    im_start_row = iv_start_row
                    im_end_col   = iv_end_col
                    im_end_row   = iv_end_row ).
    ELSE.
      lo_log_bkgrd = cf_reca_message_list=>create( ).
      lo_log_bkgrd->add_from_bapi( it_bapiret = mt_messages ).

      CALL FUNCTION 'RECA_GUI_MSGLIST_POPUP'
        EXPORTING
          io_msglist = lo_log_bkgrd
          id_title   = iv_title
          if_popup   = abap_false.
    ENDIF.
  ENDMETHOD.


  METHOD to_string.
*-----------------------------------------------------------------------*
* Description :                                                         *
*   Returns message as string                                           *
*-----------------------------------------------------------------------*
* CHANGE HISTORY                                                        *
* Date       Dev Ref#         Author                                    *
* ========== ==========       ========================================= *
*            ABAP BASE BUILD  Wilbert SIson                             *
* Description : Initial Development                                     *
*-----------------------------------------------------------------------*

    IF is_message-id IS INITIAL OR is_message-type IS INITIAL OR is_message-number IS INITIAL.
      RETURN.
    ENDIF.

    MESSAGE ID is_message-id TYPE is_message-type NUMBER is_message-number
      WITH is_message-message_v1 is_message-message_v2 is_message-message_v3 is_message-message_v4
      INTO rv_message_string.

  ENDMETHOD.
ENDCLASS.
