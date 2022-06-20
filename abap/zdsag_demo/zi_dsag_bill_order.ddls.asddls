@EndUserText.label: 'DSAG Billing Order'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DSAG_BO_IMPL'
define custom entity ZI_DSAG_BILL_ORDER
{
  key id         : abap.int4;
  receiver_id    : abap.int4;
  created_at     : timestamp;
  payment_method : abap.string(0);
  
  //Associations
  _receiver: association [1..1] to ZI_DSAG_RECEIVER
    on $projection.receiver_id = _receiver.id;
  
  _items: association [0..*] to ZI_DSAG_BILL_ITEM
    on _items.bill_id = $projection.id;
  
  //Calculated
  sum_excl_vat : abap.dec(15,2);
  sum_vat      : abap.dec(15,2);
  sum_all      : abap.dec(15,2);
  currency     : abap.cuky;
}
