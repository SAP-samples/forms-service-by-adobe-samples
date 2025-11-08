@EndUserText.label: 'Cinema Demo - Movie'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZCINE_I_MOVIE as select from zcine_a_mov
{
  key id as Id,
  title as Title,
  description as Description,
  duration as Duration,
  logo as Logo
}
