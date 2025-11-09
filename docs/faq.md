# Frequently asked questions

## Is this guide applicable for S/4 HANA Public Cloud Edition
Yes

## Do I need a separate Forms service by Adobe subscription
- Yes, for BTP, ABAP Environment
- No, for S/4 HANA Public Cloud Edition

## The arrangement SAP_COM_0503 is not available
- Arrangement is only available for BTP, ABAP Environment
- Setup of own subscription of Forms service by Adobe not supported for S/4 HANA Public Cloud Edition

## What kind of service keys are supported for configuring SAP_COM_0503
- Only service keys that include clientId + clientSecret can be used.
- Service keys using certificates are not supported

## Do Form Templates support transport via abapGit?
- Currently form templates only support gCTS transport
- abapGit support is not yet implemented

## Can I use RAP based FDP in Maintain Form Templates App (S/4 HANA Public Cloud Edition only)
- Custom FDPs created in developer extensibility are not yet usable in S/4 HANA Output Managment

## Is this guide also applicable for On-Premise Releases?
- The demo application can be implemented in all solutions based on ABAP Platform 2025 or higher

::: warning
Some configuration steps / apps might differ
:::

## Can I use a hosted ADS instead of Forms service by Adobe for On-Premise solutions?
Yes

## Difference between subscription and instance for Forms service by Adobe?
- Creating a Subscription is mandatory to use Forms service by Adobe. By doing so it will:
    - Initialize the service for the subaccount
	- Needed to access the configuration UIs
	- Cannot be used to connect to the service directly
- To access Forms service by Adobe, a service instance needs to be created
    - Enables to create service key, which contain the credentials for connecting to the service

## Is the Forms service by Adobe Template Store still supported in ABAP?
- In previous iteration of this guide, a walkaround for storing templates using the Forms service by Adobe Template Store was presented.
- The walkaround will still work, but it is recommended to store templates directly in ABAP using ADT and transport them via gCTS.
- This offers several benefits like:
    - Faster retrieval of templates
	- Templates are delivered along with the code line (no double maintenance of templates in case of dev / prod systems) 
