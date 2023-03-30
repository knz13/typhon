// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Bindings for `c_sharp_interface/src/typhon.h`.
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class TyphonBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  TyphonBindings(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  TyphonBindings.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  int initializeCppLibrary() {
    return _initializeCppLibrary();
  }

  late final _initializeCppLibraryPtr =
      _lookup<ffi.NativeFunction<ffi.Int Function()>>('initializeCppLibrary');
  late final _initializeCppLibrary =
      _initializeCppLibraryPtr.asFunction<int Function()>();

  void onMouseMove(
    double positionX,
    double positionY,
  ) {
    return _onMouseMove(
      positionX,
      positionY,
    );
  }

  late final _onMouseMovePtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Double, ffi.Double)>>(
          'onMouseMove');
  late final _onMouseMove =
      _onMouseMovePtr.asFunction<void Function(double, double)>();

  void onKeyboardKeyDown(
    int input,
  ) {
    return _onKeyboardKeyDown(
      input,
    );
  }

  late final _onKeyboardKeyDownPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Int32)>>(
          'onKeyboardKeyDown');
  late final _onKeyboardKeyDown =
      _onKeyboardKeyDownPtr.asFunction<void Function(int)>();

  void onUpdateCall(
    double dt,
  ) {
    return _onUpdateCall(
      dt,
    );
  }

  late final _onUpdateCallPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Double)>>(
          'onUpdateCall');
  late final _onUpdateCall =
      _onUpdateCallPtr.asFunction<void Function(double)>();
}

abstract class InputKey {
  static const int Underline = 32;
  static const int Exclamation_Symbol = 33;
  static const int Double_Quotes = 34;
  static const int Hashtag_Sign = 35;
  static const int Dollar_Sign = 36;
  static const int Percent_Sign = 37;
  static const int Ampersand = 38;
  static const int Single_Quote_Symbol = 39;
  static const int Parenthesis_Right = 40;
  static const int Parenthesis_Left = 41;
  static const int Asterisk = 42;
  static const int Plus_Sign = 43;
  static const int Comma = 44;
  static const int Minus_Sign = 45;
  static const int Dot = 46;
  static const int Slash = 47;
  static const int Digit_Zero = 48;
  static const int Digit_One = 49;
  static const int Digit_Two = 50;
  static const int Digit_Three = 51;
  static const int Digit_Four = 52;
  static const int Digit_Five = 53;
  static const int Digit_Six = 54;
  static const int Digit_Seven = 55;
  static const int Digit_Eight = 56;
  static const int Digit_Nine = 57;
  static const int Colon = 58;
  static const int Semicolon = 59;
  static const int Less_Than_Symbol = 60;
  static const int Equal_Sign = 61;
  static const int Greater_Than_Symbol = 62;
  static const int Question_Mark = 63;
  static const int At_Symbol = 64;
  static const int Square_Bracket_Right = 91;
  static const int Backslash = 92;
  static const int Square_Bracket_Left = 93;
  static const int Circumflex = 94;
  static const int _ = 95;
  static const int Crasis = 96;
  static const int A = 97;
  static const int B = 98;
  static const int C = 99;
  static const int D = 100;
  static const int E = 101;
  static const int F = 102;
  static const int G = 103;
  static const int H = 104;
  static const int I = 105;
  static const int J = 106;
  static const int K = 107;
  static const int L = 108;
  static const int M = 109;
  static const int N = 110;
  static const int O = 111;
  static const int P = 112;
  static const int Q = 113;
  static const int R = 114;
  static const int S = 115;
  static const int T = 116;
  static const int U = 117;
  static const int V = 118;
  static const int W = 119;
  static const int X = 120;
  static const int Y = 121;
  static const int Z = 122;
  static const int Curly_Bracket_Right = 123;
  static const int Vertical_Divider = 124;
  static const int Curly_Bracket_Left = 125;
  static const int Tilde = 126;
  static const int Unidentified = 4294967297;
  static const int Backspace = 4294967304;
  static const int Tab = 4294967305;
  static const int Enter = 4294967309;
  static const int Escape = 4294967323;
  static const int Delete = 4294967423;
  static const int Accel = 4294967553;
  static const int Alt_Graph = 4294967555;
  static const int Caps_Lock = 4294967556;
  static const int Fn = 4294967558;
  static const int Fn_Lock = 4294967559;
  static const int Hyper = 4294967560;
  static const int Num_Lock = 4294967562;
  static const int Scroll_Lock = 4294967564;
  static const int Super = 4294967566;
  static const int Symbol = 4294967567;
  static const int Symbol_Lock = 4294967568;
  static const int Shift_Level_5 = 4294967569;
  static const int Arrow_Down = 4294968065;
  static const int Arrow_Left = 4294968066;
  static const int Arrow_Right = 4294968067;
  static const int Arrow_Up = 4294968068;
  static const int End = 4294968069;
  static const int Home = 4294968070;
  static const int Page_Down = 4294968071;
  static const int Page_Up = 4294968072;
  static const int Clear = 4294968321;
  static const int Copy = 4294968322;
  static const int Cr_Sel = 4294968323;
  static const int Cut = 4294968324;
  static const int Erase_Eof = 4294968325;
  static const int Ex_Sel = 4294968326;
  static const int Insert = 4294968327;
  static const int Paste = 4294968328;
  static const int Redo = 4294968329;
  static const int Undo = 4294968330;
  static const int Accept = 4294968577;
  static const int Again = 4294968578;
  static const int Attn = 4294968579;
  static const int Cancel = 4294968580;
  static const int Context_Menu = 4294968581;
  static const int Execute = 4294968582;
  static const int Find = 4294968583;
  static const int Help = 4294968584;
  static const int Pause = 4294968585;
  static const int Play = 4294968586;
  static const int Props = 4294968587;
  static const int Select = 4294968588;
  static const int Zoom_In = 4294968589;
  static const int Zoom_Out = 4294968590;
  static const int Brightness_Down = 4294968833;
  static const int Brightness_Up = 4294968834;
  static const int Camera = 4294968835;
  static const int Eject = 4294968836;
  static const int Log_Off = 4294968837;
  static const int Power = 4294968838;
  static const int Power_Off = 4294968839;
  static const int Print_Screen = 4294968840;
  static const int Hibernate = 4294968841;
  static const int Standby = 4294968842;
  static const int Wake_Up = 4294968843;
  static const int All_Candidates = 4294969089;
  static const int Alphanumeric = 4294969090;
  static const int Code_Input = 4294969091;
  static const int Compose = 4294969092;
  static const int Convert = 4294969093;
  static const int Final_Mode = 4294969094;
  static const int Group_First = 4294969095;
  static const int Group_Last = 4294969096;
  static const int Group_Next = 4294969097;
  static const int Group_Previous = 4294969098;
  static const int Mode_Change = 4294969099;
  static const int Next_Candidate = 4294969100;
  static const int Non_Convert = 4294969101;
  static const int Previous_Candidate = 4294969102;
  static const int Process = 4294969103;
  static const int Single_Candidate = 4294969104;
  static const int Hangul_Mode = 4294969105;
  static const int Hanja_Mode = 4294969106;
  static const int Junja_Mode = 4294969107;
  static const int Eisu = 4294969108;
  static const int Hankaku = 4294969109;
  static const int Hiragana = 4294969110;
  static const int Hiragana_Katakana = 4294969111;
  static const int Kana_Mode = 4294969112;
  static const int Kanji_Mode = 4294969113;
  static const int Katakana = 4294969114;
  static const int Romaji = 4294969115;
  static const int Zenkaku = 4294969116;
  static const int Zenkaku_Hankaku = 4294969117;
  static const int F1 = 4294969345;
  static const int F2 = 4294969346;
  static const int F3 = 4294969347;
  static const int F4 = 4294969348;
  static const int F5 = 4294969349;
  static const int F6 = 4294969350;
  static const int F7 = 4294969351;
  static const int F8 = 4294969352;
  static const int F9 = 4294969353;
  static const int F10 = 4294969354;
  static const int F11 = 4294969355;
  static const int F12 = 4294969356;
  static const int F13 = 4294969357;
  static const int F14 = 4294969358;
  static const int F15 = 4294969359;
  static const int F16 = 4294969360;
  static const int F17 = 4294969361;
  static const int F18 = 4294969362;
  static const int F19 = 4294969363;
  static const int F20 = 4294969364;
  static const int F21 = 4294969365;
  static const int F22 = 4294969366;
  static const int F23 = 4294969367;
  static const int F24 = 4294969368;
  static const int Soft_1 = 4294969601;
  static const int Soft_2 = 4294969602;
  static const int Soft_3 = 4294969603;
  static const int Soft_4 = 4294969604;
  static const int Soft_5 = 4294969605;
  static const int Soft_6 = 4294969606;
  static const int Soft_7 = 4294969607;
  static const int Soft_8 = 4294969608;
  static const int Close = 4294969857;
  static const int Mail_Forward = 4294969858;
  static const int Mail_Reply = 4294969859;
  static const int Mail_Send = 4294969860;
  static const int Media_Play_Pause = 4294969861;
  static const int Media_Stop = 4294969863;
  static const int Media_Track_Next = 4294969864;
  static const int Media_Track_Previous = 4294969865;
  static const int New = 4294969866;
  static const int Open = 4294969867;
  static const int Print = 4294969868;
  static const int Save = 4294969869;
  static const int Spell_Check = 4294969870;
  static const int Audio_Volume_Down = 4294969871;
  static const int Audio_Volume_Up = 4294969872;
  static const int Audio_Volume_Mute = 4294969873;
  static const int Launch_Application_2 = 4294970113;
  static const int Launch_Calendar = 4294970114;
  static const int Launch_Mail = 4294970115;
  static const int Launch_Media_Player = 4294970116;
  static const int Launch_Music_Player = 4294970117;
  static const int Launch_Application_1 = 4294970118;
  static const int Launch_Screen_Saver = 4294970119;
  static const int Launch_Spreadsheet = 4294970120;
  static const int Launch_Web_Browser = 4294970121;
  static const int Launch_Web_Cam = 4294970122;
  static const int Launch_Word_Processor = 4294970123;
  static const int Launch_Contacts = 4294970124;
  static const int Launch_Phone = 4294970125;
  static const int Launch_Assistant = 4294970126;
  static const int Launch_Control_Panel = 4294970127;
  static const int Browser_Back = 4294970369;
  static const int Browser_Favorites = 4294970370;
  static const int Browser_Forward = 4294970371;
  static const int Browser_Home = 4294970372;
  static const int Browser_Refresh = 4294970373;
  static const int Browser_Search = 4294970374;
  static const int Browser_Stop = 4294970375;
  static const int Audio_Balance_Left = 4294970625;
  static const int Audio_Balance_Right = 4294970626;
  static const int Audio_Bass_Boost_Down = 4294970627;
  static const int Audio_Bass_Boost_Up = 4294970628;
  static const int Audio_Fader_Front = 4294970629;
  static const int Audio_Fader_Rear = 4294970630;
  static const int Audio_Surround_Mode_Next = 4294970631;
  static const int AVR_Input = 4294970632;
  static const int AVR_Power = 4294970633;
  static const int Channel_Down = 4294970634;
  static const int Channel_Up = 4294970635;
  static const int Color_F0_Red = 4294970636;
  static const int Color_F1_Green = 4294970637;
  static const int Color_F2_Yellow = 4294970638;
  static const int Color_F3_Blue = 4294970639;
  static const int Color_F4_Grey = 4294970640;
  static const int Color_F5_Brown = 4294970641;
  static const int Closed_Caption_Toggle = 4294970642;
  static const int Dimmer = 4294970643;
  static const int Display_Swap = 4294970644;
  static const int Exit = 4294970645;
  static const int Favorite_Clear_0 = 4294970646;
  static const int Favorite_Clear_1 = 4294970647;
  static const int Favorite_Clear_2 = 4294970648;
  static const int Favorite_Clear_3 = 4294970649;
  static const int Favorite_Recall_0 = 4294970650;
  static const int Favorite_Recall_1 = 4294970651;
  static const int Favorite_Recall_2 = 4294970652;
  static const int Favorite_Recall_3 = 4294970653;
  static const int Favorite_Store_0 = 4294970654;
  static const int Favorite_Store_1 = 4294970655;
  static const int Favorite_Store_2 = 4294970656;
  static const int Favorite_Store_3 = 4294970657;
  static const int Guide = 4294970658;
  static const int Guide_Next_Day = 4294970659;
  static const int Guide_Previous_Day = 4294970660;
  static const int Info = 4294970661;
  static const int Instant_Replay = 4294970662;
  static const int Link = 4294970663;
  static const int List_Program = 4294970664;
  static const int Live_Content = 4294970665;
  static const int Lock = 4294970666;
  static const int Media_Apps = 4294970667;
  static const int Media_Fast_Forward = 4294970668;
  static const int Media_Last = 4294970669;
  static const int Media_Pause = 4294970670;
  static const int Media_Play = 4294970671;
  static const int Media_Record = 4294970672;
  static const int Media_Rewind = 4294970673;
  static const int Media_Skip = 4294970674;
  static const int Next_Favorite_Channel = 4294970675;
  static const int Next_User_Profile = 4294970676;
  static const int On_Demand = 4294970677;
  static const int P_In_P_Down = 4294970678;
  static const int P_In_P_Move = 4294970679;
  static const int P_In_P_Toggle = 4294970680;
  static const int P_In_P_Up = 4294970681;
  static const int Play_Speed_Down = 4294970682;
  static const int Play_Speed_Reset = 4294970683;
  static const int Play_Speed_Up = 4294970684;
  static const int Random_Toggle = 4294970685;
  static const int Rc_Low_Battery = 4294970686;
  static const int Record_Speed_Next = 4294970687;
  static const int Rf_Bypass = 4294970688;
  static const int Scan_Channels_Toggle = 4294970689;
  static const int Screen_Mode_Next = 4294970690;
  static const int Settings = 4294970691;
  static const int Split_Screen_Toggle = 4294970692;
  static const int STB_Input = 4294970693;
  static const int STB_Power = 4294970694;
  static const int Subtitle = 4294970695;
  static const int Teletext = 4294970696;
  static const int TV = 4294970697;
  static const int TV_Input = 4294970698;
  static const int TV_Power = 4294970699;
  static const int Video_Mode_Next = 4294970700;
  static const int Wink = 4294970701;
  static const int Zoom_Toggle = 4294970702;
  static const int DVR = 4294970703;
  static const int Media_Audio_Track = 4294970704;
  static const int Media_Skip_Backward = 4294970705;
  static const int Media_Skip_Forward = 4294970706;
  static const int Media_Step_Backward = 4294970707;
  static const int Media_Step_Forward = 4294970708;
  static const int Media_Top_Menu = 4294970709;
  static const int Navigate_In = 4294970710;
  static const int Navigate_Next = 4294970711;
  static const int Navigate_Out = 4294970712;
  static const int Navigate_Previous = 4294970713;
  static const int Pairing = 4294970714;
  static const int Media_Close = 4294970715;
  static const int Audio_Bass_Boost_Toggle = 4294970882;
  static const int Audio_Treble_Down = 4294970884;
  static const int Audio_Treble_Up = 4294970885;
  static const int Microphone_Toggle = 4294970886;
  static const int Microphone_Volume_Down = 4294970887;
  static const int Microphone_Volume_Up = 4294970888;
  static const int Microphone_Volume_Mute = 4294970889;
  static const int Speech_Correction_List = 4294971137;
  static const int Speech_Input_Toggle = 4294971138;
  static const int App_Switch = 4294971393;
  static const int Call = 4294971394;
  static const int Camera_Focus = 4294971395;
  static const int End_Call = 4294971396;
  static const int Go_Back = 4294971397;
  static const int Go_Home = 4294971398;
  static const int Headset_Hook = 4294971399;
  static const int Last_Number_Redial = 4294971400;
  static const int Notification = 4294971401;
  static const int Manner_Mode = 4294971402;
  static const int Voice_Dial = 4294971403;
  static const int TV_3_D_Mode = 4294971649;
  static const int TV_Antenna_Cable = 4294971650;
  static const int TV_Audio_Description = 4294971651;
  static const int TV_Audio_Description_Mix_Down = 4294971652;
  static const int TV_Audio_Description_Mix_Up = 4294971653;
  static const int TV_Contents_Menu = 4294971654;
  static const int TV_Data_Service = 4294971655;
  static const int TV_Input_Component_1 = 4294971656;
  static const int TV_Input_Component_2 = 4294971657;
  static const int TV_Input_Composite_1 = 4294971658;
  static const int TV_Input_Composite_2 = 4294971659;
  static const int TV_Input_HDMI_1 = 4294971660;
  static const int TV_Input_HDMI_2 = 4294971661;
  static const int TV_Input_HDMI_3 = 4294971662;
  static const int TV_Input_HDMI_4 = 4294971663;
  static const int TV_Input_VGA_1 = 4294971664;
  static const int TV_Media_Context = 4294971665;
  static const int TV_Network = 4294971666;
  static const int TV_Number_Entry = 4294971667;
  static const int TV_Radio_Service = 4294971668;
  static const int TV_Satellite = 4294971669;
  static const int TV_Satellite_BS = 4294971670;
  static const int TV_Satellite_CS = 4294971671;
  static const int TV_Satellite_Toggle = 4294971672;
  static const int TV_Terrestrial_Analog = 4294971673;
  static const int TV_Terrestrial_Digital = 4294971674;
  static const int TV_Timer = 4294971675;
  static const int Key_11 = 4294971905;
  static const int Key_12 = 4294971906;
  static const int Suspend = 8589934592;
  static const int Resume = 8589934593;
  static const int Sleep = 8589934594;
  static const int Abort = 8589934595;
  static const int Lang_1 = 8589934608;
  static const int Lang_2 = 8589934609;
  static const int Lang_3 = 8589934610;
  static const int Lang_4 = 8589934611;
  static const int Lang_5 = 8589934612;
  static const int Intl_Backslash = 8589934624;
  static const int Intl_Ro = 8589934625;
  static const int Intl_Yen = 8589934626;
  static const int Control_Left = 8589934848;
  static const int Control_Right = 8589934849;
  static const int Shift_Left = 8589934850;
  static const int Shift_Right = 8589934851;
  static const int Alt_Left = 8589934852;
  static const int Alt_Right = 8589934853;
  static const int Meta_Left = 8589934854;
  static const int Meta_Right = 8589934855;
  static const int Control = 8589935088;
  static const int Shift = 8589935090;
  static const int Alt = 8589935092;
  static const int Meta = 8589935094;
  static const int Numpad_Enter = 8589935117;
  static const int Numpad_Paren_Left = 8589935144;
  static const int Numpad_Paren_Right = 8589935145;
  static const int Numpad_Multiply = 8589935146;
  static const int Numpad_Add = 8589935147;
  static const int Numpad_Comma = 8589935148;
  static const int Numpad_Subtract = 8589935149;
  static const int Numpad_Decimal = 8589935150;
  static const int Numpad_Divide = 8589935151;
  static const int Numpad_0 = 8589935152;
  static const int Numpad_1 = 8589935153;
  static const int Numpad_2 = 8589935154;
  static const int Numpad_3 = 8589935155;
  static const int Numpad_4 = 8589935156;
  static const int Numpad_5 = 8589935157;
  static const int Numpad_6 = 8589935158;
  static const int Numpad_7 = 8589935159;
  static const int Numpad_8 = 8589935160;
  static const int Numpad_9 = 8589935161;
  static const int Numpad_Equal = 8589935165;
  static const int Game_Button_1 = 8589935361;
  static const int Game_Button_2 = 8589935362;
  static const int Game_Button_3 = 8589935363;
  static const int Game_Button_4 = 8589935364;
  static const int Game_Button_5 = 8589935365;
  static const int Game_Button_6 = 8589935366;
  static const int Game_Button_7 = 8589935367;
  static const int Game_Button_8 = 8589935368;
  static const int Game_Button_9 = 8589935369;
  static const int Game_Button_10 = 8589935370;
  static const int Game_Button_11 = 8589935371;
  static const int Game_Button_12 = 8589935372;
  static const int Game_Button_13 = 8589935373;
  static const int Game_Button_14 = 8589935374;
  static const int Game_Button_15 = 8589935375;
  static const int Game_Button_16 = 8589935376;
  static const int Game_Button_A = 8589935377;
  static const int Game_Button_B = 8589935378;
  static const int Game_Button_C = 8589935379;
  static const int Game_Button_Left_1 = 8589935380;
  static const int Game_Button_Left_2 = 8589935381;
  static const int Game_Button_Mode = 8589935382;
  static const int Game_Button_Right_1 = 8589935383;
  static const int Game_Button_Right_2 = 8589935384;
  static const int Game_Button_Select = 8589935385;
  static const int Game_Button_Start = 8589935386;
  static const int Game_Button_Thumb_Left = 8589935387;
  static const int Game_Button_Thumb_Right = 8589935388;
  static const int Game_Button_X = 8589935389;
  static const int Game_Button_Y = 8589935390;
  static const int Game_Button_Z = 8589935391;
}
