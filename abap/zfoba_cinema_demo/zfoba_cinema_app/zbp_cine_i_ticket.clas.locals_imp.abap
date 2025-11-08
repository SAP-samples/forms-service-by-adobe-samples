CLASS lhc_ZCINE_I_TICKET DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zcine_i_ticket RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zcine_i_ticket RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zcine_i_ticket RESULT result.

    METHODS PreviewPDF FOR MODIFY
      IMPORTING keys FOR ACTION zcine_i_ticket~PreviewPDF RESULT result.

    METHODS RenderPDF FOR MODIFY
      IMPORTING keys FOR ACTION zcine_i_ticket~RenderPDF RESULT result.

    METHODS ResetDemo FOR MODIFY
      IMPORTING keys FOR ACTION zcine_i_ticket~ResetDemo.

    METHODS SendToPQ FOR MODIFY
      IMPORTING keys FOR ACTION zcine_i_ticket~SendToPQ RESULT result.

    METHODS AddRenderOperation
      IMPORTING !id    TYPE zcine_i_ticket-Id
                !input TYPE zcine_bgpf_render_input
      RAISING   cx_bgmc cx_fp_form_reader cx_fp_fdp_error.

ENDCLASS.


CLASS lhc_ZCINE_I_TICKET IMPLEMENTATION.
  METHOD get_global_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD PreviewPDF.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      SELECT SINGLE pdf FROM zcine_a_buy
        WHERE rendered = @abap_true AND id = @<key>-id
        INTO @DATA(xpdf).

      APPEND VALUE #( %cid_ref = <key>-%cid_ref
                      id       = <key>-Id
                      %param   = VALUE zcine_AE_PDF_OUTPUT( pdf = xpdf ) )
             TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD RenderPDF.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      TRY.
          " TODO: variable is assigned but never used (ABAP cleaner)
          DATA(input) = VALUE zcine_bgpf_render_input( country      = 'US'
                                                       language     = 'E'
                                                       " 4 - very detailed logs <= recommended for development
                                                       " 0 - only error log <= recommended for production
                                                       render_trace = 4
                                                       save_pdf     = abap_true ).
          AddRenderOperation(
            EXPORTING
              id = <key>-Id
              input = input
          ).
          APPEND VALUE #( %cid_ref = <key>-%cid_ref
                          id       = <key>-Id
                          %param   = <key>-Id )
                 TO result.

        CATCH cx_bgmc
              cx_fp_form_reader
              cx_fp_fdp_error.
          APPEND VALUE #( %cid_ref = <key>-%cid_ref
                          id       = <key>-Id
                          %param   = VALUE #( ) )
                 TO result.
          "//ToDo set error state for retry?
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD ResetDemo.
    DATA factory   TYPE REF TO if_bgmc_process_factory.
    DATA operation TYPE REF TO zcl_cine_app_op_reset.
    DATA process   TYPE REF TO if_bgmc_process.

    TRY.
        factory = cl_bgmc_process_factory=>get_default( ).
        operation = NEW zcl_cine_app_op_reset( ).
        process = factory->create( )->set_name( 'RESET_CINEMA_DEMO' )->set_operation_tx_uncontrolled( operation ).
        APPEND process TO zbp_cine_i_ticket=>ct_processes.
      CATCH cx_bgmc.
        "//ToDo set error state for retry?
    ENDTRY.
  ENDMETHOD.

  METHOD SendToPQ.
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
      TRY.
          " TODO: variable is assigned but never used (ABAP cleaner)
          DATA(input) = VALUE zcine_bgpf_render_input( country      = 'US'
                                                       language     = 'E'
                                                       " 4 - very detailed logs <= recommended for development
                                                       " 0 - only error log <= recommended for production
                                                       render_trace = 4
                                                       save_pdf     = abap_false
                                                       send_to_pq   = <key>-%param-pq_name ).

          AddRenderOperation(
            EXPORTING
              id = <key>-Id
              input = input
          ).
          APPEND VALUE #( %cid_ref = <key>-%cid_ref
                          id       = <key>-Id
                          %param   = <key>-Id )
                 TO result.

        CATCH cx_bgmc
              cx_fp_form_reader
              cx_fp_fdp_error.
          APPEND VALUE #( %cid_ref = <key>-%cid_ref
                          id       = <key>-Id
                          %param   = VALUE #( ) )
                 TO result.
          "//ToDo set error state for retry?
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD AddRenderOperation.
    DATA factory   TYPE REF TO if_bgmc_process_factory.
    DATA operation TYPE REF TO zcl_cine_app_op_render.
    DATA process   TYPE REF TO if_bgmc_process.

    DATA(op_input) = input.
    DATA(formname) = CONV fpname( |ZF_CINE_TICKET| ).
    factory = cl_bgmc_process_factory=>get_default( ).
    DATA(form) = cl_fp_form_reader=>create_form_reader( formname ).
    DATA(fdp)  = cl_fp_fdp_services=>get_instance( form->get_fdp_name( ) ).
    DATA(fdp_keys) = fdp->get_keys( ).
    fdp_keys[ name = 'ID' ]-value = id.
    operation = NEW zcl_cine_app_op_render( ).
    op_input-formname = formname.
    MOVE-CORRESPONDING fdp_keys TO op_input-fdp_it_select.

    operation->if_bgmc_operation_aif~set_input( op_input ).
    process = factory->create( )->set_name( 'RENDER_PDF' )->set_operation_tx_uncontrolled( operation ).
    APPEND process TO zbp_cine_i_ticket=>ct_processes.
  ENDMETHOD.
ENDCLASS.


CLASS lsc_ZCINE_I_TICKET DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save_modified    REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.


CLASS lsc_ZCINE_I_TICKET IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT zbp_cine_i_ticket=>ct_processes ASSIGNING FIELD-SYMBOL(<process>).
      TRY.
          <process>->save_for_execution( ).
        CATCH cx_bgmc.
          " Skip error handling
      ENDTRY.
      DELETE zbp_cine_i_ticket=>ct_processes.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
