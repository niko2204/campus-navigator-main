# 국립목포대학교 캠퍼스 내비게이터

국립목포대학교 캠퍼스 내비게이터는 목포대학교 학생들을 위한 실시간 위치 기반 길찾기 애플리케이션입니다.

## 주요 기능

- 🗺️ 실시간 위치 추적
- 🚶 실시간 경로 안내
- 🏢 건물 내부 지도 제공
- 🔍 건물, 강의실, 교수명 검색
- 🚗 차량/도보 경로 안내

## 설치 방법

### 필수 요구사항

- Flutter SDK (3.0.0 이상)
- Dart SDK (3.0.0 이상)
- Android Studio / VS Code
- Google Maps API 키
- OpenRoute API 키

### 설치 단계

1. 저장소를 클론합니다:
```bash
git clone https://github.com/your-username/campus-navigator.git
cd campus-navigator
```

2. 의존성 패키지를 설치합니다:
```bash
flutter pub get
```

3. API 키를 설정합니다:
   - 프로젝트 루트 디렉토리에 `.env` 파일을 생성합니다.
   - 다음 내용을 `.env` 파일에 추가합니다:
```
GOOGLE_MAPS_API_KEY="your_google_maps_api_key"
OPENROUTE_API_KEY="your_openroute_api_key"
```

4. 플랫폼별 추가 설정:

#### Android 설정
- `android/app/build.gradle` 파일에 다음 내용이 이미 포함되어 있습니다:
```gradle
def envFile = rootProject.file('../.env')
def envProperties = new Properties()
if (envFile.exists()) {
    envFile.withReader('UTF-8') { reader ->
        envProperties.load(reader)
    }
}
```
- `android/app/src/main/AndroidManifest.xml`에 다음 권한이 포함되어 있는지 확인:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

#### iOS 설정
1. Xcode에서 Runner 프로젝트를 엽니다:
```bash
cd ios
open Runner.xcworkspace
```

2. .env 파일을 프로젝트에 추가:
   - Xcode에서 Runner 그룹을 선택
   - File > Add Files to "Runner"... 선택
   - 프로젝트 루트의 .env 파일 선택
   - "Copy items if needed" 옵션 체크
   - "Add to targets"에서 Runner 선택
   - "Create groups" 선택 후 "Add" 클릭

3. Info.plist에 다음 권한이 포함되어 있는지 확인:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to show your current location on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location when in the background to show your current location on the map.</string>
```

4. iOS 최소 배포 버전 설정:
   - Podfile에서 `platform :ios, '14.0'` 설정 확인
   - Xcode에서 Runner 프로젝트의 Deployment Target이 14.0 이상으로 설정되어 있는지 확인

5. 앱을 실행합니다:
```bash
flutter run
```

## locations.json 파일 형식

`assets/locations.json` 파일은 캠퍼스 내 건물과 특수 위치 정보를 포함합니다. 파일 구조는 다음과 같습니다:

```json
{
  "buildings": [
    {
      "baseName": "건물명",
      "coordinates": {
        "latitude": 위도,
        "longitude": 경도
      },
      "indoorMapUrl": "실내지도_URL",  // 선택사항
      "rooms": [
        {
          "number": 방번호,
          "name": "교수명 또는 용도"
        }
      ]
    }
  ],
  "specialLocations": [
    {
      "name": "위치명",
      "coordinates": {
        "latitude": 위도,
        "longitude": 경도
      },
      "indoorMapUrl": "실내지도_URL"  // 선택사항
    }
  ]
}
```

### 필드 설명

#### buildings 배열
- `baseName`: 건물의 기본 이름
- `coordinates`: 건물의 위치 좌표
  - `latitude`: 위도
  - `longitude`: 경도
- `indoorMapUrl`: 실내 지도 URL (선택사항)
- `rooms`: 건물 내 방 목록
  - `number`: 방 번호
  - `name`: 교수명 또는 방 용도

#### specialLocations 배열
- `name`: 특수 위치의 이름
- `coordinates`: 위치 좌표
  - `latitude`: 위도
  - `longitude`: 경도
- `indoorMapUrl`: 실내 지도 URL (선택사항)

## TODO 리스트

### 현재 진행 중
- [ ] 실시간 위치 추적 정확도 개선
- [ ] 경로 안내 UI/UX 개선
- [ ] 건물 내부 지도 연동 최적화

### 향후 계획
- [ ] UWB를 이용한 실내 위치 추적 시스템 구현
  - [ ] UWB 앵커 설치 및 보정
  - [ ] 실내 지도 제작 및 연동
  - [ ] 실내 위치 추적 알고리즘 개발
  - [ ] 실내/실외 위치 전환 로직 구현
- [ ] 다국어 지원 추가
- [ ] 다크 모드 지원
- [ ] 오프라인 모드 지원

## 사용 방법

1. 앱을 실행하면 현재 위치가 지도에 표시됩니다.
2. 검색창에 건물명, 강의실, 교수명을 입력하여 검색합니다.
3. 목적지를 선택하면 실시간 경로 안내가 시작됩니다.
4. 도착지 근처에 도달하면 건물 내부 지도로 전환됩니다.

## 기술 스택

- Flutter
- Google Maps API
- OpenRoute API
- Geolocator
- HTTP

## 개발팀

- 프로젝트 리더: 이영호 교수님
- 개발 기간: 2025년 6월
- 버전: 0.0.1

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 기여 방법

1. 이 저장소를 포크합니다.
2. 새로운 브랜치를 생성합니다 (`git checkout -b feature/amazing-feature`).
3. 변경사항을 커밋합니다 (`git commit -m 'Add some amazing feature'`).
4. 브랜치에 푸시합니다 (`git push origin feature/amazing-feature`).
5. Pull Request를 생성합니다.

## 문제 해결

문제가 발생하면 다음을 확인해주세요:
1. API 키가 올바르게 설정되어 있는지 확인
2. 인터넷 연결 상태 확인
3. 위치 서비스가 활성화되어 있는지 확인
4. 앱 권한이 올바르게 설정되어 있는지 확인

## 업데이트 내역

- 0.0.1
  - 초기 버전 릴리즈
  - 기본 길찾기 기능 구현
  - 실시간 위치 추적 기능 추가
  - 건물 내부 지도 연동
