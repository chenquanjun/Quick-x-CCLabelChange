require("app/action/CCLabelChange")
require("app/basic/extern")


local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    local label =  ui.newTTFLabel({text = "Hello, World", size = 64, align = ui.TEXT_ALIGN_CENTER})
        :pos(display.cx, display.cy)
        :addTo(self)


    local action = CCLabelChange:create(label, 3, 100, 200)

    action:playAction()

    self:performWithDelay(function ()
        local newAction = CCLabelChange:create(label, 1, 500, 1)

        action:pauseAction()
        self:performWithDelay(function ()
            newAction:playAction()
        end, 0.5)

        
    end, 2)

end

function MainScene:onEnter()
    if device.platform == "android" then
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(function(event)
                if event == "back" then app.exit() end
            end)
            self:addChild(layer)

            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

function MainScene:onExit()
end

return MainScene
