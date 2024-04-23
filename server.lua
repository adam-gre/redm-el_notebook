local VORPcore = exports.vorp_core:GetCore()

RegisterCommand('notebook', function(source, args, raw)
	exports.vorp_inventory:addItem(source, "el_notebook", 1, {})
end, false)


-- function CreateNewNotebook(source, copy)
--     local _source = source
--     local Character = VORPcore.getUser(_source).getUsedCharacter
--     local char = Character.charIdentifier
--     local player = Character.identifier
	
-- 	exports.oxmysql:execute(
-- 		'INSERT INTO notebooks (title, purchased_by_char, purchased_by_player, content, copy) VALUES (?, ?, ?, ?, ?)',
-- 		{ "Empty Notebook", char, player, "", copy },
-- 		function(row)
-- 			VorpInv.addItem(source, "el_notebook", 1, { notebookId = row.insertId })
-- 			print(row)
-- 		end
-- 	)

-- end

RegisterNetEvent("el_notebook:AddPage")
AddEventHandler("el_notebook:AddPage", function (source, notebookId)	
	exports.oxmysql:execute(
		'INSERT INTO notebook_pages (title, content, notebook_id) VALUES (?, ?, ?)',
		{ "Blank Notebook", "Thank you for purchasing a notebook!", notebookId },
		function(row)
			exports.vorp_inventory:addItem(source, "el_notebook", 1, { notebookId = row.insertId })
			print(row)
		end
	)
end)



RegisterNetEvent("el_notebook:SaveNote")
AddEventHandler("el_notebook:SaveNote", function (data)
	print("Notebook Info=====")
	-- print(dump(data))
	print("title: "..data.title)
	print("content: "..data.content)
	print("itemId: "..data.itemId)
	print("notebookId: "..data.notebookId)
	print("playerSource: "..data.playerSource)
	print("source: "..source)

	
	exports.oxmysql:execute(
		'UPDATE notebook_pages SET title = ?, content = ? WHERE id = ? AND notebook_id = ?',
		{ data.title, data.content, data.pageId, data.notebookId },
		function(row)
			print(dump(row))
		end
	)

end)

-- RegisterNetEvent("el_notebook:GetNotebook")
-- AddEventHandler("el_notebook:GetNotebook", function(notebookId, source)
-- 	GetNotebookInfo(notebookId, source)
-- end)


exports.vorp_inventory:registerUsableItem("el_notebook", function(data)
	print(dump(data.item.metadata))
	if not data.item.metadata.notebookId then
		exports.oxmysql:execute(
			'INSERT INTO notebooks (title, content, item_id) VALUES (?, ?, ?)',
			{ "Blank Notebook", "Thank you for purchasing a notebook!", data.item.mainid },
			function(row)
				-- VorpInv.subItem(data.source, "el_notebook", 1, data.item.metadata)
				exports.vorp_inventory:setItemMetadata(data.source, data.item.id, {notebookId = row.id}, 1, function ()
					TriggerClientEvent("el_notebook:OpenNotebook", data.source, data.source, row, data.item.id)
					exports.vorp_inventory:closeInventory(data.source)
				end)
				print("Notebook created:" ..dump(row))
			end
		)
	else
		exports.oxmysql:execute(
			'SELECT * FROM notebooks WHERE id=? LIMIT 1',
			{ data.item.metadata.notebookId },
			function(row)				
				print("notebook found: ".. dump(row))
				
				TriggerClientEvent("el_notebook:OpenNotebook", data.source, data.source, row, data.item.id)
				exports.vorp_inventory:closeInventory(data.source)
			end
		)
	end
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
