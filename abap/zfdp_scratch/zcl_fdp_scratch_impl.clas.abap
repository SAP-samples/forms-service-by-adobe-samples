CLASS zcl_fdp_scratch_impl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
ENDCLASS.


CLASS zcl_fdp_scratch_impl IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    " Data request always expected
    IF NOT io_request->is_data_requested( ).
      RETURN.
    ENDIF.

    DATA(filter) = io_request->get_filter( ).
    TRY.
        DATA(range) = filter->get_as_ranges( ).
        IF NOT line_exists( range[ name = 'NAME' ] ).
          " Our primary key is missing
          RETURN.
        ENDIF.
      CATCH cx_rap_query_filter_no_range.
        RETURN.
    ENDTRY.

    " Paging needs to be called, even though values are not handled further
    " TODO: variable is assigned but never used (ABAP cleaner)
    DATA(paging) = io_request->get_paging( ).

    DATA table TYPE TABLE OF zce_fdp_scratch_root.

    LOOP AT range[ name = 'NAME' ]-range ASSIGNING FIELD-SYMBOL(<ls_range>).

      DATA lv_username TYPE cl_abap_context_info=>ty_user_name.
      lv_username = <ls_range>-low.
      TRY.
          INSERT VALUE zce_fdp_scratch_root(
              iso       = cl_abap_context_info=>get_user_language_iso_format( lv_username )
              language  = cl_abap_context_info=>get_user_language_abap_format( lv_username )
              name      = lv_username
              tz        = cl_abap_context_info=>get_user_time_zone( lv_username )
              userAlias = cl_abap_context_info=>get_user_description( lv_username )
              syDate    = cl_abap_context_info=>get_system_date( )
              syTime    = cl_abap_context_info=>get_system_time( )
              syURL     = xco_cp=>current->tenant( )->get_url( xco_cp_tenant=>url_type->ui  )->get_host( ) )
                 INTO TABLE table.
        CATCH cx_abap_context_info_error.
          CONTINUE.
      ENDTRY.
    ENDLOOP.

    io_response->set_data( table ).
    io_response->set_total_number_of_records( lines( table ) ).
  ENDMETHOD.
ENDCLASS.
