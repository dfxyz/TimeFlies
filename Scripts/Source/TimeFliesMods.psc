Scriptname TimeFliesMods extends Quest  

TimeFliesMCM Property mcm Auto

;; load mod supporting scripts as properties
TFHearthfire Property hearthfire Auto
TFCampfire Property campfire Auto
TFiNeed Property ineed Auto

Function prepare_pages()
    ;; change page number if necessary
    mcm.pages = new string[6]
    ;; fixed pages
    mcm.pages[0] = "$general"
    mcm.pages[1] = "$crafting"
    mcm.pages[2] = "$others"
    ;; mod related pages
    mcm.pages[3] = "$hearthfire"
    mcm.pages[4] = "$campfire"
    mcm.pages[5] = "$ineed"
    ;; add more behind
EndFunction


Function update(int version)
    ;; if updating from old version (adding new mod(s) support),
    ;; call load_defaults() and initialize() from those mod support scripts

    ;; if version >= x
    ;;     mod.load_defaults()
    ;;     mod.initialize()
    ;; endif
EndFunction


Function initialize()
    ;; prepare some variables like form lists needing to process
    hearthfire.initialize()
    campfire.initialize()
    ineed.initialize()
EndFunction

Function load_defaults()
    ;; load default settings related to those mods
    hearthfire.load_defaults()
    campfire.load_defaults()
    ineed.load_defaults()
EndFunction


bool Function handle_added_item(Form item)
    ;; called when player gets an item through crafting
    ;; if an item is handled by a mod, it should return True
    ;; then return True in this function
    ;; otherwise return False to handle it as a vanilla item
    if hearthfire.handle_added_item(item)
        return True
    endif

    if campfire.handle_added_item(item)
        return True
    endif

    if ineed.handle_added_item(item)
        return True
    endif

    return False
EndFunction

bool Function handle_removed_item(Form item)
    ;; called when player loses an item through crafting
    ;; if an item is handled by a mod, it should return True
    ;; then return True in this function
    ;; otherwise return False to handle it as a vanilla item
    if campfire.handle_removed_item(item)
        return True
    endif

    return False
EndFunction


Function save_settings()
    ;; save settings related to those mods
    hearthfire.save_settings()
    campfire.save_settings()
    ineed.save_settings()
EndFunction

Function load_settings()
    ;; load settings related to those mods
    hearthfire.load_settings()
    campfire.load_settings()
    ineed.load_settings()
EndFunction


Function handle_page(string page)
    ;; draw UI when selecting mod-related pages
    ;; if a page is handled by a mod, it should return True
    if hearthfire.handle_page(page)
    elseif campfire.handle_page(page)
    elseif ineed.handle_page(page)
    endif
EndFunction

Function handle_option_selected(int option)
    ;; called when an mod-related option is selected
    ;; if an option is handled by a mod, it should return True

    ;; if some_mod.handle_option_selected(option)
    ;; elseif other_mod.handle_option_selected(option)
    ;; endif
EndFunction

Function handle_slider_opened(int option)
    ;; called when an mod-related slider is opened
    ;; if an option is handled by a mod, it should return True
    if hearthfire.handle_slider_opened(option)
    elseif campfire.handle_slider_opened(option)
    elseif ineed.handle_slider_opened(option)
    endif
EndFunction

Function handle_slider_accepted(int option, float value)
    ;; called when an mod-related slider is accepted
    ;; if an option is handled by a mod, it should return True
    if hearthfire.handle_slider_accepted(option, value)
    elseif campfire.handle_slider_accepted(option, value)
    elseif ineed.handle_slider_accepted(option, value)
    endif
EndFunction

Function handle_option_set_default(int option)
    ;; called when an mod-related option is reset to its default value
    ;; if an option is handled by a mod, it should return True

    ;; if some_mod.handle_option_set_default(option)
    ;; elseif other_mod.handle_option_set_default(option)
    ;; endif
EndFunction

Function handle_option_highlighted(int option)
    ;; called when an mod-related option is highlighted
    ;; if an option is handled by a mod, it should return True
    if hearthfire.handle_option_highlighted(option)
    elseif campfire.handle_option_highlighted(option)
    elseif ineed.handle_option_highlighted(option)
    endif
EndFunction
