class ZCL_CA_INBOUND_IDOC definition
  public
  create public .

public section.

  methods PROCESS
    importing
      !IT_IDOC_CONTROL type EDIDC_TT
      !IT_IDOC_DATA type EDIDD_TT
    changing
      !CT_IDOC_STATUS type T_IDOC_STATUS .
protected section.

  data MT_IDOC_DATA type EDIDD_TT .
  data MT_IDOC_STATUS type T_IDOC_STATUS .
  data MO_MESSAGES type ref to ZCL_MESSAGES .

  methods SET_STATUS
    importing
      !IV_STATUS type EDI_STATUS
      !IV_DOCNUM type EDI_DOCNUM
      !IV_SEGNUM type EDI_SEGNUM optional
      !IV_SEGFLD type EDI_SEGFLD optional
    returning
      value(RT_STATUS) type T_IDOC_STATUS .
private section.
ENDCLASS.



CLASS ZCL_CA_INBOUND_IDOC IMPLEMENTATION.


  method PROCESS.
*----------------------------------------------------------------------*
* Description:
*  Main inbound idoc processing
*----------------------------------------------------------------------*
* Date          Author       Reference
*----------------------------------------------------------------------*
* 03/06/2021    WILBERTS
* Description:
*   Initial development
*----------------------------------------------------------------------*

    " To be refedined at subclass level

  endmethod.


  METHOD set_status.
*----------------------------------------------------------------------*
* Description:
*  Set idoc status and status message
*----------------------------------------------------------------------*
* Date          Author       Reference
*----------------------------------------------------------------------*
* 03/06/2021    WILBERTS
* Description:
*   Initial development
*----------------------------------------------------------------------*

    " Get all messages
    LOOP AT mo_messages->mt_messages ASSIGNING FIELD-SYMBOL(<message>).
      APPEND INITIAL LINE TO mt_idoc_status ASSIGNING FIELD-SYMBOL(<status>).
      <status> = VALUE #(
          docnum = iv_docnum
          status = iv_status
          msgty = <message>-type
          msgid = <message>-id
          msgno = <message>-number
          msgv1 = <message>-message_v1
          msgv2 = <message>-message_v2
          msgv3 = <message>-message_v3
          msgv4 = <message>-message_v4
          segnum = iv_segnum
          segfld = iv_segfld
      ).
    ENDLOOP.
    IF sy-subrc NE 0.
      APPEND VALUE #(  docnum = iv_docnum status = iv_status ) TO mt_idoc_status.
    ENDIF.

    rt_status = mt_idoc_status.

  ENDMETHOD.
ENDCLASS.
