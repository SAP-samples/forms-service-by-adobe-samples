CLASS zcl_fdp_cinema_calc_price DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
ENDCLASS.


CLASS zcl_fdp_cinema_calc_price IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA calculated_data TYPE STANDARD TABLE OF zcine_i_ticket WITH DEFAULT KEY.

    MOVE-CORRESPONDING it_original_data TO calculated_data.

    LOOP AT calculated_data ASSIGNING FIELD-SYMBOL(<data>).
      SELECT SINGLE * FROM zcine_i_seat WHERE id = @<data>-seatid INTO @DATA(seat).
      DATA total TYPE p LENGTH 16 DECIMALS 2.

      " Base charge
      CASE <data>-PricingTier.
        WHEN 1.
          total = 8.
        WHEN 2.
          total = 10.
        WHEN 3.
          total = 12.
      ENDCASE.

      " Seat charge
      CASE seat-pricetier.
        WHEN 1.
          total += 0.
        WHEN 2.
          total += 2.
        WHEN 3.
          total += 4.
      ENDCASE.

      <data>-TotalPrice = total.
    ENDLOOP.

    MOVE-CORRESPONDING calculated_data TO ct_calculated_data.
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
  ENDMETHOD.
ENDCLASS.
