CLASS zcl_cine_app_op_reset DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_bgmc_operation_aif.
    INTERFACES if_bgmc_operation_aif_conf.
    INTERFACES if_serializable_object.
    INTERFACES if_bgmc_operation.
    INTERFACES if_bgmc_op_single_tx_uncontr.

ENDCLASS.


CLASS zcl_cine_app_op_reset IMPLEMENTATION.
  METHOD if_bgmc_op_single_tx_uncontr~execute.
    TRY.
        DATA(lo_util) = NEW zcl_fdp_cinema_fill_data( ).
        lo_util->if_oo_adt_classrun~main( out = VALUE #( ) ).
      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif~get_input.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif_conf~get_input_container.
  ENDMETHOD.

  METHOD if_bgmc_operation_aif~set_input.
  ENDMETHOD.
ENDCLASS.
