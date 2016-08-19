-- Auto-reload
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", function(files)
  for _ ,file in pairs(files) do
    if file:sub(-4) == ".lua" then
      hs.reload()
    end
  end
end):start()

hs.notify.show("Hammerspoon", "Config loaded.", '')
