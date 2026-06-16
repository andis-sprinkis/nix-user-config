// ==UserScript==
// @name        Select link text
// @namespace   https://sprinkis.com
// @match       *://*/*
// @grant       none
// @version     0.1.0
// @copyright   Licensed under the MIT License. This script is a code fork of the Firefox add-on "Select Link Text" authored by Dzianis Rusak - https://addons.mozilla.org/en-US/firefox/addon/select-link-text/
// @author      Andis Spriņķis
// @description Automatically enables Picture-in-Picture (PiP) for all web videos.
// @downloadURL https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/userscripts/select_link_text.user.js
// @updateURL   https://github.com/andis-sprinkis/nix-user-config/raw/master/.local/share/userscripts/select_link_text.user.js
// ==/UserScript==

/**********************************************************************************\

  Copyright (c) 2014-2015 Dzianis Rusak
  Copyright (c) 2026- Andis Spriņķis

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

\**********************************************************************************/

if (window.SelectLinkText !== undefined) {
  window.SelectLinkText.uninit();
}

window.SelectLinkText = (function SelectLinkText() {
  let styleElm;
  let handlers;
  let timeDown;
  let moveFired;
  let selection;
  let userSelecting;
  let needStopClick;
  let currentTarget;
  let needCreateStartSelection;
  let needDetermineUserSelection;
  const D = 3;
  const K = 1.4;
  const T = 151;
  const cursor = {};
  const topElements = [
    HTMLLIElement,
    HTMLPreElement,
    HTMLBodyElement,
    HTMLHtmlElement,
    HTMLFormElement,
    HTMLUListElement,
    HTMLOListElement,
    HTMLTableCellElement,
  ];
  const excludeElements = [HTMLInputElement, HTMLImageElement, HTMLCanvasElement, HTMLTextAreaElement];
  const unselectableElements = [HTMLAnchorElement, HTMLButtonElement];
  const dataAttr = "data-select-link-text";
  const mouseMoveMouseUpDragStartDragEnd = ["mousemove", "mouseup", "dragstart", "dragend"];
  const mouseMoveMouseUpDragStartDragEndClick = ["mousemove", "mouseup", "dragstart", "dragend", "click"];

  function stopEvent(e) {
    e.preventDefault();
    e.stopPropagation();
  }

  function bind(ev, remove) {
    const events = Array.isArray(ev) ? ev : [ev];
    for (const event of events) {
      document[`${remove ? "remove" : "add"}EventListener`](event, handlers[event], true);
    }
  }

  function unbind(ev) {
    bind(ev, true);
  }

  function getRangeFromPoint(x, y) {
    if (document.caretRangeFromPoint) {
      return document.caretRangeFromPoint(x, y);
    }
    if (document.caretPositionFromPoint) {
      const p = document.caretPositionFromPoint(x, y);
      if (p && p.offsetNode && !excludeElements.includes(p.offsetNode.constructor)) {
        const range = document.createRange();
        range.setStart(p.offsetNode, p.offset);
        return range;
      }
    }
    return undefined;
  }

  function letUserSelect(node) {
    if (node) {
      node.setAttribute(dataAttr, 1);
    } else if (currentTarget && currentTarget.node) {
      currentTarget.node.removeAttribute(dataAttr);
    }
  }

  function isNotLinkAndDraggable(node) {
    return node.constructor !== HTMLAnchorElement && node.draggable;
  }

  function hasParentAnchor(n) {
    let node = n.parentElement;
    while (node && node.constructor !== HTMLBodyElement) {
      if (node.constructor === HTMLAnchorElement) {
        return true;
      }
      node = node.parentElement;
    }
    return false;
  }

  function findUnselectableElement(node) {
    const ret = {
      node: null,
      likeUI: false,
      isAnchor: false,
    };
    let n = node;
    while (n && !topElements.includes(n.constructor)) {
      if (excludeElements.includes(n.constructor)) {
        return undefined;
      }
      if (unselectableElements.includes(n.constructor)) {
        if (n.textContent === "") {
          return undefined;
        }
        ret.node = n;
        ret.likeUI = !(ret.isAnchor = n.constructor === HTMLAnchorElement);
        return ret;
      }
      n = n.parentElement;
    }
    if (node.textContent !== "") {
      return ret;
    }
    return undefined;
  }

  function findElementToSelect(t, rightClick) {
    const target = t.nodeType === 3 ? t.parentElement : t;
    if (rightClick) {
      if (target.textContent === "") {
        return undefined;
      }
      return { node: target, forced: true };
    }
    const result = findUnselectableElement(target, rightClick);
    if (!result) {
      return undefined;
    }
    const node = result.node || target;
    if (isNotLinkAndDraggable(node)) {
      return undefined;
    }
    return {
      node,
      forced: !!result.node,
      likeUI: result.likeUI,
      isAnchor: result.isAnchor,
      hasParentAnchor: !result.isAnchor && result.node && hasParentAnchor(result.node),
    };
  }

  function resetconsts() {
    needDetermineUserSelection = needCreateStartSelection = true;
    moveFired = userSelecting = needStopClick = false;
  }

  function unbindAndDeselect(events) {
    unbind(events || mouseMoveMouseUpDragStartDragEndClick);
    letUserSelect();
    selection.removeAllRanges();
  }

  function hackHandler() {
    document.removeEventListener("mousemove", hackHandler, true);
    if (!currentTarget || isNotLinkAndDraggable(currentTarget.node)) {
      unbindAndDeselect("click");
    }
  }

  function hackLazyDraggable() {
    document.removeEventListener("mousemove", hackHandler, true);
    document.addEventListener("mousemove", hackHandler, true);
  }

  function mainMouseDownHandler(e) {
    if (e.buttons > 2) {
      return;
    }
    resetconsts();
    timeDown = e.timeStamp;
    cursor.x = e.clientX;
    cursor.y = e.clientY;
    selection = window.getSelection();
    const range = getRangeFromPoint(cursor.x, cursor.y);
    if (!selection.isCollapsed && range) {
      for (let i = 0, l = selection.rangeCount; i < l; i += 1) {
        if (selection.getRangeAt(i).isPointInRange(range.startContainer, range.startOffset)) {
          return;
        }
      }
    }
    letUserSelect();
    currentTarget = findElementToSelect(e.target, e.buttons === 2);
    if (!currentTarget) {
      return;
    }
    if (currentTarget.forced) {
      bind(mouseMoveMouseUpDragStartDragEnd);
    } else {
      bind("click");
      hackLazyDraggable();
    }
    letUserSelect(currentTarget.node);
  }

  function isCasual(e) {
    return e.timeStamp - timeDown < T && Math.abs(cursor.x - e.clientX) < 41;
  }

  function startNewSelection(e, x, y) {
    if (!e.ctrlKey) {
      selection.removeAllRanges();
    }
    const correct = x > cursor.x ? -2 : 2;
    const range = getRangeFromPoint(x + correct, y);
    if (range) {
      selection.addRange(range);
      needCreateStartSelection = false;
    }
  }

  function stopDetermining(isDragging) {
    needDetermineUserSelection = false;
    if (!isDragging) {
      needStopClick = true;
      bind("click");
    }
  }

  handlers = {
    mousemove(e) {
      moveFired = true;
      if (e.buttons < 1) {
        unbindAndDeselect();
        return;
      }
      const x = e.clientX;
      const y = e.clientY;
      if (needCreateStartSelection) {
        startNewSelection(e, x, y);
      }
      if (needDetermineUserSelection) {
        const vx = Math.abs(cursor.x - x);
        const vy = Math.abs(cursor.y - y);
        userSelecting = vy === 0 || vx / vy > K;
        if (vx > D || vy > D) {
          stopDetermining(!userSelecting);
        }
      }
      if (userSelecting) {
        const range = getRangeFromPoint(x, y - 3);
        if (range) {
          selection.extend(range.startContainer, range.startOffset);
          if (!selection.isCollapsed) {
            stopDetermining();
          }
        }
      } else if (!needDetermineUserSelection) {
        unbindAndDeselect();
      }
    },

    dragstart(e) {
      unbind("dragstart");
      if (!moveFired) {
        userSelecting = true;
        startNewSelection(e, e.clientX, e.clientY);
      }
      if (userSelecting) {
        stopEvent(e);
      }
    },

    mouseup(e) {
      unbind(mouseMoveMouseUpDragStartDragEnd);
      const anchorEnv = currentTarget.isAnchor || currentTarget.hasParentAnchor;
      if ((anchorEnv || currentTarget.likeUI) && isCasual(e)) {
        if (userSelecting && !selection.isCollapsed) {
          unbindAndDeselect("click");
        }
        return;
      }
      if (!userSelecting && needStopClick) {
        needStopClick = false;
      }
      setTimeout(() => unbind("click"), 111);
      if (selection.isCollapsed) {
        letUserSelect();
      }
      if (currentTarget.likeUI && !selection.isCollapsed && !isCasual(e)) {
        needStopClick = true;
        stopEvent(e);
      }
    },

    click(e) {
      unbind("click");
      if (selection.isCollapsed) {
        letUserSelect();
      }
      if (needStopClick || (!selection.isCollapsed && !isCasual(e) && !currentTarget.forced)) {
        stopEvent(e);
      }
    },

    dragend() {
      unbind(mouseMoveMouseUpDragStartDragEnd);
    },
  };

  return {
    init() {
      styleElm = document.createElement("style");
      document.documentElement.appendChild(styleElm);
      styleElm.sheet.insertRule(
        `[${dataAttr}],[${dataAttr}] *{-moz-user-select:text!important;user-select:text!important;outline:none!important}`,
        0,
      );
      document.addEventListener("mousedown", mainMouseDownHandler, true);
    },

    uninit() {
      document.removeEventListener("mousedown", mainMouseDownHandler, true);
      letUserSelect();
      if (styleElm) {
        styleElm.parentElement.removeChild(styleElm);
      }
      delete window.SelectLinkText;
    },
  };
})();

window.SelectLinkText.init();
