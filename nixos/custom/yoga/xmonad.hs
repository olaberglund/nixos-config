{-# LANGUAGE LambdaCase #-}

import           XMonad

import           Control.Monad                     (forM_)
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
import           XMonad.Hooks.StatusBar.PP         (PP (..), filterOutWsPP,
                                                    xmobarPP)
import           XMonad.StackSet                   (RationalRect (..),
                                                    focusWindow, greedyView,
                                                    integrate', peek, screen,
                                                    screens, shift, stack,
                                                    swapMaster, tag, view,
                                                    visible, workspace)
import           XMonad.Util.EZConfig              (additionalKeys)
import           XMonad.Util.NamedScratchpad       (NamedScratchpad (..),
                                                    customFloating,
                                                    namedScratchpadAction,
                                                    namedScratchpadManageHook,
                                                    scratchpadWorkspaceTag)

import           Data.List                         (intercalate)
import           System.Directory                  (doesFileExist)
import           System.FilePath                   (FilePath, (</>))
import           System.Posix.Files                (touchFile)
import           Text.Read                         (readMaybe)
import           XMonad.Layout.Spacing             (smartSpacingWithEdge)

mySB = withEasySB (statusBarProp "xmobar /etc/nixos/nixos/custom/yoga/xmobarrc" myXmobar) hideSB
  where
    hideSB = const (modm, xK_b)
    myXmobar = filterOutWsPP [scratchpadWorkspaceTag] <$> workspaceNamesPP myXmobarPP
    myXmobarPP = xmobarPP{ppLayout = const "", ppTitle = \s -> if s == "" then "Nothing" else "Just (" <> s <> ")"}

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
        , borderWidth = 4
        , normalBorderColor = black
        , manageHook = myManageHook <+> manageHook def
        , layoutHook = smartSpacingWithEdge 5 $ layoutHook def
        , logHook = myLogHook
        }
        `additionalKeys` keybindings

keybindings :: [((KeyMask, KeySym), X ())]
keybindings =
    [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
    , ((modm, xK_Return), spawn $ myTerminal <> " -e tmux")
    , ((modm, xK_q), kill)
    , ((modm, xK_w), dwmpromote)
    , ((modm, xK_space), runOrRaiseMasterShift browser (className =? "firefox"))
    , ((modm .|. shiftMask, xK_space), spawn browser)
    , ((altMask, xK_p), spawn "hwarden")
    , ((modm, xK_p), spawn "launcher_t1")
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
    , ((altMask, xK_Shift_L), spawn toggleKbLangCmd)
    , ((modm, xK_Tab), toggleWS' [scratchpadWorkspaceTag])
    , ((modm, xK_o), nextScreen)
    , ((altMask, xK_a), swapNextScreen)
    ,
        ( (altMask, xK_r)
        , submap . Map.fromList $
            [((0, key), spawnRedshift level) | (key, level) <- zip [xK_1 .. xK_5] [1 ..]]
        )
    , ((modm .|. shiftMask, xK_o), screenBy 1 >>= screenWorkspace >>= flip whenJust (windows . shift))
    , ((0, xK_Menu), selectWindow def{cancelKey = xK_Escape} >>= (`whenJust` windows . focusWindow))
    , ((shiftMask, xK_Menu), selectWindow def >>= (`whenJust` killWindow))
    ]

-- ifEmpty :: X () -> X ()
-- ifEmpty = whenX (withWindowSet (return . isNothing . peek))

-- TODO: dim using `xrandr --output DP-X --brightness 0.2` if nothing is on it

runOrRaiseMasterShift :: String -> Query Bool -> X ()
runOrRaiseMasterShift run query = runOrRaiseAndDo run query (\wId -> whenX (elem wId <$> visibleWindows) swapNextScreen >> windows swapMaster)
  where
    visibleWindows :: X [Window]
    visibleWindows = withWindowSet (return . concatMap (integrate' . stack . workspace) . visible)

toggleKbLangCmd :: String
toggleKbLangCmd = "(setxkbmap -query | grep -q \"layout:\\s\\+us\") && setxkbmap se || setxkbmap us; xmodmap /home/ola/.Xmodmap"

scratchpads :: [NamedScratchpad]
scratchpads =
    [ NS "terminal" spawnTerm findTerm (scratchpadCentered 0.5 0.5)
    , NS spotify spotify (className =? "Spotify") (scratchpadCentered 0.8 0.8)
    ]
  where
    spawnTerm = myTerminal <> " -n scratchpad"
    findTerm = resource =? "scratchpad"

myManageHook :: ManageHook
myManageHook = composeAll [namedScratchpadManageHook scratchpads]

scratchpadCentered :: Rational -> Rational -> ManageHook
scratchpadCentered height width = customFloating $ RationalRect l t width height
  where
    t = 0.5 - height / 2
    l = 0.5 - width / 2

withRsCache :: (FilePath -> IO a) -> X a
withRsCache action = do
    cd <- asks (cacheDir . directories)
    let filename = (cd </> "redshift-level")
    catchIO (touchFile filename)
    io (action filename)

myLogHook :: X ()
myLogHook = do
    rsLevel <- readMaybe <$> withRsCache readFile
    forM_ rsLevel spawnRedshift

spawnRedshift :: Int -> X ()
spawnRedshift level = do
    withRsCache (`writeFile` (show level))
    withWindowSet
        ( mapM_
            ( \s ->
                let nbrWindows = length . integrate' . stack . workspace $ s
                 in if nbrWindows == 0
                        then spawn (redshiftCmd (darken (screen s)) level)
                        else spawn (redshiftCmd (lighten (screen s)) level)
            )
            . screens
        )
  where
    darken (S 1) = ["-m", "randr:crtc=1", "-b", "0.3"]
    darken (S 0) = ["-m", "randr:crtc=0", "-b", "0.3"]
    darken _     = []

    lighten (S 1) = ["-m", "randr:crtc=1", "-b", "1"]
    lighten (S 0) = ["-m", "randr:crtc=0", "-b", "1"]
    lighten _     = []

redshiftCmd :: [String] -> Int -> String
redshiftCmd params level =
    "redshift "
        <> intercalate " " params
        <> " -PO "
        <> show (1000 * (6 - level))
        <> " /dev/null 2>&1"
