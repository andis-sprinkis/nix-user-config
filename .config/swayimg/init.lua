local S = swayimg
local g = S.gallery
local gk = g.on_key
local imglist = S.imagelist
local set_title = S.set_title
local s = S.slideshow
local text = S.text
local v = S.viewer
local vk = v.on_key

S.enable_overlay(false)
S.enable_decoration(true)
S.set_dnd_button('MouseExtra')
imglist.enable_adjacent(true)
text.hide()
text.set_size(16)
v.set_default_scale('optimal')

--

g.on_image_change(
  function()
    local img = g.get_image()

    set_title(img.path .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

v.on_image_change(
  function()
    local img = v.get_image()

    set_title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

s.on_image_change(
  function()
    local img = s.get_image()

    set_title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

--

g.bind_reset()
v.bind_reset()
s.bind_reset()

gk('Return', function () end)
gk('h', function () end)
gk('j', function () end)
gk('k', function () end)
gk('l', function () end)
gk('n', function () end)
gk('p', function () end)
gk('g', function () end)
gk('Shift+g', function () end)
gk('Escape', function () end)
gk('q', function () end)

vk('Return', function () end)
vk('h', function () end)
vk('j', function () end)
vk('k', function () end)
vk('l', function () end)
vk('n', function () end)
vk('p', function () end)
vk('g', function () end)
vk('Shift+g', function () end)
vk('Escape', function () end)
vk('q', function () end)
