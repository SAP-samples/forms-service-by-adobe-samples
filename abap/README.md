# Integrate SAP Forms Service by Adobe with SAP BTP, ABAP Environment in Cloud Foundry

This sample contains:
- Short guide what service is needed and how to set them up
- Example data + form template

## Table of contents

- [Prerequisites](#prerequisites)
  * [SAP Business Technology Platform](#sap-business-technology-platform)
  * [Local Machine](#local-machine)
- [Setup](#setup)
  * [SAP Forms Service by Adobe](#sap-forms-service-by-adobe)
  * [Destination](#destination)
  * [ABAP Environment](#abap-environment)
  * [SAP Cloud Print Manager for Pull Integration](#sap-cloud-print-manager-for-pull-integration)
- [Execute example](#execute-example)
  * [Upload demo template](#upload-demo-template)
  * [Create test data](#create-test-data)
  * [Execute Scenario](#execute-scenario)

### Prerequisites
#### SAP Business Technology Platform
- Create or use an existing account on [SAP Business Technology Platform](https://www.sap.com/germany/products/business-technology-platform.html)
- Order [SAP Forms service by Adobe](https://discovery-center.cloud.sap/serviceCatalog/forms-service-by-adobe?region=all) via Service Marketplace
- Order [SAP Forms service by Adobe API](https://discovery-center.cloud.sap/serviceCatalog/forms-service-by-adobe?region=all) via Service Marketplace
- Order [ABAP environment](https://discovery-center.cloud.sap/serviceCatalog/abap-environment?region=all) via Service Marketplace
- Use [SAP Destination service](https://discovery-center.cloud.sap/serviceCatalog/destination?service_plan=lite&region=all&licenseModel=cpea) via Service Marketplace
- Perform basic [SAP BTP, ABAP environment Setup](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/a999fac2a578468ea0e4e320c82145ce.html).

#### Local Machine
- Download [ABAP Development Tools](https://launchpad.support.sap.com/#/softwarecenter/template/products/%20_APP=00200682500000001943&_EVENT=DISPHIER&HEADER=Y&FUNCTIONBAR=N&EVENT=TREE&NE=NAVIGATE&ENR=01200314690100008586&V=MAINT&TA=ACTUAL&PAGE=SEARCH/SAP%20ABAP%20IN%20ECLIPSE) and connect them to your ABAP Environment
- Download [Adobe LiveCycle Designer](https://launchpad.support.sap.com/#/softwarecenter/search/Adobe%20Livecycle%20Designer%2011)
- Download [SAP Cloud Print Manager for Pull Integration](https://launchpad.support.sap.com/#/softwarecenter/template/products/%20_APP=00200682500000001943&_EVENT=DISPHIER&HEADER=Y&FUNCTIONBAR=N&EVENT=TREE&NE=NAVIGATE&ENR=73554900100200013761&V=MAINT&TA=ACTUAL&PAGE=SEARCH/SAP%20CLOUD%20PRNT%20MGR%20770%20FOR%20P)

### Setup
#### SAP Forms Service by Adobe
1. Create new subscription for Forms Service by Adobe (plan: default)
2. Assign roles to the admin user
    - `ADSAdmin` for accessing SAP Forms Service by Adobe Config UI (used for maintaining fonts, xdc, xci, etc.)
    - `TemplateStoreAdmin` for accessing the Template Store UI
3. Create new instance and service key for service: **Forms Service by Adobe** (plan: standard)
4. Create new instance and service key for service: **Forms Service by Adobe API** (plan: standard)

#### SAP Destination service
1. Create new instance and service key for service: **Destination**
2. Maintain a new destination pointing to service instance of **Forms Service by Adobe API** using the corresponding service key

#### ABAP Environment
1. Navigate to app: **Maintain Communication Users** and create a new user with username + password (used for accessing the print queue)
2. Navigate to app: **Communication Systems**
3. Create a new communication system (to connect to Forms Service by Adobe service instance)
    - System ID: `any name`
    - System Name: `any name`
    - Host Name: `uri in service key`
    - Auth. Endpoint: `uaa.url in service key>/oauth/authorize`
    - Token Endpoint: `uaa.url in service key>/oauth/token`
    - Create new **Users for Outbound Communication**:
        - Authentication Method: `OAuth 2.0`
        - OAuth 2.0 Client ID: `uaa.clientid in service key`
        - Client Secret: `uaa.clientsecret in service key`
    - Save the system
4. Navigate to app: **Communication Arrangement**
5. Create a new communication arrangement (scenario: SAP_COM_0503):
    - Communication System: `System that connects to Forms Service by Adobe service instance`
    - OAuth 2.0 Client ID: `Should be auto selected`
    - Path: `/AdobeDocumentServicesSec/Config`
6. Check connection should return following error: **Method Not Allowed (405)**
7. Create a new communication arrangement (scenario: SAP_COM_0276) with service key of destination service instance
8. Create a new communication arrangement (scenario: SAP_COM_0466):
    - Inbound Communication: `select communication user for print_queue`
9. Navigate to app: **Maintain Print Queues**
10. Create a new print queue, select communication user for print queue
    
#### SAP Cloud Print Manager for Pull Integration
1. Start the desktop app
2. Start all needed services
3. Create a new runtime system:
    - SAP System URL: `click button: System URL in Maintain Print Queues app`
    - User: `username of communication user`
    - Password: `password of communication user`
4. Double click print queue and maintain settings

### Execute example

#### Upload demo template
1. [Access Template Store Admin UI](https://help.sap.com/docs/CP_FORMS_BY_ADOBE/dcbea777ceb3411cb10500a1a392273e/1069ce905dda4481a89f13a8b6c20ac1.html/#result)
2. Create a new Form
3. Upload [Demo Template](https://github.com/SAP-samples/forms-service-by-adobe-samples/blob/main/abap/Form.xdp)

#### Create test data

1. Import the project: https://github.com/SAP-samples/forms-service-by-adobe-samples.git via abapGit plugin in ADT
2. Activate all imported objects
3. Execute class **zcl_dsag_fill_data** with \[F9\]

#### Execute Scenario

1. Open the class: zcl_dsag_execute_fdp
2. Maintain following changes: 
    ```abap
    data(lo_store) = new ZCL_FP_TMPL_STORE_CLIENT(
        iv_name = 'restapi' "<= name of the destination (in destination service instance) pointing to Forms Service by Adobe API service instance
        iv_service_instance_name = 'SAP_COM_0276' "<= name of communication arrangement with scenario SAP_COM_0276
      ).
    ```
    ```abap
    lo_store->set_schema(
        iv_form_name = 'DSAG_DEMO' "<= form object where schema is stored in template store
        is_data = value #( note = '' schema_name = 'schema' xsd_schema = lo_fdp_util->get_xsd(  )  )
    ).
    ```
    ```abap
    data(ls_template) = lo_store->get_template_by_name(
        iv_get_binary     = abap_true
        iv_form_name      = 'DSAG_DEMO' "<= form object in template store
        iv_template_name  = 'TEMPLATE' "<= template (in form object) that should be used
    ).
    ```
    ```abap
    cl_fp_ads_util=>render_4_pq(
        EXPORTING
          iv_locale       = 'en_US'
          iv_pq_name      = 'PRINT_QUEUE' "<= Name of the print queue where result should be stored
          iv_xml_data     = lv_xml
          iv_xdp_layout   = ls_template-xdp_template
          is_options      = value #(
            trace_level = 4 "Use 0 in production environment
          )
        IMPORTING
          ev_trace_string = data(lv_trace)
          ev_pdl          = data(lv_pdf)
    ).
    ```
    ```abap
    cl_print_queue_utils=>create_queue_item_by_data(
        iv_qname = 'PRINT_QUEUE' "<= Name of the print queue where result should be stored
        iv_print_data = lv_pdf
        iv_name_of_main_doc = 'DSAG DEMO Output'
    ).    
    ```
3. Execute class with \[F9\]
4. If cloud print manager is running the pdf should be saved / printed
