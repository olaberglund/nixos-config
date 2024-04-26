import XMonad

import XMonad.Hooks.StatusBar (withEasySB, statusBarProp)
import XMonad.Hooks.StatusBar.PP (xmobarPP, def, sjanssenPP)
import XMonad.Hooks.DynamicLog (xmobarProp)
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Actions.DwmPromote (dwmpromote)
import XMonad.Hooks.ManageDocks (docks)
import XMonad.Actions.FindEmptyWorkspace (viewEmptyWorkspace)
import XMonad.Actions.WorkspaceNames (renameWorkspace)
import XMonad.Hooks.EwmhDesktops (ewmhFullscreen, ewmh)

mySB = withEasySB (statusBarProp "xmobar" (pure xmobarPP)) hideSB  
    where
        hideSB = const (mod1Mask, xK_b)

main = xmonad
    . mySB
    $ myConfig

modm = mod4Mask
myTerminal = "st"

myConfig = def {
      terminal = myTerminal
    , modMask = modm
    , focusedBorderColor = "#7d7d7d"
    , normalBorderColor = "#000"
} `additionalKeys` keybindings

keybindings :: [((KeyMask, KeySym), X ())]
keybindings = [
      ((modm  .|. shiftMask, xK_Return), spawn myTerminal)
    , ((modm, xK_Return), spawn $ myTerminal <> " -e tmux")
    , ((modm, xK_q), kill)
    , ((modm, xK_w), dwmpromote)
    , ((modm, xK_space), spawn "firefox")
    , ((modm, xK_r), renameWorkspace def)
    , ((modm, xK_e), viewEmptyWorkspace)
    ]



