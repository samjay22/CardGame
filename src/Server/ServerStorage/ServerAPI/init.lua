--!strict
--!strict
local HttpService : HttpService = game:GetService("HttpService")

local DistributedQueue = require(game.ServerStorage.UtilityModules.DistributedQueue)

local ClientAPI = {}
local _Delegates = {}
local _ServerRequestQueue : {() -> ()} = {}

for _, module in ipairs(script:GetChildren()) do
    if module:IsA("ModuleScript") then
        for name, value in pairs(require(module)) do
            if _Delegates[name] then
                warn("Duplicate API name: " .. name)
                continue
            end
            
            _Delegates[name] = value
        end
    end
end

local NetworkTypes = require(game.ReplicatedStorage.ClientNetwork.Types)
function ClientAPI.ProcessRequest(endpoint : string, payload : NetworkTypes.ResponsePayload)
   if _Delegates[endpoint] then
        DistributedQueue.ProcessRequest(function(dt : number)
            _Delegates[endpoint](payload.data)
        end)
   end 
end

return ClientAPI