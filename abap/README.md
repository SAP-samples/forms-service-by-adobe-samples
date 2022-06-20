# Integrate SAP Forms Service by Adobe with ABAP Environment

This sample contains:
- Short guide what service is needed and how to set them up
- Example data + form template

## Table of contents

+ [Prerequisites](#prerequisites)
    - [SAP Business Technology Platform](#sap-business-technology-platform)
    - [Local Machine](#local-machine)
+ [Assign Roles](#assign-roles)

### Prerequisites
#### SAP Business Technology Platform
- Create or use an existing account on [SAP Business Technology Platform](https://www.sap.com/germany/products/business-technology-platform.html)
- Order [SAP Forms Service by Adobe](https://discovery-center.cloud.sap/serviceCatalog/forms-service-by-adobe?region=all) via service marketplace
- Order [SAP Forms Service by Adobe API](https://discovery-center.cloud.sap/serviceCatalog/forms-service-by-adobe?region=all) via service marketplace
- Order [ABAP Environment](https://discovery-center.cloud.sap/serviceCatalog/abap-environment?region=all) via service marketplace
- Order [Destination](https://discovery-center.cloud.sap/serviceCatalog/destination?service_plan=lite&region=all&licenseModel=cpea) via service marketplace
- Perform basic [ABAP Environment Setup](https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/a999fac2a578468ea0e4e320c82145ce.html).

#### Local Machine
- Download [ABAP Development Tools](https://tools.hana.ondemand.com/#abap) and connect them to your ABAP Environment
- Download [Adobe LiveCycle Designer](https://launchpad.support.sap.com/#/softwarecenter/template/products/_APP=00200682500000001943&_EVENT=NEXT&HEADER=Y&FUNCTIONBAR=Y&EVENT=TREE&NE=NAVIGATE&ENR=73554900100800002751&V=MAINT&TA=ACTUAL/ADOBE%20LIVECYCLE%20DESIGNER) from SAP Software Marketplace
- Download [SAP Cloud Print Manager for Pull Integration](https://launchpad.support.sap.com/#/softwarecenter/template/products/%20_APP=00200682500000001943&_EVENT=DISPHIER&HEADER=Y&FUNCTIONBAR=N&EVENT=TREE&NE=NAVIGATE&ENR=73555000100100001346&V=MAINT&TA=ACTUAL&PAGE=SEARCH/SAP%20CLOUD%20PRINT%20MANAGER)

### Assign Roles
- `ADSAdmin` for accessing SAP Forms Service by Adobe Config UI (used for maintaining fonts, xdc, xci, etc.)
- `TemplateStoreAdmin` for accessing the Template Store UI

### Setup
#### 
