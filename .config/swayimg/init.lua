local S = swayimg
local gallery = S.gallery
local imagelist = S.imagelist
local set_title = S.set_title
local slideshow = S.slideshow
local text = S.text
local viewer = S.viewer

S.enable_overlay(false)
S.enable_decoration(true)
S.set_dnd_button('MouseExtra')
imagelist.enable_adjacent(true)
text.hide()
text.set_size(16)
viewer.set_default_scale('optimal')

gallery.on_image_change(
  function()
    local img = gallery.get_image()

    set_title(img.path .. " [" .. img.index .. "/" .. imagelist.size() .. "]")
  end
)

viewer.on_image_change(
  function()
    local img = viewer.get_image()

    set_title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imagelist.size() .. "]")
  end
)

slideshow.on_image_change(
  function()
    local img = slideshow.get_image()

    set_title(img.path ..
      " " .. img.width .. "x" .. img.height .. " [" .. img.index .. "/" .. imagelist.size() .. "]")
  end
)
