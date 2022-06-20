@AbapCatalog.sqlViewName: 'ZI_DSAG_RECEIV'
@EndUserText.label: 'Receiver CDS view'
@ClientHandling.type: #CLIENT_DEPENDENT
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view ZI_DSAG_RECEIVER as select from zdsag_receiver {
  key id,
  name,
  street,
  zip,
  country
}
