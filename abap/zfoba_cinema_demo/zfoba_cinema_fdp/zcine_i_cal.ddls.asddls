@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cinema Demo - Schedule'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCINE_I_CAL as select from zcine_a_cal
  association [1..1] to ZCINE_I_ROOM as _room
    on $projection.Roomid = _room.Id
  association [1..1] to ZCINE_I_MOVIE as _movie
    on $projection.Movieid = _movie.Id
{
  key id as Id,
  begindate as Begindate,
  enddate as Enddate,
  begintime as Begintime,
  endtime as Endtime,
  movieid as Movieid,
  roomid as Roomid,
  _room as Room,
  _movie as Movie
}
