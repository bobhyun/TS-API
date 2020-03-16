TS-API
======

![Alt TS-CMS](img/tscms.png) ![Alt TS-NVR](img/tsnvr.png) ![Alt TS-LPR](img/tslpr.png)

**TS-API** is a web API built into the TS series video software lineup, which are **TS-CMS**, **TS-NVR** and **TS-LPR** of TS Solutions Corp..

With this API, you can easily embed **CCTV video and search functionality** into your web page, like this:
```html
<!DOCTYPE>
<head>
  <meta charset='utf-8'>
  <title>My Video</title>
</head>
<body>
  <iframe src='http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D' 
  width='640' height='360' frameborder='0' allowfullscreen />
</body>
```
[Run](http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D)

For more information, refer to the following **TS-API Programmer's Guide**:
[English](./en/TS-API.en.md)
[Korean](./ko/TS-API.ko.md)

License
------
MIT, Copyright (c) 2018-2020 TS Solution Corp.