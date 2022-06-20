@EndUserText.label: 'Product DSAG Demo'
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
@AbapCatalog.sqlViewName: 'ZI_DSAG_PROD'
define view ZI_DSAG_PRODUCT as select from zdsag_product {
    key id,
    name,
    price,
    currency,
    vat,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_DSAG_PROD_EAN_CALC'
    cast ('' as abap.char( 13 )) as ean,
    cast (price as abap.fltp) + cast (price as abap.fltp) * ( cast(vat as abap.fltp) / cast(100 as abap.fltp) ) as price_with_vat 
}
