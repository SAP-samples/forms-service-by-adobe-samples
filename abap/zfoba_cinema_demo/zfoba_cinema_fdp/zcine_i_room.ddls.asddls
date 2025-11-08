@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cinema Demo - Room'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCINE_I_ROOM as select from zcine_a_roo
{
  key id as Id,
  name as Name,
  address as Address,
  zip as Zip,
  country as Country
}
