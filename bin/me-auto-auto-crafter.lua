-- Original by Palagius : https://oc.cil.li/index.php?/topic/1426-ae2-level-auto-crafting/
-- Modfied by Dalden 2018-07-28
--           - Store crafting result object to check for status
--           - If crafting job is not yet finished from previous cycle then skip this cycle

local component = require("component")
local meController = component.proxy(component.me_controller.address)
local gpu = component.gpu

-- Each element of the array is "item", "damage", "number wanted", "max craft size"
-- Damage value should be zero for base items

items = {
    { "minecraft:iron_ingot",       0, 16384, 256 },
    { "minecraft:gold_ingot",       0, 16384, 256 },
    { "minecraft:glass",      0, 16384, 256 },
    { "minecraft:quartz",      0, 16384, 256 },
    { "minecraft:diamond",      0, 16384, 256 },
    { "minecraft:emerald",      0, 16384, 256 },
    { "draconicevolution:draconium_ingot",      0, 16384, 256 },
    { "thermalfoundation:material",       128, 1024, 256 }, -- Copper Ingot
    { "thermalfoundation:material",       129, 1024, 256 }, -- Tin Ingot
    { "thermalfoundation:material",       130, 1024, 256 }, -- Silver Ingot
    { "thermalfoundation:material",       131, 1024, 256 }, -- Lead Ingot
    { "thermalfoundation:material",       161, 1024, 256 }, -- Electrum Ingot
    { "thermalfoundation:material",       162, 1024, 256 }, -- Invar Ingot
    { "thermalfoundation:material",       163, 1024, 256 }, -- Bronze Ingot
    { "thermalfoundation:material",       164, 1024, 256 }, -- Constantan Ingot
    { "thermalfoundation:material",       165, 1024, 256 }, -- Signalum Ingot
    { "thermalfoundation:material",       166, 1024, 256 }, -- Lumium Ingot
    { "thermalfoundation:material",       167, 1024, 256 }, -- Enderium Ingot
    { "appliedenergistics2:material",       24, 4096, 256 }, -- Engineering Processor
    { "appliedenergistics2:material",       23, 4096, 256 }, -- Calculation Processor
    { "appliedenergistics2:material",       22, 4096, 256 }, -- Logic Processor
    { "appliedenergistics2:material",       11, 4096, 256 }, -- Pure Nether Quartz Crystal
    { "appliedenergistics2:material",       10, 4096, 256 }, -- Pure Certus Quartz Crystal
    { "appliedenergistics2:material",       7, 4096, 256 }, -- Fluix Crystal
    { "appliedenergistics2:material",       12, 4096, 256 }, -- Pure Fluix Crystal
    { "appliedenergistics2:material",       0, 4096, 256 }, -- Certus Quartz Crystal
    { "appliedenergistics2:material",       1, 4096, 256 }, -- Charged Certus Quartz Crystal
    { "appliedenergistics2:material",       8, 4096, 256 }, -- Fluix Dust
    { "appliedenergistics2:material",       2, 4096, 256 }, -- Certus Quartz Dust
    { "actuallyadditions:item_dust",       5, 4096, 256 }, -- Crushed Quartz
    { "enderio:item_material",       5, 4096, 256 }, -- Silicon
    { "enderio:item_alloy_ingot",       1, 1024, 256 }, -- Energetic Alloy Ingot
    { "enderio:item_alloy_ingot",       2, 1024, 256 }, -- Vibrant Alloy Ingot
    { "enderio:item_alloy_ingot",       5, 1024, 256 }, -- Pulsating Iron Ingot
    { "enderio:item_alloy_ingot",       6, 1024, 256 }, -- Dark Steel Ingot
    { "enderio:item_alloy_ingot",       7, 1024, 256 }, -- Soularium Ingot
    { "enderio:item_alloy_ingot",       8, 1024, 256 }, -- End Steel Ingot
    { "enderio:item_alloy_ingot",       0, 1024, 256 } -- Electrical Steel Ingot
}

loopDelay = 60 -- Seconds between runs

-- Init list with crafting status
for curIdx = 1, #items do
    items[curIdx][5] = false -- Crafting status set to false
    items[curIdx][6] = nil -- Crafting object null
end

while true do
    for curIdx = 1, #items do
        curName = items[curIdx][1]
        curDamage = items[curIdx][2]
        curMinValue = items[curIdx][3]
        curMaxRequest = items[curIdx][4]
        curCrafting = items[curIdx][5]
        curCraftStatus = items[curIdx][6]

        -- io.write("Checking for " .. curMinValue .. " of " .. curName .. "\n")
        storedItem = meController.getItemsInNetwork({
            name = curName,
            damage = curDamage
            })
        io.write("Network contains ")
        gpu.setForeground(0xCC24C0) -- Purple-ish
        io.write(storedItem[1].size)
        gpu.setForeground(0xFFFFFF) -- White
        io.write(" items with label ")
        gpu.setForeground(0x00FF00) -- Green
        io.write(storedItem[1].label .. "\n")
        gpu.setForeground(0xFFFFFF) -- White
        if storedItem[1].size < curMinValue then
            delta = curMinValue - storedItem[1].size
            craftAmount = delta
            if delta > curMaxRequest then
                craftAmount = curMaxRequest
            end

            io.write("  Need to craft ")
            gpu.setForeground(0xFF0000) -- Red
            io.write(delta)
            gpu.setForeground(0xFFFFFF) -- White
            io.write(", requesting ")
            gpu.setForeground(0xCC24C0) -- Purple-ish
            io.write(craftAmount .. "... ")
            gpu.setForeground(0xFFFFFF) -- White

            craftables = meController.getCraftables({
                name = curName,
                damage = curDamage
                })
            if craftables.n >= 1 then
                cItem = craftables[1]
                if curCrafting then
                    if curCraftStatus.isCanceled() or curCraftStatus.isDone() then
                        io.write("Previous Craft completed\n")
                        items[curIdx][5] = false
                        curCrafting = false
                    end
                end
                if curCrafting then
                        io.write("Previous Craft busy\n")
                end
                if not curCrafting then
                    retval = cItem.request(craftAmount)
                    items[curIdx][5] = true
                    items[curIdx][6] = retval
                    gpu.setForeground(0x00FF00) -- Green
                    io.write("Requested - ")
		    --while (not retval.isCanceled()) and (not retval.isDone()) do
	            --		os.sleep(1)
                    --        io.write(".")
		    -- end
                    gpu.setForeground(0xFFFFFF) -- White
                    io.write("Done \n")
                end
            else
                gpu.setForeground(0xFF0000) -- Red
                io.write("    Unable to locate craftable for " .. storedItem[1].name .. "\n")
                gpu.setForeground(0xFFFFFF) -- White
            end
        end
    end
    io.write("Sleeping for " .. loopDelay .. " seconds...\n\n")
    os.sleep(loopDelay)
end
