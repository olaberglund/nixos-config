{ config, pkgs, ... }:

let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in {
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "de" "en-US" ];

      # ---- POLICIES ----
      # Check about:policies#documentation for options.
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always"; # alternatives: "always" or "newtab"
        DisplayMenuBar =
          "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        # ---- EXTENSIONS ----
        # Check about:support for extension/add-on ID strings.
        # Valid strings for installation_mode are "allowed", "blocked",
        # "force_installed" and "normal_installed".
        ExtensionSettings = {
          "*".installation_mode =
            "blocked"; # blocks all addons except the ones specified below
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Dark Reader:
          "addon@darkreader.org" = {
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
          # Dark theme for firefox
          "{1afaee19-8dde-4b0e-8c84-f46ca0f02f06}" = {
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/dark-theme-for-firefox/latest.xpi";
            installation_mode = "force_installed";
          };
          # Vimium
          "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
            install_url =
              "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
            installation_mode = "force_installed";
          };
          "moz-addon-prod@7tv.app" = {
            install_url = "https://extension.7tv.gg/v3.0.9/ext.xpi";
            installation_mode = "force_installed";
          };

        };

        # ---- PREFERENCES ----
        # Check about:config for options.
        Preferences = {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          "browser.formfill.enable" = lock-false;
          "browser.search.suggest.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          "browser.privateWindowSeparation.enabled" = lock-false;
          "browser.urlbar.suggest.searches" = lock-false;
          "browser.urlbar.showSearchSuggestionsFirst" = lock-true;
          "browser.newtabpage.activity-stream.feeds.section.topstories" =
            lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" =
            lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" =
            lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" =
            lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" =
            lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" =
            lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" =
            lock-false;
        };
      };
    };
  };
}
