local VORPutils = {}
local notebook = false -- Leave as false for production
local notebookData = nil
local notebookContents = "Lorem ipsum dolor sit amet" -- Remove from production

-- Textbox config - don't change these. Eventually will have a custom editor, but uses basic HTML textarea from VORP Inputs for now
local editor = {
    type = "enableinput",
    inputType = "textarea",
    button = "Confirm",
    style = "block",
    attributes = {
		inputHeader = "Editing Notebook",
        type = "textarea",
        style = "border-radius: 10px; background-color: ; border:none;",
		value = notebookContents,
		rows = "20" -- This needs the following adding as line 24 in script.js of vorp_inputs: inputEle.rows = data.attributes.rows || "3";
		-- Also edit line 14 of styles.css for vorp_inputs to change h-48 to h-100 or the text box will overflow
    }
}

TriggerEvent("getUtils", function(utils)
    VORPutils = utils
	print = VORPutils.Print:initialize(print)
end)

-- RegisterCommand('notebook', function(source, args, raw)
-- 	OpenNotebook()
-- end, false)

RegisterNetEvent("el_notebook:OpenNotebook")
AddEventHandler("el_notebook:OpenNotebook", function(source, notebookId)
	OpenNotebook(source, notebookId)
end)

RegisterNetEvent("el_notebook:UpdateNotebook")
AddEventHandler("el_notebook:UpdateNotebook", function(data)
	print("NOTEBOOK: ", dump(data[1]))
	notebookData = data
end)

local function DrawTexture(textureStreamed,textureName,x, y, width, height,rotation,r, g, b, a, p11)
    if not HasStreamedTextureDictLoaded(textureStreamed) then
       RequestStreamedTextureDict(textureStreamed, false);
    else
        DrawSprite(textureStreamed, textureName, x, y, width, height, rotation, r, g, b, a, p11);
    end
end

function OpenNotebook(source, notebookId)
	if not VORPutils.Render then TriggerEvent("getUtils", function(utils)
			VORPutils = utils
			print = VORPutils.Print:initialize(print)
		end)
	end

	TriggerServerEvent("el_notebook:GetNotebook", notebookId, source)

	SendNUIMessage({
		type = 'open'
	})

	if not notebook then
		notebook = true

		-- Draw notebook background and text
		local notebookThread = Citizen.CreateThread(function()
			while true do
				Citizen.Wait(0)
				if notebook == true then
					-- DrawText({x = 0.5, y = 0.5}, "Test Text", {r = 0, g = 0, b = 0, a = 255}, 1, true)
					DrawTexture("big_feed", "big_feed_bg_1", 0.5, 0.5, 0.3, 0.75, 0.0, 255, 255, 255, 255, false);
					if notebookData ~= nil then
						VORPutils.Render:DrawText({x = 0.4, y = 0.2}, notebookData[1].title, {r = 0, g = 0, b = 0, a = 255}, 0.25, false)
						VORPutils.Render:DrawText({x = 0.4, y = 0.25}, notebookData[1].content, {r = 0, g = 0, b = 0, a = 255}, 0.25, false)
					end
				end
			end
		end)

		-- Add input prompts
		local promptGroup = UipromptGroup:new("Test")

		local nextPrompt = Uiprompt:new("INPUT_FRONTEND_RIGHT", "Next page", promptGroup)
		nextPrompt:setHoldMode(false)

		local prevPrompt = Uiprompt:new("INPUT_FRONTEND_LEFT", "Previous page", promptGroup)
		prevPrompt:setHoldMode(false)

		local editPrompt = Uiprompt:new("INPUT_FRONTEND_ACCEPT", "Edit", promptGroup)
		editPrompt:setHoldMode(true)
		
		local closePrompt = Uiprompt:new("INPUT_FRONTEND_CANCEL", "Close", promptGroup)
		closePrompt:setHoldMode(false)
		

		UipromptManager:startEventThread()
		
		-- Handle input to prompts
		promptGroup:setOnHoldModeJustCompleted(function(group, prompt)
			if prompt.text == "Edit" then
				TriggerEvent("vorpinputs:advancedInput", json.encode(editor), function(result)
					-- if result ~= "" and result then
					print(result) --returns string
					notebookContents = result
					SendNUIMessage({
						type = 'updateContent',
						notebookContents = result
					})
				end)
			end
		end)

		promptGroup:setOnControlJustPressed(function(group, prompt)
			if prompt.text == "Close" then
				notebook = false
				promptGroup:delete()
				SendNUIMessage({
					type = 'close'
				})
			elseif prompt.text == "Next page" or prompt.text == "Previous page" then
				print("nothing yet!")
			end
		end)
	end
end


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
