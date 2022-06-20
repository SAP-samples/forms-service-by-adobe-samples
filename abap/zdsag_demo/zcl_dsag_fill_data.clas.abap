CLASS zcl_dsag_fill_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dsag_fill_data IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    data:
      lt_bill_doc   type STANDARD TABLE OF zdsag_billdoc,
      lt_bill_item  type STANDARD TABLE OF zdsag_billitem,
      lt_receiver   type STANDARD TABLE OF zdsag_receiver,
      lt_product    type STANDARD TABLE OF zdsag_product.

    delete from zdsag_billdoc.
    delete from zdsag_billitem.
    delete from zdsag_product.
    delete from zdsag_receiver.

    append value zdsag_receiver(
      client          = 100
      id              = 1
      country         = 'USA'
      zip             = 'New York, NY 10023'
      street          = '123 Sesame Street'
      name            = 'Cookie Monster'
    ) to lt_receiver.


    append value zdsag_billdoc(
      client          = 100
      created_at      = 20220523164722
      id              = 1
      payment_method  = 'Cash'
      receiver        = 1
    ) to lt_bill_doc.

    append value zdsag_billitem(
      client          = 100
      billdoc         = 1
      id              = 1
      amount          = 10000
      product         = 1
    ) to lt_bill_item.

    append value zdsag_billitem(
      client          = 100
      billdoc         = 1
      id              = 2
      amount          = 1
      product         = 2
    ) to lt_bill_item.

    append value zdsag_product(
      client          = 100
      name            = 'Cookie'
      currency        = 'EUR'
      id              = 1
      price           = '5'
      vat             = 7
    ) to lt_product.

    append value zdsag_product(
      client          = 100
      name            = 'Versandkosten'
      currency        = 'EUR'
      id              = 2
      price           = '100'
      vat             = 19
    ) to lt_product.

    insert zdsag_billdoc  FROM TABLE @lt_bill_doc.
    insert zdsag_billitem FROM TABLE @lt_bill_item.
    insert zdsag_product  FROM TABLE @lt_product.
    insert zdsag_receiver FROM TABLE @lt_receiver.

  ENDMETHOD.

ENDCLASS.
