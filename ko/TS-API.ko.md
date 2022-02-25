TS-API 프로그래밍 안내서
======

TS-API@0.9.16
-----

이 문서는 **(주)티에스 솔루션**의 **TS-CMS**, **TS-NVR**, **TS-LPR**에 내장된 **TS-API**를 사용하여 응용 소프트웨어를 개발하는 분들을 위한 프로그래밍 안내서입니다.
이 문서를 참고하여 실시간 영상, 녹화 영상 보기, 영상 검색 기능을 간단하게 여러분의 응용 소프트웨어에 포함시킬 수 있습니다.

API를 사용하기 위해 간단한 `HTML`과 `자바스크립트`를 사용해 본 경험이 있으면 도움이 됩니다.
그리고 제품 별로 지원하는 기능이 다를 수 있으므로 [부록](#부록)의  
[제품별 API 지원 버전](#제품별-api-지원-버전)와 [제품별 기능 지원 표](#제품별-기능-지원-표) 부분을 참고하시기 바랍니다.


> [참고]
API와 본 문서는 개발 지원 및 기능 향상을 위해 공지 없이 변경될 수 있습니다.

목차
-----

<!-- TOC -->

- [TS-API 프로그래밍 안내서](#ts-api-프로그래밍-안내서)
  - [TS-API@0.9.16](#ts-api0916)
  - [목차](#목차)
  - [시작하기](#시작하기)
  - [영상 표시](#영상-표시)
    - [실시간 영상 표시](#실시간-영상-표시)
    - [웹 페이지에 영상 삽입하기](#웹-페이지에-영상-삽입하기)
    - [실제 서버에 접속하기](#실제-서버에-접속하기)
    - [사용자 인증](#사용자-인증)
    - [채널 변경](#채널-변경)
    - [녹화 영상 표시](#녹화-영상-표시)
  - [JSON 데이터 들여쓰기 `@0.5.0`](#json-데이터-들여쓰기-050)
  - [세션 인증](#세션-인증)
    - [로그인](#로그인)
    - [로그아웃](#로그아웃)
  - [서버 정보 요청](#서버-정보-요청)
    - [API 버전](#api-버전)
    - [사이트 이름](#사이트-이름)
    - [서버 시간대](#서버-시간대)
    - [제품 정보](#제품-정보)
    - [라이센스 정보](#라이센스-정보)
      - [부가 기능`extension` 목록](#부가-기능extension-목록)
    - [사용자 정보](#사용자-정보)
    - [모두 한 번에 요청](#모두-한-번에-요청)
  - [시스템 정보 요청 `@0.3.0`](#시스템-정보-요청-030)
    - [개별 항목 요청](#개별-항목-요청)
  - [시스템 상태 요청 `@0.3.0`](#시스템-상태-요청-030)
    - [개별 항목 요청](#개별-항목-요청-1)
  - [HDD S.M.A.R.T. 요청 `@0.6.0`](#hdd-smart-요청-060)
  - [서버 재시작 요청 `@0.6.0`](#서버-재시작-요청-060)
  - [시스템 재부팅 요청 `@0.6.0`](#시스템-재부팅-요청-060)
  - [채널 상태 요청 `@0.3.0`](#채널-상태-요청-030)
  - [각종 목록 요청](#각종-목록-요청)
    - [채널 목록 `@0.9.4`](#채널-목록-094)
      - [스트림 목록 추가하기 `@0.9.4`](#스트림-목록-추가하기-094)
      - [카메라 지원 기능 추가하기 `@0.9.4`](#카메라-지원-기능-추가하기-094)
    - [차량 번호 인식 장치 목록](#차량-번호-인식-장치-목록)
    - [비상 호출 장치 목록 `@0.3.0`](#비상-호출-장치-목록-030)
    - [이벤트 로그 종류 목록](#이벤트-로그-종류-목록)
    - [주차장 목록 `@0.9.8`](#주차장-목록-098)
    - [수신 가능한 실시간 이벤트 목록 `@0.9.6`](#수신-가능한-실시간-이벤트-목록-096)
    - [지원하는 객체 목록 `@0.9.11`](#지원하는-객체-목록-0911)
    - [지원하는 객체별 속성 목록 `@0.9.11`](#지원하는-객체별-속성-목록-0911)
  - [저장 데이터 검색](#저장-데이터-검색)
    - [녹화 영상이 있는 날짜 검색](#녹화-영상이-있는-날짜-검색)
    - [녹화 영상이 있는 분 단위 검색 `@0.2.0`](#녹화-영상이-있는-분-단위-검색-020)
    - [이벤트 로그 검색](#이벤트-로그-검색)
    - [차량 번호 로그 검색](#차량-번호-로그-검색)
    - [유사 차량 번호 검색 `@0.2.0`](#유사-차량-번호-검색-020)
    - [객체 검색 `@0.9.11`](#객체-검색-0911)
      - [공통 매개변수](#공통-매개변수)
      - [face용 매개변수](#face용-매개변수)
      - [human용 매개변수](#human용-매개변수)
      - [vehicle용 매개변수](#vehicle용-매개변수)
    - [얼굴 검색 `@0.9.6`](#얼굴-검색-096)
  - [동영상 소스 검색](#동영상-소스-검색)
    - [실시간 영상 소스](#실시간-영상-소스)
    - [녹화 영상 소스](#녹화-영상-소스)
  - [동영상 소스를 사용하여 영상 요청 `@0.3.0`](#동영상-소스를-사용하여-영상-요청-030)
  - [실시간 이벤트 모니터링 `@0.3.0`](#실시간-이벤트-모니터링-030)
    - [웹 소켓 (RFC6455)](#웹-소켓-rfc6455)
    - [채널 상태 변경 이벤트](#채널-상태-변경-이벤트)
    - [차량 번호 인식 이벤트](#차량-번호-인식-이벤트)
    - [비상 호출 이벤트](#비상-호출-이벤트)
    - [시스템 이벤트 `@0.7.0`](#시스템-이벤트-070)
    - [움직임 감지 이벤트 `@0.8.0`](#움직임-감지-이벤트-080)
    - [주차 카운트 이벤트 `@0.9.0`](#주차-카운트-이벤트-090)
    - [녹화 상태 이벤트 `@0.9.5`](#녹화-상태-이벤트-095)
    - [객체 감지 이벤트 `@0.9.11`](#객체-감지-이벤트-0911)
      - [`face` 객체](#face-객체)
      - [`human` 객체](#human-객체)
      - [`vehicle` 객체](#vehicle-객체)
    - [체온 감지 이벤트 `@0.9.14`](#체온-감지-이벤트-0914)
  - [녹화 영상 받아내기 `@0.3.0`](#녹화-영상-받아내기-030)
  - [채널 정보 및 장치 제어 `@0.5.0`](#채널-정보-및-장치-제어-050)
    - [장치 정보 및 지원 기능 목록 요청](#장치-정보-및-지원-기능-목록-요청)
    - [팬틸트 제어](#팬틸트-제어)
    - [팬틸트 프리셋 제어](#팬틸트-프리셋-제어)
    - [릴레이 출력](#릴레이-출력)
    - [AUX 출력](#aux-출력)
    - [장치 재부팅](#장치-재부팅)
  - [채널 추가 `@0.9.7`](#채널-추가-097)
    - [요청 데이터](#요청-데이터)
      - [카메라](#카메라)
      - [동영상 스트림](#동영상-스트림)
      - [동영상 파일](#동영상-파일)
    - [응답](#응답)
      - [응답 데이터](#응답-데이터)
  - [채널 삭제 `@0.9.7`](#채널-삭제-097)
      - [응답 데이터](#응답-데이터-1)
  - [부록](#부록)
    - [제품별 API 지원 버전](#제품별-api-지원-버전)
    - [제품별 기능 지원 표](#제품별-기능-지원-표)
    - [base64 인코딩](#base64-인코딩)
    - [URL 인코딩](#url-인코딩)
    - [URL 디코딩](#url-디코딩)
    - [ISO 8601 형식으로 날짜 시각 표현하기](#iso-8601-형식으로-날짜-시각-표현하기)
    - [지원하는 언어 목록](#지원하는-언어-목록)
    - [JSON 데이터 형식](#json-데이터-형식)
    - [피드백](#피드백)

<!-- /TOC -->


## 시작하기
이 문서 내에서는 TS-API를 줄여서 **API**로 부르고, 각 제품들은 간단히 **서버**로 부르겠습니다.



## 영상 표시

### 실시간 영상 표시
웹 브라우저 주소 창에 다음과 같이 입력해 보십시오.
```ruby
http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
[실행하기](http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D)


동영상이 표시되나요?

> [참고]
이 예제 코드에 사용된 시연용 영상은 현장 상황에 따라 접속되지 않을 수도 있습니다.


### 웹 페이지에 영상 삽입하기
이 번에는 이 영상을 웹 페이지에 삽입해 봅시다.
```html
<!DOCTYPE>
<head>
  <meta charset="utf-8">
  <title>ex1</title>
</head>

<body>
<h2>예제1. 동영상 삽입하기</h2>
<iframe src="http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D" 
  width="640" height="360" frameborder="0" allowfullscreen />
</body>
```
[실행하기](./examples/ex1.html)

예제에서 사용된 동영상 URL과 `<iframe>` 태그 코드는 표시되는 **영상 위에서 오른쪽 마우스 버튼을 클릭**하면 (모바일인 경우 1초 정도 화면을 누르면) 팝업 메뉴가 나타납니다. 여기서 필요한 메뉴 항목을 선택하면 해당 코드가 클립보드에 복사되며 아래 표와 같이 각각의 용도에 맞게 **붙여넣기** 하면 됩니다.

| 메뉴 항목        | 용도                          |
|--------------|-----------------------------|
| 동영상 URL 복사   | 웹 브라우저 주소 창에 붙여넣기           |
| 동영상 태그 코드 복사 | HTML 코드의 `<iframe>`부분에 붙여넣기 |

> [참고]
보안 상의 이유로 이렇게 복사한 코드에는 `auth=ZGVtbzohMTIzNHF3ZXI%3D` 부분이 제외됩니다. 이 부분은 로그인에 필요한 코드이며 [세션 인증](#세션-인증)에서 자세히 설명합니다.
이 예제에서는 동영상을 표시하기 위한 최소한의 코드만을 사용했기 때문에 복사된 코드에 비해 빠진 부분이 더 있습니다.


### 실제 서버에 접속하기
이제 데모용 서버가 아닌 실제 서버의 영상을 표시하는 방법을 알아 보겠습니다.
실제 서버에 접속하려면 기본적으로 아래 두 가지 정보를 알아야 합니다.

1. 서버의 **호스트명** (**IP 주소** 또는 **도메인명**, 80 포트가 아닌 경우 **포트 번호**)
>* 포트 번호는 사용하시는 제품 설정 창에서 `웹 서비스` 탭의 `HTTP 포트` 항목에서 확인할 수 있습니다.
2. **원격 접속** 권한이 있는 **사용자 ID**와 **비밀번호**


### 사용자 인증
예를 들어, 다음과 같은 접속정보를 사용하는 것으로 가정하면

| 항목      | 값                         |
|---------|---------------------------|
| IP 주소   | `http://tssolution.iptime.org` |
| 웹 포트    | `81`                      |
| 사용자 아이디 | `demo`                    |
| 비밀번호    | `!1234qwer`               |

위의 예제에서 주소 부분을 다음과 같이 변경하면 됩니다.
```html
<iframe src="http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D"
  width="640" height="360" frameborder="0" allowfullscreen></iframe>
```
여기서 `auth=` 다음에 있는 `ZGVtbzohMTIzNHF3ZXI%3D` 부분은 사용자 아이디와 비밀번호를 [base64 인코딩](#base64-인코딩)한 부분입니다.
형식은 `userid:password`와 같이 콜론(`:`) 구분자를 사용하여 사용자 아이디와 비밀번호를 하나의 텍스트로 만든 다음 [base64 인코딩](#base64-인코딩)합니다.
위의 예에서는 `demo:!1234qwer`을 [base64 인코딩](#base64-인코딩)해서 `ZGVtbzohMTIzNHF3ZXI%3D`가 됩니다.


이번 예제에서는 자바스크립트로 로그인 정보를 [base64 인코딩](#base64-인코딩)해서 접속하는 방식으로 개선해 보도록 하겠습니다.
```html
<!DOCTYPE>
<head>
  <meta charset="utf-8">
  <title>ex2</title>
</head>

<script>
  function onConnect() {
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert("호스트를 입력하십시오.");
      return;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert("사용자 아이디를 입력하십시오.");
      return;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert("비밀번호를 입력하십시오.");
      return;
    }
    var encodedData = window.btoa(userId + ':' + password); // base64 인코딩
    var src = 'http://' + hostName + '/watch?ch=1&auth=' + encodedData;
    document.getElementById('result').innerText = src;
    document.getElementById('player').src = src;
  }
</script>

<body>
  <h2>예제2. 실제 서버에 접속하기</h2>
  <table>
    <tr>
      <td>호스트</td>
      <td>사용자 아이디</td> 
      <td>비밀번호</td>
    </tr>
    <tr>
      <td><input type="text" id="host-name"></td>
      <td><input type="text" id="user-id"></td> 
      <td><input type="text" id="password"></td>
      <td><button type="button" onClick="onConnect()">접속</button></td>
    </tr>
    <tr>
      <td colspan="4" id="result"></td>
    </tr>
  </table>

  <iframe width="640" height="360" frameborder="0" allowfullscreen id="player" />
</body>
```
[실행하기](./examples/ex2.html)


### 채널 변경
아래와 같이 동영상 소스의 `ch=` 부분을 원하는 채널 번호로 변경하면 해당 채널의 동영상이 표시됩니다.
채널 번호는 1부터 시작하는 정수입니다.
예를 들어, 채널 3번을 보고 싶다면 다음과 같이 수정하면 됩니다.
```ruby
http://tssolution.iptime.org:83/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
실행하기: [채널1](http://tssolution.iptime.org:83/watch?ch=1&auth=ZGVtbzohMTIzNHF3ZXI%3D) [채널2](http://tssolution.iptime.org:83/watch?ch=2&auth=ZGVtbzohMTIzNHF3ZXI%3D) [채널3](http://tssolution.iptime.org:83/watch?ch=3&auth=ZGVtbzohMTIzNHF3ZXI%3D)



### 녹화 영상 표시
녹화된 영상을 표시하기 위해서는 원하는 동영상의 날짜, 시각 정보(타임스탬프)가 필요합니다.
예를 들어, 위의 예제와 동일한 접속 정보로 `채널 1번`의 `2018년 2월 1일 오후 2시 30분 15초`에 녹화된 영상을 표시하기 위해서는 다음과 같이 `when=2018-02-01T14%3a30%3a15%2b09%3a00` 부분을 추가해야 합니다.
```ruby
http://tssolution.iptime.org:83/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
[실행하기](http://tssolution.iptime.org:83/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGVtbzohMTIzNHF3ZXI%3D)
> [참고]
오래된 날짜의 녹화 영상은 저장장치의 용량에 따라 이미 덮어쓰기 되어 존재하지 않을 수 있습니다.

`2018-02-01T14%3a30%3a15%2b09%3a00` 부분은 [ISO 8601](#ISO-8601-형식으로-날짜-시각-표현하기) 형식의 날짜, 시각을 [URL 인코딩](#url-인코딩)한 것입니다.

실시간 영상을 요청하기 위해서 `when=now`로 요청해도 되지만, `when=`이 없으면 실시간을 의미하므로 생략해도 됩니다.
그리고 사용상 편의를 위해 다음과 같은 팁들을 제공합니다.
```
when=yesterday    // 서버의 로컬 타임으로 어제 00시 00분 00초
when=today        // 서버의 로컬 타임으로 오늘 00시 00분 00초
```
실행하기: [어제 영상](http://tssolution.iptime.org:83/watch?ch=1&when=yesterday&auth=ZGVtbzohMTIzNHF3ZXI%3D) [오늘 영상](http://tssolution.iptime.org:83/watch?ch=1&when=today&auth=ZGVtbzohMTIzNHF3ZXI%3D)

매개변수를 사용하여 영상 위에 표시되는 자막의 언어를 설정할 수 있습니다.
[지원하는 언어 목록](#지원하는-언어-목록)은 부록을 참고하십시오.
여기서부터는 `http://host`부분과 `auth=` 부분은 생략하고 표현합니다.
```ruby
# 매개변수
lang            # 자막 언어 지정
showTitle       # 채널 이름 표시 (true, false)
showPlayTime    # 재생 날짜, 시각 표시 (true, false)

# 예제
# 한글로 날짜, 시각 표시
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&lang=ko-KR

# 채널 이름 및 재생 날짜, 시각 표시 안함
# showTitle과 showPlayTime은 명시하지 않은 경우 true로 간주함
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&showTitle=false&showPlayTime=false
```


지금까지는 `/watch` 호출을 통해 영상을 표시하는 방법들을 알아 보았습니다. 여기서부터는 `/api` 호출을 통해 각종 정보를 질의하는 방법을 알아보겠습니다.


## JSON 데이터 들여쓰기 `@0.5.0`
모든 응답 데이터는 [JSON](#JSON-데이터-형식) 형식이며 텍스트는 `utf8`로 인코딩되어 있습니다.

데이터는 줄바꿈과 공백 문자없이 최적화된 형식을 사용하는 것이 성능을 위해서 좋지만 사람이 읽기에는 불편합니다.
예를 들어, 아래와 같이 서버 시간대(timezone)를 얻기 위해 아래와 같이 요청하면
```ruby
GET /api/info?timezone
```
서버는 다음과 같이 줄바꿈과 공백 문자없이 최적화된 형식의 JSON 데이터를 반환합니다.
```jsx
{"timezone":{"name":"Asia/Seoul","bias":"+09:00"}}
```

개발자 편의를 위해 모든 TS-API에서 들여쓰기`indent`를 지정하여 읽기 편한 형식의 JSON 데이터를 응답하도록 할 수 있습니다.
`indent` 값의 범위는 0부터 8까지입니다.

예를 들어, 들여쓰기를 2로 지정하여 요청하면
```ruby
GET /api/info?timezone&indent=2
```
서버는 다음과 같이 공백 문자를 2개씩 들여쓰고 줄바꿈 문자를 넣어서 읽기 편한 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  }
}
```
물론 들여쓰기 값으로 원하는 숫자를 사용할 수 있으며 모든 TS-API에 동일한 방식으로 사용할 수 있습니다.
이 문서에서는 데이터의 항목들을 쉽게 읽을 수 있도록 들여쓰기를 2로 지정한 형식을 사용합니다.



## 세션 인증
서버는 클라이언트 프로그램(웹 브라우저)이 로그인 한 이후부터 로그아웃할 때까지 쿠키를 사용하여 HTTP 세션을 유지합니다. 세션이 유지되는 동안은 인증 정보를 서버가 유지하고 있으므로 클라이언트 프로그램(웹 브라우저)에서는 서버에 어떤 요청을 할 때마다 매번 로그인할 필요가 없습니다.

*이렇게 로그인하는 과정을 통칭하여 **세션 인증**이라고 부르겠습니다.*


### 로그인
여기서는 API를 사용하여 세션 인증하는 방법을 알아봅니다.
서버에서는 아래 코드와 같이 전통적인 URL 형식으로 로그인하는 Basic authentication 방식도 지원하고 있지만, 대부분의 최신 웹 브라우저에서 로그인 정보가 그대로 노출되는 보안상의 이유로 더 이상 지원하지 않고 있습니다.
````ruby
http://userid:password@host/path/to/
````

이런 이유로 다음과 같이 추가적인 로그인 방식을 제공합니다.
[사용자 인증](#사용자-인증)에서 사용했던 방법으로 사용자 아이디와 비빌번호를 암호화한 다음, 다음과 같이 `login=` 매개변수에 붙여서 사용합니다.
```ruby
GET /api/auth?login=ZGVtbzohMTIzNHF3ZXI%3D    # http://host 부분 생략함
```
로그인이 성공한 경우 서버는 HTTP 응답 코드 200을 반환합니다.

아래와 같이 `auth=`를 사용해도 동일하게 로그인할 수 있습니다.
```ruby
GET /api/auth?auth=ZGVtbzohMTIzNHF3ZXI%3D
```
`auth=` 매개변수는 앞으로 소개할 다양한 API에 사용될 수 있으며, 별도의 로그인 과정을 거치지 않고 서버에 어떤 요청을 하면서 사용자 인증 정보를 한꺼번에 전달하는 용도로 사용할 수 있습니다.



### 로그아웃
[세션 인증](#세션-인증)된 상태에서 다음과 같이 요청하면 세션이 종료됩니다.
```ruby
GET /api/auth?logout
```
세션이 종료된 상태에서는 서버는 인증이 필요한 요청에 대해 HTTP 응답 코드 401을 반환하여 인증이 필요함을 알립니다.



## 서버 정보 요청


### API 버전
이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
GET /api/info?apiVersion
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "apiVersion": "TS-API@0.3.0"
}
```


### 사이트 이름
서버의 사이트 이름을 얻기 위해 사용합니다. 서버가 여러 대일 경우 각각을 구분할 수 있는 이름을 부여해서 사용할 수 있습니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
GET /api/info?siteName
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "siteName": "우리집 서버"
}
```


### 서버 시간대
서버 측 표준 시간대(타임 존)를 얻을 수 있습니다.
클라이언트 측과 서버가 다른 시간대로 동작할 경우 구분하기 위해 사용합니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
GET /api/info?timezone
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "timezone": {
    "name": "Asia/Seoul",   // IANA 타임 존 이름
    "bias": "+09:00"        // UTC 오프셋
  }
}
```
`Asia/Seoul` 부분은 `IANA` 형식의 타임 존 이름이며, 해당 서버의 운영체제에 따라 [IANA 타임 존 이름](#https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) 대신 `UTC+09:00`와 같이 UTC 오프셋으로 표기될 수도 있습니다.


### 제품 정보
서버의 제품명과 버전 정보를 얻기 위해 사용합니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
GET /api/info?product
````
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
// TS-CMS인 경우:
{
  "product": {
    "name": "TS-CMS",               // 제품명
    "version": "v0.38.0 (64-bit)"   // 버전명
  }
}

// TS-NVR인 경우:
{
  "product": {
    "name": "TS-NVR",               // 제품명
    "version": "v0.35.0 (64-bit)"   // 버전명
  }
}

// TS-LPR인 경우:
{
  "product": {
    "name": "TS-LPR",               // 제품명
    "version": "v0.2.0A (64-bit)"   // 버전명
  }
}
```


### 라이센스 정보
서버에 설치된 라이센스 정보를 얻기 위해 사용합니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
GET /api/info?license
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
// 정품인 경우:
{
  "license": {
    "type": "genuine",         // 정품 라이센스
    "maxChannels": 36,         // 최대 사용할 수 있는 채널 수
    "nLprZone": 36,            // 차번 인식 영역 수 (TS-API@0.9.12)
    "nDevEmCall": 50,          // 비상 호출 비상벨 수 (TS-API@0.9.12)
    "nChObjDetection": 36,     // 객체 감지 채널 수 (TS-API@0.9.12)
    "nChFaceRecognition": 10,  // 얼굴 인식 채널 수 (TS-API@0.9.12)
    "nChTrafficCount": 10,     // 차량 통행량 집계 채널 수 (TS-API@0.9.12)
    "nChSpeedometer": 10,      // 차량 속도 측정 채널 (TS-API@0.9.12)
    "mediaType": "USB dongle", // 라이센스 미디어 종류 ("USB dongle" 또는 "Software") (TS-API@0.9.12)
    "extension": [             // 부가 기능
      "lprExt",                // 차량 번호 인식 장치 연동
      "emergencyCall"          // 비상 호출 장치 연동
    ]
  }
}

// 무료 평가판인 경우:
{
  "license": {
    "type": "trial",    // 무료 평가판
    "maxChannels": 16,  // 최대 사용할 수 있는 채널 수
    "trialDays": 30,    // 30일 무료 사용
    "leftDays": 15      // 15일 남음
  }
}
```

#### 부가 기능`extension` 목록
| `extension` | 설명     |
|-----------|------------|
| `lprExt`  | 차번 인식 |
| `emergencyCall`  | 비상 호출 |
| `lprKiosk`  | 키오스크 - 내 차 찾기 |
| `packing`  | 포장 API |
| `objectDetection`  | 객체 감지 |
| `faceRecognition`  | 얼굴 인식 |
| `sharedFrameBuffer`  | 공유 프레임 버퍼 `TS-API@0.9.7`| 


### 사용자 정보
로그인된 사용자 정보를 얻어오기 위해 사용됩니다.
이 요청은 [세션 인증](#세션-인증) 상태에서만 정상적으로 응답합니다.
여기서부터는 [세션 인증](#세션-인증)을 하기 위한 `auth=` 사용 부분은 생략하겠습니다. 
```ruby
GET /api/info?whoAmI
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
만약 [세션 인증](#세션-인증) 상태가 아니라면 서버는 HTTP 응답 코드 401 에러를 보냅니다.
```jsx
{
  "whoAmI": {
    "uid":"admin",      // 사용자 아이디
    "name":"admin",     // 사용자 이름
    "##COMMENT1": "---- NOTICE OF CHANGE --------------------------------------------",
    "##COMMENT2": "'accessRights' is deprecated and 'accessRights2' is used instead.",
    "##COMMENT3": "------------------------------------------------------------------",    
    // 0.5.0 이후 새 형식으로 변경됨 
    "accessRights2": {        // 사용자 권한
      "DataExport": true,     // 이미지, 동영상 받아내기
      "Control": true,        // 팬틸트, 릴레이 제어
      "Settings": true,       // 설정 변경
      "Playback": true,       // 녹화 데이터 보기
      "LPR": true,            // 차량 번호 조회
      "Remote": true          // 원격 접속
    },
    // 기존 형식은 삭제 예정이며 하위 호환성을 위해 유지함
    "accessRights": [
      "DataExport",
      "Control",
      "Settings",
      "Playback",
      "LPR",
      //"SearchEdit",   // 0.5.0 이후 삭제됨 (Playback 권한으로 대체됨)
      "Remote"
    ]
  }
}
```


### 모두 한 번에 요청
각각 정보를 개별적으로 요청할 수도 있지만, 편의상 모든 정보를 한 번에 요청하는 방법도 제공합니다.
```ruby
GET /api/info?all
```
이 요청은 세션 인증 상태인 경우는 HTTP 응답 코드 200과 함께 JSON 데이터를 반환하며, 인증이 되지 않은 경우는 HTTP 응답 코드 401과 함께 `"whoAmI"` 항목이 빠진 JSON 데이터를 반환합니다.
```jsx
// 세션 인증된 상태 (HTTP 응답 코드: 200):
{
  "apiVersion": "TS-API@0.3.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
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

// 세션 인증 안된 상태 (HTTP 응답 코드: 401):
{
  "apiVersion": "TS-API@0.3.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
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
  }     // whoAmI 부분 없음
}
```


## 시스템 정보 요청 `@0.3.0`
서버의 시스템 정보를 요청합니다.
```ruby
GET /api/system?info
GET /api/system   # 생략 가능
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
*@0.7.0에서 disk 데이터 형식 수정됨*
```jsx
{
  "lastUpdate": "2018-09-15T13:49:12.440+09:00",
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

또는 아래와 같이 개별 항목을 지정해서 요청할 수 있습니다.
```ruby
GET /api/system?info=supported  # 지원하는 항목 목록 요청
```
지원하는 항목 목록 요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
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

### 개별 항목 요청
```ruby
GET /api/system?info=os   # OS만 요청
GET /api/system?info=cpu  # CPU만 요청
GET /api/system?info=storage,network  # storage와 network항목을 요청

GET /api/system?info=all  # 모든 항목을 요청 (간단히 /api/system?info 또는 /api/system)
```



## 시스템 상태 요청 `@0.3.0`
서버의 시스템 상태를 요청합니다.
```ruby
GET /api/system?health
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
*@0.7.0에서 cpu 데이터 형식 수정됨*
```jsx
{
  "lastUpdate": "2018-09-15T13:49:12.440+09:00",
  "cpu": [
    {                         # 첫번째 CPU
      "temperatureKelvin": {  # 절대온도(Kelvin) 단위
        "critical": 393.2,    # 한계 온도 (이 온도에 도달하면 시스템을 종료해야 함)
        "current": 287.2      # 현재 온도
      },
      "usage": {
        "threads": [
          37,                 # 첫번째 CPU의 첫번째 쓰레드 사용률
          19,                 # 첫번째 CPU의 두번째 쓰레드 사용률
          50,
          6,
          19,
          31,
          31,
          12
        ],
        "total": 26           # 첫번째 CPU 총 사용률
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
        "comment": "사용 안함",
        "path": "D:\\recData\\",
        "usage": -1
      },
      {
        "comment": "덮어 쓰기",
        "path": "E:\\recData\\",
        "usage": 2
      }
    ]
  },
  "network": [
    {
      "name": "Intel[R] Dual Band Wireless-AC 3160",
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

`recording` 항목 중 `storage` 아래 `usage` 값은 다음 중 하나입니다.
```ruby
-1    # 사용 안함
0     # 읽기 전용
1     # 한 번 녹화
2     # 덮어 쓰기
```


또는 아래와 같이 개별 항목을 지정해서 요청할 수 있습니다.
```ruby
GET /api/system?health=supported  # 지원하는 항목 목록 요청
```
지원하는 항목 목록 요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  "cpu",
  "memory",
  "disk",       // 마운트된 논리적 디스크(디스크 파티션)을 의미, @0.6.0에 추가됨
  "recording",  // 녹화용 스토리지 상태, @0.7.0에 추가됨
  "network",
  "all"
]
```

### 개별 항목 요청
```ruby
GET /api/system?health=os   # OS만 요청
GET /api/system?health=cpu  # CPU만 요청
GET /api/system?health=disk,recording,network  # disk, recording, network 항목을 요청
GET /api/system?health=all  # 모든 항목을 요청 (간단히 /api/system?health)
```


## HDD S.M.A.R.T. 요청 `@0.6.0`
서버 각 하드 디스크의 S.M.A.R.T. 정보를 요청합니다.
```ruby
GET /api/system?hddsmart    # 모든 하드 디스크의 S.M.A.R.T. 정보를 요청
GET /api/system?hddsmart=1  # 첫번째 하드 디스크의 S.M.A.R.T. 정보를 요청
GET /api/system?hddsmart=1,2  # 첫번째와 두번째 하드 디스크의 S.M.A.R.T. 정보를 요청
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "code": 1,          // S.M.A.R.T. 지원 여부 (-1:아직 테스트 안됨, 0:지원안됨, 1:지원)
    "message": "지원",
    "model": "SanDisk SD9SB8W512G1122",
    "name": "\\\\.\\PHYSICALDRIVE0",
    "smart": [
      {
        "attribute": "Reallocated Sector Count",
        "critical": true,
        "id": 5,
        "raw": 100,
        "rawHex": "000000000064",   // TS-API@0.9.13에 추가됨 (raw의 16진수 표기)
        "threshold": 0,
        "value": 0,
        "worst": 100
      },
      {
        "attribute": "Power-On Time Count",
        "critical": false,
        "id": 9,
        "raw": 100,
        "rawHex": "000000000064",   // TS-API@0.9.13에 추가됨 (raw의 16진수 표기)
        "threshold": 0,
        "value": 1819,
        "worst": 100
      },
      // ... 중략
    ]
  }
]
```


## 서버 재시작 요청 `@0.6.0`
관리자 권한을 가진 계정으로 로그인 한 경우, 서버 프로세스를 재시작 시킬 수 있습니다.
```ruby
GET /api/system?restart
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
  {
    "code": 0,
    "message": "서버가 수 초 내로 다시 시작됩니다."
  }
```
관리자 권한이 없는 경우에 대해 서버는 HTTP 응답 코드 403 (FORBIDDEN)을 반환합니다.


## 시스템 재부팅 요청 `@0.6.0`
관리자 권한을 가진 계정으로 로그인 한 경우, 서버 시스템을 재부팅 시킬 수 있습니다.
```ruby
GET /api/system?reboot
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
  {
    "code": 0,
    "message": "1 분 안에 시스템이 종료된 후 다시 시작됩니다."
  }
```
관리자 권한이 없는 경우에 대해 서버는 HTTP 응답 코드 403 (FORBIDDEN)을 반환합니다.



## 채널 상태 요청 `@0.3.0`
서버의 각 채널 상태를 요청합니다.
```ruby
GET /api/status
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
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
  // ... 중략
]
```

필요한 경우, 아래 매개변수를 사용할 수 있습니다.
```ruby
# 매개변수
ch        # 채널 번호 (여러 채널을 동시에 지정할 경우 쉼표 문자(,)로 구분)
verbose   # 상태 코드에 해당하는 메시지 요청
lang      # 메시지에 사용될 언어 지정
recordingStatus # 현재 녹화 상태  (@0.9.5부터 지원)

# 예제
# 3번 채널만 지정
GET /api/status?ch=3

# 1~4번 채널만 지정
GET /api/status?ch=1,2,3,4

# 상태 메시지를 포함 (lang을 명시하지 않으면 서버 측 언어 설정을 따름)
GET /api/status?verbose=true

# 상태 메시지를 스페인어로 포함
GET /api/status?verbose=true&lang=es-ES

# 모든 채널의 녹화 상태를 요청
GET /api/status?recordingStatus

# 1~4번 채널의 녹화 상태를 요청
GET /api/status?ch=1,2,3,4&recordingStatus
```

메시지를 포함하여 요청하면 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,
    "status": {
      "code": 200,
      "message": "연결됨"
    }
  },
  {
    "chid": 2,
    "status": {
      "code": 200,
      "message": "연결됨"
    }
  },
  {
    "chid": 3,
    "status": {
      "code": 200,
      "message": "연결됨"
    }
  },
  {
    "chid": 4,
    "status": {
      "code": 200,
      "message": "연결됨"
    }
  },
  // ... 중략
]
```

전체 상태 코드 목록은 다음과 같습니다.
```ruby
-5    # 재부팅 중
-4    # 재접속 중
-3    # 접속 중
-2    # 로딩 중
-1    # 사용 안함
0     # 응답 없음
1     # 사용함
2     # 동영상 있음
200   # 연결됨
401   # 카메라 로그인 실패
403   # 카메라 차단됨
404   # 네트워크 접속 안됨
408   # 카메라 응답 시간 초과
410   # 영상 입력 없음
503   # 카메라 서비스 오류
1000  # 동영상 재생 완료, TS-API@0.9.7
1404  # 파일 없음, TS-API@0.9.7
```

녹화 상태를 포함하여 요청하면 아래와 같은 형식의 JSON 데이터를 반환합니다.
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
      // 녹화 장애 발생 시각 (이 값은 장애 상태에만 명시됨)
      "timestampRecordingFailure":"2020-03-25T10:07:09.646+09:00"
    }
  },
  // ... 중략
]
```


## 각종 목록 요청
다음 요청들은 `auth=`를 사용하여 로그인 정보를 전달하거나 이미 로그인된 세션의 경우는 HTTP 응답 코드 200과 함께 JSON 데이터를 반환하며, 로그인 인증이 되지 않은 경우는 HTTP 응답 코드 401이 반환합니다.


### 채널 목록 `@0.9.4`
사용 중인 채널 목록을 얻기 위해 아래와 같이 요청합니다.
```ruby
GET /api/enum?what=channel
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,            // 채널 번호
    "title": "카메라1",     // 채널 이름
    "displayName": "CH1. 카메라1"  // TS-API@0.9.4 이후 추가됨 ("ptzSupported" 항목 삭제됨)
  },
  {
    "chid": 2,            // 채널 번호
    "title": "",          // 채널 이름
    "displayName": "CH2"  // TS-API@0.9.4 이후 추가됨
  }
]
```

#### 스트림 목록 추가하기 `@0.9.4`
스트림 목록을 함께 얻으려면 `staticSrc` 매개변수를 추가합니니다.
이 스트림들은 카메라 접속 상태에 따라 가용하지 않을 수도 있습니다.
```ruby
GET /api/enum?what=channel&staticSrc
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,
    "title": "카메라1",
    "displayName": "CH1. 카메라1",
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
  // 중략
]
```

#### 카메라 지원 기능 추가하기 `@0.9.4`
카메라 지원 기능 목록을 함께 얻으려면 `caps` 매개변수를 추가합니니다.
```ruby
GET /api/enum?what=channel&caps
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,
    "title": "카메라1",
    "displayName": "CH1. 카메라1",
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


### 차량 번호 인식 장치 목록
사용 중인 차량 번호 인식 장치 목록을 얻기 위해 아래와 같이 요청합니다.
차량 번호 인식 장치 목록에는 차량 번호 인식 장치 연동 기능을 사용하는 경우는 해당 장치들이 포함되고, 차량 번호 인식 기능이 내장된 TS-LPR의 경우는 설정된 차량 번호 인식 영역들이 포함됩니다.

```ruby
GET /api/enum?what=lprSrc
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  // 연동된 차량 번호 인식 장치로부터 수신한 정보
  {
    "id": 1,                  // 장치 번호
    "code": "F00001",         // 장치 코드
    "name": "F00001",         // 장치 이름
    "linkedChannel": [        // 트리거 발생 시 연동되는 채널 목록
      1,
      2
    ],
    "tag": "Normal"           // 상태 (Normal: 사용중인 채널, NotUsed: 사용 안하는 채널, ReadOnly: 읽기 전용 채널)
  },

  // TS-LPR의 경우 차량 번호 인식 영역에 의해 인식된 정보
  {
    "id": 2,                  // 장치 번호
    "code": "1-1-1",          // 장치 코드
    "name": "1-1-1",          // 장치 이름
    "linkedChannel": [],      // 트리거 발생 시 연동되는 채널 목록 (추가 연동 채널이 없는 경우 비어있음)
    "tag": "Normal",          // 상태 (Normal: 사용중인 채널, NotUsed: 사용 안하는 채널, ReadOnly: 읽기 전용 채널)
    "zone": {                 // 인식 영역
      "id": 0,                // 영역 번호
      "chid": 1,              // 채널 번호
      "rect": [               // 영역 좌표
        2622, 1499,           // 사각형 테두리의 왼쪽 위 좌표 (x0,y0) 
        4297, 4297            // 사각형 테두리의 오른쪽 아래 좌표 (x1,y1) 
      ],
      "mode": "driving",      // 번호 인식 동작 모드 (driving: 주행 모드, parking: 주차 모드)
      "disabledOnly": false,  // 장애인 전용 주차면일 경우 true, 아니면 false
      "noParkingAllowed": false // 주차 금지 구역일 경우 true, 아니면 false
    },
    "parkingLot": {           // 연결된 주차장 id (TS-API@0.9.8)
      "entrance": 1,          // 주차장 입구 id
      "exit": 2               // 주차장 출구 id
    }
  }
]

// 여기서,
// zone의 rect를 표현하는 좌푯값은 다양한 실제 해상도와 무관하게 영상 위의 위치를
// 표현하기 위해 논리적 좌표계 8K(7680x4320)를 기준으로 물리적 좌표계(실제 영상의
// 해상도)를 비례식으로 계산한 값을 사용합니다.
// 예를 들어, 1920x1080 영상에서 사각형 영역의 좌표가 (480, 270, 1440, 810)일 경우 
// 각각 가로 좌표에는 7680/1920을 곱하고, 세로 좌표에는 각각 4320/1080을 곱해서
// (1920, 1080, 5760, 3240)으로 표현합니다.
```


### 비상 호출 장치 목록 `@0.3.0`
서버에 등록된 비상 호출 장치 목록을 얻기 위해 아래와 같이 요청합니다.

```ruby
GET /api/enum?what=emergencyCall
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  // 등록된 비상 호출 장치 목록
  {
    "id": 1,                  // 장치 번호
    "code": "0000001",        // 위치 코드
    "name": "B1 계단",        // 장치 이름
    "linkedChannel": [        // 트리거 발생 시 연동되는 채널 목록
      1,
      2
    ],
  },
  // ... 중략
]
```


### 이벤트 로그 종류 목록
지원하는 이벤트 로그 종류 목록을 얻으려면 다음과 같이 요청합니다.
```ruby
GET /api/enum?what=eventType
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "id": 0,                  // 이벤트 로그 유형 번호
    "name": "시스템 로그",     // 이벤트 로그 유형 이름
    "code": [                 // 이벤트 로그 코드 목록
      {
        "id": 1,              // 이벤트 로그 코드 번호
        "name": "시스템 시작"  // 이벤트 로그 코드 이름
      },
      {
        "id": 2,
        "name": "시스템 종료"
      },
      // ... 중략
  },
  {
    "id": 6,
    "name": "사용자 정의 이벤트"
  }
]
```
이처럼 이벤트 로그 종류 목록은 유형별로 코드가 정의되어 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우, 아래 매개변수를 사용하여 언어를 변경할 수 있습니다.
```ruby
# 매개변수
lang      # 언어

# 예제
# 영어로 요청한 경우
GET /api/enum?what=eventType&lang=en-US
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "id": 0,
    "name": "System log",
    "code": [
      {
        "id": 1,
        "name": "System startup"
      },
      {
        "id": 2,
        "name": "System shutdown"
      },
      {
        "id": 3,
        "name": "Abnormal shutdown"
      },
      // ... 중략
  },
  {
    "id": 6,
    "name": "User-defined event"
  }
]
```


### 주차장 목록 `@0.9.8`
서버에 등록된 주차장 목록을 얻으려면 다음과 같이 요청합니다.
```ruby
GET /api/enum?what=parkingLot
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "counter:": [
    {
      "id": 1,
      "name": "B1 주차장",
      "type": "counter"     // 주차 구역 (입출차 카운터)
      "count": 3,           // 현재 입차 수 
      "maxCount": 50,       // 최대 주차 수
    },
    {
      "id": 2,
      "name": "B2 주차장",
      "type": "counter"     // 주차 구역 (입출차 카운터)
      "count": 25,          // 현재 입차 수 
      "maxCount": 40,       // 최대 주차 수
    }
  ],
  "group": [
    {
      "id": 3,
      "name": "지하주차장",
      "type": "group",      // 그룹 (주차 구역의 집합)
      "count": 28,          // 현재 입차 수 합계
      "maxCount": 90,       // 최대 주차 수 합계
      "member": [           // 그룹 멤버 id
        1,
        2
      ]
    }
  ]
}
```

### 수신 가능한 실시간 이벤트 목록 `@0.9.6`
서버에서 제공하는 실시간 이벤트 종류를 얻으려면 다음과 같이 요청합니다.
```ruby
GET /api/enum?what=realtimeEvent
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
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

### 지원하는 객체 목록 `@0.9.11`
서버에서 지원하는 객체 종류를 얻으려면 다음과 같이 요청합니다.
```ruby
GET /api/enum?what=objectType
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  "face",
  "human",
  "vehicle"
]
```

### 지원하는 객체별 속성 목록 `@0.9.11`
서버에서 지원하는 객체별 속성을 얻으려면 다음과 같이 요청합니다.
```ruby
GET /api/enum?what=objectAttr&type=face  # 얼굴 객체의 속성
GET /api/enum?what=objectAttr            # type을 명시하지 않으면 모든 객체별 속성
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.

얼굴 객체의 속성을 요청한 경우:
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

모든 객체의 속성을 요청한 경우:
```jsx
{
  "face": {
    "age": [
      "young",
      "adult",
      "middle",
      "senior"
    ],
    // ... 중략
  },
  "human": {
    "bag": [
      true,
      false
    ],
     // ... 중략
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
    // ... 중략
  }
}
```


## 저장 데이터 검색

녹화데이터를 검색하기 위해서는 `/api/find`를 사용합니다.

### 녹화 영상이 있는 날짜 검색
녹화된 영상이 있는 날짜 목록을 얻기 위해 다음과 같이 요청합니다.

```ruby
GET /api/find?what=recDays      // 녹화된 영상이 있는 모든 날짜를 요청
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "timeBegin": "2018-01-01T00:00:00+09:00",     // 처음 날짜, 시각 (서버의 로컬 타임)
  "timeEnd": "2018-02-28T23:59:59.999+09:00",   //  마지막 날짜, 시각 (서버의 로컬 타임)
  "data": [
    {
      "year": 2018,
      "month": 1,
      "days": [ // YYYY-MM 형식으로 데이터가 존재하는 날짜를 배열로 표시
        8,        // 2018-1-18  녹화 데이터 있음
        23,       // 2018-1-23  녹화 데이터 있음
        24        // 2018-1-24  녹화 데이터 있음
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
  ]
}
```
아래와 같은 매개변수를 추가하여 특정 조건에 해당하는 결과를 요청할 수 있습니다.
```ruby
# 매개변수
ch          # 특정 채널이 녹화된 날짜 목록 
            # (여러 채널은 쉼표를 사용하여 나열)
timeBegin   # 특정 날짜, 시각 이후 녹화된 날짜 목록
timeEnd     # 특정 날짜, 시각 이전 녹화된 날짜 목록
            # (UTC 타임으로 요청하면 UTC를 기준으로한 날짜가 반환되며, 
            # 그렇지 않으면 서버의 로컬 타임을 기준으로하는 날짜가 반환됨)

# 예제
# 1번 채널이 녹화된 날짜 목록 요청
GET /api/find?what=recDays&ch=1
# 1,2,3번 채널이 녹화된 날짜 목록 요청
GET /api/find?what=recDays&ch=1,2,3

# 2018년 2월 (2018-02-01T00:00:00+09:00) 이후 녹화된 날짜 목록
GET /api/find?what=recDays&timeBegin=2018-02-01T00%3A00%3A00%2B09%3A00

# 2018년 1월 중에 녹화된 날짜 목록
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
GET /api/find?what=recDays&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 2018년 1번 채널이 1월 중에 녹화된 날짜 목록
GET /api/find?what=recDays&ch=1&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00
```

`ch`, `timeBegin` 또는 `timeEnd`와 같은 매개변수를 사용하여 조건을 지정한 경우는 아래와 같이 요청받은 시간을 포함하여 결과가 반환됩니다.
```jsx
{
  "timeBegin": "2018-01-01T00:00:00+09:00",     // 처음 날짜, 시각 (서버의 로컬 타임)
  "timeEnd": "2018-01-31T23:59:59.999+09:00",   //  마지막 날짜, 시각 (서버의 로컬 타임)
  "data": [
    {
      "chid": 1,   // 채널 번호
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
        // ... 중략
      ]
    }
  ]
}
```


### 녹화 영상이 있는 분 단위 검색 `@0.2.0`
녹화된 영상이 있는 분 단위 목록을 얻기 위해 다음과 같이 요청합니다.
분 단위 검색 경우는 날짜 검색과 달리 응답 데이터량이 클 수 있으므로 전체를 모두 요청할 수 없으며 반드시 시간을 명시해야 합니다.
timeBegin 또는 timeEnd 중 하나만 지정하면 저정한 날짜로 부터 하루 동안의 검색 결과를 반환합니다. 지정할 수 있는 날짜 범위는 최대 3일로 제한됩니다.
사용할 수 있는 매개변수들은 `/api/find?what=recDays`와 동일합니다.
```ruby
# 로컬 타임을 사용하는 경우
GET /api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00%2B09%3A00&timeEnd=2018-02-02T00%3A00%3A00%2B09%3A00

# UTC 타임을 사용하는 경우
GET /api/find?what=recMinutes&timeBegin=2018-05-25T00%3A00%3A00Z&timeEnd=2018-05-26T00%3A00%3A00Z
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.

```jsx
{
  "timeBegin": "2018-05-25T00:00:00.000+09:00",
  "timeEnd": "2018-05-26T00:00:00.000+09:00",
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


### 이벤트 로그 검색
서버에 기록된 이벤트 로그를 검색하기 위해서는 다음과 같이 요청합니다.
```ruby
GET /api/find?what=eventLog
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "totalCount": 513,    // 서버에 기록된 총 이벤트 로그 개수
  "at": 0,              // 데이터 오프셋 표시 (0이므로 첫 번째 위치의 데이터를 의미함)
  "data": [             // 이벤트 로그 데이터 목록
    {
      "id": 518,                        // 이벤트 로그 번호
      "type": 0,                        // 이벤트 로그 유형 번호
      "typeName": "시스템 로그",         // 이벤트 로그 유형 이름
      "code": 25,                       // 이벤트 로그 코드 번호
      "codeName": "저장 장치 준비 완료",  // 이벤트 로그 코드 이름
      "timeRange": [
        "2018-02-19T18:24:26.002+09:00" // 발생 시각 (일정 기간 연속적으로 발생한 이벤트는 배열의 두 번 째 항목에 종료 시각이 포함됨)
      ],
      "param": {                            // 이벤트 로그 코드별 추가 정보
        "storagePath": "E%3A%5CrecData%5C", // 녹화용으로 사용할 스토리지 경로
        "statusCode": 0                     // 스토리지 상태 코드
      }
    },
    {
      "id": 517,
      "type": 1,
      "typeName": "개인 정보",
      "code": 4,
      "codeName": "로그인",
      "timeRange": [
        "2018-02-19T18:24:20.249+09:00"
      ],
      "param": {
        "uid": "admin",
        "autoLogin": 1
      },
      "comment": "admin: 자동 로그인" // 옵션
    },
    // ... 중략
    {
      "id": 469,
      "type": 0,
      "typeName": "시스템 로그",
      "code": 27,
      "codeName": "라이센스 적용",
      "timeRange": [
        "2018-02-19T12:11:08.680+09:00"
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
      "comment": "정품 라이센스"  // 옵션
    }
  ]
}
```
서버에 기록된 이벤트 로그는 대량의 데이터이므로 모두 한꺼번에 전송하기 적합하지 않습니다. 이 때문에 개수를 명시하지 않을 경우 가장 최근 것부터 최대 50개까지만 로그 항목을 반환합니다.
`totalCount`, `at` 그리고 다음에 언급할 `maxCount`를 사용하여 검색 결과 페이지 단위로 표현할 수 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우 아래와 같은 매개변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.
```ruby
# 매개변수
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 이벤트 목록
timeEnd     # 특정 날짜, 시각 이전에 기록된 이벤트 목록
at          # 데이터 오프셋
maxCount    # 최대 항목 개수
sort        # 정렬 방식 (desc: 최신 데이터 순(기본값), asc: 오래된 데이터 순)
type        # 이벤트 로그 유형

# 예제
# 아랍어로 요청한 경우
GET /api/find?what=eventLog&lang=ar-AE

# 2018년 1월 동안 기록된 이벤트 로그 요청
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
GET /api/find?what=eventLog&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 검색 결과의 10번째 항목부터 20개를 요청
GET /api/find?what=eventLog&at=10&maxCount=20

# 오래된 데이터 순(오름차순)으로 정렬하여 요청
GET /api/find?what=eventLog&sort=asc

# 시스템 로그 유형 id 목록 요청
GET /api/enum?what=eventType

# 이벤트 로그 유형 중 시스템 로그(id: 0)만 요청
GET /api/find?what=eventLog&type=0

```



### 차량 번호 로그 검색
차량 번호 인식 기능을 사용하는 경우 인식된 차량 번호는 해당 동영상과 함께 저장됩니다. 차량 번호 로그를 조회하기 위해서는 다음과 같이 요청합니다.

```ruby
GET /api/find?what=carNo
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "totalCount": 64,   // 서버에 기록된 전체 차량 번호 로그 개수
  "at": 0,            // 데이터 오프셋 표시 (0이므로 첫 번째 위치의 데이터를 의미함)
  "data": [           // 차량 번호 로그 데이터 목록
    {
      "id": 64,                           // 차량 번호 로그 번호
      "plateNo": "13다5939",              // 차량 번호 텍스트
      "score":98,                         // 인식 점수 (100점 만점): 차번인식 엔진에 따라 지원하지 않을 수 있음 (항목 없을 수 있음)
      "roi": {                            // 번호판 이미지 영역
        "offset": [943,635],              // 좌상단 좌표
        "size": [132,31]                  // 번호판 이미지 크기
      },
      "image": [                          // 동일 번호판이 연속으로 저장된 경우를 위해 배열로 표현함 (항목 없을 수 있음)
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732385942440.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386146439.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386199445.plate.jpg",
        "http://192.168.0.100/storage/e/0/0/0/39/39589.161142.1576732386510078.plate.jpg"
      ],
      "timeRange": [                      // 차량 번호 인식 날짜, 시각
        "2018-02-21T09:07:29.000+09:00",  // 시작 시점
        "2018-02-21T09:07:34.057+09:00"   // 종료 시점
      ],
      "srcCode": "1-1-1",                 // 차량 번호 인식 장치 (또는 영역) 코드
      "srcName": "정문 입구",              // 차량 번호 인식 장치 (또는 영역) 이름
      "vod": [  // 인식된 시점의 영상 (연동 채널이 설정된 경우 여러 개가 될 수 있음)
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D21T09%3A07%3A29%2E000%2B09%3A00"
        },
        {
          "chid": 2,
          "videoSrc": "http://192.168.0.100/watch?ch=2&when=2018%2D02%2D21T09%3A07%3A29%2E000%2B09%3A00"
        },
        {
          "chid": 3,
          "videoSrc": "http://192.168.0.100/watch?ch=3&when=2018%2D02%2D21T09%3A07%3A29%2E000%2B09%3A00"
        },
        {
          "chid": 4,
          "videoSrc": "http://192.168.0.100/watch?ch=4&when=2018%2D02%2D21T09%3A07%3A29%2E000%2B09%3A00"
        }
      ]
    },
    {
      "id": 63,
      "plateNo": "02루2841",
      "score":95,
      "roi": {
        "offset": [753,578],
        "size": [150,38]
      },
      "image": [
        "http://192.168.0.100/storage/e/0/0/0/39/39588.161141.1576732012342440.plate.jpg"
      ],
      "timeRange": [
        "2018-02-21T08:00:00.915+09:00",
        "2018-02-21T08:00:01.714+09:00"
      ],
      "srcCode": "1-1-1",
      "srcName": "1-1-1",
      "vod": [
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D21T08%3A00%3A00%2E915%2B09%3A00"
        },
        {
          "chid": 2,
          "videoSrc": "http://192.168.0.100/watch?ch=2&when=2018%2D02%2D21T08%3A00%3A00%2E915%2B09%3A00"
        },
        {
          "chid": 3,
          "videoSrc": "http://192.168.0.100/watch?ch=3&when=2018%2D02%2D21T08%3A00%3A00%2E915%2B09%3A00"
        },
        {
          "chid": 4,
          "videoSrc": "http://192.168.0.100/watch?ch=4&when=2018%2D02%2D21T08%3A00%3A00%2E915%2B09%3A00"
        }
      ]
    },
    // ... 중략
    {
      "id": 15,
      "plateNo": "64다3736",
      "roi": {
        "offset": [832,380],
        "size": [122,31]
      },
      "timeRange": [
        "2018-02-20T18:12:05.828+09:00",
        "2018-02-20T18:12:06.253+09:00"
      ],
      "srcCode": "1-1-1",
      "srcName": "1-1-1",
      "vod": [
        {
          "chid": 1,
          "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00"
        }
      ]
    }
  ]
}
```

서버에 기록된 차량 번호 로그는 대량의 데이터이므로 모두 한꺼번에 전송하기 적합하지 않습니다. 이 때문에 개수를 명시하지 않을 경우 가장 최근 것부터 최대 50개까지만 로그 항목을 반환합니다.
totalCount, at 그리고 다음에 언급할 maxCount를 사용하여 검색 결과를 페이지 단위로 표현할 수 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우 아래와 같은 매개변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.


```ruby
# 매개변수
keyword     # 검색할 차량 번호 (또는 일부 문자)
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 차량 번호 목록
timeEnd     # 특정 날짜, 시각 이전에 기록된 차량 번호 목록
at          # 데이터 오프셋
maxCount    # 최대 항목 개수
sort        # 정렬 방식 (desc: 최신 데이터 순(기본값), asc: 오래된 데이터 순)
src         # 차량 번호 인식 장치 id (여러 장치를 동시에 지정할 경우 쉼표 문자(,)로 구분)

# 예제
# "12"가 포함된 차량 번호를 검색 (키워드 검색)
GET /api/find?what=carNo&keyword=12

# 아랍어로 요청한 경우
GET /api/find?what=carNo&lang=ar-AE

# 2018년 1월 동안 기록된 이벤트 로그 요청
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
GET /api/find?what=carNo&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 검색 결과의 10번째 항목부터 20개를 요청
GET /api/find?what=carNo&at=10&maxCount=20

# 오래된 데이터 순(오름차순)으로 정렬하여 요청
GET /api/find?what=carNo&sort=asc

# 차량 번호 인식 장치 1, 2를 지정해서 검색
GET /api/find?what=carNo&src=1,2
```

검색된 결과 데이터에 있는 동영상을 표시하기 위해서는 [녹화 영상 표시](#녹화-영상-표시)에서 사용했던 방법을 쓰면 됩니다.

예를 들어, 검색 결과 중 동영상을 표시하고자 하는 항목이 다음과 같다면 
```jsx
  // ... 중략
  {
    "id": 15,
    "plateNo": "64다3736",
    "timeRange": [
      "2018-02-20T18:12:05.828+09:00",
      "2018-02-20T18:12:06.253+09:00"
    ],
    "srcCode": "1-1-1",
    "srcName": "1-1-1",
    "vod": [
      {
        "chid": 1,
        "videoSrc": "http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00"
      }
    ]
  }
  // ... 중략
```
여기서 `"vod"` 아래 `"videoSrc"`의 값에 해당하는 `http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00`을 사용하여 영상을 표시할 수 있습니다.

```ruby
# 세션 인증된 경우 그대로 사용
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00

# 세션 인증된 안된 경우는 auth 매개변수를 추가
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00&auth=ZGV2MTpkZXZlbG9wZXIhMTIzNA==
```


### 유사 차량 번호 검색 `@0.2.0`
유사한 차량 번호가 존재하는지 확인하기 위해 사용할 수 있습니다. 인식된 차량 번호 로그에서 유사한 차량 번호를 조회하기 위해서는 다음과 같이 요청합니다.

```ruby
GET /api/find?what=similarCarNo&keyword=1234

# 매개변수
keyword     # 검색할 차량 번호 (또는 일부 문자)
maxCount    # 최대 항목 개수

# 예제
# 최대 10개까지 결과를 요청
GET /api/find?what=similarCarNo&keyword=1234&maxCount=10
```

요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  "11가1234",
  "12바1234",
    // ... 중략
]
```


### 객체 검색 `@0.9.11`
객체 감지 기능을 사용하는 경우 감지된 객체들(`face`, `human`, `vehicle`)은 해당 동영상과 함께 저장됩니다. 객체 로그를 조회하기 위해서는 다음과 같이 요청합니다.

```ruby
GET /api/find?what=object
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "totalCount": 100,
  "at": 0,
  "data": [
    {
      "timestamp": "2020-05-25T14:58:15.819+09:00",
      "chid": 1,               # 채널 번호
      "objId": 837,            # 객체 id (id가 같으면 동일 객체로 구분함)
      "type": "face",          # 객체 종류 (얼굴)
      "likelihood": 82.59      # 정확도 (%)
      "attributes": {          # 객체 속성
        "gender": "female",    # 성별 (여자)
        "age": "middle",       # 나이 (중년)
        "glasses": true,       # 안경 (착용)
        "mask": false          # 마스크 (미착용)
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412659.1590386295819221.object._c1_t2_s392x504.jpg" # 이미지 주소
    },
    {
      "timestamp": "2020-05-25T14:58:14.449+09:00",
      "chid": 1,               # 채널 번호
      "objId": 842,            # 객체 id (id가 같으면 동일 객체로 구분함)
      "type": "face",          # 객체 종류 (얼굴)
      "likelihood": 90.09,     # 정확도 (%)
      "attributes": {          # 객체 속성
        "gender": "male",      # 성별 (남자)
        "hat": true            # 모자 (착용)
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412660.1590386294449281.object._c1_t2_s744x624.jpg" # 이미지 주소
    },
    {
      "timestamp": "2020-05-25T14:58:14.185+09:00",
      "chid": 1,               # 채널 번호
      "objId": 834,            # 객체 id (id가 같으면 동일 객체로 구분함)
      "type": "human",         # 객체 종류 (사람)
      "likelihood": 62.20,     # 정확도 (%)
      "attributes": {          # 객체 속성
        "gender": "male",      # 성별 (남자)
        "clothes": [           # 옷
          {
            "type": "tops",    # 상의
            "length": "long",  # 소매 길이
            "colors": [        # 색상
              "red"
            ]
          },
          {
            "type": "bottoms", # 하의
            "length": "long",  # 바지 길이
            "colors": [        # 색상
              "red"
            ]
          }
        ]
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673911/7673911.4412658.1590386294185653.object._c1_t1_s296x464.jpg" # 이미지 주소
    },
    {
      "timestamp": "2020-05-25T14:55:21.557+09:00",
      "chid": 1,               # 채널 번호
      "objId": 748,            # 객체 id (id가 같으면 동일 객체로 구분함)
      "type": "vehicle",       # 객체 종류 (차량)
      "likelihood": 95.80,     # 정확도 (%)
      "attributes": {          # 객체 속성
        "vehicleType": "Car",  # 차량 종류 (승용차)
        "colors": [            # 색상
          "gray"
        ]
      },
      "image": "http://host/storage/e/0/0/7/7673/object/7673909/7673909.4412630.1590386121557955.object._c1_t3_s440x312.jpg" # 이미지 주소
    },
    // ... 중략
  ]
}
```

검색 결과의 `data` 항목의 내용은 [객체 감지 이벤트 `@0.9.11`](#객체-감지-이벤트-0911)의 내용과 동일합니다.

또한 아래와 같이 각 객체별 속성을 지정하여 조건 검색할 수 있습니다.

#### 공통 매개변수
```ruby
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 객체 목록
timeEnd     # 특정 날짜, 시각 이전에 기록된 객체 목록
ch          # 채널 번호, 콤마(,) 사용해서 복수 표기 가능
objectType  # 객체 종류 (face, human, vehicle 중 하나, 지정하지 않으면 모든 종류의 객체를 의미함)
at          # 데이터 오프셋
maxCount    # 최대 항목 개수
sort        # 정렬 방식 (desc: 최신 데이터 순(기본값), asc: 오래된 데이터 순)


# 2020년 1월 동안 저장된 객체 요청
# (2020-01-01T00:00:00+09:00 ~ 2020-01-31T23:59:59.999+09:00)
GET /api/find?what=object&timeBegin=2020-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2020-01-31T23%3A59%3A59.999%2B09%3A00

# 1, 2번 채널의 객체만 요청
GET /api/find?what=object&ch=1,2

# face 객체만 요청
GET /api/find?what=object&objectType=face

# 검색 결과의 10번째 항목부터 20개를 요청
GET /api/find?what=object&at=10&maxCount=20

# 오래된 데이터 순(오름차순)으로 정렬하여 요청
GET /api/find?what=object&sort=asc
```

#### face용 매개변수
```ruby
gender       # 성별 지정 (male, female 중 하나)
age          # 나이 구분 (young, adult, middle, senior 중 하나)
hat          # 모자 착용 여부 (true, false 중 하나, 또는 0, 1 중 하나)
glasses      # 안경 착용 여부 (true, false 중 하나, 또는 0, 1 중 하나)
mask         # 마스크 착용 여부 (true, false 중 하나, 또는 0, 1 중 하나)

# 남자만 요청
GET /api/find?what=object&objectType=face&gender=male

# 성인만 요청
GET /api/find?what=object&objectType=face&age=adult

# 중년 여자만 요청
GET /api/find?what=object&objectType=face&gender=female&age=middle

# 안경 쓴 사람만 요청
GET /api/find?what=object&objectType=face&glasses=true

# 안경 쓰고 모자 쓴 사람만 요청
GET /api/find?what=object&objectType=face&glasses=1&hat=1

# 마스크 안 쓴 사람만 요청
GET /api/find?what=object&objectType=face&mask=false

# 안경 쓰고 마스크 안 쓴 사람만 요청
GET /api/find?what=object&objectType=face&glasses=true&mask=false
```


#### human용 매개변수
```ruby
gender        # 성별 지정 (male, female 중 하나)
hat           # 모자 착용 여부 (true, false 중 하나, 또는 0, 1 중 하나)
bag           # 가방 소지 여부 (true, false 중 하나, 또는 0, 1 중 하나)
topClothes    # 상의 길이 및 색상을 콤마(,)로 구분해서 복수 지정
              # 길이 (short, long 중 하나)
              # 색상 (brown, black, red, orange, yellow, green, cyan, blue, purple, magenta, gray, pink, beige, white, other 중 복수 지정 가능)
bottomClothes # 하의 색상 지정 (상동)

# 여자만 요청
GET /api/find?what=object&objectType=human&gender=female

# 가방 든 사람만 요청
GET /api/find?what=object&objectType=human&bag=true

# 모자 쓰고 가방 든 사람만 요청
GET /api/find?what=object&objectType=human&hat=true&bag=true

# 반팔 상의를 입은 사람
GET /api/find?what=object&objectType=human&topClothes=short

# 노란색 상의를 입은 사람
GET /api/find?what=object&objectType=human&topClothes=yellow

# 빨강과 파랑색 상의를 입은 사람
GET /api/find?what=object&objectType=human&topClothes=red,blue

# 짧은 하의를 입은 사람
GET /api/find?what=object&objectType=human&bottomClothes=short

# 상하의 모두 검정색을 입은 사람
GET /api/find?what=object&objectType=human&topClothes=black&bottomClothes=black

# 모자 쓰고 가방 들고 흰색 상의를 입은 남자
GET /api/find?what=object&objectType=human&hat=1&bag=1&topClothes=white&gender=male
```


#### vehicle용 매개변수
```ruby
vehicleType  # 차량 종류와 색상을 콤마(,)로 구분 표기
             # 차량 종류 (car, truck, bus, bicycle, motorcycle, train 중 하나) 
             # 차량 색상 (brown, black, red, orange, yellow, green, cyan, blue, purple, magenta, gray, pink, beige, white, other 중 복수 지정 가능)

# 버스만 요청
GET /api/find?what=object&objectType=vehicle&vehicleType=bus

# 노란색 승용차만 요청
GET /api/find?what=object&objectType=vehicle&vehicleType=car,yellow
```


### 얼굴 검색 `@0.9.6`
얼굴 사진으로 닮은 얼굴은 찾을 수 있습니다.

사진 이미지를 전송하기 위해 `HTTP POST` 방식으로 요청합니다.
CGI parameter로 검색 조건을 설정하고 이미지만 POST data로 전송합니다.
이미지 파일 형식은 `jpg` (`Content-Type=image/jpeg`), `png` (`Content-Type=image/png`)를 지원합니다.

얼굴
```ruby
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 얼굴
timeEnd     # 특정 날짜, 시각 이전에 기록된 얼굴
ch          # 채널 번호, 콤마(,) 사용해서 복수 표기 가능
threshold   # 닮은 정도 (1 ~ 100 사이의 퍼센트로 표기)

# 2020년 1월 동안 저장된 얼굴에서 검색
# (2020-01-01T00:00:00+09:00 ~ 2020-01-31T23:59:59.999+09:00)
GET /api/searchFace?timeBegin=2020-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2020-01-31T23%3A59%3A59.999%2B09%3A00

# 1, 2번 채널의 얼굴에서 검색
GET /api/searchFace?ch=1,2

# 95% 닮은 얼굴 검색
GET /api/searchFace?threshold=95
```



## 동영상 소스 검색
[웹 페이지에 영상 삽입하기](#웹-페이지에-영상-삽입하기)에서 사용했던 API를 사용한 동영상 표시 기능 대신 응용 프로그램에서 직접 동영상 주소 사용하는 경우 이 방법을 사용할 수 있습니다.

이 방법은 동영상을 표시하는 대신 동영상 주소를 얻을 수 있습니다.


### 실시간 영상 소스
아무런 매개변수 없이 다음과 같이 호출하면 서버에서 스트리밍하고 있는 실시간 영상 주소 목록을 요청할 수 있습니다.
```ruby
GET /api/vod
```
서버는 이에 대해 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[ // 각 채널이 배열의 항목으로 구성됨
  {
    "chid": 1,                        // 채널 번호
    "title": "Profile1 (1920x1080)",  // 채널 이름
    "displayName": "CH1. Profile1 (1920x1080)",
    "src": [  // 동영상 소스 목록
              // (프로토콜 및 해상도에 따라 하나의 채널에 여러 개의 소스가 배열로 구성됨)
      { // 1080p RTMP 스트림
        "protocol": "rtmp",
        "profile": "main",
        "src": "rtmp://192.168.0.100/live/ch1main",  // 동영상 주소
        "type": "rtmp/mp4",     // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
        "label": "1080p",       // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ]
      },
      { // 1080p HTTP-FLV 스트림
        "protocol": "flv",
        "profile": "main",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1main", // 동영상 주소
        "type": "video/x-flv",  // MIME 형식: FLV (HTTP 프로토콜)
        "label": "1080p",       // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ]
      },
      { // 1080p HLS 스트림
        "protocol": "hls",
        "profile": "main",
        "src": "http://192.168.0.100/hls/ch1main/index.m3u8", // 동영상 주소
        "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
        "label": "1080p",       // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ]
      },
      { // VGA RTMP 스트
        "protocol": "rtmp",
        "profile": "sub",
        "src": "rtmp://192.168.0.100/live/ch1sub",   // RTMP 프로토콜 (Adobe Flash 방식)
        "type": "rtmp/mp4",   // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
        "label": "VGA",
        "size": [
          640,
          480
        ]
      },
      { // VGA HTTP-FLV 스트림
        "protocol": "flv",
        "profile": "sub",
        "src": "http://192.168.0.100/live?port=1935&app=live&stream=ch1sub", // 동영상 주소
        "type": "video/x-flv",  // MIME 형식: FLV
        "label": "VGA",   // 해상도 이름
        "size": [               // 해상도
          640,                // 가로 픽셀 수
          480                 // 세로 픽셀 수
        ]
      },
      { // VGA HLS 스트림
        "protocol": "hls",
        "profile": "sub",
        "src": "http://192.168.0.100/hls/ch1sub/index.m3u8", // 동영상 주소
        "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
        "label": "VGA",       // 해상도 이름
        "size": [             // 해상도
          640,                // 가로 픽셀 수
          480                 // 세로 픽셀 수
        ]
      }
    ]
  },
  {
    "chid": 2,
    "title": "192.168.0.106",
    "displayName": "CH2. 192.168.0.106",
    "src": [
      // ... 중략
    ]
  },
  // ... 중략
]
```
> [참고]
`TS-API@0.5.0`부터 `"ptzSupported"` 항목이 추가되었습니다.

동영상을 재생하는 환경 (전송 선로 속도와 플레이어에서 지원하는 프로토콜)이 다양하기 때문에 호환성을 높이기 위해 위의 예처럼 채널 당 여러 개의 동영상 소스를 제공합니다.
현재 버전에서는 `RTMP`와 `HLS` 두 가지 형식으로 스트리밍하고 있으며, 카메라가 지원하는 경우 고해상도와 저해상도로 이중으로 스트리밍합니다.

사실 위의 예제에는 실시간 영상을 의미하는 `when=now` 매개변수가 생략되어 있습니다.
```ruby
GET /api/vod?when=now
```

필요한 경우 아래와 같은 매개변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.
```ruby
ch          # 채널 번호 (명시하지 않으면 전체 채널을 의미함)
protocol    # 스트리밍 프로토콜을 지정 (rtmp, hls)
stream      # 동영상의 해상도를 지정 (main: 고해상도 영상, sbu:저해상도 영상)
nameonly    # true인 경우 동영상 스트림 데이터 부분 없이 채널 이름만 요청 

# 예제
# 1번 채널만 요청
GET /api/vod?ch=1

# hls 프로토콜만 요청할 경우
GET /api/vod?protocol=hls

# 저해상도 스트림만 요청할 경우
GET /api/vod?stream=sub

# 채널 이름만 요청할 경우
GET /api/vod?nameonly=true
# 또는 간단히
GET /api/vod?nameonly
```



### 녹화 영상 소스
일반적으로는 [녹화 데이터 검색](#녹화-데이터-검색) 기능을 사용해서 녹화 영상에 접근하겠지만, 여기서는 좀 더 저수준으로 녹화된 동영상 소스를 얻는 방법들을 소개합니다.

실시간 영상 소스를 요청할 때 사용하는 `/api/vod`를 그대로 사용하며 다음과 같이 매개변수만 다르게 지정합니다.
```ruby
when        # 녹화된 영상의 시각(타임스템프)을 지정
duration    # when으로 지정한 시각부터 검색할 시간
id          # 녹화 동영상 파일 아이디
next        # true이면 지정한 영상의 다음 영상
prev        # true이면 지정한 영상의 이전 영상
limit       # 검색 결과의 항목 수를 지정 (명시하지 않으면 기본값 10개, 최대 50개)
otherwise   # 검색 결과가 없을 경우, 
            # 'nearBefore'로 요청하면 검색 구간보다 이전에 녹화된 영상 중 가까운 것을 반환
            # 'nearAfter'로 요청하면 검색 구간보다 이후에 녹화된 영상 중 가까운 것을 반환
nolive      # 타임스템프가 현재 시각에서 1분 미만인 경우라도 검색 결과에 실시간 영상이 포함되지 않도록 함 (TS-API@0.9.9)

# 예제
# 1번 채널에 대한민국 시각 2018년 1월 8일 오후 9시 30분 00초에 녹화된 영상 소스
# [중요]
#   1. 녹화 영상의 경우는 ch=를 명시하지 않으면 HTTP 응답 코드 400(잘못된 요청) 발생함
#   2. when=으로 지정한 시각에서 1초 이내의 데이터만 검색함
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00

# 1번 채널에 대한민국 시각 2018년 1월 8일 오후 9시 30분 00초부터 1시간 이내의 데이터 검색
# [duration에서 사용하는 시간 단위 표기법]
#   w: 주  (예: 1w = 한 주)
#   d: 일  (예: 5d = 5일)
#   h: 시  (예: 3h = 3시간)
#   m: 분  (예: 10m = 10분)
#   s: 초  (예: 30s = 30초)
#   ms: 밀리초(1/1000초) (예: 5000ms = 5000밀리초 = 5초)
#   * 단위를 명시하지 않으면 기본적으로 초 단위가 적용됨
#   * 여러 단위를 조합하는 표기(예: 1h30m)법은 지원되지 않으며
#     필요하면 가장 작은 단위로 계산해서 표기(예: 90m)해야 함
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h

# 녹화 파일 아이디를 사용하여 직접 요청
# 영상이 있을 경우 해당 영상에서부터 10개(기본값)를 반환함
# [참고]
#   서버에 녹화된 동영상 파일은 각각 정수로 표현되는 일련 번호가 부여되어 있습니다.
GET /api/vod?id=1304

# 1번 채널의 현재 파일 아이디가 1034일 경우 같은 채널의 다음 파일을 요청 (연속 재생 시 유용함)
GET /api/vod?ch=1&id=1304&next=true
# 또는 간단히
GET /api/vod?ch=1&id=1304&next

# 1번 채널의 현재 파일 아이디가 1034일 경우 같은 채널의 이전 파일을 요청 (역방향 연속 재생 시 유용함)
GET /api/vod?ch=1&id=1304&prev=true
# 또는 간단히
GET /api/vod?ch=1&id=1304&prev

# 검색된 영상 소스를 30개 받기
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30

# 검색 결과 해당 시간에 영상이 존재하지 않을 경우:
# 검색 구간보다 이전에 녹화된 영상 중 가까운 것을 반환
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearBefore
# 검색 구간보다 이후에 녹화된 영상 중 가까운 것을 반환
GET /api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30&otherwise=nearAfter
```
이와 같은 방식으로 요청하면 서버는 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.

```jsx
[ // 녹화된 동영상 파일 단위의 배열로 구성됨
  {
    "chid": 1,                        // 채널 번호
    "title": "192%2E168%2E0%2E111",   // 동영상 이름
    "fileId": 100,                    // 파일 아이디
    "src": [  //동영상 소스 
      {
        "src": "http://192.168.0.100/storage/e/0/0/0/0/100.mp4",  // 동영상 주소
        "type": "video/mp4",    // MIME 형식 (mp4 파일)
        "label": "1080p FHD",   // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ],
        "timeRange": [
          "2018-02-05T17:57:12.935+09:00",  // 동영상 파일 처음의 날짜, 시각 
          "2018-02-05T17:57:20.036+09:00"   // 동영상 파일 마지막의 날짜, 시각
        ]
      }
    ]
  },
  // ... 중략
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
          "2018-02-05T18:05:12.147+09:00",
          "2018-02-05T18:05:12.229+09:00"
        ]
      }
    ]
  }
]
```


## 동영상 소스를 사용하여 영상 요청 `@0.3.0`
API로 제공되는 `/watch`를 사용하지 않고 영상 소스를 사용하여 영상을 요청하는 경우에 대해, 각 프로토콜 별로 다음과 같은 방식으로 인증을 지원합니다.
```ruby 
# RTMP (auth= 매개변수가 지원됩니다.)
rtmp://host/path/to?auth=ZGVtbzohMTIzNHF3ZXI%3D

# HTTP (m3u8, JPG, MP4 와 같은 정적인 파일 기반 리소스들은 Basic Authentication만 지원됩니다.)
http://userid:password@host/path/to

# HTTP (/api/ 하위 경로는 두 가지 방법이 모두 지원됩니다.)
http://userid:password@host/api/path/to
http://host/api/path/to&?auth=ZGVtbzohMTIzNHF3ZXI%3D
```


## 실시간 이벤트 모니터링 `@0.3.0`

### 웹 소켓 (RFC6455)
웹 소켓 (RFC6455)으로 실시간 이벤트 데이터를 수신할 수 있는 기능을 지원합니다.
서버와 클라이언트가 접속 상태를 유지하며 이벤트가 발생하면 서버가 클라이언트에게 메시지를 송신하는 방식으로 동작합니다.

단계별 통신 절차는 다음과 같습니다.
>1. 클라이언트가 웹 소켓으로 서버에 접속
>2. 서버에 인증에 성공하면 구독자 ID를 발급
>3. 이후 클라이언트는 접속을 유지하며 메시지 대기 상태로 들어감
>>* 서버는 전송할 메시지가 없더라도 접속을 유지하기 위해 30초에 한번씩 ping 메시지를 송신함
>4. 이벤트 발생시 서버는 클라이언트에게 메시지를 송신
>5. 클라이언트 스스로 접속을 종료하기 전까지 위의 3번에서 4번 과정을 반복

> [참고]
웹 소켓 방식은 Microsoft 웹 브라우저들을 포함한 모든 웹 브라우저에서 지원합니다.
https://developer.mozilla.org/en-US/docs/Web/API/WebSocket


지원하는 이벤트 토픽은 다음과 같습니다.
```ruby
channelStatus   # 채널 상태 변경
LPR             # 차량 번호 인식
emergencyCall   # 비상 호출
systemEvent     # 시스템 이벤트 (@0.7.0에서 추가됨)
motionChanges   # 움직임 감지 상태 변경 (@0.8.0에서 추가됨)
parkingCount    # 주차장 차량수 변동 이벤트 (@0.9.0에서 추가됨)
packing         # 포장 이벤트 (@0.9.0에서 추가됨)
recordingStatus # 녹화 상태 이벤트 (@0.9.5에서 추가됨)
object          # 객체 감지 이벤트 (@0.9.6에서 추가됨)
```

 
웹 소켓 접속 경로와 매개변수들은 다음과 같습니다.
```ruby
/wsapi/subscribeEvents

# 필수 매개 변수들
auth    # 인증 정보 (세션 인증과 별도로 개별 웹 소켓마다 인증 필요)
topics  # 수신할 토픽 지정 (여러 토픽을 동시에 지정할 경우 쉼표 문자(,)로 구분)

# 공용 매개 변수들 (선택 사항)
verbose # 연동된 실시간 영상 채널들의 동영상 스트림 소스를 자세히 나열
        # channelStatus의 경우 텍스트 메시지를 포함 (구독자 id 발급 직후 최초 메시지에 "title" 포함)
session # 이미 연결된 session cookie를 전달하여 인증 정보를 대신할 수 있음

# channelStatus 전용 매개 변수들 (선택 사항)
ch      # 특정 채널을 지정할 경우 (여러 채널을 동시에 지정할 경우 쉼표 문자(,)로 구분)
        # 채널을 명시하지 않으면 모든 채널을 의미
lang    # 상태 메시지 표기 언어


# 사용 예
# 차량 번호 인식 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=LPR&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 비상 호출 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 두 이벤트를 모두 요청
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 연동된 실시간 영상 채널들의 동영상 스트림 소스를 자세히 요청
ws://host/wsapi/subscribeEvents?topics=LPR,emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true

# 모든 채널의 상태 변경 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 모든 채널의 상태 변경 이벤트시 메시지를 포함 요청
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true

# 1, 2번 채널의 상태 변경 이벤트시 스페인어 메시지를 포함 요청
ws://host/wsapi/subscribeEvents?topics=channelStatus&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2&verbose=true&lang=es-ES

# 모든 채널에 대해 움직임 감지 상태 변경시 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=motionChanges&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 1, 2번 채널에 대해 움직임 감지 상태 변경시 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=motionChanges&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2

# 모든 주차장의 주차 카운트 변경시 이벤트 요청
ws://host/wsapi/subscribeEvents?topics=parkingCount&auth=ZGVtbzohMTIzNHF3ZXI%3D

# Id 1, 2번 주차장의 주차 카운트 변경시 이벤트 요청 (이때 ch는 주차장 id로 사용됨)
ws://host/wsapi/subscribeEvents?topics=parkingCount&auth=ZGVtbzohMTIzNHF3ZXI%3D&ch=1,2
```

서버는 요청한 인증 정보와 토픽이 올바른 경우 아래와 같이 JSON형식으로 구독자 ID를 발급합니다.
만약 인증 정보가 올바르지 않거나 지원하는 토픽이 아니면 즉시 접속을 끊습니다.
```jsx
{
  "subscriberId": "cd57c82b-7e8c-4b04-91eb-520f6a9773ce", // 구독자 ID (접속 당 유일한 ID를 발급)
  "topics": [   // 요청한 토픽에 대한 응답 (두 이벤트를 모두 지원한다는 의미임)
    "LPR",
    "emergencyCall"
  ]
}
```


### 채널 상태 변경 이벤트
`topics=channelStatus`를 요청하면 실시간으로 채널 상태 변경 이벤트를 수신할 수 있습니다.
채널 상태 토픽은 다른 토픽과 달리 상태 변경 관리를 위해 구독자 id 발급 직후 현재 채널 상태가 한 번 이벤트로 전송됩니다.
이후 나머지 이벤트들은 최초 상태에서 변경 사항이 있을 때만 전송됩니다.
 채널 상태 변경 이벤트 메시지는 아래와 같이 JSON형식으로 수신됩니다.
```jsx
// 구독자 id
{
  "subscriberId":"1a3dc2de-d3b5-4983-933a-49a86ac8ad3d",
  "topics": [
    "channelStatus"
  ]
}

// 현재 전체 채널 상태 (구독자 id 이후 즉시 전송됨)
{
  "timestamp": "2018-07-20T15:05:45.956+09:00",
  "topic": "channelStatus",
  "event": "currentStatus",
  "channel": [
    {
      "chid": 1,
      "title": "카메라1",
      "displayName": "CH1. 카메라1", // TS-API@0.9.4 이후 추가됨
      "status": {
        "code": 200,
        "message": "연결됨"
      },
      "caps": {   // 카메라 지원 기능 (TS-API@0.9.4 이후 추가됨)
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
      "src": [  // 가용한 스트리밍 목록 (TS-API@0.9.4 이후 추가됨)
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
      "title": "카메라2",
      "displayName": "CH2. 카메라2",
      "status": {
        "code": 200,
        "message": "연결됨"
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
  // ... 중략
  ]
}

// 채널 이름 변경시
{
  "timestamp": "2018-07-20T16:05:45.956+09:00",
  "topic": "channelStatus",
  "event": "nameChanged",
  "chid": 1,
  "name": "카메라1",
  "displayName: "CH1. Camera1"  // TS-API@0.9.4 이후 추가됨
}

// 카메라의 영상 주소가 변경시
{
  "timestamp": "2018-07-20T16:01:45.956+09:00",
  "topic": "channelStatus",
  "event": "videoSrcModified",
  "chid": 1
}

// 비디오 스트림이 연결된 경우
{
  "timestamp": "2018-07-20T16:03:45.956+09:00",
  "topic": "channelStatus",
  "event": "videoStreamReady",
  "chid": 1,
  "status": {
    "code": 2,
    "message": "Video available"
  },
  "src": [  // 가용한 스트림 목록 (TS-API@0.9.4 이후 추가됨)
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

// 비디오 스트림이 주소는 동일하나 변경되어 다시 연결해야 하는 경우
{
  "timestamp": "2018-07-20T16:03:45.956+09:00",
  "topic": "channelStatus",
  "event": "videoStreamChanged",
  "chid": 1
}

// 카메라가 접속된 경우
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

// 채널이 추가된 경우 (설정 변경)
// TS-API@0.9.4 이후 추가됨
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelAdded",
  "chid": 1
}

// 채널이 삭제된 경우 (설정 변경)
// TS-API@0.9.4 이후 추가됨
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelRemoved",
  "chid": 1
}

// 두 채널의 채널 번호가 서로 바뀐 경우 (설정 변경)
// TS-API@0.9.4 이후 추가됨
{
  "timestamp": "2018-07-20T16:05:45.956-05:00",
  "topic": "channelStatus",
  "event": "channelSwapped",
  "chid": [1,2]
}


```

채널 상태 코드 목록은 [채널 상태 요청 `@0.3.0`](#채널-상태-요청-030)의 상태 코드 목록과 동일합니다.



### 차량 번호 인식 이벤트
`topics=LPR`를 요청하면 실시간으로 차량 번호 인식 이벤트를 수신할 수 있습니다.
차량 번호 이벤트 메시지는 아래와 같이 JSON형식으로 수신됩니다.
```jsx
{
  "timestamp":"2018-06-27T10:42:06.575+09:00",  // 차량 번호 인식 시점
  "chid": {                                     // 차량 번호 인식 채널
    "chid":1,
    "title":"카메라1",
    "displayName":"CH1. 카메라1",                // TS-API@0.9.4 이후 추가됨
    "src":"http://host/watch?ch=1&when=2018%2D06%2D27T10%3A42%3A06%2E575%2B09%3A00"  // 차량 번호 인식 시점의 영상
  },
  "srcCode":"1-1-7",                            // 차량 번호 인식 장치(영역) 코드
  "srcName":"B1주차장",                          // 차량 번호 인식 장치(영역) 이름
  "linkedChannel": [                            // 연동된 채널
    {
      "chid":2,
      "title":"카메라2",
      "displayName":"CH2. 카메라2",              // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=2&when=2018%2D06%2D27T10%3A42%3A06%2E575%2B09%3A00" // 차량 번호 인식 시점의 영상
    }
  ],
  "image":"http://host/storage/e/0/0/0/39/39612.161192.1576732638241699.plate.jpg", // 캡쳐된 낱장 이미지
  "plateNo":"11가1432",                          // 차량 번호
  "score":98,                                    // 인식 점수 (100점 만점): 차번인식 엔진에 따라 지원하지 않을 수 있음 (항목 없을 수 있음)
  "roi": {                                       // 번호판 이미지 영역
    "offset":[964,560],                          // 좌상단 좌표
    "size":[187,51]                              // 번호판 이미지 크기
  },
  "timeBegin":"2018-06-27T10:42:02.573+09:00",   // 동일 차량 번호 최초 인식 시점 
  "topic":"LPR",                                 // 토픽 이름
  "parkingLot": {                                // 연결된 주차장 id (TS-API@0.9.8)
    "entrance": 1,                               // 주차장 입구 id
    "exit": 2                                    // 주차장 출구 id
  }
}
```


### 비상 호출 이벤트
`topics=emergencyCall`을 요청하면 실시간으로 비상 호출에 의한 통화 시작과 종료 시점에  이벤트 메시지를 수신할 수 있습니다.
비상 호출 이벤트 메시지는 아래와 같이 JSON형식으로 수신됩니다.

**통화 시작 메시지**
```jsx
{
  "timestamp":"2018-06-27T10:56:16.316+09:00",  // 통화 시작 시점
  "caller":"0000002",                           // 비상 호출 장치 위치 코드
  "device":"Sammul/Vizufon",                    // 비상 호출 장치 이름
  "event":"callStart",                          // 통화 시작 이벤트
  "linkedChannel":[                             // 연동된 채널
    {
      "chid":1,
      "title":"카메라1",
      "displayName":"CH1. 카메라1",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"카메라2",
      "displayName":"CH2. 카메라2",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=2"
    }
  ],
  "name":"지하1층 계단",                         // 비상 호출 장치 위치 이름
  "topic":"emergencyCall"                       // 토픽 이름
}
```

비상 호출 이벤트는 실시간 통화용 이벤트이므로 연동된 채널들은 모두 실시간 영상을 링크하고 있습니다. 
아래와 같이 채널들의 동영상 스트림 소스를 자세히 요청한 경우는 동영상 스트림 항목들이 추가로 포함됩니다.
```ruby
GET /api/subscribeEvents?topics=emergencyCall&auth=ZGVtbzohMTIzNHF3ZXI%3D&verbose=true
```
```jsx
{
  "timestamp":"2018-06-27T10:56:16.316+09:00",  // 통화 시작 시점
  "caller":"0000002",                           // 비상 호출 장치 위치 코드
  "device":"Sammul/Vizufon",                    // 비상 호출 장치 이름
  "event":"callStart",                          // 통화 시작 이벤트
  "linkedChannel":[                             // 연동된 채널
    {
      "chid":1,
      "title":"카메라1",
      "displayName":"CH1. 카메라1",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=1",
      "streams": [  // 동영상 소스 목록
                // (프로토콜 및 해상도에 따라 하나의 채널에 여러 개의 소스가 배열로 구성됨)
        { // 1080p RTMP 스트림
          "src": "rtmp://host/live/ch1main",  // 동영상 주소
          "type": "rtmp/mp4",     // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
          "label": "1080p FHD",   // 해상도 이름
          "size": [               // 해상도
            1920,                 // 가로 픽셀 수
            1080                  // 세로 픽셀 수
          ]
        },
        { // 1080p HLS 스트림
          "src": "http://host/hls/ch1main/index.m3u8", // 동영상 주소
          "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
          "label": "1080p FHD",   // 해상도 이름
          "size": [               // 해상도
            1920,                 // 가로 픽셀 수
            1080                  // 세로 픽셀 수
          ]
        },
        { // VGA RTMP 스트림
          "src": "rtmp://host/live/ch1sub",   // RTMP 프로토콜 (Adobe Flash 방식)
          "type": "rtmp/mp4",   // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
          "label": "VGA",
          "size": [
            640,
            480
          ]
        },
        { // VGA HLS 스트림
          "src": "http://host/hls/ch1sub/index.m3u8", // 동영상 주소
          "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
          "label": "VGA",       // 해상도 이름
          "size": [             // 해상도
            640,                // 가로 픽셀 수
            480                 // 세로 픽셀 수
          ]
        }
      ]
    },
    {
      "chid":2,
      "title":"카메라2",
      "displayName":"CH2. 카메라2",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=2",
      "streams":[
        // ... 중략
      ]
    }
  ],
  "name":"지하1층 계단",                         // 비상 호출 장치 위치 이름
  "topic":"emergencyCall"                       // 토픽 이름
}
```

**통화 종료 메시지**
```jsx
{
  "timestamp":"2018-06-27T10:59:26.322+09:00",  // 통화 종료 시점
  "caller":"0000002",                           // 비상 호출 장치 위치 코드
  "device":"Sammul/Vizufon",                    // 비상 호출 장치 이름
  "event":"callEnd",                            // 통화 종료 이벤트
  "linkedChannel":[                             // 연동된 채널
    {
      "chid":1,
      "title":"카메라1",
      "displayName":"CH1. 카메라1",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=1"
    },
    {
      "chid":2,
      "title":"카메라2",
      "displayName":"CH2. 카메라2",               // TS-API@0.9.4 이후 추가됨
      "src":"http://host/watch?ch=2"
    }
  ],
  "name":"비상벨2",                             // 비상 호출 장치 위치 이름
  "topic":"emergencyCall"                      // 토픽 이름
}
```
비상 호출 메시지는 실시간 통화를 위한 용도로 사용되므로 연동된 채널의 영상 주소는 차량 번호 인식의 경우와 달리 실시간 영상으로 링크되어 있습니다.


### 시스템 이벤트 `@0.7.0`
`topics=systemEvent`를 요청하면 실시간으로 시스템 이벤트를 수신할 수 있습니다.
시스템 이벤트는 [이벤트 로그 종류 목록](#이벤트-로그-종류-목록) 중에서 "시스템 로그" 데이터가 생성되면 아래와 같이 JSON형식으로 수신됩니다.
개별 데이터 형식은 [이벤트 로그 검색](#이벤트-로그-검색)에서 사용되는 형식과 동일합니다.

```jsx
{
  "topic": "systemEvent",
  "id": 16384,
  "type": 0,
  "typeName": "시스템 로그",
  "code": 30,
  "codeName": "저장 경로 변경",
  "timeRange": [
    "2018-11-15T13:16:38.054+09:00"
  ],
  "param": {
    "storagePathBefore": "D:\\recData\\",
    "storagePathAfter": "E:\\recData\\"
  },
  "comment": "D:\\recData\\에서 E:\\recData\\로 저장 경로 변경됨"  // 옵션
}
```
```jsx
{
  "topic": "systemEvent",
  "id": 19138,
  "type": 0,
  "typeName": "시스템 로그",
  "code": 2,
  "codeName": "시스템 종료",
  "timeRange": [
    "2018-12-26T15:29:20.013+09:00"
  ]
}
```


### 움직임 감지 이벤트 `@0.8.0`
`topics=motionChanges`를 요청하면 실시간으로 각 채널별 움직임 감지 상태 변경시 이벤트를 수신할 수 있습니다.
요청 직후 한번은 지정한 모든 채널의 현재 움직임 감지 상태가 수신되며 
이 후 1초 주기로 움직임 감지가 변경된 채널들의 상태를 아래와 같이 JSON 형식으로 수신됩니다.
동일한 움직임 감지 상태가 지속되는 채널의 경우는 이벤트가 발생하지 않습니다.

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


### 주차 카운트 이벤트 `@0.9.0`
`topics=parkingCount`를 요청하면 각 주차장의 차량 수가 변경시 실시간으로 이벤트를 수신할 수 있습니다.
요청 직후 한번은 지정한 모든 주차장의 현재 차량 수가 수신되며 
이 후 변경시 마다 해당 주차장의 차량 수가 아래와 같이 JSON 형식으로 수신됩니다.

```jsx
{
  "timestamp": "2019-02-18T23:11:12.119+09:00",
  "topic": "parkingCount",
  "updated": [
    {
      "id": 11,
      "name": "전체",
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
      "name": "B1 주차장",
      "type": "counter",
      "count": 2,
      "maxCount": 21
    },
    {
      "id": 13,
      "name": "B2 주차장",
      "type": "counter",
      "count":1,
      "maxCount":10
    }
  ]
}
```

### 녹화 상태 이벤트 `@0.9.5`
`topics=recordingStatus`를 요청하면 각 채널별 녹화 상태를 실시간 이벤트를 수신할 수 있습니다.
요청 직후 한 번은 모든 채널의 현재 상태가 수신되며 
이 후 변동사항이 발생할 때마다 아래와 같이 JSON 형식으로 수신됩니다.

- 최초 모든 채널 녹화 상태 데이터
```jsx
{
  "timestamp": "2020-03-25T10:01:53.841+09:00",
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

- 변동사항 데이터
```jsx
{
  "timestamp": "2020-03-25T10:08:30.003+09:00",
  "topic": "recordingStatus",
  "event": "statusChanged",
  "channel": [
    {
      "chid":3,
      "streaming":true,
      "recording":false,
      // 녹화 장애 발생 시각 (이 값은 장애 상태에만 명시됨)
      "timestampRecordingFailure":"2020-03-25T10:07:09.646+09:00"
    },
  ]
}
```

### 객체 감지 이벤트 `@0.9.11`
`topics=object`를 요청하면 각 카메라에서 객체가 감지되는 시점에 실시간 이벤트를 수신할 수 있습니다.

지원하는 객체 종류는 다음과 같습니다.
- face
- human
- vehicle

아래와 같이 `objectType` (객체 종류)를 지정하여 원하는 객체만 수신할 수 있습니다. 
지정하지 않으면 지원하는 모든 종류의 객체가 전송됩니다.
```ruby
# 얼굴만 요청
GET /api/subscribeEvents?topics=object&objectType=face&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 차량만 요청
GET /api/subscribeEvents?topics=object&objectType=vehicle&auth=ZGVtbzohMTIzNHF3ZXI%3D

# 얼굴과 사람만 요청
GET /api/subscribeEvents?topics=object&objectType=face,human&auth=ZGVtbzohMTIzNHF3ZXI%3D
```

#### `face` 객체
1. 예제 데이터
```jsx
{
  "timestamp":"2020-05-25T13:56:02.558+09:00",
  "chid": 1,              # 채널 번호
  "objId": 132,           # 객체 id (id가 같으면 동일 객체로 구분함)
  "parentId": 130,        # `face` 객체의 경우 `human`이 부모가 될 수 있음, `human`(몸통:부모)에 딸린 `face`(얼굴:자식)의 관계 (두 객체가 동시에 감지된 경우에만 존재함)
  "type": "face",         # 객체 종류
  "likelihood": 71.10,    # 정확도 (%)
  "attributes": {         # 객체 속성 (감지된 속성만 나열)
    "gender": "female",   # 성별
    "age": "adult",       # 나이 구분
    "hat": true,          # 모자 (착용) 
    "glasses": false,     # 안경 (미착용)
    "mask": false         # 마스크 (미착용)
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673854/7673854.4411971.1590382562558672.object._c1_t2_s552x400.jpg" # 이미지 주소
}
```
2. `face` 객체 속성
    | key         | 형식       | 목록                                  |
    |-------------|-----------|--------------------------------------|
    | `gender`    | `string`  | `female`, `male`                     |
    | `age`       | `string`  | `young`, `adult`, `middle`, `senior` |
    | `hat`       | `boolean` | true, false                          |
    | `glasses`   | `boolean` | true, false                          |
    | `mask`      | `boolean` | true, false                          |
    

#### `human` 객체
1. 예제 데이터
```jsx
{
  "timestamp": "2020-05-25T13:56:18.461+09:00",
  "chid": 1,              # 채널 번호
  "objId": 142,           # 객체 id (id가 같으면 동일 객체로 구분함)
  "type": "human",        # 객체 종류
  "likelihood": 74.80,    # 정확도 (%)
  "attributes": {         # 객체 속성 (감지된 속성만 나열)
    "gender": "female",   # 성별
    "hat": true,          # 모자 (착용) 
    "bag": true,          # 가방 (소지)
    "clothes": [          # 옷 (복수 표기)
      {
        "type": "tops",   # 상의
        "length": "long", # 길이
        "colors": [       # 색상 (복수 표기)
          "white"
        ]
      },
      {
        "type": "bottoms", # 하의
        "length": "long",  # 길이
        "colors": [        # 색상 (복수 표기)
          "blue"
        ]
      }
    ]
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673854/7673854.4411974.1590382578461739.object._c1_t1_s376x600.jpg" # 이미지 주소
}
```
2. `human` 객체 속성
    | key         | 형식              | 목록                            |
    |-------------|------------------|--------------------------------|
    | `gender`    | `string`         | `female`, `male`               |
    | `hat`       | `boolean`        | true, false                    |
    | `bag`       | `boolean`        | true, false                    |
    | `clothes`   | `object` `array` | *`clothes` 객체 속성 참조*        |
3. `clothes` 객체 속성  
    | key         | 형식              | 목록                    | 설명         |
    |-------------|------------------|------------------------|-------------|
    | `type`      | `string`         | `tops`, `bottoms`      | 상.하의 구분   |
    | `length`    | `string`         | `short`, `long`        | 소매.바지 기장 |
    | `colors`    | `string` `array` | `brown`, `black`, `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `magenta`, `gray`, `pink`, `beige`, `white`, `other`  | 색상 |
    
    
  
#### `vehicle` 객체
```jsx
1. 예제 데이터
{
  "timestamp": "2020-05-25T14:23:58.768+09:00",
  "chid": 1,              # 채널 번호
  "objId": 182,           # 객체 id (id가 같으면 동일 객체로 구분함)
  "type": "vehicle",      # 객체 종류
  "likelihood": 99.60,    # 정확도 (%)
  "attributes": {         # 객체 속성 (감지된 속성만 나열)
    "vehicleType": "car", # 차량 종류
    "colors": [           # 차량 색상
      "white"
    ]
  },
  "image": "http://host/storage/e/0/0/7/7673/object/7673880/7673880.4412174.1590384238768802.object._c1_t3_s944x520.jpg" # 이미지 주소
}
```
2. `vehicle` 객체 속성
    | key           | 형식          | 목록                            |
    |---------------|--------------|--------------------------------|
    | `vehicleType` | `string`     | `car`, `truck`, `bus`, `bicycle`, `motorcycle`, `train`  |
    | `colors`      | `string` `array` | `brown`, `black`, `red`, `orange`, `yellow`, `green`, `cyan`, `blue`, `purple`, `magenta`, `gray`, `pink`, `beige`, `white`, `other`  |


### 체온 감지 이벤트 `@0.9.14`
`topics=bodyTemperature`를 요청하면 각 체온 감지용 열화상 카메라에서 고온이 감지되는 시점에 실시간 이벤트를 수신할 수 있습니다.

체온 감지 이벤트를 수신하려면 아래와 같이 요청합니다.
```ruby
GET /api/subscribeEvents?topics=object&objectType=bodyTemperature&auth=ZGVtbzohMTIzNHF3ZXI%3D
```
예제 데이터
```jsx
{
  "timestamp": "2020-05-25T14:23:58.768-05:00",
  "chid": 1,              # 채널 id
  "objId": 182,           # 객체 id (id가 동일하면 같은 사람임)
  "likelihood": 99.60,    # 인식 신뢰도 (%)
  "linkedChannel":[                             // 채널 정보
    {
      "chid":1,
      "title":"카메라1",
      "displayName":"CH1. 카메라1",             // TS-API@0.9.4
      "src":"http://host/watch?ch=1",
      "streams": [  // 동영상 스트림 정보
                // (프로토콜 및 해상도에 따라 하나의 채널에 여러 개의 소스가 배열로 구성됨)
        { // 1080p RTMP 스트림
          "src": "rtmp://host/live/ch1main",  // 동영상 주소
          "type": "rtmp/mp4",     // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
          "label": "1080p FHD",   // 해상도 이름
          "size": [               // 해상도
            1920,                 // 가로 픽셀 수
            1080                  // 세로 픽셀 수
          ]
        },
        { // 1080p HLS 스트림
          "src": "http://host/hls/ch1main/index.m3u8", // 동영상 주소
          "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
          "label": "1080p FHD",   // 해상도 이름
          "size": [               // 해상도
            1920,                 // 가로 픽셀 수
            1080                  // 세로 픽셀 수
          ]
        },
        { // VGA RTMP 스트림
          "src": "rtmp://host/live/ch1sub",   // RTMP 프로토콜 (Adobe Flash 방식)
          "type": "rtmp/mp4",   // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
          "label": "VGA",
          "size": [
            640,
            480
          ]
        },
        { // VGA HLS 스트림
          "src": "http://host/hls/ch1sub/index.m3u8", // 동영상 주소
          "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
          "label": "VGA",       // 해상도 이름
          "size": [             // 해상도
            640,                // 가로 픽셀 수
            480                 // 세로 픽셀 수
          ]
        }
      ]
    }
  ]
}
```

이 번에는 웹 소켓을 이용하여 이벤트 메시지를 수신하는 예제를 만들어 봅시다.
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
  <h2>예제3. 이벤트 수신하기 (Web Socket)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='서버 IP주소:포트'>
      <input type='text' id='user-id' placeholder='사용자 ID'> 
      <input type='password' id='password' placeholder='비밀번호'>
    </div>
    <div>
      토픽:
      <input class='topic' type='checkbox' value="channelStatus" checked>채널 상태 
      <input class='topic' type='checkbox' value="LPR" checked>차량 번호 인식 
      <input class='topic' type='checkbox' value="emergencyCall" checked>비상 호출
      <input class='topic' type='checkbox' value="systemEvent" checked>시스템 이벤트
      <input class='topic' type='checkbox' value="motionChanges" checked>움직임 감지
      <input class='topic' type='checkbox' value="parkingCount" checked>주차 카운트
      <input class='topic' type='checkbox' value="packing" checked>포장
      <input class='topic' type='checkbox' value="recordingStatus" checked>녹화 상태
      <input class='topic' type='checkbox' value="object" checked>객체 감지
      <input class='topic' type='checkbox' value="bodyTemperature" checked>체온 감지
      <input id='verbose' type='checkbox' checked>자세히
      <button type='button' onClick='onConnect()'>접속</button>
      <button type='button' onClick='onDisconnect()'>접속 종료</button>
      <button type='button' onClick='onClearAll()'>모두 삭제</button>
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
      alert('웹 소켓을 지원하지 않는 웹 브라우저입니다.');
      return url;
    }

    if(window.myApp.ws !== null) {
      alert('이미 접속 중입니다.');
      return url;
    }
      
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert('호스트를 입력하십시오.');
      return url;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert('사용자 아이디를 입력하십시오.');
      return url;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert('비밀번호를 입력하십시오.');
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
      alert('하나 이상의 토픽을 선택하십시오.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 인코딩
    url = (hostName.includes('ws://', 0) ? '' : 'ws://') +
      hostName + '/wsapi/subscribeEvents?topics=' + topics + 
      '&auth=' + encodedData;
    
    if(document.getElementById('verbose').checked)
      url += '&verbose=true';

    //url += '&ch=4&lang=ko-KR';
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

    // 웹 소켓 인스턴스와 핸들러 함수들
    var ws = new WebSocket(url);
    ws.onopen = function() {
      addItem('open', '접속 성공');
    };
    ws.onclose = function(e) {
      addItem('close', '접속 종료: ' + e.code);
      onDisconnect();
    };
    ws.onerror = function(e) {
      addItem('error', '오류: ' + e.code);
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
[실행하기](./examples/ex3.html)



## 녹화 영상 받아내기 `@0.3.0`
웹 소켓을 사용하여 서버로 부터 녹화된 동영상을 받아낼 수 있습니다.
서버 측에서는 파일은 하나씩 생성하고 클라이언트에서 다운로드를 완료하면 해당 파일을 삭제한 후
다음 파일을 생성하는 방식으로 동작합니다.
모든 진행 과정은 서버와 클라이언트가 접속 상태가 유지되는 동안 동작하며,
접속이 끊어지면 서버 측에서는 즉시 작업을 중단하고 생성된 파일을 삭제합니다.

단계별 통신 절차는 다음과 같습니다.
>1. 클라이언트가 웹 소켓으로 서버에 접속
>2. `서버 -> 클라이언트 [stage:ready]` 서버에 인증에 성공하면 task id와 받아낼 데이터에 대한 요약 내용을 전송
>4. `서버 -> 클라이언트 [stage:begin]` 서버에서 요청받은 작업을 시작
>5. `서버 -> 클라이언트 [stage:channelBegin]` 하나의 채널에 대한 작업 시작
>6. `서버 -> 클라이언트 [stage:fileBegin]` 하나의 파일을 생성 시작
>7. `서버 -> 클라이언트 [stage:fileWriting]` 하나의 파일에 데이터를 저장 중
>8. `서버 -> 클라이언트 [stage:fileEnd]` 하나의 파일을 생성 완료 (다운로드 링크 제공)
>9. `서버 -> 클라이언트 [stage:timeoutAlert]` `fileEnd`의 `ttl`에 명시된 시간이 초과되기 직전에 보내짐
>10. `클라이언트 -> 서버 [cmd:wait]` 클라이언트가 다운로드 받는 동안 서버 작업을 대기 시킴
>11. `클라이언트 -> 서버 [cmd:next]` 클라이언트가 다운로드를 완료하고 서버에게 다음 파일을 생성하도록 지시함
>12. `서버 -> 클라이언트 [stage:channelEnd]` 하나의 채널에 대한 작업 완료
>13. `서버 -> 클라이언트 [stage:end]` 
>14. 파일이 여러 개일 경우, 6번에서 10번 과정을 반복
>15. 채널이 여러 개일 경우, 5번에서 12번 과정을 반복
>16. `클라이언트 -> 서버 [cmd:cancel]` 2번 과정 이후 어느 때든 클라이언트는 작업을 취소할 수 있음


웹 소켓 접속 경로와 매개변수들은 다음과 같습니다.
```ruby
/wsapi/dataExport

# 필수 매개 변수들
auth            # 인증 정보 (세션 인증과 별도로 개별 웹 소켓마다 인증 필요)
timeBegin       # 받아낼 데이터 구간의 시작 시각 (ISO8601 형식)
timeEnd         # 받아낼 데이터 구간의 끝 시각 (ISO8601 형식)

# 매개 변수들 (선택 사항)
ch              # 특정 채널을 지정할 경우 (여러 채널을 동시에 지정할 경우 쉼표 문자(,)로 구분)
                # 채널을 명시하지 않으면 모든 채널을 의미
subtitleFormat  # 영상의 시각 표시를 자막으로 할 경우 사용할 자막 파일 형식 지정
                # VTT, SRT, SMI 형식을 지원하며, 지정하지 않거나 None으로 설정하면 자막 파일이 생성되지 않음
mediaSize       # 동영상 파일의 최대 크기를 지정 (GB, MB, KB, B 등의 단위를 붙여 표기할 수 있음, 예: 1GB, 700MB)
statusInterval  # 서버에서 내보낼 동영상 파일이 생성되는 진행률(stage:fileWriting)을 전송 받는 주기를 설정
                # (s, ms 등의 단위를 붙여서 표시할 수 있음, 예: 1s, 500ms)
                # statusInterval을 명시하지 않으면 진행률을 전송하지 않음 
lang            # 백업 진행 상태 표시와 자막 파일에 사용될 언어를 지정

# 서버측 로그를 위해 사용되는 매개변수들 (여러 줄의 텍스트를 사용할 수 있음)
submitter       # 동영상 제출자를 명시
recipient       # 동영상 수령인을 명시
purpose         # 제출할 동영상의 용도를 명시

# md5 포함
md5             # v0.9.2에 포함됨

# 사용 예
# 2018년 7월 27일 오전 9시 정각부터 9시 30분까지 녹화된 모든 동영상을 받아내기
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A

# 1번 채널에 녹화된 동영상을 받아내기
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1

# 1번 채널에 녹화된 동영상을 받아내기 (md5 포함)
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&md5=true

# 1,2,3번 채널에 녹화된 동영상을 받아내기
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1,2,3

# 파일을 500MB 단위로 저장
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB

# VTT 자막 파일 생성
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT

# 1초 주기로 진행률 표시
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s

# 언어를 스페인어로 지정
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s&lang=es-ES

# 동영상 제출자(흥부), 수령인(놀부), 용도(춥고\n배고파서)를 명시
ws://host/wsapi/dataExport?auth=ZGVtbzohMTIzNHF3ZXI%3D&timeBegin=2018-07-27T09%3A00%3A00%0D%0A&timeEnd=2018-07-27T09%3A30%3A00%0D%0A&ch=1&mediaSize=500MB&subtitleFormat=VTT&statusInterval=1s&submitter=%ED%9D%A5%EB%B6%80%0D%0A&recipient=%EB%86%80%EB%B6%80&purpose=%EC%B6%A5%EA%B3%A0%0D%0A%EB%B0%B0%EA%B3%A0%ED%8C%8C%EC%84%9C
```

각 단계(stage)별로 서버가 전송하는 메시지 형식은 다음과 같습니다.
**stage:ready - 준비**
```jsx
{
  "stage": "ready",
  "status": {
    "code": 0,
    "message": "성공"
  },
  "task": {
    "id": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # 작업 번호
    "ch": [
      1,
      2,
      3
    ],
    "timeRange": [
      "2018-07-27T09:00:00.000+09:00",
      "2018-07-27T09:30:00.000+09:00"
    ],
    "mediaSize": 524288000,
    "subtitleFormat": "VTT",
    "language":"ko-KR"
  }
}
```

상황에 따라 이 단계에서 실패하고 즉시 종료되는 경우가 발생할 수 있습니다.
`status` 코드의 종류는 다음과 같습니다.
```ruby
0: 성공
-1: 요청한 구간 내에 데이터 없음
-2: 잘못된 매개변수
-5: 저장 공간 부족 (서버에 여유 공간이 없을 경우)   
```

**stage:begin - 작업 시작**
```jsx
{
  "stage": "begin",
  "overallProgress": "0%", # 전체 진행률
  "timestamp": "2018-07-27T09:00:00.000+09:00" # 현재 진행중인 위치
}
```

**stage:channelBegin - 채널 시작**
```jsx
{
  "stage": "channelBegin",
  "overallProgress": "0%", # 전체 진행률
  "timestamp": "2018-07-27T09:00:00.000+09:00", # 현재 진행중인 위치
  "channel": {
    "chid": 1,         # 채널 번호
    "progress": "0%"   # 채널당 진행률
  }
}
```

**stage:fileBegin - 파일 생성 시작**
```jsx
{
  "stage": "fileBegin",
  "overallProgress": "37%",  # 전체 진행률
  "timestamp": "2018-07-27T09:11:19.825+09:00", # 현재 진행중인 위치
  "channel": {
    "chid": 1,         # 채널 번호
    "progress": "37%", # 채널당 진행률
    "file": {
      "fid": 1,        # 파일 번호
      "name": "CH1.2018-07-27T09.11.19.mp4"  # 파일명
    }
  }
}
```

**stage:fileWriting - 파일 생성 진행 중**
```jsx
{
  "stage": "fileWriting",
  "overallProgress": "42%",  # 전체 진행률
  "timestamp": "2018-07-27T09:12:49.466+09:00", # 현재 진행중인 위치
  "channel": {
    "chid": 1,         # 채널 번호
    "progress": "42%", # 채널당 진행률
    "file": {
      "fid": 1         # 파일 번호
    }
  }
}
```

**stage:fileEnd - 파일 생성 완료**
하나의 파일 생성이 완료되면 다음과 같이 다운로드 링크와 함께 ttl이 반환됩니다.
ttl 이내에 클라이언트는 서버에로 명령을 보내어 흐름을 제어해야 하며, 그렇지 않으면 서버는 자동으로 작업을 취소합니다.
```jsx
{
  "stage": "fileEnd",
  "overallProgress": "51%",  # 전체 진행률
  "timestamp": "2018-07-27T09:15:25.225+09:00", # 현재 진행중인 위치
  "channel": {
    "chid": 1,         # 채널 번호
    "progress": "51%", # 채널당 진행률
    "file": {
      "fid": 1,        # 파일 번호
      "ttl": 10000,    # 10000밀리초(10초) 이내에 클라이언트가 아무 명령을 보내지 않으면 서버는 작업을 자동 취소함
      "download": [
        # 생성된 동영상 파일
        {
          "fileName": "CH1.2018-07-27T09.11.19.mp4",
          "src": "http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.mp4",
          "md5": "1125ee2c3d20f30b31166c821204603d" # md5=true로 요청시 포함됨
        },
        # 생성된 자막 파일
        {
          "fileName": "CH1.2018-07-27T09.11.19.vtt",
          "src": "http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.vtt",
          "md5": "9176eec58f3be777ae7bd188a1f14165" # md5=true로 요청시 포함됨
        }
      ]
    }
  }
}
```

다운로드 링크는 `auth` 매개변수를 붙여서 다운로드할 수있습니다.
```ruby
http://host/download/7963635e-1bff-40e1-bbf3-3f17525aef40/CH1.2018-07-27T09.11.19.mp4&auth=YWRtaW46YWRtaW4
```

**stage:timeoutAlert - 대기 시간 종료 알림**
`fileEnd`에 명시된 ttl에 명시된 시간이 종료되기 직전에 곧 종료된다는 것을 알리기 위해 서버가 클라이언트로 보냅니다.
```jsx
{
  "stage": "timeoutAlert",
  "ttl": 2000         # 종료까지 남은 시간 2초
}
```
클라이언트는 이 메시지를 수신하면 `ttl`에 명시된 시간 내에 `wait` 명령을 서버로 전송해야 하며 그렇지 않으면 작업은 자동 취소됩니다.

**stage:channelEnd - 채널 완료**
```jsx
{
  "stage": "channelEnd",
  "overallProgress": "100%", # 전체 진행률
  "timestamp": "2018-07-27T09:30:00.000+09:00", # 현재 진행중인 위치
  "channel": {
    "chid": 1,         # 채널 번호
    "progress": "100%" # 채널당 진행률
  }
}
```

**stage:end - 작업 완료**
```jsx
{
  "stage": "end",
  "overallProgress": "100%", # 전체 진행률
  "timestamp": "2018-07-27T09:30:00.000+09:00", # 현재 진행중인 위치
  "status": {
    "code":0,
    "message":"성공"
  }
}
```
대표적인 `status` 코드는 다음과 같습니다.
```ruby
0: 성공
-1001: 저장할 공간 부족
-1003: 사용자에 의해 작업 취소됨
-1004: 시간 초과로 작업 종료됨
```


각 상황별로 클라이언트가 서버로 전송하는 명령 형식은 다음과 같습니다.
**cmd:wait - 대기 명령**
서버 측에서 생성된 동영상 파일은 다운로드가 끝나고 다음 파일을 생성하기 전에 즉시 삭제되므로
다운로드하는 동안 wait 명령을 계속 보내서 서버가 파일을 삭제하지 않도록 해야 합니다.

`wait` 명령을 한번 보내면 `fileEnd`시 명시된 `ttl`만큼 서버를 대기 시킬 수 있으며, 
다운로드 시간이 오래걸리면 주기적으로 wait 명령를 보내야 합니다.
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # stage:ready시 발급된 작업 번호
  "cmd": "wait"   # 대기 명령
}
```

**cmd:next - 작업 계속**
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # stage:ready시 발급된 작업 번호
  "cmd": "next"   # 다음 파일 작업으로 넘어감
}
```

**cmd:cancel - 작업 취소**
```jsx
{
  "task": "7963635e-1bff-40e1-bbf3-3f17525aef40",  # stage:ready시 발급된 작업 번호
  "cmd": "cancel"   # 클라이언트가 작업 취소
}
```

이 번에는 웹 소켓을 이용하여 동영상을 받아내는 예제를 만들어 봅시다.
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
  <h2>예제4. 녹화 영상 받아내기 (Web Socket)</h2>
  <div id='control'>
    <div>
      <input type='text' id='host-name' placeholder='서버 IP주소:포트'>
      <input type='text' id='user-id' placeholder='사용자 ID'> 
      <input type='password' id='password' placeholder='비밀번호'>
    </div>
    <div id='param'>
      <div>
        데이터 구간 : <input type='datetime-local' id='timeBegin' step='1' value='2018-07-27T09:00:00'>
        ~ <input type='datetime-local' id='timeEnd' step='1' value='2018-07-27T09:30:00'>
      </div>
      <div>
        채널: 
          <input type='checkbox' onclick='onSelectAllChannels(this)'>모두 선택
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
        파일 크기: <input type='text' id='mediaSize' placeholder='예) 500MB'>
      </div>
      <div>
        자막 형식: <select id='subtitleFormat'>
          <option value='SRT' selected>SRT</option>
          <option value='SMI'>SMI</option>
          <option value='VTT'>VTT</option>
          <option value='None'>사용안함</option>
        </select>
      </div>
      <div>
        제출자: <input type='text' id='submitter' placeholder='예) 흥부'>
      </div>
      <div>
        수령인: <input type='text' id='recipient' placeholder='예) 놀부'>
      </div>
      <div>
        용도: <textarea cols='40' rows='3' id='purpose' placeholder='예) 너무 배고파서...'></textarea>
      </div>
      <div>
        진행 표시 주기: <input type='text' id='statusInterval' placeholder='예) 2s' value='2s'>
      </div>
      <div>
        언어: <select id='lang'>
          <option value='ko-KR'>한국어</option>
          <option value='en-US'>영어</option>
          <option value='es-ES'>스페인어</option>
          <option value='zh-CN'>중국어 (간체)</option>
          <option value='zh-TW'>중국어 (번체)</option>
        </select>
      </div>
      <div>
        <input type='checkbox' id='md5' value='md5'>md5
      </div>
    </div>
    <div>
      <button type='button' onClick='onConnect()'>접속</button>
      <button type='button' onClick='onDisconnect()'>접속 종료</button>
      <button type='button' onClick='onClearAll()'>모두 삭제</button>
      <button type='button' onClick='onCancel()' id='cancel' style='visibility:hidden;color:red'>작업 취소</button>
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
      alert('웹 소켓을 지원하지 않는 웹 브라우저입니다.');
      return url;
    }

    if(window.myApp.ws !== null) {
      alert('이미 접속 중입니다.');
      return url;
    }
    
    var hostName = document.getElementById('host-name').value;
    if(hostName == '') {
      alert('호스트를 입력하십시오.');
      return url;
    }
    var userId = document.getElementById('user-id').value;
    if(userId == '') {
      alert('사용자 아이디를 입력하십시오.');
      return url;
    }
    var password = document.getElementById('password').value;
    if(password == '') {
      alert('비밀번호를 입력하십시오.');
      return url;
    }


    // 매개 변수들
    var timeBegin = document.getElementById('timeBegin').value;
    if(timeBegin == '') {
      alert('데이터 구간을 입력하십시오.');
      return url;
    }

    var timeEnd = document.getElementById('timeEnd').value;
    if(timeEnd == '') {
      alert('데이터 구간을 입력하십시오.');
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
      alert('채널을 선택하십시오.');
      return url;
    }
 
    var mediaSize = document.getElementById('mediaSize').value;
    if(mediaSize == '') {
      alert('동영상 파일의 최대 크기를 입력하십시오.');
      return url;
    }

    var subtitleFormat = document.getElementById('subtitleFormat').value;
    if(subtitleFormat == '') {
      alert('자막 형식을 선택하십시오.');
      return url;
    }

    var submitter = document.getElementById('submitter').value;
    if(submitter == '') {
      alert('제출자를 입력하십시오.');
      return url;
    }

    var recipient = document.getElementById('recipient').value;
    if(submitter == '') {
      alert('수령인을 입력하십시오.');
      return url;
    }

    var purpose = document.getElementById('purpose').value;
    if(purpose == '') {
      alert('용도를 입력하십시오.');
      return url;
    }

    var statusInterval = document.getElementById('statusInterval').value;
    if(statusInterval == '') {
      alert('진행 표시 주기를 입력하십시오.');
      return url;
    }

    var lang = document.getElementById('lang').value;
    if(lang == '') {
      alert('언어를 선택하십시오.');
      return url;
    }

    var encodedData = window.btoa(userId + ':' + password); // base64 인코딩
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

    // 웹 소켓 인스턴스와 핸들러 함수들
    var ws = new WebSocket(url);
    ws.onopen = function() {
      addItem('open', '접속 성공');
    };
    ws.onclose = function(e) {
      addItem('close', '접속 종료: ' + e.code);
      onDisconnect();
    };
    ws.onerror = function(e) {
      addItem('error', '오류: ' + e.code);
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

    // 다운로드 링크에 auth 매개변수를 붙여서 요청
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
    // 다운로드 작업을 모두 중단
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
[실행하기](./examples/ex4.html)



## 서버에 이벤트 밀어넣기 `@0.4.0`
외부의 장치나 소프로트웨어로부터 서버에 이벤트를 `HTTP POST` 방식으로 송신할 수 있습니다.

지원하는 이벤트 토픽은 다음과 같습니다.
```ruby
LPR             # 차량 번호
emergencyCall   # 비상 호출
```

서버로 이벤트를 송신하기 위한 경로와 매개변수들은 다음과 같습니다.
```ruby
POST /api/push

# 매개 변수들
auth    # 인증 정보
```

Contents에 JSON 형식으로 이벤트 데이터를 명시합니다.

**차량 번호 인식 데이터**
```jsx
{
  "topic": "LPR",         // 차량 번호 데이터
  "src": "F00001",        // 차량 번호 인식 장치 코드
  "plateNo": "01가2345",  // 차량 번호
  // 아래는 선택 항목임
  "when": "2018-02-01T14:30:15+09:00",      // 차량 번호 인식 시각, 명시하지 않으면 서버에서는 이벤트가 수신된 시각을 사용함
  "timeBegin": "2018-02-01T14:30:14+09:00"  // 주정차한 차량의 경우 차량 번호가 인식되기 시작한 시점
}
```

**비상 호출 데이터**
```jsx
{
  "topic": "emergencyCall",   // 비상 호출 데이터
  "device": "vendor/device",  // 비상 호출 장치 모델명
  "src": "0000001",           // 비상 호출 장치 위치 코드
  "event": "callStart",       // 통화 시작 (또는 통화 종료시 "callEnd")
  "when": "2018-02-01T14:30:15+09:00" // 이벤트 발생 시각
}
```

요청이 성공한 경우 서버는 HTTP 응답 코드 200을 반환하며 추가로 반환되는 Contents 데이터는 없습니다.

아래와 같이 여러 개의 이벤트를 배열로 만들어 한 번에 보낼 수도 있습니다.
```jsx
[
  {
    "topic": "LPR",
    "src": "F00001",
    "plateNo": "01가2345"
  },
  {
    "topic": "emergencyCall",
    "device": "vendor/device",
    "src": "0000001",
    "event": "callStart",
    "when": "2018-02-01T14:30:15+09:00"
  }
]
```

콘솔 창에서 curl 명령을 사용해서 테스트 해 볼 수 있습니다.
>1. 먼저 위의 json 데이터를 복사해서 UTF-8 인코딩 텍스트 파일로 `test.json` 이라는 이름으로 저장합니다.
>2. 서버 주소를 `192.168.0.100`, 웹 포트를 `80`으로 가정하고, 사용자 아이디를 `demo`, 비밀번호를 `!1234qwer` 라고 가정합니다.
>3. 콘솔 창을 열고 `test.json` 파일이 저장된 디렉토리로 이동한 다음, 아래와 같이 curl 명령을 실행합니다.
```bash
curl http://192.168.0.100/api/push -H "Content-Type: application/json; charset=UTF-8" -X POST -u demo:!1234qwer -d @test.json
```
>4. 또는 사용자 계정을 Base64 인코딩하고 URL 인코딩해서 `auth=` 매개변수를 사용할 수도 있습니다.
```bash
curl http://192.168.0.100/api/push?auth=ZGVtbzohMTIzNHF3ZXI%3D -H "Content-Type: application/json; charset=UTF-8" -X POST -d @test.json
```


## 채널 정보 및 장치 제어 `@0.5.0`

각 채널에 연결된 장치 정보 및 각 장치가 지원하는 기능 목록을 확인하거나 각 장치를 제어할 수 있습니다.


### 장치 정보 및 지원 기능 목록 요청
연결된 장치 정보는 다음과 같이 요청합니다.
```ruby
GET /api/channel/info

# 매개변수
caps    # "caps" 항목만 요청함, 지정하지 않으면 모든 정보를 포함
ch      # 채널을 지정함, 지정하지 않으면 사용중인 모든 채널
reload  # 채널의 카메라의 최신 정보로 갱신한 정보를 요청 (@0.9.1)

# 예
# 사용중인 각 채널 별로 연결된 장비의 지원 기능만 요청
GET /api/channel/info?caps

# 1번 채널에 연결된 장비의 지원 기능만 요청
GET /api/channel/info?caps&ch=1

# 1,2,3번 채널에 연결된 장비의 지원 기능만 요청
GET /api/channel/info?caps&ch=1,2,3

# 모든 채널의 카메라 정보를 최신 정보로 갱신 요청
GET /api/channel/info?caps&reload
```

요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,
    "type": "onvif"         // ONVIF 장치
    "caps": {               // 지원 기능
      "pantilt": true,      // 팬 틸트 기능 지원
      "zoom": true          // 줌 기능 지원
      "focus": false,       // 초점 제어 지원 안함
      "iris": false,        // 조리개 제어 지원 안함
      "home": true,         // 홈 포지션 기능 지원
      "maxPreset": 255,     // PTZ 프리셋 최대 255개 등록 지원
      "aux": 0,             // AUX 출력 없음
      "digitalInputs": 2,   // 디지털 입력 2개 지원
      "relayOutputs": 2,    // 릴레이 출력 2개 지원
      "reboot": true,       // 원격 재부팅 지원
    },
    "onvif": {              // ONVIF 장치 정보
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
  // ... 중략
]
```

**장치 제어 응답 코드**

서버의 각 채널이 장치 제어 기능을 지원할 경우 클라이언트 측에서 원격 제어할 수 있습니다.
원격 제어 기능들은 로그인 한 사용자 계정에 `장치 제어 권한`이 있는 경우만 동작합니다.

장치 제어 명령은 `/api/channel/` 다음에 개별 명령과 대상 채널과 추가로 필요한 매개변수를 지정하는 형식입니다.
여기서부터 사용할 예제에서는 대상 채널을 1번`ch=1`으로 가정했습니다.
```ruby
GET /api/channel/ptz?ch=1&home&indent=2
```

요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "code": 0,          // 응답 코드
  "message": "성공"
}
```
서버는 제어 명령을 보내고 나서 장치의 실행 결과를 기다리지 않고 장치와는 비동기로 HTTP 응답 코드 200으로 아래 코드 중 하나를 포함하는 JSON 데이터를 사용합니다.
```ruby
0     # 성공
-1    # 사용자 권한 없음
-2    # 장치가 지원하지 않는 기능
-3    # 장치가 명령을 수행할 준비가 안됨
-4    # 장치가 아직 이전 요청을 처리중 (busy)
-5    # 잘못된 채널
-6    # 잘못된 장치 토큰
-7    # 잘못된 요청
-8    # 잘못된 매개변수
-9    # 장치 응답 오류
```
위의 응답 코드는 모든 장치 제어 명령에 공통으로 사용됩니다.


`message` 부분은 언어를 지정하지 않은 경우 서버 측에 설정된 언어가 사용됩니다.
아래와 같이 매개변수에 언어를 지정하여 사용해도 됩니다.
```ruby
GET /api/channel/ptz?ch=1&home&lang=en_US
```
[지원하는 언어 목록](#지원하는-언어-목록)은 부록을 참고하십시오.



### 팬틸트 제어

장치가 팬틸트 기능을 지원할 경우 아래 명령들로 제어할 수 있습니다.
```ruby
# 매개변수가 없는 명령들
home    # 홈 위치로 복귀
stop    # 정지 (모든 이동에 대해 공통으로 사용)

# 매개변수와 함께 사용하는 명령들 (계속 이동 시키는 명령들)
move    # 가로 세로 방향 이동
zoom    # 줌 인 / 아웃
focus   # 초점 가까이 / 멀리
iris    # 조리개 열기 / 닫기
```

제어 명령은 반드시 하나의 대상 채널과 명령으로 구성됩니다.
예를 들어 `home` 명령일 경우 대상 채널을 매개변수로 지정해야 합니다.
```ruby
GET /api/channel/ptz?ch=1&home
```

매개변수와 함께 사용하는 명령들은 이동 방향과 속도를 지정해야 합니다.
방향과 속도를 가지는 명령들은 `stop` 명령을 보내기 전까지 계속 이동합니다.
`move` 명령은 가로, 세로의 이동 방향을 표현하기 위해 2개의 매개변수를 사용합니다.
그리고 이동 속도는 `0`과 `1` 사이의 소수값으로 표현합니다.
`-1`에서 `1` 사이의 소수값 2개를 사용하여 2차원 공간에 대해 현 위치로부터 이동 방향과 속도를 모두 표현할 수 있습니다.

![Alt 이동 방향과 속도](../img/ptz.png)

```ruby
GET /api/channel/ptz?ch=1&move=0.5,0.5  # 오른쪽 위 대각선 방향으로 중간 속도로 이동
GET /api/channel/ptz?ch=1&move=-1       # 왼쪽으로 최대 속도로 이동 (세로가 0인 경우는 생략 가능)
GET /api/channel/ptz?ch=1&move=0,0.1    # 아래쪽으로 느리게 이동
GET /api/channel/ptz?ch=1&move          # 가로, 세로 모두 0인 경우 모두 생략 가능, 정지 명령 stop과 동일함
```

나머지 `zoom`, `focus`, `iris` 명령은 모두 카메라 렌즈 제어 기능이며, 전진, 후진을 표현하기 위해 1개의 매개변수를 사용합니다.
마찬가지로 이동 속도와 방향을 함께 표현하기 위해 `-1`에서 `1` 사이의 소수값 1개를 사용하여 
1차원 공간에 대해 현 위치로부터 이동 방향과 속도를 모두 표현할 수 있습니다.
```ruby
GET /api/channel/ptz?ch=1&zoom=0.5      # 중간 속도로 줌인
GET /api/channel/ptz?ch=1&zoom=-0.5     # 중간 속도로 줌 아웃
GET /api/channel/ptz?ch=1&focus=0.1     # 아주 느리게 초점 가까이
GET /api/channel/ptz?ch=1&focus=-0.5    # 중간 속도로  초점 멀리
GET /api/channel/ptz?ch=1&iris=-0.1    # 아주 느리게 조리개 닫기
GET /api/channel/ptz?ch=1&iris=1       # 최대 속도로 조리개 열기
```

이동 명령에 대해 물리적인 이동 한계 지점과 속도는 각 장치의 고유 특성에 따라 다를 수 있습니다.



### 팬틸트 프리셋 제어

장치가 팬틸트 프리셋 기능을 지원할 경우 사용할 수 있습니다.

**프리셋 목록 요청**
이 명령은 서버가 이미 확보한 프리셋 목록을 요청합니다.
```ruby
# 채널 1번의 프리셋 목록을 요청하기
GET /api/channel/preset?ch=1&list

# 여러 채널의 프리셋 목록을 요청하기
GET /api/channel/preset?ch=1,2,3&list

# 모든 채널의 프리셋 목록을 요청하기
GET /api/channel/preset?list
```
매번 장치로부터 다시 읽어서 전송하지 않으므로 응답 시간이 빠른 반면, 
타 소프트웨어(예: 장치의 내장 웹 페이지)을 사용하여 프리셋 목록을 변경한 경우
서버는 변경된 목록이 아니라 이미 확보하고 있던 과거의 목록을 응답할 수 있습니다.

요청이 성공할 경우 서버는 다음과 같은 형식의 JSON 데이터로 응답합니다.
```jsx
[
  {
    "chid": 1,
    "code": 0,
    "message": "성공",
    "preset": [
      {
        "name": "정문",   // 각 프리셋 위치에 대해 사용자가 편의상 붙이는 이름
        "token": "1"      // 각 프리셋 위치를 가리키는 고유 아이디
      },
      {
        "name": "주차장",
        "token": "2"
      },
      // ... 중략
    ]
  },
  // ... 중략
]
```

**프리셋 목록 갱신 요청**
이 명령은 장치로부터 프리셋 목록을 다시 읽어서 전송합니다.
```ruby
# 채널 1번의 프리셋 목록을 갱신 요청하기
GET /api/channel/preset?ch=1&reload

# 여러 채널의 프리셋 목록을 갱신 요청하기
GET /api/channel/preset?ch=1,2,3&reload

# 모든 채널의 프리셋 목록을 갱신 요청하기
GET /api/channel/preset?reload
```
`list` 명령과 반대로 응답 시간이 느린 반면 항상 장치가 가지고 있는 프리셋 목록과 동일한 데이터를 받을 수 있습니다.


**프리셋 지정**
카메라의 현재 위치를 프리셋으로 설정합니다.

프리셋을 설정하기 위해서는 두 개의 매개변수가 필요합니다.
첫 번째 매개변수는 `프리셋 토큰`, 두 번째 매개변수는 `프리셋 이름`입니다.
프리셋 이름을 지정하지 않으면 `프리셋 토큰`이 이름이 사용됩니다.
동일한 `프리셋 토큰`의 프리셋이 이미 있으면 덮어쓰고, 그렇지 아니면 새로 추가됩니다.
카메라가 지원하는 최대 프리셋 갯수는 [장치 정보 및 지원 기능 목록 요청](#장치-정보-및-지원-기능-목록-요청)을 사용하여 확인할 수 있습니다.

카메라가 다양한 문자를 지원하지 않으므로 `프리셋 토큰`은 가능하면 숫자로 지정하길 권장합니다.
다만 `프리셋 이름`은 카메라 대신 서버에 저장되므로 문자 제약없이 다양한 문자열을 사용할 수 있습니다.
문자열을 정상적으로 보내기 위해서는 URL 인코딩하는 것을 잊지 마십시오.

```ruby
# 프리셋 이름: preset1 (프리셋 토큰은 카메라에서 생성되며 응답 데이터에 포함됩니다.)
GET /api/channel/preset?ch=1&set=preset1 

# 프리셋 이름을 생략
GET /api/channel/preset?ch=1&set

# 프리셋 이름: 우리집 현관
GET /api/channel/preset?ch=1&set=%EC%9A%B0%EB%A6%AC%EC%A7%91%20%ED%98%84%EA%B4%80
```

프리셋 지정 요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "chid": 1,
  "deviceResponseCode": 200,  // 카메라의 응답 코드
  "code": 0,                  // 응답 코드
  "message": "성공",          // 응답 메시지
  "token": "preset3",         // 카메라에서 생성된 프리셋 토큰
  "name": "우리집 현관"
}
```

**프리셋 삭제**
지정한 프리셋 토큰의 프리셋을 삭제합니다.

프리셋을 삭제하기 위해서는 `프리셋 토큰`을 매개변수로 지정해야 합니다.
```ruby
# 토큰 1의 프리셋을 삭제
GET /api/channel/preset?ch=1&rm=1

# 여러 개의 프리셋을 삭제
GET /api/channel/preset?ch=1&rm=1,2,3
```

프리셋 삭제 요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "chid": 1,
  "preset":[
    {
      "deviceResponseCode":200,   // 카메라의 응답 코드
      "code": 0,                  // 응답 코드
      "message": "성공",          // 응답 메시지
      "token": "preset1"          // 삭제된 프리셋 토큰
    },
    // ... 중략
  ]
}
```

**프리셋 위치로 이동**

지정한 프리셋 토큰의 프리셋 위치로 이동합니다.

프리셋 위치로 이동시키기 위해서는 `프리셋 토큰`을 매개변수로 지정해야 합니다.
```ruby
GET /api/channel/preset?ch=1&go=1 # 프리셋 1번으로 이동
```


### 릴레이 출력

장치가 릴레이 출력을 지원할 경우 다음과 같이 릴레이 출력의 목록을 요청할 수 있습니다.
릴레이 출력 목록을 얻기 위해서는 장치가 연결된 하나의 채널을 지정해야 합니다.
```ruby
# 채널 1번에 연결된 릴레이 출력 목록 요청
GET /api/channel/relay?ch=1&list

# 여러 채널의 릴레이 출력 목록을 요청하기
GET /api/channel/relay?ch=1,2,3&list

# 모든 채널의 릴레이 출력 목록을 요청하기
GET /api/channel/relay?list
```

요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
[
  {
    "chid": 1,
    "code": 0,          // 응답 코드
    "message": "성공",  // 응답 메시지
    "relay": [
      {
        "name": "계단",   // 이름
        "token": "7657b9aa-61d6-4b4f-a70a-c91e8657dfcf" // 릴레이 출력 토큰
      },
      {
        "name": "창고",
        "token": "cffd1289-cb2c-4d82-8c6f-c7634b432f57"
      }
    ]
  },
  // ... 중략
]
```

릴레이 출력 명령은 `on` 또는 `off` 명령과 하나 이상의 릴레이 출력 토큰을 사용하여 지정합니다.
```ruby
# 7657b9aa-61d6-4b4f-a70a-c91e8657dfcf 출력을 켜기
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf

# 7657b9aa-61d6-4b4f-a70a-c91e8657dfcf 출력을 끄기
GET /api/channel/relay?ch=1&off=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf

# 두 개의 출력을 동시에 켜기
GET /api/channel/relay?ch=1&off=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf,cffd1289-cb2c-4d82-8c6f-c7634b432f57

# on과 off를 인자에 동시 지정할 경우 off 명령은 무시됩니다.
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf&off=cffd1289-cb2c-4d82-8c6f-c7634b432f57

# 하나는 켜고 하나는 끌 경우는 각각 명령을 나누어 각 각 보내야 합니다.
GET /api/channel/relay?ch=1&on=7657b9aa-61d6-4b4f-a70a-c91e8657dfcf
GET /api/channel/relay?ch=1&off=cffd1289-cb2c-4d82-8c6f-c7634b432f57
```


### AUX 출력

장치가 AUX 출력을 지원할 경우 `릴레이 출력`와 마찬가지로 `on` 또는 `off` 명령을 사용합니다.
AUX 출력은 토큰 대신 0부터 시작하는 번호를 사용하여 지정합니다.
```ruby
# AUX 0 출력을 켜기
GET /api/channel/aux?ch=1&on=0

# AUX 1 출력을 끄기
GET /api/channel/aux?ch=1&off=1

# 두 개의 출력을 동시에 켜기
GET /api/channel/aux?ch=1&on=0,1

# on과 off를 인자에 동시 지정할 경우 off 명령은 무시됩니다.
GET /api/channel/aux?ch=1&on=0&off=1

# 하나는 켜고 하나는 끌 경우는 각각 명령을 나누어 각 각 보내야 합니다.
GET /api/channel/aux?ch=1&on=0
GET /api/channel/aux?ch=1&off=1
```


### 장치 재부팅

장치가 지원할 경우 원격으로 아래 명령으로 재부팅 시킬 수 있습니다.

```ruby
GET /api/channel/reboot?ch=1    # 1번 채널의 카메라 재부팅

```

요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```jsx
{
  "code": 0,
  "message": "성공"
}
```
응답을 보낸 후 카메라는 수 초 내에 재부팅을 시작합니다.
재부팅이 완료되데 일반적으로 1분 정도의 시간이 걸리 수 있으며 카메라마다 다를 수 있습니다.

클라이언트 소프트웨어 관점에서는 재부팅 명령을 보낸 후 영상 접속이 끊어진 후부터 
주기적으로 재 접속을 시도해서 재부팅이 완료되는 과정을 모니터링할 필요가 있습니다.


## 채널 추가 `@0.9.7`

아래와 같이 채널을 추가할 수 있습니다.
```ruby
POST /api/channel

# 사용 가능한 매개변수
auth  # 이미 로그인 상태가 아닌 경우 API 호출시 로그인
lang  # 오류 코드 메시지에 사용될 언어 지정

# 사용 예
POST /api/channel?auth=ZGVtbzohMTIzNHF3ZXI%3D
POST /api/channel?lang=vi-VN   # 베트남어로 지정
```

### 요청 데이터
POST 데이터에 `JSON` 형식으로 추가할 채널 정보를 정의합니다.
여러 채널을 지정할 수 있도록 배열 형식을 사용합니다.

일부 데이터 항목들은 동영상 소스의 종류에 따라 다르게 정의되어 있습니다.
#### 카메라
`ONVIF` 프로토콜을 지원하는 카메라를 추가할 수 있습니다.
선택 항목들은 명시하지 않으면 default 값으로 간주됩니다.
```jsx
[
  {
    "chid": 1,                                       # [선택] 1) 등록할 채널 번호 
    "name": "내 동영상 스트림",                       # [선택] 등록할 채널 이름
    "source": "rtsp://192.168.0.220:554/stream1",    # [필수] RTSP URL
    "tcp": true,                                     # [선택] RTP 프로토콜, true: TCP (default), false: UDP
    "substream": false,                              # [선택] 2) Substream 사용 여부, true: Substream 사용 (default), false: Substream 사용 안함
    "uid": "admin",                                  # [선택] RTSP 인증 id
    "password": "admin",                             # [선택] RTSP 인증 비밀번호
    "device": {                                      # [필수] ONVIF 카메라로 등록 (ONVIF 기능 사용 가능)
      "name": "내 카메라",                            # [선택] 등록할 카메라 이름
      "url": "onvif://192.168.0.220:8000"            # [필수] 3) 카메라 장치 URL
    }
  }
]
```
1. `chid`:
   - 1부터 시작하는 채널 번호
   - `chid`를 명시하지 않으면 앞 쪽부터 빈자리에 자동 할당됩니다.
2. `substream`: 
   - 카메라의 동일 입력 소스에서 등록된 동영상 스트림보다 저해상도 스트림이 있는 경우 분할 화면에서 디스플레이 영역이 작은 경우, 자동으로 저해상도 스트림을 표시하도록 동작합니다.
   - 이 기능을 사용하지 않고 지정한 동영상 스트림만 사용하고자 할 경우, `substream` 항목을 `false`로 지정합니다.
3. `url` (카메라 장치 URL):
   - 원래 `http://192.168.0.220:8000` 형식이지만 `ONVIF` 장치임을 명시하기 위해 `onvif://192.168.0.220:8000` 로 표기합니다.


#### 동영상 스트림 
`RTSP` 프로토콜을 사용하는 동영상 스트림을 추가할 수 있습니다.
카메라의 경우에도 동영상 스트림 외에 다른 기능을 사용하지 않을 경우 사용할 수 있습니다.

```jsx
[
  {
    "chid": 2,                                        # [선택] 등록할 채널 번호, 명시하지 않으면 자동 할당됨
    "name": "내 동영상 스트림",                        # [선택] 등록할 채널 이름
    "source": "rtsp://192.168.0.220:554/stream1",     # [필수] RTSP URL
    "tcp": true,                                      # [선택] RTP 프로토콜, true: TCP (default), false: UDP
    "uid": "admin",                                   # [선택] RTSP 인증 id
    "password": "admin",                              # [선택] RTSP 인증 비밀번호    
  }
]
```

#### 동영상 파일
로컬 PC 또는 윈도우 공유 폴더에 있는 동영상 파일을 추가할 수 있습니다.

```jsx
[
  {
    "chid": 1,                                         # [선택] 등록할 채널 번호, 명시하지 않으면 자동 할당됨
    "name": "내 PC 동영상",                             # [선택] 등록할 채널 이름
    "source": "C:\\videos\\sample.mp4",                # [필수] 1) 동영상 파일명 (full path)
    "playback": "once"                                 # [선택] once: 한 번 재생, repeat: 반복 재생 (default)
  },
  {
    "chid": 2,                                         # [선택] 등록할 채널 번호, 명시하지 않으면 자동 할당됨
    "name": "친구 PC 공유 폴더 동영상",                  # [선택] 등록할 채널 이름
    "source": "\\\\192.168.0.14\\videos\\sample.mp4",  # [필수] 1) 동영상 파일명 (full path)
  }
]
```
1. `videoSrc` (동영상 파일명): 
   - `\`문자를 하나만 사용할 경우 `ESCAPE` 문자로 해석되므로 파일 경로를 표기할 때 `\\` 를 사용합니다.


### 응답

- 요청 데이터 예
```jsx
[
  {
    "name": "내 동영상 스트림",
    "source": "rtsp://192.168.0.162:554/stream1",
    "uid": "admin",
    "password": "admin",
    "tcp": true
  },
  {
    "name": "내 카메라",
    "source": "rtsp://192.168.0.30:554/stream1",
    "tcp": true,
    "substream": false,
    "uid": "admin",
    "password": "admin",
    "device": {
      "name": "내 카메라",
      "url": "onvif://192.168.0.30:80"
    }
  },
  {
    "name": "내 동영상 파일",
    "source": "C:\\video\\myVideo.mp4",
    "playback": "once"
  }
]
```

#### 응답 데이터

위 예제와 같이 요청한 경우 서버는 다음과 같이 HTTP 응답 코드와 함께 JSON 데이터로 응답합니다.

```jsx
{
  "status": {
    "code": 0,                               # 오류 코드
    "message": "채널이 성공적으로 추가되었습니다."  # 오류 메시지
  },
  "added": [
    {
      "chid": 1,                             # 할당된 채널 번호
      "name": "내 스트림",
      "type": "rtsp",                        # 채널 종류 (RTSP 스트림)
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
      "tcp": true,
      "sharedFrameBuffer": {                 # 공유 프레임 버퍼 API 기능 사용시 프레임 버퍼 인터페이스
        "data": "sfb_data_ch1",              # 프레임 버퍼의 공유 메모리 이름
        "event": "sfb_event_ch1"             # 프레임 버퍼 갱신 이벤트 이름
      }
    },
    {
      "chid": 2,                             # 할당된 채널 번호
      "name": "내 카메라",
      "type": "onvif",                       # 채널 종류 (ONVIF 카메라)
      "device": "onvif://192.168.0.30:80",   # 장치 URL
      "source": "rtsp://192.168.0.30:554/stream1",
      "tcp": true,                           # RTP 프로토콜 TCP 사용 여부 (false 이면 UDP)
      "substream": false,                    # ONVIF 카메라의 경우 서브스트림 사용 여부
      "sharedFrameBuffer": {
        "data": "sfb_data_ch2",
        "event": "sfb_event_ch2"
      }
    },
    {
      "chid": 3,                             # 할당된 채널 번호
      "name": "내 동영상 파일",
      "type": "file",                        # 채널 종류 (파일)
      "source": "C:\\video\\myVideo.mp4",
      "playback": "once",                    # once: 동영상 한 번 재생, repeat: 반복 재생
      "sharedFrameBuffer": {
        "data": "sfb_data_ch3",
        "event": "sfb_event_ch3"
      }
    }
  ]
}
```

만약 오류가 발생할 경우 응답 데이터는 아래 예와 같습니다.
- 요청한 채널 전체를 추가하지 못한 경우
  
```jsx
{
  "status": {
    "code": -6,                              # 오류 코드
    "message": "채널을 추가할 수 없습니다."    # 오류 메시지
  },
  "failed": [                                # 실패한 목록
    {
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
    },
    {
      "source": "C:\\video\\myVideo.mp4",
    }
  ]
}
```

- 요청한 채널 중 일부를 추가하지 못한 경우

```jsx
{
  "status": {
    "code": -5,                              # 오류 코드
    "message": "일부 채널만 추가되었습니다."   # 오류 메시지
  },
  "added": [                                 # 추가된 목록
    {
      "chid": 2,                             # 할당된 채널 번호
      "name": "내 카메라",
      "type": "onvif",                       # 채널 종류 (ONVIF 카메라)
      "device": "onvif://192.168.0.30:80",   # 장치 URL
      "source": "rtsp://192.168.0.30:554/stream1",
      "tcp": true,                           # RTP 프로토콜 TCP 사용 여부 (false 이면 UDP)
      "substream": false,                    # ONVIF 카메라의 경우 서브스트림 사용 여부
      "sharedFrameBuffer": {
        "data": "sfb_data_ch2",
        "event": "sfb_event_ch2"
      }
    }
  ],
  "failed": [                                # 실패한 목록
    {
      "source": "rtsp://admin:admin@192.168.0.162:554/stream1",
    },
    {
      "source": "C:\\video\\myVideo.mp4",
    }
  ]
}
```

- 오류 코드
`status`의 `code` 항목은 성공할 경우 이외에도 다음과 같은 오류 코드를 반환할 수 있습니다.

    | 코드   | 설명                                                |
    |------|------------------------------------------------------|
    | `0`  | 성공                                                  |
    | `-1` | 지정한 채널 번호가 이미 사용중인 경우                    |
    | `-2` | 필수 항목인 `source`가 없는 경우                        |
    | `-3` | `device` 항목이 있는 경우, 필수 항목인 `url`이 없는 경우 |
    | `-4` | 라이센스 상 최대 채널 수를 초과하여 요청한 경우          |
    | `-5` | 일부 채널을 추가하지 못한 경우                         |
    | `-6` | 요청받은 채널 전체를 추가하지 못한 경우                 |

 

## 채널 삭제 `@0.9.7`

아래와 같이 채널을 삭제할 수 있습니다.
요청 데이터는 사용하지 않고 매개변수 만으로 삭제할 채널을 지정합니다.
```ruby
DELETE /api/channel/{id}

# {id} 부분에는 삭제할 채널 번호를 지정합니다.
# 콤마(,) 문자를 사용하여 여러 채널을 지정할 수 있습니다.
# 또는 all을 사용하여 전체 체널을 지정할 수 있습니다.
DELETE /api/channel/1          # 1번 채널 삭제
DELETE /api/channel/1,2,3      # 1,2,3번 채널 삭제
DELETE /api/channel/all        # 모든 채널 삭제


# 사용 가능한 매개변수
auth  # 이미 로그인 상태가 아닌 경우 API 호출시 로그인
lang  # 오류 코드 메시지에 사용될 언어 지정

# 사용 예
DELETE /api/channel/1,2,3?auth=ZGVtbzohMTIzNHF3ZXI%3D
DELETE /api/channel/all?lang=vi-VN   # 베트남어로 지정
```

#### 응답 데이터

채널 삭제 요청에 대해 서버는 다음과 같이 HTTP 응답 코드와 함께 JSON 데이터로 응답합니다.

```jsx
{
  "status": {
    "code": 0,    # 오류 코드
    "message": "채널이 성공적으로 삭제되었습니다."  # 오류 메시지
  },
  "deleted": [    # 삭제된 채널 목록
    1,
    2,
    3
  ]
}
```

만약 오류가 발생할 경우 응답 데이터는 아래 예와 같습니다.
- 요청한 채널 전체를 삭제하지 못한 경우
  
```jsx
{
  "status": {
    "code": -6,   # 오류 코드
    "message": "채널을 삭제할 수 없습니다."  # 오류 메시지
  },
  "failed": [     # 실패한 채널 목록
    1,
    2,    
    3
  ]
}
```

- 요청한 채널 중 일부를 삭제하지 못한 경우

```jsx
{
  "status": {
    "code": -5,   # 오류 코드
    "message": "일부 채널만 삭제되었습니다."  # 오류 메시지
  },
  "deleted": [    # 삭제된 채널 목록
    1
  ],
  "failed": [     # 실패한 채널 목록
    2,
    3
  ]
}
```

- 오류 코드
`status`의 `code` 항목은 성공할 경우 이외에도 다음과 같은 오류 코드를 반환할 수 있습니다.

    | 코드   | 설명                                 |
    |------|---------------------------------------|
    | `0`  | 성공                                   |
    | `-7` | 삭제할 채널 번호가 지정되지 않은 경우    |
    | `-8` | 지정한 채널이 존재하지 않는 경우         |
    | `-9` | 일부 채널을 삭제하지 못한 경우          |
    | `-10` | 요청받은 모든 채널을 삭제하지 못한 경우 |



## 부록


### 제품별 API 지원 버전

API를 지원하는 제품들의 버전은 다음과 같습니다.

| API 버전 | TS-CMS     | TS-NVR     | TS-LPR     |
|--------|------------|------------|------------|
| 0.1.0  | v0.38.0 이상 | v0.35.0 이상 | v0.2.0A 이상 |
| 0.2.0  | v0.41.0 이상 | v0.40.0 이상 | v0.7.0A 이상 |
| 0.3.0  | v0.42.1 이상 | v0.41.1 이상 | v0.8.2A 이상 |
| 0.4.0  | v0.44.7 이상 | v0.44.7 이상 | v0.11.7A 이상 |
| 0.5.0  | v0.45.0 이상 | v0.45.0 이상 | v0.12.0A 이상 |
| 0.6.0  | v0.46.0 이상 | v0.46.0 이상 | v0.14.0A 이상 |
| 0.7.0  | v0.46.2 이상 | v0.46.2 이상 | v0.14.2A 이상 |
| 0.8.0  | v0.46.6 이상 | v0.46.6 이상 | v0.14.6A 이상 |
| 0.9.0  |              |             | v0.14.7A 이상 |

API는 모든 제품군에 호환되지만, 제품별 또는 라이센스별로 일부 기능이 지원되지 않을 수 있습니다. 아래 목록 중에서 사용하는 제품이 어디에 해당하는지 확인하시기 바랍니다.


### 제품별 기능 지원 표

| 구분                                  | TS-CMS | TS-NVR          | TS-LPR |
|-------------------------------------|--------|-----------------|--------|
| [실시간 영상 표시](#실시간-영상-표시)             | O      | O               | O      |
| [실시간 영상 소스 검색](#실시간-영상-소스)          | O      | O               | O      |
| [녹화 영상 표시](#녹화-영상-표시)               | X      | O               | O      |
| [녹화 영상 소스 검색](#녹화-영상-소스)            | X      | O               | O      |
| [세션 인증](#세션-인증)                     | O      | O               | O      |
| [서버 정보 요청](#서버-정보-요청)               | O      | O               | O      |
| [각종 목록 요청](#각종-목록-요청)               | O      | O               | O      |
| [녹화 영상이 있는 날짜 검색](#녹화-영상이-있는-날짜-검색) | X      | O               | O      |
| [이벤트 로그 검색](#이벤트-로그-검색)             | O      | O               | O      |
| [차량 번호 로그 검색](#차량-번호-로그-검색)         | X      | 라이센스에 준함 `[참고]` | O      |
| [서버에 이벤트 밀어넣기](#서버에-이벤트-밀어넣기-040)   | X      | O       | O      |
| [채널 정보 및 장치 제어](#채널-정보-및-장치-제어-050) | O  | O                        | O      |

> [참고]
TS-NVR은 자체적인 차량 번호 인식 기능이 없어 **차량 번호 로그 검색** 기능을 지원하지 않습니다. 
하지만 **차량 번호 인식 장치 연동** 부가 기능 라이센스를 사용하는 경우 별도의 차량 번호 인식 장치와 연동하여 차량 번호 로그를 저장하기 때문에 **차량 번호 로그 검색** 기능을 사용할 수 있습니다.



### base64 인코딩
base64 인코딩 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.
* https://www.base64encode.org/
* https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
* https://www.w3schools.com/jsref/met_win_btoa.asp



### URL 인코딩
URL 인코딩 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.

* http://www.convertstring.com/ko/EncodeDecode/UrlEncode
* https://www.urlencoder.org/
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
* https://www.w3schools.com/jsref/jsref_encodeuricomponent.asp



### URL 디코딩
URL 디코딩에 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.
* http://www.convertstring.com/ko/EncodeDecode/UrlDecode
* https://www.urldecoder.org/
* https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent
* https://www.w3schools.com/jsref/jsref_decodeuricomponent.asp



### ISO 8601 형식으로 날짜 시각 표현하기

```
YYYY-MM-DDThh:mm:ss.sss±Hh:Mm (로컬 타임 표기)
또는
YYYY-MM-DDThh:mm:ss.sssZ (UTC 표기)
또 하나 더
YYYY-MM-DDThh:mm:ss.sss (서버의 로컬 타임)

여기서,
  YYYY: 년
  MM: 월
  DD: 일
  hh: 시 (24시 표기)
  mm: 분
  ss: 초
  sss: 1/n 초
  Hh: UTC 시간 오프셋의 시
  Mm: UTC 시간 오프셋의 분
```

예를 들어, `2018년 2월 1일 오후 2시 30분 15초`의 경우
>1. 날짜 부분의 년, 월, 일은 각각 숫자 4문자, 2문자, 2문자로 표현하며 구분자로 하이픈 문자(`-`)를 사용합니다. 그리고 자릿수가 남는 경우 앞에 `0`으로 채웁니다.
`예) 2018-02-01`
>2. 시각 부분의 시, 분, 초는 각각 숫자 2문자, 2문자, 2문자로 표현하며 구분자로 콜론 문자(`:`)를 사용합니다. 24시 표기를 사용하며 자릿수가 남는 경우 마찬가지로 앞에 `0`으로 채웁니다.
`예) 14:30:15`
동영상은 일반적으로 1초 동안 여러 장면의 이미지로 구성되기 떄문에 초 이하의 단위를 사용해서 정확한 장면을 지정해야 하는 경우도 많습니다. 이 경우 초 단위 미만의 값에 대해 소수점 표기를 사용할 수 있습니다.
`예) 14:30:15.253 => 14시 30분 15초 253 밀리초(1/1000초)`
>3. 날짜와 시간은 `T` 문자로 구분하여 합칩니다.
`예) 2018-02-01T14:30:15.253`
>4. 표준 시간대(타임존)를 사용하여 어느 지역의 시각인지 추가로 표현합니다.
대한민국 서울의 경우 영국 표준 시각(UTC)보다 9시간 빠르므로 다음과 같이 표기합니다.
`예) +09:00 (또는 간단히 +0900 또는 +09)`
만약 UTC 시각으로 표기할 경우는 `+00:00` 표기 대신 `Z` 문자를 사용하여 끝마치면 됩니다.
>5. 위의 조각들을 모두 합치면 다음과 같습니다.
`예) 2018-02-01T14:30:15+09:00  (로컬 타임)`
>6. 이 문자열을 URL 인코딩하면 아래와 같습니다.
`예) 2018-02-01T14%3A30%3A15%2B09%3A00`




### 지원하는 언어 목록
서버는 다음과 같이 총 104개 언어를 지원합니다.
```ruby
af-ZA       # 아프리카어, Afrikaans
sq-AL       # 알바니아어, Shqip, Albanian
am-ET       # 암하라어, አማርኛ, Amharic
ar-AE       # 아랍어, العربية, Arabic
hy-AM       # 아르메니아어, Հայերեն, Armenian
az-Latn     # 아제르바이잔어, Azərbaycan, Azerbaijani
eu-ES       # 바스크어, Euskara, Basque
be-BY       # 벨라루스어, беларускі, Belarusian
bn-BD       # 벵골어, বাংলা, Bengali
bs-Latn     # 보스니아어, Bosanski, Bosnian
bg-BG       # 불가리아어, български, Bulgarian
ca-ES       # 카탈로니아어, Català, Catalan
ceb         # 세부아노, Cebuano
ny          # 체와어, Chichewa
zh-CN       # 중국어 (간체), 简体中国, Chinese (Simplified)
zh-TW       # 중국어 (번체), 中國傳統, Chinese (Traditional)
co-FR       # 코르시카어, Corsu, Corsican
hr-HR       # 크로아티아어, Hrvatski, Croatian
cs-CZ       # 체코어, Čeština, Czech
da-DK       # 덴마크어, Dansk, Danish
nl-NL       # 네덜란드어, Nederlands, Dutch
en-US       # 영어, English
eo          # 에스페란토어, Esperanto
et-EE       # 에스토니아어, Eesti keel, Estonian
fil-PH      # 필리핀어, Filipino
fi-FI       # 핀란드어, Suomalainen, Finnish
fr-FR       # 프랑스어, Français, French
fy-NL       # 프리지아어, Frysk, Frisian
gl-ES       # 갈리시아어, Galego, Galician
ka-GE       # 조지아어, ქართული, Georgian
de-DE       # 독일어, Deutsch, German
el-GR       # 그리스어, Ελληνικά, Greek
gu-IN       # 구자라트어, ગુજરાતી, Gujarati
ht          # 아이티 크리올어, Kreyòl ayisyen, Haitian Creole
ha          # 하우사어, Hausa
haw-U       # 하와이어, ʻŌlelo Hawaiʻi, Hawaiian,
he-IL       # 히브리어, עברית, Hebrew
hi-IN       # 힌디어, हिन्दी, Hindi
hmn         # 몽어, Hmong
hu-HU       # 헝가리어, Magyar, Hungarian
is-IS       # 아이슬란드어, Íslensku, Icelandic
ig-NG       # 이그보어, Igbo
id-ID       # 인도네시아어, Bahasa Indonesia, Indonesian
ga-IE       # 아일랜드어, Gaeilge, Irish
it-IT       # 이탈리아어, Italiano, Italian
ja-JP       # 일본어, 日本語, Japanese
jv-Latn     # 자바어, Jawa, Javanese
kn-IN       # 칸나다어, ಕನ್ನಡ, Kannada
kk-KZ       # 카자흐어, Қазақ тілінде, Kazakh
km-KH       # 크메르어, ភាសាខ្មែរ, Khmer
ko-KR       # 한국어, Korean
ku-Arab-IR  # 쿠르드어 (쿠르만지어), Kurdî, Kurdish (Kurmanji)
ru-KG       # 키르기스어, Кыргызча, Kyrgyz
lo-LA       # 라오어, ລາວ, Lao
sr-Latn     # 라틴어, Latine, Latin
lv-LV       # 라트비아어, Latviešu, Latvian
lt-LT       # 리투아니아어, Lietuviškai, Lithuanian
lb-LU       # 룩셈부르크어, Lëtzebuergesch, Luxembourgish
mk-MK       # 마케도니아어, Македонски, Macedonian
mg-MG       # 말라가시어, Malagasy
ms-MY       # 말레이어, Melayu, Malay
ml-IN       # 말라얄람어, മലയാളം, Malayalam
mt-MT       # 몰타어, Malti, Maltese
mi-NZ       # 마오리어, Maori
mr-IN       # 마라티어, मराठी, Marathi
mn-MN       # 몽골어, Монгол хэл дээр, Mongolian
my-MM       # 미얀마어 (버마어), မြန်မာ", Myanmar (Burmese)
ne-NP       # 네팔어, नेपाली, Nepali
nb-NO       # 노르웨이어, Norwegian
ps-AF       # 파슈토어, پښتو, Pashto
fa-IR       # 페르시아어, فارسی, Persian
pl-PL       # 폴란드어, Polskie, Polish
pt-PT       # 포르투갈어, Português, Portuguese
pa-IN       # 펀자브어, ਪੰਜਾਬੀ, Punjabi
ro-RO       # 루마니아어, Română, Romanian
ru-RU       # 러시아어, Русский, Russian
sm          # 사모아어, Samoan
gd-GB       # 스코틀랜드 게일어, Gàidhlig, Scots Gaelic
sr-Cyrl-RS  # 세르비아어, Српски, Serbian
nso-ZA      # 세소토어, Sesotho
sn-Latn-ZW  # 쇼나어, Shona
sd-Arab-PK  # 신디어, سنڌي, Sindhi
si-LK       # 신할라어, සිංහල, Sinhala
sk-SK       # 슬로바키아어, Slovenský, Slovak
sl-SI       # 슬로베니아어, Slovenščina, Slovenian
so-SO       # 소말리아어, Soomaali, Somali
es-ES       # 스페인어, Español, Spanish
su          # 순다어, Basa Sunda, Sundanese
swc-CD      # 스와힐리어, Kiswahili, Swahili
sv-SE       # 스웨덴어, Svenska, Swedish
tg-Cyrl-TJ  # 타지크어, Тоҷикистон, Tajik
ta-IN       # 타밀어, தமிழ், Tamil
te-IN       # 텔루구어, తెలుగు, Telugu
th-TH       # 태국어, ไทย, Thai
tr-TR       # 터키어, Türkçe, Turkish
uk-UA       # 우크라이나어, Українська, Ukrainian
ur-PK       # 우르두어, اردو, Urdu
uz-Latn-UZ  # 우즈베크어, O'zbek, Uzbek
vi-VN       # 베트남어, Tiếng Việt, Vietnamese
cy-GB       # 웨일즈어, Cymraeg, Welsh
xh-ZA       # 코사어, isiXhosa, Xhosa
yi          # 이디시어, ייִדיש, Yiddish
yo-NG       # 요루바어, Yorùbá, Yoruba
zu-ZA       # 줄루어, isiZulu, Zulu
```


### JSON 데이터 형식
서버는 데이터의 전송 속도 향상을 위해 JSON 데이터 내에 줄 바꿈이나 공백 문자를 사용하지 않습니다. 예를 들면 다음과 같은 형태의 텍스트를 사용합니다.
```json
{"apiVersion":"TS-API@0.2.0","siteName":"%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84","timezone":{"name":"Asia/Seoul","bias":"+09:00"},"product":{"name":"TS-LPR","version":"v0.5.0A (64-bit)"},"license":{"type":"genuine","maxChannels":16}}
```
이렇게 한 줄로 길게 나열되어 있어 사람이 읽기에는 다소 불편할 수 있습니다.

이 경우 아래와 같은 도구들을 사용하면 읽기 쉽게 변환해 줍니다.
* http://www.csvjson.com/json_beautifier
* https://codebeautify.org/jsonviewer
* https://jsonformatter.curiousconcept.com/
* https://jsonformatter.org/

읽기 쉽게 변환된 JSON 데이터는 다음과 같은 형태입니다.
```json
{
  "apiVersion": "TS-API@0.2.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
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
물론 내용면으로는 둘 다 완전히 같은 데이터입니다.



### 피드백
우리는 항상 고객의 의견에 항상 귀기울이고 있습니다.
개발 관련 문의 사항이나 개선할 부분이 있으시면 https://github.com/bobhyun/TS-API/issues 에 남겨주시기 바랍니다.
