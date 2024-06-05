local ReplicatedStorage = game:GetService("ReplicatedStorage")
--!strict
local Network = require(ReplicatedStorage.ClientNetwork)
return {
    ClientResponse = Network.ResponseAsync
}