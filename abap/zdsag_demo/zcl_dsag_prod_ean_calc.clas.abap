CLASS zcl_dsag_prod_ean_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces IF_SADL_EXIT_CALC_ELEMENT_READ.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dsag_prod_ean_calc IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    data(lo_generator) = cl_abap_random_int=>create(
      seed = cl_abap_random=>seed(  )
      min = 0
      max = 9
    ).

    LOOP AT it_requested_calc_elements INTO DATA(lv_virtual_field_name).
      LOOP AT ct_calculated_data ASSIGNING FIELD-SYMBOL(<ls_calculation_structure>).
        ASSIGN COMPONENT lv_virtual_field_name OF STRUCTURE <ls_calculation_structure> TO FIELD-SYMBOL(<lv_virtual_field_value>).
        IF lv_virtual_field_name = 'EAN'.
          data lv_ean type string VALUE ''.
          clear lv_ean.


          do 10 times.
            lv_ean = lv_ean && lo_generator->get_next(  ).
          enddo.

          <lv_virtual_field_value> = lv_ean.

        ELSE.
          "Data Initialization for this type is not implemented yet
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

  ENDMETHOD.

ENDCLASS.
