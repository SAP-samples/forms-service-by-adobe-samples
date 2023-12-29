CLASS zcl_fp_tmpl_store_client DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA:
      mo_http_destination     type ref to if_http_destination,
      mv_client               type ref to if_web_http_client.
    TYPES :
      BEGIN OF ty_schema_body,
        xsd_Schema              type xstring,
        schema_Name             type c LENGTH 30,
        note                    type c LENGTH 280,
      END OF ty_schema_body,
      BEGIN OF ty_schema_body_in,
        xsd_Schema              type string,
        schema_Name             type c LENGTH 30,
        note                    type c LENGTH 280,
      END OF ty_schema_body_in,
      BEGIN OF ty_template_body,
        xdp_Template            type xstring,
        template_Name           type c LENGTH 30,
        description             type c LENGTH 280,
        note                    type c LENGTH 280,
        locale                  type c LENGTH 6,
        language                type c LENGTH 280,
        master_Language         type c LENGTH 280,
        business_Area           type c LENGTH 280,
        business_Department     type c LENGTH 280,
      END OF ty_template_body,
      BEGIN OF ty_template_body_in,
        xdp_Template            type string,
        template_Name           type c LENGTH 30,
        description             type c LENGTH 280,
        note                    type c LENGTH 280,
        locale                  type c LENGTH 6,
        language                type c LENGTH 280,
        master_Language         type c LENGTH 280,
        business_Area           type c LENGTH 280,
        business_Department     type c LENGTH 280,
      END OF ty_template_body_in,
      tt_templates type STANDARD TABLE OF ty_template_body WITH KEY template_Name,
      BEGIN OF ty_form_body,
        form_Name               type c LENGTH 30,
        description             type c LENGTH 280,
        note                    type c LENGTH 30,
      END OF ty_form_body,
      tt_forms type STANDARD TABLE OF ty_form_body WITH KEY form_Name,
      BEGIN OF ty_version_history,
        version_Object_Id       type string,
        version_Number          type string,
        is_Latest_Version       type abap_boolean,
        last_Modification_Date  type string,
      END OF ty_version_history,
      tt_versions type STANDARD TABLE OF ty_version_history WITH KEY version_object_id.
    METHODS:
      constructor
        IMPORTING
          iv_use_destination_service type abap_boolean DEFAULT abap_true
          iv_name                    type string OPTIONAL
          iv_service_instance_name   type string
        RAISING
          zcx_fp_tmpl_store_error,
      list_forms
        IMPORTING
          iv_limit  type i DEFAULT 10
          iv_offset type i DEFAULT 0
        RETURNING VALUE(rt_forms) type tt_forms
        RAISING
          zcx_fp_tmpl_store_error,
      get_form_by_name
        IMPORTING
          iv_name type string
        RETURNING VALUE(rs_form) type ty_form_body
        RAISING
           zcx_fp_tmpl_store_error,
      list_templates
        IMPORTING
          iv_form_name            type string
          iv_locale               type string OPTIONAL
          iv_language             type string OPTIONAL
          iv_template_name        type string OPTIONAL
          iv_master_language      type string OPTIONAL
          iv_business_area        type string OPTIONAL
          iv_business_department  type string OPTIONAL
          iv_limit                type i default 10
          iv_offset               type i default 0
        RETURNING VALUE(rt_templates) type tt_templates
        RAISING
           zcx_fp_tmpl_store_error,
      get_template_history_by_name
        IMPORTING
          iv_form_name      type string
          iv_template_name  type string
        RETURNING VALUE(rt_versions) type tt_versions
        RAISING
           zcx_fp_tmpl_store_error,
      get_template_by_name
        IMPORTING
          iv_get_binary    type abap_boolean default abap_false
          iv_form_name     type string
          iv_template_name type string
        RETURNING VALUE(rs_template) type ty_template_body
        RAISING
           zcx_fp_tmpl_store_error,
      get_template_by_id
        IMPORTING
          iv_form_name       type string
          iv_object_id  type string
        RETURNING VALUE(rs_template) type ty_template_body
        RAISING
           zcx_fp_tmpl_store_error,
      get_schema_history_by_name
        IMPORTING
          iv_form_name      type string
        RETURNING VALUE(rt_versions) type tt_versions
        RAISING
           zcx_fp_tmpl_store_error,
      get_schema_by_name
        IMPORTING
          iv_get_binary        type abap_boolean default abap_false
          iv_form_name         type string
        RETURNING VALUE(rs_schema) type ty_schema_body
        RAISING
          zcx_fp_tmpl_store_error,
      get_schema_by_id
        IMPORTING
          iv_form_name type string
          iv_object_id type string
        RETURNING VALUE(rs_schema) type ty_schema_body
        RAISING
           zcx_fp_tmpl_store_error,
      set_form
        IMPORTING
          iv_form_name type string
          is_form     type ty_form_body
        RAISING
           zcx_fp_tmpl_store_error,
      set_template
        IMPORTING
          iv_template_name type string
          iv_form_name type string
          is_template  type ty_template_body
        RAISING
           zcx_fp_tmpl_store_error,
      set_schema
        IMPORTING
          iv_form_name type string
          is_data      type ty_schema_body
        RAISING
          zcx_fp_tmpl_store_error,
      delete_form
        IMPORTING
          iv_form_name type string
        RAISING
           zcx_fp_tmpl_store_error,
      delete_template_in_form
        IMPORTING
          iv_form_name      type string
          iv_template_name  type string
        RAISING
           zcx_fp_tmpl_store_error,
      delete_schema_in_form
        IMPORTING
          iv_form_name    type string
        RAISING
          zcx_fp_tmpl_store_error.
  PROTECTED SECTION.
  PRIVATE SECTION.
    data:
      mv_use_dest_srv type abap_boolean,
      mv_name type string,
      mv_instance_name type string.
    methods:
      __close_request,
      __conv_path
        IMPORTING
          iv_path type string
        RETURNING VALUE(rv_path) type string,
      __get_request
        returning value(ro_request) type ref to if_web_http_request,
      __json2abap
        importing
          ir_input_data type data
        changing
          cr_abap_data  type data,
      __execute
        IMPORTING
           i_method type if_web_http_client=>method
           i_expect type i DEFAULT 200
        RETURNING VALUE(ro_response) type ref to if_web_http_response
        RAISING
          zcx_fp_tmpl_store_error.

ENDCLASS.



CLASS ZCL_FP_TMPL_STORE_CLIENT IMPLEMENTATION.


  METHOD constructor.
    mv_use_dest_srv = iv_use_destination_service.
    mv_instance_name = iv_service_instance_name.
    mv_name = iv_name.
*    TRY.
*        mv_use_dest_srv = iv_use_destination_service.
*        mv_instance_name = iv_service_instance_name.
*        mv_name = iv_name.
*
*        IF iv_use_destination_service = abap_true.
*          mo_http_destination = cl_http_destination_provider=>create_by_cloud_destination(
*            i_service_instance_name = CONV #( mv_instance_name )
*            i_name                  = mv_name
*            i_authn_mode            = if_a4c_cp_service=>service_specific
*          ).
*        ELSE.
*          mo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement(
*            comm_scenario           = CONV #( mv_instance_name )
*          ).
*        ENDIF.
*        mv_client = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).
*      CATCH
*        cx_web_http_client_error INTO DATA(x).
*        DATA(message) = x->get_text( ).
*      CATCH
*      cx_http_dest_provider_error INTO DATA(x2).
*        message = x2->get_text( ).
*        RAISE EXCEPTION TYPE zcx_fp_tmpl_store_error
*          EXPORTING
*            textid = zcx_fp_tmpl_store_error=>setup_not_complete.
*    ENDTRY.
  ENDMETHOD.


  METHOD delete_form.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }| ) ).
    data(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
    __close_request(  ).
  ENDMETHOD.


  METHOD delete_schema_in_form.
    data(ls_schema) = me->get_schema_by_name(
      iv_form_name = iv_form_name
      iv_get_binary = abap_false
    ).

    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ) ).
    lo_request->set_query( |allVersions=true| ).
    data(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
    __close_request(  ).
  ENDMETHOD.


  METHOD delete_template_in_form.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }| ) ).
    data(lo_response) = __execute(
      i_method = if_web_http_client=>delete
      i_expect = 200
    ).
    __close_request(  ).
  ENDMETHOD.


  METHOD get_form_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_name }| ) ).
    lo_request->set_query( |formData| ).
    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lo_response->get_text( )
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      assign lr_data->* to FIELD-SYMBOL(<data>).
      __json2abap(
        EXPORTING
          ir_input_data = <data>
        CHANGING
          cr_abap_data = rs_form
      ).

    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_schema_by_id.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/schema/{ iv_object_id }| ) ).
    lo_request->set_query( |select=xsdSchema,schemaData&isObjectId=true| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      assign lr_data->* to FIELD-SYMBOL(<data>).
      __json2abap(
        EXPORTING
          ir_input_data = <data>
        CHANGING
          cr_abap_data = rs_schema
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_schema_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }| ) ).
    if iv_get_binary = abap_true.
      lo_request->set_query( |select=schemaData,xsdSchema| ).
    else.
      lo_request->set_query( |select=schemaData| ).
    endif.

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      assign lr_data->* to FIELD-SYMBOL(<data>).

      assign component 'SCHEMA' of structure <data> to FIELD-SYMBOL(<schema>).

      if <schema> is assigned.
        __json2abap(
          EXPORTING
            ir_input_data = <schema>->*
          CHANGING
            cr_abap_data = rs_schema
        ).
      else.
        raise EXCEPTION type zcx_fp_tmpl_store_error
          EXPORTING
            mv_http_status_code = 404
            mv_http_reason = 'No schema maintained for form'
            textid = zcx_fp_tmpl_store_error=>data_error.
      endif.

    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_schema_history_by_name.
    data(ls_schema) = me->get_schema_by_name(
      iv_form_name = iv_form_name
      iv_get_binary = abap_false
    ).
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ) ).
    lo_request->set_query( |select=schemaData,schemaVersions| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      field-SYMBOLS: <versions> type STANDARD TABLE.

      assign lr_data->* to FIELD-SYMBOL(<data>).
      assign component `VERSIONS` of structure <data> to <versions>.

      loop at <versions> ASSIGNING FIELD-SYMBOL(<version>).
        data ls_version type ty_version_history.

        __json2abap(
          EXPORTING
            ir_input_data = <version>->*
          CHANGING
            cr_abap_data = ls_version
        ).

        append ls_version to rt_versions.
      endloop.

    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_template_by_id.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates/{ iv_object_id }| ) ).
    lo_request->set_query( |select=xdpTemplate,templateData&isObjectId=true| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      assign lr_data->* to FIELD-SYMBOL(<data>).
      __json2abap(
          EXPORTING
            ir_input_data = <data>->*
          CHANGING
            cr_abap_data = rs_template
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_template_by_name.

    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ) ).
    if iv_get_binary = abap_true.
      lo_request->set_query( |select=xdpTemplate,templateData| ).
    else.
      lo_request->set_query( |select=templateData| ).
    endif.
    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      assign lr_data->* to FIELD-SYMBOL(<data>).
      __json2abap(
          EXPORTING
            ir_input_data = <data>
          CHANGING
            cr_abap_data = rs_template
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD get_template_history_by_name.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ) ).
    lo_request->set_query( |select=templateData,templateVersions| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      field-SYMBOLS: <versions> type STANDARD TABLE.

      assign lr_data->* to FIELD-SYMBOL(<data>).
      assign component `VERSIONS` of structure <data> to <versions>.

      loop at <versions> ASSIGNING FIELD-SYMBOL(<version>).
        data ls_version type ty_version_history.

        __json2abap(
          EXPORTING
            ir_input_data = <version>->*
          CHANGING
            cr_abap_data = ls_version
        ).

        append ls_version to rt_versions.
      endloop.

    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD list_forms.
    DATA(lo_request) = __get_request( ).
    lo_request->set_uri_path( __conv_path( |/v1/forms| ) ).
    lo_request->set_query( |limit={ iv_limit }&offset={ iv_offset }&select=formData| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      field-symbols:
         <data> type any table.

      assign lr_data->* to <data>.

      loop at <data> assigning FIELD-SYMBOL(<form>).
        data ls_form type ty_form_body.

        __json2abap(
          EXPORTING
            ir_input_data = <form>->*
          CHANGING
            cr_abap_data = ls_form
        ).

        append ls_form to rt_forms.
      endloop.
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD list_templates.
    DATA(lo_request) = __get_request( ).
    data(lv_query) = |select=templateData&limit={ iv_limit }&offset={ iv_offset }|.
    if iv_business_area is not initial.
      lv_query = lv_query && |&businessArea={ iv_business_area }|.
    endif.

    if iv_business_department is not initial.
      lv_query = lv_query && |&businessDepartment={ iv_business_department }|.
    endif.

    if iv_language is not initial.
      lv_query = lv_query && |&language={ iv_language }|.
    endif.

    if iv_locale is not initial.
      lv_query = lv_query && |&locale={ iv_locale }|.
    endif.

    if iv_master_language is not initial.
      lv_query = lv_query && |&masterLanguage={ iv_master_language }|.
    endif.

    if iv_template_name is not initial.
      lv_query = lv_query && |&templateName={ iv_template_name }|.
    endif.

    lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates| ) ).
    lo_request->set_query( |limit={ iv_limit }&offset={ iv_offset }&select=formData| ).

    data(lo_response) = __execute(
      i_method = if_web_http_client=>get
      i_expect = 200
    ).

    DATA(lv_json_response) = lo_response->get_text( ).
    DATA lr_data type ref to data.
    lr_data = /ui2/cl_json=>generate(
      json = lv_json_response
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    if lr_data is bound.
      field-symbols: <data> type any table.

      assign lr_data->* to <data>.

      loop at <data> assigning field-symbol(<template>).
        data ls_template type ty_template_body.

        __json2abap(
          exporting
            ir_input_data = <template>->*
          CHANGING
            cr_abap_data = ls_template
        ).

        append ls_template to rt_templates.

      endloop.
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD set_form.
    data(lv_exists) = abap_false.

    try.
      me->get_form_by_name( iv_name = iv_form_name ).
      lv_exists = abap_true.
    catch zcx_fp_tmpl_store_error into data(lo_data_error).
      if lo_data_error->mv_http_status_code <> 404.
        raise exception lo_data_error.
      ENDIF.
    endtry.

    DATA(lo_request) = __get_request( ).
    if lv_exists = abap_true.
      lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }| ) ).
    else.
      lo_request->set_uri_path( __conv_path( |/v1/forms| ) ).
    ENDIF.

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = is_form
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    if lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    else.
      __execute(
        i_method = if_web_http_client=>post
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD set_schema.
    data(lv_exists) = abap_false.

    try.
      data(ls_schema) = me->get_schema_by_name(
        iv_form_name = iv_form_name
        iv_get_binary = abap_false
      ).
      lv_exists = abap_true.
    catch zcx_fp_tmpl_store_error into data(lo_data_error).
      if lo_data_error->mv_http_status_code <> 404.
        raise exception lo_data_error.
      ENDIF.
    endtry.

    DATA(lo_request) = __get_request( ).
    if lv_exists = abap_true.
      lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/schema/{ ls_schema-schema_name }| ) ).
    else.
      lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/schema| ) ).
    ENDIF.

    data(ls_body) = value ty_schema_body_in(
      note = is_data-note
      schema_name = is_data-schema_name
      xsd_schema = cl_web_http_utility=>encode_base64( cl_web_http_utility=>decode_utf8( is_data-xsd_schema ) )
    ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = ls_body
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    if lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    else.
      __execute(
        i_method = if_web_http_client=>post
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD set_template.
    data(lv_exists) = abap_false.

    try.
      data(lv_template) = me->get_template_by_name(
        iv_form_name = iv_form_name
        iv_get_binary = abap_false
        iv_template_name = iv_template_name
      ).
      lv_exists = abap_true.
    catch zcx_fp_tmpl_store_error into data(lo_data_error).
      if lo_data_error->mv_http_status_code <> 404.
        raise exception lo_data_error.
      ENDIF.
    endtry.

    DATA(lo_request) = __get_request( ).
    if lv_exists = abap_true.
      lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates/{ iv_template_name }| ) ).
    else.
      lo_request->set_uri_path( __conv_path( |/v1/forms/{ iv_form_name }/templates| ) ).
    ENDIF.

    data(ls_body) = value ty_template_body_in(
      note = is_template-note
      business_area = is_template-business_area
      business_department = is_template-business_department
      description = is_template-description
      language = is_template-language
      locale = is_template-locale
      master_language = is_template-master_language
      template_name = is_template-template_name
      xdp_template = cl_web_http_utility=>encode_base64( cl_web_http_utility=>decode_utf8( is_template-xdp_template ) )
    ).

    DATA(lv_json) = /ui2/cl_json=>serialize(
      data = ls_body
      compress = abap_true
      pretty_name = /ui2/cl_json=>pretty_mode-camel_case
    ).

    lo_request->append_text(
        EXPORTING
          data   = lv_json
    ).

    if lv_exists = abap_true.
      __execute(
        i_method = if_web_http_client=>put
      ).
    else.
      __execute(
        i_method = if_web_http_client=>post
      ).
    endif.
    __close_request(  ).
  ENDMETHOD.


  METHOD __execute.
    try.
      ro_response = mv_client->execute( i_method = i_method ).
      if ro_response->get_status(  )-code <> i_expect.
        RAISE EXCEPTION type zcx_fp_tmpl_store_error
          EXPORTING
            textid = zcx_fp_tmpl_store_error=>data_error
            mv_http_status_code = ro_response->get_status(  )-code
            mv_http_reason = ro_response->get_status(  )-reason.
      ENDIF.
    catch cx_web_http_client_error into data(lo_http_error).
      RAISE EXCEPTION type zcx_fp_tmpl_store_error
        EXPORTING
          textid = zcx_fp_tmpl_store_error=>http_client_error
          mv_http_reason = lo_http_error->get_longtext( ).
    endtry.
  ENDMETHOD.


  METHOD __json2abap.
    data(lo_input_struct)   = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = ir_input_data ) ).
    data(lo_target_struct)  = cast cl_abap_structdescr( cl_abap_structdescr=>describe_by_data( p_data = cr_abap_data ) ).


    LOOP at lo_input_struct->components ASSIGNING FIELD-SYMBOL(<ls_component>).
      if line_exists( lo_target_struct->components[ name = <ls_component>-name ] ).
        assign component <ls_component>-name of structure ir_input_data to FIELD-SYMBOL(<field_in_data>).
        assign component <ls_component>-name of structure cr_abap_data to FIELD-SYMBOL(<field_out_data>).

        if lo_target_struct->components[ name = <ls_component>-name ]-type_kind = cl_abap_typedescr=>typekind_xstring.
          <field_out_data> = cl_web_http_utility=>decode_x_base64( <field_in_data>->* ).
        else.
          <field_out_data> = <field_in_data>->*.
        endif.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD __get_request.
    try.
      if mv_client is BOUND.
        mv_client->close(  ).
      endif.
      IF mv_use_dest_srv = abap_true.
        mo_http_destination = cl_http_destination_provider=>create_by_cloud_destination(
          i_service_instance_name = CONV #( mv_instance_name )
          i_name                  = mv_name
          i_authn_mode            = if_a4c_cp_service=>service_specific
        ).
      ELSE.
        mo_http_destination = cl_http_destination_provider=>create_by_comm_arrangement(
          comm_scenario           = CONV #( mv_instance_name )
        ).
      ENDIF.
      mv_client = cl_web_http_client_manager=>create_by_http_destination( mo_http_destination ).
    catch cx_web_http_client_error cx_http_dest_provider_error .
    endtry.

    ro_request = mv_client->get_http_request( ).
    ro_request->set_header_fields( VALUE #(
      ( name = 'Accept' value = 'application/json, text/plain, */*'  )
      ( name = 'Content-Type' value = 'application/json;charset=utf-8'  )
    ) ).
  ENDMETHOD.

  METHOD __CONV_PATH.
    rv_path = iv_path.
    if mv_use_dest_srv = abap_false.
      SHIFT rv_path left.
    endif.
  ENDMETHOD.

  METHOD __close_request.

  ENDMETHOD.

ENDCLASS.
