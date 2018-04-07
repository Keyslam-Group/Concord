local PATH = (...):gsub('%.[^%.]+$', '')

local Concord = require(PATH)

return function()
   if love.math then
      love.math.setRandomSeed(os.time())
      love.timer.step()
   end

   for _, instance in ipairs(Concord.instances) do
      instance:emit("load", arg)
   end

   if love.timer then love.timer.step() end

   local dt = 0

   return function()
      if love.event then
         love.event.pump()
         for name, a, b, c, d, e, f in love.event.poll() do
            for _, instance in ipairs(Concord.instances) do
               instance:emit(name, a, b, c, d, e, f)
            end

            if name == "quit" then
               return a or 0
            end
         end
      end

      if love.timer then
         love.timer.step()
         dt = love.timer.getDelta()
      end

      for _, instance in ipairs(Concord.instances) do
         instance:emit("update", dt)
      end

      if love.graphics and love.graphics.isActive() then
         love.graphics.clear(love.graphics.getBackgroundColor())
         love.graphics.origin()

         for _, instance in ipairs(Concord.instances) do
            instance:emit("draw")
         end

         love.graphics.present()
      end

      if love.timer then love.timer.sleep(0.001) end
   end
end