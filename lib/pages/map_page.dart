import 'dart:async';

import 'package:assignment/const.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Location locationController = new Location();
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();
  static const LatLng pGooglePlex = LatLng(28.6139, 77.2088);

  static const LatLng pUser = LatLng(28.5876, 77.1690);
  LatLng? currentPos = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocationUpdates().then(
      (_) => {
        getPolylinePoints().then((coordinates) => {
              generatePolyline(coordinates),
            }),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPos == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              onMapCreated: ((GoogleMapController controller) =>
                  mapController.complete(controller)),
              initialCameraPosition:
                  CameraPosition(target: pGooglePlex, zoom: 13),
              markers: {
                Marker(
                    markerId: MarkerId("currentloaction"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: currentPos!),
                Marker(
                    markerId: MarkerId("sourceLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: pUser),
                Marker(
                    markerId: MarkerId("destinationLocation"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: pGooglePlex),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

  Future<void> cameraToPos(LatLng pos) async {
    final GoogleMapController controller = await mapController.future;
    CameraPosition newCameraPos = CameraPosition(target: pos, zoom: 13);
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(newCameraPos));
  }

  Future<void> getLocationUpdates() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          currentPos =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          cameraToPos(currentPos!);
        });
      }
    });
  }

  Future<List<LatLng>> getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAP_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(pUser.latitude, pUser.longitude),
        destination: PointLatLng(pGooglePlex.latitude, pGooglePlex.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    return polylineCoordinates;
  }

  void generatePolyline(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blue,
        points: polylineCoordinates,
        width: 8);
    setState(() {
      polylines[id] = polyline;
    });
  }
}
