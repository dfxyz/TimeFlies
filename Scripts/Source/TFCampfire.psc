Scriptname TFCampfire extends Quest

TimeFliesMain Property main Auto
TimeFliesMCM Property mcm Auto

int prefix
float small_tent_crafting_hour
int small_tent_crafting_hour_id
float large_tent_crafting_hour
int large_tent_crafting_hour_id
float backpack_crafting_hour
int backpack_crafting_hour_id
float misc_crafting_minute
int misc_crafting_minute_id
float cooking_pot_crafting_hour
int cooking_pot_crafting_hour_id
float stone_hatchet_crafting_minute
int stone_hatchet_crafting_minute_id
float stone_arrow_crafting_minute
int stone_arrow_crafting_minute_id
bool reclaiming_amulet
bool reclaiming_backpack
bool removing_bed_roll
Form cooking_pot
Form stone_hatchet
Form stone_arrow
Form[] backpacks
Form[] cloaks
Form[] small_tents
Form[] large_tents
Form[] tents_with_two_bed_rolls
Form[] misc_items

Function initialize()
    prefix = main.get_prefix(Game.getFormFromFile(0x26bf1, "Campfire.esm"))
    if prefix == -1
        return
    endif

    reclaiming_amulet = False
    reclaiming_backpack = False
    removing_bed_roll = False

    cooking_pot = Game.getFormFromFile(0x19849, "Campfire.esm")
    stone_hatchet = Game.getFormFromFile(0x4103d, "Campfire.esm")
    stone_arrow = Game.getFormFromFile(0x415d7, "Campfire.esm")

    backpacks = new Form[3]
    backpacks[0] = Game.getFormFromFile(0x2c260, "Campfire.esm")
    backpacks[1] = Game.getFormFromFile(0x2c261, "Campfire.esm")
    backpacks[2] = Game.getFormFromFile(0x2c262, "Campfire.esm")

    cloaks = new Form[4]
    cloaks[0] = Game.getFormFromFile(0x3fa9c, "Campfire.esm")
    cloaks[1] = Game.getFormFromFile(0x3fa9d, "Campfire.esm")
    cloaks[2] = Game.getFormFromFile(0x3fa9e, "Campfire.esm")
    cloaks[3] = Game.getFormFromFile(0x3fa9f, "Campfire.esm")

    ;; small tents with only one bed roll
    small_tents = new Form[2]
    small_tents[0] = Game.getFormFromFile(0x1a314, "Campfire.esm")
    small_tents[1] = Game.getFormFromFile(0x36b4e, "Campfire.esm")

    ;; large tents with only one bed roll
    large_tents = new Form[2]
    large_tents[0] = Game.getFormFromFile(0x1a348, "Campfire.esm")
    large_tents[1] = Game.getFormFromFile(0x38cbc, "Campfire.esm")

    tents_with_two_bed_rolls = new Form[4]
    tents_with_two_bed_rolls[0] = Game.getFormFromFile(0x1a347, "Campfire.esm")
    tents_with_two_bed_rolls[1] = Game.getFormFromFile(0x38cbd, "Campfire.esm")
    tents_with_two_bed_rolls[2] = Game.getFormFromFile(0x624fb, "Campfire.esm")
    tents_with_two_bed_rolls[3] = Game.getFormFromFile(0x36b70, "Campfire.esm")

    misc_items = new Form[5]
    misc_items[0] = Game.getFormFromFile(0x536e4, "Campfire.esm")
    misc_items[1] = Game.getFormFromFile(0x38680, "Campfire.esm")
    misc_items[2] = Game.getFormFromFile(0x36b4f, "Campfire.esm")
    misc_items[3] = Game.getFormFromFile(0x19daf, "Campfire.esm")
    misc_items[4] = Game.getFormFromFile(0x250ca, "Campfire.esm")
EndFunction

Function load_defaults()
    small_tent_crafting_hour = 2.5
    large_tent_crafting_hour = 3.0
    backpack_crafting_hour = 2.0
    cooking_pot_crafting_hour = 2.0
    stone_hatchet_crafting_minute = 45.0
    stone_arrow_crafting_minute = 45.0
    misc_crafting_minute = 15.0
EndFunction

bool Function handle_added_item(Form item)
    Armor a = item as Armor
    if a.isJewelry() && reclaiming_amulet
        reclaiming_amulet = False
        return True
    endif

    if main.get_prefix(item) != prefix
        return False
    endif

   if item == cooking_pot
        main._debug("Cooking pot made")
        main.pass_time( \
            cooking_pot_crafting_hour * main.random_time_multiplier())
    elseif item == stone_hatchet
        main._debug("Stone hatchet made")
        main.pass_time( \
            stone_hatchet_crafting_minute * main.random_time_multiplier() / 60)
    elseif item == stone_arrow
        main._debug("Stone arrow made")
        main.pass_time( \
            stone_arrow_crafting_minute * main.random_time_multiplier() / 60)
    elseif backpacks.find(item) > -1
        if reclaiming_backpack
            reclaiming_backpack = False
        else
            main._debug("Backpack made")
            main.pass_time( \
                backpack_crafting_hour * main.random_time_multiplier())
        endif
    elseif cloaks.find(item) > -1
        main._debug("Cloak made")
        main.pass_time( \
            main.clothes_crafting_hour * main.random_time_multiplier())
    elseif small_tents.find(item) > -1
        if removing_bed_roll
            removing_bed_roll = False
        else
            main._debug("Small tent made")
            main.pass_time( \
                small_tent_crafting_hour * main.random_time_multiplier())
        endif
    elseif large_tents.find(item) > -1
        if removing_bed_roll
            removing_bed_roll = False
        else
            main._debug("Large tent made")
            main.pass_time( \
                large_tent_crafting_hour * main.random_time_multiplier())
        endif
    elseif misc_items.find(item) > -1
        main._debug("Campfire misc item made")
        main.pass_time( \
            misc_crafting_minute * main.random_time_multiplier() / 60)
    else
        main._debug("Campfire misc item ignored")
    endif
    return True
EndFunction

bool Function handle_removed_item(Form item)
    int id = item.getFormID() - Math.leftShift(prefix, 24)
    if tents_with_two_bed_rolls.find(item) > -1
        main._debug("Removing bed roll")
        removing_bed_roll = True
        return True
    elseif 0x2d81d <= id && id <= 0x2f8ea
        main._debug("Separating backpack") 
        reclaiming_amulet = True
        reclaiming_backpack = True
        return True
    else
        return False
    endif
EndFunction

Function save_settings()
    mcm.fiss.saveFloat("campfire_small_tent_crafting_hour", \
        small_tent_crafting_hour)
    mcm.fiss.saveFloat("campfire_large_tent_crafting_hour", \
        large_tent_crafting_hour)
    mcm.fiss.saveFloat("campfire_backpack_crafting_hour", \
        backpack_crafting_hour)
    mcm.fiss.saveFloat("campfire_cooking_pot_crafting_hour", \
        cooking_pot_crafting_hour)
    mcm.fiss.saveFloat("campfire_stone_axe_crafting_minute", \
        stone_hatchet_crafting_minute)
    mcm.fiss.saveFloat("campfire_stone_arrow_crafting_minute", \
        stone_arrow_crafting_minute)
    mcm.fiss.saveFloat("campfire_misc_crafting_minute", misc_crafting_minute)
EndFunction

Function load_settings()
    small_tent_crafting_hour = \
        mcm.fiss.loadFloat("campfire_small_tent_crafting_hour")
    large_tent_crafting_hour = \
        mcm.fiss.loadFloat("campfire_large_tent_crafting_hour")
    backpack_crafting_hour = \
        mcm.fiss.loadFloat("campfire_backpack_crafting_hour")
    cooking_pot_crafting_hour = \
        mcm.fiss.loadFloat("campfire_cooking_pot_crafting_hour")
    stone_hatchet_crafting_minute = \
        mcm.fiss.loadFloat("campfire_stone_axe_crafting_minute")
    stone_arrow_crafting_minute = \
        mcm.fiss.loadFloat("campfire_stone_arrow_crafting_minute")
    misc_crafting_minute = mcm.fiss.loadFloat("campfire_misc_crafting_minute")
EndFunction

bool Function handle_page(string page)
    if page != "$campfire"
        return False
    endif

    if prefix == -1
        mcm.addTextOption("", "$campfire_not_installed")
    else
        mcm.setCursorFillMode(mcm.TOP_TO_BOTTOM)
        mcm.addHeaderOption("$options")
        small_tent_crafting_hour_id = mcm.addSliderOption( \
            "$campfire_small_tent", small_tent_crafting_hour, "${2}hour")
        large_tent_crafting_hour_id = mcm.addSliderOption( \
            "$campfire_large_tent", large_tent_crafting_hour, "${2}hour")
        backpack_crafting_hour_id = mcm.addSliderOption( \
            "$campfire_backpack", backpack_crafting_hour, "${2}hour")
        cooking_pot_crafting_hour_id = mcm.addSliderOption( \
            "$campfire_cooking_pot", cooking_pot_crafting_hour, "${2}hour")
        stone_hatchet_crafting_minute_id = mcm.addSliderOption( \
            "$campfire_stone_axe", stone_hatchet_crafting_minute, "${0}min")
        stone_arrow_crafting_minute_id = mcm.addSliderOption( \
            "$campfire_stone_arrow", stone_arrow_crafting_minute, "${0}min")
        misc_crafting_minute_id = mcm.addSliderOption( \
            "$campfire_misc", misc_crafting_minute, "${0}min")
    endif
    return True
EndFunction

bool Function handle_slider_opened(int option)
    if option == small_tent_crafting_hour_id
        mcm.setSliderDialogStartValue(small_tent_crafting_hour)
        mcm.setSliderDialogDefaultValue(2.5)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == large_tent_crafting_hour_id
        mcm.setSliderDialogStartValue(large_tent_crafting_hour)
        mcm.setSliderDialogDefaultValue(3.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == backpack_crafting_hour_id
        mcm.setSliderDialogStartValue(backpack_crafting_hour)
        mcm.setSliderDialogDefaultValue(2.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == cooking_pot_crafting_hour_id
        mcm.setSliderDialogStartValue(cooking_pot_crafting_hour)
        mcm.setSliderDialogDefaultValue(2.0)
        mcm.setSliderDialogRange(0.0, 8.0)
        mcm.setSliderDialogInterval(0.25)
    elseif option == stone_hatchet_crafting_minute_id
        mcm.setSliderDialogStartValue(stone_hatchet_crafting_minute)
        mcm.setSliderDialogDefaultValue(45.0)
        mcm.setSliderDialogRange(0.0, 90.0)
        mcm.setSliderDialogInterval(1.0)
    elseif option == stone_arrow_crafting_minute_id
        mcm.setSliderDialogStartValue(stone_arrow_crafting_minute)
        mcm.setSliderDialogDefaultValue(45.0)
        mcm.setSliderDialogRange(0.0, 90.0)
        mcm.setSliderDialogInterval(1.0)
    elseif option == misc_crafting_minute_id
        mcm.setSliderDialogStartValue(misc_crafting_minute)
        mcm.setSliderDialogDefaultValue(15.0)
        mcm.setSliderDialogRange(0.0, 60.0)
        mcm.setSliderDialogInterval(1.0)
    else
        return False
    endif
    return True
EndFunction

bool Function handle_slider_accepted(int option, float value)
    if option == small_tent_crafting_hour_id
        small_tent_crafting_hour = value
        mcm.setSliderOptionValue(small_tent_crafting_hour_id, value, "${2}hour")
    elseif option == large_tent_crafting_hour_id
        large_tent_crafting_hour = value
        mcm.setSliderOptionValue(large_tent_crafting_hour_id, value, "${2}hour")
    elseif option == backpack_crafting_hour_id
        backpack_crafting_hour = value
        mcm.setSliderOptionValue(backpack_crafting_hour_id, value, "${2}hour")
    elseif option == cooking_pot_crafting_hour_id
        cooking_pot_crafting_hour = value
        mcm.setSliderOptionValue( \
            cooking_pot_crafting_hour_id, value, "${2}hour")
    elseif option == stone_hatchet_crafting_minute_id
        stone_hatchet_crafting_minute = value
        mcm.setSliderOptionValue( \
            stone_hatchet_crafting_minute_id, value, "${0}min")
    elseif option == stone_arrow_crafting_minute_id
        stone_arrow_crafting_minute = value
        mcm.setSliderOptionValue( \
            stone_arrow_crafting_minute_id, value, "${0}min")
    elseif option == misc_crafting_minute_id
        misc_crafting_minute = value
        mcm.setSliderOptionValue(misc_crafting_minute_id, value, "${0}min")
    else
        return False
    endif
    return True
EndFunction

bool Function handle_option_highlighted(int option)
    if option == small_tent_crafting_hour_id || \
            option == large_tent_crafting_hour_id || \
            option == cooking_pot_crafting_hour_id || \
            option == stone_hatchet_crafting_minute_id || \
            option == stone_arrow_crafting_minute_id
        mcm.setInfoText("$time_passed_performing_this_action")
    elseif option == misc_crafting_minute_id
        mcm.setInfoText("$campfire_misc_info")
    else
        return False
    endif
    return True
EndFunction
