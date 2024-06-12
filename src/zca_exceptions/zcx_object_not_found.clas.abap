class ZCX_OBJECT_NOT_FOUND definition
  public
  inheriting from ZCX_BAPI_MESSAGES
  create private .

public section.

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MO_MESSAGES type ref to ZCL_MESSAGES optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_OBJECT_NOT_FOUND IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
MO_MESSAGES = MO_MESSAGES
.
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
