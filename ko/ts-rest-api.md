# ts-rest-api 프로그래밍 안내서

## 순서

[개요](#개요)
>[버전](#버전)
>[피드백](#피드백)
[미리 알아야 할 것](#미리-알아야-할-것)
[제품별 기능 지원 표](#제품별-기능-지원-표)

[시작하기](#시작하기)
>[동영상 보기](#동영상-보기)
>[웹 페이지에 동영상 삽입하기](#웹-페이지에-동영상-삽입하기)

[실시간 영상 표시](#실시간-영상-표시)
>[실제 서버에 접속하기](#실제-서버에-접속하기)
>[사용자 인증](#사용자-인증)
>[base64 인코딩](#base64-인코딩)
>[채널 변경](#채널-변경)

[녹화 영상 표시](#녹화-영상-표시)
>[날짜, 시각 표기법](#날짜-시각-표기법)
>[URL 인코딩](#url-인코딩)
>[지원하는 언어 목록](#지원하는-언어-목록)

[JSON 데이터](#json-데이터)

[세션 인증](#세션-인증)
>[로그인](#로그인)
>[로그아웃](#로그아웃)


[서버 정보 요청](#서버-정보-요청)
>[API 버전](#api-버전)
>[사이트 이름](#사이트-이름)
>[URL 디코딩](#url-디코딩)
>[서버 시간대](#서버-시간대)
>[제품 정보](#제품-정보)
>[라이센스 정보](#라이센스-정보)
>[사용자 정보](#사용자-정보)
>[모두 한 번에 요청](#모두-한-번에-요청)

[각종 목록 요청](#각종-목록-요청)
>[채널 목록](#채널-목록)
>[차량 번호 인식 장치 목록](#차량-번호-인식-장치-목록)
>[이벤트 로그 종류 목록](#이벤트-로그-종류-목록)

[저장 데이터 검색](#저장-데이터-검색)
>[녹화 영상이 있는 날짜 검색](#녹화-영상이-있는-날짜-검색)
>[이벤트 로그 검색](#이벤트-로그-검색)
>[차량 번호 로그 검색](#차량-번호-로그-검색)

[동영상 소스 검색](#동영상-소스-검색)
>[실시간 영상 소스](#실시간-영상-소스)
>[녹화 영상 소스](#녹화-영상-소스)

## 개요
이 문서는 **(주)티에스 솔루션**의 **TS-CMS**, **TS-NVR**, **TS-LPR**에 내장된 **ts-rest-api**를 사용하여 응용 소프트웨어를 개발하는 분들을 위한 프로그래밍 안내서입니다.
이 문서를 참고하여 실시간 영상, 녹화 영상 보기, 영상 검색 기능을 간단하게 여러분의 응용 소프트웨어에 포함시킬 수 있습니다.

*이 문서 내에서는 ts-rest-api를 줄여서 **API**로 부르고, 각 제품은 네트워크 프로그램 관점에서 통칭하여 **서버**로 부르겠습니다.*

### 버전
현재 최신 버전은 **ts-rest-api@0.1.0** 입니다.
API가 탑재된 제품의 버전은 다음과 같습니다.
제품 | 버전
-----|--
TS-CMS | v0.38.0부터 지원
TS-NVR | v0.35.0부터 지원
TS-LPR | v0.2.0A부터 지원

*API와 본 문서는 개발 지원 및 기능 향상을 위해 공지 없이 변경될 수 있습니다.*


### 피드백
보내주시는 피드백은 언제나 환영합니다.
개발 관련 문의는 물론이고 개선했으면 하는 부분이 있으시면 아래로 보내주시면 고맙겠습니다.
*bobhyun@gmail.com*



### 미리 알아야 할 것
1. 프로그래밍 지식
API를 사용하기 위해 간단한 `HTML`과 `자바스크립트`를 사용해 본 경험이 있으면 도움이 됩니다.
2. 대상 제품
API는 모든 제품군에 호환되지만, 제품별 또는 라이센스별로 일부 기능이 지원되지 않을 수 있습니다. 아래 목록 중에서 사용하는 제품이 어디에 해당하는지 확인하시기 바랍니다.

### 제품별 기능 지원 표

구분 | TS-CMS | TS-NVR | TS-LPR 
----------------|--------|--------|-------
[실시간 영상 표시](#실시간-영상-표시) | O | O | O
[실시간 영상 소스](#실시간-영상-소스) 검색 | O | O | O
[녹화 영상 표시](#녹화-영상-표시)  | X | O | O
[녹화 영상 소스](#녹화-영상-소스) 검색 | X | O | O
[세션 인증](#세션-인증) | O | O | O
[서버 정보 요청](#서버-정보-요청)  | O | O | O
[각종 목록 요청](#각종-목록-요청)  | O | O | O
[녹화 영상이 있는 날짜 검색](#녹화-영상이-있는-날짜-검색) | X | O | O
[이벤트 로그 검색](#이벤트-로그-검색)  | O | O | O
[차량 번호 로그 검색](#차량-번호-로그-검색)  | X | 라이센스에 준함 `[설명]` | O
`[설명]` *TS-NVR은 자체적인 차량 번호 인식 기능이 없어 **차량 번호 로그 검색** 기능을 지원하지 않습니다. 
하지만 **차량 번호 인식 장치 연동** 부가 기능 라이센스를 사용하는 경우 별도의 차량 번호 인식 장치와 연동하여 차량 번호 로그를 저장하기 때문에 **차량 번호 로그 검색** 기능을 사용할 수 있습니다.*

## 시작하기
### 동영상 보기
웹 브라우저 주소 창에 다음과 같이 입력해 보십시오.
```ruby
http://tssolution.ipdisk.co.kr:88/watch?ch=1&auth=d2VidXNlcjoxMjM0YWJjZCs=
```
<button onClick="window.open('http://tssolution.ipdisk.co.kr:88/watch?ch=1&auth=d2VidXNlcjoxMjM0YWJjZCs=')">보기</button>


동영상이 표시되나요?

`[참고]` *이 예제 코드에 사용된 시연용 영상은 현장 상황에 따라 접속되지 않을 수도 있습니다.*

### 웹 페이지에 동영상 삽입하기
이 번에는 이 동영상을 웹 페이지에 삽입해 봅시다.
```html
<!DOCTYPE>
<head>
  <meta charset="utf-8">
  <title>ex1</title>
</head>

<body>
<h2>예제1. 동영상 삽입하기</h2>
<iframe src="http://tssolution.ipdisk.co.kr:88/watch?ch=1&auth=d2VidXNlcjoxMjM0YWJjZCs=" 
  width="640" height="360" frameborder="0" allowfullscreen />
</body>
```
<button onClick="window.open('./examples/ex1.html')">보기</button>

예제에서 사용된 것과 같은 동영상 URL과 `<iframe>` 태그 코드는 다음과 같은 간단한 방법으로 얻을 수 있습니다.
`[방법]` *제품의 웹 페이지에 접속하거나 예제와 같은 방법으로 접속하여 표시되는 **영상 위에서 오른쪽 마우스 버튼을 클릭**하면 (모바일인 경우 1초 정도 화면을 누르면) 팝업 메뉴가 나타납니다.
여기서 필요한 메뉴 항목을 선택하면 해당 코드가 클립보드에 복사되며 아래 표와 같이 각각의 용도에 맞게 **붙여넣기** 하면 됩니다.*
메뉴 항목 | 용도
---------|-----
동영상 URL 복사 | 웹 브라우저 주소 창에 붙여넣기
동영상 태그 코드 복사 | HTML 코드의 `<iframe>`부분에 붙어넣기
`[참고]` *보안 상의 이유로 이렇게 복사한 코드에는 `auth=d2VidXNlcjoxMjM0YWJjZCs=` 부분이 빠집니다. 이 부분은 로그인 정보에 해당하는 코드이며 [세션 인증](#세션-인증)에서 설명합니다.
이 예제에서는 동영상을 표시하기 위한 최소한의 코드만을 사용했기 때문에 복사된 코드에 비해 빠진 부분이 더 있습니다.*


## 실시간 영상 표시
[동영상 보기](#동영상-보기) 예제에서 간단한 실시간 영상 표시 기능을 사용해 보았습니다.
가장 중요한 부분은 동영상 주소에 해당하는 웹 주소 코드이며, API가 지원하는 기능 중에서 **필요한 기능을 웹 주소 코드로 표현**할 수 있도록 안내하는 것이 이 문서의 목적입니다.

여기서부터는 완전한 HTML 형식 대신 웹 주소 코드만으로 구성된 예제를 사용하겠습니다.

### 실제 서버에 접속하기
실제 서버에 접속하려면 기본적으로 아래 두 가지 정보를 알아야 합니다.
1. 서버의 **호스트명** (**IP 주소** 또는 **도메인명**, 80 포트가 아닌 경우 **포트 번호**)
*포트 번호는 사용하시는 제품 설정 창에서 `웹 서비스` 탭의 `HTTP 포트` 항목에서 확인할 수 있습니다.*
2. **원격 접속** 권한이 있는 **사용자 ID**와 **비밀번호**

### 사용자 인증
예를 들어, 다음과 같은 접속정보를 사용하는 것으로 가정하면

항목      | 값
----------|------
IP 주소   | `192.168.0.100`
웹 포트   | `80`
사용자 아이디 | `webuser`
비밀번호  | `1234abcd+`

위의 예제에서 주소 부분을 다음과 같이 변경하면 됩니다.
```html
<iframe src="http://192.168.0.100/watch?ch=1&auth=d2VidXNlcjoxMjM0YWJjZCs="
  width="640" height="360" frameborder="0" allowfullscreen></iframe>
```
여기서 `auth=` 다음에 있는 `d2VidXNlcjoxMjM0YWJjZCs=` 부분은 **사용자 아이디와 비밀번호를 base64 인코딩**한 부분입니다.
형식은 `userid:password`와 같이 콜론(`:`) 구분자를 사용하여 사용자 아이디와 비밀번호를 하나의 텍스트로 만든 다음 base64 인코딩합니다.
위의 예에서는 `webuser:1234abcd+`을 base64 인코딩해서 `d2VidXNlcjoxMjM0YWJjZCs=`가 됩니다.

### base64 인코딩
base64 인코딩 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.
>https://www.base64encode.org/
https://developer.mozilla.org/en-US/docs/Web/API/WindowBase64/Base64_encoding_and_decoding
https://www.w3schools.com/jsref/met_win_btoa.asp

이번 예제에서는 자바스크립트로 로그인 정보를 base64 인코딩해서 접속하는 방식으로 개선해 보도록 하겠습니다.
```html
<!DOCTYPE>
<head>
  <meta charset="utf-8">
  <title>ex2</title>
</head>

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
      <td><button type="button" onClick="onConnect()">접속</button>	</td>
    </tr>
    <tr>
      <td colspan="4" id="result"></td>
    </tr>
  </table>

  <iframe width="640" height="360" frameborder="0" allowfullscreen id="player" />
</body>

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
    var encodedData = window.btoa(userId + ':' + password);	// base64 인코딩
    var src = 'http://' + hostName + '/watch?ch=1&auth=' + encodedData;
    document.getElementById('result').innerText = src;
    document.getElementById('player').src = src;
  }
</script>
```
<button onClick="window.open('./examples/ex2.html')">보기</button>

### 채널 변경
아래와 같이 동영상 소스의 `ch=` 부분을 원하는 채널 번호로 변경하면 해당 채널의 동영상이 표시됩니다.
채널 번호는 1부터 시작하는 정수입니다.
예를 들어, 채널 3번을 보고 싶다면 다음과 같이 수정하면 됩니다.
```ruby
http://tssolution.ipdisk.co.kr:88/watch?ch=3&auth=d2VidXNlcjoxMjM0YWJjZCs=
```
<button onClick="window.open('http://tssolution.ipdisk.co.kr:88/watch?ch=3&auth=d2VidXNlcjoxMjM0YWJjZCs=')">보기</button>

## 녹화 영상 표시
녹화된 영상을 표시하기 위해서는 원하는 동영상의 날짜, 시각 정보(타임스탬프)가 필요합니다.
예를 들어, 위의 예제와 동일한 접속 정보로 `채널 1번`의 `2018년 2월 1일 오후 2시 30분 15초`에 녹화된 영상을 표시하기 위해서는 다음과 같이 `when=2018-02-01T14%3a30%3a15%2b09%3a00` 부분을 추가해야 합니다.
```ruby
http://tssolution.ipdisk.co.kr:88/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&auth=ZGV2MTpkZXZlbG9wZXIhMTIzNA==
```

`2018-02-01T14%3a30%3a15%2b09%3a00` 부분은 날짜, 시각 부분을 URL 인코딩한 것입니다.

### 날짜, 시각 표기법
날짜, 시각은 **ISO 8601** 표기법을 따릅니다.
```
YYYY-MM-DDThh:mm:ss.sss±Hh:Mm (로컬 타임 표기)
또는
YYYY-MM-DDThh:mm:ss.sssZ (UTC 표기)

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

위의 예제에 사용했던 `2018년 2월 1일 오후 2시 30분 15초`를 예를 들면,
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
`예) 2018-02-01T14%3a30%3a15%2b09%3a00`

실시간 영상을 요청하기 위해서 `when=now`로 요청해도 되지만, `when=`이 없으면 실시간을 의미하므로 생략해도 됩니다.

그리고 사용상 편의를 위해 다음과 같은 팁들을 제공합니다.
```
when=yesterday    // 서버의 로컬 타임으로 어제 00시 00분 00초
when=today        // 서버의 로컬 타임으로 오늘 00시 00분 00초
```

### URL 인코딩
URL 인코딩 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.

>http://www.convertstring.com/ko/EncodeDecode/UrlEncode
https://www.urlencoder.org/
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
https://www.w3schools.com/jsref/jsref_encodeuricomponent.asp


매개 변수를 사용하여 영상 위에 표시되는 자막의 언어를 설정할 수 있습니다.
여기서부터는 `http://host`부분과 `auth=` 부분은 생략하고 표현합니다.
```ruby
# 매개 변수
lang            # 자막 언어 지정
showTitle       # 채널 이름 표시 (true, false)
showPlayTime    # 재생 날짜, 시각 표시 (true, false)

# 예제
# 한글로 날짜, 시각 표시
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&lang=ko-KR

# 채널 이름 및 재생 날짜, 시각 표시한함
# showTitle과 showPlayTime은 명시하지 않은 경우 true로 간주함
/watch?ch=1&when=2018-02-01T14%3a30%3a15%2b09%3a00&showTitle=false&showPlayTime=false
```

### 지원하는 언어 목록
서버는 다음과 같이 총 104개 언어를 지원합니다.
```ruby
af-ZA       # 아프리카어, Afrikaans
sq-AL       # 알바니아어, Shqip, Albanian
am-ET       # 암하라어, አማርኛ, Amharic
ar-AE       # 아랍어, العربية, Arabic
hy-AM       # 아르메니아어, Հայերեն, Armenian
az-Latn     # 아제르바이잔어, Azərbaycan, Azerbaijani
eu-ES       # 바스크어, euskara, Basque
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
hr-HR       # 크로아티아어, hrvatski, Croatian
cs-CZ       # 체코어, čeština, Czech
da-DK       # 덴마크어, dansk, Danish
nl-NL       # 네덜란드어, Nederlands, Dutch
en-US       # 영어, English
eo          # 에스페란토어, Esperanto
et-EE       # 에스토니아어, Eesti keel, Estonian
fil-PH      # 필리핀어, Filipino
fi-FI       # 핀란드어, Suomalainen, Finnish
fr-FR       # 프랑스어, français, French
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
id-ID       # 인도네시아어, bahasa Indonesia, Indonesian
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
sk-SK       # 슬로바키아어, slovenský, Slovak
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

### JSON 데이터
지금까지는 `/watch` 호출을 통해 영상을 표시하는 방법들을 알아 보았습니다. 여기서부터는 `/api` 호출을 통해 각종 정보를 질의하는 방법을 알아보겠습니다.
모든 응답 데이터는 JSON 형식이며 텍스트는 `utf8`로 인코딩되어 있습니다.

서버는 데이터의 전송 속도 향상을 위해 JSON 데이터 내에 줄 바꿈이나 공백 문자를 사용하지 않습니다. 예를 들면 다음과 같은 형태의 텍스트를 사용합니다.
```json
{"apiVersion":"ts-rest-api@0.1.0","siteName":"%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84","timezone":{"name":"Asia/Seoul","bias":"+09:00"},"product":{"name":"TS-LPR","version":"v0.2.0A (64-bit)"},"license":{"type":"genuine","maxChannels":16}}
```
이렇게 한 줄로 길게 나열되어 있어 사람이 읽기에는 다소 불편할 수 있습니다.

이 경우 아래와 같은 도구들을 사용하면 읽기 쉽게 변환해 줍니다.
>http://www.csvjson.com/json_beautifier
https://codebeautify.org/jsonviewer
https://jsonformatter.curiousconcept.com/
https://jsonformatter.org/

읽기 쉽게 변환된 JSON 데이터는 다음과 같은 형태입니다.
```json
{
  "apiVersion": "ts-rest-api@0.1.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.2.0A (64-bit)"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 64
  }
}
```
물론 내용면으로는 둘 다 완전히 같은 데이터입니다.
이 문서에서는 데이터의 항목들을 설명하기 쉽도록 변환된 형식을 사용합니다.

## 세션 인증
서버는 클라이언트 프로그램(웹 브라우저)이 로그인 한 이후부터 로그아웃할 때까지 쿠키를 사용하여 HTTP 세션을 유지합니다. 세션이 유지되는 동안은 인증 정보를 서버가 유지하고 있으므로 클라이언트 프로그램(웹 브라우저)에서는 서버에 어떤 요청을 할 때마다 매번 로그인할 필요가 없습니다.

*이렇게 로그인하는 과정을 통칭하여 **세션 인증**이라고 부르겠습니다.*

### 로그인
여기서는 API를 사용하여 세션 인증하는 방법을 알아봅니다.
[사용자 인증](#사용자-인증)에서 사용했던 방법으로 사용자 아이디와 비빌번호를 암호화한 다음, 다음과 같이 `login=` 매개 변수에 붙여서 사용합니다.
```ruby
/api/auth?login=d2VidXNlcjoxMjM0YWJjZCs=    # http://host 부분 생략함
```
로그인이 성공한 경우 서버는 HTTP 응답 코드 200을 반환합니다.

아래와 같이 `auth=`를 사용해도 동일하게 로그인할 수 있습니다.
```ruby
/api/auth?auth=d2VidXNlcjoxMjM0YWJjZCs=
```
`auth=` 매개 변수는 앞으로 소개할 다양한 API에 사용될 수 있으며, 별도의 로그인 과정을 거치지 않고 서버에 어떤 요청을 하면서 사용자 인증 정보를 한꺼번에 전달하는 용도로 사용할 수 있습니다.


### 로그아웃
[세션 인증](#세션-인증)된 상태에서 다음과 같이 요청하면 세션이 종료됩니다.
```ruby
/api/auth?logout
```
세션이 종료된 상태에서는 서버는 인증이 필요한 요청에 대해 HTTP 응답 코드 401을 반환하여 인증이 필요함을 알립니다.

## 서버 정보 요청


### API 버전
이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
/api/info?apiVersion
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "apiVersion": "ts-rest-api@0.1.0"
}
```

### 사이트 이름
서버의 사이트 이름을 얻기 위해 사용합니다. 서버가 여러 대일 경우 각각을 구분할 수 있는 이름을 부여해서 사용할 수 있습니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
/api/info?siteName
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84"  // (URL 인코딩)
}
```
`siteName`에 해당하는 텍스트`"%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84"`는 서버의 웹 서비스 설정 창에 입력한 내용이며 어떤 문자를 사용하더라도 JSON 형식으로 표현하기 위해 URL 인코딩되어 있습니다.
위의 문자열을 URL 디코딩하면 `"우리집 서버"`로 변환됩니다.

### URL 디코딩
URL 디코딩에 관련한 더 자세한 정보는 아래 링크들을 참고하십시오.
>http://www.convertstring.com/ko/EncodeDecode/UrlDecode
https://www.urldecoder.org/
https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/decodeURIComponent
https://www.w3schools.com/jsref/jsref_decodeuricomponent.asp


### 서버 시간대
서버 측 표준 시간대(타임 존)를 얻을 수 있습니다.
클라이언트 측과 서버가 다른 시간대로 동작할 경우 구분하기 위해 사용합니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
/api/info?timezone
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "timezone": {
    "name": "Asia/Seoul",   // IANA 타임존 명
    "bias": "+09:00"        // 영국 표준 시각(UTC 또는 GMT) 오프셋
  }
}
```
`Asia/Seoul` 부분은 `IANA` 형식의 타임 존 이름이며, 해당 서버의 운영체제에 따라 IANA 타임 존 이름 대신 `UTC+09:00`로 표기될 수도 있습니다.

### 제품 정보
서버의 제품명과 버전 정보를 얻기 위해 사용합니다.

이 요청은 [세션 인증](#세션-인증) 상태가 아니어도 정상적으로 응답합니다.
```ruby
/api/info?product
````
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
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
/api/info?license
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
정품인 경우:
{
  "license": {
    "type": "genuine",    // 정품 라이센스
    "maxChannels": 36,    // 최대 사용할 수 있는 채널 수
    "extension": [        // 부가 기능
      "lprExt"            // 차량 번호 인식 장치 연동
    ]
  }
}

무료 평가판인 경우:
{
  "license": {
    "type": "trial",    // 무료 평가판
    "maxChannels": 16,  // 최대 사용할 수 있는 채널 수
    "trialDays": 30,    // 30일 무료 사용
    "leftDays": 15      // 15일 남음
  }
}
```

### 사용자 정보
로그인된 사용자 정보를 얻어오기 위해 사용됩니다.
이 요청은 [세션 인증](#세션-인증) 상태에서만 정상적으로 응답합니다.
여기서부터는 [세션 인증](#세션-인증)을 하기 위한 `auth=` 사용 부분은 생략하겠습니다. 
```ruby
/api/info?whoAmI
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
만약 [세션 인증](#세션-인증) 상태가 아니라면 서버는 HTTP 응답 코드 401 에러를 보냅니다.
```json
{
  "whoAmI": {
    "uid":"admin",      // 사용자 아이디 (URL 인코딩)
    "name":"admin",     // 사용자 이름 (URL 인코딩)
    "accessRights": [   // 사용 권한
      "DataExport",     // 이미지, 동영상 받아내기
      "Control",        // 팬틸트, 릴레이 제어
      "Settings",       // 설정 변경
      "Playback",       // 녹화 데이터 보기
      "LPR",            // 차량 번호 조회
      "SearchEdit",     // 검색 데이터 편집
      "Remote"          // 원격 접속
    ]
  }
}
```

#### 모두 한 번에 요청
각각 정보를 개별적으로 요청할 수도 있지만, 편의상 모든 정보를 한 번에 요청하는 방법도 제공합니다.
```ruby
/api/info?all
```
이 요청은 세션 인증 상태인 경우는 HTTP 응답 코드 200과 함께 JSON 데이터를 반환하며, 인증이 되지 않은 경우는 HTTP 응답 코드 401과 함께 `"whoAmI"` 항목이 빠진 JSON 데이터를 반환합니다.
```json
// 세션 인증된 상태 (HTTP 응답 코드: 200):
{
  "apiVersion": "ts-rest-api@0.1.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.2.0A (64-bit)"
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

// 세션 인증 안된 상태 (HTTP 응답 코드: 401):
{
  "apiVersion": "ts-rest-api@0.1.0",
  "siteName": "%EC%9A%B0%EB%A6%AC%EC%A7%91%20%EC%84%9C%EB%B2%84",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  },
  "product": {
    "name": "TS-LPR",
    "version": "v0.2.0A (64-bit)"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 36,
    "extension": [
      "lprExt"
    ]
  }     // whoAmI 부분 없음
}
```


## 각종 목록 요청
다음 요청들은 `auth=`를 사용하여 로그인 정보를 전달하거나 이미 로그인된 세션의 경우는 HTTP 응답 코드 200과 함께 JSON 데이터를 반환하며, 로그인 인증이 되지 않은 경우는 HTTP 응답 코드 401이 반환합니다.

### 채널 목록
사용 중인 채널 목록을 얻기 위해 아래와 같이 요청합니다.
```ruby
/api/enum?what=channel
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
[
  {
    "chid": 1,                                                  //채널 번호
    "title": "%EC%A0%84%EB%B0%A9%20%EC%B6%9C%EC%9E%85%EA%B5%AC" //채널 이름 (URL 인코딩)
  },
  {
    "chid": 2,                                                  //채널 번호
    "title": "%ED%9B%84%EB%B0%A9%20%EC%B6%9C%EC%9E%85%EA%B5%AC" //채널 이름 (URL 인코딩)
  }
]
```

### 차량 번호 인식 장치 목록
사용 중인 차량 번호 인식 장치 목록을 얻기 위해 아래와 같이 요청합니다.
차량 번호 인식 장치 목록에는 차량 번호 인식 장치 연동 기능을 사용하는 경우는 해당 장치들이 포함되고, 차량 번호 인식 기능이 내장된 TS-LPR의 경우는 설정된 차량 번호 인식 영역들이 포함됩니다.

```ruby
/api/enum?what=lprSrc
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
[
  // 연동된 차량 번호 인식 장치로부터 수신한 정보
  {
    "id": 1,                  // 장치 번호
    "code": "F00001",         // 장치 코드 (URL 인코딩)
    "name": "F00001",         // 장치 이름 (URL 인코딩)
    "linkedChannel": [        // 트리거 발생 시 연동되는 채널 목록
      1,
      2
    ],
    "tag": "Normal"           // 상태 (Normal: 사용중인 채널, NotUsed: 사용 안하는 채널, ReadOnly: 읽기 전용 채널)
  },

  // TS-LPR의 경우 차량 번호 인식 영역에 의해 인식된 정보
  {
    "id": 2,                  // 장치 번호
    "code": "1%2D1%2D1",      // 장치 코드 (URL 인코딩)
    "name": "1%2D1%2D1",      // 장치 이름 (URL 인코딩)
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
    }
  }
]

여기서,
  zone의 rect를 표현하는 좌푯값은 다양한 실제 해상도와 무관하게 영상 위의 위치를
  표현하기 위해 논리적 좌표계 8K(7680x4320)를 기준으로 물리적 좌표계(실제 영상의
  해상도)를 비례식으로 계산한 값을 사용합니다.
  예를 들어, 1920x1080 영상에서 사각형 영역의 좌표가 (480, 270, 1440, 810)일 경우 
  각각 가로 좌표에는 7680/1920을 곱하고, 세로 좌표에는 각각 4320/1080을 곱해서
  (1920, 1080, 5760, 3240)으로 표현합니다.
```

### 이벤트 로그 종류 목록
지원하는 이벤트 로그 종류 목록을 얻으려면 다음과 같이 요청합니다.
```ruby
/api/enum?what=eventType
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
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

      ... // 중략
  },
  {
    "id": 6,
    "name": "사용자 정의 이벤트"
  }
]
```
이처럼 이벤트 로그 종류 목록은 유형별로 코드가 정의되어 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우, 아래 매개 변수를 사용하여 언어를 변경할 수 있습니다.
```ruby
# 매개 변수
lang      # 언어

# 예제
# 영어로 요청한 경우
/api/enum?what=eventType&lang=en-US
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
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

      ... // 중략
  },
  {
    "id": 6,
    "name": "User-defined event"
  }
]
```


## 저장 데이터 검색

녹화데이터를 검색하기 위해서는 `/api/find`를 사용합니다.
### 녹화 영상이 있는 날짜 검색
녹화된 영상이 있는 날짜 목록을 얻기 위해 다음과 같이 요청합니다.

```ruby
/api/find?what=recDays      // 녹화된 영상이 있는 모든 날짜를 요청
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "result": {
    "2018-1": [ // 년-월 형식으로 데이터가 존재하는 날짜를 배열로 표시
      8,        // 2018-1-18  녹화 데이터 있음
      23,       // 2018-1-23  녹화 데이터 있음
      24        // 2018-1-24  녹화 데이터 있음
    ],
    "2018-2": [
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
```
아래와 같은 매개 변수를 추가하여 특정 조건에 해당하는 결과를 요청할 수 있습니다.
```ruby
# 매개 변수
ch          # 특정 채널이 녹화된 날짜 목록
timeBegin   # 특정 날짜, 시각 이후 녹화된 날짜 목록
timeEnd     # 특정 날짜, 시각 이전 녹화된 날짜 목록

# 예제
# 1번 채널이 녹화된 날짜 목록 요청
/api/find?what=recDays&ch=1

# 2018년 2월 (2018-02-01T00:00:00+09:00) 이후 녹화된 날짜 목록
/api/find?what=recDays&timeBegin=2018-02-01T00%3A00%3A00%2B09%3A00

# 2018년 1월 중에 녹화된 날짜 목록
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
/api/find?what=recDays&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 2018년 1번 채널이 1월 중에 녹화된 날짜 목록
/api/find?what=recDays&ch=1&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00
```

`ch`, `timeBegin` 또는 `timeEnd`와 같은 매개 변수를 사용하여 조건을 지정한 경우는 아래와 같이 요청받은 조건을 포함하여 결과가 반환됩니다.
```json
{
  "timeBegin": "2018-01-01T00:00:00+09:00",     // 요청받은 처음 날짜, 시각
  "timeEnd": "2018-01-31T23:59:59.999+09:00",   // 요청받은 마지막 날짜, 시각
  "chid": 1,                                    // 요청받은 채널 번호
  "result": {
    "2018-1": [
      8,
      23,
      24
    ]
  }
}
```


## 이벤트 로그 검색
서버에 기록된 이벤트 로그를 검색하기 위해서는 다음과 같이 요청합니다.
```ruby
/api/find?what=eventLog
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
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
      "comment": "admin: 자동 로그인"
    },

    ...   // 중략

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
      "comment": "정품 라이센스"
    }
  ]
}
```
서버에 기록된 이벤트 로그는 대량의 데이터이므로 모두 한꺼번에 전송하기 적합하지 않습니다. 이 때문에 개수를 명시하지 않을 경우 가장 최근 것부터 최대 50개까지만 로그 항목을 반환합니다.
`totalCount`, `at` 그리고 다음에 언급할 `maxCount`를 사용하여 검색 결과 페이지 단위로 표현할 수 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우 아래와 같은 매개 변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.
```ruby
# 매개 변수
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 이벤트 목록
timeEnd     # 특정 날짜, 시각 이전에 기록된 이벤트 목록
at          # 데이터 오프셋
maxCount    # 최대 항목 개수
sort        # 정렬 방식 (desc: 최신 데이터 순(기본값), asc: 오래된 데이터 순)
type        # 이벤트 로그 유형

# 예제
# 아랍어로 요청한 경우
/api/find?what=eventLog&lang=ar-AE

# 2018년 1월 동안 기록된 이벤트 로그 요청
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
/api/find?what=eventLog&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 검색 결과의 10번째 항목부터 20개를 요청
/api/find?what=eventLog&at=10&maxCount=20

# 오래된 데이터 순(오름차순)으로 정렬하여 요청
/api/find?what=eventLog&sort=asc

# 이벤트 로그 유형 중 시스템 로그(id: 0)만 요청
# [참고] 시스템 로그 유형 id 목록은 아래와 같이 요청해서 확인할 것
#        /api/enum?what=eventType
/api/find?what=eventLog&type=0

```


## 차량 번호 로그 검색
차량 번호 인식 기능을 사용하는 경우 인식된 차량 번호는 해당 동영상과 함께 저장됩니다. 차량 번호 로그를 조회하기 위해서는 다음과 같이 요청합니다.

```ruby
/api/find?what=carNo
```
요청에 대해 서버는 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
{
  "totalCount": 64,   // 서버에 기록된 전체 차량 번호 로그 개수
  "at": 0,            // 데이터 오프셋 표시 (0이므로 첫 번째 위치의 데이터를 의미함)
  "data": [           // 차량 번호 로그 데이터 목록
    {
      "id": 64,                           // 차량 번호 로그 번호
      "plateNo": "13다5939",               // 차량 번호 텍스트
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

    ... // 중략

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
  ]
}
```

서버에 기록된 차량 번호 로그는 대량의 데이터이므로 모두 한꺼번에 전송하기 적합하지 않습니다. 이 때문에 개수를 명시하지 않을 경우 가장 최근 것부터 최대 50개까지만 로그 항목을 반환합니다.
totalCount, at 그리고 다음에 언급할 maxCount를 사용하여 검색 결과를 페이지 단위로 표현할 수 있습니다.

언어를 지정하지 않으면 기본값으로 서버의 언어 설정에 따라 결과를 반환합니다.
필요한 경우 아래와 같은 매개 변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.


```ruby
# 매개 변수
keyword     # 검색할 차량 번호 (또는 일부 문자)
lang        # 언어
timeBegin   # 특정 날짜, 시각 이후에 기록된 차량 번호 목록
timeEnd     # 특정 날짜, 시각 이전에 기록된 차량 번호 목록
at          # 데이터 오프셋
maxCount    # 최대 항목 개수
sort        # 정렬 방식 (desc: 최신 데이터 순(기본값), asc: 오래된 데이터 순)

# 예제
# "12"가 포함된 차량 번호를 검색 (키워드 검색)
/api/find?what=carNo&keyword=12

# 아랍어로 요청한 경우
/api/find?what=carNo&lang=ar-AE

# 2018년 1월 동안 기록된 이벤트 로그 요청
# (2018-01-01T00:00:00+09:00 ~ 2018-01-31T23:59:59.999+09:00)
/api/find?what=carNo&timeBegin=2018-01-01T00%3A00%3A00%2B09%3A00&timeEnd=2018-01-31T23%3A59%3A59.999%2B09%3A00

# 검색 결과의 10번째 항목부터 20개를 요청
/api/find?what=carNo&at=10&maxCount=20

# 오래된 데이터 순(오름차순)으로 정렬하여 요청
/api/find?what=carNo&sort=asc
```

검색된 결과 데이터에 있는 동영상을 표시하기 위해서는 [녹화 영상 표시](#녹화-영상-표시)에서 사용했던 방법을 쓰면 됩니다.

예를 들어, 검색 결과 중 동영상을 표시하고자 하는 항목이 다음과 같다면 
```json
  ... // 중략

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

  ... // 중략
```
여기서 `"vod"` 아래 `"videoSrc"`의 값에 해당하는 `http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00`을 사용하여 영상을 표시할 수 있습니다.

```ruby
# 세션 인증된 경우 그대로 사용
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00

# 세션 인증된 안된 경우는 auth 매개 변수를 추가
http://192.168.0.100/watch?ch=1&when=2018%2D02%2D20T18%3A12%3A05%2E828%2B09%3A00&auth=ZGV2MTpkZXZlbG9wZXIhMTIzNA==
```

## 동영상 소스 검색
[동영상 삽입하기](#동영상-삽입하기)에서 사용했던 것처럼 API에서 자체적으로 지원하는 동영상 표시 기능 대신 다른 동영상 재생기나 프로그램에서 동영상 주소 사용할 경우에 이 방법을 사용할 수 있습니다.

이 방법을 사용하면 동영상을 표시하는 것이 아니라 동영상 주소만 요청할 수 있습니다.

### 실시간 영상 소스
아무런 매개변수 없이 다음과 같이 호출하면 서버에서 스트리밍하고 있는 실시간 영상 주소 목록을 요청할 수 있습니다.
```ruby
/api/vod
```
서버는 이에 대해 다음과 같이 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.
```json
[ // 각 채널이 배열의 항목으로 구성됨
  {
    "chid": 1,                              // 채널 번호
    "title": "Profile1%20%281920x1080%29",  // 채널 이름 (URL 인코딩)
    "src": [  // 동영상 소스 목록
              // (프로토콜 및 해상도에 따라 하나의 채널에 여러 개의 소스가 배열로 구성됨)
      { // 1080p RTMP 스트림
        "src": "rtmp://192.168.0.100/live/ch1main",  // 동영상 주소
        "type": "rtmp/mp4",     // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
        "label": "1080p FHD",   // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ]
      },
      { // 1080p HLS 스트림
        "src": "http://192.168.0.100/hls/ch1main/index.m3u8", // 동영상 주소
        "type": "application/x-mpegurl",  // MIME 형식: HLS 프로토콜 (HTML5 방식)
        "label": "1080p FHD",   // 해상도 이름
        "size": [               // 해상도
          1920,                 // 가로 픽셀 수
          1080                  // 세로 픽셀 수
        ]
      },
      { // VGA RTMP 스트림
        "src": "rtmp://192.168.0.100/live/ch1sub",   // RTMP 프로토콜 (Adobe Flash 방식)
        "type": "rtmp/mp4",   // MIME 형식: RTMP 프로토콜 (Adobe Flash 방식)
        "label": "VGA",
        "size": [
          640,
          480
        ]
      },
      { // VGA HLS 스트림
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
    "title": "192%2E168%2E0%2E106",
    "src": [

      ... // 중략

    ]
  },

  ... // 중략

]
```

동영상을 재생하는 환경 (전송 선로 속도와 플레이어에서 지원하는 프로토콜)이 다양하기 때문에 호환성을 높이기 위해 위의 예처럼 채널 당 여러 개의 동영상 소스를 제공합니다.
현재 버전에서는 `RTMP`와 `HLS` 두 가지 형식으로 스트리밍하고 있으며, 카메라가 지원하는 경우 고해상도와 저해상도로 이중으로 스트리밍합니다.

사실 위의 예제에는 실시간 영상을 의미하는 `when=now` 매개 변수가 생략되어 있습니다.
```ruby
/api/vod?when=now
```

필요한 경우 아래와 같은 매개 변수들을 하나 또는 여러 개를 조합하여 검색 조건들을 지정할 수 있습니다.
```ruby
ch          # 채널 번호 (명시하지 않으면 전체 채널을 의미함)
protocol    # 스트리밍 프로토콜을 지정 (rtmp, hls)
stream      # 동영상의 해생도를 지정 (main: 고해상도 영상, sbu:저해상도 영상)
nameonly    # true인 경우 동영상 스트림 데이터 부분 없이 채널 이름만 요청 

# 예제
# 1번 채널만 요청
/api/vod?ch=1

# hls 프로토콜만 요청할 경우
/api/vod?protocol=hls

# 저해상도 스트림만 요청할 경우
/api/vod?stream=sub

# 채널 이름만 요청할 경우
/api/vod?nameonly=true
# 또는 간단히
/api/vod?nameonly
```


### 녹화 영상 소스
일반적으로는 [녹화 데이터 검색](#녹화-데이터-검색) 기능을 사용해서 녹화 영상에 접근하겠지만, 여기서는 좀 더 저수준으로 녹화된 동영상 소스를 얻는 방법들을 소개합니다.

실시간 영상 소스를 요청할 때 사용하는 `/api/vod`를 그대로 사용하며 다음과 같이 매개 변수만 다르게 지정합니다.
```ruby
when        # 녹화된 영상의 시각(타임스템프)을 지정
duration    # when으로 지정한 시각부터 검색할 시간
id          # 녹화 동영상 파일 아이디
next        # true이면 지정한 영상의 다음 영상
limit       # 검색 결과의 항목 수를 지정 (명시하지 않으면 기본값 10개, 최대 50개)


# 예제

# 1번 채널에 대한민국 시각 2018년 1월 8일 오후 9시 30분 00초에 녹화된 영상 소스
# [중요]
#   1. 녹화 영상의 경우는 ch=를 명시하지 않으면 HTTP 응답 코드 400(잘못된 요청) 발생함
#   2. when=으로 지정한 시각에서 1초 이내의 데이터만 검색함
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00

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
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h

# 녹화 파일 아이디를 사용하여 직접 요청
# 영상이 있을 경우 해당 영상에서부터 10개(기본값)를 반환함
# [참고]
#   서버에 녹화된 동영상 파일은 각각 정수로 표현되는 일련 번호가 부여되어 있습니다.
/api/vod?id=1304

# 1번 채널의 현재 파일 아이디가 1034일 경우 같은 채널의 다음 파일을 요청 (연속 재생 시 유용함)
/api/vod?ch=1&id=1304&next=true
# 또는 간단히
/api/vod?ch=1&id=1304&next

# 검색된 영상 소스를 30개 받기
/api/vod?ch=1&when=2018-01-08T09%3A30%3A00%2B09%3A00&duration=1h&limit=30
```

이와 같은 방식으로 요청하면 서버는 HTTP 응답 코드 200과 함께 아래와 같은 형식의 JSON 데이터를 반환합니다.

```json
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

  ... // 중략

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


