local S = swayimg
local imglist = S.imagelist
local txt = S.text
local g = S.gallery
local v = S.viewer
local s = S.slideshow
local bg = g.on_key
local mg = g.on_mouse

local thumb_size_default = 128

S.enable_decoration(true)
S.enable_overlay(false)
S.set_dnd_button('MouseExtra')
g.enable_pstore(true)
g.limit_cache(8192)
g.set_aspect('fit')
g.set_border_size(8)
g.set_padding_size(16)
g.set_selected_scale(1.4)
g.set_thumb_size(thumb_size_default)
imglist.enable_adjacent(true)
imglist.enable_fsmon(false)
txt.hide()
txt.set_background(0xaa000000)
txt.set_font('sans-serif')
txt.set_foreground(0xffffffff)
txt.set_shadow(0xff000000)
txt.set_size(18)
v.enable_loop(false)
v.limit_preload(3)
v.set_default_scale('fit')
v.set_drag_button('MouseRight')
s.limit_preload(3)
s.set_default_scale('fit')
s.set_drag_button('MouseRight')

local nop = function() end

local function title()
  local mode = S.get_mode()

  local img = S[mode].get_image()

  if img == nil then
    S.set_title("swayimg")
    return
  end

  local wsize = S.get_window_size()

  local fname = ""
  for part in img.path:gmatch("([^/]+)") do fname = part end

  local wtitle = (wsize.width < 800) and fname or img.path

  if mode == 'gallery' then
    S.set_title(
      '[' .. img.index .. '/' .. imglist.size() .. ']' ..
      ' ' ..
      wtitle
    )

    return
  end

  S.set_title(
    '[' .. img.index .. '/' .. imglist.size() .. ']' ..
    ' ' ..
    wtitle ..
    ' ' ..
    '[' .. math.floor(S[mode].get_scale() * 100) .. '%' .. ']' ..
    ' ' ..
    '[' .. img.width .. 'x' .. img.height .. ']'
  )
end

local function zoomreset()
  local mode = S.get_mode()

  if mode == 'gallery' then
    g.set_thumb_size(thumb_size_default)
    title()

    return
  end

  S[mode].reset()
  title()
end

local function zoomreal()
  S[S.get_mode()].set_fix_scale('real')
  title()
end

local function zoomin()
  local mode = S.get_mode()

  if mode == 'gallery' then
    g.set_thumb_size(g.get_thumb_size() + 10)
    return
  end

  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale + scale / 10)
  title()
end

local function zoomout()
  local mode = S.get_mode()

  if mode == 'gallery' then
    g.set_thumb_size(g.get_thumb_size() - 10)
    return
  end

  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale - scale / 10)
  title()
end

local function mzoomin()
  local mode = S.get_mode()

  if mode == 'gallery' then
    g.set_thumb_size(g.get_thumb_size() + 10)
    return
  end

  local mpos = S.get_mouse_pos()
  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale + scale / 10, mpos.x, mpos.y)
  title()
end

local function mzoomout()
  local mode = S.get_mode()

  if mode == 'gallery' then
    g.set_thumb_size(g.get_thumb_size() - 10)
    return
  end

  local mpos = S.get_mouse_pos()
  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale - scale / 10, mpos.x, mpos.y)
  title()
end

S.on_window_resize(
  function()
    if (S.get_mode() == 'gallery') then
      title()
      return
    end

    zoomreset()
  end
)

local function mode_viewer() S.set_mode('viewer') end
local function mode_gallery() S.set_mode('gallery') end
local function mode_slideshow() S.set_mode('slideshow') end

local function file_manager_desktop()
  local imgpath = S[S.get_mode()].get_image().path

  if (imgpath == nil) then return end

  os.execute(
    'nohup file_manager_desktop ' .. '"' .. imgpath .. '"' .. ' 0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

local function reopen()
  local imgpath = S[S.get_mode()].get_image().path

  if (imgpath == nil) then return end

  os.execute(
    'nohup swayimg --gallery ' .. '"' .. imgpath .. '"' .. ' 0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

local function open_with_menu_desktop()
  local imgpath = S[S.get_mode()].get_image().path

  if (imgpath == nil) then return end

  os.execute(
    'nohup open_with_menu_desktop ' .. '"' .. imgpath .. '"' .. ' 0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

local function pager_desktop()
  local imgpath = S[S.get_mode()].get_image().path

  if (imgpath == nil) then return end

  os.execute(
    'nohup pager_desktop ' .. '"' .. imgpath .. '"' .. ' 0</dev/null 1>/dev/null 2>/dev/null & disown'
  )
end

for _, mode in pairs({ 'gallery', 'viewer', 'slideshow' }) do
  S[mode].on_image_change(
    function()
      title()
      txt.set_status(S[mode].get_image().index .. '/' .. imglist.size())
    end
  )

  S[mode].bind_reset()

  S[mode].on_key('equal', zoomin)
  S[mode].on_key('plus', zoomin)
  S[mode].on_key('minus', zoomout)
  S[mode].on_key('0', zoomreset)
  S[mode].on_key('i', function() if txt.visible() then txt.hide() else txt.show() end end)
  S[mode].on_key('f', S.set_fullscreen)
  S[mode].on_key('Escape', S.exit)
  S[mode].on_key('q', S.exit)
  S[mode].on_key('e', file_manager_desktop)
  S[mode].on_key('Shift-p', pager_desktop)
  S[mode].on_key('Shift-r', S[mode].reload)
  S[mode].on_key('r', reopen)
  S[mode].on_key('Shift-o', open_with_menu_desktop)

  S[mode].on_mouse('Ctrl-ScrollLeft', mzoomin)
  S[mode].on_mouse('Ctrl-ScrollRight', mzoomout)
  S[mode].on_mouse('Ctrl-ScrollUp', mzoomin)
  S[mode].on_mouse('Ctrl-ScrollDown', mzoomout)
  S[mode].on_mouse('Ctrl-MouseMiddle', zoomreset)
  S[mode].on_mouse('MouseRight-ScrollLeft', mzoomin)
  S[mode].on_mouse('MouseRight-ScrollRight', mzoomout)
  S[mode].on_mouse('MouseRight-ScrollUp', mzoomin)
  S[mode].on_mouse('MouseRight-ScrollDown', mzoomout)
  S[mode].on_mouse('MouseRight-MouseMiddle', zoomreset)
  S[mode].on_mouse('MouseRight', nop)
  S[mode].on_mouse('MouseMiddle-ScrollLeft', nop)
  S[mode].on_mouse('MouseMiddle-ScrollRight', nop)
  S[mode].on_mouse('MouseMiddle-ScrollUp', nop)
  S[mode].on_mouse('MouseMiddle-ScrollDown', nop)
  S[mode].on_mouse('MouseLeft-ScrollLeft', nop)
  S[mode].on_mouse('MouseLeft-ScrollRight', nop)
  S[mode].on_mouse('MouseLeft-ScrollUp', nop)
  S[mode].on_mouse('MouseLeft-ScrollDown', nop)
  S[mode].on_mouse('MouseRight-MouseMiddle-ScrollUp', nop)
  S[mode].on_mouse('MouseRight-MouseMiddle-ScrollDown', nop)
end

for _, mode in pairs({ 'viewer', 'slideshow' }) do
  local function panl()
    local wsize = S.get_window_size()
    local icoord = S[mode].get_position()
    S[mode].set_abs_position(math.floor(icoord.x + wsize.width / 10), icoord.y)
  end

  local function panr()
    local wsize = S.get_window_size()
    local icoord = S[mode].get_position()
    S[mode].set_abs_position(math.floor(icoord.x - wsize.width / 10), icoord.y)
  end

  local function panu()
    local wsize = S.get_window_size()
    local icoord = S[mode].get_position()
    S[mode].set_abs_position(icoord.x, math.floor(icoord.y + wsize.height / 10))
  end

  local function pand()
    local wsize = S.get_window_size()
    local icoord = S[mode].get_position()
    S[mode].set_abs_position(icoord.x, math.floor(icoord.y - wsize.height / 10))
  end

  local function img_next()
    S[mode].switch_image('next')
  end

  local function img_prev()
    S[mode].switch_image('prev')
  end

  S[mode].on_key('Return', mode_gallery)
  S[mode].on_key('w', zoomreset)
  S[mode].on_key('Ctrl-0', zoomreal)
  S[mode].on_key(
    's',
    function()
      if mode == 'viewer' then
        mode_slideshow()
        return
      end

      mode_viewer()
    end
  )
  S[mode].on_key('h', panl)
  S[mode].on_key('j', pand)
  S[mode].on_key('k', panu)
  S[mode].on_key('l', panr)
  S[mode].on_key('Left', panl)
  S[mode].on_key('Down', pand)
  S[mode].on_key('Up', panu)
  S[mode].on_key('Right', panr)
  S[mode].on_key(
    'bracketleft',
    function()
      S[mode].rotate(270)
      zoomreset()
    end
  )
  S[mode].on_key(
    'bracketright',
    function()
      S[mode].rotate(90)
      zoomreset()
    end
  )
  S[mode].on_key('Shift-braceleft', S[mode].flip_vertical)
  S[mode].on_key('Shift-braceright', S[mode].flip_horizontal)
  S[mode].on_key('n', img_next)
  S[mode].on_key('p', img_prev)
  S[mode].on_key('Space', img_next)
  S[mode].on_key('Shift-space', img_prev)
  S[mode].on_key('g', function() S[mode].switch_image('first') end)
  S[mode].on_key('Shift-g', function() S[mode].switch_image('last') end)
  S[mode].on_key(
    'Shift-w',
    function()
      S[mode].set_fix_scale('width')
      title()
    end
  )
  S[mode].on_key(
    'Ctrl-w',
    function()
      S[mode].set_fix_scale('height')
      title()
    end
  )

  S[mode].on_mouse('MouseMiddle', mode_gallery)
  S[mode].on_mouse('Ctrl-MouseRight', nop)
  S[mode].on_mouse('MouseLeft', img_next)
  S[mode].on_mouse('MouseRight-MouseLeft', img_prev)
  S[mode].on_mouse('Ctrl-MouseLeft', img_next)
  S[mode].on_mouse('Ctrl-MouseRight-MouseLeft', img_prev)
  S[mode].on_mouse('ScrollUp', img_prev)
  S[mode].on_mouse('ScrollDown', img_next)
  S[mode].on_mouse('ScrollLeft', img_prev)
  S[mode].on_mouse('ScrollRight', img_next)
end

bg('Ctrl-0', zoomreset)
bg('Return', mode_viewer)
bg('Space', mode_viewer)
bg('s', mode_slideshow)
bg('Shift-space', mode_viewer)
bg('h', function() g.switch_image('left') end)
bg('j', function() g.switch_image('down') end)
bg('k', function() g.switch_image('up') end)
bg('l', function() g.switch_image('right') end)
bg('Left', function() g.switch_image('left') end)
bg('Down', function() g.switch_image('down') end)
bg('Up', function() g.switch_image('up') end)
bg('Right', function() g.switch_image('right') end)
bg('n', function() g.switch_image('pgdown') end)
bg('p', function() g.switch_image('pgup') end)
bg('bracketleft', function() g.switch_image('pgup') end)
bg('bracketright', function() g.switch_image('pgdown') end)
bg('g', function() g.switch_image('first') end)
bg('Shift-g', function() g.switch_image('last') end)

mg('ScrollUp', function() g.switch_image('pgup') end)
mg('ScrollDown', function() g.switch_image('pgdown') end)
mg('ScrollLeft', function() g.switch_image('pgup') end)
mg('ScrollRight', function() g.switch_image('pgdown') end)
mg('Ctrl-MouseLeft', mode_viewer)
mg('Ctrl-MouseRight', mode_viewer)
mg('MouseLeft', mode_viewer)
mg('MouseMiddle', mode_viewer)
