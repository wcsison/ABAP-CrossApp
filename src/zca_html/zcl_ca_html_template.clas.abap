class ZCL_CA_HTML_TEMPLATE definition
  public
  create public .

public section.

  methods GENERATE
    importing
      !IT_PARAMETERS type SWWW_T_MERGE_TABLE
    returning
      value(RT_HTML_PAGE) type SWWW_T_HTML_TABLE
    raising
      ZCX_CA_HTML_TEMPLATE .
  methods CONSTRUCTOR
    importing
      !IV_TEMPLATE_NAME type W3OBJID .
protected section.
private section.

  data MV_TEMPLATE type W3OBJID .
ENDCLASS.



CLASS ZCL_CA_HTML_TEMPLATE IMPLEMENTATION.


  method CONSTRUCTOR.
*----------------------------------------------------------------------*
* Dev Request : Base Build                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*   Constructor - HTML Template                                        *
*                                                                      *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
* Date       CR/Defect#   Author                                       *
* ========== ==========   ============================================ *
* 16.12.2020 N/A          Wilbert SIson                                *
* Description :                                                        *
*   Initial Development                                                *
*----------------------------------------------------------------------*
    mv_template = iv_template_name.
  endmethod.


  method GENERATE.
*----------------------------------------------------------------------*
* Dev Request : Base Build                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*   Generate HTML Document                                             *
*                                                                      *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
* Date       CR/Defect#   Author                                       *
* ========== ==========   ============================================ *
* 16.12.2020 N/A          Wilbert SIson                                *
* Description :                                                        *
*   Initial Development                                                *
*----------------------------------------------------------------------*

   data : lt_merge type  swww_t_merge_table.
   lt_merge[] = it_parameters[].

   CALL FUNCTION 'WWW_HTML_MERGER'
     EXPORTING
       template                 = mv_template
    IMPORTING
      HTML_TABLE               = rt_html_page
     changing
       merge_table              = lt_merge
    EXCEPTIONS
      TEMPLATE_NOT_FOUND       = 1
      OTHERS                   = 2
             .
   IF sy-subrc <> 0.
     raise exception type zcx_Ca_html_template
       exporting
         mo_messages = new zcl_messages( )->add_system_message( ).
   ENDIF.

  endmethod.
ENDCLASS.
