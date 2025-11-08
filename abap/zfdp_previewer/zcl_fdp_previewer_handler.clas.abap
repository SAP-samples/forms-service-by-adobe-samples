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
|ICAgICAgICAgICAgICAgICAgICAgICAgdHJ5ew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzYXAudWkuY29yZS5CdXN5SW5kaWNhdG9yLnNob3coKQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBjb25zdCByZXNwID0gYXdhaXQgZmV0| &&
|Y2goYC9zYXAvYmMvaHR0cC9zYXAvWkZEUF9QUkVWSUVXRVJfSFRUUC9rZXlzP3NhcC1jbGllbnQ9WFhYYCwgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgbWV0aG9kOiAicG9zdCIsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg| &&
|ICAgICBib2R5OiBmb3JtRGF0YQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICB9KQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzYXAudWkuY29yZS5CdXN5SW5kaWNhdG9yLmhpZGUoKQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAg| &&
|ICAgICBjb25zdCBrZXlzID0gYXdhaXQgcmVzcC5qc29uKCkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgb01vZGVsLnNldFByb3BlcnR5KCIva2V5cyIsIGtleXMpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfSBjYXRjaCAoZSkgew0KICAg| &&
|ICAgICAgICAgICAgICAgICAgICAgICAgICAgICBzYXAudWkuY29yZS5CdXN5SW5kaWNhdG9yLmhpZGUoKQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBvTW9kZWwuc2V0UHJvcGVydHkoIi9lcnJvcnMvbmFtZS9zdGF0ZSIsICJFcnJvciIpDQogICAg| &&
|ICAgICAgICAgICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgiL2Vycm9ycy9uYW1lL2Vycm9yIiwgIkludmFsaWQgbmFtZSIpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICAgICAgICAgICAgfQ0KICAgICAg| &&
|ICAgICAgICAgICAgICB9KSwNCiAgICAgICAgICAgICAgICBdDQogICAgICAgICAgICB9KTsNCiAgICAgICAgICAgIA0KICAgICAgICAgICAgdmFyIG9MaXN0ID0gbmV3IHNhcC5tLkxpc3Qoew0KICAgICAgICAgICAgICAgIGl0ZW1zOiB7DQogICAgICAgICAgICAg| &&
|ICAgICAgIHBhdGg6ICIva2V5cyIsDQogICAgICAgICAgICAgICAgICAgIHRlbXBsYXRlOiBuZXcgc2FwLm0uSW5wdXRMaXN0SXRlbSh7DQogICAgICAgICAgICAgICAgICAgICAgICBsYWJlbDogIntOQU1FfSIsDQogICAgICAgICAgICAgICAgICAgICAgICBjb250| &&
|ZW50OiBuZXcgc2FwLm0uSW5wdXQoe3ZhbHVlOiAie1ZBTFVFfSJ9KQ0KICAgICAgICAgICAgICAgICAgICB9KQ0KICAgICAgICAgICAgICAgIH0NCiAgICAgICAgICAgIH0pDQoNCiAgICAgICAgICAgIC8vIENyZWF0ZSBQREYgdmlld2VyICh1c2luZyBIVE1MIG9i| &&
|amVjdCBmb3IgUERGKQ0KICAgICAgICAgICAgdmFyIG9QREZWaWV3ZXIgPSBuZXcgc2FwLm0uUERGVmlld2VyKHsNCiAgICAgICAgICAgICAgICBpc1RydXN0ZWRTb3VyY2U6IHRydWUsDQogICAgICAgICAgICAgICAgaGVpZ2h0OiAiODAwcHgiDQogICAgICAgICAg| &&
|ICB9KTsNCiAgICAgICAgICAgIGpRdWVyeS5zYXAuYWRkVXJsV2hpdGVsaXN0KCJibG9iIik7DQogICAgICAgICAgICB2YXIgb0J1dHRvbiA9IG5ldyBzYXAubS5CdXR0b24oew0KICAgICAgICAgICAgICAgIHRleHQ6ICJFeGVjdXRlIiwNCiAgICAgICAgICAgICAg| &&
|ICB3aWR0aDoiMTAwJSIsDQogICAgICAgICAgICAgICAgcHJlc3M6IGFzeW5jICgpID0+IHsNCiAgICAgICAgICAgICAgICAgICAgY29uc3QgYmFzZTY0VG9CbG9iID0gKHBkZikgPT4gew0KICAgICAgICAgICAgICAgICAgICAgICAgdmFyIGJhc2U2NEVuY29kZWRQ| &&
|REYgPSBwZGY7IC8vIHRoZSBlbmNvZGVkIHN0cmluZw0KICAgICAgICAgICAgICAgICAgICAgICAgdmFyIGRlY29kZWRQZGZDb250ZW50ID0gYXRvYihiYXNlNjRFbmNvZGVkUERGKTsNCiAgICAgICAgICAgICAgICAgICAgICAgIHZhciBieXRlQXJyYXkgPSBuZXcg| &&
|VWludDhBcnJheShkZWNvZGVkUGRmQ29udGVudC5sZW5ndGgpOw0KICAgICAgICAgICAgICAgICAgICAgICAgZm9yICh2YXIgaSA9IDA7IGkgPCBkZWNvZGVkUGRmQ29udGVudC5sZW5ndGg7IGkrKykgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJ5dGVB| &&
|cnJheVtpXSA9IGRlY29kZWRQZGZDb250ZW50LmNoYXJDb2RlQXQoaSk7DQogICAgICAgICAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICAgICAgICAgICAgICB2YXIgYmxvYiA9IG5ldyBCbG9iKFtieXRlQXJyYXkuYnVmZmVyXSwgeyB0eXBlOiAiYXBwbGlj| &&
|YXRpb24vcGRmIiB9KTsNCiAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiBVUkwuY3JlYXRlT2JqZWN0VVJMKGJsb2IpOw0KICAgICAgICAgICAgICAgICAgICB9DQogICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgiL2xvZ3MiLCAiIikN| &&
|CiAgICAgICAgICAgICAgICAgICAgY29uc3QgZm9ybURhdGEgPSBuZXcgRm9ybURhdGEoKTsNCiAgICAgICAgICAgICAgICAgICAgZm9ybURhdGEuYXBwZW5kKCJuYW1lIiwgb01vZGVsLmdldFByb3BlcnR5KCIvbmFtZSIpICkNCiAgICAgICAgICAgICAgICAgICAg| &&
|Zm9ybURhdGEuYXBwZW5kKCJ0eXBlIiwgb01vZGVsLmdldFByb3BlcnR5KCIvc2VsZWN0ZWRPdXRwdXQiKSApDQogICAgICAgICAgICAgICAgICAgIGZvcm1EYXRhLmFwcGVuZCgiaW5wdXQiLEpTT04uc3RyaW5naWZ5KG9Nb2RlbC5nZXRQcm9wZXJ0eSgiL2tleXMi| &&
|KSkgKQ0KICAgICAgICAgICAgICAgICAgICB0cnl7DQogICAgICAgICAgICAgICAgICAgICAgICBzYXAudWkuY29yZS5CdXN5SW5kaWNhdG9yLnNob3coKQ0KICAgICAgICAgICAgICAgICAgICAgICAgY29uc3QgcmVzcCA9IGF3YWl0IGZldGNoKGAvc2FwL2JjL2h0| &&
|dHAvc2FwL1pGRFBfUFJFVklFV0VSX0hUVFAvZXhlYz9zYXAtY2xpZW50PVhYWGAsIHsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBtZXRob2Q6ICJwb3N0IiwNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBib2R5OiBmb3JtRGF0YQ0KICAgICAgICAg| &&
|ICAgICAgICAgICAgICAgfSkNCiAgICAgICAgICAgICAgICAgICAgICAgIHNhcC51aS5jb3JlLkJ1c3lJbmRpY2F0b3IuaGlkZSgpDQogICAgICAgICAgICAgICAgICAgICAgICBpZiAocmVzcC5vaykgew0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIGNvbnN0| &&
|IG91dHB1dCA9IGF3YWl0IHJlc3AuanNvbigpDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgaWYgKG91dHB1dC5QREYpIHsNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgdmFyIF9wZGZ1cmwgPSBiYXNlNjRUb0Jsb2Iob3V0cHV0LlBERik7DQog| &&
|ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIG9QREZWaWV3ZXIuc2V0U291cmNlKF9wZGZ1cmwpOw0KICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBvUERGVmlld2VyLnNldFRpdGxlKGBQcmV2aWV3IERvY3VtZW50YCk7DQogICAgICAgICAgICAg| &&
|ICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgICAgICAgICAgICAgICAgIG9Nb2RlbC5zZXRQcm9wZXJ0eSgiL2xvZ3MiLCBvdXRwdXQuTE9HUykNCiAgICAgICAgICAgICAgICAgICAgICAgIH0gZWxzZSB7DQogICAgICAgICAgICAgICAgICAgICAgICAgICAg| &&
|Y29uc3Qgc3RhdHVzTXNnID0gYXdhaXQgcmVzcC50ZXh0KCkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBvTW9kZWwuc2V0UHJvcGVydHkoIi9sb2dzIiwgc3RhdHVzTXNnKQ0KICAgICAgICAgICAgICAgICAgICAgICAgfQ0KDQogICAgICAgICAgICAgICAg| &&
|ICAgIH0gY2F0Y2ggKGUpIHsNCiAgICAgICAgICAgICAgICAgICAgICAgIHNhcC51aS5jb3JlLkJ1c3lJbmRpY2F0b3IuaGlkZSgpDQogICAgICAgICAgICAgICAgICAgICAgICBvTW9kZWwuc2V0UHJvcGVydHkoIi9sb2dzIiwgZS5tZXNzYWdlKQ0KICAgICAgICAg| &&
|ICAgICAgICAgICB9DQogICAgICAgICAgICAgICAgfQ0KICAgICAgICAgICAgfSkNCg0KICAgICAgICAgICAgLy8gQ3JlYXRlIGxlZnQgcGFuZWwgd2l0aCBmb3JtIGFuZCB0YWJsZQ0KICAgICAgICAgICAgdmFyIG9MZWZ0UGFuZWwgPSBuZXcgc2FwLm0uVkJveCh7| &&
|DQogICAgICAgICAgICAgICAgaXRlbXM6IFtvRm9ybSwgb0xpc3QsIG9CdXR0b25dDQogICAgICAgICAgICB9KTsNCiAgICAgICAgICAgIA0KDQogICAgICAgICAgICAvLyBDcmVhdGUgdGV4dCBhcmVhDQogICAgICAgICAgICB2YXIgb1RleHRBcmVhID0gbmV3IHNh| &&
|cC5tLlRleHRBcmVhKHsNCiAgICAgICAgICAgICAgICB3aWR0aDogIjEwMCUiLA0KICAgICAgICAgICAgICAgIGhlaWdodDogIjQwMHB4IiwNCiAgICAgICAgICAgICAgICBwbGFjZWhvbGRlcjogIkxvZ3Mgd2lsbCBiZSBzaG93biBoZXJlLi4uIiwNCiAgICAgICAg| &&
|ICAgICAgICB2YWx1ZTogInsvbG9nc30iDQogICAgICAgICAgICB9KTsNCg0KICAgICAgICAgICAgLy8gQ3JlYXRlIHNlY29uZGFyeSBzcGxpdCBsYXlvdXQgKHJpZ2h0IHBhbmVsKQ0KICAgICAgICAgICAgdmFyIG9TZWNvbmRhcnlTcGxpdHRlciA9IG5ldyBzYXAu| &&
|dWkubGF5b3V0LlNwbGl0dGVyKHsNCiAgICAgICAgICAgICAgICBvcmllbnRhdGlvbjogIlZlcnRpY2FsIiwNCiAgICAgICAgICAgICAgICBjb250ZW50QXJlYXM6IFsNCiAgICAgICAgICAgICAgICAgICAgb1BERlZpZXdlciwgb1RleHRBcmVhDQogICAgICAgICAg| &&
|ICAgICAgXQ0KICAgICAgICAgICAgfSk7DQoNCiAgICAgICAgICAgIC8vIENyZWF0ZSBtYWluIHZlcnRpY2FsIHNwbGl0dGVyDQogICAgICAgICAgICB2YXIgb01haW5TcGxpdHRlciA9IG5ldyBzYXAudWkubGF5b3V0LlNwbGl0dGVyKHsNCiAgICAgICAgICAgICAg| &&
|ICBvcmllbnRhdGlvbjogIkhvcml6b250YWwiLA0KICAgICAgICAgICAgICAgIGNvbnRlbnRBcmVhczogWw0KICAgICAgICAgICAgICAgICAgICBuZXcgc2FwLm0uUGFuZWwoew0KICAgICAgICAgICAgICAgICAgICAgICAgaGVhZGVyVGV4dDogIklucHV0IHZhbHVl| &&
|cyIsDQogICAgICAgICAgICAgICAgICAgICAgICBjb250ZW50OiBbb0xlZnRQYW5lbF0NCiAgICAgICAgICAgICAgICAgICAgfSksDQogICAgICAgICAgICAgICAgICAgIG5ldyBzYXAubS5QYW5lbCh7DQogICAgICAgICAgICAgICAgICAgICAgICBoZWFkZXJUZXh0| &&
|OiAiVmlld2VyICYgTG9ncyIsDQogICAgICAgICAgICAgICAgICAgICAgICBjb250ZW50OiBbb1NlY29uZGFyeVNwbGl0dGVyXQ0KICAgICAgICAgICAgICAgICAgICB9KQ0KICAgICAgICAgICAgICAgIF0NCiAgICAgICAgICAgIH0pOw0KDQogICAgICAgICAgICAv| &&
|LyBDcmVhdGUgYW5kIHBsYWNlIHRoZSBhcHANCiAgICAgICAgICAgIHZhciBvQXBwID0gbmV3IHNhcC5tLkFwcCh7DQogICAgICAgICAgICAgICAgcGFnZXM6IFsNCiAgICAgICAgICAgICAgICAgICAgbmV3IHNhcC5tLlBhZ2Uoew0KICAgICAgICAgICAgICAgICAg| &&
|ICAgICAgdGl0bGU6ICJQcmV2aWV3IEZvcm0gRGF0YSBQcm92aWRlciBVdGlsaXR5IiwNCiAgICAgICAgICAgICAgICAgICAgICAgIGNvbnRlbnQ6IFtvTWFpblNwbGl0dGVyXQ0KICAgICAgICAgICAgICAgICAgICB9KQ0KICAgICAgICAgICAgICAgIF0NCiAgICAg| &&
|ICAgICAgIH0pOw0KDQogICAgICAgICAgICBvQXBwLnBsYWNlQXQoImNvbnRlbnQiKTsNCiAgICAgICAgICAgIG9BcHAuc2V0TW9kZWwob01vZGVsKTsNCiAgICAgICAgfSk7DQogICAgPC9zY3JpcHQ+DQo8L2hlYWQ+DQo8Ym9keSBjbGFzcz0ic2FwVWlCb2R5Ij4N| &&
|CiAgICA8ZGl2IGlkPSJjb250ZW50Ij48L2Rpdj4NCjwvYm9keT4NCjwvaHRtbD4=| ).

    REPLACE ALL OCCURRENCES OF '?sap-client=XXX' IN html WITH |?sap-client={ sy-mandt }|.
  ENDMETHOD.
ENDCLASS.
