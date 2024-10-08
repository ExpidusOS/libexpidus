import 'package:libadwaita/libadwaita.dart' as adwaita;
import 'package:flutter/material.dart' as material;

export 'package:bitsdojo_window/bitsdojo_window.dart' show appWindow;
export 'package:flutter/widgets.dart' hide runApp;

export 'package:libadwaita/src/controllers/flap_controller.dart';

// Imports of ExpidusOS specific widgets

export 'widgets/app.dart';
export 'widgets/button.dart';
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
typedef Card = material.Card;
typedef Clamp = adwaita.AdwClamp;
typedef ComboButton = adwaita.AdwComboButton;
typedef ComboRow = adwaita.AdwComboRow;
typedef Colors = material.Colors;
typedef CircularProgressIndicator = material.CircularProgressIndicator;
typedef DrawerButton = material.DrawerButton;
typedef HeaderButton = adwaita.AdwHeaderButton;
typedef LinearProgressIndicator = material.LinearProgressIndicator;
typedef Material = material.Material;
typedef PopupMenu = adwaita.GtkPopupMenu;
typedef PreferencesGroup = adwaita.AdwPreferencesGroup;
typedef RefreshProgressIndicator = material.RefreshProgressIndicator;
typedef StackSidebar = adwaita.GtkStackSidebar;
typedef Switch = adwaita.AdwSwitch;
typedef SwitchRow = adwaita.AdwSwitchRow;
typedef Theme = material.Theme;
typedef ThemeData = material.ThemeData;
typedef TextField = adwaita.AdwTextField;
typedef ToggleButton = adwaita.GtkToggleButton;
typedef ThumbPainer = adwaita.AdwThumbPainter;
typedef ViewStack = adwaita.AdwViewStack;
typedef ViewSwitcher = adwaita.AdwViewSwitcher;
typedef ViewSwitcherTab = adwaita.AdwViewSwitcherTab;
typedef WindowButton = adwaita.AdwWindowButton;
