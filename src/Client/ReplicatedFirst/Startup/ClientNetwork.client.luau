local ReplicatedStorage = game:GetService("ReplicatedStorage")

--!strict
game.ReplicatedStorage.Network.RemoteEvent.OnClientEvent:Connect(function(endpoint : string, data)
    require(ReplicatedStorage.ClientAPI).ProcessRequest(endpoint, data)
end)