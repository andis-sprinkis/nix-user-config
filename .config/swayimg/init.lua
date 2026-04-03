local S = swayimg
local g = S.gallery
local bg = g.on_key
local imglist = S.imagelist
local title = S.set_title
local s = S.slideshow
local txt = S.text
local v = S.viewer
local bv = v.on_key

S.enable_overlay(false)
S.enable_decoration(true)
S.set_dnd_button('MouseExtra')
v.set_default_scale('fit')
imglist.enable_adjacent(true)
txt.hide()
txt.set_size(16)

--

g.on_image_change(
  function()
    local img = g.get_image()

    title(img.path .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

v.on_image_change(
  function()
    local img = v.get_image()

    title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

s.on_image_change(
  function()
    local img = s.get_image()

    title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imglist.size() .. "]")
  end
)

---

S.on_window_resize(
  function() if (S.get_mode() == 'viewer') then v.set_fix_scale("fit") end end
)

--

g.bind_reset()
v.bind_reset()
s.bind_reset()

bg('Return', function() S.set_mode("viewer") end)
bg('h', function() g.switch_image("left") end)
bg('j', function() g.switch_image("down") end)
bg('k', function() g.switch_image("up") end)
bg('l', function() g.switch_image("right") end)
bg('n', function() g.switch_image("pgdown") end)
bg('p', function() g.switch_image("pgup") end)
bg('g', function() g.switch_image("first") end)
bg('Shift+g', function() g.switch_image("last") end)
bg('Escape', function() S.exit() end)
bg('q', function() S.exit() end)

bv('Return', function() S.set_mode("gallery") end)
bv('h', function() end)
bv('j', function() end)
bv('k', function() end)
bv('l', function() end)
bv('n', function() v.switch_image("next") end)
bv('p', function() v.switch_image("prev") end)
bv('g', function() v.switch_image("first") end)
bv('Shift+g', function() v.switch_image("last") end)
bv('Escape', function() S.exit() end)
bv('q', function() S.exit() end)
