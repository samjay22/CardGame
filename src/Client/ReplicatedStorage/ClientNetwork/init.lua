--!strict
local HttpService : HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(game.ReplicatedStorage.ClientNetwork.Types)
local GlobalUpdateService = require(game.ReplicatedStorage.Utility.GlobalUpdateService)

local _ClientRequestQueue : {() -> ()} = {}
local _ClientResponseHandlers : {[string] : (any...) -> (any...)} = {}

local ClientNetwork = {}

--To Server
function ClientNetwork.PostAsync(endpont : string, dataHandler : (any...) -> (any...), data : any)
    local requestID : string = HttpService:GenerateGUID(false)
    _ClientResponseHandlers[requestID] = dataHandler

    local payload : Types.RequestPayload = {
        requestID = requestID,
        data = data
    }
    game.ReplicatedStorage.Network.RemoteEvent:FireServer(endpont, payload)

    local timeout : number = os.clock() + 5
    --Wait until response or timeout
    repeat task.wait() until _ClientResponseHandlers[requestID] == nil or timeout < os.clock()
end

function ClientNetwork.ResponseAsync(data : Types.ResponsePayload)
    if _ClientResponseHandlers[data.requestID] then
        table.insert(_ClientRequestQueue, function() _ClientResponseHandlers[data.requestID](data.data) end)
        _ClientResponseHandlers[data.requestID] = nil
    end
end

function ClientNetwork.FireServer(endpont : string, data : any)
    local payload : Types.RequestPayload = {
        requestID = HttpService:GenerateGUID(false),
        data = data
    }
    game.ReplicatedStorage.Network.RemoteEvent:FireServer(endpont, payload)
end

GlobalUpdateService.AddGlobalUpdate(function(dt : number)
    while #_ClientRequestQueue > 0 do
        _ClientRequestQueue[1](dt)
        table.remove(_ClientRequestQueue, 1)
    end
end)

return ClientNetwork