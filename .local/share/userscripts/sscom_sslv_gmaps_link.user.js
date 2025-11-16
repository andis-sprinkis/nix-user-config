// ==UserScript==
// @name        ss.com, ss.lv maps service links
// @namespace   https://sprinkis.com
// @match       https://www.ss.com/*
// @match       https://www.ss.lv/*
// @grant       none
// @run-at      document-end
// @version     0.4.0
// @author      Andis Spriņķis
// @description Display location services links of Google Maps, Apple Maps, OpenStreetMap, BalticMaps in the ss.com, ss.lv listings.
// @downloadURL https://raw.githubusercontent.com/andis-sprinkis/nix-user-config/refs/heads/master/.local/share/userscripts/sscom_sslv_gmaps_link.user.js
// @updateURL   https://raw.githubusercontent.com/andis-sprinkis/nix-user-config/refs/heads/master/.local/share/userscripts/sscom_sslv_gmaps_link.user.js
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

  const urlGoogleMaps = `https://www.google.com/maps?t=k&q=loc:${lat}+${lon}`;
  // Does not insert the map pinpoint: `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`

  const urlOpenStreetMap = `https://www.openstreetmap.org/search?query=${lat}%2C%20${lon}`;

  const urlAppleMaps = `https://maps.apple.com/place?coordinate=${lat}%2C${lon}`;

  // "Karšu slāņi"
  // - "Ortofoto karte", "ar nosaukumiem"
  // - "Interešu punkti" (all)
  // - "Kadastra informācija"
  // - "Administratīvais iedalījums" (all)
  // Right click, "Norādes uz" ("Maršruta izveide")
  const urlBalticMaps = `https://balticmaps.eu/lv/c%5F%5F%5F${lat}-${lon}-18/w%5F%5F%5Fdriving-${lat},${lon}/bl%5F%5F%5Fpl/nosaukumi/kadastrs/admin%5Fied/q%5F%5F%5F`;

  console.info(
    `Latitude, longitude:
${lat}, ${lon}

Google Maps:
${urlGoogleMaps}

OpenStreetMap:
${urlOpenStreetMap}

Apple Maps:
${urlAppleMaps}

BalticMaps:
${urlBalticMaps}`,
  );

  const html = (strings, ...values) => String.raw({ raw: strings }, ...values);

  mapLinkElement.parentElement.insertAdjacentHTML(
    "afterend",
    html` <span class="td15"
        >[<a href="${urlGoogleMaps}" class="ads_opt_link_map" target="blank" rel="noreferrer noopener">Google Maps</a
        >]</span
      >
      <span class="td15"
        >[<a href="${urlAppleMaps}" class="ads_opt_link_map" target="blank" rel="noreferrer noopener">Apple Maps</a
        >]</span
      >
      <span class="td15"
        >[<a href="${urlOpenStreetMap}" class="ads_opt_link_map" target="blank" rel="noreferrer noopener"
          >OpenStreetMap</a
        >]</span
      >
      <span class="td15"
        >[<a href="${urlBalticMaps}" class="ads_opt_link_map" target="blank" rel="noreferrer noopener">BalticMaps</a
        >]</span
      >`,
  );
})();
