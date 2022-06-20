@EndUserText.label: 'DSAG Billing item'
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.sqlViewName: 'ZI_DSAG_BILLIT'
define view ZI_DSAG_BILL_ITEM as select from zdsag_billitem 
  association [1..1] to ZI_DSAG_PRODUCT as _product 
    on
      $projection.product_id = _product.id
{
  key id,
  amount,
  billdoc as bill_id,
  product as product_id,
  _product.price_with_vat * cast( amount as abap.fltp ) as price_sum,
  _product  
}
