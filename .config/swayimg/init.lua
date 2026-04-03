local S = swayimg
local g = S.gallery
local bg = g.on_key
local mg = g.on_mouse
local imglist = S.imagelist
local title = S.set_title
local s = S.slideshow
local txt = S.text
local v = S.viewer
local bv = v.on_key
local mv = v.on_mouse

S.enable_decoration(true)
S.enable_overlay(false)
S.set_dnd_button('MouseExtra')
g.enable_pstore(true)
g.limit_cache(2048)
g.set_aspect('fit')
g.set_border_size(8)
g.set_padding_size(16)
g.set_selected_scale(1.4)
g.set_thumb_size(180)
imglist.enable_adjacent(true)
txt.hide()
txt.set_size(16)
v.enable_loop(false)
v.limit_preload(3)
v.set_default_scale('fit')

local function vtitle()
  local img = v.get_image()

  title(
    "[" .. img.index .. "/" .. imglist.size() .. "]" ..
    " " ..
    img.path ..
    " " ..
    "[" .. math.floor(v.get_scale() * 100) .. "%" .. "]" ..
    " " ..
    "[" .. img.width .. "x" .. img.height .. "]"
  )
end

local function gtitle()
  local img = g.get_image()

  title(
    "[" .. img.index .. "/" .. imglist.size() .. "]" ..
    " " ..
    img.path
  )
end

g.on_image_change(gtitle)
v.on_image_change(vtitle)

S.on_window_resize(
  function()
    if (S.get_mode() == 'viewer') then
      v.set_fix_scale("fit")
      vtitle()
    end
  end
)

g.bind_reset()
v.bind_reset()
s.bind_reset()

bg('Return', function() S.set_mode("viewer") end)
bg('Space', function() S.set_mode("viewer") end)
bg('Shift+space', function() S.set_mode("viewer") end)
bg('h', function() g.switch_image("left") end)
bg('j', function() g.switch_image("down") end)
bg('k', function() g.switch_image("up") end)
bg('l', function() g.switch_image("right") end)
bg('Left', function() g.switch_image("left") end)
bg('Down', function() g.switch_image("down") end)
bg('Up', function() g.switch_image("up") end)
bg('Right', function() g.switch_image("right") end)
bg('n', function() g.switch_image("pgdown") end)
bg('p', function() g.switch_image("pgup") end)
bg('g', function() g.switch_image("first") end)
bg('Shift+g', function() g.switch_image("last") end)
bg('f', function() S.toggle_fullscreen() end)
bg('Escape', function() S.exit() end)
bg('q', function() S.exit() end)
bg('i', function() if txt.visible() then txt.hide() else txt.show() end end)

mg('ScrollUp', function() g.switch_image("pgup") end)
mg('ScrollDown', function() g.switch_image("pgdown") end)
mg('ScrollLeft', function() g.switch_image("pgup") end)
mg('ScrollRight', function() g.switch_image("pgdown") end)

mg('MouseLeft', function() S.set_mode("viewer") end)
mg('MouseRight', function() S.set_mode("viewer") end)

bv('Return', function() S.set_mode("gallery") end)
bv('h', function() end)
bv('j', function() end)
bv('k', function() end)
bv('l', function() end)
bv('Left', function() end)
bv('Down', function() end)
bv('Up', function() end)
bv('Right', function() end)
bv('n', function() v.switch_image("next") end)
bv('p', function() v.switch_image("prev") end)
bv('Space', function() v.switch_image("next") end)
bv('Shift+space', function() v.switch_image("prev") end)
bv('g', function() v.switch_image("first") end)
bv('Shift+r', function() v.reload() end)
bv('Shift+g', function() v.switch_image("last") end)
bv('f', function() S.toggle_fullscreen() end)
bv('Escape', function() S.exit() end)
bv('q', function() S.exit() end)
bv('i', function() if txt.visible() then txt.hide() else txt.show() end end)

mv('MouseLeft', function()
  local mcoord = S.get_mouse_pos()
  local wsize = S.get_window_size()

  v.switch_image((mcoord.x <= (wsize.width / 2)) and 'prev' or 'next')
end)

mv('ScrollUp', function() v.switch_image("prev") end)
mv('ScrollDown', function() v.switch_image("next") end)
mv('ScrollLeft', function() v.switch_image("prev") end)
mv('ScrollRight', function() v.switch_image("next") end)

mv('MouseRight', function() S.set_mode("gallery") end)
