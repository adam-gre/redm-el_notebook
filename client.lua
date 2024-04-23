local VORPutils = {}
local notebook = false -- Leave as false for production
local notebookData = nil
local notebookContents = "Lorem ipsum dolor sit amet" -- Remove from production

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

-- RegisterCommand('notebook', function(source, args, raw)
-- 	OpenNotebook()
-- end, false)

RegisterNetEvent("el_notebook:OpenNotebook")
AddEventHandler("el_notebook:OpenNotebook", function(source, metadata, itemId)
	print(dump(metadata))
	OpenNotebook(source, metadata, itemId)
end)

RegisterNetEvent("el_notebook:UpdateNotebook")
AddEventHandler("el_notebook:UpdateNotebook", function(data)
	-- print("NOTEBOOK: ", dump(data[1]))
	notebookData = data
end)

-- local function DrawTexture(textureStreamed,textureName,x, y, width, height,rotation,r, g, b, a, p11)
--     if not HasStreamedTextureDictLoaded(textureStreamed) then
--        RequestStreamedTextureDict(textureStreamed, false);
--     else
--         DrawSprite(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11);
--     end
-- end

function OpenNotebook(source, metadata, itemId)
	print("NOTEBOOK: ", dump(metadata))
	if not notebook then
		-- if not VORPutils.Render then TriggerEvent("getUtils", function(utils)
		-- 		VORPutils = utils
		-- 		print = VORPutils.Print:initialize(print)
		-- 	end)
		-- end

		-- TriggerServerEvent("el_notebook:GetNotebook", metadata, source)

		SendNUIMessage({
			type = 'open',
			metadata = metadata,
			itemId = itemId, 
			source = source
		})

		SetNuiFocus(true, true)

		notebook = true
	end
end

RegisterNUICallback('closeNotebook', function(data, cb)
	SetNuiFocus(false, false)
	notebook = false
	print(notebook)
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
