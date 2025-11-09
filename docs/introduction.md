---
outline: deep
---

# Introduction custom form development
At SAP form development describes the full process of implementing document output. 
This includes the designtime and runtime of the application process.

As the field is quite complex only a subset of features can be highlighted in this guide.
The goal is to build a working end-to-end process that can be adopted / modified to fit the needed usecase.

## Development Process
The development process for form development roughly boils down to:

1. Model your business data
2. Implement your business data
3. Import your business data into the form designer (Adobe LiveCycle Designer)
4. Design and develop your output document based on your business data
5. Integrate the form output process into your application

## Data Modelling
When rendering a document via template + business data, the rendering engine expects all needed data entries,
that are bound by template fields to be available.
To accomodate this we need to build a data tree that expands over the whole defined model. Technically it will work as follows:

1. Get a list of relevant CDS views
::: info
CDS Views are maintained in the service definition
:::
2. Determine the root / starting CDS view
::: info
This is determined via the annotation: **@ObjectModel.leadingEntity.name:** in the service definition
:::
3. Read all Properties of the view, resolve all associations linking to relevant CDS views
4. Data retrieval will continue recursively until no further associations are found
5. The resolved data is merged into an xml data tree

## Samples
When trying to teach such a complex field, often the resulting demo want to showcase as much features as possibe.
And as we are a reuse process, certain integrations need to be setup, in order to showcase a real life setup.

In order to address this dilemma, this guides showcases two samples, a simple on, to kick start your development and a 
complex example showcasing how to integrate form development to your existing RAP applications and make use of advanced techniques like (bgPF)
to showcase a production ready approach.