--------------------------------------------------------------------------------
-- IMPORTS
--------------------------------------------------------------------------------
import XMonad
import Data.Monoid
import System.Exit
import qualified XMonad.StackSet as W
import qualified Data.Map as M

-- Utilities
import XMonad.Util.Run (spawnPipe, hPutStrLn)
import XMonad.Util.SpawnOnce
import XMonad.Util.EZConfig (additionalKeysP, additionalMouseBindings)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Loggers

-- Hooks
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.FadeInactive
--import XMonad.Hooks.historyHook

-- Layouts
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.ResizableTile
import XMonad.Layout.NoBorders
import XMonad.Layout.Fullscreen
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Layout.Grid
import XMonad.Layout.Magnifier
import XMonad.Layout.Renamed (renamed, Rename(Replace))
import XMonad.Layout.MultiToggle
import XMonad.Layout.MultiToggle.Instances

-- Actions
import XMonad.Actions.CycleWS
import XMonad.Actions.Promote
import XMonad.Actions.WithAll
import XMonad.Actions.GridSelect

--------------------------------------------------------------------------------
-- VARIABLES - Customize these to your preference
--------------------------------------------------------------------------------

-- CHOICE 1: Terminal Emulator
-- Options: "alacritty", "kitty", "wezterm", "xterm"
myTerminal :: String
--myTerminal = "alacritty"
--myTerminal = "xterm"
myTerminal = "/usr/local/bin/st"

-- CHOICE 2: Application Launcher  
-- Options: "rofi -show drun", "dmenu_run", "rofi -show run"
myLauncher :: String
myLauncher = "rofi -show drun -show-icons"

-- Whether focus follows the mouse pointer
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels
myBorderWidth :: Dimension
myBorderWidth = 1

-- Mod key (mod1Mask = Alt, mod4Mask = Super/Windows key)
-- CHOICE 3: Modifier Key
-- Most users prefer mod4Mask (Super/Windows key) to avoid conflicts with apps
myModMask :: KeyMask
myModMask = mod4Mask

-- Workspace names - customize as you prefer
-- You can use icons if you have a font that supports them (e.g., Font Awesome)
myWorkspaces :: [String]
myWorkspaces = ["1:adm", "2:web", "3:dev", "4:cody", "5", "6", "7", "8", "9:bakkies"]

-- Border colors
-- I think the defaults are something like 0x707070 and 0xff2020 or something like that.
--myNormalBorderColor :: String
--myNormalBorderColor  = "#3b4252"  -- Nord: polar night

--myFocusedBorderColor :: String
--myFocusedBorderColor = "#88c0d0"  -- Nord: frost cyan

-- Gap sizes (pixels between windows and screen edges)
-- Set to 0 if you don't want gaps
--myGaps :: Integer
--myGaps = 0
--myGaps = 0

--mySpacing :: Integer
--mySpacing = 0
--mySpacing = 0

-- WALLPAPER CONFIGURATION (Nitrogen-based)
wallpaperDir :: String
wallpaperDir = "$HOME/.wallpapers"

-- Extract workspace number from workspace name (e.g., "1:web" -> "1")
workspaceNumber :: String -> String
workspaceNumber ws = takeWhile (/= ':') ws

wallpaperCommand :: String -> String
wallpaperCommand workspace = 
--    "feh --bg-scale " ++ wallpaperDir ++ "/" ++ workspaceNumber workspace ++ ".jpeg &"
    "nitrogen --set-zoom-fill " ++ wallpaperDir ++ "/" ++ workspaceNumber workspace ++ ".jpeg &"

defaultWallpaper :: String
defaultWallpaper = wallpaperDir ++ "/default.jpeg"

-- Nitrogen-based wallpaper setter
--wallpaperCommand :: String -> String
--wallpaperCommand workspace = 
--    -- Use nitrogen --set-scaled for better image handling
--    "nitrogen --set-scaled " ++ wallpaperDir ++ "/" ++ workspace ++ ".jpeg --save &"

-- Alternative: Use nitrogen's database mode
--wallpaperCommandDB :: String -> String
--wallpaperCommandDB workspace = 
--    "nitrogen --set-removed-if-missing --save " ++ wallpaperDir ++ "/" ++ workspace ++ ".jpeg"

--------------------------------------------------------------------------------
-- WALLPAPER SETTER HOOK
--------------------------------------------------------------------------------
--wallpaperOnFocus :: X ()
--wallpaperOnFocus = do
--    ws <- gets windowset
--    let currentWorkspace = W.currentTag ws
--    -- Use the database command for better nitrogen integration
--    spawn (wallpaperCommandDB currentWorkspace)

-- Event hook to monitor workspace changes
--myEventHook :: Event -> X All
--myEventHook (FocusChangeEvent {ev_window = w}) = do
--    focusedWindow <- withWindowSet $ pure . W.focus
--    if focusedWindow == Just w
--        then wallpaperOnFocus
--        else pure (All True)
--myEventHook (EnterWindowEvent {ev_window = w}) = do
--    focusedWindow <- withWindowSet $ pure . W.focus
--    when (focusedWindow == Just w) wallpaperOnFocus
--    pure (All True)
--myEventHook _ = pure (All True)
--myLogHook :: X ()
--myLogHook = do
--    ws <- gets windowset
--    let currentWorkspace = W.currentTag ws
--    spawn (wallpaperCommand currentWorkspace)

--------------------------------------------------------------------------------
-- STARTUP HOOK - Programs to run on xmonad startup
--------------------------------------------------------------------------------
myStartupHook :: X ()
myStartupHook = do

    -- Set initial wallpaper using nitrogen
    ws <- gets windowset
    let currentWorkspace = W.currentTag ws
    spawn (wallpaperCommand currentWorkspace)
    
    -- Set nitrogen preferences for consistent behavior
    spawn "nitrogen --force-setter=xinerama --save &"
    
    -- Create default wallpaper if missing
    spawn $ "if [ ! -f '" ++ wallpaperDir ++ "/default.jpeg" ++ "' ]; then " ++
             "convert -size 1920x1080 xc:'#2e3440' '" ++ wallpaperDir ++ "/default.jpeg'; fi"
    
    -- Set wallpaper for each workspace (with fallback to default)
    mapM_ (\i -> spawn $ 
        "if [ ! -f '" ++ wallpaperDir ++ "/" ++ show i ++ ".jpeg" ++ 
        "' ]; then cp '" ++ wallpaperDir ++ "/default.jpeg' '" ++ wallpaperDir ++ "/" ++ show i ++ ".jpeg'; fi") [1..9]
    
    -- CHOICE 4: Compositor
    -- picom for transparency, shadows, and animations
    spawnOnce "picom --config ~/.config/picom/picom.conf &"
    
    -- CHOICE 5: Wallpaper Setter
    -- Option A: nitrogen (GUI for selecting wallpapers)
    spawnOnce "nitrogen --restore &"
    -- Option B: feh (command line)
    -- spawnOnce "feh --bg-scale ~/Pictures/wallpaper.jpg &"
    
    -- Notification daemon
    spawnOnce "dunst &"

    spawnOnce "polybar -c ~/.config/xmonad/polybar.ini &"
    
    -- System tray
--    spawnOnce "trayer --edge top --align right --width 5 --height 18 --transparent true --alpha 0 --tint 0x2e3440 --iconspacing 3 --distance 1 &"
    
    -- Network manager applet
--    spawnOnce "nm-applet &"
    
    -- Audio control tray icon
    -- spawnOnce "volumeicon &"
    
    -- Bluetooth
    -- spawnOnce "blueman-applet &"
    
    -- Auto-lock screen after inactivity (5 minutes)
 --   spawnOnce "xautolock -time 5 -locker 'i3lock -c 000000' &"
    
    -- Hide mouse cursor when idle
    spawnOnce "unclutter --timeout 3 &"
    
    -- Enable numlock
--    spawnOnce "numlockx on &"
    
    -- Blue light filter (adjust coordinates to your location)
--    spawnOnce "redshift -l 41.3:-19.8 &"
    spawnOnce "redshift -c /home/yair/.config/redshift/redshift.conf  &"
    
    -- Set keyboard layout
    -- spawnOnce "setxkbmap -layout us &"
    
    -- Touchpad settings (if laptop)
    -- spawnOnce "xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Tapping Enabled' 1 &"

    -- Neko!!1!
    spawnOnce "oneko -tofocus &"

--------------------------------------------------------------------------------
-- SCRATCHPADS - Dropdown terminals and floating windows
--------------------------------------------------------------------------------
-- Scratchpads are floating windows you can toggle with a keybinding
myScratchpads :: [NamedScratchpad]
myScratchpads = 
    [ NS "terminal" spawnTerm findTerm manageTerm
--    , NS "calculator" spawnCalc findCalc manageCalc
--    , NS "mixer" spawnMixer findMixer manageMixer
    ]
  where
    spawnTerm  = myTerminal ++ " --class scratchpad"
    findTerm   = className =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect 0.1 0.1 0.8 0.8
    
--    spawnCalc  = "gnome-calculator"
--    findCalc   = className =? "Gnome-calculator"
--    manageCalc = customFloating $ W.RationalRect 0.3 0.3 0.4 0.4
    
--    spawnMixer = "pavucontrol"
--    findMixer  = className =? "Pavucontrol"
--    manageMixer = customFloating $ W.RationalRect 0.25 0.25 0.5 0.5

--------------------------------------------------------------------------------
-- LAYOUTS - Different window arrangements
--------------------------------------------------------------------------------
myLayout = avoidStruts 
         $ smartBorders 
         $ mkToggle (NBFULL ?? EOT) 
--         $ spacingLayout
         $ layouts
  where
    -- Add spacing around windows
--    spacingLayout = spacingRaw False (Border myGaps myGaps myGaps myGaps) True 
--                                      (Border mySpacing mySpacing mySpacing mySpacing) True
    
    layouts = tall ||| wide ||| threeCol ||| grid ||| spiral ||| tabs ||| full
    
    -- Tall layout: master on left, stack on right
    tall = renamed [Replace "Tall"]
         $ ResizableTall 1 (3/100) (1/2) []
    
    -- Wide layout: master on top, stack on bottom
    wide = renamed [Replace "Wide"]
         $ Mirror $ ResizableTall 1 (3/100) (1/2) []
    
    -- Three column layout
    threeCol = renamed [Replace "ThreeCol"]
             $ ThreeColMid 1 (3/100) (1/2)
    
    -- Grid layout
    grid = renamed [Replace "Grid"]
         $ Grid
    
    -- Spiral layout (Fibonacci-like)
    spiral = renamed [Replace "Spiral"]
           $ XMonad.Layout.Spiral.spiral (6/7)
    
    -- Tabbed layout
    tabs = renamed [Replace "Tabs"]
         $ tabbed shrinkText myTabConfig
    
    -- Full screen
    full = renamed [Replace "Full"]
         $ Full

-- Tab theme configuration
myTabConfig :: Theme
myTabConfig = def
    { activeColor         = "#88c0d0"
    , inactiveColor       = "#3b4252"
    , urgentColor         = "#bf616a"
    , activeBorderColor   = "#88c0d0"
    , inactiveBorderColor = "#3b4252"
    , urgentBorderColor   = "#bf616a"
    , activeTextColor     = "#2e3440"
    , inactiveTextColor   = "#d8dee9"
    , urgentTextColor     = "#2e3440"
    , fontName            = "xft:JetBrains Mono:size=10:antialias=true"
    }

--------------------------------------------------------------------------------
-- WINDOW RULES - Where windows should appear and how they should behave
--------------------------------------------------------------------------------
myManageHook :: ManageHook
myManageHook = composeAll
    -- Float certain windows
    [ className =? "MPlayer"          --> doFloat
    , className =? "Gimp"             --> doFloat
    , className =? "Pavucontrol"      --> doFloat
    , className =? "Arandr"           --> doFloat
    , className =? "Lxappearance"     --> doFloat
    , className =? "Nitrogen"         --> doFloat
    , className =? "XEyes"            --> doFloat
    , className =? "xeyes"            --> doIgnore
    , className =? "emoji-picker"     --> doFloat
    , className =? "Emoji-picker"     --> doFloat
	, className =? "oneko"			  --> doFloat
	, resource  =? "oneko"			  --> doFloat
    , resource  =? "desktop_window"   --> doIgnore
    , resource  =? "kdesktop"         --> doIgnore
    
    -- Move certain windows to specific workspaces
    , className =? "Firefox"          --> doShift "2:web"
    , className =? "Google-chrome"    --> doShift "2:web"
    , className =? "Vivaldi-stable"   --> doShift "2:web"
    , className =? "Vivaldi"          --> doShift "2:web"
    , className =? "code-oss"         --> doShift "4:cody"
    , className =? "Code"             --> doShift "4:cody"
    , className =? "Slack"            --> doShift "4:cody"
--    , className =? "discord"          --> doShift "4:chat"
--    , className =? "Spotify"          --> doShift "5:media"
--    , className =? "vlc"              --> doShift "5:media"
    
    -- Dialog windows should float
    , isDialog                        --> doFloat
    
    -- Fullscreen windows
    , isFullscreen                    --> doFullFloat
    ]
    <+> namedScratchpadManageHook myScratchpads

--------------------------------------------------------------------------------
-- KEYBINDINGS - Customize your keyboard shortcuts
--------------------------------------------------------------------------------
myKeys :: [(String, X ())]
myKeys =
    -- APPLICATIONS
    [ ("M-S-<Return>",   spawn myTerminal)                  -- Launch terminal
    , ("M-p",          spawn myLauncher)                     -- Application launcher
    , ("M-S-p",        spawn "rofi -show window")           -- Window switcher
--    , ("M-b",          spawn "firefox")                      -- Web browser
    , ("M-b",          spawn "vivaldi-stable")                      -- Web browser
--    , ("M-f",          spawn "thunar")                       -- File manager
    , ("M-e",          spawn "emoji-picker")                      -- Emoji picker
    
    -- WALLPAPER CONTROLS (Nitrogen-specific)
    , ("M-w",          changeWallpaper)                     -- Change wallpaper for current workspace
    , ("M-S-w",        spawn "nitrogen --restore")         -- Restore nitrogen database (all wallpapers)
    , ("M-<F5>",       cycleWallpaperNext)                  -- Next wallpaper for current workspace
    , ("M-<F4>",       spawn "nitrogen --show-hide")        -- Show nitrogen GUI
    
    -- SCRATCHPADS
    , ("M-s t",        namedScratchpadAction myScratchpads "terminal")
--    , ("M-s c",        namedScratchpadAction myScratchpads "calculator")
--    , ("M-s m",        namedScratchpadAction myScratchpads "mixer")
    
    -- SCREENSHOTS
    , ("M-S-s",        spawn "flameshot gui")               -- Screenshot tool				-- Like in Windows! 🥰
--    , ("<Print>",      spawn "flameshot gui")               -- Screenshot tool				-- minimax
--    , ("M-<Print>",    spawn "flameshot full -c")           -- Full screenshot to clipboard
--    , ("M-S-<Print>",  spawn "flameshot full -p ~/Pictures/Screenshots") -- Save full screenshot
--((modMask, xK_Print), spawn "maim ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png")			-- perplexity
--((modMask .|. shiftMask, xK_Print), spawn "maim -i $(xdotool getwindowfocus) ~/Pictures/screenshot-window-$(date +%Y-%m-%d_%H-%M-%S).png")
--((modMask .|. controlMask, xK_Print), spawn "maim -g $(slop -f '%x,%y %wx%h') ~/Pictures/screenshot-region-$(date +%Y-%m-%d_%H-%M-%S).png")
    , ("<Print>", spawn "maim ~/Pictures/screenshot-$(date +%Y-%m-%d_%H-%M-%S).png")
    , ("M-<Print>", spawn "maim -i $(xdotool getwindowfocus) ~/Pictures/screenshot-window-$(date +%Y-%m-%d_%H-%M-%S).png")
    , ("M-S-<Print>", spawn "maim -g $(slop -f '%x,%y %wx%h') ~/Pictures/screenshot-region-$(date +%Y-%m-%d_%H-%M-%S).png")

    
    -- SYSTEM CONTROLS
--    , ("<XF86AudioRaiseVolume>",  spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
--    , ("<XF86AudioLowerVolume>",  spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
--    , ("<XF86AudioMute>",         spawn "pactl set-sink-mute @DEFAULT_SINK@ toggle")
    , ("<XF86MonBrightnessUp>",   spawn "brightnessctl set +5%")
    , ("<XF86MonBrightnessDown>", spawn "brightnessctl set 5%-")
    
    -- WINDOW MANAGEMENT
    , ("M-q",          kill)                                 -- Close focused window
    , ("M-<Space>",    sendMessage NextLayout)              -- Cycle through layouts
--    , ("M-S-<Space>",  setLayout $ XMonad.layoutHook conf)  -- Reset layout
    , ("M-n",          refresh)                             -- Resize windows to correct size
    , ("M-<Tab>",      windows W.focusDown)                 -- Move focus to next window
    , ("M-j",          windows W.focusDown)                 -- Move focus down
    , ("M-k",          windows W.focusUp)                   -- Move focus up
    , ("M-m",          windows W.focusMaster)               -- Move focus to master
    , ("M-<Return>",   windows W.swapMaster)                -- Swap focused with master
    , ("M-S-j",        windows W.swapDown)                  -- Swap focused with next
    , ("M-S-k",        windows W.swapUp)                    -- Swap focused with previous
    , ("M-h",          sendMessage Shrink)                  -- Shrink master area
    , ("M-l",          sendMessage Expand)                  -- Expand master area
    , ("M-t",          withFocused $ windows . W.sink)      -- Push window back to tiling
    , ("M-,",          sendMessage (IncMasterN 1))          -- Increment # windows in master
    , ("M-.",          sendMessage (IncMasterN (-1)))       -- Decrement # windows in master
    
    -- ADVANCED WINDOW MANAGEMENT
    , ("M-S-f",        sendMessage $ XMonad.Layout.MultiToggle.Toggle NBFULL)         -- Toggle fullscreen
    , ("M-g",          goToSelected def)                    -- Grid select windows
    , ("M-S-a",        killAll)                             -- Kill all windows on workspace
    
    -- WORKSPACE NAVIGATION
    , ("M-<Right>",    nextWS)                              -- Next workspace
    , ("M-<Left>",     prevWS)                              -- Previous workspace
    , ("M-S-<Right>",  shiftToNext >> nextWS)               -- Move window to next workspace
    , ("M-S-<Left>",   shiftToPrev >> prevWS)               -- Move window to prev workspace
    
    -- XMONAD CONTROLS
    , ("M-S-c",        io exitSuccess)                      -- Quit xmonad
    , ("M-S-r",        spawn "xmonad --recompile; xmonad --restart") -- Recompile & restart
    , ("M-S-l",        spawn "i3lock -c 000000")            -- Lock screen
    , ("M-S-q",        spawn "rofi -show power-menu -modi power-menu:rofi-power-menu") -- Power menu
    ]

--------------------------------------------------------------------------------
-- WALLPAPER MANAGEMENT FUNCTIONS (Nitrogen-based)
--------------------------------------------------------------------------------
changeWallpaper :: X ()
changeWallpaper = do
    ws <- gets windowset
    let currentWorkspace = W.currentTag ws
    -- Use nitrogen to show file picker for this workspace
    spawn $ "nitrogen --set-scaled --save " ++ wallpaperDir ++ "/" ++ currentWorkspace ++ ".jpeg"
    spawn (wallpaperCommand currentWorkspace)

cycleWallpaperNext :: X ()
cycleWallpaperNext = do
    ws <- gets windowset
    let currentWorkspace = W.currentTag ws
    -- Random wallpaper selection
    spawn $ "find " ++ wallpaperDir ++ " -name '*.jpeg' -o -name '*.jpg' -o -name '*.png' | shuf -n 1 | xargs nitrogen --set-scaled --save"

--------------------------------------------------------------------------------
-- MOUSE BINDINGS - Mouse button actions
--------------------------------------------------------------------------------
myMouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList
    -- Set window to floating mode and move by dragging
    [ ((modm, button1), \w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster)
    
    -- Raise window to top of stack
    , ((modm, button2), \w -> focus w >> windows W.shiftMaster)
    
    -- Set window to floating mode and resize by dragging
    , ((modm, button3), \w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster)
    ]

--------------------------------------------------------------------------------
-- XMOBAR CONFIGURATION - Status bar integration
--------------------------------------------------------------------------------
-- CHOICE 6: Status Bar
-- This section is for xmobar. If you prefer polybar, see Option 2 below.

myXmobarPP :: PP
myXmobarPP = def
    { ppSep             = magenta " • "
    , ppTitleSanitize   = xmobarStrip
    , ppCurrent         = wrap " " "" . xmobarBorder "Top" "#88c0d0" 2
    , ppHidden          = white . wrap " " ""
    , ppHiddenNoWindows = lowWhite . wrap " " ""
    , ppUrgent          = red . wrap (yellow "!") (yellow "!")
    , ppOrder           = \[ws, l, _, wins] -> [ws, l, wins]
    , ppExtras          = [logTitles formatFocused formatUnfocused]
    }
  where
    formatFocused   = wrap "[" "]" . cyan . ppWindow
    formatUnfocused = wrap " " " " . blue . ppWindow
    
    ppWindow :: String -> String
    ppWindow = xmobarRaw . (\w -> if null w then "untitled" else w) . shorten 30
    
    blue, lowWhite, magenta, red, white, yellow, cyan :: String -> String
    magenta  = xmobarColor "#bf616a" ""
    blue     = xmobarColor "#5e81ac" ""
    cyan     = xmobarColor "#88c0d0" ""
    white    = xmobarColor "#d8dee9" ""
    yellow   = xmobarColor "#ebcb8b" ""
    red      = xmobarColor "#bf616a" ""
    lowWhite = xmobarColor "#4c566a" ""

--------------------------------------------------------------------------------
-- MAIN - Putting it all together
--------------------------------------------------------------------------------
main :: IO ()
main = xmonad
     . ewmhFullscreen
     . ewmh
     . withEasySB (statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure myXmobarPP)) defToggleStrutsKey
     $ myConfig

myConfig = def
    { terminal           = myTerminal
    , focusFollowsMouse  = myFocusFollowsMouse
    , clickJustFocuses   = myClickJustFocuses
    , borderWidth        = myBorderWidth
    , modMask            = myModMask
    , workspaces         = myWorkspaces
--    , normalBorderColor  = myNormalBorderColor
--    , focusedBorderColor = myFocusedBorderColor
    , mouseBindings      = myMouseBindings
    , layoutHook         = myLayout
    , manageHook         = myManageHook
    , startupHook        = myStartupHook
    , logHook            = myLogHook  -- This handles wallpaper changes!
    }
    `additionalKeysP` myKeys
  where
    myLogHook :: X ()
    myLogHook = do
        -- Get current workspace and set wallpaper
        ws <- gets windowset
        let currentWorkspace = W.currentTag ws
        let wallpaperCmd = wallpaperCommand currentWorkspace
        -- Debug: Log the wallpaper command being executed
        spawn $ "echo \"Wallpaper: " ++ currentWorkspace ++ " -> " ++ wallpaperCmd ++ "\" >> /tmp/xmonad-wallpaper.log"
        spawn wallpaperCmd
        -- This runs every time the workspace state changes (most reliable!)
