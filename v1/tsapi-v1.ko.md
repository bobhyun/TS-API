# TS-API v1 Programming Guide

[English](tsapi-v1.md) | **한국어**

> **관련 문서:** [마이그레이션 가이드](MIGRATION.ko.md) · [변경이력](CHANGELOG.ko.md)

## 목차

1. [개요](#1-개요)
   - [1.1. 시각 표기](#11-시각-표기)
   - [1.2. 박스 좌표 표기](#12-박스-좌표-표기)
   - [1.3. 언어 (`lang`)](#13-언어-lang)
2. [API 호출 흐름](#2-api-호출-흐름)
   - [2.1. 기본 흐름 (JWT 인증)](#21-기본-흐름-jwt-인증)
   - [2.2. 녹화 검색 및 재생 흐름](#22-녹화-검색-및-재생-흐름)
   - [2.3. 토큰 갱신 흐름](#23-토큰-갱신-흐름)
   - [2.4. API Key 흐름 (로그인 불필요)](#24-api-key-흐름-로그인-불필요)
3. [인증](#3-인증)
   - [3.1. 인증 방식별 적용 범위](#31-인증-방식별-적용-범위)
   - [3.2. API Key 권한 모델](#32-api-key-권한-모델)
   - [3.3. JWT 인증](#33-jwt-인증)
   - [3.4. Storage / 미디어 파일 인증](#34-storage--미디어-파일-인증)
   - [3.5. API Key 인증](#35-api-key-인증)
4. [서버 정보](#4-서버-정보)
5. [시스템](#5-시스템)
   - [5.1. 시스템 정보](#51-시스템-정보)
   - [5.2. 시스템 상태](#52-시스템-상태)
   - [5.3. HDD S.M.A.R.T](#53-hdd-smart)
   - [5.4. 시스템 제어](#54-시스템-제어)
   - [5.5. 시스템 알림](#55-시스템-알림)
6. [채널](#6-채널)
   - [6.1. 채널 목록](#61-채널-목록)
   - [6.2. 채널 상태](#62-채널-상태)
   - [6.3. 채널 정보](#63-채널-정보)
   - [6.4. 채널 추가](#64-채널-추가)
   - [6.5. 채널 삭제](#65-채널-삭제)
7. [채널 제어](#7-채널-제어)
   - [7.1. PTZ 제어](#71-ptz-제어)
   - [7.2. 프리셋](#72-프리셋)
   - [7.3. 릴레이 출력](#73-릴레이-출력)
   - [7.4. 보조 출력](#74-보조-출력)
   - [7.5. 카메라 재부팅](#75-카메라-재부팅)
8. [녹화](#8-녹화)
   - [8.1. 녹화 날짜](#81-녹화-날짜)
   - [8.2. 녹화 시간 (분 단위)](#82-녹화-시간-분-단위)
9. [이벤트](#9-이벤트)
   - [9.1. 이벤트 유형](#91-이벤트-유형)
   - [9.2. 실시간 이벤트 토픽](#92-실시간-이벤트-토픽)
   - [9.3. 이벤트 로그](#93-이벤트-로그)
   - [9.4. 이벤트 트리거 (이벤트 백업)](#94-이벤트-트리거-이벤트-백업)
10. [LPR (차량 번호 인식)](#10-lpr-차량-번호-인식)
    - [10.1. LPR 소스 (인식 지점/영역)](#101-lpr-소스-인식-지점영역)
    - [10.2. LPR 로그](#102-lpr-로그)
    - [10.3. 유사 번호판 검색](#103-유사-번호판-검색)
    - [10.4. 차량 번호 수정](#104-차량-번호-수정)
11. [객체 감지](#11-객체-감지)
    - [11.1. 객체 유형](#111-객체-유형)
    - [11.2. 객체 속성](#112-객체-속성)
    - [11.3. 객체 로그](#113-객체-로그)
12. [얼굴 검색](#12-얼굴-검색)
    - [12.1. 이미지로 검색](#121-이미지로-검색)
    - [12.2. 시간 범위로 검색](#122-시간-범위로-검색)
13. [VOD](#13-vod)
    - [13.1. 스트림 URL](#131-스트림-url)
    - [13.2. 재생 URL](#132-재생-url)
    - [13.3. Watch 페이지 (임베드 플레이어)](#133-watch-페이지-임베드-플레이어)
14. [비상호출](#14-비상호출)
    - [14.1. 비상 호출 장치 목록](#141-비상-호출-장치-목록)
15. [Push (LPR 카메라, 비상벨 연동)](#15-push-lpr-카메라-비상벨-연동)
    - [15.1. 푸시 이벤트 전송](#151-푸시-이벤트-전송)
16. [주차](#16-주차)
    - [16.1. 주차장 목록](#161-주차장-목록)
    - [16.2. 주차장 상태](#162-주차장-상태)
    - [16.3. 주차면 목록](#163-주차면-목록)
    - [16.4. 주차면 상태](#164-주차면-상태)
    - [16.5. 주차 내역 조회](#165-주차-내역-조회)
    - [16.6. 주차 내역 상세](#166-주차-내역-상세)
    - [16.7. 정산 상태 변경](#167-정산-상태-변경)
    - [16.8. 미출차 정리](#168-미출차-정리)
    - [16.9. 차량 번호 수정](#169-차량-번호-수정)
17. [실시간 이벤트 구독 (WebSocket API)](#17-실시간-이벤트-구독-websocket-api)
    - [17.1. 연결 흐름](#171-websocket-연결-흐름)
    - [17.2. 엔드포인트](#172-엔드포인트)
    - [17.3. 인증](#173-인증)
    - [17.4. 이벤트 구독](#174-이벤트-구독)
18. [데이터 내보내기 — 녹화 데이터 백업 (WebSocket API)](#18-데이터-내보내기--녹화-데이터-백업-websocket-api)
    - [18.1. 내보내기 흐름](#181-내보내기-흐름)
    - [18.2. 엔드포인트](#182-엔드포인트)

**부록**
- [A. 오류 코드](#a-오류-코드)
- [B. 시간 형식](#b-시간-형식)
- [C. 예제 코드](#c-예제-코드)
  - [curl](#curl)
  - [JavaScript](#javascript)
  - [Python](#python)
  - [C#](#c-sharp)
  - [Go](#go)
  - [Java](#java)
  - [Kotlin](#kotlin)
  - [Swift](#swift)
  - [PowerShell](#powershell)
- [D. 지원 언어](#d-지원-언어)

---

## 1. 개요

TS-API v1은 RESTful 경로 기반의 API입니다.

**Base URL**: `http://{host}:{port}/api/v1`

**Content-Type**: `application/json`

> **참고**: API 전체에서 채널 번호(`ch`, `chid`)는 1부터 시작합니다 (1-based).

### 1.1. 시각 표기

**응답의 시각 표기는 요청의 표기에 따라 결정됩니다.**

| 요청의 시각 | 해석 | 응답 표기 |
|---------------|------|-------------------|
| `2026-10-07T09:30:00Z` | UTC | `...Z` (UTC) |
| `2026-10-07T09:30:00+09:00` | 그 오프셋 | `...+09:00` (서버 로컬) |
| `2026-10-07T09:30:00` (오프셋 없음) | **서버의 로컬 타임존** | `...+09:00` (서버 로컬) |
| `today` · `yesterday` | 서버 로컬 자정 | `...+09:00` (서버 로컬) |
| (시각 파라미터 없음) | — | `...+09:00` (서버 로컬) |

**응답에는 오프셋(또는 `Z`)이 항상 포함됩니다.** 따라서 오프셋 없이 보낸 시각을 서버가
**어떻게 해석했는지 응답에서 확인**할 수 있습니다. 보낸 시각 값은 그대로 반환되고, 그 뒤에
서버가 적용한 오프셋이 붙습니다. 클라이언트와 서버의 타임존이 다르면 이 오프셋으로 확인할 수
있습니다.

오프셋을 함께 보내는 것을 권장합니다. 오프셋을 생략해도 응답에 해석 결과가 표시되므로
타임존을 처리하지 않는 클라이언트도 그대로 사용할 수 있습니다.

서버 내부 저장은 UTC(마이크로초)입니다. 응답은 밀리초 단위까지 표시합니다.

**정산 앱이 보내는 시각**([16.7](#167-정산-상태-변경)·[16.8](#168-미출차-정리)의 `time`)은
정산 앱의 시계 값으로 **별도 보존**되며, NVR 의 기록 시각은 **항상 서버 시계**를 따릅니다.
두 시스템의 시각이 어긋나도 주차 시간과 영상 위치가 영향을 받지 않도록 분리한 것입니다.

서버가 NTP 를 지원하는 경우(TS-IVR, TS-LPR4)에는 두 시스템의 시각을 일치시킬 수 있습니다.
NVR 은 표준 NTP(UDP 123) 서버 기능을 제공하므로, 연동 시스템의 시간 동기화 대상을 NVR 주소로
지정하면 두 시스템의 시각이 같아지고 위 분리로 인한 차이도 없어집니다.

### 1.2. 박스 좌표 표기

박스(바운딩 박스)는 **YOLO 좌표계**로 표기합니다. 중심 기준이며, 네 값 모두 `0~1` 로
정규화됩니다.

```json
{ "cx": 0.394, "cy": 0.556, "w": 0.164, "h": 0.201 }
```

| 값 | 뜻 |
|----|----|
| `cx` · `cy` | 박스 **중심**의 가로·세로 위치 (0 = 왼쪽/위, 1 = 오른쪽/아래) |
| `w` · `h` | 박스의 가로·세로 **크기** |

그릴 때는 대상 이미지·영상의 크기에 곱하면 됩니다. 내부 좌표 공간을 알 필요가 없습니다.

```
left = (cx - w/2) * 화면폭      top = (cy - h/2) * 화면높이
```

| 규칙 | 내용 |
|------|------|
| 범위 | `cx ± w/2` 와 `cy ± h/2` 는 `0~1` 을 **넘지 않습니다**. 벗어나는 부분은 서버가 잘라냅니다 |
| 없을 때 | `null` 입니다. "박스 없음"과 "이 버전은 박스를 제공하지 않음"을 구분할 수 있도록 키를 생략하지 않습니다 |
| 기준 | 그 박스가 포함된 **이미지/영상** 전체입니다. 크롭 이미지에 포함된 박스는 그 크롭 기준입니다 |

> **주차 내역의 박스는 세션을 열 때 관측한 한 장면의 값입니다.** 그 시점에만 일치하므로
> **스틸컷에만 표시하고, 영상 재생을 시작하면 지우십시오.** 박스는 추적되지 않습니다.
> 출입구 세션은 번호 인식 한 건으로 구성되어 차량 박스가 없으므로 `null` 입니다.

**예외 — [16.4](#164-주차면-상태) 의 `vehicle.plate`.** 이 필드는 **절대 픽셀**
(`left`, `top`, `right`, `bottom`)을 유지합니다. 이미 배포되어 응용 프로그램이 사용 중이므로
호환성 유지를 위해 변경하지 않습니다.

기준은 전체 프레임이 **아닙니다.** 같은 응답의 `vehicle.image` 크롭이 기준이며, 그 크롭의
크기가 `vehicle.imageSize` 입니다(세 필드 모두 `image=true` 일 때만 포함됩니다). 정규화된 값이
필요하면 `imageSize.width` · `imageSize.height` 로 나누십시오.

```
cx = (left + right) / 2 / imageSize.width
cy = (top + bottom) / 2 / imageSize.height
w  = (right - left)     / imageSize.width
h  = (bottom - top)     / imageSize.height
```

**새로 추가되는 박스 필드는 YOLO 좌표계를 사용합니다.**

### 1.3. 언어 (`lang`)

사람이 읽는 문구(이벤트 유형·코드 이름, 상태 메시지, 알림 문구)는 `lang` 으로 지정한 언어로
번역됩니다. REST 호출에서는 쿼리 파라미터, 웹소켓에서는 URL 파라미터로 지정합니다([17.4](#174-이벤트-구독),
[18.2](#182-엔드포인트)). 규칙은 모든 API 에서 같습니다.

`lang` 은 `ko-KR`, `zh-TW` 같은 언어 코드입니다([D. 지원 언어](#d-지원-언어)). 목록에 없는 코드는
다음 순서에 따라 가장 가까운 지원 언어로 결정합니다.

| 단계 | 규칙 | 예 |
|------|------|----|
| 1 | 정확히 일치 (대소문자 무시) | `ko-kr` → `ko-KR` |
| 2 | 지역별 번역이 여럿인 언어의 기본 지역 | `zh`, `zh-Hans`, `zh-SG` → `zh-CN` · `zh-Hant`, `zh-HK`, `zh-MO` → `zh-TW` · `pt` → `pt-BR` · `pt-AO`, `pt-MZ`, `pt-CV`, `pt-GW`, `pt-ST`, `pt-TL`, `pt-MO` → `pt-PT` |
| 3 | 마지막 하위 태그를 제거하고 1–2 단계를 반복 | `zh-Hant-HK` → `zh-Hant` → `zh-TW` |
| 4 | 같은 언어의 번역이 하나뿐이면 그 번역 | `ar-SA` → `ar-AE` · `ko` → `ko-KR` · `sw-TZ` → `sw-KE` |
| 5 | 해당 없음 | 번역하지 않음 — 영어 문구 그대로 |

`lang` 을 생략하면 NVR 에 설정된 언어를 사용합니다. 알림([5.5](#55-시스템-알림))만 예외로,
`lang` 이 없으면 영어 문구만 포함합니다.

응답에 언어를 표시하는 곳(알림 `message` 의 키)에는 요청한 문자열이 아니라 서버가 결정한 코드를
사용합니다. 예를 들어 `lang=zh-HK` 는 `zh-TW` 로 반환됩니다.

코드는 표준 의미로 해석합니다. v1.3.0 이전에 다른 언어를 가리키던 코드(`ru-KG`, `sr-Latn`,
`nso-ZA`, `swc-CD`, `ku-Arab-IR`, 그리고 내용이 브라질 포르투갈어였던 `pt-PT`)는 수정된 코드로
자동 변환하지 않습니다. [변경이력](CHANGELOG.ko.md#v130)을 참조하십시오.


---

## 2. API 호출 흐름

### 2.1. 기본 흐름 (JWT 인증)

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant Camera

    Note over Client,Server: 1. 인증
    Client->>Server: POST /api/v1/auth/login
    Server-->>Client: accessToken, refreshToken

    Note over Client,Server: 2. 채널 정보 조회
    Client->>Server: GET /api/v1/channel
    Note right of Client: Authorization: Bearer {token}
    Server-->>Client: 채널 목록

    Note over Client,Server: 3. 실시간 스트림 요청
    Client->>Server: GET /api/v1/vod?ch=1&when=now
    Server-->>Client: RTMP/FLV Stream URL

    Note over Client,Server: 4. 실시간 이벤트 구독
    Client->>Server: WS /wsapi/v1/events?topics=LPR
    Server-->>Client: 이벤트 스트림 (LPR, 상태 등)

    Note over Client,Server: 5. PTZ 제어
    Client->>Server: GET /api/v1/channel/1/ptz?move=0.5,0.5
    Server->>Camera: ONVIF PTZ Command
    Camera-->>Server: OK
    Server-->>Client: OK
```

**단계별 설명:**

| 단계 | 설명 |
|------|------|
| **1. 인증** | 사용자 ID와 비밀번호로 로그인합니다. 서버는 `accessToken`(API 호출용)과 `refreshToken`(토큰 갱신용)을 반환합니다. |
| **2. 채널 정보 조회** | `Authorization: Bearer {accessToken}` 헤더를 포함하여 등록된 카메라 채널 목록을 조회합니다. |
| **3. 실시간 스트림 요청** | VOD API로 특정 채널의 실시간 영상 스트림 URL을 요청합니다. 반환된 URL로 FLV/RTMP 플레이어에서 재생합니다. |
| **4. 실시간 이벤트 구독** | WebSocket으로 실시간 이벤트(LPR, 상태변경 등)를 수신합니다. 연결 시 `topics` 파라미터로 구독할 이벤트를 지정합니다. |
| **5. PTZ 제어** | 카메라의 팬/틸트/줌을 제어합니다. 서버가 ONVIF 프로토콜로 카메라에 명령을 전달합니다. |

### 2.2. 녹화 검색 및 재생 흐름

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. 녹화 날짜 조회
    Client->>Server: GET /api/v1/recording/days?ch=1
    Server-->>Client: [2024-01-01, 2024-01-02, ...]

    Note over Client,Server: 2. 이벤트 로그 검색
    Client->>Server: GET /api/v1/event/log?timeBegin=2024-01-01
    Server-->>Client: 이벤트 목록

    Note over Client,Server: 3. 특정 시간 재생
    Client->>Server: GET /api/v1/vod?ch=1&when=2024-01-01T10:30:00
    Server-->>Client: 재생 URL
```

**단계별 설명:**

| 단계 | 설명 |
|------|------|
| **1. 녹화 날짜 조회** | 특정 채널의 녹화가 존재하는 날짜 목록을 조회합니다. 캘린더 UI 등에서 녹화 유무를 표시할 때 사용합니다. |
| **2. 이벤트 로그 검색** | 시간 범위를 지정하여 발생한 이벤트(모션, LPR 등) 목록을 검색합니다. 검색 결과의 타임스탬프로 특정 시점 재생이 가능합니다. |
| **3. 특정 시간 재생** | `when` 파라미터에 재생 시작 시각을 ISO 8601 형식으로 지정하면, 해당 시점의 녹화 영상 재생 URL을 반환합니다. |

### 2.3. 토큰 갱신 흐름

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Client->>Server: API Request
    Server-->>Client: 401 Unauthorized (토큰 만료)

    Client->>Server: POST /api/v1/auth/refresh
    Note right of Client: refreshToken 전송
    Server-->>Client: 새 accessToken

    Client->>Server: API Request (새 토큰)
    Server-->>Client: 200 OK
```

**단계별 설명:**

| 단계 | 설명 |
|------|------|
| **토큰 만료** | `accessToken`이 만료되면 서버가 `401 Unauthorized`를 반환합니다. |
| **토큰 갱신** | `refreshToken`을 사용하여 새로운 `accessToken`을 발급받습니다. 클라이언트는 재로그인 없이 API 호출을 계속할 수 있습니다. |
| **재요청** | 새로 발급받은 `accessToken`으로 실패했던 API를 다시 호출합니다. |

> **참고**: `accessToken`은 1시간, `refreshToken`은 7일 유효합니다. `refreshToken`도 만료된 경우 재로그인이 필요합니다.

### 2.4. API Key 흐름 (로그인 불필요)

로그인 없이 사용하므로 서버 간 연동, VMS, 상황실, 상시 운영 서비스에 적합합니다.

```mermaid
sequenceDiagram
    participant Client
    participant NVR
    participant Camera

    Note over Client: X-API-Key: tsapi_key_...

    rect rgb(255, 248, 240)
        Note over Client,NVR: 채널 조회
        Client->>NVR: GET /api/v1/channel
        NVR-->>Client: 채널 목록
    end

    rect rgb(240, 255, 240)
        Note over Client,Camera: 실시간 영상
        Client->>NVR: GET /api/v1/vod?ch=1
        NVR-->>Client: Stream URL
        Client->>Camera: 스트림 요청
    end

    rect rgb(255, 240, 245)
        Note over Client,NVR: 실시간 이벤트
        Client->>NVR: WS /wsapi/v1/events?apikey=...
        loop 이벤트 발생
            NVR-->>Client: 이벤트 데이터
        end
    end
```

**단계별 설명:**

| 단계 | 설명 |
|------|------|
| **API Key** | 모든 요청에 `X-API-Key` 헤더 또는 `?apikey=` 쿼리 파라미터를 포함합니다. 로그인/토큰 갱신이 불필요하여 서버 간 연동에 적합합니다. |
| **채널 조회** | REST API로 채널 목록을 조회합니다. JWT 인증과 동일한 엔드포인트를 사용합니다. |
| **실시간 영상** | VOD API로 스트림 URL을 받아 카메라에서 직접 영상을 수신합니다. |
| **실시간 이벤트** | WebSocket으로 연결하여 이벤트를 실시간 수신합니다. `apikey` 쿼리 파라미터로 인증합니다. |

---

## 3. 인증

v1 API는 두 가지 인증 방식을 지원합니다:
1. **JWT** - 웹 브라우저, 모바일 앱용 (토큰 만료 있음)
2. **API Key** - 외부 시스템 연동용 (장기/영구 토큰)

| 방식 | 사용 사례 | 만료 | 토큰 관리 |
|------|----------|------|-----------|
| API Key | 외부 연동 (VMS, 상황실, IoT) | 없음 (관리자가 폐기하기 전까지 유효) | 관리 불필요 |
| JWT 로그인 | 웹 대시보드, 모바일 앱, 대화형 클라이언트 | Access: 1시간, Refresh: 7일 | 만료 전 갱신 필요 |

### 3.1. 인증 방식별 적용 범위

| 인증 방식 | v1 데이터 엔드포인트 | v1 WebSocket | Storage/미디어 | v0 엔드포인트 |
|-----------|:-----------------:|:------------:|:-------------:|:------------:|
| JWT (Bearer Token) | ✅ | ✅ | ✅ | ✅ |
| API Key (X-API-Key) | ✅ | ✅ | ✅ | ❌ |
| Session Cookie | ✅ | ❌ | ❌ | ✅ |

> **참고**: 모든 **v1** 엔드포인트는 JWT Bearer Token과 API Key 인증을 모두 지원합니다.
>
> ⚠️ **v0 엔드포인트는 API Key 거부**: API Key 인증(`X-API-Key` 헤더)은 v0 엔드포인트(`/api/info`, `/api/enum`, `/api/system`, `/api/find` 등)에서 **허용되지 않습니다**. v0 엔드포인트는 세션 쿠키 인증만 지원합니다. 외부 연동 시 API Key와 함께 v1 엔드포인트를 사용하세요.
>
> 외부 시스템 연동에는 **API Key** 방식을 권장합니다. 웹/모바일 클라이언트에는 **JWT**를 권장합니다.
>
> ⚠️ **지원 중단**: `GET /api/v1/auth?login=...` (URL에 인증 정보가 노출됨)은 보안상의 이유로 v1에서 **지원이 중단되어 차단됩니다**. `POST /api/v1/auth/login`만 지원됩니다.

### 3.2. API Key 권한 모델

API Key의 권한에 따라 접근 가능한 엔드포인트가 결정됩니다:

| 권한 | 접근 가능 엔드포인트 |
|------|---------------------|
| Remote | Channel, VOD, Event (realtime/type), LPR (source), Parking, System, Info |
| Playback | Recording, Event (log), LPR (log), Object (log) |
| Settings | 시스템 설정 |
| Control | PTZ 제어, 릴레이 출력, 이벤트 트리거 |
| DataExport | 녹화 데이터 내보내기 |

> API Key에 필요한 권한이 없는 엔드포인트는 `403 Forbidden`을 반환합니다.

> **API Key 관리**(`/api/v1/auth/apikey` 발급·목록·폐기)는 모든 권한을 가진 관리자 계정으로 로그인한 JWT 로만 사용할 수 있습니다. API Key 로는 권한과 무관하게 사용할 수 없으며 `403 Forbidden` 을 반환합니다.
>
> API Key 의 권한은 사용할 때마다 발급한 계정의 현재 권한으로 제한됩니다. 발급한 계정의 권한이 줄면 키의 권한도 함께 줄고, 계정이 사용 중지되거나 삭제되면 그 계정이 발급한 키는 사용할 수 없습니다.

---

### 3.3. JWT 인증

#### 로그인
```http
POST /api/v1/auth/login
Content-Type: application/json

{"auth": "YWRtaW46MTIzNA=="}
```
> **참고:** `auth` 필드는 `username:password`를 Base64 인코딩한 값입니다. 예: `base64("admin:1234")` = `"YWRtaW46MTIzNA=="`. 실제 NVR 계정 정보를 사용하세요.

**응답:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "user": {
    "username": "admin",
    "role": "admin"
  }
}
```

**로그인 시도 제한:**
- 비밀번호 인증에 실패하면 같은 접속 주소에서는 3초 동안 다시 시도할 수 없습니다.
- 1분 안에 3회 실패하면 그 주소의 비밀번호 인증을 1분 동안 차단합니다. 차단은 서버를 다시 시작해도 남은 시간만큼 유지됩니다.
- 재시도 대기·차단 중에 받은 비밀번호 인증 요청은 인증하지 않고 `429 Too Many Requests` 를 반환합니다. `Retry-After` 헤더는 다시 시도할 수 있을 때까지 남은 초입니다.
- 토큰(JWT)과 API Key 인증에는 적용하지 않습니다.
- 사용 중지된 계정은 비밀번호가 맞아도 인증되지 않으며, 실패로 처리됩니다.

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 54
Content-Type: application/json

{"error": "Too Many Requests", "message": "Too many login attempts. Please try again later."}
```

#### API 호출
```http
GET /api/v1/channel
Authorization: Bearer eyJhbGc...
```

#### 토큰 갱신
```http
POST /api/v1/auth/refresh
Content-Type: application/json

{"refreshToken": "eyJhbGc..."}
```

**응답:**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "eyJhbGc...",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

> ⚠️ **토큰 순환(Rotation)**: refresh 요청 시 기존 refresh token은 무효화되고 새로운 refresh token이 반환됩니다. 응답의 `refreshToken`을 항상 저장하세요.

#### 로그아웃
```http
POST /api/v1/auth/logout
Content-Type: application/json

{"refreshToken": "eyJhbGc..."}
```

---

### 3.4. Storage / 미디어 파일 인증

미디어 파일 경로 (`/storage`, `/event-storage`, `/download`)는 URL 쿼리 파라미터로 인증합니다.

**지원 방식:**
- `?token={accessToken}` — JWT access token
- `?apikey={apiKey}` — API Key
- `?auth={base64(id:pw)}`, `?login={base64(id:pw)}` — 계정·비밀번호. 비밀번호가 URL 에 포함되므로 `token` 또는 `apikey` 사용을 권장합니다.

같은 매개변수로 실시간 스트림(`flv`·`websocket-flv`)도 인증합니다. `rtmp` 는 URL 의 계정 정보로 인증합니다([13.1](#131-스트림-url)).

> ⚠️ `<img>`, `<video>` src 속성에서는 `Authorization` 헤더를 사용할 수 없으므로 URL 쿼리 파라미터를 사용합니다.

**예제:**
```
GET /storage/r/0/0/0/31/31103.mp4?token=eyJhbGc...
GET /storage/snapshot/1/latest.jpg?apikey=tsapi_key_a1b2c3d4...
GET /event-storage/lpr/2024/01/01/event001.jpg?token=eyJhbGc...
GET /download/export_20240101.mp4?token=eyJhbGc...
```

| 경로 | 설명 |
|------|------|
| `/storage/r/{path}` | 녹화 영상 파일 |
| `/storage/snapshot/{ch}/latest.jpg` | 최신 스냅샷 이미지 |
| `/event-storage/{path}` | 이벤트 관련 미디어 (LPR 이미지 등) |
| `/download/{file}` | 내보내기 파일 |

> **URL 형식**: v1은 응답의 `image`, `videoSrc`, `src` 등의 필드에 **상대 URL** (`/`로 시작하는 경로)을 반환합니다. 클라이언트는 요청할 때 이 경로 앞에 접속한 서버의 base URL(`http://{host}:{port}`)을 붙여야 합니다. v0(레거시)는 절대 URL을 반환합니다. 자세한 내용은 [마이그레이션 가이드](MIGRATION.ko.md#5-주요-변경사항) 참고.

---

### 3.5. API Key 인증

API Key는 외부 시스템 연동(상황실 모니터링, VMS 등)에 적합합니다.
만료 없이 영구적으로 사용 가능하며, 관리자가 언제든 폐기할 수 있습니다.

> ⚠️ API Key 인증은 **v1 엔드포인트에서만** 지원됩니다. v0 엔드포인트(`/api/*`)는 `X-API-Key`를 `401 Unauthorized`로 거부합니다.

#### API Key 발급 (관리자 전용)

모든 권한을 가진 관리자 계정으로 로그인한 JWT 가 필요합니다. API Key 로 요청하면 `403 Forbidden` 을 반환합니다.

> **참고**: 웹 페이지에서 관리자로 로그인한 후 **"API Key"** 페이지에서도 API Key를 발급할 수 있습니다.

```http
POST /api/v1/auth/apikey
Authorization: Bearer {admin_token}
Content-Type: application/json

{
  "name": "상황실 모니터링",
  "permissions": ["remote", "playback"],
  "channels": [1, 2, 3, 4],
  "ipWhitelist": ["192.168.1.0/24"],
  "expiresAt": null
}
```

**권한 값:**

| 값 | 설명 |
|----|------|
| `remote` | 기본 접근 (채널, VOD, 이벤트 type/realtime, LPR source, 주차, 시스템, 정보) |
| `playback` | 녹화 검색, 이벤트/LPR/객체 로그 |
| `settings` | 시스템 설정 |
| `control` | PTZ 제어, 릴레이 출력, 이벤트 트리거 |
| `dataExport` | 녹화 데이터 내보내기 |
| `*` | 모든 권한 (super) |

> `channel:read`, `vod:read`는 `remote`의 별칭입니다. `admin`은 `settings`의 별칭입니다.

**응답:**
```json
{
  "id": "key_abc123",
  "key": "tsapi_key_a1b2c3d4e5f6...",
  "name": "상황실 모니터링",
  "message": "Store this API key securely. It will not be shown again."
}
```

#### API Key 사용

**헤더 방식:**
```http
GET /api/v1/channel
X-API-Key: tsapi_key_a1b2c3d4e5f6...
```

**URL 파라미터 방식 (비디오 스트림용):**
```
http://server/api/v1/vod?ch=1&apikey=tsapi_key_a1b2c3d4...
```

#### API Key 목록 조회
```http
GET /api/v1/auth/apikey
Authorization: Bearer {admin_token}
```

#### API Key 폐기
```http
DELETE /api/v1/auth/apikey/{keyId}
Authorization: Bearer {admin_token}
```

> **예제:** [JavaScript](examples/javascript/01-login.js) · [Python](examples/python/01_login.py) · [C#](examples/csharp/01_Login.cs) · [Go](examples/go/01_login/) · [Java](examples/java/V1_01_Login.java) · [Kotlin](examples/kotlin/V1_01_Login.kt) · [Swift](examples/swift/01-login.swift) · [PowerShell](examples/powershell/01-login.ps1) · [curl](examples/curl/01-login.sh)

---

## 4. 서버 정보

서버 및 제품 정보를 조회합니다.

> **인증 불필요** — `whoAmI` 파라미터를 제외한 모든 정보는 인증 없이 조회할 수 있습니다. `whoAmI`는 JWT 또는 세션 인증이 필요합니다.

| 엔드포인트 | 인증 | 설명 |
|----------|:----:|-------------|
| `GET /api/v1/info?apiVersion` | - | API 버전 조회 (예: "TS-API@1.4.1") |
| `GET /api/v1/info?siteName` | - | 사이트 이름 조회 |
| `GET /api/v1/info?timezone` | - | 서버 타임존 조회 (name, bias) |
| `GET /api/v1/info?product` | - | 제품 정보 조회 (name, version) |
| `GET /api/v1/info?license` | - | 라이선스 정보 조회 (type, maxChannels) |
| `GET /api/v1/info?whoAmI` | ✅ | 현재 로그인 사용자 정보 |
| `GET /api/v1/info?all` | ✅* | 모든 정보 한번에 조회 |

> \* `?all`은 `whoAmI`를 포함하므로 사용자 정보를 얻으려면 인증이 필요합니다. 미인증 시 `whoAmI`는 응답에서 제외되며 HTTP 401 상태를 반환합니다.

**파라미터**:

| 파라미터 | 타입 | 설명 |
|----------|------|------|
| `all` | Flag | 모든 정보 포함 |
| `apiVersion` | Flag | API 버전 |
| `siteName` | Flag | 사이트 이름 |
| `product` | Flag | 제품 정보 |
| `license` | Flag | 라이선스 정보 |
| `whoAmI` | Flag | 인증된 사용자 정보 |
| `timezone` | Flag | 타임존 정보 |

**예제** (인증 불필요):
```bash
curl "http://localhost/api/v1/info?apiVersion&product&license"
```

**예제** (whoAmI 조회 시 인증 필요):
```bash
curl "http://localhost/api/v1/info?all" -H "Authorization: Bearer eyJhbGc..."
```

**응답** (정품 라이선스 + ANPR/객체감지/주차안내 활성 예시):
```json
{
  "apiVersion": "TS-API@1.4.1",
  "siteName": "Main Office",
  "timezone": {
    "name": "Asia/Seoul",
    "bias": "+09:00"
  },
  "product": {
    "name": "TS-NVR",
    "version": "2.14.1"
  },
  "license": {
    "type": "genuine",
    "maxChannels": 64,
    "nLprZone": 36,
    "nChObjDetection": 36,
    "nChFaceRecognition": 10,
    "nChTrafficCount": 10,
    "nChSpeedometer": 10,
    "nChPeopleCount": 10,
    "fisheyeCamSupports": true,
    "mediaType": "USB dongle",
    "extension": ["lprExt", "objectDetection", "parkingGuide"]
  }
}
```

**응답** (시험판 예시):
```json
{
  "license": {
    "type": "trial",
    "maxChannels": 16,
    "trialDays": 30,
    "leftDays": 15,
    "mediaType": "Software"
  }
}
```

**응답 필드**:

| 필드 | 타입 | 조건 | 설명 |
|------|------|------|------|
| `apiVersion` | String | 항상 | API 버전 |
| `siteName` | String | 항상 | NVR 사이트 이름 |
| `timezone.name` | String | 항상 | 타임존 이름 |
| `timezone.bias` | String | 항상 | 타임존 오프셋 |
| `product.name` | String | 항상 | 제품 이름 |
| `product.version` | String | 항상 | 제품 버전 |
| `license.type` | String | 항상 | `freeware`, `genuine`, `limited`, `trial` |
| `license.maxChannels` | Int | 항상 | 최대 채널 수 |
| `license.expire` | String | `type=limited` | 만료 일시 (ISO 8601) |
| `license.trialDays` | Int | `type=trial` | 시험판 총 일수 |
| `license.leftDays` | Int | `type=trial` | 시험판 남은 일수 |
| `license.nLprZone` | Int | LPR 지원 빌드 | LPR 인식 영역 수 |
| `license.nDevEmCall` | Int | 비상 호출 빌드 | 비상 호출 장치 수 (하위 호환용, 항상 `0` 반환) |
| `license.nChObjDetection` | Int | 객체 감지 라이선스 활성 | 객체 감지 채널 수 |
| `license.nChFaceRecognition` | Int | 얼굴 인식 라이선스 활성 | 얼굴 인식 채널 수 |
| `license.nChTrafficCount` | Int | 교통량 집계 라이선스 활성 | 교통량 집계 채널 수 |
| `license.nChSpeedometer` | Int | 속도 측정 라이선스 활성 | 차량 속도 측정 채널 수 |
| `license.nChPeopleCount` | Int | 인원수 집계 라이선스 활성 | 인원수 집계 채널 수 |
| `license.fisheyeCamSupports` | Boolean | 어안 디워핑 라이선스 활성 | `true` 일 때만 포함 (라이선스가 없으면 필드 생략) |
| `license.maxVehicles` | Int | ANPR + 기본값 아닐 때 | LPR 동시 추적 차량 수 |
| `license.mediaType` | String | 항상 | `"USB dongle"` 또는 `"Software"` |
| `license.extension` | Array | 확장 기능 1개 이상 | 확장 기능 토큰 목록 (아래 표 참조) |
| `whoAmI.uid` | String | whoAmI 요청 시 | 사용자 ID |
| `whoAmI.name` | String | whoAmI 요청 시 | 사용자 이름 |
| `whoAmI.accessRights` | Object | whoAmI 요청 시 | 접근 권한 |

**`license.extension` 토큰**:

| 토큰 | 설명 |
|------|------|
| `lprExt` | 차량번호 인식 (ANPR/LPR 지원) |
| `emergencyCall` | 비상 호출 장치 연동 |
| `packing` | 포장 (SEMES Lot Search 등) |
| `objectDetection` | 객체 감지 |
| `faceRecognition` | 얼굴 인식 (외부 FR 서버 연동) |
| `sharedFrameBuffer` | 공유 프레임 버퍼 |
| `vehicleTracking` | 차량 추적 |
| `parkingGuide` | 주차 안내 |
| `parkingSpot` | 주차면 점유 인식 |
| `parkingHistory` | 주차 내역 — [16.5~16.8](#165-주차-내역-조회) 엔드포인트는 이 토큰이 있을 때만 응답합니다 |

---

## 5. 시스템

시스템 정보 조회 및 제어 API입니다.

### 5.1. 시스템 정보

시스템 하드웨어 및 소프트웨어 정보를 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/system/info` | 전체 시스템 정보 조회 |
| `GET /api/v1/system/info?item=os` | OS 정보 (이름, 버전, 아키텍처) |
| `GET /api/v1/system/info?item=cpu` | CPU 정보 (모델, 코어 수, 클럭) |
| `GET /api/v1/system/info?item=storage` | 저장장치 정보 (디스크 목록, 용량) |
| `GET /api/v1/system/info?item=network` | 네트워크 정보 (인터페이스, IP) |
| `GET /api/v1/system/info?item=storage,network` | 여러 항목 동시 조회 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `item` | String | N | 전체 | 조회할 항목 (쉼표 구분: `os`, `cpu`, `storage`, `network`) |

> **참고**: 응답에서 저장장치 정보는 `disk` 필드로 반환됩니다 (`item=storage`로 요청하지만 응답 필드명은 `disk`). 네트워크 정보 요청 시 `lastUpdate` 필드도 함께 반환됩니다.

**응답 필드**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `os` | Object | OS 정보 (이름, 버전, 아키텍처) |
| `cpu` | Object | CPU 정보 (모델, 코어 수, 클럭) |
| `mainboard` | Object | 메인보드 정보 |
| `memory` | Object | 메모리 정보 |
| `graphicAdapter` | Object | 그래픽 어댑터 정보 |
| `monitor` | Object | 모니터 정보 |
| `storage` | Object | 스토리지 정보 |
| `networkAdapter` | Object | 네트워크 어댑터 정보 |

### 5.2. 시스템 상태

시스템 실시간 상태를 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/system/health` | 전체 시스템 상태 |
| `GET /api/v1/system/health?item=cpu` | CPU 사용률 (%) |
| `GET /api/v1/system/health?item=memory` | 메모리 사용량 (total, used, free) |
| `GET /api/v1/system/health?item=disk` | 디스크 사용량 (total, used, free) |
| `GET /api/v1/system/health?item=memory,disk` | 여러 항목 동시 조회 |
| `GET /api/v1/system/health?item=systemDisk` | 시스템 디스크(데이터베이스와 로그가 있는 디스크) 상태 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `item` | String | N | 조회 항목 (쉼표 구분): `cpu`, `memory`, `disk`, `systemDisk`, `recording`, `network`, `all`, `supported` |

**응답 필드**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `lastUpdate` | String | 마지막 갱신 시각 (ISO 8601) |
| `cpu` | Array | CPU 상태 목록 (`item`에 `cpu` 포함 시) |
| `cpu[].usage.total` | Int | 전체 CPU 사용률 (%) |
| `cpu[].usage.threads` | Array | 코어별 사용률 (%) |
| `cpu[].temperatureKelvin.current` | Float | 현재 온도 (K) |
| `cpu[].temperatureKelvin.critical` | Float | 임계 온도 (K) |
| `memory` | Object | 메모리 상태 (`item`에 `memory` 포함 시) |
| `memory.totalPhysical` | Int | 전체 물리 메모리 (bytes) |
| `memory.freePhysical` | Int | 여유 물리 메모리 (bytes) |
| `memory.totalVirtual` | Int | 전체 가상 메모리 (bytes) |
| `memory.freeVirtual` | Int | 여유 가상 메모리 (bytes) |
| `disk` | Array | 디스크(파티션) 상태 목록 (`item`에 `disk` 포함 시) |
| `disk[].mount` | String | 마운트 경로 (예: `"C:"`) |
| `disk[].fileSystem` | String | 파일 시스템 (예: `"NTFS"`) |
| `disk[].volumeName` | String | 볼륨 이름 |
| `disk[].totalSpace` | Int | 전체 용량 (bytes) |
| `disk[].freeSpace` | Int | 여유 용량 (bytes) |
| `disk[].totalTimePercent` | Int | 디스크 전체 사용 시간 (%) |
| `disk[].readTimePercent` | Int | 읽기 시간 (%) |
| `disk[].writeTimePercent` | Int | 쓰기 시간 (%) |
| `disk[].totalBytesPerSec` | Int | 전체 전송 속도 (bytes/sec) |
| `disk[].readBytesPerSec` | Int | 읽기 속도 (bytes/sec) |
| `disk[].writeBytesPerSec` | Int | 쓰기 속도 (bytes/sec) |
| `recording` | Object | 녹화 스토리지 상태 (`item`에 `recording` 포함 시) |
| `recording.current` | String | 현재 녹화 경로 |
| `recording.storage` | Array | 녹화 스토리지 목록 |
| `recording.storage[].path` | String | 스토리지 경로 |
| `recording.storage[].usage` | String | `overwrite`, `write-once`, `read-only`, `event-backup`, `disabled`, `unknown` 중 하나 |
| `network` | Array | 네트워크 인터페이스 상태 (`item`에 `network` 포함 시) |
| `network[].name` | String | 인터페이스 이름 |
| `network[].totalBytesPerSec` | Int | 전체 전송 속도 (bytes/sec) |
| `network[].recvBytesPerSec` | Int | 수신 속도 (bytes/sec) |
| `network[].sendBytesPerSec` | Int | 송신 속도 (bytes/sec) |
| `network[].curBandwidth` | Int | 현재 대역폭 (bps) |
| `systemDisk` | Object | 시스템 디스크 상태 (`item` 에 `systemDisk` 포함 시) |
| `systemDisk.drive` | String | 볼륨 (예: `"C:"`) |
| `systemDisk.totalSpace` | Int | 전체 용량 (bytes), 첫 측정 전에는 `-1` |
| `systemDisk.freeSpace` | Int | 여유 용량 (bytes), 첫 측정 전에는 `-1` |
| `systemDisk.status` | String | `normal`, `low` (여유 1 GB 미만), `critical` (여유 200 MB 미만 또는 최근 저장 실패) |
| `systemDisk.dataWriteFailed` | Boolean | 최근 60초 안에 공간 부족이나 I/O 오류로 기록을 저장하지 못했는지 |

*시스템 디스크*는 제품이 데이터베이스와 로그를 저장하는 디스크로, 보통 Windows 가 설치된 `C:` 이며
녹화 디스크와 별개입니다. 이 디스크가 차면 녹화 디스크에 공간이 남아 있어도 새 녹화를 색인하지 못하고
인식 기록이 저장되지 않습니다. 그러므로 `disk[]` 만 보지 말고 `systemDisk.status` 를 함께 확인하십시오.
상태 변경을 통보받으려면 시스템 알림([5.5. 시스템 알림](#55-시스템-알림))을 사용하십시오.

### 5.3. HDD S.M.A.R.T

디스크 S.M.A.R.T 상태를 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/system/hddsmart` | 전체 디스크 S.M.A.R.T 정보 |
| `GET /api/v1/system/hddsmart?disk=1` | 특정 디스크 S.M.A.R.T 정보 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `disk` | Int | N | 디스크 번호 (생략 시 전체) |
| `lang` | String | N | `[].message` 의 언어 ([1.3](#13-언어-lang)) |

**응답**: 고정 디스크마다 항목 하나씩을 배열로 반환합니다.

배열이 비어 있으면 고정 디스크를 찾지 못한 것입니다. 아직 속성을 읽지 않은 디스크도
목록에 포함되며 `code` 가 `-1` 입니다. S.M.A.R.T 정보는 백그라운드에서 읽어 한 시간 동안
캐시하므로, 서버 시작 직후 잠시 동안은 `-1` 로 표시될 수 있습니다.

| 필드 | 타입 | 설명 |
|------|------|------|
| `[].name` | String | 디스크 이름 (예: `"PhysicalDrive0"`) |
| `[].model` | String | 디스크 모델명 |
| `[].code` | Int | S.M.A.R.T 상태 (아래 표 참고) |
| `[].message` | String | `code` 에 해당하는 상태 메시지. 요청한 언어로 반환됩니다 |
| `[].protocol` | String | 속성을 읽은 방식: `"ATA"` 또는 `"NVMe"`. 둘은 속성 ID 체계가 다릅니다 |
| `[].smart` | Array | S.M.A.R.T 속성 목록 (속성을 읽은 경우에만 포함) |
| `[].smart[].id` | Int | 속성 ID |
| `[].smart[].attribute` | String | 속성 이름 |
| `[].smart[].critical` | Boolean | 치명적 속성 여부 |
| `[].smart[].value` | Int | 현재 값 |
| `[].smart[].worst` | Int | 최저 값 |
| `[].smart[].threshold` | Int | 임계 값 |
| `[].smart[].raw` | Int | Raw 값 |
| `[].smart[].rawHex` | String | Raw 값 (16진수 문자열) |

`[].code` 값:

| 코드 | 의미 |
|------|------|
| `-1` | 아직 조회하지 않음 |
| `0` | 드라이브가 S.M.A.R.T 를 지원하지 않음 |
| `1` | 지원 - 속성은 `[].smart` 에 들어 있습니다 |
| `2` | 드라이브를 열 수 없음. 관리자 권한이 필요합니다 |
| `3` | 스토리지 컨트롤러가 S.M.A.R.T 를 전달하지 않음 (RAID 컨트롤러 뒤의 디스크) |
| `4` | 드라이브는 지원하지만 속성 읽기에 실패 |

### 5.4. 시스템 제어

시스템 제어 명령입니다. **관리자 권한 필요**

| 엔드포인트 | 설명 |
|----------|-------------|
| `POST /api/v1/system/restart` | NVR 서버 프로세스 재시작 |
| `POST /api/v1/system/reboot` | 시스템(OS) 재부팅 |

**응답**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `code` | Int | 결과 코드 (0: 성공) |
| `message` | String | 결과 메시지 |

> **예제:** [JavaScript](examples/javascript/08-system-info.js) · [Python](examples/python/08_system_info.py) · [C#](examples/csharp/08_SystemInfo.cs) · [Go](examples/go/08_system/) · [Java](examples/java/V1_08_SystemInfo.java) · [Kotlin](examples/kotlin/V1_08_SystemInfo.kt) · [Swift](examples/swift/08-system-info.swift) · [PowerShell](examples/powershell/08-system-info.ps1) · [curl](examples/curl/08-system-info.sh)

---

### 5.5. 시스템 알림

알림은 **현재 유효한** 주의 사항이며, 발생·갱신·해제됩니다. 이벤트(§9)가 발생한 일의 이력이라면
알림은 현재 상태를 나타냅니다. 알림은 메모리에만 보관하므로 시스템 디스크가 가득 차도 동작합니다.

| Endpoint | 설명 |
|----------|------|
| `GET /api/v1/system/notices` | 현재 유효한 알림 목록 |
| `GET /api/v1/system/notices?lang=ko-KR` | 같은 목록, `message` 에 `ko-KR` 문구 추가 |
| `GET /api/v1/system/notices?lang=zh-HK` | 같은 목록, 문구를 `zh-TW` 키로 추가 (아래 *언어* 참조) |

로그인한 사용자는 누구나 조회할 수 있습니다. 실시간으로 받으려면 `notice` 토픽을 구독하십시오
([17.4. 이벤트 구독](#174-이벤트-구독)). 구독 직후 현재 목록을 한 번 전송하고, 이후에는 변경 사항만 전송합니다.

**언어** — `message` 는 언어 코드를 키로 하는 객체입니다. `en-US` 는 항상 포함되며 기준 문구입니다.
`lang`(REST 호출의 쿼리 또는 웹소켓 URL)으로 영어가 아닌 언어를 지정하면 번역문이 추가됩니다. 키는 요청한
문자열이 아니라 서버가 결정한 언어 코드입니다([1.3. 언어](#13-언어-lang)). `lang=ko` 나 `lang=ko-kr` 은
`ko-KR` 키로, `lang=zh-HK` 는 `zh-TW` 키로 추가됩니다. 서버가 번역할 수 없는 언어는 추가하지 않으며, `lang` 이
없으면 `en-US` 만 포함합니다. 직접 번역하는 클라이언트는 `messageKey` 와 `args` 를 사용하십시오. 이 경우
사용자가 언어를 바꿔도 다시 접속할 필요가 없습니다.

**응답** — 배열입니다. 심각도가 높은 순으로, 심각도가 같으면 먼저 발생한 순으로 정렬합니다.
```json
[
  {
    "id": "systemDisk",
    "kind": "systemDisk",
    "severity": "critical",
    "message": {
      "en-US": "Disk C: is almost full: 150MB left",
      "ko-KR": "C: 디스크 거의 가득 참: 150MB 남음"
    },
    "messageKey": "Disk %1% is almost full: %2% left",
    "args": ["C:", "150MB"],
    "param": {"drive": "C:", "totalSpace": 119387713536, "freeSpace": 157286400, "status": "critical", "dataWriteFailed": false},
    "timeBegin": "2026-10-23T08:40:12.000+09:00",
    "timeUpdate": "2026-10-23T08:51:07.000+09:00"
  }
]
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | String | 알림 식별자. 같은 `id` 의 알림은 중복 생성되지 않고 기존 항목이 갱신됩니다 |
| `kind` | String | 알림 발생원. 현재는 `systemDisk` |
| `severity` | String | `info`, `warning`, `critical`. `critical` 은 즉시 조치가 필요하므로 눈에 띄게 표시하십시오 |
| `message` | Object | 언어 코드별 문구 (자리표시자에 값이 채워진 상태) |
| `message.en-US` | String | 영어 — 항상 있음 |
| `message.{code}` | String | 번역문. 요청 언어에 대해 서버가 결정한 코드를 키로 사용(예: `ko-KR`, `lang=zh-HK` 이면 `zh-TW`). 영어가 아닌 언어를 `lang` 으로 요청했고 서버가 번역할 수 있을 때만 포함 |
| `messageKey` | String | 자리표시자(`%1%`, `%2%` …)가 든 영어 원문 — 번역 키. 직접 번역하는 클라이언트용 |
| `args` | Array | 자리표시자 값, 순서대로 (번역하지 않음) |
| `param` | Object | `kind` 별 상세 정보. 없으면 생략. 필드가 추가될 수 있으므로 알 수 없는 필드는 무시하십시오 |
| `timeBegin` | String | 처음 발생한 시각. 갱신되어도 바뀌지 않음 |
| `timeUpdate` | String | 마지막 변경 시각 |

**`notice` 토픽 메시지:**

| `action` | 본문 | 시점 |
|----------|------|------|
| `snapshot` | `notices`: 위와 같은 배열 | 구독 직후 한 번 |
| `raised` | `notice`: 알림 하나 | 새 알림 |
| `updated` | `notice`: 알림 하나 | 내용 변경 (`systemDisk` 는 남은 공간 수치가 바뀔 때마다, 상태가 지속되는 동안 약 5초 간격) |
| `cleared` | `notice`: 마지막 내용 | 조건 해소 |

```json
{"topic": "notice", "action": "updated", "notice": {"id": "systemDisk", "severity": "critical", "message": {"en-US": "Disk C: is almost full: 140MB left", "ko-KR": "C: 디스크 거의 가득 참: 140MB 남음"}, "...": "..."}}
```

#### 시스템 디스크 알림 (`kind: systemDisk`)

*시스템 디스크*는 제품이 데이터베이스와 로그를 저장하는 디스크로, 보통 Windows 가 설치된 `C:` 이며
녹화 디스크와 별개입니다. 이 디스크가 차면 녹화 디스크에 공간이 남아 있어도 새 녹화를 색인하지 못하고
인식 기록이 저장되지 않습니다.

| `severity` | 조건 | `messageKey` |
|----------|------|------|
| `warning` | 여유 공간 1 GB 미만 | `Low disk space on %1%: %2% left` |
| `critical` | 여유 공간 200 MB 미만 | `Disk %1% is almost full: %2% left` |
| `critical` | 최근 60초 안에 공간 부족이나 I/O 오류로 기록을 저장하지 못함 | `Disk %1% is full. Data is not being saved.` |

디스크가 정상으로 돌아오면 해제됩니다. `param` 은 [5.2. 시스템 상태](#52-시스템-상태)의 `systemDisk` 와
같은 필드입니다. 단계가 바뀔 때마다 `systemEvent` 로도 기록합니다([시스템 디스크 경고](#시스템-디스크-경고)
참조). 디스크가 가득 차 이벤트를 기록할 수 없으면 알림으로만 표시됩니다.

## 6. 채널

채널(카메라) 목록 조회 및 관리 API입니다.

### 6.1. 채널 목록

등록된 채널 목록을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel` | 채널 목록 조회 (기본 정보) |
| `GET /api/v1/channel?staticSrc` | 고정 소스 정보 포함 (RTSP URL 등) |
| `GET /api/v1/channel?caps` | 카메라 기능 정보 포함 (PTZ, 릴레이 등) |

**응답**:
```json
[
  {
    "chid": 1,
    "displayName": "CH1. Front Door",
    "title": "Front Door",
    "caps": {
      "pantilt": true,
      "zoom": true
    }
  },
  {
    "chid": 2,
    "displayName": "CH2. Parking Lot",
    "title": "Parking Lot"
  }
]
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `chid` | Int | 채널 ID (1부터 시작) |
| `title` | String | 채널 이름 (사용자 설정 또는 카메라 주소) |
| `displayName` | String | 표시용 이름 (`"CH{N}. {title}"` 형식) |
| `src` | Object | 고정 소스 URL (`staticSrc` 요청 시에만 포함) |
| `caps` | Object | 카메라 기능 정보 (`caps` 요청 시에만 포함) |

**`caps` 객체 필드** (`?caps` 요청 시):

| 필드 | 타입 | 설명 |
|------|------|------|
| `caps.pantilt` | Boolean | 팬/틸트 지원 |
| `caps.zoom` | Boolean | 줌 지원 |
| `caps.focus` | Boolean | 포커스 지원 |
| `caps.iris` | Boolean | 조리개 지원 |
| `caps.home` | Boolean | 홈 포지션 지원 |
| `caps.maxPreset` | Int | 최대 프리셋 수 |
| `caps.aux` | Int | 보조 출력 수 |
| `caps.relayOutputs` | Int | 릴레이 출력 수 |
| `caps.reboot` | Boolean | 원격 재부팅 지원 |

**`src` 배열 항목 필드** (`?staticSrc` 요청 시):

| 필드 | 타입 | 설명 |
|------|------|------|
| `src[].protocol` | String | 프로토콜 (`rtmp`, `flv` 등) |
| `src[].profile` | String | 프로파일 (`main`, `sub`) |
| `src[].src` | String | 스트림 URL |
| `src[].type` | String | 스트림 타입 |
| `src[].label` | String | 해상도 라벨 |
| `src[].size` | Array | `[width, height]` |

### 6.2. 채널 상태

채널 연결 상태를 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel/status` | 전체 채널 상태 조회 |
| `GET /api/v1/channel/status?ch=1,2,3` | 특정 채널만 조회 |
| `GET /api/v1/channel/status?verbose=true` | 상세 상태 정보 포함 (에러 메시지 등) |
| `GET /api/v1/channel/status?recordingStatus` | 녹화 상태 포함 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `ch` | String | N | 전체 | 채널 번호 (쉼표 구분, 예: `"1,2,3"`) |
| `verbose` | Boolean | N | false | 상세 상태 정보 포함 (에러 메시지 등) |
| `recordingStatus` | Flag | N | - | 녹화 상태 포함 (값 없이 키만 전달) |

**응답**:
```json
[
  {
    "chid": 1,
    "status": {
      "code": 0,
      "message": "Connected"
    },
    "recording": true
  },
  {
    "chid": 2,
    "status": {
      "code": -1,
      "message": "Disconnected"
    },
    "recording": false
  }
]
```

**응답 필드**:

| 필드 | 타입 | 설명 |
|------|------|------|
| `chid` | Int | 채널 번호 |
| `title` | String | 채널 이름 |
| `displayName` | String | 표시 이름 |
| `status.code` | Int | 상태 코드 |
| `status.message` | String | 상태 메시지 |

**상태 코드**:

| code | 설명 |
|------|------|
| 0 | Connected (정상 연결) |
| -1 | Disconnected (연결 끊김) |
| -2 | Connecting (연결 시도 중) |
| -3 | Authentication Failed (인증 실패) |

### 6.3. 채널 정보

채널 상세 정보 및 카메라 기능을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel/info` | 전체 채널 상세 정보 |
| `GET /api/v1/channel/info?caps` | 카메라 기능 정보 포함 |
| `GET /api/v1/channel/info?caps&reload` | 카메라에서 기능 정보 다시 조회 |
| `GET /api/v1/channel/{id}/info?caps` | 특정 채널 상세 정보 |

**예제**:
```bash
curl "http://localhost/api/v1/channel/1/info?caps"
```

### 6.4. 채널 추가

새 채널을 등록합니다. **관리자 권한 필요**

```http
POST /api/v1/channel
Content-Type: application/json

{
  "name": "New Camera",
  "source": "rtsp://192.168.1.100/stream"
}
```

### 6.5. 채널 삭제

채널을 삭제합니다. **관리자 권한 필요**

| 엔드포인트 | 설명 |
|----------|-------------|
| `DELETE /api/v1/channel/{id}` | 단일 채널 삭제 |
| `DELETE /api/v1/channel/1,2,3` | 여러 채널 동시 삭제 |

> **예제:** [JavaScript](examples/javascript/02-channels.js) · [Python](examples/python/02_channels.py) · [C#](examples/csharp/02_Channels.cs) · [Go](examples/go/02_channels/) · [Java](examples/java/V1_02_Channels.java) · [Kotlin](examples/kotlin/V1_02_Channels.kt) · [Swift](examples/swift/02-channels.swift) · [PowerShell](examples/powershell/02-channels.ps1) · [curl](examples/curl/02-channels.sh)

---

## 7. 채널 제어

카메라 PTZ, 프리셋, 릴레이 제어 API입니다.

### 7.1. PTZ 제어

카메라 Pan/Tilt/Zoom을 제어합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel/{id}/ptz?home` | 홈 포지션으로 이동 |
| `GET /api/v1/channel/{id}/ptz?move=x,y` | Pan/Tilt 이동 (x,y: -1.0 ~ 1.0) |
| `GET /api/v1/channel/{id}/ptz?zoom=z` | 줌 제어 (z: -1.0=줌아웃, 1.0=줌인) |
| `GET /api/v1/channel/{id}/ptz?focus=f` | 초점 제어 (f: -1.0=near, 1.0=far) |
| `GET /api/v1/channel/{id}/ptz?iris=i` | 조리개 제어 (i: -1.0=close, 1.0=open) |
| `GET /api/v1/channel/{id}/ptz?stop` | PTZ 동작 정지 |

**파라미터**:

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `home` | Flag | 홈 포지션으로 이동 (값 없이 키만 전달) |
| `move` | String | Pan/Tilt 이동 (형식: `"x,y"`, 범위: -1.0 ~ 1.0) |
| `zoom` | Float | 줌 제어 (-1.0=줌아웃, 0=정지, 1.0=줌인) |
| `focus` | Float | 초점 제어 (-1.0=near, 0=정지, 1.0=far) |
| `iris` | Float | 조리개 제어 (-1.0=close, 0=정지, 1.0=open) |
| `stop` | Flag | 모든 PTZ 동작 정지 (값 없이 키만 전달) |

```
              0,-1
               ↑
               |
   -1,0 ←── (0,0) ──→ 1,0        -1 ←──── 0 ────→ 1
               |                         zoom
               ↓                         focus
              0,1                         iris
             move
```

> **참고**: PTZ 명령은 카메라의 ONVIF 서비스를 통해 실행됩니다. 카메라가 ONVIF를 지원하지 않거나 연결이 불안정한 경우 500 오류가 반환될 수 있습니다.

**예제**:
```bash
# Move camera 1 to home position
curl "http://localhost/api/v1/channel/1/ptz?home"

# Pan/Tilt (오른쪽 위로 이동)
curl "http://localhost/api/v1/channel/1/ptz?move=0.3,-0.2"

# Zoom in
curl "http://localhost/api/v1/channel/1/ptz?zoom=0.5"

# Stop all PTZ movement
curl "http://localhost/api/v1/channel/1/ptz?stop"
```

**응답:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `code` | Int | 결과 코드 (0: 성공) |
| `message` | String | 오류 메시지 |

### 7.2. 프리셋

카메라 프리셋(저장된 위치)을 관리합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel/{id}/preset` | 프리셋 목록 조회 |
| `GET /api/v1/channel/{id}/preset?reload` | 카메라에서 프리셋 목록 다시 조회 |
| `POST /api/v1/channel/{id}/preset?name=xxx` | 현재 위치를 프리셋으로 저장 |
| `PUT /api/v1/channel/{id}/preset/{token}` | 프리셋 위치 업데이트 (현재 위치로) |
| `DELETE /api/v1/channel/{id}/preset/{token}` | 프리셋 삭제 |
| `GET /api/v1/channel/{id}/preset/{token}/go` | 해당 프리셋으로 이동 |

**예제**:
```bash
# List presets of channel 1
curl "http://localhost/api/v1/channel/1/preset"

# Go to preset
curl "http://localhost/api/v1/channel/1/preset/preset1/go"
```

**GET /api/v1/channel/{id}/preset 응답:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `chid` | Int | 채널 번호 |
| `preset` | Array | 프리셋 목록 |
| `preset[].token` | String | 프리셋 토큰 |
| `preset[].name` | String | 사용자 정의 이름 |
| `preset[].devName` | String | 장치 정의 이름 |

**POST /api/v1/channel/{id}/preset 파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `name` | String | Y | 프리셋 이름 (쿼리 파라미터) |

**PUT /api/v1/channel/{id}/preset/{token} 파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `name` | String | Y | 새 프리셋 이름 (쿼리 파라미터) |

### 7.3. 릴레이 출력

카메라의 릴레이 출력을 제어합니다 (도어락, 경광등 등).

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/channel/{id}/relay` | 릴레이 출력 목록 조회 |
| `PUT /api/v1/channel/{id}/relay/{uuid}?state=on` | 릴레이 ON |
| `PUT /api/v1/channel/{id}/relay/{uuid}?state=off` | 릴레이 OFF |

**GET 응답:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `chid` | Int | 채널 번호 |
| `relay` | Array | 릴레이 목록 |
| `relay[].token` | String | 릴레이 토큰 |
| `relay[].name` | String | 릴레이 이름 |

**PUT 파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `state` | String | Y | `on` 또는 `off` |

### 7.4. 보조 출력

카메라의 보조 출력을 제어합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `PUT /api/v1/channel/{id}/aux/{port}?state=on` | 보조 출력 ON |
| `PUT /api/v1/channel/{id}/aux/{port}?state=off` | 보조 출력 OFF |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `state` | String | Y | `on` 또는 `off` |

### 7.5. 카메라 재부팅

카메라를 원격으로 재부팅합니다. **관리자 권한 필요**

| 엔드포인트 | 설명 |
|----------|-------------|
| `POST /api/v1/channel/{id}/reboot` | 카메라 재부팅 (ONVIF) |

**응답:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `code` | Int | 결과 코드 (0: 성공) |
| `message` | String | 결과 메시지 |

> **예제:** [JavaScript](examples/javascript/03-ptz-control.js) · [Python](examples/python/03_ptz_control.py) · [C#](examples/csharp/03_PtzControl.cs) · [Go](examples/go/03_ptz/) · [Java](examples/java/V1_03_PtzControl.java) · [Kotlin](examples/kotlin/V1_03_PtzControl.kt) · [Swift](examples/swift/03-ptz-control.swift) · [PowerShell](examples/powershell/03-ptz-control.ps1) · [curl](examples/curl/03-ptz-control.sh)

---

## 8. 녹화

녹화 데이터 검색 API입니다. 캘린더 UI 구현에 사용됩니다.

### 8.1. 녹화 날짜

녹화가 존재하는 날짜를 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/recording/days` | 전체 채널의 녹화 날짜 |
| `GET /api/v1/recording/days?ch=1` | 특정 채널의 녹화 날짜 |
| `GET /api/v1/recording/days?ch=1,2,3` | 여러 채널의 녹화 날짜 |
| `GET /api/v1/recording/days?timeBegin=...&timeEnd=...` | 특정 기간 내 녹화 날짜 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `ch` | String | N | 전체 | 채널 번호 (쉼표 구분, 예: `"1,2,3"`) |
| `timeBegin` | DateTime | N | - | 검색 시작 시간 (ISO 8601) |
| `timeEnd` | DateTime | N | - | 검색 종료 시간 (ISO 8601) |

> **참고**: `X-Host` 헤더가 필요합니다. 일반적인 웹 브라우저 접속 시 자동으로 설정됩니다.

**응답**:
```json
{
  "timeBegin": "2024-01-01T00:00:00",
  "timeEnd": "2024-01-31T23:59:59",
  "data": [
    {
      "year": 2024,
      "month": 1,
      "days": [1, 2, 3, 5, 8, 10]
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `timeBegin` | DateTime | 조회 시작 시간 |
| `timeEnd` | DateTime | 조회 종료 시간 |
| `data` | Array | 채널별 녹화 데이터 |
| `data[].chid` | Int | 채널 번호 |
| `data[].data[].year` | Int | 연도 |
| `data[].data[].month` | Int | 월 |
| `data[].data[].days` | Array\<Int\> | 녹화가 존재하는 일 목록 |

### 8.2. 녹화 시간 (분 단위)

녹화가 존재하는 분 단위 시간을 조회합니다. 타임라인 UI에 사용됩니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/recording/minutes?timeBegin=...&timeEnd=...` | 녹화 구간 조회 (분 단위) |
| `GET /api/v1/recording/minutes?ch=1&timeBegin=...&timeEnd=...` | 특정 채널 녹화 구간 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `ch` | String | N | 전체 | 채널 번호 (쉼표 구분) |
| `timeBegin` | DateTime | Y | - | 검색 시작 시간 (ISO 8601) |
| `timeEnd` | DateTime | Y | - | 검색 종료 시간 (ISO 8601) |

**응답**:
```json
{
  "timeBegin": "2024-01-01T00:00:00",
  "timeEnd": "2024-01-01T23:59:59",
  "data": [
    {
      "chid": 1,
      "minutes": "111111110000..."
    }
  ]
}
```

`minutes`는 조회 기간의 각 분을 한 글자로 표현한 문자열입니다.
- 문자열의 첫 번째 글자(인덱스 0)가 `timeBegin` 시각의 분, 두 번째 글자가 그 다음 분에 해당합니다.
- `'1'` = 해당 분에 녹화가 존재함, `'0'` = 녹화 없음
- 하루(24시간) 조회 시 문자열 길이는 1440자 (24 × 60분)

예를 들어, `timeBegin`이 `2024-01-01T00:00:00`이고 `minutes`가 `"111111110000..."`이면:

| 인덱스 | 시각 | 값 | 의미 |
|--------|------|----|------|
| 0 | 00:00 | `1` | 녹화 있음 |
| 1 | 00:01 | `1` | 녹화 있음 |
| ... | ... | `1` | ... |
| 7 | 00:07 | `1` | 녹화 있음 |
| 8 | 00:08 | `0` | 녹화 없음 |
| ... | ... | `0` | ... |
| 1439 | 23:59 | `0` | 녹화 없음 |

즉, 이 예시에서 채널 1은 00:00~00:07 구간에만 녹화가 존재합니다.

| 필드 | 타입 | 설명 |
|------|------|------|
| `timeBegin` | DateTime | 조회 시작 시간 |
| `timeEnd` | DateTime | 조회 종료 시간 |
| `data` | Array | 채널별 녹화 데이터 |
| `data[].chid` | Int | 채널 번호 |
| `data[].minutes` | String | 분 단위 녹화 비트맵 문자열 (`'1'`=녹화 있음, `'0'`=없음) |

> **예제:** [JavaScript](examples/javascript/04-recording-search.js) · [Python](examples/python/04_recording_search.py) · [C#](examples/csharp/04_RecordingSearch.cs) · [Go](examples/go/04_recording/) · [Java](examples/java/V1_04_RecordingSearch.java) · [Kotlin](examples/kotlin/V1_04_RecordingSearch.kt) · [Swift](examples/swift/04-recording-search.swift) · [PowerShell](examples/powershell/04-recording-search.ps1) · [curl](examples/curl/04-recording-search.sh)

---

## 9. 이벤트

이벤트 조회, 구독, 트리거 API입니다.

### 9.1. 이벤트 유형

시스템에서 지원하는 이벤트 유형 목록을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/event/type` | 이벤트 유형 목록 (기본 언어) |
| `GET /api/v1/event/type?lang=en-US` | 특정 언어로 이벤트 유형 조회 |
| `GET /api/v1/event/type?lang=ko-KR` | 한국어 이벤트 유형 조회 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `lang` | String | N | 언어 코드 ([1.3](#13-언어-lang)). 없으면 NVR 자체의 언어 |

**응답**:
```json
[
  {
    "id": 0,
    "name": "시스템 로그",
    "code": [
      {
        "id": 1,
        "name": "시스템 시작"
      },
      {
        "id": 2,
        "name": "시스템 종료"
      }
    ]
  },
  {
    "id": 1,
    "name": "카메라",
    "code": [
      {
        "id": 100,
        "name": "연결됨"
      },
      {
        "id": 101,
        "name": "연결 끊김"
      }
    ]
  }
]
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | Int | 이벤트 유형 ID |
| `name` | String | 이벤트 유형 이름 (언어별) |
| `code` | Array | 해당 유형의 하위 이벤트 코드 목록 |
| `code[].id` | Int | 이벤트 코드 ID |
| `code[].name` | String | 이벤트 코드 이름 (언어별) |

### 9.2. 실시간 이벤트 토픽

실시간 이벤트 구독에 사용 가능한 토픽 목록을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/event/realtime` | 구독 가능한 토픽 목록 |

**응답**:
```json
[
  "channelStatus",
  "emergencyCall",
  "LPR",
  "systemEvent",
  "notice",
  "motionChanges",
  "recordingStatus",
  "parkingCount",
  "parkingSpot",
  "object",
  "bodyTemperature",
  "vehicleTracking"
]
```

> 구독 가능한 토픽 이름의 문자열 배열을 반환합니다. 이 토픽 이름은 실시간 이벤트 구독(SSE) 시 필터로 사용됩니다.

### 9.3. 이벤트 로그

저장된 이벤트 로그를 검색합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/event/log` | 최근 이벤트 목록 |
| `GET /api/v1/event/log?timeBegin=...&timeEnd=...` | 특정 기간 이벤트 검색 |
| `GET /api/v1/event/log?at=10&maxCount=20` | 페이지네이션 (10번부터 20개) |
| `GET /api/v1/event/log?sort=asc` | 오래된 순 정렬 (기본: desc) |
| `GET /api/v1/event/log?type=0` | 특정 이벤트 타입만 검색 |
| `GET /api/v1/event/log?ch=1,2` | 특정 채널만 검색 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `timeBegin` | DateTime | N | - | 검색 시작 시간 (ISO 8601) |
| `timeEnd` | DateTime | N | - | 검색 종료 시간 (ISO 8601) |
| `at` | Int | N | 0 | 시작 인덱스 (페이지네이션) |
| `maxCount` | Int | N | 50 | 최대 결과 수 |
| `sort` | String | N | `"desc"` | 정렬 순서 (`"asc"` 또는 `"desc"`) |
| `type` | Int | N | - | 이벤트 유형 ID 필터 |
| `ch` | String | N | - | 채널 필터 (쉼표 구분, 예: `"1,2,3"`) |

**응답**:
```json
{
  "totalCount": 100,
  "at": 0,
  "data": [
    {
      "id": 1,
      "type": 1,
      "typeName": "Camera",
      "code": 100,
      "codeName": "Connected",
      "chid": 1,
      "timeRange": ["2024-01-01T10:00:00"]
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalCount` | Int | 총 검색 결과 수 |
| `at` | Int | 현재 시작 인덱스 |
| `data[].id` | Int | 이벤트 ID |
| `data[].type` | Int | 이벤트 유형 ID |
| `data[].typeName` | String | 이벤트 유형 이름 |
| `data[].code` | Int | 이벤트 코드 |
| `data[].codeName` | String | 이벤트 코드 이름 |
| `data[].chid` | Int | 관련 채널 ID. 이벤트가 특정 채널 하나에 해당하지 않으면 `null` 입니다. 여러 채널에 걸친 이벤트는 채널 목록을 `param` 에 포함합니다(아래 참조) |
| `data[].timeRange` | Array | 이벤트 발생 시간 범위 |
| `data[].param` | Object | 이벤트별 상세 정보(저장된 원본). 형태는 `code` 에 따라 다르고 키가 추가될 수 있으므로, 처리하지 않는 키는 무시하십시오. `typeName` / `codeName` 과 달리 **번역되지 않습니다**. |

#### 스토리지 장애 상세

`codeName` 이 `"저장 장치 오류"` / `"저장 장치 준비 완료"` 인 녹화 이벤트는 `param.statusCode` 를 함께 포함합니다.

| `statusCode` | 의미 |
|-----:|---------|
| `0` | 정상 |
| `-1` | 존재하지 않음 |
| `-2` | 쓰기 전용 |
| `-4` | 읽기 전용 |
| `-6` | 읽기/쓰기 거부됨 |
| `-8` | 스토리지 정리 중단 — 정리 작업이 멈춘 상태입니다. 녹화는 계속되지만 지연 삭제와 고아 파일 정리가 수행되지 않습니다 |
| `-9` | 스토리지 쓰기 정지 — 기록할 데이터가 대기 중인데 스토리지에 한 바이트도 기록되지 않았습니다 |
| `-100` | 알 수 없는 오류 |

`-9` 는 다음 두 조건에서 발생하며, 각각 의미가 다릅니다.

| 발생 조건 | 포함 필드 |
|---|---|
| 10초를 넘는 디스크 I/O 호출이 1시간 관측 구간 안에 3건 이상 발생 | `stallCount`, `stalledSec`, `chid` |
| 기록할 데이터가 대기 중인데 스토리지에 한 바이트도 기록되지 않음 | `stalledSec` |

첫 번째 조건은 **사건 행**으로 기록됩니다. 장애가 끝난 뒤가 아니라 조건을 만족하는 즉시 생성되고, 지속되는 동안 약 1분 간격으로 갱신되며(`ongoing: true`), 관측 구간의 건수가 기준 아래로 내려가면 확정됩니다. `data[].timeRange` 도 함께 늘어나므로 같은 `data[].id` 를 나중에 다시 조회하면 더 넓은 구간이 반환됩니다. 두 번째 조건은 정지가 끝난 뒤 한 번만 기록됩니다.

정지로 실제 영상 손실이 발생한 경우 두 조건 모두 **손실 요약**(`lostSec`, `channels`, `channelList`, `droppedFrames`)을 함께 포함합니다. 집계는 사건이 시작된 시점부터입니다. 손실 정도는 프레임 수가 아니라 **영상 길이(초)와 채널 수**로 표시합니다.

**손실이 없으면 이 네 키가 모두 생략됩니다.** 쓰기 큐가 정지 시간을 흡수한 정상적인 경우입니다. 키가 없으면 "손실 없음"으로 처리하십시오. 값이 누락된 것으로 간주해 0 을 채워 "손실 0" 으로 보고하지 마십시오.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `storagePath` | String | 정지가 발생한 녹화 스토리지 |
| `stalledSec` | Int | 사건 중 가장 길었던 단일 무응답 시간(초) |
| `stallCount` | Int | 사건 동안 10초를 넘긴 디스크 I/O 호출 건수 |
| `chid` | Int | 그중 가장 오래 걸린 호출이 발생한 채널. `data[].chid` 와 달리 **0부터 시작** |
| `lostSec` | Int | 사건 동안 실제로 손실된 영상 길이(초, 전 채널 합계). 손실이 없으면 생략 |
| `channels` | Int | 영상이 손실된 채널 수. 손실이 없으면 생략 |
| `channelList` | Array | 해당 채널 ID 목록. **0부터 시작**. 손실이 없으면 생략 |
| `droppedFrames` | Int | 손실된 프레임 수(전 채널 합계). `lostSec` 의 진단용 상세 정보. 손실이 없으면 생략 |
| `ongoing` | Bool | 사건이 진행 중이면 `true` |

손실이 없는 정지(일반적인 경우):

```json
{
  "storagePath": "G:\\recData",
  "statusCode": -9,
  "stalledSec": 20
}
```

영상 손실이 있었던 정지:

```json
{
  "storagePath": "G:\\recData",
  "statusCode": -9,
  "stalledSec": 67,
  "stallCount": 19,
  "chid": 3,
  "lostSec": 200,
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

`lostSec` 은 **실제로 영상이 비어 있는 시간의 합계**이며, 사건이 걸쳐 있던 시간대가 아닙니다. 두 시간 동안 지속된 `-9` 사건에서도 손실은 3분일 수 있습니다. 구간은 `"녹화 프레임 누락"` 의 `period` 로, 손실 규모는 `lostSec` 으로 확인하십시오.

#### 녹화 프레임 누락 상세

`"녹화 프레임 누락"` 은 복구할 수 없는 영상 손실을 기록합니다.

**한 이벤트는 채널 하나가 아니라 사건 하나를 나타냅니다.** 같은 구간에 여러 채널에서 발생한 프레임 누락을 한 행으로 묶으므로 `data[].chid` 는 `null` 이고, 영향받은 채널은 `param` 에 포함됩니다. 60초 동안 누락이 없으면 사건이 종료됩니다. 위의 `-9` 와 마찬가지로 행은 즉시 생성되고 사건이 지속되는 동안 갱신되며, `data[].timeRange` 와 `param.period` 가 함께 늘어납니다.

같은 시각의 `-9` 가 일반적으로 그 **원인**입니다. 스토리지 기록 속도가 부족해 쓰기 큐가 프레임을 거부한 경우입니다. 반면 한두 채널에서만 발생한 누락은 다른 원인을 확인해야 합니다. 디스크 지연은 특정 채널에만 영향을 주지 않습니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `period` | Array | 누락 구간 — 시작과 끝, ISO 8601 두 개 |
| `channels` | Int | 영향받은 채널 수 |
| `channelList` | Array | 영향받은 채널 ID 목록. `data[].chid` 와 달리 **0부터 시작** |
| `droppedFrames` | Int | 사건 동안 손실된 프레임 수(전 채널 합계) |
| `ongoing` | Bool | 사건이 진행 중이면 `true` |

```json
{
  "period": ["2026-08-31T19:36:41", "2026-08-31T20:22:30"],
  "channels": 9,
  "channelList": [0, 1, 2, 4, 7, 8, 11, 12, 15],
  "droppedFrames": 74213,
  "ongoing": true
}
```

#### 녹화 누락 상세

`"녹화 누락"` 은 채널 단위 이벤트이므로 `data[].chid` 가 해당 채널을 가리킵니다. 녹화 감시 기능이 해당 채널에 기록되는 데이터가 없음을 확인하고 스트림을 재시작한 경우입니다. 나머지 필드는 그 시점의 상태로, 스토리지 문제와 스트림 문제를 구분하는 근거가 됩니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `secs` | Int | 재시작 전까지 녹화가 실패한 시간(초) |
| `streamFps` | Int | 그 시점의 스트림 프레임 레이트. `0` 이면 원인은 스토리지가 아니라 카메라 또는 네트워크입니다 |
| `storage` | Int | 사용 중인 녹화 스토리지 ID |
| `freeMB` | Int | 그 스토리지의 남은 용량(MB). 조회에 실패하면 `-1` |
| `anchorAge` | Int | 남은 용량을 마지막으로 측정한 뒤 경과한 시간(초). 값이 크면 볼륨이 응답하지 않는 상태입니다. 한 번도 측정하지 못했으면 `-1` |
| `queuePct` | Int | 쓰기 큐 사용률(%). 값이 낮은데도 녹화가 실패하면 큐 적체는 원인이 아닙니다. 조회할 수 없으면 `-1` |

```json
{
  "secs": 30,
  "streamFps": 15,
  "storage": 2,
  "freeMB": 10240,
  "anchorAge": -1,
  "queuePct": 0
}
```

#### 시스템 디스크 경고

시스템 디스크의 단계 변화를 시스템 로그 이벤트로 기록합니다([5.2. 시스템 상태](#52-시스템-상태)의
`systemDisk` 참조). 단계가 바뀔 때마다 한 번 기록합니다. 현재 상태는 시스템 알림
([5.5. 시스템 알림](#55-시스템-알림))으로 확인하십시오.

| `code` | `codeName` | 시점 |
|-----:|---------|------|
| `51` | `"System disk space is low"` | 여유 공간이 1 GB 아래로 내려감 |
| `52` | `"System disk is full"` | 여유 공간이 200 MB 아래로 내려가거나, 공간 부족이나 I/O 오류로 기록을 저장하지 못함 |
| `53` | `"System disk space has been restored."` | 정상으로 돌아옴 |

`codeName` 은 요청 언어로 번역됩니다. `param` 에는 상태 API 의 `systemDisk` 와 같은 필드
(`drive`, `totalSpace`, `freeSpace`, `status`, `dataWriteFailed`)가 포함됩니다.

디스크가 가득 차 이벤트를 저장하지 못한 경우에도 `systemEvent` 구독자에게는 `id` 가 `-1` 인 이벤트로
전달되지만, 이벤트 로그에는 기록되지 않습니다. 이 경고를 반드시 받아야 하는 클라이언트는 로그 조회
대신 구독을 사용하십시오.

#### 로그인 실패

개인 정보 이벤트(`type` `1`)의 `code` `6`(`"Failure to sign in"`)은 로그인 실패를 기록합니다.
로컬 화면, API, 실시간 스트림의 비밀번호 인증 실패가 모두 포함됩니다. `param` 필드는 다음과 같습니다.

| 필드 | 설명 |
|------|------|
| `uid` | 입력한 사용자 ID |
| `addr` | 접속 주소. 서버 PC 에서 접속한 경우 `"local"` |
| `lockedUntil` | 이 실패로 로그인 차단이 시작된 경우 차단 해제 시각(ISO 8601). 그 밖에는 생략됩니다. |

### 9.4. 이벤트 트리거 (이벤트 백업)

지정 채널의 PTZ 프리셋 이동 및/또는 이벤트 백업 녹화를 트리거합니다. 외부 시스템 연동(출입 통제, 화재 감지, 침입 감지 등)에 사용됩니다.

> **이벤트 백업** 라이선스가 필요합니다. 라이선스가 설치되지 않은 경우 `404`를 반환합니다.

| 엔드포인트 | 설명 | 권한 |
|----------|-------------|------|
| `PUT /api/v1/event/trigger` | PTZ 프리셋 이동 및/또는 이벤트 백업 트리거 | `Control` |

**요청**:

```http
PUT /api/v1/event/trigger
Content-Type: application/json

{
  "chid": 1,
  "timestamp": "2024-01-15T14:30:00",
  "tasks": [
    {
      "command": "presetGo",
      "token": "preset_token_1"
    },
    {
      "command": "eventBackup",
      "preAlarm": "30s",
      "postAlarm": "2m",
      "chids": [1, 2, 3]
    }
  ]
}
```

**요청 필드**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `chid` | Int | Y | 주 채널 ID (1-based) |
| `timestamp` | DateTime | N | 이벤트 발생 시간 (ISO 8601). 생략 시 서버 현재 시간 사용 |
| `tasks` | Array | Y | 실행할 작업 객체 배열 |

**작업 명령**:

| 명령 | 설명 |
|------|------|
| `presetGo` | 카메라를 PTZ 프리셋 위치로 이동 |
| `eventBackup` | 녹화를 시작하고 이벤트 스토리지에 백업 예약 |

**`presetGo` 요청 필드**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `command` | String | Y | `"presetGo"` |
| `token` | String | Y | PTZ 프리셋 토큰 (ONVIF 프리셋 목록에서 조회) |

**`eventBackup` 요청 필드**:

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `command` | String | Y | `"eventBackup"` |
| `preAlarm` | String/Int | N | 이벤트 이전 녹화 기간. 문자열(`"30s"`, `"5m"`) 또는 초 단위 숫자. 기본값: 5분, 최대: 1시간 |
| `postAlarm` | String/Int | N | 이벤트 이후 녹화 기간. 문자열(`"30s"`, `"5m"`) 또는 초 단위 숫자. 기본값: 60분, 최대: 1시간 |
| `chids` | Array\<Int\> | N | 백업 대상 채널 ID (1-based). 생략 시 `[chid]` 사용 |

> 기간 형식: 숫자(초 단위) 또는 접미사 포함 문자열 — `s`(초), `m`(분), `h`(시간). 예: `30`, `"30s"`, `"5m"`, `"1h"`.

**응답**:

```json
{
  "eventId": 12345,
  "videoURLs": [
    "/event-storage/c/20240115/143000/ch1-20240115-143000.mp4",
    "/event-storage/c/20240115/143000/ch2-20240115-143000.mp4",
    "/event-storage/c/20240115/143000/ch3-20240115-143000.mp4"
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `eventId` | Int | 이벤트 로그 ID |
| `videoURLs` | Array\<String\> | 백업 영상 URL (post-alarm 녹화 완료 후 접근 가능) |

> 백업은 비동기로 실행됩니다. `videoURLs`는 즉시 반환되지만, 실제 영상 파일은 post-alarm 기간이 경과하고 백업이 완료된 후에 접근할 수 있습니다.

> **예제:** [JavaScript](examples/javascript/05-event-log.js) · [Python](examples/python/05_event_log.py) · [C#](examples/csharp/05_EventLog.cs) · [Go](examples/go/05_events/) · [Java](examples/java/V1_05_EventLog.java) · [Kotlin](examples/kotlin/V1_05_EventLog.kt) · [Swift](examples/swift/05-event-log.swift) · [PowerShell](examples/powershell/05-event-log.ps1) · [curl](examples/curl/05-event-log.sh)

---

## 10. LPR (차량 번호 인식)

차량 번호 인식 관련 API입니다.

### 10.1. LPR 소스 (인식 지점/영역)

LPR 소스(인식 지점/영역) 목록을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/lpr/source` | LPR 소스 목록 조회 |

**응답**:
```json
[
  {
    "id": 1,
    "code": "GATE-IN",
    "name": "Entrance Gate",
    "linkedChannel": [1, 2],
    "tag": "Normal"
  }
]
```

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | Int | 소스 ID |
| `code` | String | 소스 코드 |
| `name` | String | 소스 이름 |
| `linkedChannel` | Array\<Int\> | 연결된 채널 목록 |
| `tag` | String | 상태 태그 (`Normal`, `ReadOnly`, `NotUsed`) |

### 10.2. LPR 로그

차량 번호 인식 기록을 검색합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/lpr/log` | 최근 인식 기록 |
| `GET /api/v1/lpr/log?keyword=1234` | 번호판 검색 (부분 일치) |
| `GET /api/v1/lpr/log?timeBegin=...&timeEnd=...` | 특정 기간 검색 |
| `GET /api/v1/lpr/log?src=1,2` | 특정 LPR 소스만 검색 |
| `GET /api/v1/lpr/log?at=0&maxCount=50` | 페이지네이션 |
| `GET /api/v1/lpr/log?sort=asc` | 오래된 순 정렬 |
| `GET /api/v1/lpr/log?export=true` | CSV 내보내기 형식 |
| `GET /api/v1/lpr/log?unrecognized=true` | 번호를 읽지 못한 건만 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `keyword` | String | N | - | 번호판 검색어 (부분 일치) |
| `unrecognized` | Boolean | N | false | 번호를 **읽지 못한** 건만 조회. 키워드로는 검색할 수 없으므로 별도 조건으로 제공합니다 |
| `timeBegin` | DateTime | Y | - | 검색 시작 시간 (ISO 8601) |
| `timeEnd` | DateTime | Y | - | 검색 종료 시간 (ISO 8601) |
| `src` | String | N | - | LPR 소스 필터 (쉼표 구분) |
| `at` | Int | N | 0 | 시작 인덱스 (페이지네이션) |
| `maxCount` | Int | N | 50 | 최대 결과 수 |
| `sort` | String | N | `"desc"` | 정렬 순서 (`"asc"` 또는 `"desc"`) |
| `export` | Boolean | N | false | true 시 CSV 내보내기 형식으로 반환 |

> **번호를 읽지 못한 건.** `plateNo` 가 `null` 입니다. 이전에는 자리표시 문자열(`xxxx`)이
> 들어가 번호처럼 보였으나, 현재는 "번호 없음"을 나타내는 `null` 로 통일했습니다.
> 키워드로는 검색할 수 없으므로 `unrecognized=true` 를 사용하십시오.

> **참고**: `timeBegin`과 `timeEnd`는 필수입니다. `export=true` 요청은 큰 데이터셋에서 시간이 오래 걸릴 수 있으므로 적절한 타임아웃을 설정하세요.

**응답**:
```json
{
  "totalCount": 50,
  "at": 0,
  "data": [
    {
      "id": 1,
      "plateNo": "12가3456",
      "score": 95.5,
      "timeRange": ["2024-01-01T10:00:00"],
      "srcCode": "GATE-IN",
      "srcName": "Entrance Gate",
      "direction": "entry",
      "image": ["/lpr/image1.jpg"],
      "vod": [
        {
          "chid": 1,
          "videoSrc": "/watch?ch=1&when=..."
        }
      ]
    }
  ]
}
```

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalCount` | Int | 전체 결과 수 |
| `at` | Int | 현재 오프셋 |
| `data` | Array | 인식 결과 목록 |
| `data[].id` | Int | 레코드 ID |
| `data[].plateNo` | String | 차량 번호. 항상 **현재** 값입니다. 번호를 수정한 경우([10.4](#104-차량-번호-수정)) 수정된 번호입니다 |
| `data[].plateEdited` | Boolean | 사람이 번호를 수정했으면 `true` |
| `data[].originalPlateNo` | String | (`plateEdited` 일 때만) 처음 인식한 번호 (읽지 못했으면 `""`) |
| `data[].score` | Float | 인식 신뢰도 |
| `data[].timeRange` | Array | `[시작시간, 종료시간]` (ISO 8601) |
| `data[].srcCode` | String | LPR 소스 코드 |
| `data[].srcName` | String | LPR 소스 이름 |
| `data[].direction` | String | 방향 (`entry`, `exit`) |
| `data[].image` | Array\<String\> | 이미지 URL 목록 |
| `data[].vod` | Array | 연결된 영상 정보 |
| `data[].vod[].chid` | Int | 채널 번호 |
| `data[].vod[].videoSrc` | String | 영상 URL |

### 10.3. 유사 번호판 검색

번호판의 일부 또는 전체를 키워드로 검색합니다. 키워드를 포함하는 모든 번호판을 반환하므로, 부분 번호 검색이나 오인식 대응에 활용할 수 있습니다.

예를 들어, 차량 번호의 네 자리 숫자 `1234`만 알고 있는 경우 `keyword=1234`로 검색하면 `"12가1234"`, `"56나1234"` 등 해당 숫자를 포함하는 모든 인식 기록을 찾을 수 있습니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/lpr/similar?keyword=1234` | `1234`를 포함하는 번호판 검색 |
| `GET /api/v1/lpr/similar?keyword=12가` | `12가`를 포함하는 번호판 검색 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `keyword` | String | Y | 검색할 번호판 키워드 (일부 또는 전체). 입력한 문자열을 포함하는 번호판을 검색합니다. |

**응답:** 키워드를 포함하는 번호판 문자열 배열 (최근 인식순)
```json
["12가1234", "56나1234", "78다1234", ...]
```

### 10.4. 차량 번호 수정

오인식된 인식 기록 **한 건**의 번호를 수정합니다. 주차 정산에서는 세션의 대표 번호를
수정합니다([16.9](#169-차량-번호-수정)).

| 엔드포인트 | 설명 |
|-----------|------|
| `POST /api/v1/lpr/log/{id}/plate` | 기록 `{id}` 의 번호 수정 |
| `GET /api/v1/lpr/log/{id}/plate/history` | 기록 `{id}` 의 수정 이력 |

**규칙**

| 항목 | 규칙 |
|---|---|
| 대상 | `id` 로 지정한 기록 **한 건**뿐입니다. 일괄 수정이나 번호 값으로 대상을 찾는 수정은 지원하지 않습니다 |
| `id` 확인 방법 | [10.2](#102-lpr-로그) 의 `data[].id`, 또는 실시간 `LPR` 이벤트의 각 `plateNo` 와 함께 전달되는 `id` |
| 이력 | 수정할 때마다 한 건씩 누적되며 이전 기록은 변경되지 않습니다. 잘못된 수정도 기록에 남으므로 다시 수정하여 바로잡습니다 |
| 형식 | 검사하지 않습니다(국가마다 다름). 앞뒤 공백을 제외하고 1~32자 |
| 효과 | 저장된 기록만 변경됩니다. 이미 처리된 이벤트(푸시, 등록 차량 대조, 전광판)는 다시 판정하지 않습니다 |
| 권한 | **제어(Control)** |

**파라미터** (쿼리, form, 또는 JSON 본문):

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `plateNo` | String | Y | 새 번호 (1~32자) |
| `reason` | String | N | 수정 사유 (200자 이하) |

**응답**:
```json
{
  "id": 91234,
  "plateNo": "12가3456",
  "previousPlateNo": "12가3458",
  "originalPlateNo": "12가3458",
  "editCount": 1,
  "edit": {
    "id": 57,
    "time": "2026-10-22T14:03:11.000+09:00",
    "user": "admin",
    "reason": "야간 오인식"
  }
}
```

| 필드 | 설명 |
|------|------|
| `previousPlateNo` | 이번 수정 직전 값 (미인식 기록이었으면 `""`) |
| `originalPlateNo` | 처음 인식한 값 |
| `editCount` | 이번을 포함한 누적 수정 횟수 |
| `edit.user` | 수정한 계정 (API 키면 그 키를 발급한 계정) |

**이력 응답**:
```json
{
  "target": "lpr",
  "id": 91234,
  "plateNo": "12가3456",
  "originalPlateNo": "12가3458",
  "edits": [
    { "id": 41, "time": "2026-10-22T13:58:02.000+09:00", "user": "admin",
      "before": "12가3458", "after": "12가3486", "reason": "" },
    { "id": 57, "time": "2026-10-22T14:03:11.000+09:00", "user": "admin",
      "before": "12가3486", "after": "12가3456", "reason": "야간 오인식" }
  ]
}
```

`edits` 는 기록된 순서로 정렬됩니다. 수정 이력이 없으면 빈 배열이며 `originalPlateNo` 는 생략됩니다.
이력 조회는 **재생(Playback)** 권한이 필요합니다.

| 상태 | 의미 |
|------|-----|
| `400` | ID 가 잘못됨, `plateNo` 누락·빈 값·32자 초과, 또는 `reason` 200자 초과 |
| `403` | **제어(Control)** 권한이 필요합니다 (이력은 **재생(Playback)**) |
| `404` | 해당 ID 의 기록이 없습니다 |
| `409` | `plateNo` 가 현재 번호와 같습니다 |

> **예제:** [JavaScript](examples/javascript/06-lpr-search.js) · [Python](examples/python/06_lpr_search.py) · [C#](examples/csharp/06_LprSearch.cs) · [Go](examples/go/06_lpr/) · [Java](examples/java/V1_06_LprSearch.java) · [Kotlin](examples/kotlin/V1_06_LprSearch.kt) · [Swift](examples/swift/06-lpr-search.swift) · [PowerShell](examples/powershell/06-lpr-search.ps1) · [curl](examples/curl/06-lpr-search.sh)

---

## 11. 객체 감지

객체 감지 기능이 탑재된 AI 카메라로부터 출력되는 메타데이터를 기록하고, 녹화 데이터를 조회하는 API입니다. 이 기능을 사용하려면 객체 감지를 지원하는 AI 카메라가 연동되어 있어야 합니다.

> **참고**: Object Detection은 해당 라이선스가 필요합니다. 라이선스가 활성화되지 않은 경우 404를 반환합니다.

### 11.1. 객체 유형

시스템에서 감지 가능한 객체 유형을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/object/type` | 감지 가능한 객체 유형 목록 |

**응답**:
```json
["face", "human", "vehicle"]
```

### 11.2. 객체 속성

객체 유형별 검색 가능한 속성을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/object/attr` | 전체 객체 속성 |
| `GET /api/v1/object/attr?type=face` | 얼굴 객체 속성 |
| `GET /api/v1/object/attr?type=human` | 사람 객체 속성 |
| `GET /api/v1/object/attr?type=vehicle` | 차량 객체 속성 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `type` | String | N | 객체 유형 필터 (`face`, `human`, `vehicle`). 생략 시 전체. |

**응답**:
```json
{
  "face": {
    "gender": ["female", "male"],
    "age": ["young", "adult", "middle", "senior"],
    "hat": [true, false],
    "glasses": [true, false],
    "mask": [true, false]
  }
}
```

### 11.3. 객체 로그

감지된 객체를 속성으로 검색합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/object/log` | 전체 객체 검색 |
| `GET /api/v1/object/log?objectType=face` | 얼굴만 검색 |
| `GET /api/v1/object/log?objectType=human&gender=male` | 남성만 검색 |
| `GET /api/v1/object/log?objectType=human&upper=red` | 상의 빨간색 검색 |
| `GET /api/v1/object/log?objectType=vehicle&vehicleType=car` | 승용차만 검색 |
| `GET /api/v1/object/log?objectType=vehicle&color=white` | 흰색 차량 검색 |
| `GET /api/v1/object/log?timeBegin=...&timeEnd=...` | 특정 기간 검색 |
| `GET /api/v1/object/log?ch=1,2` | 특정 채널만 검색 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|----------|------|------|--------|------|
| `timeBegin` | DateTime | N | - | 검색 시작 시간 (ISO 8601) |
| `timeEnd` | DateTime | N | - | 검색 종료 시간 (ISO 8601) |
| `ch` | String | N | 전체 | 채널 번호 (쉼표 구분) |
| `objectType` | String | N | 전체 | `human`, `face`, `vehicle` |
| `gender` | String | N | - | `male`, `female` |
| `vehicleType` | String | N | - | `car`, `truck`, `bus`, `bicycle`, `motorcycle` |
| `at` | Int | N | 0 | 페이지 오프셋 |
| `maxCount` | Int | N | 100 | 최대 결과 수 |
| `sort` | String | N | `desc` | `asc` 또는 `desc` |

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalCount` | Int | 전체 결과 수 |
| `at` | Int | 현재 오프셋 |
| `data` | Array | 객체 목록 |
| `data[].timestamp` | DateTime | 감지 시간 |
| `data[].chid` | Int | 채널 번호 |
| `data[].type` | String | 객체 유형 |
| `data[].attributes` | Object | 객체 속성 |
| `data[].image` | String | 이미지 URL |

---

## 12. 얼굴 검색

사진으로 녹화 영상에서 해당 인물을 검색하는 API입니다. 딥러닝 기반 얼굴 특징 벡터를 비교하여 유사한 얼굴을 검색합니다. 객체 인식 기능이 탑재된 AI 카메라가 연동되어 있어야 사용할 수 있습니다.

> **참고**: Face Search는 해당 라이선스가 필요합니다. 라이선스가 활성화되지 않은 경우 404를 반환합니다.

### 12.1. 이미지로 검색

업로드한 얼굴 이미지와 유사한 얼굴을 검색합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `POST /api/v1/face/search` | 이미지 기반 얼굴 검색 |

```http
POST /api/v1/face/search
Content-Type: multipart/form-data

file: <image_file>
threshold: 0.7
timeBegin: 2024-01-01
timeEnd: 2024-01-31
ch: 1,2,3
```

**파라미터**:
| 파라미터 | 타입 | 설명 |
|-----------|------|-------------|
| `file` | File | 검색할 얼굴 이미지 (JPEG, PNG) |
| `threshold` | Float | 유사도 임계값 (0.0~1.0, 기본 0.7) |
| `timeBegin` | DateTime | 검색 시작 시간 |
| `timeEnd` | DateTime | 검색 종료 시간 |
| `ch` | String | 채널 필터 (쉼표 구분) |
| `maxCount` | Int | 최대 결과 수 |

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalCount` | Int | 검색 결과 수 |
| `code` | Int | 결과 코드 |
| `data` | Array | 검색 결과 목록 |
| `data[].chid` | Int | 채널 번호 |
| `data[].timestamp` | DateTime | 감지 시간 |
| `data[].threshold` | Float | 유사도 점수 |
| `data[].faceImg` | String | 얼굴 이미지 URL |
| `data[].orgImg` | String | 원본 이미지 URL |

### 12.2. 시간 범위로 검색

특정 기간에 감지된 모든 얼굴을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/face/search?timeBegin=...&timeEnd=...` | 기간별 얼굴 목록 |
| `GET /api/v1/face/search?ch=1&timeBegin=...&timeEnd=...` | 특정 채널 얼굴 목록 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `ch` | String | N | 채널 번호 (쉼표 구분) |
| `timeBegin` | DateTime | Y | 검색 시작 시간 |
| `timeEnd` | DateTime | Y | 검색 종료 시간 |

---

## 13. VOD

실시간 스트림 및 녹화 재생 URL을 조회합니다.

### 13.1. 스트림 URL

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/vod` | 전체 채널 실시간 스트림 URL |
| `GET /api/v1/vod?when=now` | 실시간 스트림 (명시적) |
| `GET /api/v1/vod?ch=1` | 특정 채널 스트림 |
| `GET /api/v1/vod?ch=1,2,3` | 여러 채널 스트림 |
| `GET /api/v1/vod?protocol=rtmp` | RTMP 스트림만 조회 |
| `GET /api/v1/vod?protocol=flv` | HTTP-FLV 스트림만 조회 |
| `GET /api/v1/vod?protocol=websocket-flv` | WebSocket-FLV 스트림만 조회 |
| `GET /api/v1/vod?protocol=rtsp` | RTSP 스트림만 조회 |
| `GET /api/v1/vod?stream=sub` | 서브스트림 (저해상도) |
| `GET /api/v1/vod?stream=main` | 메인스트림 (고해상도) |

### 13.2. 재생 URL

녹화 영상 재생 URL을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/vod?ch=1&when=2024-01-08T09:30:00` | 특정 시간 녹화 재생 |
| `GET /api/v1/vod?id=1304&next` | 다음 녹화 세그먼트 |
| `GET /api/v1/vod?id=1304&prev` | 이전 녹화 세그먼트 |
| `GET /api/v1/vod?ch=1&when=...&otherwise=nearBefore` | 해당 시각 녹화, 없으면 **가장 가까운 과거** 녹화 |

**`otherwise` — 요청 시각에 녹화가 없을 때의 동작**

| 값 | 동작 |
|----|------|
| (생략) | 해당 채널은 아무것도 반환하지 않습니다 |
| `nearBefore` | 요청 시각보다 **앞선** 가장 가까운 녹화 |
| `nearAfter` | 요청 시각보다 **뒤인** 가장 가까운 녹화 |

`nearBefore` 는 주차 내역 조회용입니다. 주차된 차량은 움직이지 않으므로 움직임 조건 녹화가
중단되었을 수 있지만, 차량은 같은 위치에 있으므로 직전 영상이 해당 시점의 상황을 보여 줍니다.
주차 내역(16.5 이하)에서 시작한 요청에만 사용하십시오. 이벤트·차량 번호·객체 검색에는 사용하지
마십시오. 이 검색은 해당 시점에 발생한 일을 조회하므로, 이전 영상을 대신 표시하면 다른 시점의
영상을 해당 시점의 영상으로 잘못 보여 주게 됩니다.

**응답**:
```json
[
  {
    "chid": 1,
    "title": "Front Door",
    "displayName": "CH1. Front Door",
    "src": [
      {
        "protocol": "rtmp",
        "profile": "main",
        "src": "rtmp://host/live/ch1main",
        "type": "rtmp/mp4",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "flv",
        "profile": "main",
        "src": "https://host/live?app=live&stream=ch1main",
        "type": "video/x-flv",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "websocket-flv",
        "profile": "main",
        "src": "wss://host/live?app=live&stream=ch1main",
        "type": "video/x-flv",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "rtsp",
        "profile": "main",
        "src": "rtsp://host/live/ch1main",
        "type": "application/x-rtsp",
        "label": "1080p",
        "size": [1920, 1080]
      },
      {
        "protocol": "rtmp",
        "profile": "sub",
        "src": "rtmp://host/live/ch1sub",
        "type": "rtmp/mp4",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "flv",
        "profile": "sub",
        "src": "https://host/live?app=live&stream=ch1sub",
        "type": "video/x-flv",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "websocket-flv",
        "profile": "sub",
        "src": "wss://host/live?app=live&stream=ch1sub",
        "type": "video/x-flv",
        "label": "VGA",
        "size": [640, 480]
      },
      {
        "protocol": "rtsp",
        "profile": "sub",
        "src": "rtsp://host/live/ch1sub",
        "type": "application/x-rtsp",
        "label": "VGA",
        "size": [640, 480]
      }
    ]
  }
]
```

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `ch` | String | N | 전체 | 채널 번호 (쉼표 구분, 예: `"1,2,3"`) |
| `when` | String | N | `"now"` | `"now"`=실시간, ISO 8601=녹화 재생 |
| `protocol` | String | N | 전체 | 프로토콜 필터 (아래 표 참조) |
| `stream` | String | N | 전체 | 스트림 종류 (`"main"`=고해상도, `"sub"`=저해상도) |
| `id` | Int | N | - | VOD 세그먼트 ID (녹화 탐색용) |
| `next` | Flag | N | - | 다음 녹화 세그먼트 (`id`와 함께 사용) |
| `prev` | Flag | N | - | 이전 녹화 세그먼트 (`id`와 함께 사용) |
| `otherwise` | String | N | - | 요청 시각에 녹화가 없을 때의 대체 방법 (`nearBefore` / `nearAfter`, 위 표 참조) |
| `duration` | String | N | `"1m"` | `when` 부터 검색할 구간. 숫자만 입력하면 초 단위, 접미사로 `m`·`h`·`d`·`w` 사용 |
| `limit` | Int | N | `10` | 채널당 최대 세그먼트 수 |
| `nolive` | Boolean | N | false | 라이브 대체 사용 안 함 (아래 주의 참조) |

| 응답 필드 | 타입 | 설명 |
|----------|------|------|
| `chid` | Int | 채널 ID |
| `title` | String | 채널 이름 |
| `src` | Array | 스트림 URL 목록 |
| `src[].protocol` | String | 프로토콜 이름 |
| `src[].profile` | String | 스트림 프로파일 (`"main"`, `"sub"`) |
| `src[].src` | String | 스트림 URL |
| `src[].type` | String | MIME 타입 |
| `src[].label` | String | 해상도 라벨 (예: `"1080p"`) |
| `src[].size` | number[] | 해상도 `[width, height]` |

**녹화 재생 응답** (`when` 에 시각을 지정한 경우)은 형식이 다릅니다. `protocol`·`profile` 은 실시간
전용이며, 대신 세그먼트를 가리키는 `fileId` 와 해당 구간의 `timeRange` 가 포함됩니다.

```json
[
  {
    "chid": 1,
    "title": "Front Door",
    "fileId": 1304,
    "src": [
      {
        "src": "https://host/storage/f/00/13/1304.mp4",
        "type": "video/mp4",
        "label": "1080p",
        "size": [1920, 1080],
        "timeRange": ["2024-01-08T09:28:11+09:00", "2024-01-08T09:33:04+09:00"]
      }
    ]
  }
]
```

| 응답 필드 (녹화) | 타입 | 설명 |
|----------------|------|------|
| `fileId` | Int | 세그먼트 ID. `?id=<fileId>&next`/`&prev` 로 앞뒤 세그먼트를 탐색합니다 |
| `src[].timeRange` | String[] | 해당 세그먼트의 `[시작, 끝]` ([1.1](#11-시각-표기)) |

> **라이브 대체.** 조회 결과가 없고 **요청 시각이 현재 이후**이면 해당 채널의 실시간 스트림으로
> 대체하여 응답합니다(응답은 위의 실시간 형식입니다). 따라서 미래 시각을 지정해도 빈 응답이
> 반환되지 않습니다. 녹화만 받으려면 `nolive=true` 를 지정하십시오.

> **삭제된 파일은 제외됩니다.** 보존 기간이 지나 삭제된 세그먼트는 기록이 남아 있어도 응답에
> 포함되지 않습니다. 따라서 `otherwise` 로 검색한 결과가 **빈 배열**일 수 있습니다. 특히
> `nearAfter` 에서 발생하기 쉽습니다. 요청 시각이 남아 있는 모든 녹화보다 앞서면 가장 오래된 녹화를
> 선택하는데, 보존 정책은 가장 오래된 녹화부터 삭제하기 때문입니다. 빈 배열은 오류가 아닙니다.

**사용 가능한 프로토콜**:
| 프로토콜 | 설명 | 조건 |
|----------|-------------|-----------|
| `rtmp` | RTMP 스트림 | 항상 |
| `flv` | HTTP-FLV 스트림 (`http`/`https`) | HTTP-FLV 활성화 시 |
| `websocket-flv` | WebSocket-FLV 스트림 (`ws`/`wss`) | HTTP-FLV 활성화 시 |
| `rtsp` | RTSP 재송출 (`rtsp`), TCP 전용 | RTSP 재송출 활성화 시 |

> **`flv` 와 `websocket-flv` 의 차이**: 같은 스트림, 같은 엔드포인트이며 전송 프레이밍만 다릅니다. `flv` 는 HTTP chunked 전송을 사용하고, `websocket-flv` 는 연결을 업그레이드하여 FLV 태그 하나를 WebSocket 바이너리 프레임 하나로 전송합니다. 스킴은 요청 스킴을 따릅니다(`http`→`ws`, `https`→`wss`). flv.js / mpegts.js 같은 플레이어는 두 방식을 모두 지원합니다.

> **여러 채널을 동시에 재생할 때는 `websocket-flv` 를 사용하십시오.** 실시간 스트림은 재생하는 동안 연결이 유지되므로 채널 수만큼 연결이 동시에 열립니다. 브라우저는 **출처(origin)당 HTTP/1.1 연결을 약 6개로 제한**하며, 이 엔드포인트는 HTTP/2 와 HTTP/3 을 지원하지 않으므로 `flv` 스트림은 각각 이 연결 하나를 사용합니다. 한도를 넘으면 나머지 채널은 대기하고, 같은 출처로 보내는 다른 요청(REST 호출, 썸네일)도 대기합니다. WebSocket 연결은 이 한도에 포함되지 않고 훨씬 많은 수가 허용되므로, `websocket-flv` 를 사용하면 비디오월에서도 동시 접속 수 제한이 사실상 없습니다. 채널이 하나뿐이면 어느 방식을 사용해도 됩니다.

> **실시간 스트림 인증**: `flv`·`websocket-flv` 스트림은 URL 에 인증 매개변수가 있어야 재생됩니다.
> 매개변수는 미디어 파일과 같습니다([3.4](#34-storage--미디어-파일-인증)) — `?token=`(JWT), `?apikey=`(API Key), `?auth=`·`?login=`(base64 `id:pw`).
> 쿠키와 `Authorization` 헤더로는 인증되지 않습니다. 응답의 URL 에 매개변수를 덧붙여 재생하십시오
> (예: `https://host/live?app=live&stream=ch1main&token=eyJhbGc...`).
> `rtmp` 와 `rtsp` 는 아래와 같이 URL 의 계정 정보로 인증합니다.

> **`rtmp`**: 계정 정보를 URL 에 포함합니다(`rtmp://user:pass@host/live/ch1main`). API Key 는 사용자 이름에 `apikey`, 비밀번호에 키를 지정합니다(`rtmp://apikey:tsapi_key_...@host/live/ch1main`). 예약 문자는 퍼센트 인코딩하십시오(`@` 는 `%40`).
> 클라이언트와 서버는 Adobe RTMP 인증 방식(질의·응답)으로 확인하며, 비밀번호는 전송되지 않습니다. VLC·FFmpeg·OBS 등 이 방식을 지원하는 클라이언트를 사용하십시오. URL 쿼리의 인증 매개변수(`?token=` 등)로는 인증되지 않습니다.
> - 계정: v1.4.1 로 업그레이드하거나 설정을 가져온 뒤에는 한 번 로그인해야 RTMP 인증을 사용할 수 있습니다.
> - API Key: v1.4.1 이전에 발급한 키는 RTMP 에 사용할 수 없습니다. 키를 새로 발급하십시오.
> - 계정과 API Key 모두 `remote` 권한이 필요합니다. 실패한 시도는 로그인 시도 제한([3.3](#33-jwt-인증))에 포함됩니다.

> **`rtsp`**: 서버가 같은 RTMP 스트림을 RTP 로 재송출합니다. **TCP interleaved 전용**입니다. UDP `SETUP` 요청에는 `461 Unsupported Transport` 로 응답하므로, 기본값이 UDP 인 클라이언트는 TCP 를 지정해야 합니다(`vlc --rtsp-tcp`, `ffplay -rtsp_transport tcp`). Basic 인증은 필수이며 해제할 수 없습니다. 인증 정보를 URL 에 포함하고(`rtsp://user:pass@host/live/ch1main`) 예약 문자는 퍼센트 인코딩하십시오(`@` 는 `%40`). 영상은 **H.264 전용**입니다. 브라우저는 RTSP 를 재생할 수 없으므로, 웹 페이지가 아니라 외부 플레이어·VMS 연동·FFmpeg 기반 파이프라인에 사용합니다.

> **웹 페이지에 영상을 삽입하려면** 대개 위 URL 이 필요하지 않습니다. 서버가 [`GET /watch`](#133-watch-페이지-임베드-플레이어) 로 완성된 플레이어를 제공합니다. `<iframe>` 에 넣으면 프로토콜 선택·인증(`token` / `apikey`)·녹화 재생을 자동으로 처리합니다. Watch 페이지에서 제공하지 않는 제어가 필요한 경우에만 `flv` / `websocket-flv` 로 직접 구현하십시오.

> **참고**: `X-Host` 헤더가 필요합니다. 일반적인 웹 브라우저 접속 시 자동으로 설정됩니다. 직접 호출 시 `X-Host: {host}:{port}` 헤더를 포함하세요.

> **예제:** [JavaScript](examples/javascript/07-vod-stream.js) · [Python](examples/python/07_vod_stream.py) · [C#](examples/csharp/07_VodStream.cs) · [Go](examples/go/07_vod/) · [Java](examples/java/V1_07_VodStream.java) · [Kotlin](examples/kotlin/V1_07_VodStream.kt) · [Swift](examples/swift/07-vod-stream.swift) · [PowerShell](examples/powershell/07-vod-stream.ps1) · [curl](examples/curl/07-vod-stream.sh)

### 13.3. Watch 페이지 (임베드 플레이어)

비디오 플레이어가 포함된 HTML 페이지를 반환합니다. 외부 시스템에 실시간 또는 녹화 영상을 임베드(iframe, 알림 링크 등)할 때 유용합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /watch?ch=1` | 채널 1 실시간 영상 |
| `GET /watch?ch=1&when=2024-01-01T10:30:00` | 특정 시간 녹화 영상 |
| `GET /watch?ch=1&id=1304` | 세그먼트 ID로 녹화 영상 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `ch` | String | N | `"1"` | 채널 번호 (1부터 시작) |
| `when` | DateTime | N | - | 녹화 재생 시간 (ISO 8601, 생략 시 실시간) |
| `id` | String | N | - | 녹화 재생용 VOD 세그먼트 ID |
| `duration` | String | N | `"1h"` | 녹화 검색 구간 |
| `showTitle` | Boolean | N | false | 영상 제목 오버레이 표시 |
| `showPlaytime` | Boolean | N | false | 현재 재생 시간 오버레이 표시 |
| `noContextMenu` | Boolean | N | false | 우클릭 컨텍스트 메뉴 비활성화 |
| `token` | String | N | - | JWT 인증 토큰 |
| `apikey` | String | N | - | API Key 인증 |

> **참고**: 인증 없이 URL을 열 수 있습니다. 유효한 세션이 없으면 로그인 대화상자가 표시됩니다. `token` 또는 `apikey` 파라미터로 사전 인증할 수 있습니다.

> **장시간 표시**: 실시간 영상은 재접속할 때마다 인증을 다시 확인합니다. `token` 으로 전달한 JWT 는 페이지에서 갱신할 수 없으므로 만료 후 재접속하면 로그인 대화상자가 표시됩니다. 상황판처럼 장시간 표시하는 화면에는 `apikey` 사용을 권장합니다.

**응답**: `text/html` — 비디오 플레이어가 포함된 HTML 페이지

**예제** (iframe 임베드):
```html
<iframe src="http://nvr-host/watch?ch=1&showTitle=true&noContextMenu=true&apikey=tsapi_key_..."
        width="640" height="360" frameborder="0"></iframe>
```

---

## 14. 비상호출

비상 호출 관련 API입니다.

> **참고**: Emergency API는 해당 라이선스가 필요합니다. 라이선스가 활성화되지 않은 경우 404를 반환합니다.

### 14.1. 비상 호출 장치 목록

등록된 비상 호출 장치 목록을 조회합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/emergency` | 비상 호출 장치 목록 |

**응답**:
```json
[
  {
    "id": 1,
    "code": "EM-001",
    "name": "Fire Alarm",
    "linkedChannel": [1, 2, 3]
  }
]
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | Int | 장치 ID |
| `code` | String | 장치 코드 |
| `name` | String | 장치 이름 |
| `linkedChannel` | Array | 연동된 카메라 채널 ID 목록 |

> **예제:** [JavaScript](examples/javascript/11-emergency.js) · [Python](examples/python/11_emergency.py) · [C#](examples/csharp/11_Emergency.cs) · [Go](examples/go/11_emergency/) · [Java](examples/java/V1_11_Emergency.java) · [Kotlin](examples/kotlin/V1_11_Emergency.kt) · [Swift](examples/swift/11-emergency.swift) · [PowerShell](examples/powershell/11-emergency.ps1) · [curl](examples/curl/11-emergency.sh)

---

## 15. Push (LPR 카메라, 비상벨 연동)

외부에서 이벤트를 NVR로 전송합니다. LPR 카메라, 비상벨 등 외부 장치 연동에 사용됩니다.

> **참고**: Push API는 해당 라이선스가 필요합니다. 라이선스가 활성화되지 않은 경우 404를 반환합니다.

### 15.1. 푸시 이벤트 전송

| 엔드포인트 | 설명 |
|----------|-------------|
| `POST /api/v1/push` | 이벤트 데이터 전송 |

**지원 토픽**:
| 토픽 | 설명 |
|-------|-------------|
| `LPR` | 차량 번호 인식 데이터 |
| `emergencyCall` | 비상 호출 이벤트 (알람 시작/종료) |

#### LPR 푸시

외부 LPR 카메라에서 인식된 차량 번호를 전송합니다.

```http
POST /api/v1/push
Content-Type: application/json

{
  "topic": "LPR",
  "src": "1",
  "plateNo": "12가3456",
  "when": "2024-01-01T12:00:00"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `topic` | String | Y | `"LPR"` 고정 |
| `src` | String | Y | LPR 소스 ID |
| `plateNo` | String | Y | 인식된 차량 번호 |
| `when` | DateTime | Y | 인식 시간 (ISO 8601) |

#### 비상 호출 푸시

비상 호출 장치의 상태를 전송합니다.

```http
POST /api/v1/push
Content-Type: application/json

{
  "topic": "emergencyCall",
  "device": "dev1",
  "src": "1",
  "event": "callStart",
  "camera": "1,2",
  "when": "2024-01-01T10:00:00"
}
```

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `topic` | String | Y | `"emergencyCall"` 고정 |
| `device` | String | Y | 장치 식별자 |
| `src` | String | Y | 소스 ID |
| `event` | String | Y | `"callStart"` (알람 시작) 또는 `"callEnd"` (알람 종료) |
| `camera` | String | Y | 연동 카메라 채널 (쉼표 구분, 예: `"1,2"`) |
| `when` | DateTime | Y | 이벤트 발생 시간 (ISO 8601) |

> ⚠️ **주의**: `callStart`를 전송하면 실제 비상벨이 울립니다. 반드시 `callEnd`를 전송하여 알람을 종료하세요.

> **예제:** [JavaScript](examples/javascript/09-push-notification.js) · [Python](examples/python/09_push.py) · [C#](examples/csharp/09_Push.cs) · [Go](examples/go/09_push/) · [Java](examples/java/V1_09_Push.java) · [Kotlin](examples/kotlin/V1_09_Push.kt) · [Swift](examples/swift/09-push.swift) · [PowerShell](examples/powershell/09-push.ps1) · [curl](examples/curl/09-push.sh)

---

## 16. 주차

주차 관리 API입니다. 주차장(Parking Lot)과 주차면(Parking Spot) 두 가지 개념을 지원합니다.

### 16.1. 주차장 목록

주차장 목록을 조회합니다. 주차장은 카운터 기반으로 입출차를 관리합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/parking/lot` | 주차장 목록 조회 |

**응답**:
```json
[
  {
    "id": 1,
    "name": "Main Lot",
    "type": "counter",
    "maxCount": 100,
    "parkingSpots": [101, 102, 103]
  },
  {
    "id": 2,
    "name": "All",
    "type": "group",
    "maxCount": 300,
    "member": [1, 3]
  }
]
```

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `id` | number | 주차장 ID |
| `name` | string | 주차장 이름 |
| `type` | string | `"counter"` (입출차 카운팅) 또는 `"group"` (그룹 집계) |
| `maxCount` | number | 최대 주차 용량 |
| `member` | number[] | (group 전용) 멤버 주차장 ID |
| `parkingSpots` | number[] | (선택) 연결된 주차면 ID 목록 (주차면 기반 집계 모드에서 사용하는 영역 ID) |

### 16.2. 주차장 상태

주차장별 주차 현황을 반환합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/parking/lot/status` | 전체 주차장 상태 |
| `GET /api/v1/parking/lot/status?id=1,2` | 특정 주차장 상태 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `id` | String | N | 주차장 ID (쉼표 구분, 생략 시 전체) |

**응답**:
```json
[
  {
    "id": 1,
    "name": "Main Lot",
    "maxCount": 100,
    "count": 45,
    "available": 55
  }
]
```

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | Int | 주차장 ID |
| `name` | String | 주차장 이름 |
| `maxCount` | Int | 최대 주차 가능 수 |
| `count` | Int | 현재 주차 수 |
| `available` | Int | 잔여 주차 가능 수 |

### 16.3. 주차면 목록

시스템에 구성된 모든 번호인식 영역을 조회합니다. 주차면, 입구, 출구, 주차금지, 인식 전용 등 모든 유형을 반환합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/parking/spot` | 전체 번호인식 영역 (모든 유형) |
| `GET /api/v1/parking/spot?ch=1` | 특정 채널의 영역 |
| `GET /api/v1/parking/spot?id=1,2,3` | 특정 영역 조회 |
| `GET /api/v1/parking/spot?category=disabled` | 카테고리 필터링 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `ch` | String | N | 채널 번호 (쉼표 구분) |
| `id` | String | N | 영역 ID (쉼표 구분) |

**응답**:
```json
[
  {
    "id": 1,
    "chid": 1,
    "name": "A-001",
    "type": "spot",
    "category": "normal",
    "occupied": true,
    "vehicle": {
      "plateNo": "12가3456",
      "score": 95
    }
  },
  {
    "id": 2,
    "chid": 1,
    "name": "Main Gate",
    "type": "entrance",
    "category": null
  }
]
```

> 주차면(`type:"spot"`)의 경우 현재 점유 상태와 차량 번호도 함께 반환됩니다. 더 상세한 점유 정보(주차 시작 시간, 차량 이미지 등)는 [주차면 상태](#164-주차면-상태) API를 사용하세요.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `id` | number | 영역 ID |
| `chid` | number | 채널 ID |
| `name` | string | 영역 이름 |
| `type` | string | 영역 유형 (아래 표 참조) |
| `category` | string\|null | 주차면 카테고리 (`type:"spot"`만 해당, 아래 표 참조). 비주차면 유형은 `null`. |
| `occupied` | boolean | (spot 전용) 점유 여부 |
| `vehicle` | object\|null | (spot 전용) 점유 차량 정보. 비점유 시 생략. |
| `vehicle.plateNo` | string | 차량 번호 |
| `vehicle.score` | number | 인식 점수 |

**`type` 영역 유형:**

| 값 | 설명 |
|----|------|
| `spot` | 주차면 — 차량 점유 상태를 추적하는 영역 |
| `entrance` | 입구 — 진입 차량을 인식하는 영역 |
| `exit` | 출구 — 출차 차량을 인식하는 영역 |
| `noParking` | 주차금지 — 주차 불가 영역 (위반 감지용) |
| `recognition` | 인식 전용 — 번호 인식만 수행하고 주차 상태를 추적하지 않는 영역 |

**`category` 주차면 카테고리** (`type:"spot"`인 경우):

| 값 | 설명 |
|----|------|
| `normal` | 일반 주차면 |
| `disabled` | 장애인 전용 |
| `compact` | 경차 전용 |
| `eco_friendly` | 친환경차 전용 |
| `ev_charging` | 전기차 충전 |
| `women_family` | 여성·가족 전용 |

### 16.4. 주차면 상태

실시간 주차면 점유 상태를 조회합니다. 주차면(`type:"spot"`)만 반환합니다.

| 엔드포인트 | 설명 |
|----------|-------------|
| `GET /api/v1/parking/spot/status` | 전체 주차면 상태 |
| `GET /api/v1/parking/spot/status?ch=1` | 특정 채널 주차면 상태 (1-based) |
| `GET /api/v1/parking/spot/status?image=true` | 썸네일 이미지 포함 |
| `GET /api/v1/parking/spot/status?occupied=true` | 점유된 주차면만 |
| `GET /api/v1/parking/spot/status?occupied=false` | 비어있는 주차면만 |

**파라미터:**

| 파라미터 | 타입 | 필수 | 설명 |
|----------|------|------|------|
| `ch` | String | N | 채널 번호 (쉼표 구분) |
| `id` | String | N | 주차면 ID (쉼표 구분) |
| `image` | Boolean | N | 이미지 포함 여부 |

**응답**:
```json
[
  {
    "id": 1,
    "chid": 1,
    "name": "A-001",
    "category": "normal",
    "occupied": true,
    "vehicle": {
      "plateNo": "12가3456",
      "score": 95,
      "ev": false,
      "bike": false,
      "since": "2024-01-01T10:00:00"
    }
  }
]
```

**응답 필드:**

| 필드 | 타입 | 설명 |
|------|------|------|
| `id` | Int | 주차면 ID |
| `chid` | Int | 채널 번호 |
| `name` | String | 주차면 이름 |
| `category` | String | 카테고리 (`normal`, `disabled`, `ev_charging` 등) |
| `occupied` | Boolean | 점유 여부 |
| `vehicle` | Object\|null | 차량 정보 |
| `vehicle.plateNo` | String | 차량 번호 |
| `vehicle.score` | Float | 인식 신뢰도 |
| `vehicle.ev` | Boolean | 전기차 여부 |
| `vehicle.bike` | Boolean | 이륜차 여부 |
| `vehicle.since` | DateTime\|null | 주차 시작 시간 |
| `vehicle.image` | String | (`image=true` 시) 차량 이미지 경로 |
| `vehicle.plate` | Object | (`image=true` 시) 번호판 좌표 (`left`, `top`, `right`, `bottom`). **절대 픽셀**이며 `vehicle.image` 크롭 기준입니다. [1.2](#12-박스-좌표-표기) 의 예외입니다 |
| `vehicle.imageSize` | Object | (`image=true` 시) 이미지 크기 (`width`, `height`) |

### 16.5. 주차 내역 조회

**주차 세션**은 차량 한 대가 한 자리에 머문 기록 한 건입니다. 차량이 있다고 확정되면 시작되고
차량이 사라지면 종료됩니다. 차량의 현재 주차 시간을 조회하거나 정산 근거를 만들 때 사용합니다.

세션이 생성되는 영역은 세 가지입니다(`kind`): 주차면, 출입구, 주차 금지(체류) 구역.

> 주차 내역 조회 라이선스가 필요합니다. 라이선스가 없으면 16.5~16.9 는 모두 `403` 을 반환합니다.
> 사전에 확인하려면 `GET /api/v1/info?license` 를 조회하십시오. `license.extension` 에
> `parkingHistory` 가 있으면 라이선스가 활성 상태입니다([서버 정보](#4-서버-정보) 참조).
> 조회에는 **재생(Playback)** 권한, 이력을 변경하는 16.7·16.8·16.9 에는 **제어(Control)** 권한이 필요합니다.

| 엔드포인트 | 설명 |
|-----------|------|
| `GET /api/v1/parking/session` | 세션 목록 |
| `GET /api/v1/parking/session?open=true` | 현재 주차 중인 차량 |
| `GET /api/v1/parking/session?plateNo=12가3456&open=true` | 해당 번호의 주차 여부와 주차 시간 |
| `GET /api/v1/parking/session?timeField=out&timeBegin=...&timeEnd=...` | 해당 기간에 출차한 차량 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `timeBegin` | DateTime | N | 기간 시작 |
| `timeEnd` | DateTime | N | 기간 끝 |
| `timeField` | String | N | 기간 적용 기준 — `in`(입차), `out`(출차), `overlap`(기간과 겹치는 세션) |
| `plateNo` | String | N | 번호 정확히 일치 |
| `keyword` | String | N | 번호 부분 일치 |
| `scope` | String | N | 조회 대상 — `all`(기본), `spot`, `gate`, `noparking`, `channel`, `lot`. 아래 설명 참고 |
| `lot` | String | N | 주차장 ID 목록, 콤마 구분 (세션에 기록된 소속 주차장으로 검색) |
| `src` | String | N | 영역 ID 목록, 콤마 구분 (주차면·출입구·체류 구역) |
| `ch` | String | N | 채널 번호 목록, 콤마 구분 (1부터) |
| `kind` | String | N | `spot`, `gate`, `dwell` — 콤마 구분, 생략하면 전부 |
| `outKind` | String | N | 출차 근거, 콤마 구분 (아래 표 참고) |
| `inKind` | String | N | 입차 근거, 콤마 구분 (아래 표 참고). 주차 중인 세션에도 적용됩니다 |
| `open` | Boolean | N | `true` = 주차 중, `false` = 출차 완료 |
| `paid` | Boolean | N | `true` = **유효한** 정산 기록이 있는 건 (되돌린 정산은 제외) |
| `exempt` | Boolean | N | `true` = 정산 대상에서 제외된 건만 조회. 제외를 **되돌리려면 먼저 대상을 조회해야** 하므로 이 조건을 제공합니다 ([16.7](#167-정산-상태-변경)) |
| `hasPlate` | Boolean | N | `true` = 번호를 인식한 건 |
| `durationMin` | Int | N | 최소 주차 시간(초) |
| `durationMax` | Int | N | 최대 주차 시간(초) |
| `unpaidDurationMin` | Int | N | 최소 미정산 시간(초) — 마지막 정산 이후 경과 |
| `at` | Int | N | 페이지 오프셋 (기본 `0`) |
| `maxCount` | Int | N | 페이지 크기 (서버 상한이 적용됩니다) |
| `sort` | String | N | `desc`(기본) 또는 `asc` |
| `sortBy` | String | N | `time`(입차 시각, 기본) 또는 `duration` |
| `includePayments` | Boolean | N | 각 세션에 `payments` 배열을 포함합니다 |

**`scope` — 조회 대상**

`scope` 는 세부 항목을 **어떤 대상의 목록에서** 선택할지 결정합니다. 대상마다 항목 파라미터가 다릅니다.

| `scope` | 항목 파라미터 | 항목을 생략하면 |
|---------|--------------|----------------|
| `all` (기본) | — | 조건 없음. 각 파라미터가 독립적으로 적용됩니다(기존 동작) |
| `spot` | `src` | 주차면 이력 전부 |
| `gate` | `src` | 출입구 이력 전부 |
| `noparking` | `src` | 주차 금지 영역 이력 전부 |
| `channel` | `ch` | 모든 채널 (= 조건 없음) |
| `lot` | `lot` | **주차장에 속한 세션만** |

항목을 생략하면 '해당 대상 전체'를 의미하며, 이는 **조건 없음과 다릅니다**. `scope=lot` 에 `lot` 을
지정하지 않으면 주차장에 소속된 세션만 반환합니다. 주차 금지 영역 이력은 주차장에 속하지 않으므로
제외됩니다. 같은 이유로 `scope=spot` 은 주차면 이력만 반환합니다.

`scope` 가 `spot`·`gate`·`noparking` 이면 세션 종류가 함께 결정되므로 `kind` 보다 우선합니다.
`scope` 를 지정하지 않으면 기존과 동일하게 동작합니다.

**응답**:
```json
{
  "totalCount": 128,
  "at": 0,
  "asOf": "2026-10-07T09:30:00",
  "summary": {
    "count": 128,
    "totalDurationMs": 442800000,
    "firstTimeIn": "2026-10-07T07:05:11",
    "lastTimeOut": "2026-10-07T09:22:40"
  },
  "data": [
    {
      "id": 4821,
      "kind": "spot",
      "src": {
        "id": 101,
        "name": "A-13"
      },
      "lots": [1],
      "usageFlags": 1,
      "chid": 3,
      "plateNo": "12가3456",
      "plateTime": "2026-10-07T08:01:12",
      "score": 95.0,
      "timeRange": ["2026-10-07T08:01:04", "2026-10-07T09:22:40"],
      "open": false,
      "outKind": "observed",
      "outTimeMeans": "exitedAt",
      "inKind": "observed",
      "inTimeMeans": "enteredAt",
      "durationMs": 4896000,
      "box": { "cx": 0.394, "cy": 0.556, "w": 0.164, "h": 0.201 },
      "paidCount": 1,
      "lastPaidTime": "2026-10-07T09:20:03",
      "unpaidDurationMs": 157000,
      "snapshots": [
        {
          "time": "2026-10-07T08:01:04",
          "chid": 3,
          "tags": ["in", "bestshot", "plate"],
          "plateNo": "12가3456",
          "image": "https://nvr.example.com/storage/f/parking/20261007/4821-in.jpg",
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T08%3A01%3A04&otherwise=nearBefore"
        },
        {
          "time": "2026-10-07T08:04:22",
          "chid": 3,
          "tags": ["bestshot"],
          "plateNo": null,
          "image": "https://nvr.example.com/storage/f/lpr/20261007/99213.jpg",
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T08%3A04%3A22&otherwise=nearBefore"
        },
        {
          "time": "2026-10-07T09:22:40",
          "chid": 3,
          "tags": ["out"],
          "plateNo": null,
          "image": null,
          "video": "https://nvr.example.com/api/v1/vod?ch=3&when=2026-10-07T09%3A22%3A40&otherwise=nearBefore"
        }
      ]
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `totalCount` | Int | 전체 건수 (시간 조건이 없어 건수 집계를 생략한 경우 `-1`) |
| `at` | Int | 이 페이지의 오프셋 |
| `asOf` | DateTime | 응답을 생성한 서버 시각. **주차 중인 세션의 주차 시간은 이 시각까지로 계산합니다** |
| `summary.count` | Int | 결과 전체의 세션 수 |
| `summary.totalDurationMs` | Int | 주차 시간 합계(밀리초) |
| `summary.firstTimeIn` | DateTime\|null | 결과 중 가장 이른 입차 |
| `summary.lastTimeOut` | DateTime\|null | 결과 중 가장 늦은 출차 |
| `data[].id` | Int | 세션 ID |
| `data[].kind` | String | `spot`, `gate`, `dwell` |
| `data[].src` | Object | 세션이 발생한 영역 — 주차면·출입구·구역의 `id` 와 `name` |
| `data[].srcOut` | Int | (출입구) 출차 지점의 영역 ID |
| `data[].lots` | Int[] | **세션 당시** 그 영역이 속했던 주차장입니다. 현재 설정이 아닙니다 |
| `data[].usageFlags` | Int | 세션에 기록된 영역 용도 플래그 |
| `data[].chid` | Int | 채널 번호 (1부터) |
| `data[].plateNo` | String\|null | 번호. 끝내 인식하지 못했으면 `null`. 항상 **현재** 값입니다. 번호를 수정한 경우([16.9](#169-차량-번호-수정)) 수정된 번호입니다 |
| `data[].plateEdited` | Boolean | 사람이 번호를 수정했으면 `true` |
| `data[].originalPlateNo` | String | (`plateEdited` 일 때만) 처음 인식한 번호 (읽지 못했으면 `""`) |
| `data[].plateTime` | DateTime\|null | 번호를 읽은 시각 |
| `data[].score` | Float | 인식 신뢰도 (`plateNo` 와 함께 포함) |
| `data[].timeRange` | DateTime[] | 주차 중이면 `[입차]`, 종료되었으면 `[입차, 출차]` |
| `data[].open` | Boolean | `true` = 주차 중 |
| `data[].outKind` | String | 출차 시각의 결정 근거 (종료된 세션만) |
| `data[].outTimeMeans` | String | 그 시각의 **의미** (종료된 세션만) |
| `data[].inKind` | String | 입차 시각의 결정 근거 (**주차 중인 세션에도** 포함) |
| `data[].inTimeMeans` | String | 그 시각의 **의미** |
| `data[].durationMs` | Int | 주차 시간(밀리초). 주차 중이면 `asOf` 까지 |
| `data[].paidCount` | Int | **유효한** 정산 건수 (되돌린 정산은 제외) |
| `data[].lastPaidTime` | DateTime\|null | 마지막 정산 시각 |
| `data[].unpaidDurationMs` | Int | 정산되지 않은 시간. **`exempt` 가 `true` 이면 청구 근거로 사용하지 마십시오** |
| `data[].exempt` | Boolean | 정산 대상에서 제외됨 ([16.7](#167-정산-상태-변경)) |
| `data[].box` | Object\|null | 해당 차량의 박스 ([1.2](#12-박스-좌표-표기)). 스냅샷에서 **어느 차량인지** 식별하는 용도입니다 |
| `data[].snapshots` | Object[] | 세션의 주요 시점을 **시각 오름차순**으로 담은 배열(아래) |
| `data[].payments` | Object[] | (`includePayments=true`) `{ id, time, kind, target?, ref? }`. `kind` 는 `commit`·`exempt`·`undo`, `target` 은 `undo` 가 되돌린 행의 `id` 입니다 |

**스냅샷** — 항목은 `{ time, chid, tags, plateNo, image, video }` 이며 **시각 오름차순**으로 정렬됩니다.
한 장이 여러 의미를 가질 수 있으므로(입차 프레임이 번호를 인식한 샷이기도 한 경우) 의미는 키가 아니라
**태그 배열**로 표시합니다. 같은 의미의 스냅샷이 여러 장일 수도 있습니다. AI 카메라는 차량 한 대에 대해
베스트샷을 여러 번 전송합니다.

| 필드 | 내용 |
|------|------|
| `time` | 해당 시점의 시각. `current` 는 현재 시점을 나타내므로 `null` 입니다 |
| `chid` | 채널 번호 (1부터) |
| `tags` | 아래 표의 태그 목록 |
| `plateNo` | 그 샷에서 인식한 번호. **인식하지 못했으면 `null`** 입니다 |
| `image` | 사진 URL. 보존 기간이 지나 삭제되었거나 원래 사진이 없는 시점이면 `null` |
| `video` | 그 시각의 VOD 링크 ([13.2](#132-재생-url), `otherwise=nearBefore` 포함) |

| 태그 | 의미 |
|------|-----|
| `in` | 입차 |
| `out` | 출차 |
| `current` | 주차 중인 세션의 현재 시점 (사진 없음, 라이브 링크) |
| `bestshot` | 번호 인식을 **시도한** 샷 |
| `plate` | 그 샷에서 번호를 **인식함** |

> **`bestshot` 과 `plate` 는 다릅니다.** 인식에 실패한 샷도 `bestshot` 으로 남으며, 이 경우
> `plate` 태그가 없고 `plateNo` 가 `null` 입니다. 사진은 보존되므로 나중에 사람이 확인할 수
> 있습니다. 번호가 있는 항목만 사용하려면 `tags` 에 `plate` 가 있는지 확인하십시오.

> **스냅샷은 세션당 최대 20장**입니다. 초과하면 **번호를 인식한 샷을 우선하고, 그다음 큰 이미지
> 순**으로 보존합니다. 사진이 없는 시점(`in`·`out`·`current`)은 영상 링크이므로 상한과 무관하게
> 항상 포함됩니다.

**출차 근거** — 측정값은 `observed` 하나뿐입니다. 나머지는 추정값이며 오차 방향이 서로 다르므로,
정산 앱은 시각만 사용하지 말고 근거에 따라 다르게 처리해야 합니다.

| `outKind` | `outTimeMeans` | 시각의 의미 |
|-----------|----------------|-------------------|
| `observed` | `exitedAt` | 출차를 관측했습니다. 유일한 측정값입니다 |
| `paid` | `paidAt` | 마지막 정산 시각입니다. 일반적으로 정산 직후 출차하므로 영상 근거보다 실제에 가깝고 영수증과도 일치합니다 |
| `covered` | `discoveredAt` | 가려져 있다가 **사라진 것을 발견한** 시점입니다. 실제 출차는 그 이전입니다 |
| `lastSeen` | `lastSeenAt` | **관측이 중단되었습니다**(카메라 접속 종료·프로그램 종료). 해당 채널을 마지막으로 판정한 시각이므로 **하한**입니다. 원인은 기록하지 않으므로 이름도 관측 사실만 나타냅니다 |
| `manual` | `closedByOperator` | 운영자가 종료했습니다(야간 개방·장시간 가림). 출차 시각이 아니라 운영 조치 시각입니다 |
| `unknown` | `unknown` | 이 규칙 도입 이전 데이터입니다. 소급 추정값만 있습니다 |

**입차 근거** — 출차와 대칭이며 **오차 방향이 반대**입니다. `lastSeenAt` 은 실제 출차 시각의
하한이고, `firstSeenAt` 은 실제 입차 시각의 **상한**입니다(그 이전부터 주차되어 있었습니다).
두 경우 모두 주차 시간이 실제보다 짧게 계산됩니다.

출차 근거와 달리 **주차 중인 세션에도 포함됩니다**. 입차는 이미 지난 일이므로, 주차 중인 세션도
관측 시작으로 열렸을 수 있습니다.

| `inKind` | `inTimeMeans` | 시각의 의미 |
|----------|---------------|-------------------|
| `observed` | `enteredAt` | 빈 자리가 점유로 바뀌는 것을 관측했습니다. 유일한 측정값입니다 |
| `firstSeen` | `firstSeenAt` | 관측을 시작했을 때 **이미 차량이 있었습니다**. 언제부터 있었는지는 알 수 없습니다 |
| `unknown` | `unknown` | 이 규칙 도입 이전 데이터입니다. 입차가 관측된 것인지 알 수 없습니다 |

> **같은 차량이 여러 건으로 나뉠 수 있습니다.** 관측이 오래 중단되면 해당 세션을 `lastSeen` 으로
> 종료하고, 관측이 재개되면 `firstSeen` 으로 새 세션을 시작합니다. 관측하지 않은 구간을 주차 시간에
> 포함하지 않기 위해서입니다. 같은 주차면에서 `lastSeen` 으로 종료된 세션과 `firstSeen` 으로 시작된
> 세션의 시각이 연속되면 같은 주차일 가능성이 높습니다. 합산 여부는 정산 정책에 속하므로 API 가
> 판단하지 않습니다.
>
> 짧은 중단은 세션을 나누지 않습니다. 그 시간 안에서는 출차·입차가 확정될 수 없으므로, 관측이
> 계속되었더라도 한 건이었을 구간입니다. 기준은 다음 둘 중 **더 긴 시간**입니다.
>
> - **진출입 확정 시간의 두 배**
> - **차량 번호 인식 주기의 두 배** — 정상적인 인식 주기를 중단으로 판단하지 않기 위한 하한입니다.
>   인식 주기를 길게 설정한 장비에서는 이 값이 기준이 되므로, 같은 공백이라도 세션이 나뉘지 않습니다.

| 질의 | 설명 |
|------|------|
| `GET /api/v1/parking/session?inKind=firstSeen` | 입차를 관측하지 못한 건만 |
| `GET /api/v1/parking/session?outKind=lastSeen` | 출차를 관측하지 못하고 관측이 중단된 건만 |

### 16.6. 주차 내역 상세

세션 한 건을 정산 이력과 함께 반환합니다. 분쟁 발생 시 근거를 한 번에 제시하는 용도입니다.

| 엔드포인트 | 설명 |
|-----------|------|
| `GET /api/v1/parking/session/{id}` | 세션 상세 |

**응답**: 16.5 의 `data[]` 와 같은 형식의 객체 하나입니다. `payments` 가 **항상** 포함됩니다.

```json
{
  "id": 4821,
  "kind": "spot",
  "src": {
    "id": 101,
    "name": "A-13"
  },
  "chid": 3,
  "plateNo": "12가3456",
  "timeRange": ["2026-10-07T08:01:04", "2026-10-07T09:22:40"],
  "open": false,
  "outKind": "paid",
  "outTimeMeans": "paidAt",
  "durationMs": 4739000,
  "paidCount": 1,
  "lastPaidTime": "2026-10-07T09:20:03",
  "unpaidDurationMs": 0,
  "snapshots": [
    {
      "time": "2026-10-07T08:01:04",
      "chid": 3,
      "tags": ["in"],
      "plateNo": null,
      "image": null,
      "video": "..."
    }
  ],
  "payments": [
    {
      "id": 77,
      "time": "2026-10-07T09:20:03",
      "ref": "POS-20261007-0042"
    }
  ]
}
```

| 상태 | 의미 |
|------|-----|
| `404` | 해당 ID 의 세션이 없습니다 |

### 16.7. 정산 상태 변경

세션의 정산 상태를 변경합니다. NVR 은 **시각**과 호출자의 참조만 저장합니다.
금액·요금표·할인 규칙은 정산 앱에서 관리합니다.

| 엔드포인트 | 하는 일 | `409` |
|-----------|--------|-------|
| `POST /api/v1/parking/session/{id}/payment/commit` | 정산 완료 (한 세션에 여러 번 가능) | — |
| `POST /api/v1/parking/session/{id}/payment/exempt` | 정산 대상에서 제외 | 이미 제외됨 |
| `POST /api/v1/parking/session/{id}/payment/undo` | 가장 최근 유효 변경을 되돌림 | 되돌릴 변경 없음 |

**동작별 변경 값** (16.5 응답 필드)

| 동작 | `paidCount` | `lastPaidTime` | `unpaidDurationMs` | `exempt` |
|------|------------|----------------|--------------------|----------|
| `commit` | +1 | 이번 시각 | 이번 시각부터 다시 계산 | 그대로 |
| `exempt` | 그대로 | 그대로 | 그대로 | `true` |
| `undo` | −1 (완료를 되돌린 경우) | 이전 유효 정산 시각 | 그에 맞춰 되돌아감 | 제외를 되돌리면 `false` |

**규칙**

| 항목 | 규칙 |
|---|---|
| 기록 | 변경 이력이 누적됩니다. `undo` 도 마찬가지입니다 |
| `undo` 대상 | 생략하면 가장 최근 유효 변경(완료·제외 모두). `ref` 를 지정하면 해당 참조의 **완료** 건 |
| `undo` 응답 | `undone` 에 되돌린 변경의 종류가 표시됩니다 (`commit` 또는 `exempt`) |
| 반복 `undo` | 이력을 거슬러 올라가며 이전 변경을 차례로 되돌립니다 |
| `exempt` 의 의미 | **정산하지 않기로 한 결정**을 기록합니다. 시간 값은 바뀌지 않으므로, `exempt` 가 `true` 이면 `unpaidDurationMs` 를 청구 근거로 사용하지 않습니다 |
| 제외와 조회 | 제외된 세션은 `unpaidDurationMin` 조회 결과에서 제외됩니다. 이 조건은 정산되지 않은 시간이 남은 세션만 반환하는 필터이며, 제외된 세션은 정산 대상이 아니기 때문입니다 |
| 되돌린 정산 | `outKind:"paid"` 의 출차 시각 근거가 되지 않습니다 |
| 기록 시각 | **항상 서버 시계**입니다. `time` 으로 전달한 값은 `clientTime` 으로 별도 보존됩니다 ([1.1](#11-시각-표기)) |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `time` | DateTime | N | **호출자 시계의** 시각. 별도로 보존되며 NVR 의 기록 시각은 항상 서버 시계입니다 ([1.1](#11-시각-표기)) |
| `ref` | String | N | 정산 앱의 거래 식별자. `undo` 에서는 되돌릴 완료 건을 지정합니다 |

**응답**:
```json
{
  "session": 4821,
  "time": "2026-10-07T09:20:03",
  "action": "commit",
  "ref": "POS-20261007-0042"
}
```
```json
{
  "session": 4821,
  "time": "2026-10-07T18:40:11",
  "action": "undo",
  "undone": "exempt"
}
```

| 상태 | 의미 |
|------|-----|
| `400` | 세션 ID 또는 시각이 올바르지 않습니다 |
| `403` | **제어(Control)** 권한이 필요합니다 |
| `404` | 해당 ID 의 세션이 없습니다 |
| `409` | `exempt` 요청인데 이미 제외되었거나, `undo` 요청인데 되돌릴 변경이 없습니다 |

> 주차 중인 세션에 기록된 정산은 출차 시각의 근거로 사용될 수 있습니다. **프로그램을 다시
> 시작할 때** 열려 있던 주차면·체류 세션을 종료하면서, 마지막 정산 시각이 영상 근거보다
> 늦으면 그 시각을 출차 시각으로 사용하고 근거를 `paid` 로 기록합니다([16.5](#165-주차-내역-조회) 의
> 출차 근거 표). 출입구 세션에는 적용되지 않습니다.
>
> **되돌린 정산과 제외는 근거로 사용하지 않습니다**(사용하면 출차 시각이 잘못 계산됩니다).
> 운영 중 관측이 중단되어 종료된 세션은 `lastSeen` 으로 남으며, 이후 정산이 기록되어도 `paid` 로
> 바뀌지 않습니다.

### 16.8. 미출차 정리

출차를 관측하지 못해 '주차중' 으로 남은 세션을 운영자가 정리(종료)합니다.

| 항목 | 내용 |
|---|---|
| 용도 | 차량은 출차했지만 출차가 인식되지 않아 남은 세션을 정리합니다 |
| 발생 원인 | 야간 차단기 개방(출입구 미인식) · 대형 차량에 의한 장시간 가림(주차면) |
| 방치할 경우 | '주차중' 세션이 누적되어 현황과 이력의 신뢰도가 떨어집니다 |
| 기록되는 값 | `outKind: "manual"` · `outTimeMeans: "closedByOperator"` |
| 정산 앱 처리 | 출차가 관측된 세션과 **구분하여** 처리하십시오 |
| [16.7](#167-정산-상태-변경) `exempt` 와 차이 | 이 API 는 **주차 상태**를 종료합니다. `exempt` 는 **정산 대상**에서 제외하는 것이며 세션은 열려 있을 수 있습니다 |

| 엔드포인트 | 설명 |
|-----------|------|
| `POST /api/v1/parking/session/{id}/close` | 현재 시각으로 종료 |
| `POST /api/v1/parking/session/{id}/close?time=...` | 지정한 시각으로 종료 |

**파라미터**:

| 파라미터 | 타입 | 필수 | 설명 |
|---------|------|------|------|
| `time` | DateTime | N | **호출자 시계의** 출차 시각. 별도로 보존되며 주차 시간 계산에는 서버 시계만 사용합니다 ([1.1](#11-시각-표기)) |

**응답**:
```json
{
  "session": 4821,
  "time": "2026-10-07T09:30:00",
  "outKind": "manual",
  "outTimeMeans": "closedByOperator"
}
```

| 상태 | 의미 |
|------|-----|
| `400` | 세션 ID 가 잘못되었거나, 지정한 시각이 입차 시각과 같거나 그보다 이릅니다 |
| `403` | **제어(Control)** 권한이 필요합니다 |
| `404` | 해당 ID 의 세션이 없습니다 |
| `409` | 이미 종료된 세션입니다. 기존 출차 기록을 덮어쓰지 않습니다 |

> 종료는 해당 세션이 **더 이상 존재하지 않음**을 의미합니다. NVR 은 해당 주차면·구역에서
> 추적하던 상태도 함께 초기화하므로, 같은 세션을 자동으로 다시 열지 않습니다. 차량이 실제로
> 있으면 진입 확정 시간을 처음부터 다시 거친 뒤 **새** 세션으로 시작됩니다.

### 16.9. 차량 번호 수정

세션의 **대표 번호**(세션의 `plateNo` 로 제공되는 번호 하나)를 수정합니다. 추적 세션은
베스트샷 여러 장에서 번호를 인식할 수 있지만 수정 대상은 대표 번호뿐이며, 장별 인식 결과
(`snapshots[].plateNo`)는 증거이므로 변경하지 않습니다.

| 엔드포인트 | 설명 |
|-----------|------|
| `POST /api/v1/parking/session/{id}/plate` | 세션 `{id}` 의 번호 수정 |
| `GET /api/v1/parking/session/{id}/plate/history` | 세션 `{id}` 의 수정 이력 |

파라미터·응답·이력·상태 코드는 [10.4](#104-차량-번호-수정) 와 같습니다. 수정 응답은 `"id"` 대신
`"session": {id}`, 이력은 `"target": "session"` 입니다. 주차 내역 조회 라이선스가 없으면 다른 세션 API 와
마찬가지로 두 API 모두 `403` 을 반환합니다.

**규칙**

| 항목 | 규칙 |
|---|---|
| 대상 | `id` 로 지정한 세션 **한 건**뿐입니다. 일괄 수정, 번호 값으로 대상을 찾는 수정, 세션 병합은 지원하지 않습니다 |
| 이력 | 수정할 때마다 한 건씩 누적되며 이전 기록은 변경되지 않습니다 |
| 진행 중 세션 | 수정한 번호가 유지됩니다. 이후 해당 차량의 인식 결과로 덮어쓰지 않습니다. **다른** 차량이 그 자리에 들어오면 그 차량의 번호로 새 세션이 시작됩니다 |
| 정산 기록 | 세션에 그대로 연결됩니다 (번호가 아니라 세션 ID 로 연결됩니다) |
| 출입구 세션 | 출차는 번호를 기준으로 열린 입차 세션과 연결됩니다. 열린 입차 세션의 번호를 수정하면, 출차 시 수정된 번호로 인식될 때만 연결됩니다. 오인식으로 이미 분리된 두 세션은 **병합하지 않습니다**. 입차 세션은 [16.8](#168-미출차-정리) 로 종료하십시오 |
| 프로그램 재시작 | 재시작 후에도 이어지는 세션은 수정한 번호를 유지합니다. 재시작 시 종료된 세션(16.7 의 안내 참조)의 수정 내용은 이후 새로 시작된 세션으로 이어지지 않습니다 |

> **예제:** [JavaScript](examples/javascript/10-parking.js) · [Python](examples/python/10_parking.py) · [C#](examples/csharp/10_Parking.cs) · [Go](examples/go/10_parking/) · [Java](examples/java/V1_10_Parking.java) · [Kotlin](examples/kotlin/V1_10_Parking.kt) · [Swift](examples/swift/10-parking.swift) · [PowerShell](examples/powershell/10-parking.ps1) · [curl](examples/curl/10-parking.sh)

---

## 17. 실시간 이벤트 구독 (WebSocket API)

실시간 이벤트를 구독하기 위한 WebSocket API입니다.

### 17.1. WebSocket 연결 흐름

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. WebSocket 연결 (초기 토픽 지정)
    Client->>Server: WS /wsapi/v1/events?topics=LPR&apikey=xxx
    Server-->>Client: Connection Established

    Note over Client,Server: 2. 실시간 이벤트 수신
    loop 이벤트 발생 시
        Server-->>Client: {"topic":"LPR","channel":1,"plates":[{"plateNo":"12가3456",...}]}
    end

    Note over Client,Server: 3. 토픽 추가 구독
    Client->>Server: {"subscribe":"channelStatus"}
    Server-->>Client: {"type":"subscribed","topic":"channelStatus"}
    loop 이벤트 발생 시
        Server-->>Client: {"topic":"channelStatus","chid":1,...}
    end

    Note over Client,Server: 4. 토픽 구독 해제
    Client->>Server: {"unsubscribe":"LPR"}
    Server-->>Client: {"type":"unsubscribed","topic":"LPR"}

    Note over Client,Server: 5. 연결 종료
    Client->>Server: Close
    Server-->>Client: Close ACK
```

**단계별 설명:**

| 단계 | 설명 |
|------|------|
| **1. WebSocket 연결** | WebSocket 엔드포인트에 연결합니다. URL 쿼리 파라미터 `topics`로 초기 구독 토픽을 지정하고, `apikey` 또는 `token`으로 인증합니다. |
| **2. 실시간 이벤트 수신** | 구독한 토픽의 이벤트가 발생하면 서버가 JSON 메시지를 자동으로 푸시합니다. |
| **3. 토픽 추가 구독** | 연결 중에 추가 토픽을 구독할 수 있습니다. `{"subscribe":"토픽명"}` 메시지를 전송하면 서버가 `{"type":"subscribed"}` 응답과 함께 해당 토픽의 초기 데이터를 전송합니다. 필터 파라미터(`ch`, `lot`, `spot` 등)를 함께 지정할 수 있습니다. |
| **4. 토픽 구독 해제** | `{"unsubscribe":"토픽명"}` 메시지를 전송하면 해당 토픽의 이벤트 수신이 중단됩니다. 서버는 `{"type":"unsubscribed"}` 응답을 반환합니다. |
| **5. 연결 종료** | 클라이언트가 WebSocket을 닫으면 모든 구독이 자동으로 해제됩니다. |

### 17.2. 엔드포인트

| 엔드포인트 | 설명 |
|----------|-------------|
| `/wsapi/v1/events` | 실시간 이벤트 구독 (LPR, 상태변경, 객체감지 등) |
| `/wsapi/v1/export` | 녹화 데이터 내보내기 (백업) |

### 17.3. 인증

WebSocket v1 API는 다음 인증 방식을 지원합니다:

| 방식 | 헤더 | 쿼리 파라미터 |
|------|------|---------------|
| JWT Bearer 토큰 | `Authorization: Bearer {token}` | `?token={accessToken}` |
| API Key | `X-API-Key: {apiKey}` | `?apikey={apiKey}` |

> **참고**: 브라우저 WebSocket API는 커스텀 헤더를 지원하지 않으므로, 쿼리 파라미터(`?token=`, `?apikey=`)를 대안으로 사용합니다. 브라우저 외 클라이언트(Node.js, Python, Go 등)는 헤더 또는 쿼리 파라미터 모두 사용 가능합니다.
>
> **중요**: `?session=`과 `?auth=`는 v1 WebSocket에서 **지원하지 않습니다** (v0 전용).

### 17.4. 이벤트 구독

```
ws://{host}:{port}/wsapi/v1/events?topics={topics}&token={accessToken}
ws://{host}:{port}/wsapi/v1/events?topics={topics}&apikey={apiKey}
```

**파라미터:**

| 파라미터 | 설명 |
|-----------|-------------|
| `topics` | 구독할 이벤트 토픽 (쉼표로 구분) |
| `ch` | 채널 필터 (선택) |
| `lot` | 주차장 ID 필터 (선택, v1 전용) |
| `spot` | 주차면 ID 필터 (선택, v1 전용) |
| `verbose` | 상세 정보 포함 (true/false) |
| `indent` | JSON 들여쓰기 (0-8) |
| `lang` | 이벤트 문구의 언어 ([1.3](#13-언어-lang)) |
| `objectTypes` | 객체 타입 필터 (human, face, vehicle) |

**토픽:**

| 토픽 | 설명 | 조건 |
|-------|-------------|-----------|
| `channelStatus` | 채널 연결 상태 변경 | 항상 |
| `emergencyCall` | 비상 호출 이벤트 | 비상 호출 라이선스 |
| `LPR` | 차량 번호 인식 이벤트 | 항상 |
| `systemEvent` | 시스템 이벤트 (시작, 종료, 오류 등) | 항상 |
| `notice` | 현재 유효한 알림 — 구독 직후 목록, 이후 raised / updated / cleared ([5.5](#55-시스템-알림)) | 항상 |
| `motionChanges` | 모션 감지 상태 변경 | 항상 |
| `recordingStatus` | 녹화 상태 변경 | 녹화 활성화 시 |
| `parkingCount` | 주차장 카운트 변동 | 주차 안내 라이선스 |
| `parkingSpot` | 개별 주차면 점유 변동 | 주차면 라이선스 |
| `object` | 객체 감지 (얼굴, 사람, 차량) | 객체 감지 라이선스 |
| `bodyTemperature` | 체온 측정 이벤트 | 체온 측정 라이선스 |
| `vehicleTracking` | 차량 추적 이벤트 | 차량 추적 라이선스 |

**런타임 토픽 구독/해제:**

연결 후에도 WebSocket 메시지로 토픽을 추가하거나 해제할 수 있습니다.

구독 추가:
```json
{
  "subscribe": "channelStatus",
  "ch": [1, 2]
}
```

구독 해제:
```json
{
  "unsubscribe": "channelStatus"
}
```

**응답:**

| 응답 | 설명 |
|------|------|
| `{"type":"subscribed","topic":"..."}` | 구독 성공. 토픽에 따라 초기 상태 데이터가 함께 전송될 수 있습니다. |
| `{"type":"unsubscribed","topic":"..."}` | 구독 해제 성공. |
| `{"type":"error","topic":"...","message":"..."}` | 알 수 없는 토픽이거나 잘못된 요청. |
| `{"type":"error","message":"unknown command"}` | `subscribe`·`unsubscribe` 가 아닌 메시지. |
| `{"type":"error","message":"invalid JSON"}` | JSON 으로 해석할 수 없는 메시지. |

> **참고**: 같은 토픽을 다시 구독하면 기존 구독이 자동으로 교체됩니다 (필터 변경 시 유용).

**토픽 없이 연결하기:**

v1 은 `topics` 없이 연결할 수 있습니다. 연결 후 `subscribe` 메시지로 토픽을 선택하면 되므로,
실행 중에 구독 목록이 바뀌는 클라이언트는 재연결 없이 토픽을 변경할 수 있습니다.

```
ws://{host}:{port}/wsapi/v1/events?apikey={apiKey}
```

**subscribe 메시지의 필터:**

| 필드 | 형식 | 설명 |
|------|------|------|
| `subscribe` | string | 구독할 토픽 이름 |
| `ch` | number[] | 채널 필터 (선택) |
| `objectTypes` | string[] | 객체 유형 필터 — `human`·`face`·`vehicle` (선택) |
| `lot` | number[] | 주차장 ID 필터 (선택) |
| `spot` | number[] | 주차면 ID 필터 (선택) |

```json
{"subscribe": "channelStatus"}
{"subscribe": "channelStatus", "ch": [1, 2, 3]}
{"subscribe": "object", "objectTypes": ["human", "vehicle"]}
{"subscribe": "parkingSpot", "lot": [1, 2], "spot": [100, 200]}
{"subscribe": "LPR", "ch": [1]}
```

**동적 구독 예제:**

```javascript
const ws = new WebSocket('ws://localhost/wsapi/v1/events?apikey=tsapi_key_...');

ws.onopen = () => {
  // 연결한 뒤에 토픽을 고른다
  ws.send(JSON.stringify({ subscribe: 'channelStatus' }));
  ws.send(JSON.stringify({ subscribe: 'LPR', ch: [1, 2] }));
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  // 제어 메시지 먼저 가린다
  if (data.type === 'subscribed') { console.log('Subscribed:', data.topic); return; }
  if (data.type === 'unsubscribed') { console.log('Unsubscribed:', data.topic); return; }
  if (data.type === 'error') { console.error('Error:', data.message); return; }

  // 이벤트 데이터
  if (data.topic === 'LPR') (data.plates || [data]).forEach(p => console.log('Plate:', p.plateNo));
};

// 실행 중에 토픽을 빼거나 더한다
ws.send(JSON.stringify({ unsubscribe: 'channelStatus' }));
ws.send(JSON.stringify({ subscribe: 'object', objectTypes: ['human'] }));
```

**LPR 이벤트 형식:**

인식한 프레임마다 이벤트 하나가 전송됩니다. 그 프레임에서 인식한 번호는 모두 `plates` 배열에 포함됩니다.

```json
{
  "timestamp": "2026-10-23T09:12:31.250+09:00",
  "topic": "LPR",
  "channel": {
    "chid": 1,
    "title": "Main Gate",
    "displayName": "CH1. Main Gate",
    "src": "/watch?ch=1&when=2026-10-23T09%3A12%3A31.250%2B09%3A00"
  },
  "image": "/storage/e/.../plate.jpg",
  "plates": [
    {
      "id": 91234,
      "plateNo": "12가3456",
      "score": 95.5,
      "srcCode": "GATE-IN",
      "srcName": "Entrance Gate",
      "direction": "entry",
      "roi": { "offset": [812, 604], "size": [180, 44] },
      "timeBegin": "2026-10-23T09:12:30.900+09:00",
      "parkingLot": { "entrance": 1 }
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `timestamp` | String | 이벤트 시각 |
| `channel` | Object | 인식 지점의 채널 — `chid`, `title`, `displayName`, `src`(이벤트 시각의 재생 URL). 채널에 연결되지 않은 지점이면 생략 |
| `linkedChannel` | Array | 연동 채널, `channel` 과 같은 객체 |
| `image` | String | 프레임 이미지 URL. 저장된 이미지가 없으면 생략 |
| `plates[].id` | Int | 인식 기록 ID — [10.2](#102-lpr-로그) 의 `data[].id`, [10.4](#104-차량-번호-수정) 의 `{id}`. 기록을 저장하지 못했으면(시스템 디스크 가득 참) 생략 |
| `plates[].plateNo` | String\|null | 차량 번호. 번호를 인식하지 못했으면 `null` |
| `plates[].score` | Number | 인식 신뢰도. 인식 지점이 제공하지 않으면 생략 |
| `plates[].srcCode` · `srcName` | String | 인식 지점 코드와 이름 ([10.1](#101-lpr-소스-인식-지점영역)) |
| `plates[].direction` | String | `entry` 또는 `exit`. 방향을 알 수 없으면(인식 지점에 주행 방향을 설정하지 않음) 생략 |
| `plates[].roi` | Object | 번호판 영역(픽셀): `offset` `[x, y]`, `size` `[w, h]` |
| `plates[].timeBegin` | String | 번호를 처음 인식한 시각 |
| `plates[].parkingLot` | Object | 입구(`entrance`)·출구(`exit`) 주차장 ID. 주차장에 연결된 인식 지점일 때만 포함 |

값이 없는 필드는 생략됩니다. `plateNo` 만 예외로 `null` 입니다.

**주차면 이벤트 필터:**

`parkingSpot` 토픽은 OR 조건으로 결합할 수 있는 세 가지 필터를 지원합니다:
- `ch=1,2` — 지정된 채널에 속한 구역 (1-based)
- `lot=1,2` — 지정된 주차장의 구역
- `spot=100,200` — 특정 구역 ID

필터를 지정하지 않으면 모든 구역이 포함됩니다.

**parkingSpot 응답 형식:**

최초 연결 시 `event` 는 `"currentStatus"` 이며 모든 구역 유형(spot, entrance, exit, noParking, recognition)이 포함됩니다.
이후 업데이트는 `event: "statusChanged"` 를 사용하며, 상태 변경 이벤트는 주차면(`type:"spot"`)에서만 발생합니다.

```json
{
  "timestamp": "2024-01-01T10:00:00+09:00",
  "topic": "parkingSpot",
  "event": "currentStatus",
  "spots": [
    {
      "id": 123,
      "chid": 1,
      "name": "A-001",
      "type": "spot",
      "category": "normal",
      "occupied": true,
      "vehicle": {
        "plateNo": "12가3456",
        "score": 95.5,
        "ev": false,
        "bike": false,
        "since": "2024-01-01T09:30:00+09:00"
      }
    },
    {
      "id": 200,
      "chid": 1,
      "name": "Main Gate",
      "type": "entrance",
      "category": null,
      "vehicle": null
    }
  ]
}
```

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `type` | string | 구역 유형: `"spot"`, `"entrance"`, `"exit"`, `"noParking"`, `"recognition"` |
| `category` | string\|null | 주차면 카테고리 (`type:"spot"`만 해당). 비주차면 유형은 `null`. |
| `occupied` | boolean | (spot 전용) 점유 여부 |
| `vehicle` | object\|null | 차량 정보. 주차면: 점유 시 전체 차량 객체. 비주차면 유형: 마지막 인식의 `plateNo`와 `score`를 포함할 수 있음. |

**예제:**

```javascript
// API Key 인증으로 LPR 및 채널 상태 구독
const ws = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=LPR,channelStatus&apikey=tsapi_key_...'
);

ws.onopen = () => {
  console.log('Connected');
};

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  switch(data.topic) {
    case 'LPR':
      // v1.0.1: data.plates (배열), v1.0.0: data (단일 객체) — 양쪽 모두 호환
      (data.plates || [data]).forEach(p => console.log('Plate:', p.plateNo, 'Score:', p.score));
      break;
    case 'channelStatus':
      console.log('Channel', data.chid, 'Status:', data.status);
      break;
  }
};

ws.onclose = () => {
  console.log('Disconnected');
};
```

**주차면 모니터링 예제:**

```javascript
// 모든 주차면 모니터링
const ws1 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&apikey=tsapi_key_...'
);

// 특정 채널의 주차면 모니터링
const ws2 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&ch=1,2&apikey=tsapi_key_...'
);

// 특정 주차장의 주차면 모니터링
const ws3 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&lot=1,2&apikey=tsapi_key_...'
);

// 특정 주차면 모니터링
const ws4 = new WebSocket(
  'ws://localhost/wsapi/v1/events?topics=parkingSpot&spot=100,200&apikey=tsapi_key_...'
);
```

> **예제:**
> - 이벤트: [JavaScript](examples/javascript/12-websocket-events.js) · [Python](examples/python/12_websocket_events.py) · [C#](examples/csharp/12_WebSocketEvents.cs) · [Go](examples/go/12_ws_events/) · [Java](examples/java/V1_12_WebSocketEvents.java) · [Kotlin](examples/kotlin/V1_12_WebSocketEvents.kt) · [Swift](examples/swift/12-websocket-events.swift) · [PowerShell](examples/powershell/12-websocket-events.ps1) · [curl](examples/curl/12-websocket-events.sh)
> - 주차장: [JavaScript](examples/javascript/13-websocket-parking-lot.js) · [Python](examples/python/13_websocket_parking_lot.py) · [C#](examples/csharp/13_WebSocketParkingLot.cs) · [Go](examples/go/13_ws_parking_lot/) · [Java](examples/java/V1_13_WebSocketParkingLot.java) · [Kotlin](examples/kotlin/V1_13_WebSocketParkingLot.kt) · [Swift](examples/swift/13-websocket-parking-lot.swift) · [PowerShell](examples/powershell/13-websocket-parking-lot.ps1) · [curl](examples/curl/13-websocket-parking-lot.sh)
> - 주차면: [JavaScript](examples/javascript/14-websocket-parking-spot.js) · [Python](examples/python/14_websocket_parking_spot.py) · [C#](examples/csharp/14_WebSocketParkingSpot.cs) · [Go](examples/go/14_ws_parking_spot/) · [Java](examples/java/V1_14_WebSocketParkingSpot.java) · [Kotlin](examples/kotlin/V1_14_WebSocketParkingSpot.kt) · [Swift](examples/swift/14-websocket-parking-spot.swift) · [PowerShell](examples/powershell/14-websocket-parking-spot.ps1) · [curl](examples/curl/14-websocket-parking-spot.sh)

---

## 18. 데이터 내보내기 — 녹화 데이터 백업 (WebSocket API)

녹화 영상을 동영상 파일로 백업하는 WebSocket API입니다.

### 18.1. 내보내기 흐름

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Note over Client,Server: 1. WebSocket 연결
    Client->>Server: WS /wsapi/v1/export?ch=1,2&timeBegin=...&timeEnd=...&apikey=xxx
    Server-->>Client: stage: "ready" (task ID, 채널, 시간범위)

    Note over Client,Server: 2. 내보내기 시작
    Server-->>Client: stage: "begin"

    Note over Client,Server: 3. 채널/파일별 처리
    loop 각 채널
        Server-->>Client: stage: "channelBegin" (chid)
        loop 각 파일
            Server-->>Client: stage: "fileBegin" (파일명)
            Server-->>Client: stage: "fileEnd" (다운로드 URL, MD5)
            Note over Client: HTTP GET으로 파일 다운로드
            Client->>Server: {"task":"...", "cmd":"next"}
        end
        Server-->>Client: stage: "channelEnd"
    end

    Note over Client,Server: 4. 내보내기 완료
    Server-->>Client: stage: "end" (최종 상태)
    Client->>Server: Close
    Server-->>Client: Close ACK
```

**단계별 설명:**

| 단계 | stage | 설명 |
|------|-------|------|
| **1. 연결** | `ready` | WebSocket 연결 후 서버가 파라미터를 검증하고 작업 ID를 발급합니다. `status.code`가 0이 아니면 오류입니다. |
| **2. 시작** | `begin` | 내보내기 작업이 시작됩니다. |
| **3-1. 채널 시작** | `channelBegin` | 해당 채널의 녹화 데이터 처리를 시작합니다. |
| **3-2. 채널 건너뛰기** | `channelSkip` | 해당 채널에 지정된 시간 범위의 녹화 데이터가 없을 때 전송됩니다. |
| **3-3. 파일 시작** | `fileBegin` | 새 동영상 파일 생성을 시작합니다. `mediaSize`로 분할된 경우 여러 번 발생합니다. |
| **3-4. 파일 쓰기 중** | `fileWriting` | `statusInterval` 파라미터 설정 시 주기적으로 진행률을 전송합니다. |
| **3-5. 파일 완료** | `fileEnd` | 파일 생성이 완료되어 다운로드할 수 있습니다. **서버는 클라이언트 응답을 대기합니다.** `ttl` 시간 내에 `next`, `wait`, `cancel` 중 하나를 전송해야 합니다. |
| **3-6. 채널 완료** | `channelEnd` | 해당 채널의 모든 파일 처리가 완료되었습니다. |
| **4. 완료** | `end` | 모든 채널 처리가 완료되었습니다. `status.code`로 최종 결과를 확인합니다. |

#### 서버 메시지 (서버 → 클라이언트)

**`ready` — 작업 준비 완료:**

```json
{
  "stage": "ready",
  "status": {
    "code": 0,
    "message": "Success"
  },
  "task": {
    "id": "task-uuid",
    "ch": [1, 2],
    "timeRange": ["2024-01-01T00:00:00", "2024-01-01T01:00:00"],
    "mediaSize": 1073741824,
    "subtitleFormat": "srt"
  }
}
```

**`ready` 오류 코드:**

| code | 설명 |
|------|------|
| `0` | 성공 |
| `-1` | 지정된 시간 범위에 녹화 데이터 없음 |
| `-2` | 잘못된 파라미터 |
| `-3` | 녹화 스토리지에 저장 불가 |
| `-4` | 폴더 생성/쓰기 불가 |
| `-5` | 디스크 여유 공간 부족 |

**`fileEnd` — 파일 다운로드 준비:**

```json
{
  "stage": "fileEnd",
  "overallProgress": "30%",
  "timestamp": "2024-01-01T12:40:00",
  "channel": {
    "chid": 1,
    "progress": "100%",
    "file": {
      "fid": 0,
      "ttl": 10000,
      "download": [
        {
          "fileName": "CH01_20240101_120000.mp4",
          "src": "/download/task-uuid/CH01_20240101_120000.mp4",
          "md5": "abc123..."
        },
        {
          "fileName": "CH01_20240101_120000.srt",
          "src": "/download/task-uuid/CH01_20240101_120000.srt",
          "md5": "def456..."
        }
      ]
    }
  }
}
```

| 필드 | 설명 |
|------|------|
| `overallProgress` | 전체 진행률 |
| `channel.chid` | 채널 번호 |
| `channel.progress` | 해당 채널 진행률 |
| `channel.file.fid` | 파일 순번 (0부터) |
| `channel.file.ttl` | 응답 제한 시간 (ms). 이 시간 내에 클라이언트 명령을 전송해야 합니다. |
| `channel.file.download` | 다운로드 가능한 파일 목록 (동영상 + 자막) |
| `download[].fileName` | 파일명 |
| `download[].src` | 다운로드 URL (HTTP GET) |
| `download[].md5` | MD5 체크섬 (`md5=true` 요청 시) |

**`end` — 내보내기 완료:**

```json
{
  "stage": "end",
  "overallProgress": "100%",
  "timestamp": "2024-01-01T13:00:00",
  "status": {
    "code": 0,
    "message": "Success"
  }
}
```

#### 클라이언트 명령 (클라이언트 → 서버)

`fileEnd` 메시지를 수신한 후, `ttl` 시간 내에 다음 명령 중 하나를 전송해야 합니다:

```json
{
  "task": "{taskId}",
  "cmd": "next"
}
```

| cmd | 설명 |
|-----|------|
| `next` | 현재 파일 다운로드를 완료하고 다음 파일로 진행합니다. 서버는 임시 파일을 정리하고 다음 파일 처리를 시작합니다. |
| `wait` | 다운로드 시간이 더 필요할 때 전송합니다. 서버는 `ttl`을 초기화하고 다시 대기합니다. 대용량 파일 다운로드 시 사용합니다. |
| `cancel` | 내보내기 작업을 취소합니다. 서버는 진행 중인 처리를 중단하고 `end` 메시지를 전송합니다. |

> **참고**: `ttl` 시간 내에 응답하지 않으면 서버가 `timeoutAlert` 메시지를 전송하며, 계속 응답이 없으면 작업이 자동 취소됩니다.

### 18.2. 엔드포인트

```
ws://{host}:{port}/wsapi/v1/export?ch={channels}&timeBegin={start}&timeEnd={end}&apikey={apiKey}
```

**파라미터:**

| 파라미터 | 설명 |
|-----------|-------------|
| `ch` | 채널 목록 (쉼표로 구분) |
| `timeBegin` | 시작 시간 (ISO 8601) |
| `timeEnd` | 종료 시간 (ISO 8601) |
| `md5` | MD5 체크섬 포함 (true/false) |
| `password` | 암호화 비밀번호 (base64) |
| `mediaSize` | 미디어 파일 크기 제한 (예: `1GB`, `100MB`) |
| `subtitleFormat` | 자막 형식 (srt, vtt, ass, ssa) |
| `statusInterval` | 파일 쓰기 중 진행률 전송 주기 (예: `5s`, `1m`. 기본값: 비활성) |
| `lang` | 언어 코드 ([1.3](#13-언어-lang)) |
| `indent` | JSON 들여쓰기 (0-8) |

**예제:**

```javascript
const params = new URLSearchParams({
  ch: '1,2',
  timeBegin: '2024-01-01T00:00:00',
  timeEnd: '2024-01-01T01:00:00',
  apikey: 'tsapi_key_...'
});

const ws = new WebSocket(`ws://localhost/wsapi/v1/export?${params}`);

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);

  switch(data.stage) {
    case 'ready':
      if (data.status.code !== 0) {
        console.error('Error:', data.status.message);
        ws.close();
        return;
      }
      console.log('Task ID:', data.task.id);
      break;
    case 'fileEnd':
      // 파일 다운로드
      data.channel.file.download.forEach(f => {
        console.log('Download:', f.src);
      });
      // 다음 파일 요청
      ws.send(JSON.stringify({ task: data.task.id, cmd: 'next' }));
      break;
    case 'end':
      console.log('Export complete, code:', data.status.code);
      ws.close();
      break;
  }
};
```

> **예제:** [JavaScript](examples/javascript/15-websocket-export.js) · [Python](examples/python/15_websocket_export.py) · [C#](examples/csharp/15_WebSocketExport.cs) · [Go](examples/go/15_ws_export/) · [Java](examples/java/V1_15_WebSocketExport.java) · [Kotlin](examples/kotlin/V1_15_WebSocketExport.kt) · [Swift](examples/swift/15-websocket-export.swift) · [PowerShell](examples/powershell/15-websocket-export.ps1) · [curl](examples/curl/15-websocket-export.sh)

---

## 부록

### A. 오류 코드

| HTTP 상태 | 설명 |
|-------------|-------------|
| 200 | 성공 |
| 400 | 잘못된 요청 |
| 401 | 인증 필요 |
| 403 | 접근 거부 |
| 404 | 찾을 수 없음 |
| 409 | 충돌 — 요청이 현재 상태와 맞지 않음 |
| 429 | 요청 과다 — 로그인 시도 제한 (`Retry-After` 참조) |
| 500 | 내부 서버 오류 |

오류 발생 시 HTTP 상태 코드와 함께 다음 형식의 JSON 응답 본문이 반환됩니다:

```json
{
  "code": -1,
  "message": "Invalid channel"
}
```

### B. 시간 형식

API의 모든 시간 파라미터와 응답은 [ISO 8601](https://ko.wikipedia.org/wiki/ISO_8601) 형식을 사용합니다.

| 형식 | 예시 | 설명 |
|------|------|------|
| 로컬 시간 | `2024-01-01T10:30:00` | 타임존 오프셋이 없으면 서버의 로컬 시간으로 해석됩니다. |
| UTC | `2024-01-01T10:30:00Z` | `Z` 접미사는 UTC(협정 세계시)를 의미합니다. |
| 타임존 명시 | `2024-01-01T10:30:00+09:00` | `+HH:MM` 또는 `-HH:MM`으로 UTC 오프셋을 명시합니다. |

> **참고**: `timeBegin`, `timeEnd`, `when` 등 시간 파라미터에 타임존 오프셋을 생략하면 **서버 로컬 시간**으로 처리됩니다.

### C. 예제 코드

각 API 기능별 예제 코드입니다. 9개 언어로 제공됩니다.

[curl](#curl) · [JavaScript](#javascript) · [Python](#python) · [C#](#c-sharp) · [Go](#go) · [Java](#java) · [Kotlin](#kotlin) · [Swift](#swift) · [PowerShell](#powershell)

<a id="javascript"></a>**JavaScript** (`examples/javascript/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [01-login.js](examples/javascript/01-login.js) |
| 02 | 채널 목록 | [02-channels.js](examples/javascript/02-channels.js) |
| 03 | PTZ 제어 | [03-ptz-control.js](examples/javascript/03-ptz-control.js) |
| 04 | 녹화 검색 | [04-recording-search.js](examples/javascript/04-recording-search.js) |
| 05 | 이벤트 로그 | [05-event-log.js](examples/javascript/05-event-log.js) |
| 06 | LPR 검색 | [06-lpr-search.js](examples/javascript/06-lpr-search.js) |
| 07 | VOD 스트림 | [07-vod-stream.js](examples/javascript/07-vod-stream.js) |
| 08 | 시스템 정보 | [08-system-info.js](examples/javascript/08-system-info.js) |
| 09 | Push 알림 | [09-push-notification.js](examples/javascript/09-push-notification.js) |
| 10 | 주차 | [10-parking.js](examples/javascript/10-parking.js) |
| 11 | 비상호출 | [11-emergency.js](examples/javascript/11-emergency.js) |
| 12 | WS 이벤트 구독 | [12-websocket-events.js](examples/javascript/12-websocket-events.js) |
| 13 | WS 주차장 모니터링 | [13-websocket-parking-lot.js](examples/javascript/13-websocket-parking-lot.js) |
| 14 | WS 주차면 모니터링 | [14-websocket-parking-spot.js](examples/javascript/14-websocket-parking-spot.js) |
| 15 | WS 데이터 내보내기 | [15-websocket-export.js](examples/javascript/15-websocket-export.js) |

<a id="python"></a>**Python** (`examples/python/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [01_login.py](examples/python/01_login.py) |
| 02 | 채널 목록 | [02_channels.py](examples/python/02_channels.py) |
| 03 | PTZ 제어 | [03_ptz_control.py](examples/python/03_ptz_control.py) |
| 04 | 녹화 검색 | [04_recording_search.py](examples/python/04_recording_search.py) |
| 05 | 이벤트 로그 | [05_event_log.py](examples/python/05_event_log.py) |
| 06 | LPR 검색 | [06_lpr_search.py](examples/python/06_lpr_search.py) |
| 07 | VOD 스트림 | [07_vod_stream.py](examples/python/07_vod_stream.py) |
| 08 | 시스템 정보 | [08_system_info.py](examples/python/08_system_info.py) |
| 09 | Push 알림 | [09_push.py](examples/python/09_push.py) |
| 10 | 주차 | [10_parking.py](examples/python/10_parking.py) |
| 11 | 비상호출 | [11_emergency.py](examples/python/11_emergency.py) |
| 12 | WS 이벤트 구독 | [12_websocket_events.py](examples/python/12_websocket_events.py) |
| 13 | WS 주차장 모니터링 | [13_websocket_parking_lot.py](examples/python/13_websocket_parking_lot.py) |
| 14 | WS 주차면 모니터링 | [14_websocket_parking_spot.py](examples/python/14_websocket_parking_spot.py) |
| 15 | WS 데이터 내보내기 | [15_websocket_export.py](examples/python/15_websocket_export.py) |

<a id="c-sharp"></a>**C#** (`examples/csharp/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [01_Login.cs](examples/csharp/01_Login.cs) |
| 02 | 채널 목록 | [02_Channels.cs](examples/csharp/02_Channels.cs) |
| 03 | PTZ 제어 | [03_PtzControl.cs](examples/csharp/03_PtzControl.cs) |
| 04 | 녹화 검색 | [04_RecordingSearch.cs](examples/csharp/04_RecordingSearch.cs) |
| 05 | 이벤트 로그 | [05_EventLog.cs](examples/csharp/05_EventLog.cs) |
| 06 | LPR 검색 | [06_LprSearch.cs](examples/csharp/06_LprSearch.cs) |
| 07 | VOD 스트림 | [07_VodStream.cs](examples/csharp/07_VodStream.cs) |
| 08 | 시스템 정보 | [08_SystemInfo.cs](examples/csharp/08_SystemInfo.cs) |
| 09 | Push 알림 | [09_Push.cs](examples/csharp/09_Push.cs) |
| 10 | 주차 | [10_Parking.cs](examples/csharp/10_Parking.cs) |
| 11 | 비상호출 | [11_Emergency.cs](examples/csharp/11_Emergency.cs) |
| 12 | WS 이벤트 구독 | [12_WebSocketEvents.cs](examples/csharp/12_WebSocketEvents.cs) |
| 13 | WS 주차장 모니터링 | [13_WebSocketParkingLot.cs](examples/csharp/13_WebSocketParkingLot.cs) |
| 14 | WS 주차면 모니터링 | [14_WebSocketParkingSpot.cs](examples/csharp/14_WebSocketParkingSpot.cs) |
| 15 | WS 데이터 내보내기 | [15_WebSocketExport.cs](examples/csharp/15_WebSocketExport.cs) |

<a id="go"></a>**Go** (`examples/go/`)

| # | 기능 | 디렉토리 |
|---|------|----------|
| 01 | 인증 (로그인) | [01_login/](examples/go/01_login/) |
| 02 | 채널 목록 | [02_channels/](examples/go/02_channels/) |
| 03 | PTZ 제어 | [03_ptz/](examples/go/03_ptz/) |
| 04 | 녹화 검색 | [04_recording/](examples/go/04_recording/) |
| 05 | 이벤트 로그 | [05_events/](examples/go/05_events/) |
| 06 | LPR 검색 | [06_lpr/](examples/go/06_lpr/) |
| 07 | VOD 스트림 | [07_vod/](examples/go/07_vod/) |
| 08 | 시스템 정보 | [08_system/](examples/go/08_system/) |
| 09 | Push 알림 | [09_push/](examples/go/09_push/) |
| 10 | 주차 | [10_parking/](examples/go/10_parking/) |
| 11 | 비상호출 | [11_emergency/](examples/go/11_emergency/) |
| 12 | WS 이벤트 구독 | [12_ws_events/](examples/go/12_ws_events/) |
| 13 | WS 주차장 모니터링 | [13_ws_parking_lot/](examples/go/13_ws_parking_lot/) |
| 14 | WS 주차면 모니터링 | [14_ws_parking_spot/](examples/go/14_ws_parking_spot/) |
| 15 | WS 데이터 내보내기 | [15_ws_export/](examples/go/15_ws_export/) |

<a id="java"></a>**Java** (`examples/java/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [V1_01_Login.java](examples/java/V1_01_Login.java) |
| 02 | 채널 목록 | [V1_02_Channels.java](examples/java/V1_02_Channels.java) |
| 03 | PTZ 제어 | [V1_03_PtzControl.java](examples/java/V1_03_PtzControl.java) |
| 04 | 녹화 검색 | [V1_04_RecordingSearch.java](examples/java/V1_04_RecordingSearch.java) |
| 05 | 이벤트 로그 | [V1_05_EventLog.java](examples/java/V1_05_EventLog.java) |
| 06 | LPR 검색 | [V1_06_LprSearch.java](examples/java/V1_06_LprSearch.java) |
| 07 | VOD 스트림 | [V1_07_VodStream.java](examples/java/V1_07_VodStream.java) |
| 08 | 시스템 정보 | [V1_08_SystemInfo.java](examples/java/V1_08_SystemInfo.java) |
| 09 | Push 알림 | [V1_09_Push.java](examples/java/V1_09_Push.java) |
| 10 | 주차 | [V1_10_Parking.java](examples/java/V1_10_Parking.java) |
| 11 | 비상호출 | [V1_11_Emergency.java](examples/java/V1_11_Emergency.java) |
| 12 | WS 이벤트 구독 | [V1_12_WebSocketEvents.java](examples/java/V1_12_WebSocketEvents.java) |
| 13 | WS 주차장 모니터링 | [V1_13_WebSocketParkingLot.java](examples/java/V1_13_WebSocketParkingLot.java) |
| 14 | WS 주차면 모니터링 | [V1_14_WebSocketParkingSpot.java](examples/java/V1_14_WebSocketParkingSpot.java) |
| 15 | WS 데이터 내보내기 | [V1_15_WebSocketExport.java](examples/java/V1_15_WebSocketExport.java) |

<a id="kotlin"></a>**Kotlin** (`examples/kotlin/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [V1_01_Login.kt](examples/kotlin/V1_01_Login.kt) |
| 02 | 채널 목록 | [V1_02_Channels.kt](examples/kotlin/V1_02_Channels.kt) |
| 03 | PTZ 제어 | [V1_03_PtzControl.kt](examples/kotlin/V1_03_PtzControl.kt) |
| 04 | 녹화 검색 | [V1_04_RecordingSearch.kt](examples/kotlin/V1_04_RecordingSearch.kt) |
| 05 | 이벤트 로그 | [V1_05_EventLog.kt](examples/kotlin/V1_05_EventLog.kt) |
| 06 | LPR 검색 | [V1_06_LprSearch.kt](examples/kotlin/V1_06_LprSearch.kt) |
| 07 | VOD 스트림 | [V1_07_VodStream.kt](examples/kotlin/V1_07_VodStream.kt) |
| 08 | 시스템 정보 | [V1_08_SystemInfo.kt](examples/kotlin/V1_08_SystemInfo.kt) |
| 09 | Push 알림 | [V1_09_Push.kt](examples/kotlin/V1_09_Push.kt) |
| 10 | 주차 | [V1_10_Parking.kt](examples/kotlin/V1_10_Parking.kt) |
| 11 | 비상호출 | [V1_11_Emergency.kt](examples/kotlin/V1_11_Emergency.kt) |
| 12 | WS 이벤트 구독 | [V1_12_WebSocketEvents.kt](examples/kotlin/V1_12_WebSocketEvents.kt) |
| 13 | WS 주차장 모니터링 | [V1_13_WebSocketParkingLot.kt](examples/kotlin/V1_13_WebSocketParkingLot.kt) |
| 14 | WS 주차면 모니터링 | [V1_14_WebSocketParkingSpot.kt](examples/kotlin/V1_14_WebSocketParkingSpot.kt) |
| 15 | WS 데이터 내보내기 | [V1_15_WebSocketExport.kt](examples/kotlin/V1_15_WebSocketExport.kt) |

<a id="swift"></a>**Swift** (`examples/swift/`)

| # | 기능 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [01-login.swift](examples/swift/01-login.swift) |
| 02 | 채널 목록 | [02-channels.swift](examples/swift/02-channels.swift) |
| 03 | PTZ 제어 | [03-ptz-control.swift](examples/swift/03-ptz-control.swift) |
| 04 | 녹화 검색 | [04-recording-search.swift](examples/swift/04-recording-search.swift) |
| 05 | 이벤트 로그 | [05-event-log.swift](examples/swift/05-event-log.swift) |
| 06 | LPR 검색 | [06-lpr-search.swift](examples/swift/06-lpr-search.swift) |
| 07 | VOD 스트림 | [07-vod-stream.swift](examples/swift/07-vod-stream.swift) |
| 08 | 시스템 정보 | [08-system-info.swift](examples/swift/08-system-info.swift) |
| 09 | Push 알림 | [09-push.swift](examples/swift/09-push.swift) |
| 10 | 주차 | [10-parking.swift](examples/swift/10-parking.swift) |
| 11 | 비상호출 | [11-emergency.swift](examples/swift/11-emergency.swift) |
| 12 | WS 이벤트 구독 | [12-websocket-events.swift](examples/swift/12-websocket-events.swift) |
| 13 | WS 주차장 모니터링 | [13-websocket-parking-lot.swift](examples/swift/13-websocket-parking-lot.swift) |
| 14 | WS 주차면 모니터링 | [14-websocket-parking-spot.swift](examples/swift/14-websocket-parking-spot.swift) |
| 15 | WS 데이터 내보내기 | [15-websocket-export.swift](examples/swift/15-websocket-export.swift) |

<a id="powershell"></a>**PowerShell** (`examples/powershell/`)

| # | 주제 | 파일 |
|---|------|------|
| 01 | 인증 (로그인) | [01-login.ps1](examples/powershell/01-login.ps1) |
| 02 | 채널 목록 | [02-channels.ps1](examples/powershell/02-channels.ps1) |
| 03 | PTZ 제어 | [03-ptz-control.ps1](examples/powershell/03-ptz-control.ps1) |
| 04 | 녹화 검색 | [04-recording-search.ps1](examples/powershell/04-recording-search.ps1) |
| 05 | 이벤트 로그 | [05-event-log.ps1](examples/powershell/05-event-log.ps1) |
| 06 | LPR 검색 | [06-lpr-search.ps1](examples/powershell/06-lpr-search.ps1) |
| 07 | VOD 스트림 | [07-vod-stream.ps1](examples/powershell/07-vod-stream.ps1) |
| 08 | 시스템 정보 | [08-system-info.ps1](examples/powershell/08-system-info.ps1) |
| 09 | Push 알림 | [09-push.ps1](examples/powershell/09-push.ps1) |
| 10 | 주차 | [10-parking.ps1](examples/powershell/10-parking.ps1) |
| 11 | 비상호출 | [11-emergency.ps1](examples/powershell/11-emergency.ps1) |
| 12 | WS 이벤트 구독 | [12-websocket-events.ps1](examples/powershell/12-websocket-events.ps1) |
| 13 | WS 주차장 모니터링 | [13-websocket-parking-lot.ps1](examples/powershell/13-websocket-parking-lot.ps1) |
| 14 | WS 주차면 모니터링 | [14-websocket-parking-spot.ps1](examples/powershell/14-websocket-parking-spot.ps1) |
| 15 | WS 데이터 내보내기 | [15-websocket-export.ps1](examples/powershell/15-websocket-export.ps1) |

<a id="curl"></a>**curl / Shell** (`examples/curl/`)

| # | 주제 | 파일 |
|----|------|------|
| 01 | 인증 (로그인) | [01-login.sh](examples/curl/01-login.sh) |
| 02 | 채널 목록 | [02-channels.sh](examples/curl/02-channels.sh) |
| 03 | PTZ 제어 | [03-ptz-control.sh](examples/curl/03-ptz-control.sh) |
| 04 | 녹화 검색 | [04-recording-search.sh](examples/curl/04-recording-search.sh) |
| 05 | 이벤트 로그 | [05-event-log.sh](examples/curl/05-event-log.sh) |
| 06 | LPR 검색 | [06-lpr-search.sh](examples/curl/06-lpr-search.sh) |
| 07 | VOD 스트림 | [07-vod-stream.sh](examples/curl/07-vod-stream.sh) |
| 08 | 시스템 정보 | [08-system-info.sh](examples/curl/08-system-info.sh) |
| 09 | Push 알림 | [09-push.sh](examples/curl/09-push.sh) |
| 10 | 주차 | [10-parking.sh](examples/curl/10-parking.sh) |
| 11 | 비상호출 | [11-emergency.sh](examples/curl/11-emergency.sh) |
| 12 | WS 이벤트 구독 | [12-websocket-events.sh](examples/curl/12-websocket-events.sh) |
| 13 | WS 주차장 모니터링 | [13-websocket-parking-lot.sh](examples/curl/13-websocket-parking-lot.sh) |
| 14 | WS 주차면 모니터링 | [14-websocket-parking-spot.sh](examples/curl/14-websocket-parking-spot.sh) |
| 15 | WS 데이터 내보내기 | [15-websocket-export.sh](examples/curl/15-websocket-export.sh) |

### D. 지원 언어

`lang` 에 지정할 수 있는 코드입니다([1.3. 언어](#13-언어-lang)). `en-US` 가 원문입니다.

| 코드 | 원어 이름 | 영어 이름 |
|------|--------|---------|
| `af-ZA` | Afrikaans | Afrikaans |
| `sq-AL` | Shqip | Albanian |
| `am-ET` | አማርኛ | Amharic |
| `ar-AE` | العربية | Arabic |
| `hy-AM` | Հայերեն | Armenian |
| `az-Latn` | Azərbaycan | Azerbaijani |
| `eu-ES` | euskara | Basque |
| `be-BY` | беларускі | Belarusian |
| `bn-BD` | বাংলা | Bengali |
| `bs-Latn` | Bosanski | Bosnian |
| `bg-BG` | български | Bulgarian |
| `ca-ES` | Català | Catalan |
| `ceb` | Cebuano | Cebuano |
| `ny` | Chichewa | Chichewa |
| `zh-CN` | 简体中国 | Chinese (Simplified) |
| `zh-TW` | 中國傳統 | Chinese (Traditional) |
| `co-FR` | Corsu | Corsican |
| `hr-HR` | hrvatski | Croatian |
| `cs-CZ` | čeština | Czech |
| `da-DK` | dansk | Danish |
| `nl-NL` | Nederlands | Dutch |
| `en-US` | English | English |
| `eo` | Esperanto | Esperanto |
| `et-EE` | Eesti keel | Estonian |
| `fil-PH` | Filipino | Filipino |
| `fi-FI` | Suomalainen | Finnish |
| `fr-FR` | français | French |
| `fy-NL` | Frysk | Frisian |
| `gl-ES` | Galego | Galician |
| `ka-GE` | ქართული | Georgian |
| `de-DE` | Deutsch | German |
| `el-GR` | Ελληνικά | Greek |
| `gu-IN` | ગુજરાતી | Gujarati |
| `ht` | Kreyòl ayisyen | Haitian Creole |
| `ha` | Hausa | Hausa |
| `haw-US` | ʻŌlelo Hawaiʻi | Hawaiian |
| `he-IL` | עברית | Hebrew |
| `hi-IN` | हिन्दी | Hindi |
| `hmn` | Hmong | Hmong |
| `hu-HU` | Magyar | Hungarian |
| `is-IS` | Íslensku | Icelandic |
| `ig-NG` | Igbo | Igbo |
| `id-ID` | bahasa Indonesia | Indonesian |
| `ga-IE` | Gaeilge | Irish |
| `it-IT` | Italiano | Italian |
| `ja-JP` | 日本語 | Japanese |
| `jv-Latn` | Jawa | Javanese |
| `kn-IN` | ಕನ್ನಡ | Kannada |
| `kk-KZ` | Қазақ тілінде | Kazakh |
| `km-KH` | ភាសាខ្មែរ | Khmer |
| `ko-KR` | 한국어 | Korean |
| `kmr-Latn-TR` | Kurdî (Kurmancî) | Kurdish (Kurmanji) |
| `ky-KG` | Кыргызча | Kyrgyz |
| `lo-LA` | ລາວ | Lao |
| `la` | Latine | Latin |
| `lv-LV` | Latviešu | Latvian |
| `lt-LT` | Lietuviškai | Lithuanian |
| `lb-LU` | Lëtzebuergesch | Luxembourgish |
| `mk-MK` | Македонски | Macedonian |
| `mg-MG` | Malagasy | Malagasy |
| `ms-MY` | Melayu | Malay |
| `ml-IN` | മലയാളം | Malayalam |
| `mt-MT` | Malti | Maltese |
| `mi-NZ` | Maori | Maori |
| `mr-IN` | मराठी | Marathi |
| `mn-MN` | Монгол хэл дээр | Mongolian |
| `my-MM` | မြန်မာ | Myanmar (Burmese) |
| `ne-NP` | नेपाली | Nepali |
| `nb-NO` | Norwegian | Norwegian |
| `ps-AF` | پښتو | Pashto |
| `fa-IR` | فارسی | Persian |
| `pl-PL` | Polskie | Polish |
| `pt-BR` | Português (Brasil) | Portuguese |
| `pt-PT` | Português (Portugal) | Portuguese |
| `pa-IN` | ਪੰਜਾਬੀ | Punjabi |
| `ro-RO` | Română | Romanian |
| `ru-RU` | Русский | Russian |
| `sm` | Samoan | Samoan |
| `gd-GB` | Gàidhlig | Scots Gaelic |
| `sr-Cyrl-RS` | Српски | Serbian |
| `st-ZA` | Sesotho | Sesotho |
| `sn-Latn-ZW` | Shona | Shona |
| `sd-Arab-PK` | سنڌي | Sindhi |
| `si-LK` | සිංහල | Sinhala |
| `sk-SK` | slovenský | Slovak |
| `sl-SI` | Slovenščina | Slovenian |
| `so-SO` | Soomaali | Somali |
| `es-ES` | Español | Spanish |
| `su` | Basa Sunda | Sundanese |
| `sw-KE` | Kiswahili | Swahili |
| `sv-SE` | Svenska | Swedish |
| `tg-Cyrl-TJ` | Тоҷикистон | Tajik |
| `ta-IN` | தமிழ் | Tamil |
| `te-IN` | తెలుగు | Telugu |
| `th-TH` | ไทย | Thai |
| `tr-TR` | Türkçe | Turkish |
| `uk-UA` | Українська | Ukrainian |
| `ur-PK` | اردو | Urdu |
| `uz-Latn-UZ` | O'zbek | Uzbek |
| `vi-VN` | Tiếng Việt | Vietnamese |
| `cy-GB` | Cymraeg | Welsh |
| `xh-ZA` | isiXhosa | Xhosa |
| `yi` | ייִדיש | Yiddish |
| `yo-NG` | Yorùbá | Yoruba |
| `zu-ZA` | isiZulu | Zulu |
