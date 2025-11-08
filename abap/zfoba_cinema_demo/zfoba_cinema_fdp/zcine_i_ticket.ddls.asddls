@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cinema Demo - Ticket'
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER  ]
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCINE_I_TICKET as select from zcine_a_buy
  association [1..1] to ZCINE_I_CAL as _schedule
    on $projection.Scheduleid = _schedule.Id
  association [1..1] to ZCINE_I_SEAT as _seat
    on $projection.Seatid = _seat.Id
{
  key id as Id,
  scheduleid as Scheduleid,
  seatid as Seatid,
  pricingtier as Pricingtier,
  currency as CurrencyCode,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FDP_CINEMA_CALC_PRICE'
  cast( 0 as abap.curr( 16,2 )) as TotalPrice,
  pdf as Pdf,
  rendered as Rendered,
  /* Associations */
  _seat as Seat,
  _schedule as Schedule
}
