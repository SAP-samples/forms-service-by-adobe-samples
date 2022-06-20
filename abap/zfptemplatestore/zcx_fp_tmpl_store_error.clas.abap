CLASS zcx_fp_tmpl_store_error DEFINITION
  public
  inheriting from CX_STATIC_CHECK
  create public .

  PUBLIC SECTION.
    interfaces IF_T100_DYN_MSG .
    interfaces IF_T100_MESSAGE .

    CONSTANTS:
      begin of SETUP_NOT_COMPLETE,
        msgid type symsgid value 'Z_TMPL_STORE',
        msgno type symsgno value '001',
        attr1 type scx_attrname value '',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of SETUP_NOT_COMPLETE,
      begin of DATA_ERROR,
        msgid type symsgid value 'Z_TMPL_STORE',
        msgno type symsgno value '002',
        attr1 type scx_attrname value 'MV_HTTP_STATUS_CODE',
        attr2 type scx_attrname value 'MV_HTTP_REASON',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of DATA_ERROR,
      begin of HTTP_CLIENT_ERROR,
        msgid type symsgid value 'Z_TMPL_STORE',
        msgno type symsgno value '003',
        attr1 type scx_attrname value 'MV_HTTP_REASON',
        attr2 type scx_attrname value '',
        attr3 type scx_attrname value '',
        attr4 type scx_attrname value '',
      end of HTTP_CLIENT_ERROR.

    data MV_HTTP_STATUS_CODE type I .
    data MV_HTTP_REASON type STRING .
    methods CONSTRUCTOR
      importing
        !TEXTID like IF_T100_MESSAGE=>T100KEY optional
        !PREVIOUS like PREVIOUS optional
        !MV_HTTP_STATUS_CODE type I optional
        !MV_HTTP_REASON type STRING optional .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcx_fp_tmpl_store_error IMPLEMENTATION.
  METHOD constructor ##ADT_SUPPRESS_GENERATION.

    CALL METHOD SUPER->CONSTRUCTOR
      EXPORTING
        PREVIOUS = PREVIOUS.
    me->MV_HTTP_STATUS_CODE = MV_HTTP_STATUS_CODE .
    me->MV_HTTP_REASON = MV_HTTP_REASON .
    clear me->textid.
    if textid is initial.
      IF_T100_MESSAGE~T100KEY = IF_T100_MESSAGE=>DEFAULT_TEXTID.
    else.
      IF_T100_MESSAGE~T100KEY = TEXTID.
    endif.

  ENDMETHOD.

ENDCLASS.
