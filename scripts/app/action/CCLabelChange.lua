--此处继承CCNode,因为需要维持这个表，但是用object的话需要retian/release
CCLabelChange = class("CCLabelChange", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)			
--index
CCLabelChange.__index  			= CCLabelChange
CCLabelChange._duration         = -1
CCLabelChange._fromNum          = -1
CCLabelChange._toNum            = -1
CCLabelChange._target           = nil
CCLabelChange._isPause          = false

--初步使用思路
--创建对象时候自动将本对象addChild(因为基于schedule执行)
--动作执行完毕后从父类移除，并通过某种方式标记执行完毕（例如在使用对象加字段，nil表示完毕）

--因为不是继承CCActionInterval，所以需要传入target对象
function CCLabelChange:create(target, duration, fromNum, toNum)
	local ret = CCLabelChange.new()
	ret:init(target, duration, fromNum, toNum)
	return ret
end

function CCLabelChange:init(target, duration, fromNum, toNum)
    self._duration = duration
    self._fromNum = fromNum
    self._toNum = toNum
    self._target = target

    target:addChild(self) --基于此执行
end

--两种情况下执行此方法 1、动作执行完毕 2、同类动作，旧动作在执行中，新动作需要执行，此时把旧动作移除
function CCLabelChange:selfKill()
    self._target._labelChange:unscheduleUpdate() --停止scheduler
    self:removeFromParentAndCleanup(true) --从父类移除
    self._target._labelChange = nil --把引用删除
    self._target = nil
end

function CCLabelChange:pauseAction()
    self._isPause = true
end

function CCLabelChange:resumeAction()
    self._isPause = false
end

function CCLabelChange:playAction()
    local oldAction = self._target._labelChange

    if oldAction then
        --旧动作存在
        oldAction:selfKill()
    end

    self._target._labelChange = self --引用变成自己

    local curTime = 0
    local duration = self._duration

    local function int(x) 
        return x>=0 and math.floor(x) or math.ceil(x)
    end

    local function updateLabelNum(dt)
                if self._isPause then
                    return
                end

                curTime = curTime + dt

                --这个类似动作里面的update的time参数
                local time = curTime / duration

                if self._target then 
                    if time < 1 then --执行时间内
                        local tempNum = int((self._toNum - self._fromNum) *time) --取整
                        local num = self._fromNum + tempNum

                        self._target:setString(num)
                    else
                        self._target:setString(self._toNum)
                        self:selfKill()
                    end

                else
                    error("target not exist")
                end

    end

    self:unscheduleUpdate()
    self:scheduleUpdate(updateLabelNum)
end

function CCLabelChange:onEnter()
    -- print("enter")
end

function CCLabelChange:onExit()
    print("exit")
    self:unscheduleUpdate()
end
