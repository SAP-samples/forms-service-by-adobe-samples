@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cinema Demo - Seat'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCINE_I_SEAT as select from zcine_a_seat
  association [1..1] to ZCINE_I_ROOM as _room
    on $projection.Roomid = _room.Id
{
  key id as Id,
  roomid as Roomid,
  name as Name,
  pricetier as Pricetier,
  _room as Room
}
