local VORPcore = {}
VorpInv = exports.vorp_inventory:vorp_inventoryApi()

TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterCommand('notebook', function(source, args, raw)
	print("trying")

	CreateNewNotebook(source, false)
end, false)

-- function ToggleNotebook(source, args, raw)
-- 	TriggerEvent("showNotebook", function(source)
		
-- 	end)
-- end

function CreateNewNotebook(source, copy)
    local _source = source
    local Character = VORPcore.getUser(_source).getUsedCharacter
    local char = Character.charIdentifier
    local player = Character.identifier
	
	exports.oxmysql:execute(
		'INSERT INTO notebooks (title, purchased_by_char, purchased_by_player, content, copy) VALUES (?, ?, ?, ?, ?)',
		{ "Blank Notebook", char, player, "Thank you for purchasing a notebook!", copy },
		function(row)
			VorpInv.addItem(source, "el_notebook", 1, { notebookId = row.insertId })
			print(row)
		end
	)

end



function GetNotebookInfo(notebookId, source)
	print("getting info")
	exports.oxmysql:execute('SELECT * FROM notebooks WHERE id = ?', {notebookId}, function(row)
		if row then
			TriggerClientEvent("el_notebook:UpdateNotebook", source, row)
			return row
		end
	end)
	-- local notebook = exports.oxmysql:single_async("SELECT * FROM notebooks WHERE id = ?", { notebookId })
	-- if notebook then
	-- 	return notebook
	-- end
end


RegisterNetEvent("el_notebook:GetNotebook")
AddEventHandler("el_notebook:GetNotebook", function(notebookId, source)
	GetNotebookInfo(notebookId, source)
end)


VorpInv.RegisterUsableItem("el_notebook", function(data)
	-- print("notebook: ", tostring(data.item.metadata.notebookId))
	-- local notebookData = GetNotebookInfo(data.item.metadata.notebookId)
	TriggerClientEvent("el_notebook:OpenNotebook", data.source, data.source, data.item.metadata.notebookId)
	VorpInv.CloseInv(data.source)
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
