# Send the Style
---

Send the Style is an API that allows you to send a request with web-accessible 
SASS/SCSS URIs or files and get a response with the generated CSS.

## The Problem

When deploying web applications we don't always have control over the server or 
hosting environment. That means we can't expect [SASS](http://sass-lang.com/), 
[Compass](http://compass-style.org/), or another preprocessor to be available.

## API

This simple API is built using the most awesome [Sinatra Framework](http://www.sinatrarb.com/). 
Basically you'll send some options and data to the API and receive `JSON` containing 
generated CSS to be used in your application.

### Authentication

You will authenticate to the Send-the-Style API by providing your API key in the 
request. Your API keys carry magic privileges, so be sure to keep them secret!

Authentication to the API occurs via 
[HTTP Basic Authentication](http://en.wikipedia.org/wiki/Basic_access_authentication). 
Provide your API key as the basic authentication username. You do not need to 
provide a password.

All API requests must be made over HTTPS. Calls made over plain HTTP will fail. 
You must authenticate for all requests.

Example Request:

```bash
$ curl https://send-the-style.heroku.com/ \
  -u NmM0M2YzYmJhYTBjMTI3YjczMzM4ZTZjZGM5NzUzNTA=:
```

> **Note:** `curl` uses the `-u` flag to pass basic auth credentials (adding a 
> colon after your API key will prevent it from asking you for a password.

### HTTP Status Code Summary

`200 OK - Everything worked as expected.`

`400 Bad Request - Often missing a required parameter.`

`401 Unauthorized - No valid API key provided.`

`402 Request Failed - Parameters were valid but request failed.`

`404 Not Found - The requested item doesn't exist.`

`500, 502, 503, 504 Server errors - something went wrong on Send-the-Style's end.`
