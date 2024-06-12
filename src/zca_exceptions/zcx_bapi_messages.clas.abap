class ZCX_BAPI_MESSAGES definition
  public
  inheriting from CX_STATIC_CHECK
  create public .

public section.

  interfaces IF_T100_MESSAGE .

  constants OBJECT_NOT_FOUND type SOTR_CONC value 'C217F29256021EDD82F58F0DC4720454' ##NO_TEXT.
  data MO_MESSAGES type ref to ZCL_MESSAGES .

  methods CONSTRUCTOR
    importing
      !TEXTID like IF_T100_MESSAGE=>T100KEY optional
      !PREVIOUS like PREVIOUS optional
      !MO_MESSAGES type ref to ZCL_MESSAGES optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_BAPI_MESSAGES IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
PREVIOUS = PREVIOUS
.
me->MO_MESSAGES = MO_MESSAGES .
clear me->textid.
if textid is initial.
  IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
else.
  IF_T100_MESSAGE~T100KEY = TEXTID.
endif.
  endmethod.
ENDCLASS.
