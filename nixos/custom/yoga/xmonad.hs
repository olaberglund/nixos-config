{-# LANGUAGE LambdaCase #-}

import           XMonad

import           Control.Monad                     (forM_)
import qualified Data.Map                          as Map
import           Data.Maybe                        (isNothing)
import           XMonad.Actions.CycleWS            (nextScreen, prevScreen,
                                                    screenBy, swapNextScreen,
                                                    swapPrevScreen, toggleWS')
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
import           XMonad.Hooks.DynamicLog           (shorten, wrap, xmobarProp)
import           XMonad.Hooks.EwmhDesktops         (ewmh, ewmhFullscreen)
import           XMonad.Hooks.ManageDocks          (docks)
import           XMonad.Hooks.StatusBar            (statusBarProp, withEasySB)
import           XMonad.Hooks.StatusBar.PP         (PP (..), filterOutWsPP,
                                                    xmobarColor, xmobarFont,
                                                    xmobarPP)
import           XMonad.Layout.NoBorders           (Ambiguity (..), lessBorders,
                                                    noBorders)
import           XMonad.Layout.Spacing             (smartSpacingWithEdge)
import           XMonad.StackSet                   (RationalRect (..),
                                                    focusWindow, greedyView,
                                                    integrate', peek, screen,
                                                    screens, shift, stack,
                                                    swapMaster, tag, view,
                                                    visible, workspace)
import           XMonad.Util.EZConfig              (additionalKeys,
                                                    additionalMouseBindings)
import           XMonad.Util.NamedScratchpad       (NamedScratchpad (..),
                                                    customFloating,
                                                    namedScratchpadAction,
                                                    namedScratchpadManageHook,
                                                    scratchpadWorkspaceTag)

import           Data.List                         (intercalate)
import           Data.Time
import           System.Directory                  (doesFileExist)
import           System.FilePath                   (FilePath, (</>))
import           System.Posix.Files                (touchFile)
import           Text.Read                         (readMaybe)

mySB = withEasySB (statusBarProp "xmobar" myXmobar) hideSB
  where
    hideSB = const (modm, xK_b)
    myXmobar = filterOutWsPP [scratchpadWorkspaceTag] <$> workspaceNamesPP myXmobarPP
    myXmobarPP =
        xmobarPP
            { ppLayout = const ""
            , ppTitle = \case
                "" -> xmobarColor "#a882f6" "" "Nothing"
                s -> xmobarColor "#a882f6" "" "Just " <> "(" <> shorten 40 s <> ")"
            , ppCurrent = xmobarFont 2 . currentIcon
            , ppVisible = xmobarFont 2 . visibleIcon
            , ppHidden = xmobarFont 2 . hiddenIcon
            }

currentIcon :: String -> String
currentIcon = \case
    "1" -> "\xf03a5"
    "2" -> "\xf03a8"
    "3" -> "\xf03ab"
    "4" -> "\xf03b2"
    "5" -> "\xf03af"
    "6" -> "\xf03b4"
    "7" -> "\xf03b7"
    "8" -> "\xf03ba"
    "9" -> "\xf03bd"
    s -> s

visibleIcon :: String -> String
visibleIcon = \case
    "1" -> "\xf03a6"
    "2" -> "\xf03a9"
    "3" -> "\xf03ac"
    "4" -> "\xf03ae"
    "5" -> "\xf03b0"
    "6" -> "\xf03b5"
    "7" -> "\xf03b8"
    "8" -> "\xf03bb"
    "9" -> "\xf03be"
    s -> s

hiddenIcon :: String -> String
hiddenIcon = \case
    "1" -> "\xf0b3a"
    "2" -> "\xf0b3b"
    "3" -> "\xf0b3c"
    "4" -> "\xf0b3d"
    "5" -> "\xf0b3e"
    "6" -> "\xf0b3f"
    "7" -> "\xf0b40"
    "8" -> "\xf0b41"
    "9" -> "\xf0b42"
    s -> s

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
        , borderWidth = 2
        , normalBorderColor = black
        , manageHook = myManageHook <+> manageHook def
        , layoutHook = smartSpacingWithEdge 5 $ layoutHook def
        , logHook = myLogHook
        }
        `additionalKeys` keybindings
        `additionalMouseBindings` mousebindings

keybindings :: [((KeyMask, KeySym), X ())]
keybindings =
    [ ((modm .|. shiftMask, xK_Return), spawn myTerminal)
    , ((modm, xK_Return), spawn $ myTerminal <> " -e tmux")
    , ((modm, xK_q), kill)
    , ((modm, xK_w), dwmpromote)
    , -- , ((modm, xK_space), runOrRaiseMasterShift browser (className =? "firefox"))
      ((modm, xK_space), spawn browser)
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
    , ((modm, xK_i), nextScreen)
    , ((modm, xK_o), prevScreen)
    , ((altMask, xK_a), swapNextScreen)
    , ((altMask, xK_s), swapPrevScreen)
    ,
        ( (altMask, xK_r)
        , submap . Map.fromList $
            [((0, key), adjustLight level) | (key, level) <- zip [xK_1 .. xK_5] [1 ..]]
        )
    , ((modm .|. shiftMask, xK_i), screenBy 1 >>= screenWorkspace >>= flip whenJust (windows . shift))
    , ((modm .|. shiftMask, xK_o), screenBy (-1) >>= screenWorkspace >>= flip whenJust (windows . shift))
    , ((0, xK_Menu), selectWindow def{cancelKey = xK_Escape} >>= (`whenJust` windows . focusWindow))
    , ((shiftMask, xK_Menu), selectWindow def >>= (`whenJust` killWindow))
    ]
        ++
        -- mod-[1..9] %! Switch to workspace N
        -- mod-shift-[1..9] %! Move client to workspace N
        [ ((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (workspaces myConfig) [xK_1 .. xK_9]
        , (f, m) <- [(view, 0), (shift, shiftMask)]
        ]

mousebindings :: [((ButtonMask, Button), Window -> X ())]
mousebindings = [((altMask, button1), const $ spawn "find-cursor --color white --follow")]

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
myManageHook =
    composeAll
        [ className =? "Pavucontrol" --> doFloat
        , namedScratchpadManageHook scratchpads
        ]

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
    forM_ rsLevel adjustLight

adjustLight :: Int -> X ()
adjustLight level = do
    withRsCache (`writeFile` (show level))
    t <- io $ localTimeOfDay .: utcToLocalTime <$> getCurrentTimeZone <*> getCurrentTime
    let time = (todHour t, todMin t)
    withWindowSet
        ( mapM_
            ( \s ->
                let nbrWindows = length . integrate' . stack . workspace $ s
                 in if nbrWindows == 0
                        then spawn (redshiftCmd (darken (screen s) time) level)
                        else spawn (redshiftCmd (lighten (screen s)) level)
            )
            . screens
        )
  where
    darken (S n) t = ["-m", "randr:crtc=" <> show n, "-b", darkShade t]
    darken _ _     = []

    darkShade (h, m) =
        show $
            if h > startHour
                then 1 - (0.7 * min 1 (fromIntegral diff / fromIntegral duration))
                else 1
      where
        startHour = 15
        duration = 6 * 60
        diff = abs (startHour * 60 - (h * 60 + m))

    lighten (S n) = ["-m", "randr:crtc=" <> show n, "-b", "1"]
    lighten _     = []

redshiftCmd :: [String] -> Int -> String
redshiftCmd params level =
    "redshift "
        <> intercalate " " params
        <> " -PO "
        <> show (1000 * (6 - level))
        <> " /dev/null 2>&1"

(.:) :: (c -> d) -> (a -> b -> c) -> a -> b -> d
(.:) = (.) . (.)
