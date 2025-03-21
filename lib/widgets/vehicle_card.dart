import 'package:flutter/material.dart';
import 'package:inrida/models/vehicle.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      height: 199,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child:
                    vehicle.exteriorPhotoUrl.isNotEmpty
                        ? Image.network(
                          vehicle.exteriorPhotoUrl,
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => _buildCarIcon(),
                        )
                        : _buildCarIcon(),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _getStatusColor(vehicle.status),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFC7C0C0),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      vehicle.status,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        height: 1.5,
                        letterSpacing: -0.02,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 25,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned(
                  top: 5,
                  left: 10,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isSmallScreen = constraints.maxWidth < 350;
                      return Text(
                        isSmallScreen && vehicle.name.length > 15
                            ? '${vehicle.name.substring(0, 15)}...'
                            : vehicle.name,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.4,
                          letterSpacing: -0.02,
                        ),
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: Stack(
              children: [
                Positioned(
                  top: 15,
                  left: 10,
                  child: _buildBadge(
                    vehicle.year.toString(),
                    assetPath: 'assets/year.png',
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 10,
                  child: _buildBadge(
                    '${vehicle.mileage} km',
                    assetPath: 'assets/carbon_meter.png',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 12,
            child: Stack(
              children: [
                Positioned(
                  top: 3, // Adjust this value to move the line vertically
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 25,
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 10,
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/location-icon.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.location,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: 0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 10,

                  child: Row(
                    children: [
                      Icon(Icons.edit_calendar, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        vehicle.listedDate.toIso8601String().split('T')[0],
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.0,
                          letterSpacing: 0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarIcon() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.grey[300],
      child: Icon(Icons.directions_car, size: 50, color: Colors.grey[600]),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF78BE20);
      case 'in use':
        return const Color(0xFF34978A);
      case 'pending':
        return const Color(0xFF838383);
      case 'inactive':
        return const Color(0xFFDD0808);
      default:
        return const Color(0xFF0148FE);
    }
  }

  Widget _buildBadge(String text, {String? assetPath}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 350;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (assetPath != null)
              Row(
                children: [
                  Image.asset(
                    scale: 0.5,
                    assetPath,
                    height: isSmallScreen ? 12 : 20,
                    width: isSmallScreen ? 12 : 20,
                  ),
                  SizedBox(width: isSmallScreen ? 0.3 : 0.7),
                ],
              ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8,
                vertical: isSmallScreen ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w500,
                  fontSize: isSmallScreen ? 10 : 15,
                  height: 1.0,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
