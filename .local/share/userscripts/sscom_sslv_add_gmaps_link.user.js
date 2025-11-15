// ==UserScript==
// @name        ss.com, ss.lv Google Maps link
// @namespace   https://sprinkis.com
// @match       https://www.ss.com/*
// @match       https://www.ss.lv/*
// @grant       none
// @run-at      document-end
// @version     0.1.0
// @author      Andis Spriņķis
// @description Display the Google Maps location link in the ss.com, ss.lv listings
// ==/UserScript==

const mapLinkElement = document.getElementById("mnu_map");

if (!mapLinkElement) return;

const onClickAttr = mapLinkElement.getAttribute("onclick");

if (!onClickAttr) return;

const latLonMatch = onClickAttr.match(/c=(-?\d+\.\d+),\s?(-?\d+.\d+),\s?\d+'\)/);

if (!latLonMatch) return;

const lat = latLonMatch[1];
const lon = latLonMatch[2];

if (!lat.length && !lon.length) return;

const urlGmaps = `https://www.google.com/maps?t=k&q=loc:${lat}+${lon}`;

// Does not insert the map pinpoint: `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`

mapLinkElement.parentElement.insertAdjacentHTML(
  "afterend",
  ` <span class="td15">[<a href="${urlGmaps}" class="ads_opt_link_map" target="blank" rel="noreferrer">Google Maps</a>]</span>`,
);
