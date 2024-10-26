{-# LANGUAGE LambdaCase #-}

import           XMonad

import qualified Data.Map                          as Map
import           Data.Maybe                        (isNothing)
import           XMonad.Actions.CycleWS            (nextScreen, screenBy,
                                                    swapNextScreen, toggleWS')
import           XMonad.Actions.DwmPromote         (dwmpromote)
import           XMonad.Actions.EasyMotion         (EasyMotionConfig (cancelKey),
                                                    selectWindow)
import           XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace)
import           XMonad.Actions.Submap             (submap)
import           XMonad.Actions.WindowGo           (runOrRaiseAndDo,
                                                    runOrRaiseMaster)
import           XMonad.Actions.WithAll            (sinkAll)
import           XMonad.Actions.WorkspaceNames     (renameWorkspace,
                                                    workspaceNamesPP)
import           XMonad.Config.Prime               (Query)
import           XMonad.Hooks.DynamicLog           (xmobarProp)
import           XMonad.Hooks.EwmhDesktops         (ewmh, ewmhFullscreen)
import           XMonad.Hooks.ManageDocks          (docks)
import           XMonad.Hooks.StatusBar            (statusBarProp, withEasySB)
import           XMonad.Hooks.StatusBar.PP         (filterOutWsPP, xmobarPP)
import           XMonad.StackSet                   (RationalRect (..),
                                                    focusWindow, greedyView,
                                                    integrate', peek, shift,
                                                    stack, swapMaster, tag,
                                                    view, visible, workspace)
import           XMonad.Util.EZConfig              (additionalKeys)
import           XMonad.Util.NamedScratchpad       (NamedScratchpad (..),
                                                    customFloating,
                                                    namedScratchpadAction,
                                                    namedScratchpadManageHook,
                                                    scratchpadWorkspaceTag)

mySB = withEasySB (statusBarProp "xmobar /etc/nixos/nixos/custom/latitude/xmobarrc" myXmobarPP) hideSB
  where
    hideSB = const (modm, xK_b)
    myXmobarPP = filterOutWsPP [scratchpadWorkspaceTag] <$> workspaceNamesPP xmobarPP

main :: IO ()
main =
    xmonad
        . mySB
        $ myConfig

modm = mod4Mask
altMask = mod1Mask

myTerminal = "st"
browser = "firefox"
spotify = "spotify"
lightGray = "#7d7d7d"
black = "#000"

myConfig =
    def
        { terminal = myTerminal
        , modMask = modm
        , focusedBorderColor = lightGray
        , normalBorderColor = black
        , manageHook = myManageHook <+> manageHook def
        }
        `additionalKeys` keybindings

myManageHook :: ManageHook
myManageHook =
    composeAll
        [ className =? "Pavucontrol" --> doFloat
        , namedScratchpadManageHook scratchpads
        ]

myStartupHook :: X ()
myStartupHook = do
    spawn "sunpaper -d"

keybindings :: [((KeyMask, KeySym), X ())]
keybindings =
    [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
    , ((modm, xK_Return), spawn $ myTerminal <> " -e tmux")
    , ((modm, xK_q), kill)
    , ((modm, xK_w), dwmpromote)
    , ((modm, xK_space), runOrRaiseMasterShift browser (className =? "firefox"))
    , ((modm .|. shiftMask, xK_space), spawn browser)
    , ((modm .|. shiftMask, xK_p), spawn "bwm")
    , ((modm, xK_e), viewEmptyWorkspace)
    , ((modm .|. shiftMask, xK_s), sinkAll)
    , ((modm, 0xa7), namedScratchpadAction scratchpads "terminal")
    , ((modm, 0x60), namedScratchpadAction scratchpads "terminal")
    , ((modm, xK_s), namedScratchpadAction scratchpads spotify)
    , ((noModMask, xK_Print), spawn "flameshot gui")
    , ((noModMask, 0x1008FF11), spawn "pamixer --allow-boost -d 2") -- decrease master volume
    , ((noModMask, 0x1008FF13), spawn "pamixer --allow-boost -i 2") -- increase music volume
    , ((noModMask, 0x1008FF12), spawn "pamixer -t") -- mute music; 0 to tap mult. media key w/o super
    , ((noModMask, 0x1008FF14), spawn "playerctl play-pause") -- increase music volume
    , ((noModMask, 0x1008FF16), spawn "playerctl previous") -- increase music volume
    , ((noModMask, 0x1008FF17), spawn "playerctl next") -- increase music volume
    , ((noModMask, 0x1008FF02), spawn "xbacklight -inc 5")
    , ((noModMask, 0x1008FF03), spawn "xbacklight -dec 5")
    , ((altMask, xK_Shift_L), spawn toggleKbLangCmd)
    , ((modm, xK_Tab), toggleWS' [scratchpadWorkspaceTag])
    , ((modm, xK_o), nextScreen)
    , ((altMask, xK_a), swapNextScreen)
    ,
        ( (altMask, xK_r)
        , submap . Map.fromList $
            [((0, key), spawn (redshiftCmd level)) | (key, level) <- zip [xK_1 .. xK_5] [1 ..]]
        )
    , ((modm .|. shiftMask, xK_o), screenBy 1 >>= screenWorkspace >>= flip whenJust (windows . shift))
    , ((0, xK_Menu), selectWindow def{cancelKey = xK_Escape} >>= (`whenJust` windows . focusWindow))
    , ((shiftMask, xK_Menu), selectWindow def >>= (`whenJust` killWindow))
    ]

-- ifEmpty :: X () -> X ()
-- ifEmpty = whenX (withWindowSet (return . isNothing . peek))

runOrRaiseMasterShift :: String -> Query Bool -> X ()
runOrRaiseMasterShift run query = runOrRaiseAndDo run query (\wId -> whenX (elem wId <$> visibleWindows) swapNextScreen >> windows swapMaster)
  where
    visibleWindows :: X [Window]
    visibleWindows = withWindowSet (return . concatMap (integrate' . stack . workspace) . visible)

redshiftCmd :: Int -> String
redshiftCmd level = "redshift -PO " <> show (1000 * (6 - level)) <> " /dev/null 2>&1"

toggleKbLangCmd :: String
toggleKbLangCmd = "(setxkbmap -query | grep -q \"layout:\\s\\+us\") && setxkbmap se || setxkbmap us; xmodmap /home/ola/.Xmodmap"

scratchpads :: [NamedScratchpad]
scratchpads =
    [ NS "terminal" spawnTerm findTerm (scratchpadCentered 0.7 0.7)
    , NS spotify spotify (className =? "Spotify") (scratchpadCentered 0.8 0.8)
    ]
  where
    spawnTerm = myTerminal <> " -n scratchpad"
    findTerm = resource =? "scratchpad"

scratchpadCentered :: Rational -> Rational -> ManageHook
scratchpadCentered height width = customFloating $ RationalRect l t width height
  where
    t = 0.5 - height / 2
    l = 0.5 - width / 2
