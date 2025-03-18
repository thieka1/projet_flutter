import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math' as math;
import '../config/size_config.dart';

class Utils{
  static const double TABLE_BREAKPOINT = 600.0;
  static final  DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static bool isPortrait(BuildContext context){
    return SizeConfig.orientation == Orientation.portrait;
  }

  static Future<bool> isTablet(BuildContext context) async{
    try{
      if(Platform.isIOS){
        return _isIosTablet();
      }
      if(Platform.isAndroid) {
        return _isAndroidTablet(context);
      }

      return _isTabletByScreenSize(context);

    }catch(e) {
      debugPrint("Erreur lors de la detection de la tabelle");
      return _isTabletByScreenSize(context);
    }
  }

  /*
    pour ios c'est simple on veridie juste si le modele
    contient ipad. C'est fiable car apple a une
    nomenclature claire
  */
  static Future<bool> _isIosTablet() async{
    final iosInfos = await _deviceInfo.iosInfo;
    return iosInfos.model.toLowerCase().contains("ipad");
  }
  /*
  pour android, on utilise 3 criteres:
  -verifier si l'ecran depasse 600dp
  -verifier si l'appareil le 64 bits(commun sur la plupart des tablettes modernes)
  -verifier si l'ecran fait plus de 7 pouces en diagonal
   */
  static Future<bool> _isAndroidTablet(BuildContext context) async{
    final androidInfos = await _deviceInfo.androidInfo  ;

    bool isTableByScreen = _isTabletByScreenSize(context);

    bool hasTabletCharacteristecs = androidInfos.supported64BitAbis?.isEmpty ?? false;

    double screenWidth =  MediaQuery.of(context).size.width;
    double screenHeight =  MediaQuery.of(context).size.height;
    double diagonalInchers = _calculateScreenDiagonal(screenWidth, screenHeight, context);
    bool isLargeScreen = diagonalInchers > 7.0;

    return hasTabletCharacteristecs && isTableByScreen && isLargeScreen;
  }
  static double _calculateScreenDiagonal(double width, double height, BuildContext context){
    var pixelRatio = MediaQuery.of(context).devicePixelRatio;
    var physicalWidth = width * pixelRatio;
    var physicalHeight = height * pixelRatio;
    var diagonalPixels = _pytagoras(physicalWidth,physicalHeight);

    return diagonalPixels / (160 * pixelRatio) ;
  }

  static double _pytagoras(double width, double height){
    return math.sqrt(width * width + height * height);
  }

  static bool _isTabletByScreenSize(BuildContext context){
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > TABLE_BREAKPOINT;
  }
}