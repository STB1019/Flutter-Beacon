import 'package:flutter/material.dart';

class ThemeBuilder extends StatefulWidget{
  final Widget Function(BuildContext context, Brightness brightness, Color primaryColor, Color accentColor) builder;
  final Brightness defaultBrightness;
  final Color defaultPrimaryColor;
  final Color defaultAccentColor;
  //final TextTheme defaultTextTheme;

  static ThemeBuilderState of(BuildContext context){
    return context.findAncestorStateOfType();
  }

  ThemeBuilder({
    this.builder,
    this.defaultBrightness = _ThemeInfo.lightThemeBrightness,
    this.defaultPrimaryColor = _ThemeInfo.lightThemePrimaryColor,
    this.defaultAccentColor = _ThemeInfo.lightThemeAccentColor,
    //this.defaultTextTheme,
  });

  @override
  ThemeBuilderState createState() => ThemeBuilderState();

}


class ThemeBuilderState extends State<ThemeBuilder>{
  Brightness _brightness;
  Color _primaryColor;
  Color _accentColor;
  TextTheme _textTheme;


  @override
  void initState() {
    super.initState();
    _brightness = widget.defaultBrightness;
    _primaryColor = widget.defaultPrimaryColor;
    _accentColor = widget.defaultAccentColor;
    //_textTheme = widget.defaultTextTheme;

    if(mounted)
      setState(() {});
  }


  bool isDarkModeOn() => _brightness == Brightness.dark;

  void changeTheme(){
    setState(() {
      if (isDarkModeOn()){
        _brightness = _ThemeInfo.lightThemeBrightness;
        _primaryColor = _ThemeInfo.lightThemePrimaryColor;
        _accentColor = _ThemeInfo.lightThemeAccentColor;
      }
      else{
        _brightness = _ThemeInfo.darkThemeBrightness;
        _primaryColor = _ThemeInfo.darkThemePrimaryColor;
        _accentColor = _ThemeInfo.darkThemeAccentColor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _brightness, _primaryColor, _accentColor);
  }
}



class _ThemeInfo {

  static const Brightness lightThemeBrightness = Brightness.light;
  static const Color lightThemePrimaryColor = Colors.deepPurpleAccent;
  static const Color lightThemeAccentColor = Color(0xffb19cd9);
  static const TextTheme lightThemeTextTheme = TextTheme(
      headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      headline2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
    );

  static const Brightness darkThemeBrightness = Brightness.dark;
  static const Color darkThemePrimaryColor = Colors.orange;
  static const Color darkThemeAccentColor = Colors.teal;
  static const TextTheme darkThemeTextTheme = TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
    headline2: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
    bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  );

}
