---
outline: deep
---

# Cinema Demo
In this demo we explore an advanced usecase, where we build a full end-to-end application.

Features:
- RAP App
- bgPF Integration
- Print Queue Integration
- Custom fonts for rendering

Preview:
![Cinema Demo](/images/cinema_demo.png "Our goal, a cinema ticket system with printing functionality")
## Setup

### Upload form template
1. Download it [here](https://raw.githubusercontent.com/SAP-samples/forms-service-by-adobe-samples/refs/heads/main/forms/ZF_CINE_TICKET.xdp)
2. Upload it to the abap system, as data source link it to: **ZCINE_TICKET_SRVD**
![Upload ZF_CINE_TICKET](/images/FORM_ZF_CINE_TICKET.png)
3. Enable embed font usage, so custom fonts will be embedded to the output

### Upload custom font

#### S/4 HANA Cloud Public Edition
1. Navigate to the app: [**Adobe Document Services Config**](https://fioriappslibrary.hana.ondemand.com/sap/fix/externalViewer/#/detail/Apps('F4971'))
::: tip
Your user needs the role: **SAP_BR_XXXISTRATOR** to see the app
:::
2. Download the [SAP-Icon Font](https://github.com/SAP-samples/forms-service-by-adobe-samples/raw/refs/heads/main/forms/SAP-icons.ttf) and upload it via the app
![Upload font](/images/F4971_1.png)
3. If everything works and you press: **Go**, the fonts should appear in the list
![Upload font success](/images/F4971_2.png)

#### BTP, ABAP environment
1. Login to BTP Cloud Foundry Cockpit
2. Open the subaccount, where Forms service by Adobe is subscribed
3. Create and Assign yourself a role collection that contains the role **ADSAdmin**
4. Navigate to **Instances and Subscriptions**
5. Press on the Application: Forms Service by Adobe
6. Press on **Setup**
::: tip
Note: If you see 'Forbidden' error, check if the role was assigned to your user and try again in a private browser session
:::
7. Navigate on the left to **Fonts**
Press upload and select your local font file
![Upload font success](/images/ADS_CONFIGUI_FONTS.png)

### Clone the ABAPgit sample package
1. Clone the following package and all of its sub packages to the system: [ZFOBA_CINEMA_DEMO](https://github.com/SAP-samples/forms-service-by-adobe-samples/tree/main/abap/zfoba_cinema_demo)
2. Locally publish the service binding **ZCINE_APP_UI_SB**
3. Run ZCL_FDP_CINEMA_FILL_DATA once in ADT, to reset and populate demo data to the system. This can be repeated later directly in the app. 

### Upload the UI5 App
A detailed guide is available [here](https://developers.sap.com/tutorials/abap-environment-vs-code..html)

1. Copy the UI development to your local disk: https://github.com/SAP-samples/forms-service-by-adobe-samples/tree/main/ui/cinema
2. Install npm dependencies by running `npm install`
3. Modify the files by replacing XXX with your system url:
    - **ui5-deploy.yaml**
    - **ui5-local.yaml**
    - **ui5-mock.yaml**
    - **ui5.yaml**
4. Deploy the application via: `npm deploy`
5. Your application should now be deployed to: /sap/bc/ui5_ui5/sap/zcin_bsp_demo
6. It is not yet accessible. Follow this [guide](https://developers.sap.com/tutorials/abap-environment-deploy-fiori-elements-ui.html) (Step 9) to setup the authorization
7. After the setup is completed, you can follow the link from vscode to open the app

### Setup Print Queue
You need to configure two print queues, to simulate different output devices.
Here a suggestion:

![Print Queues](/images/PQs.png)

The how to is documented [here](https://community.sap.com/t5/enterprise-resource-planning-blog-posts-by-sap/cloud-print-manager-for-pull-integration-installation-and-configuration/ba-p/13334437)

You want a short summary, what needs to be done? 
Expand this section:
::: details
1. Setup SAP_COM_0466
    1. First we need to create a new communication user and assign it to our ABAP system
	2. Go to App: **Communication Systems**
	3. Select your current system (system name is a random string + hostname should be the same as in our current browser url)
	4. The header should read: **This is your own SAP cloud system**
    ![Own System](/images/own_system.png)
	5. Press **Edit**
	6. Go to tab **Users for Inbound Communication**
	7. Press "+"
	8. Press **New User**
	9. Choose User Name + Description + Password to your liking
	10. Press **Create**
	11. Press **OK**
    12. Press **Save**
	13. Go to App: Communication Arrangements
	14. Press "New"
	15 Select Scenario: SAP_COM_0466
    ![Own System](/images/SAP_COM_0466_1.png)
	16. Communication System: Select your own system we previously modified
	17. Inbound Communication: Choose previously created user and press **OK**
    ![Own System](/images/SAP_COM_0466_2.png)
	18. Press "Save"
	19. Go to App:  Maintain Print Queues
	20. For demo purpose we will create two queues to showcase different behavior based on desired output format
		1. Queue for PDF output
		    - Name: DEMO_PDF
			- Format: PDF
		2. Queue for ZPL output (format for zebra label printer, output is plain text)
			- Name: DEMO_ZPL
			- Format: Zebra 203 dpi
2. Configure SAP Cloud Print Manager (CPM) for Pull Integration
    Using your system url + user / password of the inbound communication user, you should be able to add the print queues to client
    ![CPM](/images/PQ_setup_finished.png)
:::

## Data Model
Here you can see the sample data model. 
You can toggle through the different objects and see how the data is modeled. 
There is also an example XML available to see the potential output.
<!--@include: ./parts/cinema/data_cds.md-->

## PDF Preview
You can also use the [Previewer](/preview_util.md) to review your PDF before calling the app.
![Previewer Cinema Example](/images/Preview_CINEMA.png)

## Usage of the UI application
### Book a new Ticket
1. Start the application
![Start](/images/cinema_demo_select_airing.png)
2. You can click on any movie currently airing
3. It will show you an overview of available seats
![Start](/images/cinema_demo_choose_seat.png)
4. Select ticket type + seat
5. Press **Book**, a notification will popup informing you of your selection and the seat will be blocked
6. Refresh the list **Generated Tickets** and wait for your ticket to appear
### Preview Ticket
Once a ticket was generated, it will be listed under: **Generated Tickets**
In the list, press the first action button:
![Preview](/images/actions.png)

This will load the persisted PDF from the database table.
### Sent Ticket 
Once a ticket was generated, it will be listed under: **Generated Tickets**
In the list, press the second action button:
![Preview](/images/actions.png)

This will show a dialog, where you can input the name of your created print queue.
Depending on the output type defined in the print queue, the resulting document format will change.
![Start](/images/cinema_demo_choose_pq.png)

### Reset Demo
It can happen that the demo becomes quite messy after a while. 
Click the button at the upper right, to reset the demo, deleting all tickets and generating a new airing schedule.

## Further details
### Usage of bgPF
This demo is using bgPF for rendering the document. 
This has a couple of benefits:
- The RAP transactional flow is not blocked and document rendering is deligated to the background
- In case unexpected errors occur, the rendering job can be retried
- The transactional data is saved independant from document rendering

You can check the implementation for these processes here:
- [zcl_cine_app_op_reset](https://github.com/SAP-samples/forms-service-by-adobe-samples/blob/main/abap/zfoba_cinema_demo/zfoba_cinema_app/zcl_cine_app_op_reset.clas.abap)
- [zcl_cine_app_op_render](https://github.com/SAP-samples/forms-service-by-adobe-samples/blob/main/abap/zfoba_cinema_demo/zfoba_cinema_app/zcl_cine_app_op_render.clas.abap)

By default queuing bgPF processes requires to be in the RAP transactional state **save**.
When we call actions directly this state might be unreachable from the action itself.

In order for this to work, the following technique is applied.

1. Add a table of processes to the behavior class
```abap {3}
CLASS zbp_cine_i_ticket DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zcine_i_ticket.
  PUBLIC SECTION.
    CLASS-DATA ct_processes TYPE STANDARD TABLE OF REF TO if_bgmc_process.
ENDCLASS.

CLASS zbp_cine_i_ticket IMPLEMENTATION.
ENDCLASS.
```
2. Add the annotation **with additional save** to unlock the RAP saver methods 
```abapcds {5}
define behavior for ZCINE_I_TICKET //alias <alias_name>
persistent table zcine_a_buy
lock master
authorization master ( instance )
with additional save
```
3. In the local type of the behavior implementation class, we can now queue all temporary saved processes and cleanup the global data
```abap {5}
CLASS lsc_ZCINE_I_TICKET IMPLEMENTATION.
  METHOD save_modified.
    LOOP AT zbp_cine_i_ticket=>ct_processes ASSIGNING FIELD-SYMBOL(<process>).
      TRY.
          <process>->save_for_execution( ).
        CATCH cx_bgmc.
          " Skip error handling
      ENDTRY.
      DELETE zbp_cine_i_ticket=>ct_processes.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.
ENDCLASS.
```
4. Inside of our actions, we can now create new bgPF processes and queue them to our temporary table and wait for them to be picked up later
```abap {17,18,19}
METHOD AddRenderOperation.
    DATA factory   TYPE REF TO if_bgmc_process_factory.
    DATA operation TYPE REF TO zcl_cine_app_op_render.
    DATA process   TYPE REF TO if_bgmc_process.

    DATA(op_input) = input.
    DATA(formname) = CONV fpname( |ZF_CINE_TICKET| ).
    factory = cl_bgmc_process_factory=>get_default( ).
    DATA(form) = cl_fp_form_reader=>create_form_reader( formname ).
    DATA(fdp)  = cl_fp_fdp_services=>get_instance( form->get_fdp_name( ) ).
    DATA(fdp_keys) = fdp->get_keys( ).
    fdp_keys[ name = 'ID' ]-value = id.
    operation = NEW zcl_cine_app_op_render( ).
    op_input-formname = formname.
    MOVE-CORRESPONDING fdp_keys TO op_input-fdp_it_select.

    operation->if_bgmc_operation_aif~set_input( op_input ).
    process = factory->create( )->set_name( 'RENDER_PDF' )->set_operation_tx_uncontrolled( operation ).
    APPEND process TO zbp_cine_i_ticket=>ct_processes.
  ENDMETHOD.
```

### Print Queue Integration
The reuse classes for interacting with the print queue should only be called in a RAP save context.
Since we are making use of the bgPF uncontrolled feature, this limitation does not apply here.

Sending items to the print queue is straight forward. 
Simply create a new print queue with our document as input and provide a name.

```abap [zcl_cine_app_op_render] {11,12,13,14,15,16}
cl_fp_ads_util=>render_4_pq( 
    EXPORTING 
        iv_pq_name    = input-send_to_pq
        iv_locale     = iso
        iv_xml_data   = xml
        iv_xdp_layout = form->get_layout( )
        is_options    = VALUE #( trace_level = input-render_trace )
    IMPORTING 
        ev_pdl        = pdf ).

cl_print_queue_utils=>create_queue_item_by_data(
    " Name of the print queue where result should be stored
    iv_qname            = input-send_to_pq
    iv_print_data       = pdf
    iv_name_of_main_doc = |Ticket-{ id }| 
).
```
