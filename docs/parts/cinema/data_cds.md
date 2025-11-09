![Plantuml](/images/model.svg)

::: code-group
```abapcds [Service Definition]
@EndUserText.label: 'Cinema Demo - Service Definition'
@ObjectModel.leadingEntity.name: 'ZCINE_I_TICKET'
define service ZCINE_TICKET_SRVD {
  expose ZCINE_I_TICKET as Ticket;
  expose ZCINE_I_MOVIE  as Movie;
  expose ZCINE_I_ROOM   as Room;
  expose ZCINE_I_SEAT   as Seat;
  expose ZCINE_I_CAL    as Schedule;
}
```
```abapcds [Ticket]
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

```
```abapcds [Movie]
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
```
```abapcds [Room]
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
```
```abapcds [Seat]
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
```
```abapcds [Schedule]
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
```
```xml [XML Output]
<?xml version="1.0" encoding="utf-8"?>
<Form version="2">
  <Ticket>
    <Id>BtvpcPMMH+CvmRqWLRHhew==</Id>
    <Scheduleid>BtvpcPMMH+CvmRqGdT8Bew==</Scheduleid>
    <Seatid>BtvpcPMMH+CvmRqGdUBBew==</Seatid>
    <Pricingtier>2</Pricingtier>
    <CurrencyCode>EUR</CurrencyCode>
    <TotalPrice>12.00</TotalPrice>
    <Pdf></Pdf>
    <Rendered>false</Rendered>
    <Schedule>
      <Id>BtvpcPMMH+CvmRqGdT8Bew==</Id>
      <Begindate>20241101</Begindate>
      <Enddate>20241101</Enddate>
      <Begintime>100000</Begintime>
      <Endtime>113000</Endtime>
      <Movieid>BtvpcPMMH+CvmRqGdT6hew==</Movieid>
      <Roomid>BtvpcPMMH+CvmRqGdT4Bew==</Roomid>
      <Movie>
        <Id>BtvpcPMMH+CvmRqGdT6hew==</Id>
        <Title>UI5 - Rise of the Phoenix</Title>
        <Description>From the ashes of webdynpro a new framework may arise.</Description>
        <Duration>5400 </Duration>
        <Logo>::base64_img::</Logo>
      </Movie>
      <Room>
        <Id>BtvpcPMMH+CvmRqGdT4Bew==</Id>
        <Name>Auditorium</Name>
        <Address>SAP-Allee 37</Address>
        <Zip>68789</Zip>
        <Country>Germany</Country>
      </Room>
    </Schedule>
    <Seat>
      <Id>BtvpcPMMH+CvmRqGdUBBew==</Id>
      <Roomid>BtvpcPMMH+CvmRqGdT4Bew==</Roomid>
      <Name>B0</Name>
      <Pricetier>2</Pricetier>
      <Room>
        <Id>BtvpcPMMH+CvmRqGdT4Bew==</Id>
        <Name>Auditorium</Name>
        <Address>SAP-Allee 37</Address>
        <Zip>68789</Zip>
        <Country>Germany</Country>
      </Room>
    </Seat>
  </Ticket>
</Form>
```
:::