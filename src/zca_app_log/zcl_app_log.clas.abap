class ZCL_APP_LOG definition
  public
  final
  create private .

public section.

  data GV_LOG_HANDLE type BALLOGHNDL read-only .

  class-methods CREATE
    importing
      !IV_OBJECT type BALOBJ_D
      !IV_SUBOBJECT type BALSUBOBJ optional
      !IV_EXTNUMBER type BALNREXT
    returning
      value(RO_INSTANCE) type ref to ZCL_APP_LOG
    raising
      ZCX_APP_LOG .
  methods ADD_MESSAGES
    importing
      !IT_MESSAGES type BAPIRET2_T
    raising
      ZCX_APP_LOG .
  methods SAVE
    importing
      !IV_IN_UPDATE_TASK type ABAP_BOOL default ABAP_FALSE
    raising
      ZCX_APP_LOG .
  methods ADD_LOG_MESSAGE
    importing
      !IS_MESSAGE type BAL_S_MSG
    raising
      ZCX_APP_LOG .
  class-methods GET_LOG_HEADERS
    importing
      !IV_OBJECT type BALOBJ_D
      !IV_SUBOBJECT type BALSUBOBJ optional
      !IV_EXTNUMBER type BALNREXT
    returning
      value(RT_HEADERS) type BALHDR_T .
  class-methods LOAD
    importing
      !IV_LOG_HANDLE type BALLOGHNDL
    returning
      value(RO_INSTANCE) type ref to ZCL_APP_LOG
    raising
      ZCX_APP_LOG .
  methods GET_LOG_MESSAGES
    returning
      value(RT_MESSAGES) type BAL_T_MSGR
    raising
      ZCX_APP_LOG .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS constructor
      IMPORTING
        VALUE(iv_log_handle) TYPE balloghndl .
ENDCLASS.



CLASS ZCL_APP_LOG IMPLEMENTATION.


  METHOD ADD_LOG_MESSAGE.

    " Add message to application log (memory)
    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = gv_log_handle
        i_s_msg          = is_message
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDIF.

  ENDMETHOD.


  METHOD add_messages.

    FIELD-SYMBOLS <ls_message> TYPE bapiret2.

* Log each message in the table to the application log
    LOOP AT it_messages ASSIGNING <ls_message>.

      add_log_message( VALUE #( msgty = <ls_message>-type
                   msgid = <ls_message>-id
                   msgno = <ls_message>-number
                   msgv1 = <ls_message>-message_v1
                   msgv2 = <ls_message>-message_v2
                   msgv3 = <ls_message>-message_v3
                   msgv4 = <ls_message>-message_v4
                   context = VALUE #( tabname = <ls_message>-field
                                         value   = <ls_message>-parameter   ) )
      ).
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.

    gv_log_handle = iv_log_handle.

  ENDMETHOD.


  METHOD create.
    DATA lt_log_handle TYPE bal_t_logh.
    DATA ls_log_header TYPE bal_s_log.
    DATA lv_log_handle TYPE balloghndl.

*   Set values for app log header
    ls_log_header-extnumber = iv_extnumber.
    ls_log_header-object    = iv_object.
    ls_log_header-subobject = iv_subobject.
    ls_log_header-aldate    = sy-datum.
    ls_log_header-altime    = sy-uzeit.
    ls_log_header-aluser    = sy-uname.

*   Create new application log
    CALL FUNCTION 'BAL_LOG_CREATE'
      EXPORTING
        i_s_log                 = ls_log_header
      IMPORTING
        e_log_handle            = lv_log_handle
      EXCEPTIONS
        log_header_inconsistent = 1
        OTHERS                  = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDIF.


    CREATE OBJECT ro_instance
      EXPORTING
        iv_log_handle = lv_log_handle.

  ENDMETHOD.


  METHOD get_log_headers.

    DATA : ls_filter TYPE bal_s_lfil.
    ls_filter-object = VALUE #( ( sign = 'I' option = 'EQ' low = iv_object ) ).
    ls_filter-subobject = VALUE #( ( sign = 'I' option = 'EQ' low = iv_subobject ) ).
    ls_filter-extnumber = VALUE #( ( sign = 'I' option = 'EQ' low = iv_extnumber ) ).

    CALL FUNCTION 'BAL_DB_SEARCH'
      EXPORTING
        i_s_log_filter = ls_filter
      IMPORTING
        e_t_log_header = rt_headers
      EXCEPTIONS
        OTHERS         = 3.
    IF sy-subrc NE 0.
      CLEAR rt_headers.
    ENDIF.

  ENDMETHOD.


  METHOD GET_LOG_MESSAGES.

    CALL FUNCTION 'BAL_LOG_READ'
      EXPORTING
        i_log_handle  = gv_log_handle
      IMPORTING
        et_msg        = rt_messages
      EXCEPTIONS
        log_not_found = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      CLEAR rt_messages.
    ENDIF.

  ENDMETHOD.


  METHOD load.

    CREATE OBJECT ro_instance
      EXPORTING
        iv_log_handle = iv_log_handle.

    CALL FUNCTION 'BAL_DB_LOAD'
      EXPORTING
        i_t_log_handle = VALUE bal_t_logh( ( iv_log_handle ) )
      EXCEPTIONS
        OTHERS         = 4.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDIF.

  ENDMETHOD.


  METHOD save.

    DATA lt_handle      TYPE bal_t_logh.

** If instance is not dirty, there is no need to save
*  IF is_dirty( ) = abap_false.
*    RETURN.
*  ENDIF.

* Save application log in memory to database
    APPEND gv_log_handle TO lt_handle.
    CALL FUNCTION 'BAL_DB_SAVE'
      EXPORTING
        i_in_update_task = iv_in_update_task
        i_t_log_handle   = lt_handle
      EXCEPTIONS
        log_not_found    = 1
        save_not_allowed = 2
        numbering_error  = 3
        OTHERS           = 4.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
*  ELSE.
**   Clear dirty
*    set_dirty( abap_false ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
