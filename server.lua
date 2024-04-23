local VORPcore = exports.vorp_core:GetCore()

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
	  return
	end
	print('[Electrum] Checking for database initialisation...')
		exports.oxmysql:execute(
			[[CREATE TABLE IF NOT EXISTS `notebooks` (
				`id` int(11) NOT NULL AUTO_INCREMENT,
				`item_id` int(11) NOT NULL DEFAULT 0,
				PRIMARY KEY (`id`),
				FOREIGN KEY (`id`) REFERENCES `notebook_pages` (`notebook_id`)
			  ) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4;]]
		)
		
		exports.oxmysql:execute(
			[[CREATE TABLE IF NOT EXISTS `notebook_pages` (
				`id` int(11) NOT NULL AUTO_INCREMENT,
				`title` varchar(50) NOT NULL,
				`content` varchar(5000) NOT NULL,
				`notebook_id` int(11) NOT NULL DEFAULT 0,
				PRIMARY KEY (`id`),
				KEY `notebook` (`notebook_id`)
			  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]]
		)
end)


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
		'INSERT INTO notebook_pages (notebook_id) VALUES (?, ?, ?)',
		{ notebookId },
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
	exports.oxmysql:execute(
		'SELECT * FROM notebooks WHERE item_id=? LIMIT 1',
		{ data.item.mainid },
		function(row)
			-- print("search result: ".. dump(row))
			
			if row[1] then
				print("search result: ".. data.item.mainid)
				TriggerClientEvent("el_notebook:OpenNotebook", data.source, data.source, data.item.mainid)
				exports.vorp_inventory:closeInventory(data.source)
			else
				exports.oxmysql:execute(
					'INSERT INTO notebooks (title, content, item_id) VALUES (?, ?, ?)',
					{ "Blank Notebook", "Thank you for purchasing a notebook!", data.item.mainid },
					function(row)
						TriggerClientEvent("el_notebook:OpenNotebook", data.source, data.item.mainid)
						exports.vorp_inventory:closeInventory(data.source)
						print("Notebook created:" ..dump(row))
					end
				)
			end
		end
	)
end)

-- Client Callbacks
RegisterNetEvent("el_notebook:GetPages")
AddEventHandler("el_notebook:GetPages", function (source, notebookId)
	print(source)
	local result
	exports.oxmysql:execute(
		'SELECT * FROM notebook_pages WHERE notebook_id=?',
		{ notebookId },
		function(row)
			print(dump(row))
			result = row
			TriggerClientEvent("el_notebook:ReceivePages", source, row)
		end
	)

	return result
end)


-- Utils
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
