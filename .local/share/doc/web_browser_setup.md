# The web browsers setup

## Configuration

### Mozilla Firefox

- On Linux:

    ```sh
    cd "$HOME/.config/mozilla/firefox/PROFILE_ID.default-release"
    ln -s "../../../.config/firefox/user.js" "user.js"
    ln -s "../../../.config/firefox/chrome" "chrome"
    ```

- On macOS:
    ```sh
    cd "$HOME/Library/Application Support/Firefox/Profiles/PROFILE_ID.default-release"
    ln -s "../../../../../.config/firefox/user.js" "user.js"
    ln -s "../../../../../.config/firefox/chrome" "chrome"
    ```

## Addons

### Mozilla Firefox

1.  https://addons.mozilla.org/en-US/firefox/addon/accessibility-checker/
1.  https://addons.mozilla.org/en-US/firefox/addon/clearurls/
1.  https://addons.mozilla.org/en-US/firefox/addon/copy-as-markdown/
1.  https://addons.mozilla.org/en-US/firefox/addon/extension-copycat/
1.  https://addons.mozilla.org/en-US/firefox/addon/favicon-detector/
1.  https://addons.mozilla.org/en-US/firefox/addon/global-speed/
1.  https://addons.mozilla.org/en-US/firefox/addon/istilldontcareaboutcookies/
1.  https://addons.mozilla.org/en-US/firefox/addon/jump-to-anchor/
1.  https://addons.mozilla.org/en-US/firefox/addon/localcdn-fork-of-decentraleyes/
1.  https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/
1.  https://addons.mozilla.org/en-US/firefox/addon/react-devtools/
1.  https://addons.mozilla.org/en-US/firefox/addon/scroll-zoom/
1.  https://addons.mozilla.org/en-US/firefox/addon/search_by_image/
1.  https://addons.mozilla.org/en-US/firefox/addon/sponsorblock/
1.  https://addons.mozilla.org/en-US/firefox/addon/stop-autoplay-next-for-youtube/
1.  https://addons.mozilla.org/en-US/firefox/addon/styl-us/
1.  https://addons.mozilla.org/en-US/firefox/addon/toggle-dark-mode/
1.  https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/
1.  https://addons.mozilla.org/en-US/firefox/addon/undoclosetabbutton
1.  https://addons.mozilla.org/en-US/firefox/addon/view-page-archive/
1.  https://addons.mozilla.org/en-US/firefox/addon/violentmonkey/
1.  https://addons.mozilla.org/en-US/firefox/addon/webpage-extractor/
1.  https://addons.mozilla.org/en-US/firefox/addon/youtube-recommended-videos/

#### _Firefox Multi-Account Containers_

Follow [Configuring _Firefox Multi-Account Containers_ for session isolation](./ff_addon_multiaccountcontainers.md)

### Google Chrome / Chromium

1.  https://chrome.google.com/webstore/detail/clearurls/lckanjgmijmafbedllaakclkaicjfmnk (Manifest v2)
1.  https://chrome.google.com/webstore/detail/copy-as-markdown/fkeaekngjflipcockcnpobkpbbfbhmdn
1.  https://chrome.google.com/webstore/detail/favicon-detector/jlfeffjhgmgblofcgpbgpkkhfniipejm
1.  https://chrome.google.com/webstore/detail/global-speed/jpbjcnkcffbooppibceonlgknpkniiff
1.  https://chrome.google.com/webstore/detail/i-still-dont-care-about-c/edibdbjcniadpccecjdfdjjppcpchdlm
1.  https://chrome.google.com/webstore/detail/ibm-equal-access-accessib/lkcagbfjnkomcinoddgooolagloogehp
1.  https://chrome.google.com/webstore/detail/jump-to-anchor/fhbjjkmbahpmoegppmljagmakkeomlmb
1.  https://chrome.google.com/webstore/detail/localcdn/njdfdhgcmkocbgbhcioffdbicglldapd (Manifest v2)
1.  https://chrome.google.com/webstore/detail/react-context-devtool/oddhnidmicpefilikhgeagedibnefkcf
1.  https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi
1.  https://chrome.google.com/webstore/detail/redux-devtools/lmhkpmbekcpmknklioeibfkpmmfibljd
1.  https://chrome.google.com/webstore/detail/scroll-zoom/ccfomhdaagemnbhbpminjoggkbglmcgb
1.  https://chrome.google.com/webstore/detail/search-by-image/cnojnbdhbhnkbcieeekonklommdnndci
1.  https://chrome.google.com/webstore/detail/sponsorblock-for-youtube/mnjggcdmjocbbbhaepdhchncahnbgone
1.  https://chrome.google.com/webstore/detail/stop-autoplay-next-for-yo/bhnhbmjfaanopkalgkjoiemhekdnhanh
1.  https://chrome.google.com/webstore/detail/stylus/clngdbkpkpeebahjckkjfobafhncgmne (Manifest v2)
1.  https://chrome.google.com/webstore/detail/unhook-remove-youtube-rec/khncfooichmfjbepaaaebmommgaepoid
1.  https://chrome.google.com/webstore/detail/violentmonkey/jinjaccalgkegednnccohejagnlnfdag
1.  https://chromewebstore.google.com/detail/ublock-origin-lite/ddkjiahejlhfcafbddmgiahcphecmpfh

## Search engines

```
ArchWiki
https://wiki.archlinux.org/index.php?search=%s
aw
```

```
Brave
https://search.brave.com/search?q=%s
bw
```

```
DuckDuckGo Lite
https://lite.duckduckgo.com/lite?q=%s
ddg
```

```
Google (EN)
https://www.google.com/search?q=%s
gg
```

```
Google Images
https://www.google.com/search?udm=2&q=%s
gi
```

```
GitHub
https://github.com/search?q=%s&type=repositories
gh
```

```
Mojeek
https://www.mojeek.com/search?q=%s
mjk
```

```
Mozilla Developer Network
https://developer.mozilla.org/en-US/search?q=%s
mdn
```

```
Yandex Images
https://yandex.com/images/search?text=%s
yi
```

```
YouTube
https://www.youtube.com/results?search_query=%s
yt
```

```
Wikipedia (EN)
https://en.wikipedia.org/w/index.php?search=%s
wen
```

```
Wikipedia (LV)
https://lv.wikipedia.org/w/index.php?search=%s
wlv
```

## Usersripts

1.  https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/userscripts/sscom_sslv_gmaps_link.user.js
1.  https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/userscripts/select_link_text.user.js
1.  https://github.com/fznhq/userscript-collection/raw/main/Redirect_Youtube_Shorts.user.js

## Userstyles

1.  https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/userstyles/lazy_dark_mode.user.css
