import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PostLocation extends StatefulWidget {
  final String postLocation;
  const PostLocation({super.key, required this.postLocation});

  @override
  State<PostLocation> createState() => _PostLocationState();
}

class _PostLocationState extends State<PostLocation> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  CameraPosition? _initialCameraPosition;
  final Set<Marker> _markers = {};


  @override
  void initState() {
    super.initState();
    _getCoordinatesFromAddress();
  }

  Future<void> _getCoordinatesFromAddress() async {
    try {
      List<Location> locations = await locationFromAddress(widget.postLocation);
      if (locations.isNotEmpty) {
        setState(() {
          _initialCameraPosition = CameraPosition(
            target: LatLng(locations[0].latitude, locations[0].longitude),
            zoom: 14.0,
          );
          _markers.add(Marker(
            markerId: MarkerId(widget.postLocation),
            position: LatLng(locations[0].latitude, locations[0].longitude),
            infoWindow: InfoWindow(title: widget.postLocation),
          ));
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching coordinates: $e");
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:
       Text("Foodgram",
         style: GoogleFonts.getFont('Euphoria Script',
           textStyle: const TextStyle(
             fontSize: 40, // Adjust the font size as needed
             fontWeight: FontWeight.bold,
             color: Colors.white70,
           ),
         ),),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _initialCameraPosition != null
          ? GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition!,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

