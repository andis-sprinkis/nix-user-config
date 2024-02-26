// ==UserScript==
// @name        Enable video Picture-in-picture (PiP)
// @namespace   https://andis.work
// @match       *://*/*
// @grant       none
// @version     0.1.0
// @copyright   Licensed under the MIT License. This script is a code fork of the Firefox add-on "Enable Picture-in-Picture" authored by Sven - https://addons.mozilla.org/en-US/firefox/addon/enable-picture-in-picture/ .
// @author      Andis Spriņķis
// @description Automatically enables Picture-in-Picture (PiP) for all web videos.
// @downloadURL https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/usersripts/enable_video_pictureinpicture.user.js
// @updateURL   https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/usersripts/enable_video_pictureinpicture.user.js
// ==/UserScript==

function adjustVideoElement(video) {
  if (video.hasAttribute("disablepictureinpicture")) {
    video.removeAttribute("disablepictureinpicture");

    setTimeout(function () {
      video.removeAttribute("disablepictureinpicture");
    }, 2000);
  }
}

const observer = new MutationObserver((mutations) => {
  mutations.forEach((mutation) => {
    if (mutation.type !== "childList") return;

    mutation.addedNodes.forEach((node) => {
      if (node.nodeName === "VIDEO") adjustVideoElement(node);
      else if (node.querySelectorAll) node.querySelectorAll("video").forEach(adjustVideoElement);
    });
  });
});

observer.observe(document.body, { childList: true, subtree: true });
