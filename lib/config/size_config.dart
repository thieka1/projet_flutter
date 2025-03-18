import 'package:flutter/cupertino.dart';

import '../utils/utils.dart';


class SizeConfig {
  //reference suivant les dimentions de l'iphone X/XS
  static const double DESIGN_WIDTH = 375.0;
  static const double DESIGN_HEIGHT = 812.0;

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double pixelRadio;
  static late Orientation orientation;
  static bool isTablet = false;
  static bool isDarkMode = false;

  /*
  Cache pour stocker les calculs de pourcentages
  Ces maps evitent de recalculer les memes pourcentages plusieurs fois

   */
  static final Map<int, double> _widthPercentages = {};
  static final Map<int, double> _heightPercentages = {};

  static void init(BuildContext context) async{
    //permet de recuperer les infos de l'application
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width ;
    screenHeight = _mediaQueryData.size.height ;
    orientation = _mediaQueryData.orientation;
    pixelRadio = _mediaQueryData.devicePixelRatio;
    isDarkMode = _mediaQueryData.platformBrightness == Brightness.dark;



    print("screenWidth: $screenWidth");
    print("screenHeight: $screenHeight");
    print("orientation: $orientation");
    print("pixelRadio: $pixelRadio");
    print("isDarkMode: $isDarkMode");

    isTablet = await Utils.isTablet(context);
    print("isTablet: $isTablet");


  }

  static double getPropotionateScreenHeignt(double inputHeight){
    return (inputHeight / DESIGN_HEIGHT) * screenHeight;

  }
  static double getPropotionateScreenWidth(double inputHeight){
    return (inputHeight / DESIGN_HEIGHT) * screenHeight;

  }
}