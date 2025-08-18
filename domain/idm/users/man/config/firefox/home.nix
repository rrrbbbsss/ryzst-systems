{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      nativeMessagingHosts = [ pkgs.tridactyl-native ];
    };
    policies = {
      SecurityDevices.Add = {
        "Yubikey" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
      };
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      SearchSuggestEnabled = false;
      WebsiteFilter = {
        Block = [
          "https://bsky.app/*"
          "https://mastodon.social/*"
          "https://www.reddit.com/r/NixOS/*"
          "https://github.com/rrrbbbsss/ryzst-systems/graphs/traffic"
        ];
      };
    };
    profiles.default = {
      id = 0;
      isDefault = true;
      userChrome = builtins.readFile ./userChrome.css;
      settings = {
        "browser.startup.homepage" = "https://google.com";
        "browser.newtabpage.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "extensions.pocket.enabled" = false;
        "extensions.autoDisableScopes" = 14;
        "signon.rememberSignons" = false;
        "network.IDN_show_punycode" = true;
        "geo.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "privacy.firstparty.isolate" = true;
        "privacy.resistFingerprinting" = false;
        "privacy.trackingprotection.enabled" = true;
        "browser.cache.offline.enable" = false;
        "dom.battery.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "network.trr.mode" = 5;
        "network.http.referer.XOriginPolicy" = 1;
        "dom.security.https_only_mode" = true;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.cookies" = true;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.inTitlebar" = 0;
      };
      search = {
        force = true;
        engines = {
          "bing".metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          "ebay".metaData.hidden = true;
        };
      };
      extensions.packages = with pkgs.firefox-addons; [
        ublock-origin
        tridactyl
        adsum-notabs
      ];
    };
  };

  #https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin:-configuration
  home.file.ublock = {
    source = ./ublock.json;
    target = ".mozilla/managed-storage/uBlock0@raymondhill.net.json";
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;

  xdg.mimeApps =
    let
      app = "firefox.desktop";
      mimeapps = {
        "text/html" = [ app ];
        "x-scheme-handler/http" = [ app ];
        "x-scheme-handler/https" = [ app ];
        "x-scheme-handler/chrome" = [ app ];
        "application/x-extension-htm" = [ app ];
        "application/x-extension-html" = [ app ];
        "application/x-extension-shtml" = [ app ];
        "application/xhtml+xml" = [ app ];
        "application/x-extension-xhtml" = [ app ];
        "application/x-extension-xht" = [ app ];
      };
    in
    {
      enable = true;
      associations.added = mimeapps;
      defaultApplications = mimeapps;
    };
}
