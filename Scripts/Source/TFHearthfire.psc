Scriptname TFHearthfire extends Quest

TimeFliesMain Property main Auto
TimeFliesMCM Property mcm Auto

int prefix
float building_crafting_hour
int building_crafting_hour_id
float furniture_crafting_hour
int furniture_crafting_hour_id
float misc_crafting_hour
int misc_crafting_hour_id
Form[] armorer_workbenches

Function initialize()
    prefix = main.get_prefix(Game.getFormFromFile(0x8ce, "HearthFires.esm"))
    if prefix == -1
        return
    endif

    ;; craftable workbenches that should not be ignored
    armorer_workbenches = new Form[2]
    armorer_workbenches[0] = Game.getFormFromFile(0xc1e1, "HearthFires.esm")
    armorer_workbenches[1] = Game.getFormFromFile(0xcd46, "HearthFires.esm")
EndFunction

Function load_defaults()
    building_crafting_hour = 3.0
    furniture_crafting_hour = 3.0
    misc_crafting_hour = 2.0
EndFunction

bool Function handle_added_item(Form item)
    if main.get_prefix(item) != prefix || item.getType() != 32
        return False
    endif

    string name = item.getName()
    if item.hasKeywordString("BYOHHouseCraftingCategoryBuilding")
        main._debug("Building part constructed")
        main.pass_time(building_crafting_hour * main.random_time_multiplier())
    elseif item.hasKeywordString("BYOHHouseCraftingCategoryShelf") || \
            item.hasKeywordString("BYOHHouseCraftingCategoryExterior") || \
            item.hasKeywordString("BYOHHouseCraftingCategoryFurniture") || \
            item.hasKeywordString("BYOHHouseCraftingCategoryContainers") || \
            item.hasKeywordString("BYOHHouseCraftingCategoryWeaponRacks")
        main._debug("Furniture made")
        main.pass_time(furniture_crafting_hour * main.random_time_multiplier())
    elseif StringUtil.find(name, "Addition") > -1 || \
            StringUtil.find(name, "Workbench") > -1 && \
            armorer_workbenches.find(item) < 0 || \
            item.hasKeywordString("BYOHHouseCraftingCategorySmithing")
        ;; ignore drafting, carpenter's workbench and small objects like nail
    else
        main._debug("Hearthfire misc item made")
        main.pass_time(misc_crafting_hour * main.random_time_multiplier())
    endif
    return True
EndFunction

Function save_settings()
    mcm.fiss.saveFloat("hearthfire_building_crafting_hour", \
        building_crafting_hour)
    mcm.fiss.saveFloat("hearthfire_furniture_crafting_hour", \
        furniture_crafting_hour)
    mcm.fiss.saveFloat("hearthfire_misc_crafting_hour", misc_crafting_hour)
EndFunction

Function load_settings()
    building_crafting_hour = \
        mcm.fiss.loadFloat("hearthfire_building_crafting_hour")
    furniture_crafting_hour = \
        mcm.fiss.loadFloat("hearthfire_furniture_crafting_hour")
    misc_crafting_hour = mcm.fiss.loadFloat("hearthfire_misc_crafting_hour")
EndFunction

bool Function handle_page(string page)
    if page != "$hearthfire"
        return False
    endif

    if prefix == -1
        mcm.addTextOption("", "$hearthfire_not_installed")
    else
        mcm.setCursorFillMode(mcm.TOP_TO_BOTTOM)
        mcm.addHeaderOption("$options")
        building_crafting_hour_id = mcm.addSliderOption( \
            "$hearthfire_building_parts", building_crafting_hour, "${2}hour")
        furniture_crafting_hour_id = mcm.addSliderOption( \
            "$hearthfire_furniture", furniture_crafting_hour, "${2}hour")
        misc_crafting_hour_id = mcm.addSliderOption( \
            "$hearthfire_misc", misc_crafting_hour, "${2}hour") 
    endif
    return True
EndFunction

bool Function handle_slider_opened(int option)
    if option == building_crafting_hour_id
        mcm.setSliderDialogStartValue(building_crafting_hour)
        mcm.setSliderDialogDefaultValue(3.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == furniture_crafting_hour_id
        mcm.setSliderDialogStartValue(furniture_crafting_hour)
        mcm.setSliderDialogDefaultValue(3.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == misc_crafting_hour_id
        mcm.setSliderDialogStartValue(misc_crafting_hour)
        mcm.setSliderDialogDefaultValue(2.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    else
        return False
    endif
    return True
EndFunction

bool Function handle_slider_accepted(int option, float value)
    if option == building_crafting_hour_id
        building_crafting_hour = value
        mcm.setSliderOptionValue(building_crafting_hour_id, value, "${2}hour")
    elseif option == furniture_crafting_hour_id
        furniture_crafting_hour = value
        mcm.setSliderOptionValue(furniture_crafting_hour_id, value, "${2}hour")
    elseif option == misc_crafting_hour_id
        misc_crafting_hour = value
        mcm.setSliderOptionValue(misc_crafting_hour_id, value, "${2}hour")
    else
        return False
    endif
    return True
EndFunction

bool Function handle_option_highlighted(int option)
    if option == building_crafting_hour_id || \
            option == furniture_crafting_hour_id
        mcm.setInfoText("$time_passed_performing_this_action")
    elseif option == misc_crafting_hour_id
        mcm.setInfoText("$hearthfire_misc_info")
    else
        return False
    endif
    return True
EndFunction
