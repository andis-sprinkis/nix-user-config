// ==UserScript==
// @name        ss.com, ss.lv Google Maps link
// @namespace   https://sprinkis.com
// @match       https://www.ss.com/*
// @match       https://www.ss.lv/*
// @grant       none
// @run-at      document-end
// @version     0.2.0
// @author      Andis Spriņķis
// @description Display the Google Maps location link in the ss.com, ss.lv listings
// ==/UserScript==

(() => {
  const mapLinkElement = document.getElementById("mnu_map");

  if (!mapLinkElement) return;

  const onClickAttr = mapLinkElement.getAttribute("onclick");

  if (!onClickAttr) {
    console.error(`The map link element 'onclick' attribute to match the coordinates from is not found.`);
    return;
  }

  const latLonMatch = onClickAttr.match(/c=(-?\d+\.\d+),\s?(-?\d+.\d+),\s?\d+'\)/);

  if (latLonMatch?.length !== 3) {
    console.error(`No latitude and longitude match within the map link element 'onclick' attribute.`);
    return;
  }

  const lat = latLonMatch[1];
  const lon = latLonMatch[2];

  const urlGmaps = `https://www.google.com/maps?t=k&q=loc:${lat}+${lon}`;
  // Does not insert the map pinpoint: `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`

  console.info(
    `Latitude and longitude match:
${lat} ${lon}
Google Maps URL:
${urlGmaps}`,
  );

  const html = (strings, ...values) => String.raw({ raw: strings }, ...values);

  mapLinkElement.parentElement.insertAdjacentHTML(
    "afterend",
    html` <span class="td15"
      >[<a href="${urlGmaps}" class="ads_opt_link_map" target="blank" rel="noreferrer noopener">Google Maps</a>]</span
    >`,
  );
})();
