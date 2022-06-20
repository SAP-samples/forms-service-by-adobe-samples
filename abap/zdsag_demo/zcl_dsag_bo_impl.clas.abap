CLASS zcl_dsag_bo_impl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    interfaces:
      if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dsag_bo_impl IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    if not io_request->is_data_requested(  ).
      return.
    endif.

    data(lo_filter) = io_request->get_filter(  ).
    try.
      data(lt_range) = lo_filter->get_as_ranges(  ).
    catch cx_rap_query_filter_no_range.
    endtry.

    if not line_exists( lt_range[ name = 'ID' ] ).
      "Need select parameter!
      return.
    endif.

    data rt_table type table of zi_dsag_bill_order.
    loop at lt_range[ name = 'ID' ]-range assigning field-symbol(<ls_range>).
      data(lv_id) = <ls_range>-low.
      select single * from zdsag_billdoc WHERE
        id = @lv_id INTO @DATA(ls_billdoc).

      data:
        lv_sum_excl_vat  type p LENGTH 15 DECIMALS 2 VALUE 0,
        lv_sum_vat       type p LENGTH 15 DECIMALS 2 VALUE 0,
        lv_sum_all       type p LENGTH 15 DECIMALS 2 VALUE 0,
        lv_currency      type c LENGTH 5.

      select _item~amount, _product~vat, _product~price, _product~currency from zdsag_billitem as _item
        join zdsag_product as _product on
          _item~product = _product~id
        where
          billdoc = _item~billdoc
        into TABLE @DATA(lt_bill_items).

      loop at lt_bill_items ASSIGNING FIELD-SYMBOL(<ls_bill_item>).
        if lv_currency is INITIAL.
          lv_currency = <ls_bill_item>-currency.
        endif.

        data lv_vat type p LENGTH 15 DECIMALS 2.
        data lv_price type p LENGTH 15 DECIMALS 2.
        lv_price = <ls_bill_item>-price * <ls_bill_item>-amount.
        lv_vat =  lv_price * ( <ls_bill_item>-vat / 100  ).

        lv_sum_excl_vat = lv_sum_excl_vat + lv_price.
        lv_sum_vat      = lv_sum_vat + lv_vat + lv_price.
        lv_sum_all      = lv_sum_all + lv_price + lv_vat.
      ENDLOOP.

      insert value zi_dsag_bill_order(
        created_at      = ls_billdoc-created_at
        id              = ls_billdoc-id
        payment_method  = ls_billdoc-payment_method
        receiver_id     = ls_billdoc-receiver
        sum_all         = lv_sum_all
        sum_excl_vat    = lv_sum_excl_vat
        sum_vat         = lv_sum_vat
      ) into table rt_table.
    endloop.

    io_response->set_data( rt_table ).
    io_response->set_total_number_of_records( lines( rt_table ) ).
  ENDMETHOD.

ENDCLASS.
