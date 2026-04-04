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

local thumb_size_default = 128

S.enable_decoration(true)
S.enable_overlay(false)
S.set_dnd_button('MouseExtra')
g.enable_pstore(true)
g.limit_cache(2048)
g.set_aspect('fit')
g.set_border_size(8)
g.set_padding_size(16)
g.set_selected_scale(1.4)
g.set_thumb_size(thumb_size_default)
imglist.enable_adjacent(true)
txt.hide()
txt.set_size(16)
v.enable_loop(false)
v.limit_preload(3)
v.set_default_scale('fit')
v.set_drag_button('MouseRight')

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

local function vzoomreset()
  v.reset()
  vtitle()
end

local function vzoomorig()
  v.set_fix_scale("real")
  vtitle()
end

S.on_window_resize(
  function()
    if (S.get_mode() == 'viewer') then vzoomreset() end
  end
)

g.bind_reset()
v.bind_reset()
s.bind_reset()

local function file_manager_desktop()
  local mode = S.get_mode()
  local imgpath

  if mode == "viewer" then imgpath = v.get_image().path end
  if mode == "gallery" then imgpath = g.get_image().path end

  if (imgpath == nil) then return end

  os.execute(
    'nohup file_manager_desktop' ..
    ' ' ..
    '"' .. imgpath .. '"' ..
    ' ' ..
    '0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

local function reopen()
  local mode = S.get_mode()

  local imgpath

  if mode == "viewer" then imgpath = v.get_image().path end
  if mode == "gallery" then imgpath = g.get_image().path end

  if (imgpath == nil) then return end

  os.execute(
    'nohup swayimg' ..
    ' ' ..
    '"' .. imgpath .. '"' ..
    ' ' ..
    '0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

local function gzoomin()
  g.set_thumb_size(g.get_thumb_size() + 10)
end

local function gzoomout()
  g.set_thumb_size(g.get_thumb_size() - 10)
end

local function gzoomreset()
  g.set_thumb_size(thumb_size_default)
end

bg('e', file_manager_desktop)
bg('equal', gzoomin)
bg('plus', gzoomin)
bg('minus', gzoomout)
bg('0', gzoomreset)
bg('Ctrl+0', gzoomreset)
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
bg('r', reopen)
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
mg('Ctrl+MouseLeft', function() S.set_mode("viewer") end)
mg('Ctrl+MouseRight', function() S.set_mode("viewer") end)
mg('MouseLeft', function() S.set_mode("viewer") end)
mg('MouseMiddle', function() S.set_mode("viewer") end)
mg("Ctrl-ScrollLeft", gzoomin)
mg("Ctrl-ScrollRight", gzoomout)
mg("Ctrl-ScrollUp", gzoomin)
mg("Ctrl-ScrollDown", gzoomout)
mg("Ctrl-MouseMiddle", gzoomreset)
mg("MouseRight", function() end)
mg("MouseRight-ScrollLeft", gzoomin)
mg("MouseRight-ScrollRight", gzoomout)
mg("MouseRight-ScrollUp", gzoomin)
mg("MouseRight-ScrollDown", gzoomout)
mg("MouseRight-MouseMiddle", gzoomreset)
mg("MouseRight-MouseLeft", function() S.set_mode("viewer") end)
mg("MouseMiddle-ScrollLeft", function() end)
mg("MouseMiddle-ScrollRight", function() end)
mg("MouseMiddle-ScrollUp", function() end)
mg("MouseMiddle-ScrollDown", function() end)
mg("MouseLeft-ScrollLeft", function() end)
mg("MouseLeft-ScrollRight", function() end)
mg("MouseLeft-ScrollUp", function() end)
mg("MouseLeft-ScrollDown", function() end)

local function vzoomin()
  local scale = v.get_scale()
  v.set_abs_scale(scale + scale / 10)
  vtitle()
end

local function vzoomout()
  local scale = v.get_scale()
  v.set_abs_scale(scale - scale / 10)
  vtitle()
end

local function vpanl()
  local wsize = S.get_window_size()
  local icoord = v.get_position()
  v.set_abs_position(math.floor(icoord.x + wsize.width / 10), icoord.y)
end

local function vpanr()
  local wsize = S.get_window_size()
  local icoord = v.get_position()
  v.set_abs_position(math.floor(icoord.x - wsize.width / 10), icoord.y)
end

local function vpanu()
  local wsize = S.get_window_size()
  local icoord = v.get_position()
  v.set_abs_position(icoord.x, math.floor(icoord.y + wsize.height / 10))
end

local function vpand()
  local wsize = S.get_window_size()
  local icoord = v.get_position()
  v.set_abs_position(icoord.x, math.floor(icoord.y - wsize.height / 10))
end

bv('e', file_manager_desktop)
bv('equal', vzoomin)
bv('plus', vzoomin)
bv('minus', vzoomout)
bv('Return', function() S.set_mode("gallery") end)
bv('h', vpanl)
bv('j', vpand)
bv('k', vpanu)
bv('l', vpanr)
bv("Left", vpanl)
bv('Down', vpand)
bv('Up', vpanu)
bv('Right', vpanr)
bv('0', vzoomreset)
bv('Ctrl+0', vzoomorig)
bv('n', function() v.switch_image("next") end)
bv('p', function() v.switch_image("prev") end)
bv('r', reopen)
bv('Space', function() v.switch_image("next") end)
bv('Shift+space', function() v.switch_image("prev") end)
bv('g', function() v.switch_image("first") end)
bv('Shift+r', function() v.reload() end)
bv('Shift+g', function() v.switch_image("last") end)
bv('f', function() S.toggle_fullscreen() end)
bv('Escape', function() S.exit() end)
bv('q', function() S.exit() end)
bv('i', function() if txt.visible() then txt.hide() else txt.show() end end)

local function mvzoomin()
  local mpos = S.get_mouse_pos()
  local scale = v.get_scale()
  v.set_abs_scale(scale + scale / 10, mpos.x, mpos.y)
  vtitle()
end

local function mvzoomout()
  local mpos = S.get_mouse_pos()
  local scale = v.get_scale()
  v.set_abs_scale(scale - scale / 10, mpos.x, mpos.y)
  vtitle()
end

local function mvnextprev()
  local mcoord = S.get_mouse_pos()
  local wsize = S.get_window_size()

  v.switch_image((mcoord.x <= (wsize.width / 2)) and 'prev' or 'next')
end

mv('MouseLeft', mvnextprev)
mv("MouseRight-MouseLeft", mvnextprev)
mv('Ctrl+MouseLeft', mvnextprev)
mv('Ctrl+MouseRight', mvnextprev)
mv('ScrollUp', function() v.switch_image("prev") end)
mv('ScrollDown', function() v.switch_image("next") end)
mv('ScrollLeft', function() v.switch_image("prev") end)
mv('ScrollRight', function() v.switch_image("next") end)
mv('MouseMiddle', function() S.set_mode("gallery") end)
mv("Ctrl-ScrollLeft", mvzoomin)
mv("Ctrl-ScrollRight", mvzoomout)
mv("Ctrl-ScrollUp", mvzoomin)
mv("Ctrl-ScrollDown", mvzoomout)
mv("Ctrl-MouseMiddle", vzoomreset)
mv("MouseRight", function() end)
mv("MouseRight-ScrollLeft", mvzoomin)
mv("MouseRight-ScrollRight", mvzoomout)
mv("MouseRight-ScrollUp", mvzoomin)
mv("MouseRight-ScrollDown", mvzoomout)
mv("MouseRight-MouseMiddle", vzoomreset)
mv("MouseMiddle-ScrollLeft", function() end)
mv("MouseMiddle-ScrollRight", function() end)
mv("MouseMiddle-ScrollUp", function() end)
mv("MouseMiddle-ScrollDown", function() end)
mv("MouseLeft-ScrollLeft", function() end)
mv("MouseLeft-ScrollRight", function() end)
mv("MouseLeft-ScrollUp", function() end)
mv("MouseLeft-ScrollDown", function() end)
