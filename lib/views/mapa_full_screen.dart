import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaFullScreen extends StatelessWidget {
  final String destino;
  final double latitude;
  final double longitude;

  const MapaFullScreen({
    super.key,
    required this.destino,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destino),
        backgroundColor: const Color(0xFFEEA243),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('destino'),
            position: LatLng(latitude, longitude),
            infoWindow: InfoWindow(title: destino),
          ),
        },
      ),
    );
  }
}
