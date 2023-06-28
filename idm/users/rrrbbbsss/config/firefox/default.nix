{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {
      cfg = { enableTridactylNative = true; };
    };
    profiles.default = {
      id = 0;
      isDefault = true;
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
        "browser.cache.offline.enable" = false;
        "dom.battery.enabled" = false;
        "dom.event.clipboardevents.enabled" = false;
        "network.trr.mode" = 5;
        "dom.security.https_only_mode" = true;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.cookies" = true;
        "layout.css.prefers-color-scheme.content-override" = 0;
      };
      search = {
        force = true;
        engines = {
          "Bing".metaData.hidden = true;
          "Amazon.com".metaData.hidden = true;
          "eBay".metaData.hidden = true;
        };
      };
      extensions = with pkgs.firefox-addons; [
        ublock-origin
        tridactyl
      ];
    };
  };

  #https://github.com/gorhill/uBlock/wiki/Deploying-uBlock-Origin:-configuration
  home.file.ublock = {
    source = ./ublock.json;
    target = ".mozilla/managed-storage/uBlock0@raymondhill.net.json";
  };

  xdg.configFile."tridactyl/tridactylrc".source = ./tridactylrc;
}
