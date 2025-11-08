@ObjectModel.query.implementedBy: 'ABAP:ZCL_FDP_SCRATCH_IMPL'
@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]
define custom entity ZCE_FDP_SCRATCH_ROOT {
  key name: abap.string( 0 );
  language: abap.char( 1 );
  iso: abap.char( 2 );
  userAlias: abap.string( 0 );
  tz: abap.char( 6 );
  syDate: abap.char( 8 );
  syTime: abap.char( 6 );
  syURL: abap.string( 0 );
}
