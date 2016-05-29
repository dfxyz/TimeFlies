Scriptname TimeFliesMCM extends SKI_ConfigBase

TimeFliesMain Property main Auto
TimeFliesMods Property mods Auto


bool debug_mode = True
Function _debug(string str)
    if debug_mode
        Debug.trace("Time Flies MCM: " + str)
    endif
EndFunction


Event OnConfigInit()
    mods.prepare_pages()
    main.is_enabled = False
    load_defaults()
    initialize()
    _debug("Initialized for the first time")
EndEvent

int Function GetVersion()
    return 1  ;; increases version number if new mod(s) support added
EndFunction

Event OnVersionUpdate(int version)
    ;; if added support for new mods, things needed to do:
    ;; 1. re-prepare menu pages;
    ;; 2. initialize related settings for mods recently supported;
    mods.prepare_pages()
    mods.update(version)

    _debug("Updated to version " + GetVersion())
EndEvent


Function initialize()
    _debug("Initializing...")
    if main.is_enabled
        ;; always tracks those menus because related options were removed
        registerForMenu("InventoryMenu")
        registerForMenu("Training Menu")
        registerForMenu("ContainerMenu")
        registerForMenu("Book Menu")
        registerForMenu("Lockpicking Menu")
        registerForMenu("BarterMenu")
        registerForMenu("GiftMenu")

        if main.crafting_takes_time
            registerForMenu("Crafting Menu")
        else
            unregisterForMenu("Crafting Menu")
        endif

        ;; initialize other mods
        mods.initialize()
    else
        unregisterForAllMenus()
    endif

    main.is_paused = False
    register_hotkey()
    _debug("Initialized")
EndFunction

Function load_defaults()
    ;; General
    main.random_crafting_time = True
    main.random_time_multiplier_min = 0.67
    main.random_time_multiplier_max = 1.0
    main.show_notification = True
    main.notification_threshold = 5.0
    main.hotkey = 0

    ;; Reading
    main.reading_time_multiplier = 1.0
    main.reading_increases_speech_multiplier = 1.0
    main.spell_learning_hour = 2.0

    ;; Training & Eating & Looting & Lockpicking & Trading
    main.training_hour = 2.0
    main.eating_minute = 5.0
    main.looting_time_multiplier = 1.0
    main.lockpicking_time_multiplier = 1.0
    main.trading_time_multiplier = 1.0

    ;; Crafting
    main.crafting_takes_time = True
    main.helmet_crafting_hour = 3.0
    main.armor_crafting_hour = 6.0
    main.gauntlets_crafting_hour = 3.0
    main.boots_crafting_hour = 3.0
    main.shield_crafting_hour = 4.0
    main.clothes_crafting_hour = 2.0
    main.jewelry_crafting_hour = 2.5
    main.staff_crafting_hour = 4.0
    main.bow_crafting_hour = 4.0
    main.ammo_crafting_hour = 1.5
    main.dagger_crafting_hour = 3.0
    main.sword_crafting_hour = 4.0
    main.waraxe_crafting_hour = 4.0
    main.mace_crafting_hour = 4.0
    main.greatsword_crafting_hour = 5.0
    main.battleaxe_crafting_hour = 5.0
    main.warhammer_crafting_hour = 5.0
    main.smelting_hour = 2.0
    main.leather_crafting_hour = 1.0
    main.armor_improving_minute = 15.0
    main.weapon_improving_minute = 15.0
    main.enchanting_hour = 1.0
    main.alchemy_minute = 30.0
    main.cooking_minute = 15.0

    ;; Other Mods
    mods.load_defaults()
EndFunction


Function register_hotkey()
    if main.hotkey
        registerForKey(main.hotkey)
    else
        unregisterForAllKeys()
    endif
EndFunction

Event OnOptionKeyMapChange(int option, int keycode, \
        string conflict_ctrl, string conflict_name)
    if conflict_ctrl != ""
        if conflict_name != ""
            showMessage("$key_already_mapped_to{" + conflict_ctrl \
                + "}{" + conflict_name + "}")
        else
            showMessage("$key_already_mapped_to{" + conflict_ctrl + "}")
        endif
        return
    endif

    if option == hotkey_id
        main.hotkey = keycode
        register_hotkey()
        forcePageReset()
    endif
EndEvent

Event OnKeyUp(int keycode, float hold_time)
    ;; hotkey only works in "normal" state
    if UI.isMenuOpen("Console") || Utility.isInMenuMode() \
            || Game.getPlayer().getSitState() != 0
        return
    elseif keycode == main.hotkey
        if !main.is_enabled
            Debug.notification("$mod_not_enabled")
            return
        endif

        if main.is_paused
            Debug.notification("$mod_resumed")
            main.is_paused = False
        else
            Debug.notification("$mod_paused")
            main.is_paused = True
        endif
    endif
EndEvent


import FISSFactory
FISSInterface Property fiss Auto
Function save_settings()
    fiss = FISSFactory.getFISS()
    if !fiss
        return
    endif

    _debug("Saving basic settings...")
    fiss.beginSave("TimeFlies.xml", "Time Flies")

    ;; General
    fiss.saveBool("random_crafting_time", main.random_crafting_time)
    fiss.saveFloat("random_time_multiplier_min", \
        main.random_time_multiplier_min)
    fiss.saveFloat("random_time_multiplier_max", \
        main.random_time_multiplier_max)
    fiss.saveBool("show_notification", main.show_notification)
    fiss.saveFloat("notification_threshold", main.notification_threshold)
    fiss.saveInt("hotkey", main.hotkey)
    
    ;; Reading
    fiss.saveFloat("reading_time_multiplier", main.reading_time_multiplier)
    fiss.saveFloat("reading_increases_speech_multiplier", \
        main.reading_increases_speech_multiplier)
    fiss.saveFloat("spell_learning_hour", main.spell_learning_hour)

    ;; Training & Eating & Looting & Lockpicking & Trading
    fiss.saveFloat("training_hour", main.training_hour)
    fiss.saveFloat("eating_minute", main.eating_minute)
    fiss.saveFloat("looting_time_multiplier", main.looting_time_multiplier)
    fiss.saveFloat("lockpicking_time_multiplier", \
        main.lockpicking_time_multiplier)
    fiss.saveFloat("trading_time_multiplier", main.trading_time_multiplier)

    ;; Crafting
    fiss.saveBool("crafting_takes_time", main.crafting_takes_time)
    fiss.saveFloat("helmet_crafting_hour", main.helmet_crafting_hour)
    fiss.saveFloat("armor_crafting_hour", main.armor_crafting_hour)
    fiss.saveFloat("gauntlets_crafting_hour", main.gauntlets_crafting_hour)
    fiss.saveFloat("boots_crafting_hour", main.boots_crafting_hour)
    fiss.saveFloat("shield_crafting_hour", main.shield_crafting_hour)
    fiss.saveFloat("clothes_crafting_hour", main.clothes_crafting_hour)
    fiss.saveFloat("jewelry_crafting_hour", main.jewelry_crafting_hour)
    fiss.saveFloat("staff_crafting_hour", main.staff_crafting_hour)
    fiss.saveFloat("bow_crafting_hour", main.bow_crafting_hour)
    fiss.saveFloat("ammo_crafting_hour", main.ammo_crafting_hour)
    fiss.saveFloat("dagger_crafting_hour", main.dagger_crafting_hour)
    fiss.saveFloat("sword_crafting_hour", main.sword_crafting_hour)
    fiss.saveFloat("waraxe_crafting_hour", main.waraxe_crafting_hour)
    fiss.saveFloat("mace_crafting_hour", main.mace_crafting_hour)
    fiss.saveFloat("greatsword_crafting_hour", \
        main.greatsword_crafting_hour)
    fiss.saveFloat("battleaxe_crafting_hour", main.battleaxe_crafting_hour)
    fiss.saveFloat("warhammer_crafting_hour", main.warhammer_crafting_hour)
    fiss.saveFloat("smelting_hour", main.smelting_hour)
    fiss.saveFloat("leather_crafting_hour", main.leather_crafting_hour)
    fiss.saveFloat("armor_improving_minute", main.armor_improving_minute)
    fiss.saveFloat("weapon_improving_minute", main.weapon_improving_minute)
    fiss.saveFloat("enchanting_hour", main.enchanting_hour)
    fiss.saveFloat("alchemy_minute", main.alchemy_minute)
    fiss.saveFloat("cooking_minute", main.cooking_minute)

    ;; Other Mods
    mods.save_settings()

    string result = fiss.endSave()
    if result != ""
        _debug("Saving finished with result - " + result)
    endif
EndFunction

Function load_settings()
    fiss = FISSFactory.getFISS()
    if !fiss
        return
    endif
    
    _debug("Loading settings...")
    fiss.beginLoad("TimeFlies.xml")

    ;; General
    main.random_crafting_time = fiss.loadBool("random_crafting_time")
    main.random_time_multiplier_min = \
        fiss.loadFloat("random_time_multiplier_min")
    main.random_time_multiplier_max = \
        fiss.loadFloat("random_time_multiplier_max")
    main.show_notification = fiss.loadBool("show_notification")
    main.notification_threshold = fiss.loadFloat("notification_threshold")
    main.hotkey = fiss.loadInt("hotkey")
    
    ;; Reading
    main.reading_time_multiplier = \
        fiss.loadFloat("reading_time_multiplier")
    main.reading_increases_speech_multiplier = \
        fiss.loadFloat("reading_increases_speech_multiplier")
    main.spell_learning_hour = fiss.loadFloat("spell_learning_hour")

    ;; Training & Eating & Looting & Lockpicking & Trading
    main.training_hour = fiss.loadFloat("training_hour")
    main.eating_minute = fiss.loadFloat("eating_minute")
    main.looting_time_multiplier = \
        fiss.loadFloat("looting_time_multiplier")
    main.lockpicking_time_multiplier = \
        fiss.loadFloat("lockpicking_time_multiplier")
    main.trading_time_multiplier = \
        fiss.loadFloat("trading_time_multiplier")

    ;; Crafting
    main.crafting_takes_time = fiss.loadBool("crafting_takes_time")
    main.helmet_crafting_hour = fiss.loadFloat("helmet_crafting_hour")
    main.armor_crafting_hour = fiss.loadFloat("armor_crafting_hour")
    main.gauntlets_crafting_hour = \
        fiss.loadFloat("gauntlets_crafting_hour")
    main.boots_crafting_hour = fiss.loadFloat("boots_crafting_hour")
    main.shield_crafting_hour = fiss.loadFloat("shield_crafting_hour")
    main.clothes_crafting_hour = fiss.loadFloat("clothes_crafting_hour")
    main.jewelry_crafting_hour = fiss.loadFloat("jewelry_crafting_hour")
    main.staff_crafting_hour = fiss.loadFloat("staff_crafting_hour")
    main.bow_crafting_hour = fiss.loadFloat("bow_crafting_hour")
    main.ammo_crafting_hour = fiss.loadFloat("ammo_crafting_hour")
    main.dagger_crafting_hour = fiss.loadFloat("dagger_crafting_hour")
    main.sword_crafting_hour = fiss.loadFloat("sword_crafting_hour")
    main.waraxe_crafting_hour = fiss.loadFloat("waraxe_crafting_hour")
    main.mace_crafting_hour = fiss.loadFloat("mace_crafting_hour")
    main.greatsword_crafting_hour = \
        fiss.loadFloat("greatsword_crafting_hour")
    main.battleaxe_crafting_hour = \
        fiss.loadFloat("battleaxe_crafting_hour")
    main.warhammer_crafting_hour = \
        fiss.loadFloat("warhammer_crafting_hour")
    main.smelting_hour = fiss.loadFloat("smelting_hour")
    main.leather_crafting_hour = fiss.loadFloat("leather_crafting_hour")
    main.armor_improving_minute = fiss.loadFloat("armor_improving_minute")
    main.weapon_improving_minute = \
        fiss.loadFloat("weapon_improving_minute")
    main.enchanting_hour = fiss.loadFloat("enchanting_hour")
    main.alchemy_minute = fiss.loadFloat("alchemy_minute")
    main.cooking_minute = fiss.loadFloat("cooking_minute")

    ;; Other Mods
    mods.load_settings()

    string result = fiss.endLoad()
    if result != ""
        _debug("Loading finished with result - " + result)
    endif
    initialize()
EndFunction


;; General
int is_enabled_id
int random_crafting_time_id
int random_time_multiplier_min_id
int random_time_multiplier_max_id
int show_notification_id
int notification_threshold_id
int save_id
int load_id
int load_defaults_id
int hotkey_id
int reinitialize_id

;; Reading
int reading_time_multiplier_id
int reading_increases_speech_multiplier_id
int spell_learning_hour_id

;; Training & Eating & Looting & Trading
int training_hour_id
int eating_minute_id
int looting_time_multiplier_id
int lockpicking_time_multiplier_id
int trading_time_multiplier_id

;; Crafting
int crafting_takes_time_id
int helmet_crafting_hour_id
int armor_crafting_hour_id
int gauntlets_crafting_hour_id
int boots_crafting_hour_id
int shield_crafting_hour_id
int leather_crafting_hour_id
int clothes_crafting_hour_id
int jewelry_crafting_hour_id
int staff_crafting_hour_id
int bow_crafting_hour_id
int ammo_crafting_hour_id
int dagger_crafting_hour_id
int sword_crafting_hour_id
int waraxe_crafting_hour_id
int mace_crafting_hour_id
int greatsword_crafting_hour_id
int battleaxe_crafting_hour_id
int warhammer_crafting_hour_id
int smelting_hour_id
int armor_improving_minute_id
int weapon_improving_minute_id
int enchanting_hour_id
int alchemy_minute_id
int cooking_minute_id

Event OnPageReset(string page)
    if page == ""
        loadCustomContent("TimeFlies/TimeFlies.dds", 180, 120)
        return
    else
        unloadCustomContent()
    endif

    if page == "$general"
        setCursorFillMode(TOP_TO_BOTTOM)
        addHeaderOption("$options")
        is_enabled_id = addToggleOption("$enable?", main.is_enabled)
        random_crafting_time_id = addToggleOption( \
            "$random_crafting_time", main.random_crafting_time)
        random_time_multiplier_min_id = addSliderOption( \
            "$random_time_multiplier_min", \
            main.random_time_multiplier_min, \
            "$x{2}")
        random_time_multiplier_max_id = addSliderOption( \
            "$random_time_multiplier_max", \
            main.random_time_multiplier_max, \
            "$x{2}")
        show_notification_id = addToggleOption("$show_notification", \
            main.show_notification)
        notification_threshold_id = addSliderOption( \
            "$notification_threshold", \
            main.notification_threshold, \
            "${0}min")
        hotkey_id = addKeyMapOption("$hotkey", main.hotkey)
        if main.is_paused
            addTextOption("", "$mod_paused")
        endif

        setCursorPosition(1)
        addHeaderOption("$save_and_load")
        fiss = FISSFactory.getFISS()
        int save_flag = OPTION_FLAG_NONE
        int load_flag = OPTION_FLAG_NONE
        if !fiss
            save_flag = OPTION_FLAG_DISABLED
            load_flag = OPTION_FLAG_DISABLED
        else
            fiss.beginLoad("TimeFlies.xml")
            if fiss.endLoad() != ""
                load_flag = OPTION_FLAG_DISABLED
            endif
        endif
        save_id = addTextOption("$save", "", save_flag)
        load_id = addTextOption("$load", "", load_flag)
        load_defaults_id = addTextOption("$load_defaults", "", OPTION_FLAG_NONE)
        setCursorPosition(11)
        addHeaderOption("$maintenance")
        reinitialize_id = addTextOption("$reinitialize", "", OPTION_FLAG_NONE)

    elseif page == "$crafting"
        setCursorFillMode(TOP_TO_BOTTOM)
        addHeaderOption("$options")
        crafting_takes_time_id = addToggleOption("$crafting_takes_time", \
            main.crafting_takes_time)

        addHeaderOption("$armors")
        armor_improving_minute_id = addSliderOption( \
            "$armor_improving", main.armor_improving_minute, \
            "${0}min")
        helmet_crafting_hour_id = addSliderOption( \
            "$helmet", main.helmet_crafting_hour, "${2}hour")
        armor_crafting_hour_id = addSliderOption( \
            "$cuirass", main.armor_crafting_hour, "${2}hour")
        gauntlets_crafting_hour_id = addSliderOption( \
            "$gauntlets", main.gauntlets_crafting_hour, \
            "${2}hour")
        boots_crafting_hour_id = addSliderOption( \
            "$boots", main.boots_crafting_hour, "${2}hour")
        shield_crafting_hour_id = addSliderOption( \
            "$shield", main.shield_crafting_hour, "${2}hour")

        addHeaderOption("$others")
        clothes_crafting_hour_id = addSliderOption( \
            "$clothes", main.clothes_crafting_hour, \
            "${2}hour")
        jewelry_crafting_hour_id = addSliderOption( \
            "$jewelry", main.jewelry_crafting_hour, \
            "${2}hour")
        enchanting_hour_id = addSliderOption( \
            "$enchanting", main.enchanting_hour, "${2}hour")
        alchemy_minute_id = addSliderOption( \
            "$alchemy", main.alchemy_minute, "${0}min")
        cooking_minute_id = addSliderOption( \
            "$cooking", main.cooking_minute, "${0}min")

        setCursorPosition(1)
        addHeaderOption("$weapons")
        weapon_improving_minute_id = addSliderOption( \
            "$weapon_improving", main.weapon_improving_minute, \
            "${0}min")
        bow_crafting_hour_id = addSliderOption( \
            "$bow", main.bow_crafting_hour, "${2}hour")
        ammo_crafting_hour_id = addSliderOption( \
            "$ammo", main.ammo_crafting_hour, "${2}hour")
        dagger_crafting_hour_id = addSliderOption( \
            "$dagger", main.dagger_crafting_hour, "${2}hour")
        sword_crafting_hour_id = addSliderOption( \
            "$sword", main.sword_crafting_hour, "${2}hour")
        waraxe_crafting_hour_id = addSliderOption( \
            "$waraxe", main.waraxe_crafting_hour, "${2}hour")
        mace_crafting_hour_id = addSliderOption( \
            "$mace", main.mace_crafting_hour, "${2}hour")
        greatsword_crafting_hour_id = addSliderOption( \
            "$greatsword", main.greatsword_crafting_hour, \
            "${2}hour")
        battleaxe_crafting_hour_id = addSliderOption( \
            "$battleaxe", main.battleaxe_crafting_hour, \
            "${2}hour")
        warhammer_crafting_hour_id = addSliderOption( \
            "$warhammer", main.warhammer_crafting_hour, \
            "${2}hour")
        staff_crafting_hour_id = addSliderOption( \
            "$staff", main.staff_crafting_hour, "${2}hour")

        addHeaderOption("$smelting_and_tanning")
        smelting_hour_id = addSliderOption( \
            "$smelting", main.smelting_hour, "${2}hour")
        leather_crafting_hour_id = addSliderOption( \
            "$tanning", main.leather_crafting_hour, \
            "${2}hour")

    elseif page == "$others"
        setCursorFillMode(TOP_TO_BOTTOM)
        addHeaderOption("$multipliers")
        reading_time_multiplier_id = addSliderOption( \
            "$reading", main.reading_time_multiplier, \
            "$x{2}")
        reading_increases_speech_multiplier_id = addSliderOption( \
            "$reading_increases_speech", \
            main.reading_increases_speech_multiplier, "$x{2}")
        looting_time_multiplier_id = addSliderOption( \
            "$looting", main.looting_time_multiplier, \
            "$x{2}")
        lockpicking_time_multiplier_id = addSliderOption( \
            "$lockpicking", \
            main.lockpicking_time_multiplier, "$x{2}")
        trading_time_multiplier_id = addSliderOption( \
            "$trading", main.trading_time_multiplier, \
            "$x{2}")

        addHeaderOption("$other_actions")
        training_hour_id = addSliderOption( \
            "$training", main.training_hour, "${2}hour")
        spell_learning_hour_id = addSliderOption( \
            "$spell_learning", main.spell_learning_hour, "${2}hour")
        eating_minute_id = addSliderOption("$eating", \
            main.eating_minute, "${0}min")

    else
        mods.handle_page(page)
    endif
EndEvent

Event OnOptionSelect(int option)
    if option == is_enabled_id
        main.is_enabled = !main.is_enabled
        setToggleOptionValue(is_enabled_id, main.is_enabled)
        initialize()

    elseif option == reinitialize_id
        initialize()
        showMessage("$reinitialized", False)

    elseif option == save_id
        bool choice = showMessage("$save?", True, "$save", "$cancel")
        if choice
            save_settings()
            forcePageReset()
        endif

    elseif option == load_id
        bool choice = showMessage("$load?", True, "$load", "$cancel")
        if choice
            load_settings()
            forcePageReset()
        endif

    elseif option == load_defaults_id
        load_defaults()
        initialize()
        forcePageReset()

    elseif option == random_crafting_time_id
        main.random_crafting_time = !main.random_crafting_time
        setToggleOptionValue(random_crafting_time_id, \
            main.random_crafting_time)

    elseif option == show_notification_id
        main.show_notification = !main.show_notification
        setToggleOptionValue(show_notification_id, main.show_notification)

    else
        mods.handle_option_selected(option)
    endif
EndEvent


Event OnOptionSliderOpen(int option)
    if option == random_time_multiplier_min_id
        setSliderDialogStartValue(main.random_time_multiplier_min)
        setSliderDialogDefaultValue(0.67)
        setSliderDialogRange(0.50, 1.00)
        setSliderDialogInterval(0.01)

    elseif option == random_time_multiplier_max_id
        setSliderDialogStartValue(main.random_time_multiplier_max)
        setSliderDialogDefaultValue(1.00)
        setSliderDialogRange(1.00, 2.00)
        setSliderDialogInterval(0.01)

    elseif option == notification_threshold_id
        setSliderDialogStartValue(main.notification_threshold)
        setSliderDialogDefaultValue(5.0)
        setSliderDialogRange(1.0, 60.0)
        setSliderDialogInterval(1.0)

    elseif option == reading_time_multiplier_id
        setSliderDialogStartValue(main.reading_time_multiplier)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.00, 5.00)
        setSliderDialogInterval(0.05)

    elseif option == reading_increases_speech_multiplier_id
        setSliderDialogStartValue( \
            main.reading_increases_speech_multiplier)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.00, 5.00)
        setSliderDialogInterval(0.05)

    elseif option == spell_learning_hour_id
        setSliderDialogStartValue(main.spell_learning_hour)
        setSliderDialogDefaultValue(2.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == training_hour_id
        setSliderDialogStartValue(main.training_hour)
        setSliderDialogDefaultValue(2.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == eating_minute_id
        setSliderDialogStartValue(main.eating_minute)
        setSliderDialogDefaultValue(5.0)
        setSliderDialogRange(0.0, 30.0)
        setSliderDialogInterval(1.0)

    elseif option == looting_time_multiplier_id
        setSliderDialogStartValue(main.looting_time_multiplier)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.0, 5.0)
        setSliderDialogInterval(0.05)

    elseif option == lockpicking_time_multiplier_id
        setSliderDialogStartValue(main.lockpicking_time_multiplier)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.0, 5.0)
        setSliderDialogInterval(0.05)

    elseif option == trading_time_multiplier_id
        setSliderDialogStartValue(main.trading_time_multiplier)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.0, 5.0)
        setSliderDialogInterval(0.05)

    elseif option == helmet_crafting_hour_id
        setSliderDialogStartValue(main.helmet_crafting_hour)
        setSliderDialogDefaultValue(3.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == armor_crafting_hour_id
        setSliderDialogStartValue(main.armor_crafting_hour)
        setSliderDialogDefaultValue(6.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == gauntlets_crafting_hour_id
        setSliderDialogStartValue(main.gauntlets_crafting_hour)
        setSliderDialogDefaultValue(3.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == boots_crafting_hour_id
        setSliderDialogStartValue(main.boots_crafting_hour)
        setSliderDialogDefaultValue(3.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == shield_crafting_hour_id
        setSliderDialogStartValue(main.shield_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == clothes_crafting_hour_id
        setSliderDialogStartValue(main.clothes_crafting_hour)
        setSliderDialogDefaultValue(2.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == jewelry_crafting_hour_id
        setSliderDialogStartValue(main.jewelry_crafting_hour)
        setSliderDialogDefaultValue(2.5)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == staff_crafting_hour_id
        setSliderDialogStartValue(main.staff_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == bow_crafting_hour_id
        setSliderDialogStartValue(main.bow_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == ammo_crafting_hour_id
        setSliderDialogStartValue(main.ammo_crafting_hour)
        setSliderDialogDefaultValue(1.5)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == dagger_crafting_hour_id
        setSliderDialogStartValue(main.dagger_crafting_hour)
        setSliderDialogDefaultValue(3.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == sword_crafting_hour_id
        setSliderDialogStartValue(main.sword_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == waraxe_crafting_hour_id
        setSliderDialogStartValue(main.waraxe_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == mace_crafting_hour_id
        setSliderDialogStartValue(main.mace_crafting_hour)
        setSliderDialogDefaultValue(4.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == greatsword_crafting_hour_id
        setSliderDialogStartValue(main.greatsword_crafting_hour)
        setSliderDialogDefaultValue(5.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == battleaxe_crafting_hour_id
        setSliderDialogStartValue(main.battleaxe_crafting_hour)
        setSliderDialogDefaultValue(5.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == warhammer_crafting_hour_id
        setSliderDialogStartValue(main.waraxe_crafting_hour)
        setSliderDialogDefaultValue(5.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == smelting_hour_id
        setSliderDialogStartValue(main.smelting_hour)
        setSliderDialogDefaultValue(2.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == leather_crafting_hour_id
        setSliderDialogStartValue(main.leather_crafting_hour)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == armor_improving_minute_id
        setSliderDialogStartValue(main.armor_improving_minute)
        setSliderDialogDefaultValue(15.0)
        setSliderDialogRange(0.0, 60.0)
        setSliderDialogInterval(1.0)

    elseif option == weapon_improving_minute_id
        setSliderDialogStartValue(main.weapon_improving_minute)
        setSliderDialogDefaultValue(15.0)
        setSliderDialogRange(0.0, 60.0)
        setSliderDialogInterval(1.0)

    elseif option == enchanting_hour_id
        setSliderDialogStartValue(main.enchanting_hour)
        setSliderDialogDefaultValue(1.0)
        setSliderDialogRange(0.0, 8.0)
        setSliderDialogInterval(0.25)

    elseif option == alchemy_minute_id
        setSliderDialogStartValue(main.alchemy_minute)
        setSliderDialogDefaultValue(30.0)
        setSliderDialogRange(0.0, 60.0)
        setSliderDialogInterval(1.0)

    elseif option == cooking_minute_id
        setSliderDialogStartValue(main.cooking_minute)
        setSliderDialogDefaultValue(15.0)
        setSliderDialogRange(0.0, 60.0)
        setSliderDialogInterval(1.0)

    else
        mods.handle_slider_opened(option)
    endif
EndEvent

Event OnOptionSliderAccept(int option, float value)
    if option == random_time_multiplier_min_id
        main.random_time_multiplier_min = value
        setSliderOptionValue(random_time_multiplier_min_id, value, "$x{2}")

    elseif option == random_time_multiplier_max_id
        main.random_time_multiplier_max = value
        setSliderOptionValue(random_time_multiplier_max_id, value, "$x{2}")

    elseif option == notification_threshold_id
        main.notification_threshold = value
        setSliderOptionValue(notification_threshold_id, value, "${0}min")

    elseif option == reading_time_multiplier_id
        main.reading_time_multiplier = value
        setSliderOptionValue(reading_time_multiplier_id, value, "$x{2}")

    elseif option == reading_increases_speech_multiplier_id
        main.reading_increases_speech_multiplier = value
        setSliderOptionValue(reading_increases_speech_multiplier_id, value, \
            "$x{2}")

    elseif option == spell_learning_hour_id
        main.spell_learning_hour = value
        setSliderOptionValue(spell_learning_hour_id, value, "${2}hour")

    elseif option == training_hour_id
        main.training_hour = value
        setSliderOptionValue(training_hour_id, value, "${2}hour")

    elseif option == eating_minute_id
        main.eating_minute = value
        setSliderOptionValue(eating_minute_id, value, "${0}min")

    elseif option == looting_time_multiplier_id
        main.looting_time_multiplier = value
        setSliderOptionValue(looting_time_multiplier_id, value, "$x{2}")

    elseif option == lockpicking_time_multiplier_id
        main.lockpicking_time_multiplier = value
        setSliderOptionValue(lockpicking_time_multiplier_id, value, "$x{2}")

    elseif option == trading_time_multiplier_id
        main.trading_time_multiplier = value
        setSliderOptionValue(trading_time_multiplier_id, value, "$x{2}")

    elseif option == helmet_crafting_hour_id
        main.helmet_crafting_hour = value
        setSliderOptionValue(helmet_crafting_hour_id, value, "${2}hour")

    elseif option == armor_crafting_hour_id
        main.armor_crafting_hour = value
        setSliderOptionValue(armor_crafting_hour_id, value, "${2}hour")

    elseif option == gauntlets_crafting_hour_id
        main.gauntlets_crafting_hour = value
        setSliderOptionValue(gauntlets_crafting_hour_id, value, "${2}hour")

    elseif option == boots_crafting_hour_id
        main.boots_crafting_hour = value
        setSliderOptionValue(boots_crafting_hour_id, value, "${2}hour")

    elseif option == shield_crafting_hour_id
        main.shield_crafting_hour = value
        setSliderOptionValue(shield_crafting_hour_id, value, "${2}hour")

    elseif option == clothes_crafting_hour_id
        main.clothes_crafting_hour = value
        setSliderOptionValue(clothes_crafting_hour_id, value, "${2}hour")

    elseif option == jewelry_crafting_hour_id
        main.jewelry_crafting_hour = value
        setSliderOptionValue(jewelry_crafting_hour_id, value, "${2}hour")

    elseif option == staff_crafting_hour_id
        main.staff_crafting_hour = value
        setSliderOptionValue(staff_crafting_hour_id, value, "${2}hour")

    elseif option == bow_crafting_hour_id
        main.bow_crafting_hour = value
        setSliderOptionValue(bow_crafting_hour_id, value, "${2}hour")

    elseif option == ammo_crafting_hour_id
        main.ammo_crafting_hour = value
        setSliderOptionValue(ammo_crafting_hour_id, value, "${2}hour")

    elseif option == dagger_crafting_hour_id
        main.dagger_crafting_hour = value
        setSliderOptionValue(dagger_crafting_hour_id, value, "${2}hour")

    elseif option == sword_crafting_hour_id
        main.sword_crafting_hour = value
        setSliderOptionValue(sword_crafting_hour_id, value, "${2}hour")

    elseif option == waraxe_crafting_hour_id
        main.waraxe_crafting_hour = value
        setSliderOptionValue(waraxe_crafting_hour_id, value, "${2}hour")

    elseif option == mace_crafting_hour_id
        main.mace_crafting_hour = value
        setSliderOptionValue(mace_crafting_hour_id, value, "${2}hour")

    elseif option == greatsword_crafting_hour_id
        main.greatsword_crafting_hour = value
        setSliderOptionValue(greatsword_crafting_hour_id, value, "${2}hour")

    elseif option == battleaxe_crafting_hour_id
        main.battleaxe_crafting_hour = value
        setSliderOptionValue(battleaxe_crafting_hour_id, value, "${2}hour")

    elseif option == warhammer_crafting_hour_id
        main.warhammer_crafting_hour = value
        setSliderOptionValue(warhammer_crafting_hour_id, value, "${2}hour")

    elseif option == smelting_hour_id
        main.smelting_hour = value
        setSliderOptionValue(smelting_hour_id, value, "${2}hour")

    elseif option == leather_crafting_hour_id
        main.leather_crafting_hour = value
        setSliderOptionValue(leather_crafting_hour_id, value, "${2}hour")

    elseif option == armor_improving_minute_id
        main.armor_improving_minute = value
        setSliderOptionValue(armor_improving_minute_id, value, "${0}min")

    elseif option == weapon_improving_minute_id
        main.weapon_improving_minute = value
        setSliderOptionValue(weapon_improving_minute_id, value, "${0}min")

    elseif option == enchanting_hour_id
        main.enchanting_hour = value
        setSliderOptionValue(enchanting_hour_id, value, "${2}hour")

    elseif option == alchemy_minute_id
        main.alchemy_minute = value
        setSliderOptionValue(alchemy_minute_id, value, "${0}min")

    elseif option == cooking_minute_id
        main.cooking_minute = value
        setSliderOptionValue(cooking_minute_id, value, "${0}min")

    else
        mods.handle_slider_accepted(option, value)
    endif
EndEvent

Event OnOptionDefault(int option)
    if option == is_enabled_id
        main.is_enabled = True
        setToggleOptionValue(is_enabled_id, True)
        initialize()

    elseif option == random_crafting_time_id
        main.random_crafting_time = True
        setToggleOptionValue(random_crafting_time_id, True)

    elseif option == show_notification_id
        main.show_notification = True
        setToggleOptionValue(show_notification_id, True)

    elseif option == crafting_takes_time_id
        main.crafting_takes_time = True
        setToggleOptionValue(crafting_takes_time_id, True)
        registerForMenu("Crafting Menu")

    elseif option == hotkey_id
        unregisterForAllKeys()
        main.hotkey = 0
        setKeyMapOptionValue(hotkey_id, 0)

    else
        mods.handle_option_set_default(option)
    endif
EndEvent

Event OnOptionHighlight(int option)
    if option == is_enabled_id
        setInfoText("$enable_or_disable")
    elseif option == crafting_takes_time_id
        setInfoText("$crafting_takes_time_info")
    elseif option == reading_time_multiplier_id \
            || option == looting_time_multiplier_id \
            || option == lockpicking_time_multiplier_id \
            || option == trading_time_multiplier_id
        setInfoText("$multiplier_used_to_calculate_passed_time")
    elseif option == spell_learning_hour_id \
            || option == training_hour_id \
            || option == eating_minute_id \
            || option == helmet_crafting_hour_id \
            || option == armor_crafting_hour_id \
            || option == gauntlets_crafting_hour_id \
            || option == boots_crafting_hour_id \
            || option == shield_crafting_hour_id \
            || option == leather_crafting_hour_id \
            || option == clothes_crafting_hour_id \
            || option == jewelry_crafting_hour_id \
            || option == staff_crafting_hour_id \
            || option == bow_crafting_hour_id \
            || option == ammo_crafting_hour_id \
            || option == dagger_crafting_hour_id \
            || option == sword_crafting_hour_id \
            || option == waraxe_crafting_hour_id \
            || option == mace_crafting_hour_id \
            || option == greatsword_crafting_hour_id \
            || option == battleaxe_crafting_hour_id \
            || option == warhammer_crafting_hour_id \
            || option == smelting_hour_id \
            || option == armor_improving_minute_id \
            || option == weapon_improving_minute_id \
            || option == enchanting_hour_id \
            || option == alchemy_minute_id \
            || option == cooking_minute_id
        setInfoText("$time_passed_performing_this_action")
    elseif option == random_crafting_time_id
        setInfoText("$use_random_multiplier_calculating_crafting_time")
    elseif option == random_time_multiplier_min_id
        setInfoText("$random_multiplier_minimum")
    elseif option == random_time_multiplier_max_id
        setInfoText("$random_multiplier_maximum")
    elseif option == show_notification_id
        setInfoText("$show_notification_when_time_passed")
    elseif option == notification_threshold_id
        setInfoText("$show_notification_only_when_pass_the_threshold")
    elseif option == hotkey_id
        setInfoText("$hotkey_info")
    elseif option == save_id
        setInfoText("$save_settings")
    elseif option == load_id
        setInfoText("$load_settings")
    elseif option == load_defaults_id
        setInfoText("$load_default_settings")
    elseif option == reinitialize_id
        setInfoText("$reinitialize_info")
    elseif option == reading_increases_speech_multiplier_id
        setInfoText("$multiplier_used_calculating_speech_skill_increasing")
    else
        mods.handle_option_highlighted(option)
    endif
EndEvent
