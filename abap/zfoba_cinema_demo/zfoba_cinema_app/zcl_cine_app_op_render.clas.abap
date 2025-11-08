CLASS zcl_cine_app_op_render DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_bgmc_op_single_tx_uncontr.
    INTERFACES if_bgmc_operation_aif.
    INTERFACES if_bgmc_operation_aif_conf.

  PRIVATE SECTION.
    DATA input TYPE zcine_bgpf_render_input.
    DATA xml   TYPE xstring.
    DATA pdf   TYPE xstring.
ENDCLASS.


CLASS zcl_cine_app_op_render IMPLEMENTATION.
  METHOD if_bgmc_op_single_tx_uncontr~execute.
    TRY.
        IF input-save_pdf = abap_false AND input-send_to_pq IS INITIAL.
          " Nothing to do
          RETURN.
        ENDIF.

        DATA(form) = cl_fp_form_reader=>create_form_reader( input-formname ).
        IF form->get_fdp_name( ) IS INITIAL.
          DATA(fdp_util) = cl_fp_fdp_services=>get_instance( iv_service_definition = input-fdp_srvd ).
        ELSE.
          fdp_util = cl_fp_fdp_services=>get_instance( iv_service_definition = form->get_fdp_name( ) ).
        ENDIF.
        DATA(select_keys) = fdp_util->get_keys( ).
        DATA add_select_keys TYPE if_fp_fdp_api=>tt_select_keys.

        LOOP AT input-fdp_it_select ASSIGNING FIELD-SYMBOL(<select_param>).
          IF line_exists( select_keys[ name = <select_param>-name ] ).
            select_keys[ name = <select_param>-name ]-value     = <select_param>-value.
            select_keys[ name = <select_param>-name ]-data_type = <select_param>-data_type.
          ELSE.
            APPEND VALUE #( name      = <select_param>-name
                            data_type = <select_param>-data_type
                            value     = <select_param>-value )
                   TO add_select_keys.
          ENDIF.
        ENDLOOP.

        DATA(id) = select_keys[ name = 'ID' ]-value.

        xml = fdp_util->read_to_xml_v2( it_select     = select_keys
                                        it_select_add = add_select_keys
                                        iv_language   = input-language ).

        DATA(iso) = |{ to_lower( xco_cp=>language( input-language )->as( xco_cp_language=>format->iso_639 ) ) }_{ to_upper(
                                                                                                                      input-country ) }|.

        IF input-send_to_pq IS INITIAL.
          cl_fp_ads_util=>render_pdf( EXPORTING iv_locale     = iso
                                                iv_xml_data   = xml
                                                iv_xdp_layout = form->get_layout( )
                                                is_options    = VALUE #( embed_fonts = form->get_font_embed( )
                                                                         trace_level = input-render_trace )
                                      IMPORTING ev_pdf        = pdf ).
        ELSE.
          cl_fp_ads_util=>render_4_pq( EXPORTING iv_pq_name    = input-send_to_pq
                                                 iv_locale     = iso
                                                 iv_xml_data   = xml
                                                 iv_xdp_layout = form->get_layout( )
                                                 is_options    = VALUE #( trace_level = input-render_trace )
                                       IMPORTING ev_pdl        = pdf ).

          cl_print_queue_utils=>create_queue_item_by_data(
                                                           " Name of the print queue where result should be stored
                                                           iv_qname            = input-send_to_pq
                                                           iv_print_data       = pdf
                                                           iv_name_of_main_doc = |Ticket-{ id }| ).
        ENDIF.

        IF input-save_pdf = abap_true AND input-send_to_pq IS INITIAL.

          UPDATE zcine_a_buy
            SET rendered = @abap_true, pdf = @pdf
            WHERE id = @id.
        ENDIF.

      CATCH cx_fp_fdp_error
            cx_fp_form_reader
            cx_fp_ads_util.
        "//ToDo: Set state for retry or error
    ENDTRY.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif~get_input.
    ea_input = input.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif_conf~get_input_container.
    DATA data TYPE REF TO zcine_bgpf_render_input.

    CREATE DATA data.
    er_input_container = data.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif~set_input.
    DATA data TYPE zcine_bgpf_render_input.

    data = ia_input.
    input = data.
  ENDMETHOD.
ENDCLASS.
