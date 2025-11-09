---
outline: deep
---

# Build your first simple Form Data Provider
For getting started with form development, you only strictly require 4 artifacts:
- Form template
- Service Definition (Service Binding is **not** necessary!)
- Set of CDS views to model your business data
- ABAP Class to start the process from

Based on this knowledge we can build a simple form output, that will work on virtual data.

## Sample location:
For reference, check out the package: [ZFDP_SCRATCH](https://github.com/SAP-samples/forms-service-by-adobe-samples/tree/main/abap/zfdp_scratch)
This contains:
- Service Definition: ZFDP_SCRATCH_SRVD
- Class:  ZCL_FDP_SCRATCH_TEST

That will quickly showcase the FDP data retrieval framework.

## Sample Data Model 
For this sample we have a flat data service, that only returns the structure of the custom entity (ZCE_FDP_SCRATCH_ROOT):

::: code-group
```abapcds [Service Definition]
@EndUserText.label: 'Simple form data provider'
@ObjectModel.leadingEntity.name: 'ZCE_FDP_SCRATCH_ROOT'
define service ZFDP_SCRATCH_SRVD {
  expose ZCE_FDP_SCRATCH_ROOT;
}
```
```xml [Data Preview]
<?xml version="1.0" encoding="utf-8"?>
<Form version="2">
  <ZCE_FDP_SCRATCH_ROOT>
    <name>CB9980000000</name>
    <language>E</language>
    <iso>EN</iso>
    <userAlias>Initial Admin</userAlias>
    <tz>UTC</tz>
    <syDate>20251108</syDate>
    <syTime>205654</syTime>
    <syURL>XXX.ondemand.com</syURL>
  </ZCE_FDP_SCRATCH_ROOT>
</Form>
```
:::

::: code-group
```abapcds [Root Entity - Structure]
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
```
```abap [Root Entity - Implementation]
"...
INSERT VALUE zce_fdp_scratch_root(
    iso       = cl_abap_context_info=>get_user_language_iso_format( lv_username )
    language  = cl_abap_context_info=>get_user_language_abap_format( lv_username )
    name      = lv_username
    tz        = cl_abap_context_info=>get_user_time_zone( lv_username )
    userAlias = cl_abap_context_info=>get_user_description( lv_username )
    syDate    = cl_abap_context_info=>get_system_date( )
    syTime    = cl_abap_context_info=>get_system_time( )
    syURL     = xco_cp=>current->tenant( )->get_url( xco_cp_tenant=>url_type->ui  )->get_host( ) )
INTO TABLE table.
"...
```
:::

::: tip
Notice the annotation: 

**@ObjectModel.supportedCapabilities: [ #OUTPUT_FORM_DATA_PROVIDER ]**?

This indicates that this CDS is designed for form output. 
Please add it to your root cds entity 
:::

The custom entity implementation was deliberately shortened, as it contains a lot of boilerplate for implementing a custom entity.
This section only highlights the part, where the actual data is injected.

## Generate xml data tree from
We can transform the above data model to xml by calling our reuse class.
This works by:

1. Initialize the reuse class by passing the service definition
2. Init the select key object
3. Insert the value of your root view key properties
4. The process is designed, that using the key object, only a single root entity item shall be returned.  

```abap
DATA(util) = cl_fp_fdp_services=>get_instance( |ZFDP_SCRATCH_SRVD| ).
DATA(keys) = util->get_keys( ).
keys[ name = 'NAME' ]-value = sy-uname.
 " TODO: variable is assigned but never used (ABAP cleaner)
DATA(data) = util->read_to_xml_v2( keys ).
```

::: tip
For detailed documentation of our API, see the [online help](https://help.sap.com/docs/ABAP_PLATFORM_NEW/b5670aaaa2364a29935f40b16499972d/3d8686d312bc426d8b2aa323473996b0.html)
:::

## Generate a PDF docoument

### Upload the custom form template
You need to manually upload the form template to the ABAP system.

1. Download it [here](https://raw.githubusercontent.com/SAP-samples/forms-service-by-adobe-samples/refs/heads/main/forms/ZFORM_FDP_SCRATCH.xdp)
2. In ADT create a new **Form** object. See also our [online help](https://help.sap.com/docs/abap-cloud/abap-development-tools-user-guide/working-with-forms)
    1. Insert the Data Provider Name
    ![Init](/images/FORM_SCRATCH_ADT_1.png)
    2. Upload the template 
    ![Upload](/images/FORM_SCRATCH_ADT_2.png)
    3. Save and activate
    ![Completed](/images/FORM_SCRATCH_ADT_3.png)

### Adjust the class
After creating a new form object, it can be used via ABAP reuse class.

```abap
DATA(form) = DATA(form) = cl_fp_form_reader=>create_form_reader( CONV #( |ZFORM_FDP_SCRATCH| ) ).
DATA(util) = cl_fp_fdp_services=>get_instance( form->get_fdp_name( ) ).
DATA(keys) = util->get_keys( ).
keys[ name = 'NAME' ]-value = sy-uname.
DATA(data) = util->read_to_xml_v2( keys ).
cl_fp_ads_util=>render_pdf( 
    EXPORTING 
        iv_locale       = 'en_US'
        iv_xdp_layout   = form->get_layout( )
        iv_xml_data     = xml
        is_options      = VALUE #(
            "0 - only errors <= intended for production
            "4 - very detailed trace <= intended for development
            trace_level = 4
            embed_fonts = form->get_font_embed( ) )
    IMPORTING 
        ev_pdf          = DATA(pdf)
        ev_trace_string = DATA(logs) 
).
"If you want to output pdfs to a UI, convert xstream to base64
output-pdf  = cl_web_http_utility=>encode_x_base64( pdf ).
```

### Preview PDF using Previewer.
After implementing the above output, we might face the dilemma, that the generated pdf cannot be easily previewed.
To address this issue, the sample repository contains a dedicated tool to display your form development using a 
custom HTTP service.

Follow the [dedicated guide](/preview_util.md) to setup the tool in your system.
After setup is finished, you will be able to preview your development easily. 

![Previewer](/images/Previewer.png)

