import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get/get.dart';
import 'package:note_app/services/ad_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final adService = AdService.instance;
      final screenWidth = MediaQuery.of(context).size.width;

      return Obx(() {
        if (!adService.isBannerAdReady || adService.bannerAd == null) {
          // Return a placeholder with minimum height to avoid layout shift
          return const SizedBox(height: 60);
        }

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              width: screenWidth - (screenWidth * 0.08),
              height: adService.bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: adService.bannerAd!),
            ),
          ),
        );
      });
    } catch (e) {
      print('BannerAdWidget error: $e');
      return const SizedBox(height: 60);
    }
  }
}
