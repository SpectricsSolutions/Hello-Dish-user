import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/common/widgets/no_internet_screen.dart';
import 'package:sixam_mart/features/auth/controllers/auth_controller.dart';
import 'package:sixam_mart/features/cart/controllers/cart_controller.dart';
import 'package:sixam_mart/features/notification/domain/models/notification_body_model.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/helper/address_helper.dart';
import 'package:sixam_mart/helper/auth_helper.dart';
import 'package:sixam_mart/util/app_constants.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? body;
  const SplashScreen({super.key, required this.body});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;

  @override
  void initState() {
    super.initState();

    bool firstTime = true;
    _onConnectivityChanged =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
          bool isConnected = result.contains(ConnectivityResult.wifi) ||
              result.contains(ConnectivityResult.mobile);

          if (!firstTime) {
            isConnected
                ? ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar()
                : const SizedBox();
            ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
              backgroundColor: isConnected ? Colors.green : Colors.red,
              duration: Duration(seconds: isConnected ? 3 : 6000),
              content: Text(
                isConnected ? 'connected'.tr : 'no_connection'.tr,
                textAlign: TextAlign.center,
              ),
            ));
            if (isConnected) {
              Get.find<SplashController>().getConfigData(notificationBody: widget.body);
            }
          }
          firstTime = false;
        });

    Get.find<SplashController>().initSharedData();
    if ((AuthHelper.getGuestId().isNotEmpty || AuthHelper.isLoggedIn()) &&
        Get.find<SplashController>().cacheModule != null) {
      Get.find<CartController>().getCartDataOnline();
    }

    Get.find<SplashController>().getConfigData(notificationBody: widget.body);
  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Get.find<SplashController>().initSharedData();
    if (AddressHelper.getUserAddressFromSharedPref() != null &&
        AddressHelper.getUserAddressFromSharedPref()!.zoneIds == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    return Scaffold(
      key: _globalKey,
      backgroundColor: const Color(0xFFFFFFFF), // 🔴 Solid background color
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          return splashController.hasConnection
              ? Stack(
            children: [
              // Main content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated logo
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Hero(
                            tag: 'app_logo',
                            child: Image.asset(
                              Images.logo,
                              width: 300,
                              height: 300,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // App name
                    Text(
                      'HelloDish',
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline (fade-in)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(seconds: 2),
                      curve: Curves.easeInOut,
                      builder: (context, opacity, _) => Opacity(
                        opacity: opacity,
                        child: Text(
                          'Food at your doorstep 🍕',
                          style: robotoRegular.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Loading indicator
                    const SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // Footer (version)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: robotoRegular.copyWith(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          )
              : NoInternetScreen(child: SplashScreen(body: widget.body));
        },
      ),
    );
  }
}
