CLASS zcl_fdp_previewer_handler DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_http_service_extension.

  PROTECTED SECTION.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF execute_return,
        logs TYPE string,
        pdf  TYPE string,
      END OF execute_return.

    METHODS build_html
      RETURNING VALUE(html) TYPE string.
ENDCLASS.


CLASS zcl_fdp_previewer_handler IMPLEMENTATION.
  METHOD if_http_service_extension~handle_request.
    TRY.
        DATA(service_path) = request->get_header_field( |~path_info| ).
        CASE request->get_method( ).
          WHEN 'GET'.
            response->set_text( build_html( ) ).
            response->set_content_type( 'text/html' ).
            RETURN.
          WHEN 'POST'.
            CASE service_path.
              WHEN 'exec'.
                DATA(name)  = request->get_form_field( i_name = 'name' ).
                DATA(type)  = request->get_form_field( i_name = 'type' ).
                DATA(input) = request->get_form_field( i_name = 'input' ).

                IF type = 'PDF'.
                  DATA(form) = cl_fp_form_reader=>create_form_reader( CONV #( to_upper( name ) ) ).
                  DATA(util) = cl_fp_fdp_services=>get_instance(
                                   iv_service_definition = CONV #( to_upper( form->get_fdp_name( ) ) ) ).
                  DATA(data) = util->get_keys( ).
                ELSEIF type = 'FDP'.
                  util = cl_fp_fdp_services=>get_instance( iv_service_definition = CONV #( to_upper( name ) ) ).
                  data = util->get_keys( ).
                ELSE.
                  RAISE EXCEPTION NEW cx_sy_no_handler( ).
                ENDIF.

                /ui2/cl_json=>deserialize( EXPORTING json = input
                                           CHANGING  data = data ).

                DATA(xml) = util->read_to_xml_v2( it_select   = data
                                                  iv_language = sy-langu ).

                DATA(output) = VALUE execute_return( ).

                IF type = 'PDF'.
                  cl_fp_ads_util=>render_pdf( EXPORTING iv_locale       = 'en_US'
                                                        iv_xdp_layout   = form->get_layout( )
                                                        iv_xml_data     = xml
                                                        is_options      = VALUE #(
                                                            trace_level = 4
                                                            embed_fonts = form->get_font_embed( ) )
                                              IMPORTING ev_pdf          = DATA(pdf)
                                                        ev_trace_string = DATA(logs) ).

                  output-pdf  = cl_web_http_utility=>encode_x_base64( pdf ).
                  output-logs = logs.
                ELSEIF type = 'FDP'.
                  output-logs = xco_cp=>xstring( xml )->as_string( xco_cp_character=>code_page->utf_8 )->value.
                ENDIF.

                response->set_text( /ui2/cl_json=>serialize( data = output ) ).
                response->set_content_type( 'application/json' ).
                RETURN.
              WHEN 'keys'.
                name = request->get_form_field( i_name = 'name' ).
                type = request->get_form_field( i_name = 'type' ).

                IF type = 'PDF'.
                  form = cl_fp_form_reader=>create_form_reader( CONV #( to_upper( name ) ) ).
                  util = cl_fp_fdp_services=>get_instance(
                             iv_service_definition = CONV #( to_upper( form->get_fdp_name( ) ) ) ).
                ELSEIF type = 'FDP'.
                  util = cl_fp_fdp_services=>get_instance( iv_service_definition = CONV #( to_upper( name ) ) ).
                ELSE.
                  RAISE EXCEPTION NEW cx_sy_no_handler( ).
                ENDIF.
                response->set_text( /ui2/cl_json=>serialize( data = util->get_keys( ) ) ).
                response->set_content_type( 'application/json' ).
                RETURN.
              WHEN OTHERS.
                RAISE EXCEPTION NEW cx_sy_no_handler( ).
            ENDCASE.
            RETURN.
          WHEN OTHERS.
            RAISE EXCEPTION NEW cx_sy_no_handler( ).
        ENDCASE.
      CATCH cx_root INTO DATA(err).
        response->set_content_type( 'text/plain' ).
        response->set_text( err->get_longtext( ) ).
        response->set_status( 400 ).
    ENDTRY.
  ENDMETHOD.

  METHOD build_html.
    html = cl_web_http_utility=>decode_base64(
               |PCFET0NUWVBFIGh0bWw+DQo8aHRtbD4NCjxoZWFkPg0KICAgIDxtZXRhIGNoYXJzZXQ9InV0Zi04Ij4NCiAgICA8dGl0bGU+UHJldmlldyBGb3JtIERhdGEgUHJvdmlkZXIgVXRpbGl0eTwvdGl0bGU+DQogICAgPHNjcmlwdCBpZD0ic2FwLXVpLWJvb3RzdHJhcCIN| &&
               |CiAgICAgICAgc3JjPSJodHRwczovL3VpNS5zYXAuY29tLzEuMTM2L3Jlc291cmNlcy9zYXAtdWktY29yZS5qcyINCiAgICAgICAgZGF0YS1zYXAtdWktdGhlbWU9InNhcF9maW9yaV8zIg0KICAgICAgICBkYXRhLXNhcC11aS1saWJzPSJzYXAubSxzYXAudWkubGF5| &&
               |b3V0LHNhcC51aS5jb3JlIg0KICAgICAgICBkYXRhLXNhcC11aS1jb21wYXRWZXJzaW9uPSJlZGdlIg0KICAgICAgICBkYXRhLXNhcC11aS1hc3luYz0idHJ1ZSI+DQogICAgPC9zY3JpcHQ+DQogICAgPHNjcmlwdD4NCiAgICAgICAgc2FwLnVpLmdldENvcmUoKS5h| &&
               |dHRhY2hJbml0KGZ1bmN0aW9uKCkgew0KICAgICAgICAgLy8gQ3JlYXRlIGZvcm0gd2l0aCBpbnB1dCBmaWVsZHMNCiAgICAgICAgICB2YXIgb01vZGVsID0gbmV3IHNhcC51aS5tb2RlbC5qc29uLkpTT05Nb2RlbCh7DQogICAgICAgICAgICBuYW1lOiAiIiwNCiAg| &&
               |ICAgICAgICAgIG91dHB1dEZvcm1hdHM6IFt7bmFtZTogIkZvcm0gRGF0YSBQcm92aWRlciBTZXJ2aWNlIEJpbmRpbmciLCB2YWx1ZTogIkZEUCJ9LCB7bmFtZTogIkZvcm0gVGVtcGxhdGUiLCB2YWx1ZTogIlBERiJ9XSwNCiAgICAgICAgICAgIGxvZ3M6ICIiLA0K| &&
               |ICAgICAgICAgICAga2V5czogW10sDQogICAgICAgICAgICBlcnJvcnM6IHsNCiAgICAgICAgICAgICAgICBuYW1lOiB7DQogICAgICAgICAgICAgICAgICAgIHN0YXRlOiAiTm9uZSIsDQogICAgICAgICAgICAgICAgICAgIGVycm9yOiAiIg0KICAgICAgICAgICAg| &&
               |ICAgIH0NCiAgICAgICAgICAgIH0sDQogICAgICAgICAgICBzZWxlY3RlZE91dHB1dDogIlBERiINCiAgICAgICAgICB9KTsNCg0KICAgICAgICAgIHZhciBvRm9ybSA9IG5ldyBzYXAudWkubGF5b3V0LmZvcm0uU2ltcGxlRm9ybSh7DQogICAgICAgICAgICAgICAg| &&
               |ZWRpdGFibGU6IHRydWUsDQogICAgICAgICAgICAgICAgbGF5b3V0OiAiUmVzcG9uc2l2ZUdyaWRMYXlvdXQiLA0KICAgICAgICAgICAgICAgIGNvbnRlbnQ6IFsNCiAgICAgICAgICAgICAgICAgICAgbmV3IHNhcC5tLkxhYmVsKHt0ZXh0OiAiTmFtZSJ9KSwNCiAg| &&
               |ICAgICAgICAgICAgICAgICAgbmV3IHNhcC5tLklucHV0KHt2YWx1ZTogInsvbmFtZX0iLCB2YWx1ZVN0YXRlOiAiey9lcnJvcnMvbmFtZS9zdGF0ZX0iLCB2YWx1ZVN0YXRlVGV4dDoiey9lcnJvcnMvbmFtZS9lcnJvcn0ifSksDQogICAgICAgICAgICAgICAgICAg| &&
               |IG5ldyBzYXAubS5MYWJlbCh7dGV4dDogIklucHV0IFR5cGUifSksDQogICAgICAgICAgICAgICAgICAgIG5ldyBzYXAubS5TZWxlY3Qoew0KICAgICAgICAgICAgICAgICAgICAgICAgc2VsZWN0ZWRLZXk6ICJ7L3NlbGVjdGVkT3V0cHV0fSIsDQogICAgICAgICAg| &&
               |ICAgICAgICAgICAgICBpdGVtczogew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIHBhdGg6ICIvb3V0cHV0Rm9ybWF0cyIsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgdGVtcGxhdGU6IG5ldyBzYXAudWkuY29yZS5JdGVtKHsNCiAgICAgICAgICAg| &&
               |ICAgICAgICAgICAgICAgICAgICAga2V5OiAie3ZhbHVlfSIsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHRleHQ6ICJ7bmFtZX0iDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSkNCiAgICAgICAgICAgICAgICAgICAgICAgIH0NCiAgICAg| &&
               |ICAgICAgICAgICAgICAgfSksDQogICAgICAgICAgICAgICAgICAgIG5ldyBzYXAubS5MYWJlbCh7dGV4dDogIiJ9KSwNCiAgICAgICAgICAgICAgICAgICAgbmV3IHNhcC5tLkJ1dHRvbih7DQogICAgICAgICAgICAgICAgICAgICAgICB0ZXh0OiAiTG9hZCBLZXlz| &&
               |IiwNCiAgICAgICAgICAgICAgICAgICAgICAgIHByZXNzOiBhc3luYyAob0V2ZW50KSA9PiB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgb01vZGVsLnNldFByb3BlcnR5KCIvZXJyb3JzL25hbWUvc3RhdGUiLCAiTm9uZSIpDQogICAgICAgICAgICAgICAg| &&
               |ICAgICAgICAgICAgb01vZGVsLnNldFByb3BlcnR5KCIvZXJyb3JzL25hbWUvZXJyb3IiLCAiIikNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb25zdCBmb3JtRGF0YSA9IG5ldyBGb3JtRGF0YSgpOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIGZv| &&
               |cm1EYXRhLmFwcGVuZCgibmFtZSIsIG9Nb2RlbC5nZXRQcm9wZXJ0eSgiL25hbWUiKSApDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgZm9ybURhdGEuYXBwZW5kKCJ0eXBlIiwgb01vZGVsLmdldFByb3BlcnR5KCIvc2VsZWN0ZWRPdXRwdXQiKSApDQogICAg| &&
               |ICAgICAgICAgICAgICAgICAgICAgICAgdHJ5ew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb25zdCByZXNwID0gYXdhaXQgZmV0Y2goYC9zYXAvYmMvaHR0cC9zYXAvWkZEUF9QUkVWSUVXRVJfSFRUUC9rZXlzP3NhcC1jbGllbnQ9WFhYYCwgew0K| &&
               |ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgbWV0aG9kOiAicG9zdCIsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBib2R5OiBmb3JtRGF0YQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9KQ0KICAgICAgICAg| &&
               |ICAgICAgICAgICAgICAgICAgICAgICBjb25zdCBrZXlzID0gYXdhaXQgcmVzcC5qc29uKCkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgb01vZGVsLnNldFByb3BlcnR5KCIva2V5cyIsIGtleXMpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAg| &&
               |fSBjYXRjaCAoZSkgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBvTW9kZWwuc2V0UHJvcGVydHkoIi9lcnJvcnMvbmFtZS9zdGF0ZSIsICJFcnJvciIpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgi| &&
               |L2Vycm9ycy9uYW1lL2Vycm9yIiwgIkludmFsaWQgbmFtZSIpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICAgICAgICB9KSwNCiAgICAgICAgICAgICAgICBdDQogICAgICAgICAg| &&
               |ICB9KTsNCiAgICAgICAgICAgIA0KICAgICAgICAgICAgdmFyIG9MaXN0ID0gbmV3IHNhcC5tLkxpc3Qoew0KICAgICAgICAgICAgICAgIGl0ZW1zOiB7DQogICAgICAgICAgICAgICAgICAgIHBhdGg6ICIva2V5cyIsDQogICAgICAgICAgICAgICAgICAgIHRlbXBs| &&
               |YXRlOiBuZXcgc2FwLm0uSW5wdXRMaXN0SXRlbSh7DQogICAgICAgICAgICAgICAgICAgICAgICBsYWJlbDogIntOQU1FfSIsDQogICAgICAgICAgICAgICAgICAgICAgICBjb250ZW50OiBuZXcgc2FwLm0uSW5wdXQoe3ZhbHVlOiAie1ZBTFVFfSJ9KQ0KICAgICAg| &&
               |ICAgICAgICAgICAgICB9KQ0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgIH0pDQoNCiAgICAgICAgICAgIC8vIENyZWF0ZSBQREYgdmlld2VyICh1c2luZyBIVE1MIG9iamVjdCBmb3IgUERGKQ0KICAgICAgICAgICAgdmFyIG9QREZWaWV3ZXIgPSBuZXcg| &&
               |c2FwLm0uUERGVmlld2VyKHsNCiAgICAgICAgICAgICAgICBpc1RydXN0ZWRTb3VyY2U6IHRydWUsDQogICAgICAgICAgICAgICAgaGVpZ2h0OiAiODAwcHgiDQogICAgICAgICAgICB9KTsNCiAgICAgICAgICAgIGpRdWVyeS5zYXAuYWRkVXJsV2hpdGVsaXN0KCJi| &&
               |bG9iIik7DQogICAgICAgICAgICB2YXIgb0J1dHRvbiA9IG5ldyBzYXAubS5CdXR0b24oew0KICAgICAgICAgICAgICAgIHRleHQ6ICJFeGVjdXRlIiwNCiAgICAgICAgICAgICAgICB3aWR0aDoiMTAwJSIsDQogICAgICAgICAgICAgICAgcHJlc3M6IGFzeW5jICgp| &&
               |ID0+IHsNCiAgICAgICAgICAgICAgICAgICAgY29uc3QgYmFzZTY0VG9CbG9iID0gKHBkZikgPT4gew0KICAgICAgICAgICAgICAgICAgICAgICAgdmFyIGJhc2U2NEVuY29kZWRQREYgPSBwZGY7IC8vIHRoZSBlbmNvZGVkIHN0cmluZw0KICAgICAgICAgICAgICAg| &&
               |ICAgICAgICAgdmFyIGRlY29kZWRQZGZDb250ZW50ID0gYXRvYihiYXNlNjRFbmNvZGVkUERGKTsNCiAgICAgICAgICAgICAgICAgICAgICAgIHZhciBieXRlQXJyYXkgPSBuZXcgVWludDhBcnJheShkZWNvZGVkUGRmQ29udGVudC5sZW5ndGgpOw0KICAgICAgICAg| &&
               |ICAgICAgICAgICAgICAgZm9yICh2YXIgaSA9IDA7IGkgPCBkZWNvZGVkUGRmQ29udGVudC5sZW5ndGg7IGkrKykgew0KICAgICAgICAgICAgICAgICAgICAgICAgYnl0ZUFycmF5W2ldID0gZGVjb2RlZFBkZkNvbnRlbnQuY2hhckNvZGVBdChpKTsNCiAgICAgICAg| &&
               |ICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICAgICAgICAgIHZhciBibG9iID0gbmV3IEJsb2IoW2J5dGVBcnJheS5idWZmZXJdLCB7IHR5cGU6ICJhcHBsaWNhdGlvbi9wZGYiIH0pOw0KICAgICAgICAgICAgICAgICAgICAgICAgcmV0dXJuIFVSTC5j| &&
               |cmVhdGVPYmplY3RVUkwoYmxvYik7DQogICAgICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICAgICAgb01vZGVsLnNldFByb3BlcnR5KCIvbG9ncyIsICIiKQ0KICAgICAgICAgICAgICAgICAgICBjb25zdCBmb3JtRGF0YSA9IG5ldyBGb3JtRGF0YSgp| &&
               |Ow0KICAgICAgICAgICAgICAgICAgICBmb3JtRGF0YS5hcHBlbmQoIm5hbWUiLCBvTW9kZWwuZ2V0UHJvcGVydHkoIi9uYW1lIikgKQ0KICAgICAgICAgICAgICAgICAgICBmb3JtRGF0YS5hcHBlbmQoInR5cGUiLCBvTW9kZWwuZ2V0UHJvcGVydHkoIi9zZWxlY3Rl| &&
               |ZE91dHB1dCIpICkNCiAgICAgICAgICAgICAgICAgICAgZm9ybURhdGEuYXBwZW5kKCJpbnB1dCIsSlNPTi5zdHJpbmdpZnkob01vZGVsLmdldFByb3BlcnR5KCIva2V5cyIpKSApDQogICAgICAgICAgICAgICAgICAgIHRyeXsNCiAgICAgICAgICAgICAgICAgICAg| &&
               |ICAgIGNvbnN0IHJlc3AgPSBhd2FpdCBmZXRjaChgL3NhcC9iYy9odHRwL3NhcC9aRkRQX1BSRVZJRVdFUl9IVFRQL2V4ZWM/c2FwLWNsaWVudD1YWFhgLCB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgbWV0aG9kOiAicG9zdCIsDQogICAgICAgICAgICAg| &&
               |ICAgICAgICAgICAgICAgYm9keTogZm9ybURhdGENCiAgICAgICAgICAgICAgICAgICAgICAgIH0pDQogICAgICAgICAgICAgICAgICAgICAgICBpZiAocmVzcC5vaykgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIGNvbnN0IG91dHB1dCA9IGF3YWl0IHJl| &&
               |c3AuanNvbigpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgaWYgKG91dHB1dC5QREYpIHsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdmFyIF9wZGZ1cmwgPSBiYXNlNjRUb0Jsb2Iob3V0cHV0LlBERik7DQogICAgICAgICAgICAgICAgICAg| &&
               |ICAgICAgICAgICAgIG9QREZWaWV3ZXIuc2V0U291cmNlKF9wZGZ1cmwpOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBvUERGVmlld2VyLnNldFRpdGxlKGBQcmV2aWV3IERvY3VtZW50YCk7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfQ0K| &&
               |ICAgICAgICAgICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgiL2xvZ3MiLCBvdXRwdXQuTE9HUykNCiAgICAgICAgICAgICAgICAgICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgY29uc3Qgc3RhdHVzTXNnID0g| &&
               |YXdhaXQgcmVzcC50ZXh0KCkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBvTW9kZWwuc2V0UHJvcGVydHkoIi9sb2dzIiwgc3RhdHVzTXNnKQ0KICAgICAgICAgICAgICAgICAgICAgICAgfQ0KDQogICAgICAgICAgICAgICAgICAgIH0gY2F0Y2ggKGUpIHsN| &&
               |CiAgICAgICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgiL2xvZ3MiLCBlLm1lc3NhZ2UpDQogICAgICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICB9KQ0KDQogICAgICAgICAgICAvLyBDcmVhdGUgbGVm| &&
               |dCBwYW5lbCB3aXRoIGZvcm0gYW5kIHRhYmxlDQogICAgICAgICAgICB2YXIgb0xlZnRQYW5lbCA9IG5ldyBzYXAubS5WQm94KHsNCiAgICAgICAgICAgICAgICBpdGVtczogW29Gb3JtLCBvTGlzdCwgb0J1dHRvbl0NCiAgICAgICAgICAgIH0pOw0KICAgICAgICAg| &&
               |ICAgDQoNCiAgICAgICAgICAgIC8vIENyZWF0ZSB0ZXh0IGFyZWENCiAgICAgICAgICAgIHZhciBvVGV4dEFyZWEgPSBuZXcgc2FwLm0uVGV4dEFyZWEoew0KICAgICAgICAgICAgICAgIHdpZHRoOiAiMTAwJSIsDQogICAgICAgICAgICAgICAgaGVpZ2h0OiAiNDAw| &&
               |cHgiLA0KICAgICAgICAgICAgICAgIHBsYWNlaG9sZGVyOiAiTG9ncyB3aWxsIGJlIHNob3duIGhlcmUuLi4iLA0KICAgICAgICAgICAgICAgIHZhbHVlOiAiey9sb2dzfSINCiAgICAgICAgICAgIH0pOw0KDQogICAgICAgICAgICAvLyBDcmVhdGUgc2Vjb25kYXJ5| &&
               |IHNwbGl0IGxheW91dCAocmlnaHQgcGFuZWwpDQogICAgICAgICAgICB2YXIgb1NlY29uZGFyeVNwbGl0dGVyID0gbmV3IHNhcC51aS5sYXlvdXQuU3BsaXR0ZXIoew0KICAgICAgICAgICAgICAgIG9yaWVudGF0aW9uOiAiVmVydGljYWwiLA0KICAgICAgICAgICAg| &&
               |ICAgIGNvbnRlbnRBcmVhczogWw0KICAgICAgICAgICAgICAgICAgICBvUERGVmlld2VyLCBvVGV4dEFyZWENCiAgICAgICAgICAgICAgICBdDQogICAgICAgICAgICB9KTsNCg0KICAgICAgICAgICAgLy8gQ3JlYXRlIG1haW4gdmVydGljYWwgc3BsaXR0ZXINCiAg| &&
               |ICAgICAgICAgIHZhciBvTWFpblNwbGl0dGVyID0gbmV3IHNhcC51aS5sYXlvdXQuU3BsaXR0ZXIoew0KICAgICAgICAgICAgICAgIG9yaWVudGF0aW9uOiAiSG9yaXpvbnRhbCIsDQogICAgICAgICAgICAgICAgY29udGVudEFyZWFzOiBbDQogICAgICAgICAgICAg| &&
               |ICAgICAgIG5ldyBzYXAubS5QYW5lbCh7DQogICAgICAgICAgICAgICAgICAgICAgICBoZWFkZXJUZXh0OiAiSW5wdXQgdmFsdWVzIiwNCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbnRlbnQ6IFtvTGVmdFBhbmVsXQ0KICAgICAgICAgICAgICAgICAgICB9KSwN| &&
               |CiAgICAgICAgICAgICAgICAgICAgbmV3IHNhcC5tLlBhbmVsKHsNCiAgICAgICAgICAgICAgICAgICAgICAgIGhlYWRlclRleHQ6ICJWaWV3ZXIgJiBMb2dzIiwNCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbnRlbnQ6IFtvU2Vjb25kYXJ5U3BsaXR0ZXJdDQog| &&
               |ICAgICAgICAgICAgICAgICAgIH0pDQogICAgICAgICAgICAgICAgXQ0KICAgICAgICAgICAgfSk7DQoNCiAgICAgICAgICAgIC8vIENyZWF0ZSBhbmQgcGxhY2UgdGhlIGFwcA0KICAgICAgICAgICAgdmFyIG9BcHAgPSBuZXcgc2FwLm0uQXBwKHsNCiAgICAgICAg| &&
               |ICAgICAgICBwYWdlczogWw0KICAgICAgICAgICAgICAgICAgICBuZXcgc2FwLm0uUGFnZSh7DQogICAgICAgICAgICAgICAgICAgICAgICB0aXRsZTogIlByZXZpZXcgRm9ybSBEYXRhIFByb3ZpZGVyIFV0aWxpdHkiLA0KICAgICAgICAgICAgICAgICAgICAgICAg| &&
               |Y29udGVudDogW29NYWluU3BsaXR0ZXJdDQogICAgICAgICAgICAgICAgICAgIH0pDQogICAgICAgICAgICAgICAgXQ0KICAgICAgICAgICAgfSk7DQoNCiAgICAgICAgICAgIG9BcHAucGxhY2VBdCgiY29udGVudCIpOw0KICAgICAgICAgICAgb0FwcC5zZXRNb2Rl| &&
               |bChvTW9kZWwpOw0KICAgICAgICB9KTsNCiAgICA8L3NjcmlwdD4NCjwvaGVhZD4NCjxib2R5IGNsYXNzPSJzYXBVaUJvZHkiPg0KICAgIDxkaXYgaWQ9ImNvbnRlbnQiPjwvZGl2Pg0KPC9ib2R5Pg0KPC9odG1sPg==| ).

    REPLACE ALL OCCURRENCES OF '?sap-client=XXX' IN html WITH |?sap-client={ sy-mandt }|.
  ENDMETHOD.
ENDCLASS.
