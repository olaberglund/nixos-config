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
import XMonad.StackSet (RationalRect (..))
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Util.NamedScratchpad (NamedScratchpad (..), customFloating, namedScratchpadAction, namedScratchpadManageHook)

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
    , manageHook = myManageHook <+> manageHook def
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
  , ((modm, 0xa7), namedScratchpadAction scratchpads "terminal")
  , ((modm, 0x60), namedScratchpadAction scratchpads "terminal")
  , ((0, xK_Print), spawn "flameshot gui")
  , ((0, 0x1008FF11), spawn "pamixer --allow-boost -d 2") -- decrease master volume
  , ((0, 0x1008FF13), spawn "pamixer --allow-boost -i 2") -- increase music volume
  , ((0, 0x1008FF12), spawn "pamixer -t") -- mute music; 0 to tap mult. media key w/o super
  , ((0, 0x1008FF14), spawn "playerctl play-pause") -- increase music volume
  , ((0, 0x1008FF16), spawn "playerctl previous") -- increase music volume
  , ((0, 0x1008FF17), spawn "playerctl next") -- increase music volume
  , ((mod1Mask, xK_q), spawn "rs 1")
  , ((mod1Mask, xK_w), spawn "rs 2")
  , ((mod1Mask, xK_e), spawn "rs 3")
  , ((mod1Mask, xK_r), spawn "rs 4")
  , ((mod1Mask, xK_t), spawn "rs 5")
  , ((mod1Mask, xK_space), spawn "(setxkbmap -query | grep -q \"layout:\\s\\+us\") && setxkbmap se || setxkbmap us; xmodmap /home/ola/.Xmodmap")
  ]

scratchpads :: [NamedScratchpad]
scratchpads =
  [NS "terminal" spawnTerm findTerm scratchpadFloat]
 where
  spawnTerm = myTerminal ++ " -n scratchpad"
  findTerm = resource =? "scratchpad"

myManageHook :: ManageHook
myManageHook = composeAll [namedScratchpadManageHook scratchpads]

scratchpadFloat :: ManageHook
scratchpadFloat = customFloating $ RationalRect l t w h
 where
  h = 0.6
  w = 0.6
  t = 0.5 - h / 2
  l = 0.5 - w / 2
