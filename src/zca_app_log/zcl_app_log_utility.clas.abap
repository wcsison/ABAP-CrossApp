class ZCL_APP_LOG_UTILITY definition
  public
  create public .

public section.

  class-methods DISPLAY
    importing
      !IT_LOG_HANDLES type BAL_T_LOGH optional
      !IT_FIELD_CATALOG type BAL_T_FCAT
    raising
      ZCX_APP_LOG .
protected section.
private section.
ENDCLASS.



CLASS ZCL_APP_LOG_UTILITY IMPLEMENTATION.


  METHOD display.
    DATA:
      ls_display_profile TYPE bal_s_prof.

    CALL FUNCTION 'BAL_DSP_PROFILE_SINGLE_LOG_GET'
      IMPORTING
        e_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDIF.
    append lines of it_field_catalog to     ls_display_profile-mess_fcat.
    ls_display_profile-exp_level = 0.
    ls_display_profile-disvariant-report = sy-repid.
    ls_display_profile-disvariant-handle = 'LOG'.

    if  it_log_handles is supplied.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_t_log_handle      = it_log_handles
        i_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.
    else.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_s_display_profile = ls_display_profile
      EXCEPTIONS
        OTHERS              = 1.
    endif.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_app_log
        EXPORTING
          mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDIF.
  ENDMETHOD.
ENDCLASS.
