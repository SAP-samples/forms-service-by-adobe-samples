---
outline: deep
---

# Preview your FDP / Form
In order to easily preview and extract both xml data and form output during development, there is also a previewer application available in the samples.
It can take either a form name or service definition as an input, will fetch needed keys and will show you the output including rendering traces from Forms service by Adobe.

The UI files are available [here](https://github.com/SAP-samples/forms-service-by-adobe-samples/blob/main/ui/preview/index.html).
To keep the application as portable as possible, the UI file was converted to base64 and embedded into the class implementation itself.

## Installation
1. In ABAPgit clone the following package: [ZFDP_PREVIEWER](https://github.com/SAP-samples/forms-service-by-adobe-samples/tree/main/abap/zfdp_previewer)
2. Make sure the http service: **ZFDP_PREVIEWER_HTTP** is locally published
3. Go to url: /sap/bc/http/sap/ZFDP_PREVIEWER_HTTP?sap-client=100 

## Usage
1. Go to the url: /sap/bc/http/sap/ZFDP_PREVIEWER_HTTP?sap-client=100 
::: tip
You need to append your system url before the path. The sap-client might differ depending on your system setup.
:::
2. Input either a form name or name of a service binding
3. Choose the correct type of the object name
4. Press **Load Keys**
5. Fill in necessary keys
6. Press **Execute**
7. The document / xml will appear after a short while
![Previewer](/images/Previewer.png)

## Troubleshooting
### Error: Form: \<Name\> is a legacy form and cannot be used with this api.
The form does not exist or the selected type is wrong

### Proxy initialisation error: Unspecified provider error occurred. See Error Con.
The service binding cannot be found or the selected type is wrong

### Resource not found
The filled in keys cannot find an item, check your keys.
