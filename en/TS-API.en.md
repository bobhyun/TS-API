TS-API Programmer's Guide
======

TS-API@0.9.19
-----

This article is a programming guide for those who develop application software using **TS-API**, which is built in **TS-CMS**, **TS-NVR**, **TS-LPR** of TS Solution Corp..

You can easily embed the real-time video, recorded video, and video search functions into your application software with the API. 

It would be helpful if you have some experience using simple `HTML` and `JavaScript` to use the API.

Please refer to [The API-supported versions by product](#the-api-supported-versions-by-product) and 
[The features table by product](#the-features-table-by-product) portion of [Appendix](#appendix), as the features supported by each product may differ.
 
> [Tips]
The API and this article are subject to change without notice for better development support and improvement.

Table of contents
-----
<!-- TOC -->

- [TS-API Programmer's Guide](#ts-api-programmers-guide)
  - [TS-API@0.9.19](#ts-api0919)
  - [Table of contents](#table-of-contents)
  - [Get Started](#get-started)
  - [Video display](#video-display)
    - [Real-time video display](#real-time-video-display)
    - [Inserting video into web page](#inserting-video-into-web-page)
    - [Connecting to a real server](#connecting-to-a-real-server)
    - [User authentication](#user-authentication)
    - [Change channel](#change-channel)
    - [Display recorded video](#display-recorded-video)
  - [JSON data indentation `@0.5.0`](#json-data-indentation-050)
  - [Session authentication](#session-authentication)
    - [Sign in](#sign-in)
    - [Sign out](#sign-out)
  - [Request server information](#request-server-information)
    - [API version](#api-version)
    - [Site name](#site-name)
    - [Server-side time zone](#server-side-time-zone)
    - [Product information](#product-information)
    - [License information](#license-information)
      - [`extension` list](#extension-list)
    - [User information](#user-information)
    - [Request all at once](#request-all-at-once)
  - [Request system information `@0.3.0`](#request-system-information-030)
    - [Requests individual items](#requests-individual-items)
  - [Request system health `@0.3.0`](#request-system-health-030)
    - [Requests individual items](#requests-individual-items-1)
  - [Request HDD S.M.A.R.T. `@0.6.0`](#request-hdd-smart-060)
  - [Request to restart server process `@0.6.0`](#request-to-restart-server-process-060)
  - [Request to reboot server system `@0.6.0`](#request-to-reboot-server-system-060)
  - [Request channel status `@0.3.0`](#request-channel-status-030)
  - [Request various enumeration](#request-various-enumeration)
    - [Channel list `@0.9.4`](#channel-list-094)
      - [Adding stream list `@0.9.4`](#adding-stream-list-094)
      - [Adding camera capabilities `@0.9.4`](#adding-camera-capabilities-094)
    - [Vehicle number recognition device list](#vehicle-number-recognition-device-list)
    - [Emergency call device list `@0.3.0`](#emergency-call-device-list-030)
    - [Event log type list](#event-log-type-list)
    - [Parking lot list `@0.9.8`](#parking-lot-list-098)
    - [Real-time event list `@0.9.6`](#real-time-event-list-096)
    - [Supported object types `@0.9.11`](#supported-object-types-0911)
    - [Supported object attributes `@0.9.11`](#supported-object-attributes-0911)
  - [Retrieve recorded data](#retrieve-recorded-data)
    - [Search dates with recorded video](#search-dates-with-recorded-video)
    - [Search minutes with recorded video `@0.2.0`](#search-minutes-with-recorded-video-020)
    - [Search event log](#search-event-log)
    - [Vehicle number log search](#vehicle-number-log-search)
    - [Export the search result of vehicle numbers log `@0.9.18`](#export-the-search-result-of-vehicle-numbers-log-0918)
    - [Search for similar vehicle numbers `@0.2.0`](#search-for-similar-vehicle-numbers-020)
    - [Object Search `@0.9.11`](#object-search-0911)
      - [Common parameters](#common-parameters)
      - [Parameters for `face`](#parameters-for-face)
      - [Parameters for `human`](#parameters-for-human)
      - [Parameters for `vehicle`](#parameters-for-vehicle)
    - [Face Search `@0.9.6`](#face-search-096)
  - [Search for video sources](#search-for-video-sources)
    - [Real-time video source](#real-time-video-source)
    - [Recorded video source](#recorded-video-source)
  - [Requesting video using video source `@0.3.0`](#requesting-video-using-video-source-030)
  - [Real-time event monitoring `@0.3.0`](#real-time-event-monitoring-030)
    - [Web Sockets (RFC6455)](#web-sockets-rfc6455)
    - [Channel status change events](#channel-status-change-events)
    - [Car number recognition events](#car-number-recognition-events)
    - [Emergency call events](#emergency-call-events)
    - [System event `@0.7.0`](#system-event-070)
    - [Motion Detection Status Change Event `@0.8.0`](#motion-detection-status-change-event-080)
    - [Parking Count Event `@0.9.0`](#parking-count-event-090)
    - [Recording Status Event `@0.9.5`](#recording-status-event-095)
    - [Object Detection Event `@0.9.11`](#object-detection-event-0911)
      - [`face` object](#face-object)
      - [`human` object](#human-object)
      - [`vehicle` object](#vehicle-object)
    - [Body Temperature Event `@0.9.14`](#body-temperature-event-0914)
  - [Exporting recorded video `@0.3.0`](#exporting-recorded-video-030)
  - [Pushing events to the server `@0.4.0`](#pushing-events-to-the-server-040)
  - [Channel information and device control `@0.5.0`](#channel-information-and-device-control-050)
    - [Request Device Information and Support Function List](#request-device-information-and-support-function-list)
    - [Pan tilt control](#pan-tilt-control)
    - [Pan tilt preset control](#pan-tilt-preset-control)
    - [Relay output](#relay-output)
    - [AUX output](#aux-output)
    - [Reboot the device](#reboot-the-device)
  - [Adding channels `@0.9.7`](#adding-channels-097)
    - [Request data](#request-data)
      - [Camera](#camera)
      - [Video stream](#video-stream)
      - [Video file](#video-file)
    - [Response](#response)
      - [Response data](#response-data)
  - [Deleting channels `@0.9.7`](#deleting-channels-097)
      - [Rsponse data](#rsponse-data)
  - [Event Backup `@0.9.17`](#event-backup-0917)
      - [Request](#request)
      - [Response data](#response-data-1)
  - [Appendix](#appendix)
    - [base64 Encoding](#base64-encoding)
    - [URL Encoding](#url-encoding)
    - [URL decoding](#url-decoding)
    - [Date and time notation in ISO 8601 format](#date-and-time-notation-in-iso-8601-format)
    - [List of languages supported](#list-of-languages-supported)
    - [JSON data format](#json-data-format)
    - [Feedback](#feedback)

<!-- /TOC -->



## Get Started
In this article, TS-API is abbreviated as **API**, and each product is simply called **server**.



## Video display

### Real-time video display
Try to type the following in the Web browser address window.
```ruby
http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
[Run](http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D)


Do you see the video?

> [Tips]
The demonstration video used in this sample code may not be connected depending on the situation in the field.


### Inserting video into web page
Now let's insert the video into the web page.
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>ex1</title>
</head>

<body>
<h2>Example 1. Insert video</h2>
<iframe src='http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D' 
  width='640' height='360' frameborder='0' allowfullscreen />
</body>
```
[Run](./examples/ex1.html)

The video URL and the `<iframe>` tag code used in the example are provided as a pop-up menu when you **right-click on the video** of the webpage (or long-press on the video in case of a smartphone).
Select the menu item you are to use, the code will be copied to the clipboard and then you can **paste** them into your code.

| Menu items      | Usage                                         |
|-----------------|-----------------------------------------------|
| Copy video URL  | Paste into web browser address window         |
| Copy embed code | Paste in the `<iframe>` tag of your HTML code |

> [Tips]
For security reasons, the `auth=ZGVtbzohMTIzNHF3ZXI%3D` part is excluded from this copied code. This code is required for authentication and is described in [Session Authentication](#session-authentication).
In this example, we used only minimal code to display the video, so there are more parts that were not included in the copied code.


### Connecting to a real server
Now, let's see how to display the video of a real server, not a demonstration server.
To connect to a real server, you need to know the following two things by default:

1. The **host name** of the server (**IP address** or **domain name**, and **port number** when 80 is not used)
>* The port number can be found in the `HTTP Port` item in the `Web Service` tab in your product Settings window.
2. **User ID** and **password** with **remote access privileges**


### User authentication
For example, assuming that you use the following connection information;

| Item            | Value                     |
|-----------------|---------------------------|
| IP address      | `tssolution.ipdisk.co.kr` |
| Web port number | `85`                      |
| User ID         | `demo`                    |
| Password        | `!1234qwer`               |

In the above example, you can change the address part as follows:
```html
<iframe src='http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D'
  width='640' height='360' frameborder='0' allowfullscreen></iframe>
```
Here `ZGVtbzohMTIzNHF3ZXI%3D` following `auth=` is the [base64 encoded](#base64-encoding) part of user ID and password.

The format is to use a colon (`:`) delimiter, such as `userid: password`, to create a username and password as a single text and then [base64 encoded](#base64-encoding).
In the above example, `demo:!1234qwer` is [base64 encoded](#base64-encoding) and becomes `ZGVtbzohMTIzNHF3ZXI%3D`.


In this example, we will improve the way we access the login information using JavaScript [base64 encoding](#base64-encoding) function.
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>ex2</title>
</head>

<script>
  function onConnect() {
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert('Enter the host.');
      return;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert('Enter your user ID.');
      return;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert('Enter the password.');
      return;
    }
    var encodedData = window.btoa(userId + ':' + password); // base64 encoding
    var src = 'http://' + hostName + '/watch?ch=1&auth=' + encodedData;
    document.getElementById('result').innerText = src;
    document.getElementById('player').src = src;
  }
</script>

<body>
  <h2>Example 2. Connecting to a real server</h2>
  <table>
    <tr>
      <td>Host</td>
      <td>User ID</td> 
      <td>Password</td>
    </tr>
    <tr>
      <td><input type='text' id='host-name'></td>
      <td><input type='text' id='user-id'></td> 
      <td><input type='text' id='password'></td>
      <td><button type='button' onClick='onConnect()'>Connect</button></td>
    </tr>
    <tr>
      <td colspan='4' id='result'></td>
    </tr>
  </table>

  <iframe width='640' height='360' frameborder='0' allowfullscreen id='player' />
</body>
```
[Run](./examples/ex2.html)


### Change channel
If you change the `ch=` part of the video source to the desired channel number as shown below, the video of that channel will be displayed.
Channel numbers are integers starting at 1.
For example, if you want to see channel 3, you can modify it like this:
```ruby
http://tssolution.iptime.org:83/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
Run: [Channel1](http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D) [Channel2](http://tssolution.iptime.org:83/watch?ch=2&auth=ZGVtbzohMTIzNHF3ZXI%3D) [Channel3](http://tssolution.iptime.org:83/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI%3D)


### Display recorded video
To display the recorded video, you need the date and time information (time stamp) of the desired video.
For example, to display a video recorded on `Channel 1` at 2:30:15 pm on February 1, 2018, you would need to add `when=2018-02-01T14%3a30%3a15%2b09%3a00`.
```ruby
http://tssolution.iptime.org:83/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
[Run](http://tssolution.iptime.org:83/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI%3D&lang=en-US)

> [Tips]
The recorded video of the old date may already be overwritten depending on the capacity of the storage device.

`2018-02-01T14%3a30%3a15%2b09%3a00` is the date and time in the format [ISO 8601](#date-and-time-notation-in-iso-8601-format).

You can use `when=now` to request real-time video, but if omitted, it means real-time video, and the following tips are provided for ease of use.
```
when=yesterday    // Local time on server yesterday 00:00:00
when=today        // Local time on server today 00:00:00
```
Run: [Yesterday](http://tssolution.iptime.org:83/watch?ch=1&when=yesterday&auth=ZGVtbzohMTIzNHF3ZXI%3D&lang=en-US) [Today](http://tssolution.iptime.org:83/watch?ch=1&when=today&auth=ZGVtbzohMTIzNHF3ZXI%3D&lang=en-US)

You can use the parameters to set the language of the subtitles displayed on the video.
For a [list of supported languages](#list-of-languages-supported), refer to the appendix.

From here, we will omit the `http://host` and the`auth=`part.
```ruby
# Parameters
lang            # Specify subtitle language
showTitle       # Whether channel name is displayed (true, false)
showPlayTime    # Whether the date and time are displayed (true, false)

# Example
# Show date and time in Spanish
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&lang=es-ES

# Hide Channel name and date time
# showTitle and showPlayTime are assumed to be true by default.
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&showTitle=false&showPlayTime=false
```

So far, We've seen how to display video using the `/watch`. Here we will see how to request various information using `/api`.


## JSON data indentation `@0.5.0`
All response data is in the [JSON format](#json-data-format) and the text is encoded as `utf8`. 
The actual data being transferred uses an optimized format without line breaks and whitespace, but This is too uncomfortable for a person to read.

For example, when request timezone as shown below:
```ruby
GET /api/info?timezone
```
The server returns JSON data in an optimized format with no line breaks and no whitespace, like this:
```jsx
{"timezone":{"name":"America/New_York","bias":"-05:00"}}
```

For developer's convenience, you can specify `indent` option to indent the JSON data in an easy-to-read format.
The value of `indent` ranges from 0 to 8.

For example, when request timezone using indentation of 2 as shown below:
```ruby
GET /api/info?timezone&indent=2
```
The server indents two blank characters and inserts a newline character to return the JSON data in an easy-to-read format:
```jsx
{
  "timezone": {
    "name": "America/New_York",
    "bias": "-05:00"
  }
}
```
Of course, you can use the desired number as the indent value, and it can be used in the same way for all TS-APIs.
This document uses a format with indentation of 2 to make it easier to read items in the data.


## Session authentication
The server maintains an HTTP session using Cookie until the client software (the web browser) logs in and logs out. Since the server maintains the authentication information while the session is being connected, the client software (web browser) does not need to sign in whenever makes request.

*This process of sign-in is called **session authentication**.*


### Sign in
Here's how to use the API to authenticate your session.
The server also supports Basic authentication which is a  traditional sign-in method using URL format, as shown in the code below, but for security reasons, most modern web browsers does not support this method anymore.
````ruby
http://userid:password@host/path/to/
````

For this reason, we provide the following additional login methods:
Using `login=` parameter after encrypting the user ID and password in the same way as in [User Authentication](#user-authentication).
```ruby
GET /api/auth?login=ZGVtbzohMTIzNHF3ZXI%3D    # http://host omitted
```
If the login is successful, the server returns an HTTP response code of 200.

You can use `auth=` to sign in the same way as shown below.
```ruby
GET /api/auth?auth=ZGVtbzohMTIzNHF3ZXI%3D
```
The `auth =` parameter is used in various APIs to be introduced later and can be used when making a request with user authentication information to the server without going through a separate login process.


### Sign out
After the session is connected, the following request can be used to terminate it.
```ruby
GET /api/auth?logout
```
At the end of the session, the server returns an HTTP response code of 401 for requests that require authentication, indicating that authentication is required.



## Request server information


### API version
This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
GET /api/info?apiVersion
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```json
{
  "apiVersion": "TS-API@0.3.0"
}
```


### Site name
Use to get the server's site name. If you have multiple servers, you can give them a name that can be distinguished from each other.

This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
GET /api/info?siteName
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "siteName": "My home server"
}
```
The value of `siteName`, `"My%20home%20server"`, is what you entered in the web service tab of the Settings window on the server, and it is [URL-encoded](#url-decoding) to present in JSON format.
Decoding the above[URL-encoded](#url-decoding) code will convert it to `"My home server"`.



### Server-side time zone
You can get the server-side time zone.
It is used to distinguish between the client-side and server-side local time when they are used in different time zones.

This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
GET /api/info?timezone
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "timezone": {
    "name": "America/New_York",   // Time zone name as IANA format
    "bias": "-05:00"              // UTC offset
  }
}
```
UTC offset, for example, `UTC-05:00`, may be used instead of [IANA time zone name](#https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).


### Product information
It is used to get the product name and version information of the server.

This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
GET /api/info?product
````
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
// for TS-CMS:
{
  "product": {
    "name": "TS-CMS",               // Product name
    "version": "v0.38.0 (64-bit)"   // Version information
  }
}

// for TS-NVR:
{
  "product": {
    "name": "TS-NVR",               // Product name
    "version": "v0.35.0 (64-bit)"   // Version information
  }
}

// for TS-LPR:
{
  "product": {
    "name": "TS-LPR",               // Product name
    "version": "v0.2.0A (64-bit)"   // Version information
  }
}
```


### License information
Used to get license information installed on the server.

This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
GET /api/info?license
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
// for a genuine lincense:
{
  "license": {
    "type": "genuine",         // Genuine lincense
    "maxChannels": 36,         // Maximum channels available
    "nLprZone": 36,            // Maximum license plate recognition zones available (TS-API@0.9.12)
    "nDevEmCall": 50,          // Maximum emergency call buttons available (TS-API@0.9.12)
    "nChObjDetection": 36,     // Maximum channels available for object detection (TS-API@0.9.12)
    "nChFaceRecognition": 10,  // Maximum channels available for face recognition (TS-API@0.9.12)
    "nChTrafficCount": 10,     // Maximum channels available for vehicle traffic count (TS-API@0.9.12)
    "nChSpeedometer": 10,      // Maximum channels available for vehicle speedometer (TS-API@0.9.12)
    "mediaType": "USB dongle", // License media type ("USB dongle" or "Software") (TS-API@0.9.12)
    "extension": [             // Add-ons
      "lprExt",                // Interworking the vehicle number recognition
      "emergencyCall"          // supports emergency call devices
    ]
  }
}

// for a free trial:
{
  "license": {
    "type": "trial",    // Free trial
    "maxChannels": 16,  // Maximum channels available
    "trialDays": 30,    // 30 days free trial
    "leftDays": 15      // 15 days left
  }
}
```

#### `extension` list
| `extension` | Description     |
|-----------|------------|
| `lprExt`  | License plate recognition |
| `emergencyCall`  | Emergency call |
| `lprKiosk`  | Kiosk - finding my car |
| `packing`  | Packing API |
| `objectDetection`  | Object detection |
| `faceRecognition`  | Face recognition |
| `sharedFrameBuffer`  | Shared frame buffer `TS-API@0.9.7`| 


### User information
Used to get sign-in user information.
This request works only in the [session authenticated](#session-authentication) state.
From here on, the `auth =` part of [session authentication](#session-authentication) is omitted.
```ruby
GET /api/info?whoAmI
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
If it is not in [session authenticated](#session-authentication) state, the server sends an HTTP response code 401 error.

```jsx
{
  "whoAmI": {
    "uid":"admin",      // User ID
    "name":"admin",     // User name
    "##COMMENT1": "---- NOTICE OF CHANGE -------------------------------------------",
    "##COMMENT2": "'accessRights' is deprecated and 'accessRights2' is used instead.",
    "##COMMENT3": "-----------------------------------------------------------------",    
    // The new format is used since 0.5.0
    "accessRights2": {         // Permissions
      "DataExport": true,     // Export images, videos
      "Control": true,        // Pan tilt, relay control
      "Settings": true,       // Change settings
      "Playback": true,       // Search and Play back saved videos
      "LPR": true,            // Vehicle number search
      "Remote": true          // Remote access
    },
    // Old format will be deleted and kept for backwards compatibility
    "accessRights": [
      "DataExport",
      "Control",
      "Settings",
      "Playback",
      "LPR",
      //"SearchEdit",   // Removed since 0.5.0 (replaced with Playback permission)
      "Remote"
    ]
  }
}
```


### Request all at once
You can request information individually, but we also provide a way to request all the information at once for convenience.
```ruby
GET /api/info?all
```
This request returns JSON data with an HTTP response code of 200 if the session is authenticated, or JSON data with an HTTP response code of 401 with no `whoAmI` entries if it is not authenticated.
```jsx
// Session authenticated state (HTTP response code: 200):
{
  "apiVersion": "TS-API@0.3.0",
  "siteName": "My%20home%20server",
  "timezone": {
    "name": "America/New_York",
    "bias": "-05:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.5.0A (64-bit)"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 36,
    "extension": [
      "lprExt",
      "emergencyCall"
    ]
  },
  "whoAmI": {
    "uid": "admin",
    "name": "admin",
    "accessRights": [
      "DataExport",
      "Control",
      "Settings",
      "Playback",
      "LPR",
      "SearchEdit",
      "Remote"
    ]
  }
}

// Session unauthenticated state (HTTP response code: 401):
{
  "apiVersion": "TS-API@0.3.0",
  "siteName": "My%20home%20server",
  "timezone": {
    "name": "America/New_York",
    "bias": "-05:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.5.0A (64-bit)"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 36,
    "extension": [
      "lprExt",
      "emergencyCall"
    ]
  }     // whoAmI is not included
}
```


## Request system information `@0.3.0`
Requests system information from the server.
```ruby
GET /api/system?info
GET /api/system   # omitted
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
*@0.7.0 disk data format modified*
```jsx
{
  "lastUpdate": "2018-09-15T13:49:12.440-05:00",
  "os": {
    "name": "Microsoft Windows Embedded Standard",
    "servicePack": "Service Pack 1",
    "version": "6.1.7601",
    "arch": "64-bit"
  },
  "cpu": [
    {
      "name": "Intel(R) Core(TM) i5-6500 CPU @ 3.20GHz",
      "manufacturer": "GenuineIntel",
      "cores": 4
    }
  ],
  "mainboard": {
    "name": "B150M-A",
    "manufacturer": "ASUSTeK COMPUTER INC."
  },
  "graphicAdapter": [
    {
      "name": "NVIDIA GeForce GT 1030",
      "manufacturer": "NVIDIA",
      "videoMemory": 2147483649
    },
    {
      "name": "Intel(R) HD Graphics 530",
      "manufacturer": "Intel Corporation",
      "videoMemory": 1073741824
    }
  ],
  "physicalMemory": [
    {
      "name": "DIMM_A1",
      "manufacturer": "Samsung",
      "bank": "BANK 0",
      "capacity": 4294967296,
      "serialNo": "15392520",
      "type": "DDR3",
      "speed": 1600
    },
    {
      "name": "DIMM_B1",
      "manufacturer": "Samsung",
      "bank": "BANK 2",
      "capacity": 4294967296,
      "serialNo": "15392519",
      "type": "DDR3",
      "speed": 1600
    }
  ],
  "memoryAmount": 8589934592,
  "disk": [
    {
      "capacity": 512105932800,
      "deviceId": "\\\\.\\PHYSICALDRIVE0",
      "interface": "IDE",
      "manufacturer": "(Standard disk drives)",
      "name": "SanDisk SD9SB8W512G1122",
      "partition": [
        {
          "name": "Disk #0, Partition #0",
          "numberOfBlocks": 204800,
          "size": 104857600,
          "startingOffset": 1048576
        },
        {
          "name": "Disk #0, Partition #1",
          "numberOfBlocks": 16777216,
          "size": 8589934592,
          "startingOffset": 105906176
        },
        {
          "fileSystem": "NTFS",
          "mount": "C:",
          "name": "Disk #0, Partition #2",
          "numberOfBlocks": 401210938,
          "size": 205420000256,
          "startingOffset": 8695840768,
          "volumeName": "windows"
        },
        {
          "fileSystem": "NTFS",
          "mount": "D:",
          "name": "Disk #0, Partition #3",
          "numberOfBlocks": 457089024,
          "size": 234029580288,
          "startingOffset": 214116073472,
          "volumeName": "data"
        },
        {
          "name": "Disk #0, Partition #4",
          "numberOfBlocks": 124930048,
          "size": 63964184576,
          "startingOffset": 448145653760
        }
      ],
      "serialNo": "182168800139",
      "smartCaps": true
    },
    {
      "capacity": 1000202273280,
      "deviceId": "\\\\.\\PHYSICALDRIVE1",
      "interface": "IDE",
      "manufacturer": "(Standard disk drives)",
      "name": "ST1000LM024 HN-M101MBB",
      "partition": [
        {
          "fileSystem": "NTFS",
          "mount": "E:",
          "name": "Disk #1, Partition #0",
          "numberOfBlocks": 1953519616,
          "size": 1000202043392,
          "startingOffset": 1048576,
          "volumeName": "data.hdd"
        }
      ],
      "serialNo": "S2R8J9BC700641",
      "smartCaps": true
    }
  ],
  "storageAmount": 4000784417280,
  "cdrom": [
    {
      "name": "HL-DT-ST DVDRAM GP50NB40 USB Device",
      "manufacturer": "(Standard CD-ROM drives)",
      "type": "DVD Writer"
    }
  ],  
  "networkAdapter": [
    {
      "connectionId": "Ethernet",
      "dlSpeed": 100000000,
      "ipv4": {
        "dhcp": true,
        "dns": [
          "210.220.163.82",
          "219.250.36.130"
        ],
        "gateway": [
          "192.168.0.1"
        ],
        "ip": [
          "192.168.0.43/24"
        ]
      },
      "ipv6": {
        "ip": [
          "fe80::8f0:3d03:b67f:7025%8/64"
        ]
      },
      "mac": "80:FA:5B:03:79:5E",
      "manufacturer": "Realtek",
      "name": "Realtek PCIe GBE Family Controller",
      "netEnabled": true,
      "ulSpeed": 100000000
    },
    {
      "connectionId": "Wi-Fi",
      "mac": "D0:7E:35:F7:86:A4",
      "manufacturer": "Intel Corporation",
      "name": "Intel(R) Dual Band Wireless-AC 3160",
      "netEnabled": false
    }
  ]
}
```

Or it can be requested individual items by specifying them as shown below.
```ruby
GET /api/system?info=supported  # Request a list of supported items
```
For the request of a list of supported items, the server response JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "os",
  "cpu",
  "mainboard",
  "memory",
  "graphicAdapter",
  "disk",
  "cdrom",
  "networkAdapter",
  "all"
]
```

### Requests individual items
```ruby
GET /api/system?info=os   # requests OS only
GET /api/system?info=cpu  # requests CPU only
GET /api/system?info=storage,network  # requests both storage and network

GET /api/system?info=all  # requests all the items (Simply /api/system?info or /api/system)
```


## Request system health `@0.3.0`
Requests system health from the server.
```ruby
GET /api/system?health
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
*@0.7.0 cpu data format modified*
```jsx
{
  "lastUpdate": "2018-09-15T13:49:12.440-05:00",
  "cpu": [
    {                         # the 1st CPU
      "temperatureKelvin": {  # Kelvin unit
        "critical": 393.2,    # Critical temperature (System must shut down when this temperature is reached)
        "current": 287.2      # Current temperature
      },
      "usage": {
        "threads": [
          37,                 # Usage percentage of the 1st thread of the 1st CPU
          19,                 # Usage percentage of 2nd thread of the 1st CPU
          50,
          6,
          19,
          31,
          31,
          12
        ],
        "total": 26           # Total usage persantage of the 1st CPU
      }
    }
  ],
  "memory": {
    "totalPhysical": 12797329408,
    "freePhysical": 4630482944,
    "totalVirtual": 14743486464,
    "freeVirtual": 4666306560
  },
  "disk": [
    {
      "name": "C:",
      "totalTimePercent": 0,
      "readTimePercent": 0,
      "writeTimePercent": 0,
      "totalBytesPerSec": 0,
      "readBytesPerSec": 0,
      "writeBytesPerSec": 0,
      "fileSystem": "NTFS",
      "volumeName": "Windows",
      "totalSpace": 135794782208,
      "freeSpace": 32854175744
    },
    {
      "name": "D:",
      "totalTimePercent": 0,
      "readTimePercent": 0,
      "writeTimePercent": 0,
      "totalBytesPerSec": 0,
      "readBytesPerSec": 0,
      "writeBytesPerSec": 0,
      "fileSystem": "NTFS",
      "volumeName": "data.ssd",
      "totalSpace": 161598140416,
      "freeSpace": 7250055168
    },
    {
      "name": "E:",
      "totalTimePercent": 0,
      "readTimePercent": 0,
      "writeTimePercent": 0,
      "totalBytesPerSec": 0,
      "readBytesPerSec": 0,
      "writeBytesPerSec": 0,
      "fileSystem": "NTFS",
      "volumeName": "data.hdd",
      "totalSpace": 1000202039296,
      "freeSpace": 199067635712
    }
  ],
  "recording": {
    "current": "E:\\recData\\",
    "storage": [
      {
        "comment": "Not used",
        "path": "D:\\recData\\",
        "usage": -1
      },
      {
        "comment": "Overwrite",
        "path": "E:\\recData\\",
        "usage": 2
      }
    ]
  },
  "network": [
    {
      "name": "Intel(R) Dual Band Wireless-AC 3160",
      "totalBytesPerSec": 650,
      "recvBytesPerSec": 650,
      "sendBytesPerSec": 0,
      "curBandwidth": 433300000
    },
    {
      "name": "Realtek PCIe GBE Family Controller",
      "totalBytesPerSec": 0,
      "recvBytesPerSec": 0,
      "sendBytesPerSec": 0,
      "curBandwidth": 0
    }
  ]
}
```

The `usage` value under `storage` in `recording` is one of the following:
```ruby
-1    # Not used
0     # Read-only
1     # Write once
2     # Overwrite
```

Or it can be requested individual items by specifying them as shown below.
```ruby
GET /api/system?health=supported  # Request a list of supported items
```
For the request of a list of supported items, the server response JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "cpu",
  "memory",
  "disk",       // Mounted logical disk (disk partition), added at @0.6.0
  "recording",  // Storage status for recording, added at @0.7.0
  "network",
  "all"
]
```

### Requests individual items
```ruby
GET /api/system?health=cpu   # requests CPU only
GET /api/system?health=memory  # requests memory only
GET /api/system?health=disk,recording,network  # requests disk, recording and network
GET /api/system?health=all  # requests all the items (Simply /api/system?health)
```


## Request HDD S.M.A.R.T. `@0.6.0`
Requests S.M.A.R.T. infomation of each HDD.
```ruby
GET /api/system?hddsmart    # Request for all the HDDs
GET /api/system?hddsmart=1  # Request for the first HDD
GET /api/system?hddsmart=1,2  # Request for the first and second HDDs
```
For the request of a list of supported items, the server response JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "code": 1,    // S.M.A.R.T. supports or not (-1:Not tested yet, 0:Not supportd, 1:Supported)
    "message": "Supported",
    "model": "SanDisk SD9SB8W512G1122",
    "name": "\\\\.\\PHYSICALDRIVE0",
    "smart": [
      {
        "attribute": "Reallocated Sector Count",
        "critical": true,
        "id": 5,
        "raw": 100,
        "rawHex": "000000000064",   // added @0.9.13 (hexa decimal text string of raw value)
        "threshold": 0,
        "value": 0,
        "worst": 100
      },
      {
        "attribute": "Power-On Time Count",
        "critical": false,
        "id": 9,
        "raw": 100,
        "rawHex": "000000000064",   // added @0.9.13 (hexa decimal text string of raw value)
        "threshold": 0,
        "value": 1819,
        "worst": 100
      },
      // ... omitted
    ]
  }
]
```


## Request to restart server process `@0.6.0`
If you are logged in with administrator privileges, you can restart the server process.
```ruby
GET /api/system?restart
```
For the request of a list of supported items, the server response JSON data in the following format with an HTTP response code of 200:
```jsx
  {
    "code": 0,
    "message": "The server restarts in a few seconds."
  }
```
The server returns HTTP response code 403 (FORBIDDEN) if you do not have administrator rights.



## Request to reboot server system `@0.6.0`
If you are logged in with administrator privileges, you can reboot the server system.
```ruby
GET /api/system?reboot
```
For the request of a list of supported items, the server response JSON data in the following format with an HTTP response code of 200:
```jsx
  {
    "code": 0,
    "message": "The system will shut down in less than a minute and then restart."
  }
```
The server returns HTTP response code 403 (FORBIDDEN) if you do not have administrator rights.



## Request channel status `@0.3.0`
Requests the status of each channel on the server.
```ruby
GET /api/status
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,
    "status": {
      "code": 200
    }
  },
  {
    "chid": 2,
    "status": {
      "code": 200
    }
  },
  {
    "chid": 3,
    "status": {
      "code": 200
    }
  },
  {
    "chid": 4,
    "status": {
      "code": 200
    }
  },
  // ... omitted
]
```

If necessary, the following parameters can be used.
```ruby
# Parameters
ch        # Channel number (You can specify multiple channels at the same time, which are separated by a comma (,).)
verbose   # Request a message corresponding to a status code
lang      # Specify the language to use for the message
recordingStatus # Request recording status as well (Added since TS-API@0.9.5)

# Examples
# Specify channel 3 only
GET /api/status?ch=3

# Specify only channels 1 to 4
GET /api/status?ch=1,2,3,4

# Include status messages (if lang is not specified, the server-side language settings are applied.)
GET /api/status?verbose=true

# Include status messages in Spanish
GET /api/status?verbose=true&lang=es-ES

# Request recording status of all channels
GET /api/status?recordingStatus

# Request the recording status of channels 1 to 4
GET /api/status?ch=1,2,3,4&recordingStatus
```

Requests, including messages, return JSON data in the following format:
```jsx
[
  {
    "chid": 1,
    "status": {
      "code": 200,
      "message": "Connected"
    }
  },
  {
    "chid": 2,
    "status": {
      "code": 200,
      "message": "Connected"
    }
  },
  {
    "chid": 3,
    "status": {
      "code": 200,
      "message": "Connected"
    }
  },
  {
    "chid": 4,
    "status": {
      "code": 200,
      "message": "Connected"
    }
  },
  // ... omitted
]
```

The complete list of status codes is shown below.
```ruby
-5    # On rebooting
-4    # On reconnecting
-3    # On connecting
-2    # Loading
-1    # Not used
0     # No response
1     # Used
2     # Has video
200   # Connected
401   # Camera login failed
403   # Camera blocked
404   # No network connection
408   # Camera response timeout
410   # No video input
503   # Camera service failure
1000  # Playback complete, TS-API@0.9.7
1404  # No file found, TS-API@0.9.7
```

If requested, including the recording status, returns JSON data in the following format.
```jsx
[
  {
    "chid": 1,
    "status": {
      "code": 200
    },
    "recordingStatus": {
      "streaming": true,
      "recording": true
    }
  },
  {
    "chid": 2,
    "status": {
      "code": 200
    },
    "recordingStatus": {
      "streaming": true,
      "recording": true
    }
  },
  {
    "chid": 3,
    "status": {
      "code": 200
    },
    "recordingStatus": {
      "streaming": true,
      "recording": false
    }
  },
  {
    "chid": 4,
    "status": {
      "code": 200
    },
    "recordingStatus": {
      "streaming": true,
      "recording": false,
      // The time of recording failure (this value is specified only in the failure state)
      "timestampRecordingFailure":"2020-03-25T10:07:09.646-05:00"
    }
  },
  // ... omitted
]
```


## Request various enumeration
The following requests return the JSON data with an HTTP response code of 200 if it is in [session authenticated](#session-authentication) state, or an HTTP response code of 401 if the session is not authenticated.


### Channel list `@0.9.4`
To get a list of channels in use, request the following:
```ruby
GET /api/enum?what=channel
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,              // Channel number
    "title": "Front door",  // Channel name
    "displayName": "CH1. Front door"  // Added since TS-API@0.9.4 ("ptzSupported" removed)
  },
  {
    "chid": 2,              // Channel number
    "title": "",            // Channel name
    "displayName": "CH2"    // Added since TS-API@0.9.4
  }
]
```

#### Adding stream list `@0.9.4`
You can add the `staticSrc` parameter to get the list of streams together.
These streams may not be available depending on the camera connection.
```ruby
GET /api/enum?what=channel&staticSrc
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,
    "title": "Front door",
    "displayName": "CH1. Front door",
    "src": [
      {
        "protocol": "rtmp",
        "profile": "main",
        "src": "rtmp://192.168.0.100/live/ch1main",
        "type": "rtmp/mp4",
        "label": "1080p",
        "size": [
          1920,
          1080
        ]
      },
      {
        "protocol": "flv",
        "profile": "main",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1main",
        "type": "application/x-mpegurl",
        "label": "1080p",
        "size": [
          1920,
          1080
        ]
      },
      {
        "protocol": "hls",
        "profile": "main",
        "src": "http://192.168.0.100/hls/ch1main/index.m3u8",
        "type": "application/x-mpegurl",
        "label": "1080p",
        "size": [
          1920,
          1080
        ]
      },
      {
        "protocol": "rtmp",
        "profile": "sub",
        "src": "rtmp://192.168.0.100/live/ch1sub",
        "type": "rtmp/mp4",        
        "label": "360p",
        "size": [
          640,
          360
        ]
      },
      {
        "protocol": "flv",
        "profile": "main",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1sub",
        "type": "application/x-mpegurl",
        "label": "360p",
        "size": [
          640,
          360
        ]
      },
      
      {
        "protocol": "hls",
        "profile": "sub",
        "src": "http://192.168.0.100/hls/ch1sub/index.m3u8",
        "type": "application/x-mpegurl",
        "label": "360p",
        "size": [
          640,
          360
        ]
      }
    ]
  },
  // omitted
]
```

#### Adding camera capabilities `@0.9.4`
You can add the `caps` parameter to get camera capabilities together.
```ruby
GET /api/enum?what=channel&caps
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,
    "title": "Front door",
    "displayName": "CH1. Front door",
    "caps": {
      "pantilt": true,
      "zoom": true,
      "focus": false,
      "iris": false,
      "home": false,
      "maxPreset": 128,
      "aux": 0,
      "digitalInputs": 1,
      "relayOutputs": 1,
      "reboot": true
    }
  },
  {
    "chid": 2,
    "title": "",
    "displayName": "CH2",
    "caps": {
      "pantilt": true,
      "zoom": true,
      "focus": false,
      "iris": false,
      "home": false,
      "maxPreset": 128,
      "aux": 0,
      "digitalInputs": 1,
      "relayOutputs": 1,
      "reboot": true
    }
  }
]
```


### Vehicle number recognition device list
To get a list of vehicle identification devices in use, ask for the following:
The vehicle number recognition device list includes used devices when an external device is interworked, and in case of TS-LPR with built-in car number recognition function, it includes preset car number recognition zones.

```ruby
GET /api/enum?what=lprSrc
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  // Information received from the interworked car number recognition devices
  {
    "id": 1,                  // Device number
    "code": "F00001",         // Device code
    "name": "F00001",         // Device name
    "linkedChannel": [        // List of channels that are linked when trigger occurs
      1,
      2
    ],
    "tag": "Normal"           // Usage (Normal: Channel in use, NotUsed: Channel not in use, ReadOnly: Read-only channel)
  },

  // In the case of TS-LPR, the information recognized by the car number recognition zone
  {
    "id": 2,                  // Device number
    "code": "1-1-1",          // Device code
    "name": "1-1-1",          // Device name
    "linkedChannel": [],      // List of channels that are linked when trigger occurs (Empty if there is no linked channel)
    "tag": "Normal",          // Usage (Normal: Channel in use, NotUsed: Channel not in use, ReadOnly: Read-only channel)
    "zone": {                 // Recognition zone
      "id": 0,                // Zone number
      "chid": 1,              // Channel number
      "rect": [               // Zone coordinates
        2622, 1499,           // Top-left corner of the rectangle (x0,y0) 
        4297, 4297            // Lower-right corner of the rectangle (x1,y1) 
      ],
      "mode": "driving",      // Number recognition operation mode (driving: Driving mode, parking: Parking mode)
      "disabledOnly": false,  // True if the zone is Disabled parking, false otherwise
      "noParkingAllowed": false // True if the zone is prohibited for parking, false otherwise
    },
    "parkingLot": {           // Connected parking lot id (TS-API@0.9.8)
      "entrance": 1,          // Parking lot entrance id
      "exit": 2               // Parking lot exit id
    }
  }
]

// For the rectangle coordinates of each zone,
// instead of the actual video pixel coordinates,
// the logical coordinate system of 8K (7680x4320) resolution is used.
// For example, if the video is 1920x1080 resolution and the zone is (480, 270, 1440, 810),
// the abscissas are multiplied by 7680/1920, and the ordinates are multiplied by 4320/1080, 
// then be calculated as (1920, 1080, 5760, 3240).
```


### Emergency call device list `@0.3.0`
To receive a list of registered emergency call devices on the server, request the following:

```ruby
GET /api/enum?what=emergencyCall
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  // List of registered emergency call devices
  {
    "id": 1,                  // Device number
    "code": "0000001",        // Location code
    "name": "B1 stairs",      // Device name
    "linkedChannel": [        // Linked channels when trigger occurs
      1,
      2
    ],
  },
  // ... omitted
]
```


### Event log type list
To get a list of supported event log types, request the following:
```ruby
GET /api/enum?what=eventType
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "id": 0,                  // Event log type number
    "name": "System log",     // Event log type name
    "code": [                 // List of event log codes
      {
        "id": 1,              // Event log code number
        "name": "System startup"  // Event log code name
      },
      {
        "id": 2,
        "name": "System shutdown"
      },
      // ... omitted
  },
  {
    "id": 6,
    "name": "User-defined event"
  }
]
```
The list of event log codes is defined by each type.

If you do not specify a language, the default is to return results based on the server's language setting.
If needed, you can change the language using the parameters below.
```ruby
# Parameter
lang      # Language

# Example
# Requesting Spanish
GET /api/enum?what=eventType&lang=es-ES
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "id": 0,
    "name": "Registro del sistema",
    "code": [
      {
        "id": 1,
        "name": "Inicio del sistema"
      },
      {
        "id": 2,
        "name": "Apagado del sistema"
      },
      {
        "id": 3,
        "name": "Apagado anormal"
      },
      // ... omitted
  },
  {
    "id": 6,
    "name": "Evento definido por el usuario"
  }
]
```


### Parking lot list `@0.9.8`
To get a list of registered parking lots on the server, request the followings:
```ruby
GET /api/enum?what=parkingLot
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "counter": [
    {
      "id": 1,
      "name": "B1 Parking Lot",
      "type": "counter"     // parking area (in/out counter)
      "count": 3,           // current entrances
      "maxCount": 50,       // Maximum number of parking spaces
    },
    {
      "id": 2,
      "name": "B2 Parking Lot",
      "type": "counter"     // parking area (in/out counter)
      "count": 25,          // current entrances
      "maxCount": 40,       // Maximum number of parking spaces
    }
  ],
  "group": [
    {
      "id": 3,
      "name": "Basement Parking Lot",
      "type": "group",      // Group (a set of parking area)
      "count": 28,          // Total number of current entrances
      "maxCount": 90,       // Total number of parking spaces
      "member": [           // id of the group menmbers
        1,
        2
      ]
    }
  ]
}
```

### Real-time event list `@0.9.6`
To get a list of real-time events provided by the server, request the followings:
```ruby
GET /api/enum?what=realtimeEvent
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "channelStatus",
  "emergencyCall",
  "LPR",
  "systemEvent",
  "motionChanges",
  "recordingStatus",
  "parkingCount",
  "packing",
  "object"
]
```

### Supported object types `@0.9.11`
To get a list of object types supported by the server, request the followings:
```ruby
GET /api/enum?what=objectType
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "face",
  "human",
  "vehicle"
]
```

### Supported object attributes `@0.9.11`
To get a list of object attributes supported by the server, request the followings:
```ruby
GET /api/enum?what=objectAttr&type=face  # attributes for face
GET /api/enum?what=objectAttr            # attributes for all
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:

In case of attributes for face:
```jsx
{
  "age": [
    "young",
    "adult",
    "middle",
    "senior"
  ],
  "gender": [
    "female",
    "male"
  ],
  "glasses": [
    true,
    false
  ],
  "hat": [
    true,
    false
  ],
  "mask": [
    true,
    false
  ]
}
```

In case of attributes for all:
```jsx
{
  "face": {
    "age": [
      "young",
      "adult",
      "middle",
      "senior"
    ],
    // ... omitted
  },
  "human": {
    "bag": [
      true,
      false
    ],
     // ... omitted
  },
  "vehicle": {
    "vehicleType": [
      "car",
      "truck",
      "bus",
      "bicycle",
      "motorcycle",
      "train"
    ],
    // ... omitted
  }
}
```




## Retrieve recorded data

Use `/api/find` to search for recorded data.


### Search dates with recorded video
To get a list of dates with recorded videos, request the following:

```ruby
GET /api/find?what=recDays      // Request all dates with recorded video
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "timeBegin": "2018-01-01T00:00:00-05:00",     // The first date time requested (local time of the server)
  "timeEnd": "2018-02-28T23:59:59.999-05:00",   //  The last date time requested (local time of the server)
  "data": [
    {
      "year": 2018,
      "month": 1,
      "days": [ // Displays the date in which the data exists in YYYY-MM format as an array
        8,        // The recorded data of 2018-1-1 exists.
        23,       // The recorded data of 2018-1-23 exists.
        24        // The recorded data of 2018-1-24 exists.
      ],
    },
    {
      "year": 2018,
      "month": 2,
      "days": [
        5,
        6,
        7,
        9,
        13,
        14,
        19
      ]
    }
  }
}
```
You can request to meet certain criteria by adding the following parameters:
```ruby
# Parameters
ch          # List of dates on which a specific channel was recorded 
            # (Multiple channels are listed using commas)
timeBegin   # List of dates recorded after a specific date and time
timeEnd     # List of recorded dates before a specific date and time
            # (If the request is made in UTC time, the date based on UTC is returned, 
            # otherwise the date based on the server's local time is returned.)

# Examples
# Request date list of channels 1 recorded
GET /api/find?what=recDays&ch=1
# Request date list of channels 1,2,3 recorded 
GET /api/find?what=recDays&ch=1,2,3

# List of recorded dates since February 2018 (2018-02-01T00: 00:00-05:00)
GET /api/find?what=recDays&timeBegin=2018-02-01T00%3A00%3A00-05%3A00

# List of dates recorded in January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-05:00)
GET /api/find?what=recDays&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# List of dates when channel 1 was recorded in January 2018
GET /api/find?what=recDays&ch=1&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00
```

If you specify a condition using parameters such as `ch`,`timeBegin`, or `timeEnd`, the result is returned, including the requested condition, as shown below.
```jsx
{
  "timeBegin": "2018-01-01T00:00:00-05:00",     // First date and time requested
  "timeEnd": "2018-01-31T23:59:59.999-05:00",   // Last date and time requested
  "data": [
    {
      "chid": 1,   // channel number
      "data": [
        {
          "year": 2018,
          "month": 1,
          "days": [
            8,
            23,
            24
          ]
        },
        // ... omitted
      ]
    }
  ]
}
```


### Search minutes with recorded video `@0.2.0`
To get a list of minutes with recorded videod, request the following:
In the case of minute search, you can not request all of them because the amount of response data can be large, unlike date search.
Specifying only one of timeBegin or timeEnd returns the results of one day's search from the specified date. The date range you can specify is limited to a maximum of 3 days.
The available parameters are the same as `/api/find?what=recDays`.
```ruby
# When using local time
GET /api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00-05%3A00&timeEnd=2018-02-02T00%3A00%3A00-05%3A00

# When using UTC time
GET /api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00Z&timeEnd=2018-05-26T00%3A00%3A00Z
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "timeBegin": "2018-05-25T00:00:00.000-05:00",
  "timeEnd": "2018-05-26T00:00:00.000-05:00",
  "data": [
    {
      "chid": 1,
      "data": [
        {
          "year": 2018,
          "month": 5,
          "day": 25,
          "hour": 10,
          "minutes": [ 44, 45, 46, 47, 48 ]
        },
        {
          "year": 2018,
          "month": 5,
          "day": 25,
          "hour": 18,
          "minutes": [ 1, 2, 3, 4, 16, 17, 18 ]
        }
      ]
    },
    {
      "chid": 2,
      "data": [
        {
          "year": 2018,
          "month": 5,
          "day": 25,
          "hour": 17,
          "minutes": [ 29, 30, 31, 32, 33, 34, 35, 36 ]
        },
        {
          "year": 2018,
          "month": 5,
          "day": 25,
          "hour": 18,
          "minutes": [ 1, 2, 3, 4, 5, 6 ]
        }
      ]
    }
  ]
}
```


### Search event log
To retrieve the event log recorded on the server, request the following.
```ruby
GET /api/find?what=eventLog
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "totalCount": 513,    // Total number of event logs recorded on the server
  "at": 0,              // Current data offset (0 means the first data)
  "data": [             // Event log data list
    {
      "id": 518,                        // Event log number
      "type": 0,                        // Event log type number
      "typeName": "System log",         // Event log type name
      "code": 25,                       // Event log code number
      "codeName": "Storage ready",      // Event log code name
      "timeRange": [
        "2018-02-19T18:24:26.002-05:00" // Occurrence time (events occurring consecutively for a certain period of time include the end time in the second item in the array)
      ],
      "param": {                            // Additional information by event log code
        "storagePath": "E%3A%5CrecData%5C", // Storage path for recording
        "statusCode": 0                     // Storage status codes
      }
    },
    {
      "id": 517,
      "type": 1,
      "typeName": "Privacy",
      "code": 4,
      "codeName": "Sign in",
      "timeRange": [
        "2018-02-19T18:24:20.249-05:00"
      ],
      "param": {
        "uid": "admin",
        "autoLogin": 1
      },
      "comment": "admin: Auto-login"    // optional
    },
    // ... omitted
    {
      "id": 469,
      "type": 0,
      "typeName": "System log",
      "code": 27,
      "codeName": "License applied",
      "timeRange": [
        "2018-02-19T12:11:08.680-05:00"
      ],
      "param": {
        "type": "genuine",
        "maxChannels": 36,
        "extension": [
          1,
          0,
          0
        ],
        "mediaType": "USB dongle"
      },
      "comment": "Genuine license"    // optional
    }
  ]
}
```
The event log recorded on the server is a lot of data, so it is not suitable to send all at once. Therefore, if you do not specify the count, only the log entries from the most recent to the maximum 50 items are returned.
You can use `totalCount`,` at`, and `maxCount` to refer to each page of search results.

If you do not specify a language, the default is to return results based on the server's language setting.
If required, you can specify search parameters by combining one or more of the following parameters.
```ruby
# Parameters
lang        # Language
timeBegin   # List of events recorded after a specific date and time
timeEnd     # List of events recorded before a specific date and time
at          # Offset from the first data
maxCount    # Maximum number of items
sort        # Sorting method (desc: Latest data order (default), asc: Oldest data order)
type        # Event log type

# Examples
# Requesting Arabic
GET /api/find?what=eventLog&lang=ar-AE

# Event log requests recorded during January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-05:00)
GET /api/find?what=eventLog&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# Request 20 items from the 10th item in the search results
GET /api/find?what=eventLog&at=10&maxCount=20

# Sort by old data order (ascending order)
GET /api/find?what=eventLog&sort=asc

# Request the system log type id list
GET /api/enum?what=eventType

# Request only system log (id: 0) of event log types
GET /api/find?what=eventLog&type=0


```



### Vehicle number log search
If you use the car number recognition function, the recognized car number is saved with the video. To retrieve the car number log you will request as follows:

```ruby
GET /api/find?what=carNo
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "totalCount": 64,   // Total number of vehicles number recognition logs on the server
  "at": 0,            // Current data offset (0 means the first data)
  "data": [           // List of vehicle number log data
    {
      "id": 64,                           // Vehicle number log number
      "plateNo": "55EV96",                // Vehicle number text
      "score":95,                           // recognition score (Based on 100 points): May not be supported depending on vehicle identification engine (optioanl)
      "roi": {                            // License plate area
        "offset":[821,473],                 // Top left coordinates
        "size":[173,43]                     // License plate image size
      },
      "image": [                              // an array for the same plates captured consecutively
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732385942440.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386146439.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386199445.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386510078.plate.jpg"
      ],
      "timeRange": [                      // Date and time the vehicle number was recognized
        "2018-02-21T09:07:29.000-05:00",  // Starting timestamp
        "2018-02-21T09:07:34.057-05:00"   // Ending timestamp
      ],
      "srcCode": "1-1-1",                 // Vehicle number recognition device (or zone) code
      "srcName": "The%20Empire%20State",  // Vehicle number recognition device (or zone) name,
      "direction": "entry",               // Vehicle movement direction ("entry" or "exit"), this item can be omitted when there is no movement direction data.
      "vod": [  // The Video at the recognized point (may be several if linked channels are set)
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D21T09%3A07%3A29%2E000-05%3A00"
        },
        {
          "chid": 2,
          "videoSrc": "http://192.168.0.100/watch?ch=2&when=2018%2D02%2D21T09%3A07%3A29%2E000-05%3A00"
        },
        {
          "chid": 3,
          "videoSrc": "http://192.168.0.100/watch?ch=3&when=2018%2D02%2D21T09%3A07%3A29%2E000-05%3A00"
        },
        {
          "chid": 4,
          "videoSrc": "http://192.168.0.100/watch?ch=4&when=2018%2D02%2D21T09%3A07%3A29%2E000-05%3A00"
        }
      ]
    },
    {
      "id": 63,
      "plateNo": "DSP963",
      "score":95,
      "roi": {
        "offset": [753,578],
        "size": [150,38]
      },
      "image": [
        "http://192.168.0.100/storage/e/0/0/0/39/39588.161141.1576732012342440.plate.jpg"
      ],
      "timeRange": [
        "2018-02-21T08:00:00.915-05:00",
        "2018-02-21T08:00:01.714-05:00"
      ],
      "srcCode": "1-1-1",
      "srcName": "1-1-1",,
      "direction": "exit"
      "vod": [
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D21T08%3A00%3A00%2E915-05%3A00"
        },
        {
          "chid": 2,
          "videoSrc": "http://192.168.0.100/watch?ch=2&when=2018%2D02%2D21T08%3A00%3A00%2E915-05%3A00"
        },
        {
          "chid": 3,
          "videoSrc": "http://192.168.0.100/watch?ch=3&when=2018%2D02%2D21T08%3A00%3A00%2E915-05%3A00"
        },
        {
          "chid": 4,
          "videoSrc": "http://192.168.0.100/watch?ch=4&when=2018%2D02%2D21T08%3A00%3A00%2E915-05%3A00"
        }
      ]
    },
    // ... omitted
    {
      "id": 15,
      "plateNo": "L647AN",
      "roi": {
        "offset": [832,380],
        "size": [122,31]
      },
      "timeRange": [
        "2018-02-20T18:12:05.828-05:00",
        "2018-02-20T18:12:06.253-05:00"
      ],
      "srcCode": "1-1-1",
      "srcName": "1-1-1",
      "vod": [
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00"
        }
      ]
    }
  ]
}
```

The vehicle number log recorded on the server is not suitable for sending all at once because it is a large amount of data. Therefore, if you do not specify the count, only the log entries from the most recent to the maximum 50 items are returned.
You can use `totalCount`,` at`, and `maxCount` to refer to each page of search results.

If you do not specify a language, the default is to return results based on the server's language setting.
If required, you can specify search parameters by combining one or more of the following parameters.
```ruby
# Parameters
keyword     # Vehicle number text to search (or some characters)
lang        # Language
timeBegin   # List of vehicle numbers recorded after a specific date and time
timeEnd     # List of vehicle numbers recorded before a specific date and time
at          # Offset from the first data
maxCount    # Maximum number of items
sort        # Sorting method (desc: Latest data order (default), asc: Oldest data order)
src         # Vehicle number recognition device id (separated by a comma (,) if multiple channels are specified at the same time)

# Examples
# Search for vehicle number including "12" (keyword search)
GET /api/find?what=carNo&keyword=12

# Request Arabic
GET /api/find?what=carNo&lang=ar-AE

# Request vehicle number logs recorded during January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-059:00)
GET /api/find?what=carNo&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# Request 20 items from the 10th item in the search results
GET /api/find?what=carNo&at=10&maxCount=20

# Sort by old data order (ascending order)
GET /api/find?what=carNo&sort=asc

# Search by specifying vehicle number recognition device 1, 2
GET /api/find?what=carNo&src=1,2
```

To display the video in the retrieved result data, use the method used in [Display recorded video](#display-recorded-video).

For example, if you want to display a video of the following search results
```jsx
  // ... omitted
  {
    "id": 15,
    "plateNo": "55EV96",
    "timeRange": [
      "2018-02-20T18:12:05.828-05:00",
      "2018-02-20T18:12:06.253-05:00"
    ],
    "srcCode": "1-1-1",
    "srcName": "1-1-1",
    "vod": [
      {
        "chid": 1,
        "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00"
      }
    ]
  }
  // ... omitted
```
In here, you can display video using  `http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00` corresponding to the value of `"videoSrc"` in `"vod"`.

```ruby
# If the session is authenticated, use it as it is
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00

# If the session is not authenticated, add the auth parameter
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00&auth=ZGVtbzohMTIzNHF3ZXI%3D
```

### Export the search result of vehicle numbers log `@0.9.18`
You can download the searched vehicle numbers log as Excel files.
```ruby
GET /api/find?what=carNo&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00&export=true
```
If you request by adding `export=true` parameter to vehicle number log search
The server returns JSON data in the format shown below with an HTTP response code of 200 as follows:
```jsx
[
  "http://host/download/2018-01-01T00.00.00.xls",   // Excel file download URL
  "http://host/download/2018-01-01T00.00.00(2).xls",
    // ... omitted
]
```

### Search for similar vehicle numbers `@0.2.0`
Can be used to verify that a similar vehicle number exists.
To retrieve similar vehicle numbers from the log, request the following:
```ruby
GET /api/find?what=similarCarNo&keyword=1234

# Parameters
keyword     # Vehicle number text to search (or some characters)
maxCount    # Maximum number of items

# Examples
# Request up to 10 results
GET /api/find?what=similarCarNo&keyword=123&maxCount=10
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "AVF4123",
  "123MTB",
    // ... omitted
]
```

### Object Search `@0.9.11`
When using the object detection function, the detected objects (`face`,` human`, `vehicle`) are saved with the video. To search the object detection log, request as follows.

```ruby
GET /api/find?what=object
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "totalCount": 100,
  "at": 0,
  "data": [
    {
      "timestamp": "2020-05-25T14:58:15.819-05:00",
      "chid": 1,               # channel id
      "objId": 837,            # object id (If the id is the same, it is divided into the same object)
      "type": "face",          # object type
      "likelihood": 82.59      # detection accuracy (%)
      "attributes": {          # object attributes (list only detected attributes)
        "gender": "female",    # gender
        "age": "middle",       # age 
        "glasses": true,       # glasses (wearing)
        "mask": false          # mask (not wearing)
      },  
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412659.1590386295819221.object._c1_t2_s392x504.jpg" # image address
    },
    {
      "timestamp": "2020-05-25T14:58:14.449-05:00",
      "chid": 1,               # channel id
      "objId": 842,            # object id (If the id is the same, it is divided into the same object)
      "type": "face",          # object type
      "likelihood": 90.09,     # detection accuracy (%)
      "attributes": {          # object attributes (list only detected attributes)
        "gender": "male"       # gender
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412660.1590386294449281.object._c1_t2_s744x624.jpg" # image address
    },
    {
      "timestamp": "2020-05-25T14:58:14.185-05:00",
      "chid": 1,               # channel id
      "objId": 834,            # object id (If the id is the same, it is divided into the same object)
      "type": "human",         # object type
      "likelihood": 62.20,     # detection accuracy (%)
      "attributes": {          # object attributes (list only detected attributes)
        "gender": "male",      
        "clothes": [           
          {
            "type": "tops",    
            "length": "long",  # the length of sleeves
            "colors": [        
              "red"
            ]
          },
          {
            "type": "bottoms", 
            "length": "long",  # the length of pants
            "colors": [        
              "red"
            ]
          }
        ]
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412658.1590386294185653.object._c1_t1_s296x464.jpg" # image address
    },
    {
      "timestamp": "2020-05-25T14:55:21.557-05:00",
      "chid": 1,               # channel id
      "objId": 748,            # object id (If the id is the same, it is divided into the same object)
      "type": "vehicle",       # object type
      "likelihood": 95.80,     # detection accuracy (%)
      "attributes": {          object attributes (list only detected attributes)
        "vehicleType": "car",  # vehicle type
        "colors": [            
          "gray"
        ]
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673909/7673909.4412630.1590386121557955.object._c1_t3_s440x312.jpg" # image address
    },
    // ... omitted
  ]
}
```

The contents of the `data` item of the search result are the same as the contents of [Object Detection Event `@ 0.9.11`] (#object-detection-event-0911).

You can also search for conditions by specifying parameters for each object as shown below.

#### Common parameters
```ruby
lang        # language
timeBegin   # List of objects recorded after a specific date and time
timeEnd     # List of objects recorded before a specific date and time
ch          # The channel number, multiple numbers can be used using commas(,)
objectType  # The type of object (One of face, human, and vehicle, if not specified, means all kinds of objects)
at          # Offset from the first data
maxCount    # Maximum number of items
sort        # Sorting method (desc: Latest data order (default), asc: Oldest data order)


# Requests for objects stored during January 2020
# (2020-01-01T00:00:00-05:00 ~ 2020-01-31T23:59:59.999-05:00)
GET /api/find?what=object&timeBegin=2020-01-01T00%3A00%3A00-05%3A00&timeEnd=2020-01-31T23%3A59%3A59.999-05%3A00

# Request only objects of channels 1 and 2
GET /api/find?what=object&ch=1,2

# Request only face objects
GET /api/find?what=object&objectType=face

# Request 20 items from the 10th item of the search result
GET /api/find?what=object&at=10&maxCount=20

# Requests sorted by oldest data (ascending)
GET /api/find?what=object&sort=asc
```

#### Parameters for `face`
```ruby
gender       # Gender designation (either male or female)
age          # Age classification (one of young, adult, middle, senior)
hat          # Wearing a hat (either true or false)
glasses      # Wearing glasses (either true or false)
mask         # Wearing a mask (either true or false)

# Man only request
GET /api/find?what=object&objectType=face&gender=male

# Adults only
GET /api/find?what=object&objectType=face&age=adult

# Middle-aged woman only
GET /api/find?what=object&objectType=face&gender=female&age=middle

# Request only for people with glasses
GET /api/find?what=object&objectType=face&glasses=true

# Request only for people wearing glasses and hats
GET /api/find?what=object&objectType=face&glasses=1&hat=1

# Request only for people not wearing a mask
GET /api/find?what=object&objectType=face&mask=false

# Request only for people wearing glasses but mask
GET /api/find?what=object&objectType=face&glasses=true&mask=false
```


#### Parameters for `human`
```ruby
gender        # Gender designation (either male or female)
hat           # Wearing a hat (either true or false, or either 1 or 0)
bag           # Beloing a bag (either true or false, or either 1 or 0)
topClothes    # Top length and colors (Separate multiples with comma (,))
              # length (ether short or long)
              # colors (multiple choices among brown, black, red, orange, yellow, green, cyan, blue, purple, magenta, gray, pink, beige, white, and other)
bottomClothes # Bottom length and colors (The expressions are the same as topColors)

# Woman only requests
GET /api/find?what=object&objectType=human&gender=female

# Request only for people with bags
GET /api/find?what=object&objectType=human&bag=true

# Request only for people with hats and bags
GET /api/find?what=object&objectType=human&hat=true&bag=true

# people in short-sleeved
GET /api/find?what=object&objectType=human&topClothes=short

# people in yellow top
GET /api/find?what=object&objectType=human&topClothes=yellow

# People in red and blue top
GET /api/find?what=object&objectType=human&topClothes=red,blue

# People in shorts
GET /api/find?what=object&objectType=human&bottomClothes=short

# People in black both upper and lower
GET /api/find?what=object&objectType=human&topClothes=black&bottomClothes=black

# Men in a white top wearing a hat and holding a bag
GET /api/find?what=object&objectType=human&hat=1&bag=1&topClothes=white&gender=male
```


#### Parameters for `vehicle`
```ruby
vehicleType  # Vehicle type and colors, Separated by comma (,)
             # Vehicle type (car, truck, bus, bicycle, motorcycle, train 중 하나) 
             # Vehicle colors (multiple choices among brown, black, red, orange, yellow, green, cyan, blue, purple, magenta, gray, pink, beige, white, and other)

# Bus only request
GET /api/find?what=object&objectType=vehicle&vehicleType=bus

# Yellow car only request
GET /api/find?what=object&objectType=vehicle&vehicleType=car,yellow
```

### Face Search `@0.9.6`
You can find faces that resemble using photo of faces.

In order to send a photo image, it is requested using the `HTTP POST` method.
Set search condition with CGI parameter and send only image as POST data.
Supported image file formats are `jpg` (`Content-Type=image/jpeg`) and `png` (`Content-Type=image/png`).


```ruby
lang        # Language
timeBegin   # Faces recorded after a specific date and time
timeEnd     # Faces recorded before a specific date and time
ch          # The channel number, multiple numbers can be used using commas(,)
threshold   # Similarity (specified by 1 ~ 100 percentage)

# Search faces recorded during January 2020
# (2020-01-01T00:00:00-05:00 ~ 2020-01-31T23:59:59.999-059:00)
GET /api/searchFace?timeBegin=2020-01-01T00%3A00%3A00-05%3A00&timeEnd=2020-01-31T23%3A59%3A59.999-05%3A00

# Search faces of channels 1 and 2
GET /api/searchFace?ch=1,2

# 95% similar face search
GET /api/searchFace?threshold=95
```



## Search for video sources
You can use this method if your application uses the video address directly instead of the video display feature using the API you used in [Inserting video into web page](#inserting-video-into-web-page).

This way you can get video address instead of displaying video.


### Real-time video source
You can request a list of real-time video addresses that the server is streaming by requesting the following without any parameters:
```ruby
GET /api/vod
```
The server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[ // Each channel consists of an array of items
  {
    "chid": 1,                        // Channel number
    "title": "Profile1 (1920x1080)",  // Channel name
    "display": "CH1: Profile1 (1920x1080)",
    "src": [  // List of video sources
              // (Multiple sources are organized into an array in one channel, depending on protocol and resolution)
      { // 1080p RTMP stream
        "protocol": "rtmp",
        "profile": "main",
        "src": "rtmp://192.168.0.100/live/ch1main",  // Video address
        "type": "rtmp/mp4",     // MIME type: RTMP protocol (Adobe Flash)
        "label": "1080p",       // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ]
      },
      { // 1080p HTTP-FLV stream
        "protocol": "flv",
        "profile": "main",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1main", // Video address
        "type": "video/x-flv",  // MIME type: FLV (HTTP protocol)
        "label": "1080p",       // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ]
      },
      { // 1080p HLS stream
        "protocol": "hls",
        "profile": "main",
        "src": "http://192.168.0.100/live/ch1main/index.m3u8", // Video address
        "type": "application/x-mpegurl",  // MIME type: HLS protocol (HTML5)
        "label": "1080p",       // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ]
      },
      { // VGA RTMP stream
        "protocol": "rtmp",
        "profile": "sub",
        "src": "rtmp://192.168.0.100/live/ch1sub",   // RTMP protocol (Adobe Flash)
        "type": "rtmp/mp4",   // MIME type: RTMP protocol (Adobe Flash)
        "label": "VGA",
        "size": [
          640,
          480
        ]
      },
      { // VGA HTTP-FLV stream
        "protocol": "flv",
        "profile": "sub",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1sub", // Video address
        "type": "video/x-flv",  // MIME type: FLV
        "label": "VGA",       // Resolution name
        "size": [             // Resolution
          640,                // Number of horizontal pixels
          480                 // Number of vertical pixels
        ]
      },
      { // VGA HLS stream
        "protocol": "hlv",
        "profile": "sub",
        "src": "http://192.168.0.100/live/ch1sub/index.m3u8", // Video address
        "type": "application/x-mpegurl",  // MIME type: HLS protocol (HTML5)
        "label": "VGA",       // Resolution name
        "size": [             // Resolution
          640,                // Number of horizontal pixels
          480                 // Number of vertical pixels
        ]
      }
    ]
  },
  {
    "chid": 2,
    "title": "192.168.0.106",
    "display": "CH2: 192.168.0.106",
    "src": [
      // ... omitted
    ]
  },
  // ... omitted
]
```
> [Tips]
Added `"ptzSupported"` item from `TS-API@0.5.0`.

Because of the variety of environments (network bandwidth and protocol supported by the player) in which the video is played, we provide multiple video sources per channel as shown in the example above for compatibility.
In the current version, it is streamed in two formats `RTMP` and` HLS`, and if the camera supports it, it can be dual-stream in high resolution and low resolution.

In fact, the `when=now` parameter, which means live video, is omitted in the example above.
```ruby
GET /api/vod?when=now
```

If required, you can specify search parameters by combining one or more of the following parameters.
```ruby
ch          # Channel number (meaning all channels if not specified)
protocol    # Specify a streaming protocol (rtmp, hls)
stream      # Specify the resolution of the video (main: High definition video, sbu: Low-resolution video)
nameonly    # If true, only the channel name is requested without the video stream data part. 

# Examples
# Request channel 1 only
GET /api/vod?ch=1

# Request only hls protocol streams
GET /api/vod?protocol=hls

# Request only low-resolution streams
GET /api/vod?stream=sub

# Only request channel name
GET /api/vod?nameonly=true
# Or simply
GET /api/vod?nameonly
```



### Recorded video source
In general, you will use the [Search date with recorded video](#search-date-with-recorded-video) function to access the recorded video, but here are some ways to get a video source recorded at a lower level.

Use `/api/vod`, which is used when requesting a real-time video sources, and specify different parameters as follows.
```ruby
when        # Specify the timestamp of recorded video
duration    # The time period to search from the time specified by when
id          # The file ID of recorded video
next        # If true, the next video of the specified one
prev        # If true, the previous video of the specified one
limit       # Specify the number of items in the search results (default 10, maximum 50)
otherwise   # If there is no search result,
            # If requested with 'nearBefore', near recorded video before the search time period will be returned.
            # If requested with 'nearAfter', near recorded video after the search time period will be returned.
nolive      # Prevents search results from including real-time videos even timestamp is less than 1 minute from the current time (TS-API@0.9.9)

# Examples
# The channel 1 video source on channel 1 ecorded on January 8, 2018 at 9:30 PM EST
# [Important!]
#   1. For recorded video, HTTP response code 400 (invalid request) occurs if 'ch=' is not specified.
#   2. Only data within 1 second is retrieved from the time specified by 'when='.
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00

# Search the channel 1 video source for data within 1 hour from 9:30 PM 00:00 on January 8, 2018
# [Time unit notation used by duration]
#   w: week   (eg: 1w = one week)
#   d: day    (eg: 5d = 5 days)
#   h: hour   (eg: 3h = 3 hours)
#   m: minute (eg: 10m = 10 minutes)
#   s: second (eg: 30s = 30 seconds)
#   ms: millisecond (1/1000 sec.) (eg: 5000ms = 5000 milliseconds = 5 seconds)
#   * If units are not specified, seconds is used by the default.
#   * Notation combining multiple units (eg: 1h30m) is not supported and must be
#     calculated (eg: 90m) in the smallest unit if necessary
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00&duration=1h

# Direct request using recording file ID
# If there is a video, it returns 10 consecutive (by default) video sources 
# from that video.
# [Tips]
#   Each video file recorded on the server is assigned a unique serial number 
#   that is represented by an integer.
GET /api/vod?id=1304

# If the current file ID of channel 1 is 1034, it requests the next file
# of the same channel (useful for continuous playback)
GET /api/vod?ch=1&id=1304&next=true
# Or simply
GET /api/vod?ch=1&id=1304&next

# If the current file ID of channel 1 is 1034, it requests the previous file
# of the same channel (useful for continuous backward playback)
GET /api/vod?ch=1&id=1304&prev=true
# Or simply
GET /api/vod?ch=1&id=1304&prev

# Receive 30 searched video sources
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00&duration=1h&limit=30

# If there is no search result,
# request near recorded video before the search time period
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearBefore
# request near recorded video after the search time period
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearAfter
```

When this request is made, the server returns JSON data in the following format with the HTTP response code 200:

```jsx
[ // Consists of an array of recorded video file units
  {
    "chid": 1,                        // Channel number
    "title": "192%2E168%2E0%2E111",   // Channel name
    "fileId": 100,                    // File ID
    "src": [  // Video source
      {
        "src": "http://192.168.0.100/storage/e/0/0/0/0/100.mp4",  // Video address
        "type": "video/mp4",    // MIME type (mp4 file)
        "label": "1080p FHD",   // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ],
        "timeRange": [
          "2018-02-05T17:57:12.935-05:00",  // Date and time of the beginning of the video file
          "2018-02-05T17:57:20.036-05:00"   // Date and time of the end of the video file
        ]
      }
    ]
  },
  // ... omitted
  {
    "chid": 1,
    "title": "192%2E168%2E0%2E111",
    "fileId": 104,
    "src": [
      {
        "src": "http://192.168.0.100/storage/e/0/0/0/0/104.mp4",
        "type": "video/mp4",
        "label": "1080p FHD",
        "size": [
          1920,
          1080
        ],
        "timeRange": [
          "2018-02-05T18:05:12.147-05:00",
          "2018-02-05T18:05:12.229-05:00"
        ]
      }
    ]
  }
]
```


## Requesting video using video source `@0.3.0`
For video request using video source without using `/watch` provided by API, authentication is supported by each protocol as follows.
```ruby 
# RTMP (auth= parameter supported)
rtmp://host/path/to&?auth=ZGVtbzohMTIzNHF3ZXI%3D

# HTTP (Only basic authentication is supported for file-based resources such as m3u8, JPG, and MP4)
http://userid:password@host/path/to

# HTTP (The resources of sub path /api/ are supported in both ways)
http://userid:passwordn@host/api/path/to
http://host/api/path/to&?auth=ZGVtbzohMTIzNHF3ZXI%3D
```


## Real-time event monitoring `@0.3.0`

### Web Sockets (RFC6455)
Supports the ability to receive real-time event messsage using HTML5 Web sockets (RFC6455) method.
Once connection established the server and the client maintain the connection state, and when an event occurs, the server sends a message to the client.

The step-by-step communication procedure is as follows:
>1. Client connects to the server via Web Sockets.
>2. If the authentication to the server succeeds, the subscriber ID is issued.
>3. The client then remains connected and enters the message waiting state.
>>* The server sends a ping message every 30 seconds to keep the connection even if there is no message to send.
>4. When an event occurs, the server sends a message to the client.
>5. Repeat steps 3 through 4 until the client ends the connection itself.

> [Tips]
The web socket method is supported by all web browsers including Microsoft web browsers.
https://developer.mozilla.org/en-US/docs/Web/API/WebSocket


The following event topics are supported:
```ruby
channelStatus   # Change channel status
LPR             # Car number recognition
emergencyCall   # Emergency call
systemEvent     # System Events (added @0.7.0)
motionChanges   # Motion detection status changes (added @0.8.0)
parkingCount    # Parking count events (added @0.9.0)
packing         # Packing event (added @0.9.0)
recordingStatus # Recording status event (added @0.9.5)
object          # Object detection event (added @0.9.6)
```

The web socket connection path and parameters are as follows.
```ruby
/wsapi/subscribeEvents

# Required parameters
auth    # Authentication Information (Requires authentication per individual web socket, independent of session authentication)
topics  # Specify topics to receive (You can specify multiple topics at the same time, which are separated by a comma (,).)

# Optional argument
verbose # For emergencyCall, request List the live video stream sources of the linked video channels
        # For channelStatus, request status messages (Include "title" in initial message immediately after issuing subscriber id
session # Can pass authentication credentials by passing session cookie already connected

# channelStatus-specific parameters (optional)
ch      # Used when specifying specific channels (separated by a comma (,) if multiple channels are specified at the same time)
lang    # Specify language for status messages

# Example
# Request car number recognition event
ws://host/wsapi/subscribeEvents?topics=LPR&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Request emergency call event
ws://host/wsapi/subscribeEvents?topics=emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Request both events
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D

# request List the live video stream sources of the linked video channels
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true

# Request status change events for all channels
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Requests status change events for all channels including messages
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true

# Requests status change events of channels 1 and 2 including Spanish messages
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2&verbose=true&lang=es-ES

# Requests motion detection status change events for all channels
ws://host/wsapi/subscribeEvents?topics=motionChanges&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Requests motion detection status change events of channels 1 and 2
ws://host/wsapi/subscribeEvents?topics=motionChanges&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2

# Requests parking count for all the parking lots
ws://host/wsapi/subscribeEvents?topics=parkingCount&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Requests parking count for the parking lot id 1 and 2 (in this case the `ch` used as parking lot id)
ws://host/wsapi/subscribeEvents?topics=parkingCount&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2
```


The server issues the recipient ID in JSON format as shown below if the requested authentication information and topic are correct.
If the authentication information is incorrect or is not a supported topic, it will be disconnected immediately.
```jsx
{
  "subscriberId": "cd57c82b-7e8c-4b04-91eb-520f6a9773ce", // subscriber ID (Unique ID per each connection)
  "topics": [   // Reply to requested topics (Both events are supported)
    "LPR",
    "emergencyCall"
  ]
}
```


### Channel status change events
You can receive channel status change events in real time by requesting `topics=channelStatus`.
Unlike other topics, in case of the channel status topic, for status change management, the current channel status is sent once, immediately after issuing the subscriber id.
The rest events are then sent only when there is a change from the initial state.
Channel status change event messages are received in JSON format as shown below.
```jsx
// subscriber id
{
  "subscriberId":"1a3dc2de-d3b5-4983-933a-49a86ac8ad3d",
  "topics": [
    "channelStatus"
  ]
}

// Current all channel status (sent immediately after the subscriber id)
{
  "timestamp": "2018-07-20T15:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "currentStatus",
  "channel": [
    {
      "chid": 1,
      "title": "Camera1",
      "displayName": "CH1. Camera1",  // Added since TS-API@0.9.4
      "status": {
        "code": 200,
        "message": "Connected"
      },
      "caps": {   // Camera capabilities (Added since TS-API@0.9.4)
        "pantilt": true,
        "zoom": true,
        "focus": false,
        "iris": false,
        "home": false,
        "maxPreset": 0,
        "aux": 0,
        "digitalInputs": 1,
        "relayOutputs": 0,
        "reboot": true
      },
      "src": [  // Available stream list (Added since TS-API@0.9.4)
        {
          "protocol": "rtmp",
          "profile": "main",
          "src": "rtmp://localhost/live/ch3main",
          "type": "rtmp/mp4",
          "label": "WXGA",
          "size": [
            1280,
            960
          ]
        },
        {
          "protocol": "hls",
          "profile": "main",
          "src": "http://localhost/hls/ch3main/index.m3u8",
          "type": "application/x-mpegurl",
          "label": "WXGA",
          "size": [
            1280,
            960
          ]
        },
        {
          "protocol": "rtmp",
          "profile": "sub",
          "src": "rtmp://localhost/live/ch3sub",
          "type": "rtmp/mp4",
          "label": "VGA",
          "size": [
            640,
            480
          ]
        },
        {
          "protocol": "hls",
          "profile": "sub",
          "src": "http://localhost/hls/ch3sub/index.m3u8",
          "type": "application/x-mpegurl",
          "label": "VGA",
          "size": [
            640,
            480
          ]
        }
      ]
    },
    {
      "chid": 2,
      "title": "Camera2",
      "displayName": "CH2. Camera2",
      "status": {
        "code": 200,
        "message": "Connected"
      },
      "caps": {
        "pantilt": true,
        "zoom": true,
        "focus": false,
        "iris": false,
        "home": false,
        "maxPreset": 128,
        "aux": 0,
        "digitalInputs": 1,
        "relayOutputs": 1,
        "reboot": true
      },
      "src": [
        {
          "protocol": "rtmp",
          "profile": "main",
          "src": "rtmp://localhost/live/ch1main",
          "type": "rtmp/mp4",
          "label": "1080p",
          "size": [
            1920,
            1080
          ]
        },
        {
          "protocol": "hls",
          "profile": "main",
          "src": "http://localhost/hls/ch1main/index.m3u8",
          "type": "application/x-mpegurl",
          "label": "1080p",
          "size": [
            1920,
            1080
          ]
        },
        {
          "protocol": "rtmp",
          "profile": "sub",
          "src": "rtmp://localhost/live/ch1sub",
          "type": "rtmp/mp4",
          "label": "360p",
          "size": [
            640,
            360
          ]
        },
        {
          "protocol": "hls",
          "profile": "sub",
          "src": "http://localhost/hls/ch1sub/index.m3u8",
          "type": "application/x-mpegurl",
          "label": "360p",
          "size": [
            640,
            360
          ]
        }
      ]
    },
  // ... omitted
  ]
}

// When channel name changes
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "nameChanged",
  "chid": 1,
  "name": "Camera1",
  "displayName: "CH1. Camera1"  // Added since TS-API@0.9.4
}

// When the video address modified
{
  "timestamp": "2018-07-20T16:01:45.956-05:00",
  "topic": "channelStatus",
  "event": "videoSrcModified",
  "chid": 1
}

// When the video stream is connected
{
  "timestamp": "2018-07-20T16:03:45.956-05:00",
  "topic": "channelStatus",
  "event": "videoStreamReady",
  "chid": 1,
    "status": {
    "code": 2,
    "message": "Video available"
  },
  "src": [  // Available stream list (Added since TS-API@0.9.4)
    {
      "protocol": "rtmp",
      "profile": "main",
      "src": "rtmp://localhost/live/ch1main",
      "type": "rtmp/mp4",
      "label": "1080p",
      "size": [
        1920,
        1080
      ]
    },
    {
      "protocol": "hls",
      "profile": "main",
      "src": "http://localhost/hls/ch1main/index.m3u8",
      "type": "application/x-mpegurl",
      "label": "1080p",
      "size": [
        1920,
        1080
      ]
    },
    {
      "protocol": "rtmp",
      "profile": "sub",
      "src": "rtmp://localhost/live/ch1sub",
      "type": "rtmp/mp4",
      "label": "360p",
      "size": [
        640,
        360
      ]
    },
    {
      "protocol": "hls",
      "profile": "sub",
      "src": "http://localhost/hls/ch1sub/index.m3u8",
      "type": "application/x-mpegurl",
      "label": "360p",
      "size": [
        640,
        360
      ]
    }
  ]
}

// Video stream has the same address but needs to be reconnected
{
  "timestamp": "2018-07-20T16:03:45.956-05:00",
  "topic": "channelStatus",
  "event": "videoStreamChanged",
  "chid": 1
}

// When the camera is connected
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "statusChanged",
  "chid": 1,
  "status": {
    "code": 200,
    "message": "Connected"
  }
}

// When a channel was added (setting changed)
// Added since TS-API@0.9.4
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelAdded",
  "chid": 1
}

// When a channel was removed (setting changed)
// Added since TS-API@0.9.4
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelRemoved",
  "chid": 1
}

// When channel numbers of two channels are exchanged (setting changed)
// Added since TS-API@0.9.4
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelSwapped",
  "chid": [1,2]
}
```

The list of channel status codes is the same as the status code list in [Request channel status `@0.3.0`](#request-channel-status-030).


### Car number recognition events
If you request `topics=LPR`, you can receive the car number recognition event in real time.
The car number event message is received in JSON format as shown below.
```jsx
{
  "timestamp":"2018-06-27T10:42:06.575-05:00",  // Vehicle number recognition time
  "chid": {                                     // Car number recognition channel
    "chid":1,
    "title":"Camera1",
    "displayName":"CH1. Camera1", // Added since TS-API@0.9.4
    "src":"http://host/watch?ch=1&when=2018%2D06%2D27T10%3A42%3A06%2E575-05%3A00"  // The video at vehicle identification time
  },
  "deviceCode":"1-1-7",                         // Car number identification device (zone) code
  "deviceName":"B1 Parking Lot",                // Car number identification device (zone) name
  "linkedChannel": [                            // Linked channels
    {
      "chid":2,
      "title":"Camera2",
      "displayName":"CH2. Camera2",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=2&when=2018%2D06%2D27T10%3A42%3A06%2E575-05%3A00" // The video at vehicle identification time
    }
  ],
  "image":"http://host/storage/e/0/0/0/39/39612.161192.1576732638241699.plate.jpg", // captured still cut image
  "plateNo":"DSP963",                           // License plate number
  "score":98,                                   // recognition score (Based on 100 points): May not be supported depending on vehicle identification engine (optional item)
  "roi": {                                      // License plate area
    "offset":[964,560],                         // Top left coordinates
    "size":[187,51]                             // License plate image size
  },
  "timeBegin":"2018-06-27T10:42:02.573-05:00",  // First recognized time of the car
  "topic":"LPR",                                // Topic name
  "parkingLot": {                               // Connected parking lot id (TS-API@0.9.8)
    "entrance": 1,                              // Parking lot entrance id
    "exit": 2                                   // Parking lot exit id
  },
  "direction": "entry"                          // Vehicle movement direction ("entry" or "exit"), this item can be omitted when there is no movement direction data.
}
```


### Emergency call events
If you request `topics=emergencyCall`, you can receive the event messages at the start and end of the emergency call in real time.
Emergency call event messages are received in JSON format as shown below.

**Call start message**
```jsx
{
  "timestamp":"2018-06-27T10:56:16.316-05:00",  // Start time of the call
  "caller":"0000002",                           // Emergency call device location code
  "device":"Sammul/Vizufon",                    // Emergency call device name
  "event":"callStart",                          // Call start event
  "linkedChannel":[                             // Linked channels
    {
      "chid":1,
      "title":"Camera1",
      "displayName":"CH1. Camera1",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"Camera2",
      "displayName":"CH2. Camera2",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=2"
    }
  ],
  "name":"B1 Stairs",                           // Emergency call device location name
  "topic":"emergencyCall"                       // Topic name
}
```

Emergency call events are events for real-time communication, so all channels are linked to real-time video.
If you request the video stream source of the channels as shown below, the video stream sources are additionally included.
```ruby
GET /api/subscribeEvents?topics=emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true
```
```jsx
{
  "timestamp":"2018-06-27T10:56:16.316-05:00",  // Start time of the call
  "caller":"0000002",                           // Emergency call device location code
  "device":"Sammul/Vizufon",                    // Emergency call device name
  "event":"callStart",                          // Call start event
  "linkedChannel":[                             // Linked channels
    {
      "chid":1,
      "title":"Camera1",
      "displayName":"CH1. Camera1",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=1",
      "streams": [  // vidio stream sources
                // (Multiple sources are organized into an array in one channel, depending on protocol and resolution)
        { // 1080p RTMP stream
          "src": "rtmp://host/live/ch1main",  // video address
          "type": "rtmp/mp4",     // MIME type: RTMP protocol (Adobe Flash format)
          "label": "1080p FHD",   // resolution name
          "size": [               // resolution
            1920,                 // the number of horizontal pixels
            1080                  // the number of verical pixels
          ]
        },
        { // 1080p HLS stream
          "src": "http://host/hls/ch1main/index.m3u8", // video address
          "type": "application/x-mpegurl",  // MIME type: HLS protocol (format)
          "label": "1080p FHD",   // resolution name
          "size": [               // resolution
            1920,                 // the number of horizontal pixels
            1080                  // the number of verical pixels
          ]
        },
        { // VGA RTMP stream
          "src": "rtmp://host/live/ch1sub",   // RTMP protocol (Adobe Flash format)
          "type": "rtmp/mp4",   // MIME type: RTMP protocol (Adobe Flash format)
          "label": "VGA",
          "size": [
            640,
            480
          ]
        },
        { // VGA HLS stream
          "src": "http://host/hls/ch1sub/index.m3u8", // video address
          "type": "application/x-mpegurl",  // MIME type: HLS protocol (HTML5 format)
          "label": "VGA",       // resolution name
          "size": [             // resolution
            640,                // the number of horizontal pixels
            480                 // the number of verical pixels
          ]
        }
      ]
    },
    {
      "chid":2,
      "title":"Camera2",
      "displayName":"CH2. Camera2",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=2",
      "streams":[
        // ... omitted
      ]
    }
  ],
  "name":"B1 Stairs",                     // Emergency call device location name
  "topic":"emergencyCall"                 // Topic name
}
```

**Call end message**
```jsx
{
  "timestamp":"2018-06-27T10:59:26.322-05:00",  // End time of then call
  "caller":"0000002",                           // Emergency call device location code
  "device":"Sammul/Vizufon",                    // Emergency call device name
  "event":"callEnd",                            // Call end event
  "linkedChannel":[                             // Linked channels
    {
      "chid":1,
      "title":"Camera1",
      "displayName":"CH1. Camera1",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"Camera2",
      "displayName":"CH2. Camera2",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=2"
    }
  ],
  "name":"B1 Stairs",                          // Emergency call device location name
  "topic":"emergencyCall"                      // Topic name
}
```
Emergency call event messages are used for real-time communication, so the video address of the linked channel is linked to the real-time video unlike the case of car number recognition.


### System event `@0.7.0`
If you request `topics = systemEvent`, you can receive system events in real time.
System event is received in JSON format as below when "System log" data is generated from [Event log type list](#event-log-type-list).
Each data type is the same as those used in [Search event log](#search-event-log).

```jsx
{
  "topic": "systemEvent",
  "id": 16384,
  "type": 0,
  "typeName": "System log",
  "code": 30,
  "codeName": "Storage path changed",
  "timeRange": [
    "2018-11-15T13:16:38.054-05:00"
  ],
  "param": {
    "storagePathBefore": "D:\\recData\\",
    "storagePathAfter": "E:\\recData\\"
  },
  "comment": "Storage path changed from D:\\recData\\ to E:\\recData\\."  // optional
}
```
```jsx
{
  "topic": "systemEvent",
  "id": 19138,
  "type": 0,
  "typeName": "System log",
  "code": 2,
  "codeName": "System shutdown",
  "timeRange": [
    "2018-12-26T15:29:20.013-05:00"
  ]
}
```


### Motion Detection Status Change Event `@0.8.0`
If you request `topics=motionChanges`, you can receive the event when changing the motion detection status for each channel in real time.
Immediately after the request, the current motion detection status of all specified channels is received
After this, the status of channels whose motion detection is changed in 1 second cycle is received in JSON format as below.
No events occur for channels with the same motion detection status.

```jsx
{
  "topic": "motionChanges",
  "updated": [
    {
      "chid": 1,
      "motion": true
    },
    {
      "chid": 2,
      "motion": false
    },
    {
      "chid": 5,
      "motion": true
    },
  ]
}
```


### Parking Count Event `@0.9.0`
If you ask for `topics=parkingCount`, you can receive events in real time when the number of cars in each parking lot is changed.
Immediately after the request, the current number of vehicles in all the specified parking lots will be received once.
The number of vehicles in the parking lot will be received in JSON format as shown below.

```jsx
{
  "timestamp" :"2019-02-18T23:11:12.119-05:00",
  "topic": "parkingCount",
  "updated": [
    {
      "id": 11,
      "name": "Total",
      "type": "group",
      "count": 3,
      "maxCount": 31,
      "member":[
        12,
        13
      ]
    },
    {
      "id": 12,
      "name": "B1 Parking Lot",
      "type": "counter",
      "count": 2,
      "maxCount": 21
    },
    {
      "id": 13,
      "name": "B2 Parking Lot",
      "type": "counter",
      "count":1,
      "maxCount":10
    }
  ]
}
```

### Recording Status Event `@0.9.5`
If you request `topics = recordingStatus`, you can receive real-time events for each channel's recording status.
Immediately after the request, the current status of all channels is received.
After this, whenever a change occurs, it is received in JSON format as shown below.

- all channels
```jsx
{
  "timestamp": "2020-03-25T10:01:53.841-05:00",
  "topic": "recordingStatus",
  "event": "currentStatus",
  "channel": [
    {
      "chid":1,
      "streaming":true,
      "recording":true
    },
    {
      "chid":2,
      "streaming":false,
      "recording":false
    },
    {
      "chid":3,
      "streaming":true,
      "recording":false
    },
  ]
}
```

- On status changed
```jsx
{
  "timestamp": "2020-03-25T10:08:30.003-05:00",
  "topic": "recordingStatus",
  "event": "statusChanged",
  "channel": [
    {
      "chid":3,
      "streaming":true,
      "recording":false,
      // The time of recording failure (this value is specified only in the failure state)
      "timestampRecordingFailure":"2020-03-25T10:07:09.646-05:00"
    },
  ]
}
```

### Object Detection Event `@0.9.11`
If you request `topics = object`, you can receive real-time events at the time when the object is detected by each camera.
The supported object types are as follows.
- face
- human
- vehicle

You can receive only the object you want by specifying the object type `objectType` as shown below.
If not specified, all supported object types are sent.
```ruby
# requests only face
GET /api/subscribeEvents?topics=object&objectType=face&auth=ZGVtbzohMTIzNHF3ZXI%3D

# requests only vehicle
GET /api/subscribeEvents?topics=object&objectType=vehicle&auth=ZGVtbzohMTIzNHF3ZXI%3D

# requests face and human
GET /api/subscribeEvents?topics=object&objectType=face,human&auth=ZGVtbzohMTIzNHF3ZXI%3D
```

#### `face` object
1. Example data
```jsx
{
  "timestamp":"2020-05-25T13:56:02.558-05:00",
  "chid": 1,              # channel id
  "objId": 132,           # object id (If the id is the same, it is divided into the same object)
  "parentId": 130,        # In the case of `face` objects, `human` can be the parent, Relationship of `face` (child) attached to `human` (parent) (exists only when two objects are detected simultaneously)
  "type": "face",         # object type
  "likelihood": 71.10,    # detection accuracy (%)
  "attributes": {         # object attributes (list only detected attributes)
    "gender": "female",   # gender
    "age": "adult",       # age devision
    "hat": true,          # hat (wearing) 
    "glasses": false,     # glasses (not wearing)
    "mask": false         # mask (not wearing)
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673854/7673854.4411971.1590382562558672.object._c1_t2_s552x400.jpg" # image address
}
```
2. `face` attributes
    | key         | type     | list                                 |
    |-------------|----------|--------------------------------------|
    | `gender`    | `string` | `female`, `male`                     |
    | `age`       | `string` | `young`, `adult`, `middle`, `senior` |
    | `hat`       | `boolean` | true, false                         |
    | `glasses`   | `boolean` | true, false                         |
    | `mask`      | `boolean` | true, false                         |

#### `human` object
1. Example data
```jsx
{
  "timestamp": "2020-05-25T13:56:18.461-05:00",
  "chid": 1,              # channel id
  "objId": 142,           # object id (If the id is the same, it is divided into the same object)
  "type": "human",        # object type
  "likelihood": 74.80,    # detection accuracy (%)
  "attributes": {         # object attributes (list only detected attributes)
    "gender": "female",   # gender
    "hat": true,          # hat (wearing) 
    "bag": true,          # bag (carring)
    "clothes": [          # clothes (multiple notation)
      {
        "type": "tops",   # tops
        "length": "long", # length of clothes
        "colors": [       # colors of clothes (multiple notation)
          "white"
        ]
      },
      {
        "type": "bottoms", # bottoms
        "length": "long",  # length of clothes
        "colors": [        # colors of clothes (multiple notations)
          "blue"
        ]
      }
    ]
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673854/7673854.4411974.1590382578461739.object._c1_t1_s376x600.jpg" # image address
}
```
2. `human` attributes
    | key         | type                | list                             |
    |-------------|---------------------|----------------------------------|
    | `gender`    | `string`            | `female`, `male`                 |
    | `hat`       | `boolean`           | true, false                      |
    | `bag`       | `boolean`           | true, false                      |
    | `clothes`   | `array` of `object` | *refer to `clothes` attributeds* |
3. `clothes` attributes
    | key         | type                | list                   | description          |
    |-------------|---------------------|------------------------|----------------------|
    | `type`      | `string`            | `tops`, `bottoms`      | tops or bottoms      |
    | `length`    | `string`            | `short`, `long`        | sleeve, pants length |
    | `colors`    | `array` of `string` | `brown`, `black`, `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `magenta`, `gray`, `pink`, `beige`, `white`, `other`  | colors of clothes |
    
    
  
#### `vehicle` object
```jsx
1. Example data
{
  "timestamp": "2020-05-25T14:23:58.768-05:00",
  "chid": 1,              # channel id
  "objId": 182,           # object id (If the id is the same, it is divided into the same object)
  "type": "vehicle",      # object type
  "likelihood": 99.60,    # detection accuracy (%)
  "attributes": {         # object attributes (list only detected attributes)
    "vehicleType": "car", # vehicle type
    "colors": [           # vehicle colors (multiple notation)
      "white"
    ]
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673880/7673880.4412174.1590384238768802.object._c1_t3_s944x520.jpg" # image address
}
```
2. `vehicle` attributes
    | key           | type         | list                            |
    |---------------|--------------|--------------------------------|
    | `vehicleType` | `string`     | `car`, `truck`, `bus`, `bicycle`, `motorcycle`, `train`  |
    | `colors`      | `array` of `string` | `brown`, `black`, `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `magenta`, `gray`, `pink`, `beige`, `white`, `other`  |

### Body Temperature Event `@0.9.14`
If you request `topics=bodyTemperature`, you can receive real-time events when high temperatures are detected by each thermal imaging camera for body temperature detection.

To receive body temperature detection events, make a request as follows:
```ruby
GET /api/subscribeEvents?topics=object&objectType=bodyTemperature&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
Example data
```jsx
{
  "timestamp": "2020-05-25T14:23:58.768-05:00",
  "chid": 1,              # channel id
  "objId": 182,           # object id (If the id is the same, it is divided into the same person)
  "type": "vehicle",      # object type
  "likelihood": 99.60,    # detection accuracy (%)
  "linkedChannel":[                             // Linked channels
    {
      "chid":1,
      "title":"Camera1",
      "displayName":"CH1. Camera1",             // Added since TS-API@0.9.4
      "src":"http://host/watch?ch=1",
      "streams": [  // vidio stream sources
                // (Multiple sources are organized into an array in one channel, depending on protocol and resolution)
        { // 1080p RTMP stream
          "src": "rtmp://host/live/ch1main",  // video address
          "type": "rtmp/mp4",     // MIME type: RTMP protocol (Adobe Flash format)
          "label": "1080p FHD",   // resolution name
          "size": [               // resolution
            1920,                 // the number of horizontal pixels
            1080                  // the number of verical pixels
          ]
        },
        { // 1080p HLS stream
          "src": "http://host/hls/ch1main/index.m3u8", // video address
          "type": "application/x-mpegurl",  // MIME type: HLS protocol (format)
          "label": "1080p FHD",   // resolution name
          "size": [               // resolution
            1920,                 // the number of horizontal pixels
            1080                  // the number of verical pixels
          ]
        },
        { // VGA RTMP stream
          "src": "rtmp://host/live/ch1sub",   // RTMP protocol (Adobe Flash format)
          "type": "rtmp/mp4",   // MIME type: RTMP protocol (Adobe Flash format)
          "label": "VGA",
          "size": [
            640,
            480
          ]
        },
        { // VGA HLS stream
          "src": "http://host/hls/ch1sub/index.m3u8", // video address
          "type": "application/x-mpegurl",  // MIME type: HLS protocol (HTML5 format)
          "label": "VGA",       // resolution name
          "size": [             // resolution
            640,                // the number of horizontal pixels
            480                 // the number of verical pixels
          ]
        }
      ]
    }
  ]
}
```


Now, let's create an example that uses the Web socket to receive event messages.
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>ex3</title>
  <style>
    body {font-family:Arial, Helvetica, sans-serif}
    div {padding:5px}
    #control {background-color:beige}
    #url, #messages {font-size:0.8em;font-family:'Courier New', Courier, monospace}
    li.open, li.close {color:blue}
    li.error {color:red}
  </style>
</head>
<body>
  <h2>Ex3. Receiving Events (Web Socket)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='Server IP address:port'>
      <input type='text' id='user-id' placeholder='User ID'> 
      <input type='password' id='password' placeholder='Password'>
    </div>
    <div>
      Topics:
      <input class='topic' type='checkbox' value="channelStatus" checked>channelStatus
      <input class='topic' type='checkbox' value="LPR" checked>LPR 
      <input class='topic' type='checkbox' value="emergencyCall" checked>emergencyCall
      <input class='topic' type='checkbox' value="systemEvent" checked>systemEvent
      <input class='topic' type='checkbox' value="motionChanges" checked>motionChanges
      <input class='topic' type='checkbox' value="parkingCount" checked>parkingCount
      <input class='topic' type='checkbox' value="packing" checked>packing
      <input class='topic' type='checkbox' value="recordingStatus" checked>recordingStatus
      <input class='topic' type='checkbox' value="object" checked>object
      <input id='verbose' type='checkbox' checked>Verbose
      <button type='button' onClick='onConnect()'>Connect</button>
      <button type='button' onClick='onDisconnect()'>Disconnect</button>
      <button type='button' onClick='onClearAll()'>Clear all</button>
    </div>
    <div id='url'>
    </div>
  </div>

  <div>
    <ul id='messages'></ul>
  </div>
</body>
<script type='text/javascript'>
  (function() {
    window.myApp = { ws: null };
  })();

  function getURL() {
    var url = '';

    if (typeof(WebSocket) === 'undefined') {
      alert('Your web browser does\'nt support Web Socket.');
      return url;
    }

    if(window.myApp.ws !== null) {
      alert('Already connected');
      return url;
    }
      
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert('Please enter the host.');
      return url;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert('Please enter your user ID.');
      return url;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert('Please enter your password.');
      return url;
    }

    var topics = '';
    var el = document.getElementsByClassName('topic');
    for(var i=0; i<el.length; i++) {
      if(!el[i].checked)
        continue;

      if(topics.length > 0)
        topics += ',';
       topics += el[i].value;
    }
  
    if(topics.length == 0) {
      alert('Please select at least one topic.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 encoding
    url = (hostName.includes('ws://', 0) ? '' : 'ws://') +
      hostName + '/api/subscribeEvents?topics=' + topics + 
      '&auth=' + encodedData;
    
      if(document.getElementById('verbose').checked)
      url += '&verbose=true';
      
    //url += '&ch=4';
    return url;
  }

  function addItem(tagClass, msg) {    
    var li = document.createElement('li');
    li.appendChild(document.createTextNode(msg));
    li.classList.add(tagClass); 
    document.getElementById('messages').appendChild(li);
  }

  function onConnect() {
    var url = getURL();
    if(url.length == 0)
      return;

    document.getElementById('url').innerText = url;

    // WebSocket instance and it's handler functions
    var ws = new WebSocket(url);
    ws.onopen = function() {
      addItem('open', 'Connected');
    };
    ws.onclose = function(e) {
      addItem('close', 'Disconnected: ' + e.code);
      onDisconnect();
    };
    ws.onerror = function(e) {
      addItem('error', 'Error: ' + e.code);
    };
    ws.onmessage = function(e) {
      addItem('data', e.data);
    };
    window.myApp.ws = ws;
  }

  function onDisconnect() {
    if(window.myApp.ws !== null) {
      window.myApp.ws.close();
      window.myApp.ws = null;
    }
  }
  
  function onClearAll() {
    var el = document.getElementById("messages");
    while (el.firstChild) {
      el.removeChild(el.firstChild);
    }
    document.getElementById('url').innerText = '';
  }
</script>
```
[Run](./examples/ex3.html)



## Exporting recorded video `@0.3.0`
You can use the web socket to receive recorded video from the server.
The server creates the files one by one and deletes them when the client finishes downloading, and then creates the next file.
All progress is made while the server and the client remain connected,
If the connection is lost, the server immediately stops the operation and deletes the generated file.

The step-by-step communication procedure is as follows.
>1. Client connects to server via Web socket
>2. `Server -> Client [stage:ready]` If authenticated successful, the server send ready stage which contains the summary of the task.
>4. `Server -> Client [stage:begin]` Start the requested operation from the server
>5. `Server -> Client [stage:channelBegin]` Start task on a channel
>6. `Server -> Client [stage:fileBegin]` Start creating a file
>7. `Server -> Client [stage:fileWriting]` Writing data to a file
>8. `Server -> Client [stage:fileEnd]` Completed a file (download link provided)
>9. `Server -> Client [stage:timeoutAlert]` Sent immediately before the time specified at `ttl` in` fileEnd` is exceeded
>10. `Client -> Server [cmd:wait]` Making server wait while the client is downloading
>11. `Client -> Server [cmd:next]` Making server create next file after the file has finished downloading
>12. `Server -> Client [stage:channelEnd]` Completed task on a channel
>13. `Server -> Client [stage:end]` 
>14. If there are next files, repeat steps 6 to 10
>15. If there are next channels, repeat steps 5 through 12
>16. `Client -> Server [cmd:cancel]` Clients can cancel jobs at any time after step 2


The web socket connection path and parameters are as follows.
```ruby
/wsapi/dataExport

# Required parameters
auth            # Authentication Information (Requires authentication per individual web socket, independent of session authentication)
timeBegin       # Start time of data range to export (ISO8601 format)
timeEnd         # End time of data range to export (ISO8601 format)

# Optional parameters
ch              # Used when specifying specific channels (separated by a comma (,) if multiple channels are specified at the same time)
                # If you do not specify a channel, it means all channels
subtitleFormat  # Specify the type of subtitle file to be used for the date time display of video
                # Supports VTT, SRT, and SMI formats. If not specified or set to None, subtitle files are not generated.
mediaSize   # Specify the maximum size of the video file (Can be expressed in units of GB, MB, KB, B, eg: 1GB, 700MB)
statusInterval  # Displays the interval of receiving the progress (stage:fileWriting) of the video file to be exported from the server
                # (Can be expressed in units of s, ms, eg: 1s, 500ms)
                # If statusInterval is not specified, no progress is sent
lang            # Specify the language to be used for backup progress status and subtitle file

# Parameters used for server-side logging for privacy (multiple lines of text can be used)
submitter       # Specify video submitter
recipient       # Specify video recipient
purpose         # Specify the purpose of the video to submit

# including md5
md5             # added at v0.9.2


# Examples
# July 27, 2018 to receive all recorded videos from 9:00 am to 9:30 am
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A

# Exporting video recorded on channel 1
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1

# Exporting video recorded on channel 1 with md5
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&md5=true

# Exporting video recorded on channel 1,2 and 3
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1,2,3

# Save the file as 500MB
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB

# Create VTT subtitle file
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT

# Receiving progress in 1 second interval
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s

# Specify language to Spanish
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s&lang=es-ES

# Specify Video submitter(Begger), recipient(Prince), purpose(cold\nand hungry)
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s&submitter=Begger&recipient=Prince&purpose=cold%0D%0Aand%20hungry
```

The message format sent by the server for each stage is as follows.
**stage:ready - Ready**
```jsx
{
  "stage": "ready",
  "status": {
    "code": 0,
    "message": "Success"
  },
  "task": {
    "id": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # task id-05
    "ch": [
      1,
      2,
      3
    ],
    "timeRange": [
      "2018-07-27T09:00:00.000-05:00",
      "2018-07-27T09:30:00.000-05:00"
    ],
    "mediaSize": 524288000,
    "subtitleFormat": "VTT",
    "language": "en-US",
  }
}
```

In some situations, it may fail and terminate immediately.
 The types of `status` code are as follows.
```ruby
0: Succcess
-1: No data in the requested time range and channels
-2: Invalid parameters
-5: Out of storage space (If there is no free space on the server)    
```

**stage:begin - Start task**
```jsx
{
  "stage": "begin",
  "overallProgress": "0%", # Overall progress
  "timestamp": "2018-07-27T09:00:00.000-05:00" # Current time stamp in progress
}
```

**stage:channelBegin - Start a channel**
```jsx
{
  "stage": "channelBegin",
  "overallProgress": "0%", # Overall progress
  "timestamp": "2018-07-27T09:00:00.000-05:00", # Current time stamp in progress
  "channel": {
    "chid": 1,         # Channel number
    "progress": "0%"   # Channel progress
  }
}
```

**stage:fileBegin - Start file creation**
```jsx
{
  "stage": "fileBegin",
  "overallProgress": "37%",  # Overall progress
  "timestamp": "2018-07-27T09:11:19.825-05:00", # Current time stamp in progress
  "channel": {
    "chid": 1,         # Channel number
    "progress": "37%", # Channel progress
    "file": {
      "fid": 1,        # File id
      "name": "CH1.2018-07-27T09.11.19.mp4"  # File name
    }
  }
}
```

**stage:fileWriting -File writing in progress**
```jsx
{
  "stage": "fileWriting",
  "overallProgress": "42%",  # Overall progress
  "timestamp": "2018-07-27T09:12:49.466-05:00", # Current time stamp in progress
  "channel": {
    "chid": 1,         # Channel number
    "progress": "42%", # Channel progress
    "file": {
      "fid": 1         # File id
    }
  }
}
```

**stage:fileEnd - File creation complete**
Once a file is created, the download link will be returned with the ttl as follows:
Within ttl, The client must send a command to the server to control the flow, otherwise the server automatically cancels the operation.
```jsx
{
  "stage": "fileEnd",
  "overallProgress": "51%",  # Overall progress
  "timestamp": "2018-07-27T09:15:25.225-05:00", # Current time stamp in progress
  "channel": {
    "chid": 1,          # Channel number
    "progress": "51%",  # Channel progress
    "file": {
      "fid": 1,         # File id
      "ttl": 10000,     # If the client does not send any commands within 10000 milliseconds (10 seconds), 
                        # the server will automatically cancel the operation
      "download": [
        # Created video file
        {
          "fileName": "CH1.2018-07-27T09.11.19.mp4",
          "src": "http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.mp4",
          "md5": "1125ee2c3d20f30b31166c821204603d" # md5=true
        },
        # Created subtitle file
        {
          "fileName": "CH1.2018-07-27T09.11.19.vtt",
          "src": "http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.vtt",
          "md5": "9176eec58f3be777ae7bd188a1f14165" # md5=true
        }
      ]
    }
  }
}
```

Download links can be used with the `auth` parameter.
```ruby
http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.mp4&auth=YWRtaW46YWRtaW4
```

**stage:timeoutAlert - timeout alert**
The server sends it to the client to notify the task will be canceled shortly before the time specified in the ttl specified in `fileEnd`.
```jsx
{
  "request": "timeoutAlert",
  "ttl": 2000         # 2 seconds remaining
}
```
When the client receives this message, it must send the `wait` command to the server within the time specified in` ttl`, otherwise the task will be automatically canceled.

**stage:channelEnd - Channel complete**
```jsx
{
  "stage": "channelEnd",
  "overallProgress": "100%", # Overall progress
  "timestamp": "2018-07-27T09:30:00.000-05:00", # Current time stamp in progress
  "channel": {
    "chid": 1,         # Channel number
    "progress": "100%" # Channel progress
  }
}
```

**stage:end - Task complete**
```jsx
{
  "stage": "end",
  "overallProgress": "100%", # Overall progress
  "timestamp": "2018-07-27T09:30:00.000-05:00", # Current time stamp in progress
  "status": {
    "code":0,
    "message":"Success"
  }
}
```
A typical `status` code is one of the following:
```ruby
0: Success
-1001: Not enough space to save
-1003: Task canceled by user
-1004: Task terminated by timeout
```

The format of the command that the client sends to the server for each situation is as follows:
**cmd:wait - wait command**
Video files created on the server side will be deleted immediately after downloading finished and before creating the next file, 
so you should send a wait command during download to prevent the server from deleting the file.

If you send the `wait` command once, you can make server wait for` ttl` specified in `fileEnd`,
If the download takes a long time, you should send the wait command periodically.
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # The task number issued at stage:ready
  "cmd": "wait"   # wait command
}
```

**cmd:next - Continue to next file**
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # The task number issued at stage:ready
  "cmd": "next"   # Proceed to the next file operation
}
```

**cmd:cancel - Cancel task**
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # The task number issued at stage:ready
  "cmd": "cancel"   # Client cancel the task
}
```

Now let's create an example that uses a web socket to export the recorded video.
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>ex4</title>
  <style>
    body {font-family:Arial, Helvetica, sans-serif}
    div {padding:3px}
    #control {background-color:beige;font-size:0.8em}
    #param {background-color:wheat;font-size:11px}
    #param * {font-size:10px}
    #url, #messages {font-size:0.8em;font-family:'Courier New', Courier, monospace}
    li.open, li.close {color:blue}
    li.command {color:orange}
    li.error {color:red}
  </style>
</head>
<body>
    <h2>Ex4. Exporting recorded video (Web Socket)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='Server IP address:port'>
      <input type='text' id='user-id' placeholder='User ID'> 
      <input type='password' id='password' placeholder='Password'>
    </div>
    <div id='param'>
      <div>
        Data range : <input type='datetime-local' id='timeBegin' step='1' value='2019-06-16T09:00:00'>
        ~ <input type='datetime-local' id='timeEnd' step='1' value='2019-06-16T16:30:00'>
      </div>
      <div>
        Channels: 
          <input type='checkbox' onclick='onSelectAllChannels(this)'>Select all
          <input type='checkbox' class='chid' value='1' checked>1
          <input type='checkbox' class='chid' value='2'>2
          <input type='checkbox' class='chid' value='3'>3
          <input type='checkbox' class='chid' value='4'>4    
          <input type='checkbox' class='chid' value='5'>5
          <input type='checkbox' class='chid' value='6'>6
          <input type='checkbox' class='chid' value='7'>7
          <input type='checkbox' class='chid' value='8'>8
          <input type='checkbox' class='chid' value='9'>9
          <input type='checkbox' class='chid' value='10'>10
          <input type='checkbox' class='chid' value='11'>11
          <input type='checkbox' class='chid' value='12'>12   
          <input type='checkbox' class='chid' value='13'>13
          <input type='checkbox' class='chid' value='14'>14
          <input type='checkbox' class='chid' value='15'>15
          <input type='checkbox' class='chid' value='16'>16
      </div>
      <div>
        File size unit: <input type='text' id='mediaSize' placeholder='ex) 500MB'>
      </div>
      <div>
        Subtitle format: <select id='subtitleFormat'>
          <option value='SRT' selected>SRT</option>
          <option value='SMI'>SMI</option>
          <option value='VTT'>VTT</option>
          <option value='None'>None</option>
        </select>
      </div>
      <div>
        Submitter: <input type='text' id='submitter' placeholder='ex) submitter'>
      </div>
      <div>
        Recipient: <input type='text' id='recipient' placeholder='ex) recipient'>
      </div>
      <div>
        Purpose: <textarea cols='40' rows='3' id='purpose' placeholder='ex) purpose...'></textarea>
      </div>
      <div>
        Status interval: <input type='text' id='statusInterval' placeholder='ex) 2s' value='2s'>
      </div>
      <div>
        Language: <select id='lang'>
          <option value='en-US'>English</option>
          <option value='ko-KR'>Korean</option>
          <option value='es-ES'>Spanish</option>
          <option value='zh-CN'>Chinese (Simplified)</option>
          <option value='zh-TW'>Chinese (Traditional)</option>
        </select>
      </div>
      <div>
        <input type='checkbox' id='md5' value='md5'>md5
      </div>
    </div>
    <div>
      <button type='button' onClick='onConnect()'>Connect</button>
      <button type='button' onClick='onDisconnect()'>Disconnect</button>
      <button type='button' onClick='onClearAll()'>Clear all</button>
      <button type='button' onClick='onCancel()' id='cancel' style='visibility:hidden;color:red'>Cancel task</button>
    </div>
    <div id='url'>
    </div>
  </div>
  <div>

    <ul id='messages'></ul>
  </div>
</body>
<script type='text/javascript'>
  (function() {
    window.myApp = { 
      ws: null,
      task: '',
      fname: '',
      auth: '',
      downloadJobs: []
    };
  })();

  function getURL() {
    var url = '';

    if (typeof(WebSocket) === 'undefined') {
      alert('Your web browser does\'nt support Web Socket.');
      return url;
    }

    if(window.myApp.ws !== null) {
      alert('Already connected');
      return url;
    }
    
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert('Please enter the host.');
      return url;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert('Please enter your user ID.');
      return url;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert('Please enter your password.');
      return url;
    }


    // parameters
    var timeBegin = document.getElementById('timeBegin').value;
    if(timeBegin == '') {
      alert('Please enter the data range.');
      return url;
    }

    var timeEnd = document.getElementById('timeEnd').value;
    if(timeEnd == '') {
      alert('Please enter the data range.');
      return url;
    }

    var ch = '';
    var chk = document.getElementsByClassName('chid');
    for (var i = 0; i < chk.length; i++) {
      if (chk[i].checked === true) {
        if(ch.length > 0)
          ch += ',';
        ch += chk[i].value;
      }
    }
    if(ch.length == 0) {
      alert('Select channels.');
      return url;
    }
 
    var mediaSize = document.getElementById('mediaSize').value;
    if(mediaSize == '') {
      alert('Please enter the maximum video file size.');
      return url;
    }

    var subtitleFormat = document.getElementById('subtitleFormat').value;
    if(subtitleFormat == '') {
      alert('Select subtitle format.');
      return url;
    }

    var submitter = document.getElementById('submitter').value;
    if(submitter == '') {
      alert('Please enter submitter.');
      return url;
    }

    var recipient = document.getElementById('recipient').value;
    if(submitter == '') {
      alert('Enter the recipient.');
      return url;
    }

    var purpose = document.getElementById('purpose').value;
    if(purpose == '') {
      alert('Enter your purpose.');
      return url;
    }

    var statusInterval = document.getElementById('statusInterval').value;
    if(statusInterval == '') {
      alert('Please enter the progress display interval.');
      return url;
    }

    var lang = document.getElementById('lang').value;
    if(lang == '') {
      alert('Choose your language.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 encoding
    window.myApp.auth = encodeURIComponent(encodedData);
    url = (hostName.includes('ws://', 0) ? '' : 'ws://') +
      hostName + '/wsapi/dataExport?auth=' + window.myApp.auth;

    url += 
      '&timeBegin=' + encodeURIComponent(timeBegin) +
      '&timeEnd=' + encodeURIComponent(timeEnd) +
      '&ch=' + encodeURIComponent(ch) +
      '&subtitleFormat=' + encodeURIComponent(subtitleFormat) +
      '&mediaSize=' + encodeURIComponent(mediaSize) +
      '&statusInterval=' + encodeURIComponent(statusInterval) +
      '&submitter=' + encodeURIComponent(submitter) +
      '&recipient=' + encodeURIComponent(recipient) +
      '&purpose=' + encodeURIComponent(purpose) +
      '&lang=' + encodeURIComponent(lang);
     
    var md5 = document.getElementById('md5');
    if (md5.checked === true) {
      url += '&md5=true';
    }
    return url;
  }

  function addItem(tagClass, msg) {    
    var li = document.createElement('li');
    li.appendChild(document.createTextNode(msg));
    li.classList.add(tagClass); 
    document.getElementById('messages').appendChild(li);
  }

  function addDownloadItem(fname) {
    var li = document.createElement('li');
    var span = document.createElement('span');
    span.innerHTML = '<progress value="0" max="100"></progress> <label>' + fname + '<label>';
    span.setAttribute('id', window.myApp.task + '/' + fname);
    li.appendChild(span);
    document.getElementById('messages').appendChild(li);
  }

  function showCancelButton(bShow) {
    var el = document.getElementById('param');
    el.style.display = bShow ? 'none' : 'block';

    el = document.getElementById('cancel');
    el.style.visibility = bShow ? 'visible' : 'hidden';
  }

  function onConnect() {
    var url = getURL();
    if(url.length == 0)
      return;

    document.getElementById('url').innerText = url;

    // WebSocket instance and it's handler functions
    var ws = new WebSocket(url);
    ws.onopen = function() {
      addItem('open', 'Connected');
    };
    ws.onclose = function(e) {
      addItem('close', 'Disconnected: ' + e.code);
      onDisconnect();
    };
    ws.onerror = function(e) {
      addItem('error', 'Error: ' + e.code);
    };
    ws.onmessage = function(e) {
      addItem('data', e.data);
      
      var msg = JSON.parse(e.data);
      switch(msg.stage) {
      case 'ready':
        if(msg.status.code != 0)
          break;
        window.myApp.task = msg.task.id;

        showCancelButton(true);
        break;

      case 'fileBegin':
        window.myApp.fname = msg.channel.file.name;
        break;

      case 'fileEnd':
        downloadFiles(msg.channel.file, function(bSuccess) {
          sendCommand(bSuccess ? "next" : "cancel");
        });
        break;

      case 'timeoutAlert':
        if( window.myApp.downloadJobs.length > 0)
          sendCommand("wait");
        break;

      case 'end':
        showCancelButton(false);
        break;
      }
    };
    window.myApp.ws = ws;
  }

  function onDisconnect() {
    if(window.myApp.ws !== null) {
      window.myApp.ws.close();
      window.myApp.ws = null;
    }
    document.getElementById('param').style.display = 'block';
  }

  function onClearAll() {
    var el = document.getElementById("messages");
    while (el.firstChild)
      el.removeChild(el.firstChild);
    document.getElementById('url').innerText = '';
    document.getElementById('param').style.display = 'block';
  }

  function downloadFiles(file, onFinished) {
    if(file.download.length <= 0) {
      onFinished(false);
      return;
    }

    var downloadCnt = 0, successCnt = 0;

    function onDone(bSuccess) {
      if(bSuccess)
        successCnt++;

      if(++downloadCnt < file.download.length) {
        setTimeout(function() {
          downloadFile(file.download[downloadCnt], onDone);
        }, 1000);
      }
      else {
        onFinished(successCnt == downloadCnt);
      }
    }
    downloadFile(file.download[downloadCnt], onDone);
  }

  function downloadFile(download, onFinish) {
    addDownloadItem(download.fileName);

    var req = new XMLHttpRequest();
    window.myApp.downloadJobs.push(req);

    // Requesting download link with auth parameter
    req.open('GET', download.src + '?auth=' + window.myApp.auth, true);
    req.responseType = "blob";
    req.onreadystatechange = function() {
      if (req.readyState === 4 && req.status === 200) {
        var a = document.createElement('a');
        a.href = window.URL.createObjectURL(req.response);
        a.download = download.fileName;
        a.style.display = 'none';
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(a.href);
      }
    },
    req.onprogress = function(e) {
      var prog = document.getElementById(window.myApp.task + '/' + download.fileName).firstChild;
      if(prog)
        prog.value = Math.ceil(e.loaded * 100 / e.total);
    },
    req.onerror = function(e) {
      if(onFinish)
        onFinish(false);

      var pos = window.myApp.downloadJobs.indexOf(req);
      if(pos >= 0)
        window.myApp.downloadJobs.splice(pos, 1);
    },
    req.onloadend = function (event) {
      var pos = window.myApp.downloadJobs.indexOf(req);
      if(pos >= 0)
        window.myApp.downloadJobs.splice(pos, 1);
      
      if(onFinish)
        onFinish(true);
    };
    req.send();
  }

  function sendCommand(command) {
    var str = JSON.stringify({
      task: window.myApp.task,
      cmd: command
    });

    addItem('command', str)
    window.myApp.ws.send(str);
  }

  function onCancel() {
    // abort all downloading jobs
    window.myApp.downloadJobs.forEach(function(jobs) {
      jobs.abort();
    });
    window.myApp.downloadJobs = [];

    sendCommand("cancel");
  }

  function onSelectAllChannels(el) {
    var ch = document.getElementsByClassName('chid');
    for(var i=0, cnt=ch.length; i<cnt; i++)
      ch[i].checked = el.checked;
  }
</script>

````
[Run](./examples/ex4.html)



## Pushing events to the server `@0.4.0`
You can send events from an external device or software to the server by `HTTP POST` method.

The following event topics are supported:
```ruby
LPR             # Car number recognition
emergencyCall   # Emergency call
```

The path and parameters for sending events to the server are:
```ruby
POST /api/push

# Parameter
auth    # authentication information
```

Specify event data in JSON format in contents data.

**Car number recognition data**
```jsx
{
  "topic": "LPR",         // Car number data
  "src": "F00001",        // Car number recognition device code
  "plateNo": "DSP963",    // the car number
  // Below are optional.
  "when": "2018-02-01T14:30:15-05:00",    // Vehicle number recognition time, if not specified, the server uses the time when the event was received
  "timeBegin": "2018-02-01T14:30:14-05:00"  // For car parked, specify the first recognition time
}
```

**Emergency call data**
```jsx
{
  "topic": "emergencyCall",   // Emergency call data
  "device": "vendor/device",  // Emergency call device model name
  "src": "0000001",           // Emergency call device location code
  "event": "callStart",       // call start (or "callEnd" for call end)
  "camera": "1,2,3,4",        // Camera list to popup screen (to restore "camera": "") (@0.9.19)
  "when": "2018-02-01T14:30:15-05:00" // Event occurrence time
}
```

If the request is successful, the server returns an HTTP response code of 200 and no additional Contents data is returned.

It can be created as multiple events in the array as shown below and sent at once.
```jsx
[
  {
    "topic": "LPR",
    "src": "F00001",
    "plateNo": "DSP963"
  },
  {
    "topic": "emergencyCall",
    "device": "vendor/device",
    "src": "0000001",
    "event": "callStart",
    "camera": "1,2,3,4",
    "when": "2018-02-01T14:30:15-05:00"
  }
]
```

You can test it by using the curl command in the console window.
>1. At first copy the above json data and save it as a `test.json` in a UTF-8 encoded text file.
>2. Let's assume the server address is `192.168.0.100`, the web port is `80`, the user ID is `demo`, and the password is`!1234qwer`.
>3. Open a console window, navigate to the directory where the `test.json` file is located, and run the curl command as shown below.
```bash
curl http://192.168.0.100/api/push -H "Content-Type: application/json; charset=UTF-8" -X POST -u demo:!1234qwer -d @test.json
```
>4. Alternatively, you can use the `auth =` parameter for Base64-encoded and URL-encoded user accounts.
```bash
curl http://192.168.0.100/api/push?auth=ZGVtbzohMTIzNHF3ZXI%3D -H "Content-Type: application/json; charset=UTF-8" -X POST -d @test.json
```


## Channel information and device control `@0.5.0`

You can get a list of devices connected to each channel, a list of features supported by each device, and control each device.


### Request Device Information and Support Function List
The connected device information requests:
```ruby
GET /api/channel/info

# Parameters
caps    # Only requested "caps" item, If not specified, includes all information
ch      # specify channels, If not specified, all channels in use
reload  # Request updated information with the latest information from your channel's camera (@0.9.1)

# Examples
# Only requests device capabilities for each channel in use
GET /api/channel/info?caps

# Only requests device capabilities connected to channels 1
GET /api/channel/info?caps&ch=1

# Only requests devices capabilities connected to channels 1, 2 and 3
GET /api/channel/info?caps&ch=1,2,3

# Request renewal of camera information of all channels to latest information
GET /api/channel/info?caps&reload
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,
    "type": "onvif"         // ONVIF device
    "caps": {               // Device capabilities
      "pantilt": true,      // Supports pan tilt function
      "zoom": true          // Supports zoom function
      "focus": false,       // Supports focus function
      "iris": false,        // Supports iris function
      "home": true,         // Supports home position function
      "maxPreset": 255,     // Up to 255 PTZ presets can be registered
      "aux": 0,             // No AUX output
      "digitalInputs": 2,   // Supports two digital inputs
      "relayOutputs": 2,    // Supports two relay outputs
      "reboot": true,       // Supports remote reboot
    },
    "onvif": {              // ONVIF device information
      "basic": {
        "city": "seoul",
        "country": "korea",
        "deviceType": "NVT",
        "host": "192.168.0.211:4500",
        "location": "",
        "name": "SNP-3120"
      },
      "product": {
        "firmwareVersion": "3.01_140915",
        "hardwareId": "SNP-3120",
        "macAddress": "00:09:18:73:E9:98",
        "manufacturer": "Samsung Techwin",
        "model": "SNP-3120",
        "serialNumber": "C5FS6V3D401101R"
      }
    },
  },
  // ... omitted
]
```

**Device control response code**

If each channel on the server supports device control, it can be remotely controlled from the client side.
The remote control functions will only work if the logged-in user account has `Device control permission`.

The device control commands are of the form `/api/channel/` followed by an individual command and a destination channel and additional required parameters.
In the example we will use here, let's assume that the destination channel is `ch = 1 '.
```ruby
GET /api/channel/ptz?ch=1&home&indent=2
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "code": 0,          // response code
  "message": "Success"
}
```

The server sends control commands and immediately resonse with JSON data, including one of the following codes, as an HTTP response code 200, asynchronously with the device, without waiting for the device's execution result.
```ruby
0     # Sucess
-1    # No user rights
-2    # Features not supported by the device
-3    # The device is not ready to execute the command
-4    # Device is still processing previous command (busy status)
-5    # Invalid channel
-6    # Invalid channel token
-7    # Invalid request
-8    # Invalid parameters
-9    # Device response error
```
The above response codes are common to all device control commands.


In the `message` part, if no language is specified, the language set on the server side is used.
You can specify the language for the parameter as shown below.
```ruby
GET /api/channel/ptz?ch=1&home&lang=en_US
```
For [a list of supported languages](#list-of-languages-supported), see the appendix.



### Pan tilt control

If your device supports the pan tilt function, you can control it with the following commands.
```ruby
# Commands without parameters
home    # Return to home position
stop    # Stop (Common to all move commands)

# Commands used with parameters (Commands to move continuously)
move    # Move horizontally and vertically
zoom    # Zoom in / out    
focus   # Focus near / far
iris    # Open / close iris
```

A control command consists of one target channel and a command.
For example, for the `home` command, you must specify the target channel as a parameter.
```ruby
GET /api/channel/ptz?ch=1&home
```

Commands used with parameters must specify the direction and velocity of movement.
Commands with direction and speed will continue to move until you issue a `stop` command.
The `move` command uses two parameters to represent the direction of movement in the horizontal and vertical directions.
The velocity of movement is expressed as a decimal value between `0` and `1`.
Two decimal values between `-1` and `1` can be used to express both the direction and velocity of movement from the current position in 2D space.

![Alt Direction and velocity of movement](../img/ptz.png)

```ruby
GET /api/channel/ptz?ch=1&move=0.5,0.5  # Moves at medium speed in the upper right diagonal
GET /api/channel/ptz?ch=1&move=-1       # Moves to the left at maximum speed (can be omitted if vertical value is zero)
GET /api/channel/ptz?ch=1&move=0,0.1    # Move slowly downward
GET /api/channel/ptz?ch=1&move          # Can be omitted if both horizontal and vertical are 0, same as stop command
```

The rest of the `zoom`,` focus`, and `iris` commands are all camera lens controls and use one parameter to express forward and backward.
Likewise, you can express both the direction and velocity of movement from the current position in a one-dimensional space, using one decimal value between `-1` and` 1` to express both the speed and direction of movement.
```ruby
GET /api/channel/ptz?ch=1&zoom=0.5      # Zoom in at medium speed
GET /api/channel/ptz?ch=1&zoom=-0.5     # Zoom out at medium speed
GET /api/channel/ptz?ch=1&focus=0.1     # Focus near at very slow speed
GET /api/channel/ptz?ch=1&focus=-0.5    # Focus far at medium speed
GET /api/channel/ptz?ch=1&iris=-0.1    # Close iris at very slow speed
GET /api/channel/ptz?ch=1&iris=1       # Open iris at maximum speed
```

The physical travel limit and speed for the move command can vary depending on the unique characteristics of each device.



### Pan tilt preset control

Available when the device supports the pan tilt preset function.

**Request a preset list**
This command requests a list of presets that the server has already obtained (cached).
```ruby
# Request a list of presets from channel 1
GET /api/channel/preset?ch=1&list

# Request a list of presets from multiple channels
GET /api/channel/preset?ch=1,2,3&list

# Request a preset list of all channels
GET /api/channel/preset?list
```
While the response time is fast because you do not reload from the device each time, if the preset list modified by the other software (for example, the embedded web page of the device), the server responds with the list of past.

If the request is successful, the server responds with JSON data in the following format:
```jsx
[
  {
    "chid": 1,
    "code": 0,
    "message": "Success",
    "preset": [
      {
        "name": "Front Door",  // The name that the user places conveniently for each preset position
        "token": "1"           // Unique ID indicating each preset position
      },
      {
        "name": "Garage",
        "token": "2"
      },
      // ... omitted
    ]
  },
  // ... omitted
]
```

**Preset list reload request**
This command reloads the preset list from the device and sends it back.
```ruby
# Request to reload the preset list of channel 1
GET /api/channel/preset?ch=1&reload

#  Request to reload the preset list of multiple channels
GET /api/channel/preset?ch=1,2,3&reload

#  Request to reload the preset list of all channels
GET /api/channel/preset?reload
```
Contrary to the `list` command, while the response time is slow, you can always receive the same data as the preset list that the device has.


**Adding a preset**
Adds the current position of the camera as a preset.

Adding a preset generates a preset token from the camera.
You can specify `name` as an option. Since the camera does not support various characters, it is recommended to use English letters and numbers whenever possible.
If `name` is not specified, it will be saved with the same name as the preset token generated by the camera.

The maximum number of presets supported by the camera can be found at [Request Device Information and Support Function List](#request-device-information-and-support-function-list).

```ruby
# adding a new preset
GET /api/channel/preset?ch=1&add&name=door

# adding a new preset (If name is omitted)
GET /api/channel/preset?ch=1&add
```

**Setting preset**
Sets the camera's current position as a preset.

Two parameters are required to set a preset.
The first parameter is the `preset token` and the second parameter is the `preset name`.
If you do not specify a preset name, the name of the preset token will be used.
If the presets of the same `Preset Token` already exist, it will be overwritten, otherwise added as a new one.

The maximum number of presets supported by the camera can be found at [Request Device Information and Support Function List](#request-device-information-and-support-function-list).

Since the camera does not support various character sets, it is recommended to use numeric charactors for the `preset token`.
However, since the preset name is stored in the server instead of the camera, you can use the `preset name` without any character restrictions.
Don't forget to URL-encode to send the text string normally.

```ruby
# When changing the existing preset position
GET /api/channel/preset?ch=1&set=preset1 

# When changing the position and name of an existing preset
GET /api/channel/preset?ch=1&set=preset1&name=Sweet%20home%20%5E%5E
```

For a preset assignment request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "chid": 1,
  "deviceResponseCode": 200, // Camera's response code
  "code": 0,                 // Response code
  "message": "Success",      // Message
  "token": "preset3",        // Preset token generated by the camera
  "name": "Sweet home ^^"
}
```

**Remove presets**
Removes the preset of the specified preset tokens.

To remove presets, you must specify the `preset token` as a parameter.
```ruby
# Remove presets token 1
GET /api/channel/preset?ch=1&rm=1

# Remove multiple presets
GET /api/channel/preset?ch=1&rm=1,2,3
```

For a preset removing request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "chid": 1,
  "preset":[
    {
      "deviceResponseCode": 200,  // Camera's response code
      "code": 0,                  // Response code
      "message": "Success",       // Message
      "token": "preset1"          // Removed preset token
    },
    // ... omitted
  ]
}
```

**Go to preset position**
Goes to the preset position of the specified preset token.

To move to the preset position, `preset token` must be specified as a parameter.
```ruby
GET /api/channel/preset?ch=1&go=1 # Goes to the preset token 1
```


### Relay output

If your device supports relay output, you can request a list of relay outputs as follows:
To get a list of relay outputs, you must specify one channel to which the device is connected.
```ruby
GET /api/channel/relay?ls&ch=1    # Request relay output list connected to channel 1
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "chid": 1,
  "code": 0,          // Response code
  "message": "Success",  // Message
  "relay": [
    {
      "name": "Stairway",   // name
      "token": "7657b9aa-61d6-4b4f-a70a-c91e8657dfcf" // relay output token
    },
    {
      "name": "Warehouse",
      "token": "cffd1289-cb2c-4d82-8c6f-c7634b432f57"
    }
  ]
}
```

Relay output command is specified using the `on` or` off` command and one or more relay output tokens.
```ruby
# Turn on the relay output of 7657b9aa-61d6-4b4f-a70a-c91e8657dfcf
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf

# Turn off the relay output of 7657b9aa-61d6-4b4f-a70a-c91e8657dfcf
GET /api/channel/relay?ch=1&off=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf

# Simultaneously turn on two relay outputs
GET /api/channel/relay?ch=1&off=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf,cffd1289-cb2c-4d82-8c6f-c7634b432f57

# If both on and off are specified at the same time, the off command is ignored.
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf&off=cffd1289-cb2c-4d82-8c6f-c7634b432f57

# If one is turned on and the other is turned off, each must be sent separately for each command.
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf
GET /api/channel/relay?ch=1&off=cffd1289-cb2c-4d82-8c6f-c7634b432f57
```


### AUX output

If your device supports AUX output, use the `on` or` off` command as `relay output`.
The AUX outputs are specified using a zero-based number instead of a token.

```ruby
# Turn on AUX 1 output
GET /api/channel/aux?ch=1&on=0

# Turn off AUX 1 output
GET /api/channel/aux?ch=1&off=1

# Simultaneously turn on two AUX outputs
GET /api/channel/aux?ch=1&on=0,1

# If both on and off are specified at the same time, the off command is ignored.
GET /api/channel/aux?ch=1&on=0&off=1

# If one is turned on and the other is turned off, each must be sent separately for each command.
GET /api/channel/aux?ch=1&on=0
GET /api/channel/aux?ch=1&off=1
```


### Reboot the device

If your device supports it, you can reboot it remotely with the following command:

```ruby
GET /api/channel/reboot?ch=1    # Reboot camera on channel 1
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "code": 0,
  "message": "Success"
}
```
After sending the response, the camera will start rebooting in a few seconds.
Typically, the reboot takes approximately one minute to complete, which may vary from each camera.

From the perspective of the client software, it is necessary to monitor the completion of the reboot by attempting to reconnect periodically from the video connection is disconnected after sending the reboot command.




## Adding channels `@0.9.7`

You can add channels as shown below.
```ruby
POST /api/channel

# Available parameters
auth  # If you are not already logged in, log in when calling the API
lang  # Specify the language to be used for error code messages

# Usage example
POST /api/channel?auth=ZGVtbzohMTIzNHF3ZXI%3D
POST /api/channel?lang=vi-VN   # Set in Vietnamese
```

### Request data

Defines channels to be added in POST data as `JSON` format.
Array format is used to specify multiple channels.

Some data items are defined differently depending on the type of video source.

#### Camera
Cameras that support the `ONVIF` protocol can be added.
If not specified, default values ​​are used.
```jsx
[
  {
    "chid": 1,                                        # [Optional] 1) Channel number to register 
    "name": "My video stream",                        # [Optional] Channel name to register
    "source": "rtsp://192.168.0.220:554/stream1",     # [Required] RTSP URL
    "tcp": true,                                      # [Optional] RTP protocol, true: TCP (default), false: UDP
    "substream": false,                               # [Optional] 2) Whether to use Substream, true: Use Substream (default), false: Not use Substream
    "uid": "admin",                                   # [Optional] RTSP auth id
    "password": "admin",                              # [Optional] RTSP auth password
    "device": {                                       # [Required] Register as an ONVIF camera (ONVIF function available)
      "name": "My camera",                            # [Optional] Camera name to register
      "url": "onvif://192.168.0.220:8000"             # [Required] 3) Camera device URL
    }
  }
]
```
1. `chid`:
   - Channel number starting from 1
   - If `chid` is not specified, it is automatically assigned from the front.
2. `substream`: 
   - When there is a lower resolution stream than the video stream registered from the same input source of the camera, if the display area on the split screen is small, it automatically operates to display the lower resolution stream.
   - If you want to use only the designated video stream without using this function, set the `substream` item to `false`.
3. `url` (Camera device URL):
   - It is originally in the form of `http://192.168.0.220:8000`, but it is written as `onvif://192.168.0.220:8000` to indicate that it is a `ONVIF` device.


#### Video stream
You can add a video stream using the `RTSP` protocol.
The camera can also be used when you are not using any function other than a video stream.

```jsx
[
  {
    "chid": 2,                                        # [Optional] Channel number to register, Automatically assigned if not specified
    "name": "My video stream",                        # [Optional] Channel name to register
    "source": "rtsp://192.168.0.220:554/stream1",     # [Required] RTSP URL
    "tcp": true,                                      # [Optional] RTP protocol, true: TCP (default), false: UDP
    "uid": "admin",                                   # [Optional] RTSP auth id
    "password": "admin",                              # [Optional] RTSP auth password
  }
]
```

#### Video file
You can add video files from a local PC or Windows shared folder.

```jsx
[
  {
    "chid": 1,                                         # [Optional] Channel number to register, Automatically assigned if not specified
    "name": "Video file in my PC",                          # [Optional] Channel name to register
    "source": "C:\\videos\\sample.mp4",                # [Required] 1) Video file name (full path)
    "playback": "once"                                 # [Optional] once: Play once, repeat: Repeat play (default)
  },
  {
    "chid": 2,                                         # [Optional] Channel number to register, Automatically assigned if not specified
    "name": "Video file in my freind PC",                   # [Optional] Channel name to register
    "source": "\\\\192.168.0.14\\videos\\sample.mp4",  # [Required] 1) Video file name (full path)
  }
]
```
1. `videoSrc` (Video file name): 
   - If only one `\` character is used, it is interpreted as `ESCAPE` character, so `\\` is used to indicate the file path.


### Response

- Request data example
```jsx
[
  {
    "name": "My video stream",
    "source": "rtsp://192.168.0.162:554/stream1",
    "uid": "admin",
    "password": "admin",
    "tcp": true
  },
  {
    "name": "My camera",
    "source": "rtsp://192.168.0.30:554/stream1",
    "tcp": true,
    "substream": false,
    "uid": "admin",
    "password": "admin",
    "device": {
      "name": "My camera",
      "url": "onvif://192.168.0.30:80"
    }
  },
  {
    "name": "Video file in my PC",
    "source": "C:\\video\\myVideo.mp4",
    "playback": "once"
  }
]
```

#### Response data

When requested as in the example above, the server responds with JSON data with an HTTP response code as follows:
```jsx
{
  "status": {
    "code": 0,  # Error code
    "message": "Channels were added successfully."  # Error message
  },
  "added": [
    {
      "chid": 1,                  # Assigned channel number
      "name": "My video stream",
      "type": "rtsp",             # Channel type (RTSP stream)
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
      "tcp": true,
      "sharedFrameBuffer": {      # Frame buffer interface when using the shared frame buffer API function
        "data": "sfb_data_ch1",   # Shared memory name of frame buffer
        "event": "sfb_event_ch1"  # Frame buffer update event name
      }
    },
    {
      "chid": 2,                  # Assigned channel number
      "name": "My cmamea",
      "type": "onvif",            # Channel type (ONVIF camera)
      "device": "onvif://192.168.0.30:80",  # Device URL
      "source": "rtsp://192.168.0.30:554/stream1",
      "tcp": true,                # RTP protocol, true: use TCP, false: UDP
      "substream": false,         # Whether to use substream for ONVIF cameras
      "sharedFrameBuffer": {
        "data": "sfb_data_ch2",
        "event": "sfb_event_ch2"
      }
    },
    {
      "chid": 3,                  # Assigned channel number
      "name": "My video file",
      "type": "file",             # Channel type (file)
      "source": "C:\\video\\myVideo.mp4",
      "playback": "once",         # once: Play once, repeat: Repeat play
      "sharedFrameBuffer": {
        "data": "sfb_data_ch3",
        "event": "sfb_event_ch3"
      }
    }
  ]
}
```

If an error occurs, the response data is shown in the example below.
- If the entire requested channel cannot be added
  
```jsx
{
  "status": {
    "code": -6,               # Error code
    "message": "Channels cannot be added."  # Error message
  },
  "failed": [                 # List of failed channels
    {
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
    },
    {
      "source": "C:\\video\\myVideo.mp4",
    }
  ]
}
```

- If some of the requested channels could not be added

```jsx
{
  "status": {
    "code": -5,               # Error code
    "message": "Only some channels have been added."  # Error message
  },
  "added": [                  # List of failed channels
    {
      "chid": 2,              # Assigned channel number
      "name": "My camera",
      "type": "onvif",        # Channel type (ONVIF camera)
      "device": "onvif://192.168.0.30:80",  # Device URL
      "source": "rtsp://192.168.0.30:554/stream1",
      "tcp": true,            # RTP protocol, true: use TCP, false: UDP
      "substream": false,     # Whether to use substream for ONVIF cameras
      "sharedFrameBuffer": {
        "data": "sfb_data_ch2",
        "event": "sfb_event_ch2"
      }
    }
  ],
  "failed": [                 # List of failed channels
    {
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
    },
    {
      "source": "C:\\video\\myVideo.mp4",
    }
  ]
}
```

- Error code
The `code` entry in `status` returns one of the following error codes.

    | Code | Description                                                          |
    |------|----------------------------------------------------------------------|
    | `0`  | Success                                                              |
    | `-1` | When the specified channel number is already in use                  |
    | `-2` | If the required item `source` is missing                             |
    | `-3` | If there is a `device` item, the required item `url` is missing      |
    | `-4` | If the request exceeds the maximum number of channels in the license |
    | `-5` | Some channels could not be added                                     |
    | `-6` | If the entire requested channel cannot be added                      |


## Deleting channels `@0.9.7`


You can delete a channel as shown below.
Specifies the channel to delete with only parameters, without using request data.
```ruby
DELETE /api/channel/{id}

# In the {id} section, specify the channel numbers to be deleted.
# Multiple channels can be specified using the comma (,) character.
# Or 'all' can be used to specify the entire channel.
DELETE /api/channel/1          # Delete channel 1
DELETE /api/channel/1,2,3      # Delete channels 1,2,3
DELETE /api/channel/all        # Delete all channels


# Available parameters
auth  # If you are not already logged in, log in when calling the API
lang  # Specify the language to be used for error code messages

# Usage example
DELETE /api/channel/1,2,3?auth=ZGVtbzohMTIzNHF3ZXI%3D
DELETE /api/channel/all?lang=vi-VN   # Set in Vietnamese
```

#### Rsponse data

For channel delete requests, the server responds with JSON data with an HTTP response code as follows:

```jsx
{
  "status": {
    "code": 0,          # Error code
    "message": "Channels were deleted successfully."  # Error message
  },
  "deleted": [          # List of deleted channels
    1,
    2,
    3
  ]
}
```

If an error occurs, the response data is shown in the example below.
- If the entire requested channel cannot be deleted
  
```jsx
{
  "status": {
    "code": -6,         # Error code
    "message": "Channels cannot be deleted."  # Error message
  },
  "failed": [           # List of failed channels
    1,
    2,    
    3
  ]
}
```

- If some of the requested channels could not be deleted
```jsx
{
  "status": {
    "code": -5,         # Error code
    "message": "Only some channels have been deleted."  # Error message
  },
  "deleted": [          # List of deleted channels
    1
  ],
  "failed": [           # List of failed channels
    2,
    3
  ]
}
```

- Error code
The `code` entry in `status` returns one of the following error codes.

    | Code  | Description                                            |
    |-------|--------------------------------------------------------|
    | `0`   | Succcess                                               |
    | `-7`  | When the channel number to be deleted is not specified |
    | `-8`  | If the specified channel does not exist                |
    | `-9`  | If some channels cannot be deleted                     |
    | `-10` | If all requested channels cannot be deleted            |


## Event Backup `@0.9.17`

By generating an event trigger with an API call on the client side, a copy of the normal recorded video can be saved in the dedicated storage for event backup.
In the server, event backup starts automatically after normal recording progresses up to the post-event recording (`postAlarm`) section. 
`preAlarm`, `postAlarm` are up to 1 hour each.

#### Request
```ruby
PUT /api/event-videos/trigger
```

- Request body
Event backup details can be specified with parameters.
```jsx
{
  "chid": 1,                              // channel number
  "timestamp": "2022-11-29T10:13:09.646"  // (Optional) If not specified, server reception time is applied
  "title": "fire outbreak",               // title (Appears in search results)
  "comment": {                            // comment (content is free form)
    "location": "Building 101, 5th floor",
    "tel": "119",                 
  },
  "tasks": [
    {
      "command": "presetGo",                // (Optional) Move PTZ preset
      "token": "preset1"                    // preset token
    },
    {
      "command": "eventBackup",             // (Optional) Event video backup (Video backup is performed only when this item is specified)
      "preAlarm": "5s",                     // The recorded section before the event occurs, counted in seconds when the number is indicated (e.g., 60 means 60 seconds)
      "postAlarm" "1m",                     // Recording section after the event occurred
      "chids": [1, 2, 3, 4]                 // (Optional) Channel number to back up (included by default even if you do not specify yourself)
    }
  ]
}
```

#### Response data

For the request, the server responds with the URL of the video to be saved as JSON data along with the HTTP response code as follows.

```jsx
{
  "eventId": 1234,  // stored event id
  "videoURLs": [    // Video url to be created
    "/event-storage/e/20221129/101309/ch1-20221129-101309.mp4",
    "/event-storage/e/20221129/101309/ch2-20221129-101309.mp4",
    "/event-storage/e/20221129/101309/ch3-20221129-101309.mp4",
    "/event-storage/e/20221129/101309/ch4-20221129-101309.mp4"
  ]
}
```

If the same file already exists in the same directory, it is numbered as shown below to prevent duplication.
```jsx
{
  "eventId": 1234,  // stored event id
  "videoURLs": [    // Video url to be created
    "/event-storage/e/20221129/101309/ch1-20221129-101309(2).mp4",
    "/event-storage/e/20221129/101309/ch2-20221129-101309(2).mp4",
    "/event-storage/e/20221129/101309/ch3-20221129-101309(2).mp4",
    "/event-storage/e/20221129/101309/ch4-20221129-101309(2).mp4"
  ]
}
```

Since the response is sent first, the event backup starts at the time scheduled with `postAlarm`, so
The client cannot immediately access the response URL, but can access the video file after the backup is completed (approximately 2 minutes after `postAlarm`).

The file name included in the `videoURL` of the response data is created based on the local time on the server side and has the following format.

```ruby
ch1-20221129-101309.mp4
-+- ----+--- ---+--
 |      |       | 
 |      |       +------------ HHmmss (Hour, minute, second 2 digits each)
 |      +-------------------- YYYYMMDD (4 digits for year, 2 digits each for month and day)
 +--------------------------- channel number (variable length after ch)
```

## Appendix

### base64 Encoding
For more information on base64 encoding, see the links below.
* https://www.base64encode.org/
* https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
* https://www.w3schools.com/jsref/met_win_btoa.asp



### URL Encoding
For more information on URL encoding, see the links below.
* http://www.convertstring.com/ko/EncodeDecode/UrlEncode
* https://www.urlencoder.org/
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
* https://www.w3schools.com/jsref/jsref_encodeuricomponent.asp



### URL decoding
For more information on URL decoding, see the links below.
* http://www.convertstring.com/ko/EncodeDecode/UrlDecode
* https://www.urldecoder.org/
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent
* https://www.w3schools.com/jsref/jsref_decodeuricomponent.asp



### Date and time notation in ISO 8601 format

```
YYYY-MM-DDThh:mm:ss.sss±Hh:Mm (Local time representation)
or
YYYY-MM-DDThh:mm:ss.sssZ (UTC time representation)
or, yet another
YYYY-MM-DDThh:mm:ss.sss (The server's Local time)

In here,
  YYYY: year
  MM: month
  DD: day
  hh: hour (24 hour notation)
  mm: minute
  ss: second
  sss: 1/n second
  Hh: Hour part of UTC time offset
  Mm: Minutes part of UTC time offset
```

For example, In the case of `February 1, 2018 at 2:30:15`
>1. The year, month, and day of the date part are each represented by four digits, two digits, or two digits, and the hyphen character (`-`) is used as a delimiter. If any digits remain, '0' is prefilled.
`eg: 2018-02-01`
>2. The hour, minute, and second of the time portion are each represented by two numbers, two characters, and two characters, is used as a delimiter. If any digits remain, '0' is prefilled.
`eg: 14:30:15`
Since video is typically composed of images from multiple scenes for one second, you might use units of seconds or less to specify the correct scene. In this case, you can use decimal notation for values less than a second.
`eg: 14:30:15.253 => 14:30:15 and 253 milliseconds (1/1000 second)`
>3. Use the `T` character as a separator between dates and times.
`eg: 2018-02-01T14:30:15.253`
>4. Use the time zone to specify the local time.
Because EST is 5 hours behind UTC, it is represented as follows.
`eg: -05:00 (or simply -0500 or more simply -05)`
If you want to use UTC time, you can use `Z` character instead of `+00:00`.
>5. Combine all of the above pieces.
`eg: 2018-02-01T14:30:15-05:00  (Local time as EST)`
>6. URL encoding this string is as follows:
`eg: 2018-02-01T14%3A30%3A15-05%3A00`




### List of languages supported
The server supports a total of 104 languages as follows:
```ruby
af-ZA       # Afrikaans
sq-AL       # Shqip, Albanian
am-ET       # አማርኛ, Amharic
ar-AE       # العربية, Arabic
hy-AM       # Հայերեն, Armenian
az-Latn     # Azərbaycan, Azerbaijani
eu-ES       # Euskara, Basque
be-BY       # беларускі, Belarusian
bn-BD       # বাংলা, Bengali
bs-Latn     # Bosanski, Bosnian
bg-BG       # български, Bulgarian
ca-ES       # Català, Catalan
ceb         # Cebuano
ny          # Chichewa
zh-CN       # 简体中国, Chinese (Simplified)
zh-TW       # 中國傳統, Chinese (Traditional)
co-FR       # Corsu, Corsican
hr-HR       # Hrvatski, Croatian
cs-CZ       # Čeština, Czech
da-DK       # Dansk, Danish
nl-NL       # Nederlands, Dutch
en-US       # English
eo          # Esperanto
et-EE       # Eesti keel, Estonian
fil-PH      # Filipino
fi-FI       # Suomalainen, Finnish
fr-FR       # Français, French
fy-NL       # Frysk, Frisian
gl-ES       # Galego, Galician
ka-GE       # ქართული, Georgian
de-DE       # Deutsch, German
el-GR       # Ελληνικά, Greek
gu-IN       # ગુજરાતી, Gujarati
ht          # Kreyòl ayisyen, Haitian Creole
ha          # Hausa
haw-U       # ʻŌlelo Hawaiʻi, Hawaiian,
he-IL       # עברית, Hebrew
hi-IN       # हिन्दी, Hindi
hmn         # Hmong
hu-HU       # Magyar, Hungarian
is-IS       # Íslensku, Icelandic
ig-NG       # Igbo
id-ID       # Bahasa Indonesia, Indonesian
ga-IE       # Gaeilge, Irish
it-IT       # Italiano, Italian
ja-JP       # 日本語, Japanese
jv-Latn     # Jawa, Javanese
kn-IN       # ಕನ್ನಡ, Kannada
kk-KZ       # Қазақ тілінде, Kazakh
km-KH       # ភាសាខ្មែរ, Khmer
ko-KR       # Korean
ku-Arab-IR  # Kurdî, Kurdish (Kurmanji)
ru-KG       # Кыргызча, Kyrgyz
lo-LA       # ລາວ, Lao
sr-Latn     # Latine, Latin
lv-LV       # Latviešu, Latvian
lt-LT       # Lietuviškai, Lithuanian
lb-LU       # Lëtzebuergesch, Luxembourgish
mk-MK       # Македонски, Macedonian
mg-MG       # Malagasy
ms-MY       # Melayu, Malay
ml-IN       # മലയാളം, Malayalam
mt-MT       # Malti, Maltese
mi-NZ       # Maori
mr-IN       # मराठी, Marathi
mn-MN       # Монгол хэл дээр, Mongolian
my-MM       # မြန်မာ", Myanmar (Burmese)
ne-NP       # नेपाली, Nepali
nb-NO       # Norwegian
ps-AF       # پښتو, Pashto
fa-IR       # فارسی, Persian
pl-PL       # Polskie, Polish
pt-PT       # Português, Portuguese
pa-IN       # ਪੰਜਾਬੀ, Punjabi
ro-RO       # Română, Romanian
ru-RU       # Русский, Russian
sm          # Samoan
gd-GB       # Gàidhlig, Scots Gaelic
sr-Cyrl-RS  # Српски, Serbian
nso-ZA      # Sesotho
sn-Latn-ZW  # Shona
sd-Arab-PK  # سنڌي, Sindhi
si-LK       # සිංහල, Sinhala
sk-SK       # Slovenský, Slovak
sl-SI       # Slovenščina, Slovenian
so-SO       # Soomaali, Somali
es-ES       # Español, Spanish
su          # Basa Sunda, Sundanese
swc-CD      # Kiswahili, Swahili
sv-SE       # Svenska, Swedish
tg-Cyrl-TJ  # Тоҷикистон, Tajik
ta-IN       # தமிழ், Tamil
te-IN       # తెలుగు, Telugu
th-TH       # ไทย, Thai
tr-TR       # Türkçe, Turkish
uk-UA       # Українська, Ukrainian
ur-PK       # اردو, Urdu
uz-Latn-UZ  # O'zbek, Uzbek
vi-VN       # Tiếng Việt, Vietnamese
cy-GB       # Cymraeg, Welsh
xh-ZA       # isiXhosa, Xhosa
yi          # ייִדיש, Yiddish
yo-NG       # Yorùbá, Yoruba
zu-ZA       # isiZulu, Zulu
```


### JSON data format
The server does not use line breaks or white space characters in JSON data for data optimization. For example, use the following form of text:
```json
{"apiVersion":"TS-API@0.2.0","siteName":"My%20home%20server","timezone":{"name":"America/New_York","bias":"-05:00"},"product":{"name":"TS-LPR","version":"v0.5.0A (64-bit)"},"license":{"type":"genuine","maxChannels":16}}
```
This is a long line, so it can be a little uncomfortable for the human to read.

In this case, use the following tools to convert easily readable.
* http://www.csvjson.com/json_beautifier
* https://codebeautify.org/jsonviewer
* https://jsonformatter.curiousconcept.com/
* https://jsonformatter.org/

The readable JSON data has the following form:
```json
{
  "apiVersion": "TS-API@0.2.0",
  "siteName": "My%20home%20server",
  "timezone": {
    "name": "America/New_York",
    "bias": "-05:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.5.0A (64-bit)"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 64
  }
}
```
Of course, both are completely the same data in terms of content.



### Feedback
We are always listening to your feedback.
If you have any development questions or want to improve, please leave them at https://github.com/bobhyun/TS-API/issues.