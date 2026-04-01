local S = swayimg

S.text.set_size(16)
S.enable_overlay(false)
S.imagelist.enable_adjacent(true)

-- set a custom window title in gallery mode
S.gallery.on_image_change(function()
  local image = S.gallery.get_image()
  S.set_title("Gallery: " .. image.path)
end)
