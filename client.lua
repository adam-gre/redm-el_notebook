local VORPutils = {}
local VORPcore = exports.vorp_core:GetCore()
local notebook = false -- Leave as false for production

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)



RegisterNetEvent("el_notebook:OpenNotebook")
AddEventHandler("el_notebook:OpenNotebook", function(source, notebookId)
	OpenNotebook(source, notebookId)
end)


RegisterNetEvent("el_notebook:ReceivePages")
AddEventHandler("el_notebook:ReceivePages", function(data)
	print(dump(data))
	if data ~= nil then
		SendNUIMessage({
			type = 'pages',
			source = source,
			pages = data
		})
	end
end)

-- local function DrawTexture(textureStreamed,textureName,x, y, width, height,rotation,r, g, b, a, p11)
--     if not HasStreamedTextureDictLoaded(textureStreamed) then
--        RequestStreamedTextureDict(textureStreamed, false);
--     else
--         DrawSprite(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11);
--     end
-- end

function OpenNotebook(source, notebookId)
	TriggerServerEvent("el_notebook:GetPages", source, notebookId)

	SendNUIMessage({
		type = 'open',
		source = source, 
		notebookId = notebookId
	})

	SetNuiFocus(true, true)

	notebook = true
end

RegisterNUICallback('closeNotebook', function(data, cb)
	SetNuiFocus(false, false)
	notebook = false
	-- print(notebook)
    cb({error = false})
end)


RegisterNUICallback('saveNote', function(data, cb)
    -- POST data gets parsed as JSON automatically
	print("save req received")
    local title = data.title
    local content = data.content
    -- local notebookId = data.notebookId
    local itemId = data.itemId
    local playerSource = data.playerSource

	-- print(dump(data))

	TriggerServerEvent("el_notebook:SaveNote", data)

    -- and so does callback response data
    cb({error = false})
end)

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end
