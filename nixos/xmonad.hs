import XMonad

import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace)
import XMonad.Actions.WithAll (sinkAll)
import XMonad.Actions.WorkspaceNames (renameWorkspace)
import XMonad.Hooks.DynamicLog (xmobarProp)
import XMonad.Hooks.EwmhDesktops (ewmh, ewmhFullscreen)
import XMonad.Hooks.ManageDocks (docks)
import XMonad.Hooks.StatusBar (statusBarProp, withEasySB)
import XMonad.Hooks.StatusBar.PP (def, sjanssenPP, xmobarPP)
import XMonad.Util.EZConfig (additionalKeys)

mySB = withEasySB (statusBarProp "xmobar /etc/nixos/nixos/xmobarrc" (pure xmobarPP)) hideSB
 where
  hideSB = const (modm, xK_b)

main =
  xmonad
    . mySB
    $ myConfig

modm = mod4Mask
myTerminal = "st"

myConfig =
  def
    { terminal = myTerminal
    , modMask = modm
    , focusedBorderColor = "#7d7d7d"
    , normalBorderColor = "#000"
    }
    `additionalKeys` keybindings

keybindings :: [((KeyMask, KeySym), X ())]
keybindings =
  [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
  , ((modm, xK_Return), spawn $ myTerminal <> " -e tmux")
  , ((modm, xK_q), kill)
  , ((modm, xK_w), dwmpromote)
  , ((modm, xK_space), spawn "firefox")
  , ((modm, xK_r), renameWorkspace def)
  , ((modm, xK_e), viewEmptyWorkspace)
  , ((modm .|. shiftMask, xK_s), sinkAll)
  ]
