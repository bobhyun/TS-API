TS-API Programmer's Guide
======

TS-API@0.3.0
-----

This article is a programming guide for those who develop application software using **TS-API**, which is built in **TS-CMS**, **TS-NVR**, **TS-LPR** of TS Solution Co.,Ltd.

You can easily embed the real-time video, recorded video, and video search functions into your application software with the API. 

It would be helpful if you have some experience using simple `HTML` and `JavaScript` to use the API.

Please refer to [The API-supported versions by product](#the-api-supported-versions-by-product) and 
[The features table by product](#the-features-table-by-product) portion of [Appendix](#appendix), as the features supported by each product may differ.
 
> [Tips]
The API and this article are subject to change without notice for better development support and improvement.

Table of contents
-----
<!-- TOC -->

- [Get Started](#get-started)
- [Video display](#video-display)
  - [Real-time video display](#real-time-video-display)
  - [Inserting video into web page](#inserting-video-into-web-page)
  - [Connecting to a real server](#connecting-to-a-real-server)
  - [User authentication](#user-authentication)
  - [Change channel](#change-channel)
  - [Display recorded video](#display-recorded-video)
- [Session authentication](#session-authentication)
  - [Sign in](#sign-in)
  - [Sign out](#sign-out)
- [Request server information](#request-server-information)
  - [API version](#api-version)
  - [Site name](#site-name)
  - [Server-side time zone](#server-side-time-zone)
  - [Product information](#product-information)
  - [License information](#license-information)
  - [User information](#user-information)
  - [Request all at once](#request-all-at-once)
- [Request system informatoin `@0.2.0`](#request-system-informatoin-020)
- [Request various enumeration](#request-various-enumeration)
  - [Channel list](#channel-list)
  - [Vehicle number recognition device list](#vehicle-number-recognition-device-list)
  - [Emergency call device list `@0.3.0`](#emergency-call-device-list-030)
  - [Event log type list](#event-log-type-list)
- [Retrieve recorded data](#retrieve-recorded-data)
  - [Search dates with recorded video](#search-dates-with-recorded-video)
  - [Search minutes with recorded video `@0.2.0`](#search-minutes-with-recorded-video-020)
  - [Search event log](#search-event-log)
  - [Vehicle number log search](#vehicle-number-log-search)
  - [Search for similar vehicle numbers `@0.2.0`](#search-for-similar-vehicle-numbers-020)
- [Search for video sources](#search-for-video-sources)
  - [Real-time video source](#real-time-video-source)
  - [Recorded video source](#recorded-video-source)
- [Requesting video using video source `@0.3.0`](#requesting-video-using-video-source-030)
- [Real-time event monitoring `@0.3.0`](#real-time-event-monitoring-030)
  - [Server-Sent Events (SSE)](#server-sent-events-sse)
  - [Car number recognition event](#car-number-recognition-event)
  - [Emergency call event](#emergency-call-event)
  - [Web Sockets (RFC6455)](#web-sockets-rfc6455)
- [Pushing events to the server `(@0.3.0)`](#pushing-events-to-the-server-030)
- [Appendix](#appendix)
  - [The API-supported versions by product](#the-api-supported-versions-by-product)
  - [The features table by product](#the-features-table-by-product)
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
http://tssolution.ipdisk.co.kr:85/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI=
```
[Run](http://tssolution.ipdisk.co.kr:85/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI=)


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
<iframe src='http://tssolution.ipdisk.co.kr:85/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI=' 
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
For security reasons, the `auth=ZGVtbzohMTIzNHF3ZXI=` part is excluded from this copied code. This code is required for authentication and is described in [Session Authentication](#session-authentication).
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
<iframe src='http://tssolution.ipdisk.co.kr:85/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI='
  width='640' height='360' frameborder='0' allowfullscreen></iframe>
```
Here `ZGVtbzohMTIzNHF3ZXI=` following `auth=` is the [base64 encoded](#base64-encoding) part of user ID and password.

The format is to use a colon (`:`) delimiter, such as `userid: password`, to create a username and password as a single text and then [base64 encoded](#base64-encoding).
In the above example, `demo:!1234qwer` is [base64 encoded](#base64-encoding) and becomes `ZGVtbzohMTIzNHF3ZXI=`.


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
    var encodedData = window.btoa(userId + ':' + password);	// base64 encoding
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
http://tssolution.ipdisk.co.kr:85/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI=
```
Run: [Channel1](http://tssolution.ipdisk.co.kr:85/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI=) [Channel2](http://tssolution.ipdisk.co.kr:85/watch?ch=2&auth=ZGVtbzohMTIzNHF3ZXI=) [Channel3](http://tssolution.ipdisk.co.kr:85/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI=)

### Display recorded video
To display the recorded video, you need the date and time information (time stamp) of the desired video.
For example, to display a video recorded on `Channel 1` at 2:30:15 pm on February 1, 2018, you would need to add `when=2018-02-01T14%3a30%3a15%2b09%3a00`.
```ruby
http://tssolution.ipdisk.co.kr:85/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI=
```
[Run](http://tssolution.ipdisk.co.kr:85/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI=&lang=en-US)

> [Tips]
The recorded video of the old date may already be overwritten depending on the capacity of the storage device.

`2018-02-01T14%3a30%3a15%2b09%3a00` is the date and time in the format [ISO 8601](#date-and-time-notation-in-iso-8601-format).

You can use `when=now` to request real-time video, but if omitted, it means real-time video, and the following tips are provided for ease of use.
```
when=yesterday    // Local time on server yesterday 00:00:00
when=today        // Local time on server today 00:00:00
```
Run: [Yesterday](http://tssolution.ipdisk.co.kr:85/watch?ch=1&when=yesterday&auth=ZGVtbzohMTIzNHF3ZXI=&lang=en-US) [Today](http://tssolution.ipdisk.co.kr:85/watch?ch=1&when=today&auth=ZGVtbzohMTIzNHF3ZXI=&lang=en-US)

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
All response data is in the [JSON format](#json-data-format) and the text is encoded as `utf8`. The actual data being transferred uses an optimized format without line breaks and whitespace, but this article uses a format that is easy to read the items in the data.


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
/api/auth?login=ZGVtbzohMTIzNHF3ZXI=    # http://host omitted
```
If the login is successful, the server returns an HTTP response code of 200.

You can use `auth=` to sign in the same way as shown below.
```ruby
/api/auth?auth=ZGVtbzohMTIzNHF3ZXI=
```
The `auth =` parameter is used in various APIs to be introduced later and can be used when making a request with user authentication information to the server without going through a separate login process.

### Sign out
After the session is connected, the following request can be used to terminate it.
```ruby
/api/auth?logout
```
At the end of the session, the server returns an HTTP response code of 401 for requests that require authentication, indicating that authentication is required.


## Request server information

### API version
This request works, even if it is not in [session suthenticated](#session-authentication) state.
```ruby
/api/info?apiVersion
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
/api/info?siteName
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
/api/info?timezone
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
/api/info?product
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
/api/info?license
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
// for a genuine lincense:
{
  "license": {
    "type": "genuine",    // Genuine lincense
    "maxChannels": 36,    // Maximum channels available
    "extension": [        // Add-ons
      "lprExt"            // Interworking the vehicle number recognition
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

### User information
Used to get sign-in user information.
This request works only in the [session authenticated](#session-authentication) state.
From here on, the `auth =` part of [session authentication](#session-authentication) is omitted.
```ruby
/api/info?whoAmI
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
If it is not in [session authenticated](#session-authentication) state, the server sends an HTTP response code 401 error.

```jsx
{
  "whoAmI": {
    "uid":"admin",      // User ID
    "name":"admin",     // User name
    "accessRights": [   // Permissions
      "DataExport",     // Export images, videos
      "Control",        // Pan tilt, relay control
      "Settings",       // Change settings
      "Playback",       // Play saved videos
      "LPR",            // Vehicle number search
      "SearchEdit",     // Edit search data
      "Remote"          // Eemote access
    ]
  }
}
```

### Request all at once
You can request information individually, but we also provide a way to request all the information at once for convenience.
```ruby
/api/info?all
```
This request returns JSON data with an HTTP response code of 200 if the session is authenticated, or JSON data with an HTTP response code of 401 with no `whoAmI` entries if it is not authenticated.
```jsx
// Session authenticated state (HTTP response code: 200):
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
    "maxChannels": 36,
    "extension": [
      "lprExt"
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
    "maxChannels": 36,
    "extension": [
      "lprExt"
    ]
  }     // whoAmI is not included
}
```

## Request system informatoin `@0.2.0`
Requests system information from the server.
```ruby
/api/sysinfo
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
{
  "cpu": {
    "name": "Intel(R) Core(TM) i7-4712MQ CPU @ 2.30GHz",
    "cores": 8
  },
  "systemMemory": "12 GB",
  "displayAdapter": [
    {
      "model": "Intel(R) HD Graphics 4600",
      "monitor": [
        "Generic PnP Monitor",
        "Generic PnP Monitor"
      ]
    }
  ],
  "hdd": [
    {
      "model": "SanDisk SD7SB6S256G1122",
      "serialNo": "150608401947",
      "capacity": "256 GB"
    },
    {
      "model": "ST1000LM024 HN-M101MBB",
      "serialNo": "S2R8J9BC700641",
      "capacity": "1 TB"
    }
  ],
  "networkAdapter": [
    {
      "name": "Realtek PCIe GBE Family Controller",
      "mac": "80-FA-5B-03-79-5E",
      "ipAddress": "192.168.0.43"
    },
  ]
}
```

## Request various enumeration
The following requests return the JSON data with an HTTP response code of 200 if it is in [session authenticated](#session-authentication) state, or an HTTP response code of 401 if the session is not authenticated.

### Channel list
To get a list of channels in use, request the following:
```ruby
/api/enum?what=channel
```
For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  {
    "chid": 1,              // Channel number
    "title": "Front door"   // Channel name
  },
  {
    "chid": 2,              // Channel number
    "title": "Garage"       // Channel name
  }
]
```

### Vehicle number recognition device list
To get a list of vehicle identification devices in use, ask for the following:
The vehicle number recognition device list includes used devices when an external device is interworked, and in case of TS-LPR with built-in car number recognition function, it includes preset car number recognition zones.

```ruby
/api/enum?what=lprSrc
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
/api/enum?what=emergencyCall
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
/api/enum?what=eventType
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
/api/enum?what=eventType&lang=es-ES
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


## Retrieve recorded data

Use `/api/find` to search for recorded data.

### Search dates with recorded video
To get a list of dates with recorded videos, request the following:

```ruby
/api/find?what=recDays      // Request all dates with recorded video
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
/api/find?what=recDays&ch=1
# Request date list of channels 1,2,3 recorded 
/api/find?what=recDays&ch=1,2,3

# List of recorded dates since February 2018 (2018-02-01T00: 00:00-05:00)
/api/find?what=recDays&timeBegin=2018-02-01T00%3A00%3A00-05%3A00

# List of dates recorded in January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-05:00)
/api/find?what=recDays&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# List of dates when channel 1 was recorded in January 2018
/api/find?what=recDays&ch=1&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00
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
/api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00-05%3A00&timeEnd=2018-02-02T00%3A00%3A00-05%3A00

# When using UTC time
/api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00Z&timeEnd=2018-05-26T00%3A00%3A00Z
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
/api/find?what=eventLog
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
      "comment": "admin: Auto-login"
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
      "comment": "Genuine license"
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
/api/find?what=eventLog&lang=ar-AE

# Event log requests recorded during January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-05:00)
/api/find?what=eventLog&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# Request 20 items from the 10th item in the search results
/api/find?what=eventLog&at=10&maxCount=20

# Sort by old data order (ascending order)
/api/find?what=eventLog&sort=asc

# Request the system log type id list
/api/enum?what=eventType

# Request only system log (id: 0) of event log types
/api/find?what=eventLog&type=0


```


### Vehicle number log search
If you use the car number recognition function, the recognized car number is saved with the video. To retrieve the car number log you will request as follows:

```ruby
/api/find?what=carNo
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
      "timeRange": [                      // Date and time the vehicle number was recognized
        "2018-02-21T09:07:29.000-05:00",  // Starting timestamp
        "2018-02-21T09:07:34.057-05:00"   // Ending timestamp
      ],
      "srcCode": "1-1-1",                 // Vehicle number recognition device (or zone) code
      "srcName": "The%20Empire%20State",  // Vehicle number recognition device (or zone) name
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
      "timeRange": [
        "2018-02-21T08:00:00.915-05:00",
        "2018-02-21T08:00:01.714-05:00"
      ],
      "srcCode": "1-1-1",
      "srcName": "1-1-1",
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

# Examples
# Search for vehicle number including "12" (keyword search)
/api/find?what=carNo&keyword=12

# Request Arabic
/api/find?what=carNo&lang=ar-AE

# Request vehicle number logs recorded during January 2018
# (2018-01-01T00:00:00-05:00 ~ 2018-01-31T23:59:59.999-059:00)
/api/find?what=carNo&timeBegin=2018-01-01T00%3A00%3A00-05%3A00&timeEnd=2018-01-31T23%3A59%3A59.999-05%3A00

# Request 20 items from the 10th item in the search results
/api/find?what=carNo&at=10&maxCount=20

# Sort by old data order (ascending order)
/api/find?what=carNo&sort=asc
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
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828-05%3A00&auth=ZGVtbzohMTIzNHF3ZXI=
```


### Search for similar vehicle numbers `@0.2.0`
Can be used to verify that a similar vehicle number exists.
To retrieve similar vehicle numbers from the log, request the following:
```ruby
/api/find?what=similarCarNo&keyword=1234

# Parameters
keyword     # Vehicle number text to search (or some characters)
maxCount    # Maximum number of items

# Examples
# Request up to 10 results
/api/find?what=similarCarNo&keyword=123&maxCount=10
```

For the request, the server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[
  "AVF4123",
  "123MTB",
    // ... omitted
]
```

## Search for video sources
You can use this method if your application uses the video address directly instead of the video display feature using the API you used in [Inserting video into web page](#inserting-video-into-web-page).

This way you can get video address instead of displaying video.

### Real-time video source
You can request a list of real-time video addresses that the server is streaming by requesting the following without any parameters:
```ruby
/api/vod
```
The server returns JSON data in the following format with an HTTP response code of 200:
```jsx
[ // Each channel consists of an array of items
  {
    "chid": 1,                        // Channel number
    "title": "Profile1 (1920x1080)",  // Channel name
    "src": [  // List of video sources
              // (Multiple sources are organized into an array in one channel, depending on protocol and resolution)
      { // 1080p RTMP stream
        "src": "rtmp://192.168.0.100/live/ch1main",  // Video address
        "type": "rtmp/mp4",     // MIME type: RTMP protocol (Adobe Flash)
        "label": "1080p FHD",   // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ]
      },
      { // 1080p HLS stream
        "src": "http://192.168.0.100/hls/ch1main/index.m3u8", // Video address
        "type": "application/x-mpegurl",  // MIME type: HLS protocol (HTML5)
        "label": "1080p FHD",   // Resolution name
        "size": [               // Resolution
          1920,                 // Number of horizontal pixels
          1080                  // Number of vertical pixels
        ]
      },
      { // VGA RTMP stream
        "src": "rtmp://192.168.0.100/live/ch1sub",   // RTMP protocol (Adobe Flash)
        "type": "rtmp/mp4",   // MIME type: RTMP protocol (Adobe Flash)
        "label": "VGA",
        "size": [
          640,
          480
        ]
      },
      { // VGA HLS stream
        "src": "http://192.168.0.100/hls/ch1sub/index.m3u8", // Video address
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
    "src": [
      // ... omitted
    ]
  },
  // ... omitted
]
```

Because of the variety of environments (network bandwidth and protocol supported by the player) in which the video is played, we provide multiple video sources per channel as shown in the example above for compatibility.
In the current version, it is streamed in two formats `RTMP` and` HLS`, and if the camera supports it, it can be dual-stream in high resolution and low resolution.

In fact, the `when=now` parameter, which means live video, is omitted in the example above.
```ruby
/api/vod?when=now
```

If required, you can specify search parameters by combining one or more of the following parameters.
```ruby
ch          # Channel number (meaning all channels if not specified)
protocol    # Specify a streaming protocol (rtmp, hls)
stream      # Specify the resolution of the video (main: High definition video, sbu: Low-resolution video)
nameonly    # If true, only the channel name is requested without the video stream data part. 

# Examples
# Request channel 1 only
/api/vod?ch=1

# Request only hls protocol streams
/api/vod?protocol=hls

# Request only low-resolution streams
/api/vod?stream=sub

# Only request channel name
/api/vod?nameonly=true
# Or simply
/api/vod?nameonly
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

# Examples
# The channel 1 video source on channel 1 ecorded on January 8, 2018 at 9:30 PM EST
# [Important!]
#   1. For recorded video, HTTP response code 400 (invalid request) occurs if 'ch=' is not specified.
#   2. Only data within 1 second is retrieved from the time specified by 'when='.
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00

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
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00&duration=1h

# Direct request using recording file ID
# If there is a video, it returns 10 consecutive (by default) video sources 
# from that video.
# [Tips]
#   Each video file recorded on the server is assigned a unique serial number 
#   that is represented by an integer.
/api/vod?id=1304

# If the current file ID of channel 1 is 1034, it requests the next file
# of the same channel (useful for continuous playback)
/api/vod?ch=1&id=1304&next=true
# Or simply
/api/vod?ch=1&id=1304&next

# If the current file ID of channel 1 is 1034, it requests the previous file
# of the same channel (useful for continuous backward playback)
/api/vod?ch=1&id=1304&prev=true
# Or simply
/api/vod?ch=1&id=1304&prev

# Receive 30 searched video sources
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00-05%3A00&duration=1h&limit=30

# If there is no search result,
# request near recorded video before the search time period
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearBefore
# request near recorded video after the search time period
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearAfter
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
rtmp://host/path/to&auth=YWRtaW46YWRtaW4=

# HTTP (Only basic authentication is supported for file-based resources such as m3u8, JPG, and MP4)
http://userid:password@host/path/to

# HTTP (The resources of sub path /api/ are supported in both ways)
http://userid:passwordn@host/api/path/to
http://host/api/path/to&auth=YWRtaW46YWRtaW4=
```

## Real-time event monitoring `@0.3.0`
### Server-Sent Events (SSE)
Supports the ability to receive real-time event messsage using HTML5 Server-Sent Events (SSE) method.
Once connection established the server and the client maintain the connection state, and when an event occurs, the server sends a message to the client.

The step-by-step communication procedure is as follows:
>1. Client connects to the server.
>2. If the authentication to the server succeeds, the subscriber ID is issued.
>3. The client then remains connected and enters the message waiting state.
>>* The server sends a ping message every 30 seconds to keep the connection even if there is no message to send.
>4. When an event occurs, the server sends a message to the client.
>5. Repeat steps 3 through 4 until the client ends the connection itself.

> [Tips]
Microsoft Internet Explorer and Microsoft Edge do not support the SSE standard. If you need to work with Microsoft browsers, use the Web socket (RFC6455).
https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events


The following event topics are supported:
```ruby
LPR             # Car number recognition
emergencyCall   # Emergency call
```

SSE connection paths and parameters are as follows.
```ruby
/api/subscribeEvents

# Required parameters
auth    # Authentication Information
topics  # Specify topics to receive (You can specify multiple topics at the same time, which are separated by a comma (,).)

# Optional argument
verbose # request List the live video stream sources of the linked video channels

# Examples
# Request car number recognition event
http://host/api/subscribeEvents?topics=LPR&auth=YWRtaW46YWRtaW4=

# Request emergency call event
http://host/api/subscribeEvents?topics=emergencyCall&auth=YWRtaW46YWRtaW4=

# Request both events
http://host/api/subscribeEvents?topics=LPR,emergencyCall&auth=YWRtaW46YWRtaW4=

# request List the live video stream sources of the linked video channels
http://host/api/subscribeEvents?topics=LPR,emergencyCall&auth=YWRtaW46YWRtaW4=&verbose=true
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

### Car number recognition event
If you request `topics=LPR`, you can receive the car number recognition event in real time.
The car number event message is received in JSON format as shown below.
```jsx
{
  "timestamp":"2018-06-27T10:42:06.575-05:00",  // Vehicle number recognition time
  "chid": {                                     // Car number recognition channel
    "chid":1,
    "title":"Camera1",
    "src":"http://host/watch?ch=1&when=2018%2D06%2D27T10%3A42%3A06%2E575-05%3A00"  // The video at vehicle identification time
  },
  "deviceCode":"1-1-7",                         // Car number identification device (zone) code
  "deviceName":"B1 Parking Lot",                // Car number identification device (zone) name
  "linkedChannel": [                            // Linked channels
    {
      "chid":2,
      "title":"Camera2",
      "src":"http://host/watch?ch=2&when=2018%2D06%2D27T10%3A42%3A06%2E575-05%3A00" // The video at vehicle identification time
    }
  ],
  "plateNo":"DSP963",                           // Car plate number
  "timeBegin":"2018-06-27T10:42:02.573-05:00",  // First recognized time of the car
  "topic":"LPR"                                 // Topic name
}
```

### Emergency call event
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
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"Camera2",
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
http://host/api/subscribeEvents?topics=emergencyCall&auth=YWRtaW46YWRtaW4=&verbose=true
```
```jsx
{
  "timestamp":"2018-06-27T10:56:16.316+09:00",  // Start time of the call
  "caller":"0000002",                           // Emergency call device location code
  "device":"Sammul/Vizufon",                    // Emergency call device name
  "event":"callStart",                          // Call start event
  "linkedChannel":[                             // Linked channels
    {
      "chid":1,
      "title":"Camera1",
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
      "src":"http://host/watch?ch=2",
      "streams":[
        // ... omitted
      ]
    }
  ],
  "name":"B1 Stairs",                     // 비상 호출 장치 위치 이름
  "topic":"emergencyCall"                 // 토픽 이름
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
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"Camera2",
      "src":"http://host/watch?ch=2"
    }
  ],
  "name":"B1 Stairs",                          // Emergency call device location name
  "topic":"emergencyCall"                      // Topic name
}
```
Emergency call event messages are used for real-time communication, so the video address of the linked channel is linked to the real-time video unlike the case of car number recognition.


Now, let's create an example that uses SSE to receive event messages.
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
  <h2>Ex3. Receiving Events (Server-Sent Events)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='Server IP address:port'>
      <input type='text' id='user-id' placeholder='User ID'> 
      <input type='password' id='password' placeholder='Password'>
    </div>
    <div>
      Topics:
      <input type='checkbox' id="LPR" value="LPR" checked>LPR 
      <input type='checkbox' id="emergencyCall" value="emergencyCall" checked>emergencyCall 
      <button type='button' onClick='onConnect()'>Connect</button>
      <button type='button' onClick='onDisconnect()'>Disconnect</button>
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
    window.myApp = { es: null };
  })();

  function getURL() {
    var url = '';

    if (typeof(EventSource) === 'undefined') {
			alert('Your web browser does\'nt support Server-Sent Events.');
      return url;
    }

		if(window.myApp.es !== null) {
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
    if(document.getElementById('LPR').checked)
      topics += 'LPR';
    if(document.getElementById('emergencyCall').checked) {
      if(topics.length > 0)
        topics += ',';
      topics += 'emergencyCall';
    }
    if(topics.length == 0) {
      alert('Please select at least one topic.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 encoding
    url = (hostName.includes('http://', 0) ? '' : 'http://') +
			hostName + '/api/subscribeEvents?topics=' + topics + 
			'&auth=' + encodedData;

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

    // EventSource instance and it's handler functions
		var es = new EventSource(url);
		es.onopen = function() {
			addItem('open', 'Connected');
		};
		es.onerror = function() {
			addItem('error', 'Error');
			onDisconnect();
		};
		es.onmessage = function(e) {
			var data = JSON.parse(e.data);
			addItem('data', e.data);
		}
		window.myApp.es = es;
  }

  function onDisconnect() {
		if(	window.myApp.es !== null) {
	    window.myApp.es.close();
			window.myApp.es = null;
			addItem('close', 'Disconnected');
			document.getElementById('url').innerText = '';
		}
  }
</script>
```
[Run](./examples/ex3.html)


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

The web socket connection path and parameters are as follows.
```ruby
/wsapi/subscribeEvents

# Required parameters
auth    # Authentication Information (Requires authentication per individual web socket, independent of session authentication)
topics  # Specify topics to receive (You can specify multiple topics at the same time, which are separated by a comma (,).)

# Optional argument
verbose # request List the live video stream sources of the linked video channels

# Example
# Request car number recognition event
ws://host/wsapi/subscribeEvents?topics=LPR&auth=YWRtaW46YWRtaW4=

# Request emergency call event
ws://host/wsapi/subscribeEvents?topics=emergencyCall&auth=YWRtaW46YWRtaW4=

# Request both events
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=YWRtaW46YWRtaW4=

# request List the live video stream sources of the linked video channels
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=YWRtaW46YWRtaW4=&verbose=true
```

The event data format received after a Web socket connection is exactly the same as Server-Sent Events (SSE) and is not described here again.

Now, let's create an example that uses the Web socket to receive event messages.
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>ex4</title>
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
  <h2>Ex4. Receiving Events (Web Socket)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='Server IP address:port'>
      <input type='text' id='user-id' placeholder='User ID'> 
      <input type='password' id='password' placeholder='Password'>
    </div>
    <div>
      Topics:
      <input type='checkbox' id="LPR" value="LPR" checked>LPR 
      <input type='checkbox' id="emergencyCall" value="emergencyCall" checked>emergencyCall 
      <button type='button' onClick='onConnect()'>Connect</button>
      <button type='button' onClick='onDisconnect()'>Disconnect</button>
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
    if(document.getElementById('LPR').checked)
      topics += 'LPR';
    if(document.getElementById('emergencyCall').checked) {
      if(topics.length > 0)
        topics += ',';
      topics += 'emergencyCall';
    }
    if(topics.length == 0) {
      alert('Please select at least one topic.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 encoding
    url = (hostName.includes('ws://', 0) ? '' : 'ws://') +
    	hostName + '/api/subscribeEvents?topics=' + topics + 
			'&auth=' + encodedData;

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
			document.getElementById('url').innerText = '';
		}
  }
</script>
```
[Run](./examples/ex4.html)


## Pushing events to the server `(@0.3.0)`
You can send events from an external device or software to the server by `HTTP POST` method.

The following event topics are supported:
```ruby
LPR             # Car number recognition
emergencyCall   # Emergency call
```

The path and parameters for sending events to the server are:
```ruby
/api/push

# Parameter
auth    # authentication information
```

Specify event data in JSON format in contents data.
**Car number recognition data**
```jsx
{
  "topic": "LPR",         // Car number data
  "src": "F00001",        // Car number recognition device code
  "plateNo": "01가2345",  // the car number
  // Below are optional.
  "when": "2018-02-01T14%3a30%3a15-05%3a00",    // Vehicle number recognition time, if not specified, the server uses the time when the event was received
  "timeBegin": "2018-02-01T14%3a30%3a14-05%3a00"  // For car parked, specify the first recognition time
}
```

**Emergency call data**
```jsx
{
  "topic": "emergencyCall",   // Emergency call data
  "device": "vendor/device",  // Emergency call device model name
  "src": "0000001",           // Emergency call device location code
  "event": "callStart",       // call start (or "callEnd" for call end)
  "when": "2018-02-01T14%3a30%3a15-05%3a00" // Event occurrence time
}
```

If the request is successful, the server returns an HTTP response code of 200 and no additional Contents data is returned.


## Appendix

### The API-supported versions by product

The versions of the products that support the API are as follows.

| API version | TS-CMS           | TS-NVR           | TS-LPR           |
|-------------|------------------|------------------|------------------|
| 0.1.0       | v0.38.0 or later | v0.35.0 or later | v0.2.0A or later |
| 0.2.0       | v0.41.0 or later | v0.40.0 or later | v0.7.0A or later |
| 0.3.0       | v0.42.1 or later | v0.41.1 or later | v0.8.2A or later |

APIs are compatible across all product lines, but some features may not be supported by product or by license. Please check the list below to see which products you are using.

### The features table by product

| Features                                                            | TS-CMS | TS-NVR                                 | TS-LPR |
|---------------------------------------------------------------------|--------|----------------------------------------|--------|
| [Real-time video display](#real-time-video-display)                 | O      | O                                      | O      |
| [Real-time video source search](#real-time-video-source)            | O      | O                                      | O      |
| [Display recorded video](#display-recorded-video)                   | X      | O                                      | O      |
| [Rcorded video source search](#recorded-video-source)               | X      | O                                      | O      |
| [Session Authentication](#session-authentication)                   | O      | O                                      | O      |
| [Request server information](#request-server-information)           | O      | O                                      | O      |
| [Request various enumeration](#request-various-enumeration)         | O      | O                                      | O      |
| [Search date with recorded video](#search-date-with-recorded-video) | X      | O                                      | O      |
| [Search Event Log](#search-event-log)                               | O      | O                                      | O      |
| [Vehicle number log search](#vehicle-number-log-search)             | X      | depends on the license `[Tips]` | O      |

> [Tips]
TS-NVR does not have built-in vehicle number recognition function and **vehicle number log search** function is not supported.
However, if you use the add-on license of **vehicle number recognition interworking**, you can use the **vehicle number log search** because it stores the car number log incoming from the external vehicle number recognition device.


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
ko-KR       # 한국어, Korean
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