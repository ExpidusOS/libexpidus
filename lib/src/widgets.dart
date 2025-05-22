import 'package:libadwaita/libadwaita.dart' as adwaita;
export 'package:flutter/material.dart'
    show
        Card,
        Checkbox,
        Colors,
        CircularProgressIndicator,
        DialogRoute,
        DrawerButton,
        LinearProgressIndicator,
        Icons,
        Material,
        Radio,
        RefreshProgressIndicator,
        ScaffoldState,
        Scaffold,
        SimpleDialog,
        Theme,
        ThemeData,
        showDialog;

export 'package:bitsdojo_window/bitsdojo_window.dart' show appWindow;
export 'package:flutter/widgets.dart' hide runApp;

export 'package:libadwaita/src/controllers/flap_controller.dart';
export 'package:libadwaita/src/widgets/adw/flap.dart'
    show FoldPolicy, FlapPosition;

// Imports of ExpidusOS specific widgets

export 'widgets/app.dart';
export 'widgets/button.dart';
export 'widgets/dialog.dart';
export 'widgets/digital_clock.dart';
export 'widgets/flap.dart';
export 'widgets/headerbar.dart';
export 'widgets/input_shape_region.dart';
export 'widgets/scaffold.dart';
export 'widgets/sidebar.dart';
export 'widgets/theme.dart';

// Reexports

typedef AboutWindow = adwaita.AdwAboutWindow;
typedef ActionRow = adwaita.AdwActionRow;
typedef Avatar = adwaita.AdwAvatar;
typedef AvatarColor = adwaita.AdwAvatarColor;
typedef AvatarColorPalette = adwaita.AdwAvatarColorPalette;
typedef Clamp = adwaita.AdwClamp;
typedef ComboButton = adwaita.AdwComboButton;
typedef ComboRow = adwaita.AdwComboRow;
typedef HeaderButton = adwaita.AdwHeaderButton;
typedef PopupMenu = adwaita.GtkPopupMenu;
typedef PreferencesGroup = adwaita.AdwPreferencesGroup;
typedef StackSidebar = adwaita.GtkStackSidebar;
typedef Switch = adwaita.AdwSwitch;
typedef SwitchRow = adwaita.AdwSwitchRow;
typedef TextField = adwaita.AdwTextField;
typedef ToggleButton = adwaita.GtkToggleButton;
typedef ThumbPainer = adwaita.AdwThumbPainter;
typedef ViewStack = adwaita.AdwViewStack;
typedef ViewSwitcher = adwaita.AdwViewSwitcher;
typedef ViewSwitcherData = adwaita.ViewSwitcherData;
typedef ViewSwitcherTab = adwaita.AdwViewSwitcherTab;
typedef WindowButton = adwaita.AdwWindowButton;
