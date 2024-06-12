class ZCL_CA_EMAIL definition
  public
  final
  create public .

public section.

  methods SEND
    importing
      !IT_RECIPIENT type BCSY_SMTPA optional
    raising
      ZCX_CA_EMAIL .
  methods SET_HTML_DOCUMENT
    importing
      !IT_PARAMETERS type SWWW_T_MERGE_TABLE
      !IV_TEMPLATE type W3OBJID
      !IV_SUBJECT type SO_OBJ_DES
    raising
      ZCX_CA_HTML_TEMPLATE
      ZCX_CA_EMAIL .
  methods CONSTRUCTOR .
protected section.
private section.

  data MO_SEND_REQUEST type ref to CL_BCS .
  data MO_DOCUMENT type ref to CL_DOCUMENT_BCS .
ENDCLASS.



CLASS ZCL_CA_EMAIL IMPLEMENTATION.


  method CONSTRUCTOR.
*----------------------------------------------------------------------*
* Dev Request : Base Build                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*   Constructor - Email                                                *
*                                                                      *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
* Date       CR/Defect#   Author                                       *
* ========== ==========   ============================================ *
* 16.12.2020 N/A          Wilbert SIson                                *
* Description :                                                        *
*   Initial Development                                                *
*----------------------------------------------------------------------*
    mo_send_request = cl_bcs=>create_persistent( ).
  endmethod.


  METHOD send.
*----------------------------------------------------------------------*
* Dev Request : Base Build                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*   Send email document                                                *
*                                                                      *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
* Date       CR/Defect#   Author                                       *
* ========== ==========   ============================================ *
* 16.12.2020 N/A          Wilbert SIson                                *
* Description :                                                        *
*   Initial Development                                                *
*----------------------------------------------------------------------*

    TRY.
        DATA(lt_recipient) = it_recipient.
        DELETE lt_recipient WHERE TABLE_LINE = ''.
        SORT lt_recipient .
        DELETE ADJACENT DUPLICATES FROM lt_recipient.

        LOOP AT it_recipient ASSIGNING FIELD-SYMBOL(<recipient>).

          DATA(lo_recipient) = cl_cam_address_bcs=>create_internet_address(  <recipient> ) .
          mo_send_request->add_recipient( lo_recipient  ).

        ENDLOOP.

        mo_send_request->send( ).

      CATCH cx_bcs INTO DATA(o_error).
        "System error in sending email
        MESSAGE e002(zca) INTO zcl_messages=>sv_message.
        RAISE EXCEPTION TYPE zcx_ca_email
          EXPORTING
            previous    = o_error
            mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDTRY.

  ENDMETHOD.


  METHOD set_html_document.
*----------------------------------------------------------------------*
* Dev Request : Base Build                                             *
*----------------------------------------------------------------------*
* Description :                                                        *
*   Set HTML email document                                            *
*                                                                      *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
* Date       CR/Defect#   Author                                       *
* ========== ==========   ============================================ *
* 16.12.2020 N/A          Wilbert SIson                                *
* Description :                                                        *
*   Initial Development                                                *
*----------------------------------------------------------------------*

* Sample IT_PARAMETERS
* NAME    = !MYVARIABLE!
* COMMAND = R    (Replace)
* HTML[1]    = '<p> <b>REPLACEMENT VALUE 1st line </b></p>'
* HTML[2]    = '<p> <b>REPLACEMENT VALUE 2nd line </b> </p>'


    TRY.
        DATA(lt_message) = NEW zcl_ca_html_template( iv_template )->generate( it_parameters ).
        mo_document = cl_document_bcs=>create_document( i_type = 'HTM'
                                          i_text = lt_message
                                          i_subject = iv_subject ).
        mo_send_request->set_document( mo_document ).
        mo_send_request->set_message_subject( CONV #( iv_subject ) ).
      CATCH cx_bcs INTO DATA(o_error).
        MESSAGE e001(zca) INTO zcl_messages=>sv_message.
        RAISE EXCEPTION TYPE zcx_ca_email
          EXPORTING
            previous    = o_error
            mo_messages = NEW zcl_messages( )->add_system_message( ).
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
