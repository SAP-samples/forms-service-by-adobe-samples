CLASS zcl_fdp_scratch_test DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.


CLASS zcl_fdp_scratch_test IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    TRY.
        DATA(util) = cl_fp_fdp_services=>get_instance( |ZFDP_SCRATCH_SRVD| ).
        DATA(keys) = util->get_keys( ).
        keys[ name = 'NAME' ]-value = sy-uname.
        " TODO: variable is assigned but never used (ABAP cleaner)
        DATA(data) = util->read_to_data( keys ).
        out->write( 'Execution successful' ).
      CATCH cx_fp_fdp_error INTO DATA(err).
        out->write( 'Execution encounted an error:' ).
        out->write( err->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
