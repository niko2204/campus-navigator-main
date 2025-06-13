import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'navigation_page.dart';
import 'search_service.dart';
import 'package:google_maps_project/ui_string.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _googleMapController;
  LatLng _currentCenter = LatLng(37.5665, 126.9780);  // 서울시청 좌표
  double _zoomLevel = 15.0;
  //Set<Marker> _markers = {};
  Marker _userLocationMarker = Marker(
    markerId: MarkerId('userLocation'),
    position: LatLng(37.5665, 126.9780),
  );
  LatLng? _selectedPosition;
  String? _selectedLocationName;  // 선택된 위치의 이름을 저장하는 변수 추가
  bool _buildRoute = false;
  String _selectedRouteMethod = 'walking';
  final Set<Polyline> _polylines = {};
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
 // final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;  // 누락된 변수 추가
  final SearchService _searchService = SearchService();  // 누락된 변수 추가
 // final RouteService _routeService = RouteService();
 // Position? _currentPosition;

  // 이스터 에그 관련 변수
 // final LatLng _easterEggLocation = const LatLng(34.912957, 126.437363); // 이스터 에그 위치
  int _appBarTapCount = 0;
  DateTime? _lastAppBarTapTime;
 // bool _isEasterEggActive = false;

  @override
  void initState() {
    super.initState();
    _currentCenter = const LatLng(34.912957, 126.437363); // Initial location
    _loadCustomMarker();
    _getUserLocation();
    _searchController.addListener(() {
      _searchPlaces(_searchController.text);
    });
  }

  // Custom icon for user location marker
  BitmapDescriptor customIcon = BitmapDescriptor.defaultMarker;

  Future<void> _loadCustomMarker() async {
    final ByteData byteData = await rootBundle.load('assets/user.png');
    final Uint8List originalBytes = byteData.buffer.asUint8List();

    final img.Image? originalImage = img.decodeImage(originalBytes);
    if (originalImage == null) {
      return;
    }

    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: 120,
      height: 120,
    );

    final Uint8List resizedBytes =
        Uint8List.fromList(img.encodePng(resizedImage));

    setState(() {
      customIcon = BitmapDescriptor.bytes(resizedBytes);
      _userLocationMarker = Marker(
        markerId: const MarkerId('userLocation'),
        position: _currentCenter,
        icon: customIcon,
      );
    });
  }

  // Get the user's current location
  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
    });

    LocationPermission permission = await _checkPermissions();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("위치 권한이 거부되었습니다. 앱 설정에서 위치 권한을 허용해주세요.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
        _zoomLevel = 18.0;
        _userLocationMarker = Marker(
          markerId: MarkerId('userLocation'),
          position: _currentCenter,
          icon: customIcon,
        );
        _isLoading = false;
      });

      _googleMapController
          ?.moveCamera(CameraUpdate.newLatLngZoom(_currentCenter, _zoomLevel));
    } catch (e) {
      // 위치를 가져오는데 실패하면 목포대학교 위치로 이동
      setState(() {
        _currentCenter = const LatLng(34.912957, 126.437363);
        _zoomLevel = 17.0;
        _userLocationMarker = Marker(
          markerId: const MarkerId('userLocation'),
          position: _currentCenter,
          icon: customIcon,
        );
        _isLoading = false;
      });

      _googleMapController
          ?.moveCamera(CameraUpdate.newLatLngZoom(_currentCenter, _zoomLevel));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("현재 위치를 가져오는데 실패했습니다. 목포대학교 위치로 이동합니다.")),
      );
    }
  }

  // Check location permissions
  Future<LocationPermission> _checkPermissions() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return LocationPermission.whileInUse;
    } else if (status.isDenied) {
      return LocationPermission.denied;
    } else {
      return LocationPermission.deniedForever;
    }
  }

  // Search for places
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    try {
      final results = await _searchService.searchPlaces(query);


      setState(() {
        _searchResults = results;
      });
    } catch (e) {

      //ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("Error searching places")), );
    }
  }

  // Move map to selected location
  void _moveToLocation(double lat, double lon, String locationName) {  // locationName 매개변수 추가
    setState(() {
      _selectedPosition = LatLng(lat, lon);
      _selectedLocationName = locationName;  // 선택된 위치의 이름 저장
      _searchResults = [];
      _isSearching = false;
      _searchController.clear();
    });
    _googleMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedPosition!, _zoomLevel));
  }

  // Build route buttons (Car, Walk, Bike, Bus)
  Widget _buildRouteButtons() {
    if (_selectedPosition == null) {
      return SizedBox.shrink();
    }
    _buildRoute = true;
    return Positioned(
      bottom: 20,
      left: 15,
      right: 15,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _routeMethodButton(Icons.directions_walk, myStrings["walk"]!),
                _routeMethodButton(Icons.directions_car, myStrings["car"]!),
              ],
            ),
            const SizedBox(height: 10),
            // "Get Directions" Button
            FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavigationPage(
                      startLocation: _currentCenter,
                      endLocation: _selectedPosition!,
                      method: _selectedRouteMethod.toLowerCase(),
                      buildingName: _selectedLocationName,  // 저장된 위치 이름 전달
                    ),
                  ),
                );
                if (result == 'back') {
                  setState(() {
                    _selectedPosition = null;
                    _selectedLocationName = null;  // 위치 이름도 초기화
                    _buildRoute = false;
                  });
                }
              },
              backgroundColor: Color(0xFF00959E),
              label: Row(
                children: const [
                  Icon(Icons.directions, color: Colors.white),
                  SizedBox(width: 5),
                  Text('Get Directions', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper for route buttons
  Widget _routeMethodButton(IconData icon, String method) {
    final isSelected = _selectedRouteMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRouteMethod = method;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.black),
          const SizedBox(height: 4),
          Text(
            method,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // 이스터 에그 체크 함수
  void _handleAppBarTap() {
    final now = DateTime.now();
    if (_lastAppBarTapTime != null && now.difference(_lastAppBarTapTime!) > const Duration(seconds: 2)) {
      _appBarTapCount = 0;
    }
    _lastAppBarTapTime = now;
    _appBarTapCount++;

    if (_appBarTapCount >= 5) {
      _appBarTapCount = 0;
      _showEasterEgg();
    }
  }

  // 이스터 에그 표시 함수
  void _showEasterEgg() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 숨겨진 개발자 모드 발견! 🎉'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('개발팀 정보', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('• 프로젝트 리더: 이영호 교수님'),
              const Text('• 개발 기간: 2025년 6월'),
              const Text('• 버전: 0.0.1'),
              const SizedBox(height: 16),
              const Text('개발팀 멤버', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('•  깃허브'),
              const Text('• 커서 AI'),
              const Text('• 테스트 참여자들'),
              const SizedBox(height: 16),
              const Text('특별 기능', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('• 실시간 위치 추적'),
              const Text('• 실내 네비게이션'),
              const Text('• 건물 내 상세 정보'),
              const SizedBox(height: 16),
              const Text('이 앱은 캠퍼스 내 위치 찾기를 더 쉽게 만들어주는 프로젝트입니다.'),
              const Text('개발팀의 열정과 노력이 담겨있습니다.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00959E),
        title: GestureDetector(
          onTap: _handleAppBarTap,
          child: Text(myStrings['mytitle']!, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _googleMapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _currentCenter,
              zoom: _zoomLevel,
            ),
            markers: {
              _userLocationMarker,
              if (_selectedPosition != null)
                Marker(
                  markerId: const MarkerId('selectedLocation'),
                  position: _selectedPosition!,
                  icon: BitmapDescriptor.defaultMarker,
                ),
            },
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Search bar
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                SizedBox(
                    height: 55.0,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(30, 0, 0, 0),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ]),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                            hintText: myStrings['myhintText'],
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _isSearching = false;
                                        _searchResults = [];
                                      });
                                    },
                                    icon: const Icon(Icons.clear))
                                : null),
                        onTap: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                    )),
                if (_isSearching && _searchResults.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final place = _searchResults[index];
                        return ListTile(
                          title: Text(place['name']),
                          onTap: () {
                            _moveToLocation(
                              place['lat'],
                              place['lon'],
                              place['name'],
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
              ),
            ),

          _buildRouteButtons(),
        ],
      ),
      floatingActionButton: _buildRoute == false
          ? Stack(
              children: [
                Positioned(
                  bottom: 10,
                  left: 30,
                  child: FloatingActionButton(
                    onPressed: _getUserLocation,
                    backgroundColor: Color(0xFF00959E),
                    child: const Icon(
                      Icons.my_location,
                      size: 28,
                    ),
                  ),
                ),
              ],
            )
          : null,
    );
  }
}
