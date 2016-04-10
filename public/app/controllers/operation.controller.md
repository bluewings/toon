{{ description }}

## Request

### HTTP request
```
{{ method }} {{ uri }}
```

{{#if pathVariables }}

### Path variables
[parameters:pathVariables]

{{/if}}

{{#if queries}}

### Parameters
[parameters:queries]

{{/if}}

{{#if requestBody }}

### Request body
[parameters:requestBody]

{{/if}}

## Response

{{#if responseBody }}

### Request body
[parameters:responseBody]

{{/if}}