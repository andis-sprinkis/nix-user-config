local S = swayimg

local thumb_size_default = 128

S.enable_decoration(true)
S.enable_overlay(false)
S.set_dnd_button('MouseExtra')
S.gallery.enable_pstore(true)
S.gallery.limit_cache(8192)
S.gallery.set_aspect('fit')
S.gallery.set_border_size(8)
S.gallery.set_padding_size(16)
S.gallery.set_selected_scale(1.4)
S.gallery.set_thumb_size(thumb_size_default)
S.imagelist.enable_adjacent(true)
S.imagelist.enable_fsmon(false)
S.text.hide()
S.text.set_background(0xaa000000)
S.text.set_font('sans-serif')
S.text.set_foreground(0xffffffff)
S.text.set_shadow(0xff000000)
S.text.set_size(18)
S.viewer.enable_loop(false)
S.viewer.limit_preload(3)
S.viewer.set_default_scale('fit')
S.viewer.set_drag_button('MouseRight')
S.slideshow.limit_preload(3)
S.slideshow.set_default_scale('fit')
S.slideshow.set_drag_button('MouseRight')

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
      '[' .. img.index .. '/' .. S.imagelist.size() .. ']' ..
      ' ' ..
      wtitle
    )

    return
  end

  S.set_title(
    '[' .. img.index .. '/' .. S.imagelist.size() .. ']' ..
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
    S.gallery.set_thumb_size(thumb_size_default)
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
    S.gallery.set_thumb_size(S.gallery.get_thumb_size() + 10)
    return
  end

  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale + scale / 10)
  title()
end

local function zoomout()
  local mode = S.get_mode()

  if mode == 'gallery' then
    S.gallery.set_thumb_size(S.gallery.get_thumb_size() - 10)
    return
  end

  local scale = S[mode].get_scale()
  S[mode].set_abs_scale(scale - scale / 10)
  title()
end

local function mzoomin()
  local mode = S.get_mode()

  if mode == 'gallery' then
    S.gallery.set_thumb_size(S.gallery.get_thumb_size() + 10)
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
    S.gallery.set_thumb_size(S.gallery.get_thumb_size() - 10)
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

local function toggle_mode_gallery()
  if S.get_mode() == 'gallery' then
    mode_viewer()
    return
  end

  mode_gallery()
end

for _, mode in pairs({ 'gallery', 'viewer', 'slideshow' }) do
  S[mode].bind_reset()

  S[mode].on_image_change(
    function()
      title()
      S.text.set_status(S[mode].get_image().index .. '/' .. S.imagelist.size())
    end
  )

  S[mode].on_key('Return', toggle_mode_gallery)
  S[mode].on_key('equal', zoomin)
  S[mode].on_key('plus', zoomin)
  S[mode].on_key('minus', zoomout)
  S[mode].on_key('0', zoomreset)
  S[mode].on_key('i', function() if S.text.visible() then S.text.hide() else S.text.show() end end)
  S[mode].on_key('f', S.set_fullscreen)
  S[mode].on_key('Escape', S.exit)
  S[mode].on_key('q', S.exit)
  S[mode].on_key('e', file_manager_desktop)
  S[mode].on_key('Shift-p', pager_desktop)
  S[mode].on_key('Shift-r', S[mode].reload)
  S[mode].on_key('r', reopen)
  S[mode].on_key('Shift-o', open_with_menu_desktop)

  S[mode].on_mouse('MouseMiddle', toggle_mode_gallery)
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

S.gallery.on_key('Ctrl-0', zoomreset)
S.gallery.on_key('Space', mode_viewer)
S.gallery.on_key('s', mode_slideshow)
S.gallery.on_key('Shift-space', mode_viewer)
S.gallery.on_key('h', function() S.gallery.switch_image('left') end)
S.gallery.on_key('j', function() S.gallery.switch_image('down') end)
S.gallery.on_key('k', function() S.gallery.switch_image('up') end)
S.gallery.on_key('l', function() S.gallery.switch_image('right') end)
S.gallery.on_key('Left', function() S.gallery.switch_image('left') end)
S.gallery.on_key('Down', function() S.gallery.switch_image('down') end)
S.gallery.on_key('Up', function() S.gallery.switch_image('up') end)
S.gallery.on_key('Right', function() S.gallery.switch_image('right') end)
S.gallery.on_key('n', function() S.gallery.switch_image('pgdown') end)
S.gallery.on_key('p', function() S.gallery.switch_image('pgup') end)
S.gallery.on_key('bracketleft', function() S.gallery.switch_image('pgup') end)
S.gallery.on_key('bracketright', function() S.gallery.switch_image('pgdown') end)
S.gallery.on_key('g', function() S.gallery.switch_image('first') end)
S.gallery.on_key('Shift-g', function() S.gallery.switch_image('last') end)

S.gallery.on_mouse('ScrollUp', function() S.gallery.switch_image('pgup') end)
S.gallery.on_mouse('ScrollDown', function() S.gallery.switch_image('pgdown') end)
S.gallery.on_mouse('ScrollLeft', function() S.gallery.switch_image('pgup') end)
S.gallery.on_mouse('ScrollRight', function() S.gallery.switch_image('pgdown') end)
S.gallery.on_mouse('Ctrl-MouseLeft', mode_viewer)
S.gallery.on_mouse('Ctrl-MouseRight', mode_viewer)
S.gallery.on_mouse('MouseLeft', mode_viewer)
