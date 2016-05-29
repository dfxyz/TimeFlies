Scriptname TimeFliesMain extends Quest  

TimeFliesMods Property mods Auto

GlobalVariable Property GameHour Auto  
GlobalVariable Property TimeScale Auto  
Message Property notification_long Auto
Message Property notification_short Auto


bool debug_mode = True
Function _debug(string str)
    if debug_mode
        Debug.trace("Time Flies: " + str)
    endif
EndFunction


;; General
bool Property is_enabled Auto
bool Property is_paused Auto
bool Property random_crafting_time Auto
float Property random_time_multiplier_min Auto
float Property random_time_multiplier_max Auto
bool Property show_notification Auto
float Property notification_threshold Auto
int Property hotkey Auto

;; Reading
float Property reading_time_multiplier Auto
float Property reading_increases_speech_multiplier Auto
float Property spell_learning_hour Auto

;; Training & Eating & Looting & Lockpicking & Trading
float Property training_hour Auto
float Property eating_minute Auto
float Property looting_time_multiplier Auto
float Property lockpicking_time_multiplier Auto
float Property trading_time_multiplier Auto

;; Crafting
bool Property crafting_takes_time Auto
float Property helmet_crafting_hour Auto
float Property armor_crafting_hour Auto
float Property gauntlets_crafting_hour Auto
float Property boots_crafting_hour Auto
float Property shield_crafting_hour Auto
float Property clothes_crafting_hour Auto
float Property jewelry_crafting_hour Auto
float Property staff_crafting_hour Auto
float Property bow_crafting_hour Auto
float Property ammo_crafting_hour Auto
float Property dagger_crafting_hour Auto
float Property sword_crafting_hour Auto
float Property waraxe_crafting_hour Auto
float Property mace_crafting_hour Auto
float Property greatsword_crafting_hour Auto
float Property battleaxe_crafting_hour Auto
float Property warhammer_crafting_hour Auto
float Property smelting_hour Auto
float Property leather_crafting_hour Auto
float Property armor_improving_minute Auto
float Property weapon_improving_minute Auto
float Property enchanting_hour Auto
float Property alchemy_minute Auto
float Property cooking_minute Auto

;; Private variables
ObjectReference furniture_using
float time_started
float time_stopped
float eating_time_to_pass = 0.0
int food_eaten
int spell_learned
int armor_improved
int weapon_improved
int item_enchanted
int training_session
bool is_crafting
bool is_looting
bool is_trading
bool removing_item = False


Event OnMenuOpen(string menu)
    _debug("Menu opened - " + menu)

    if menu == "Crafting Menu"
        armor_improved = Game.queryStat("Armor Improved")
        weapon_improved = Game.queryStat("Weapons Improved")
        item_enchanted = Game.queryStat("Magic Items Made")
        is_crafting = True
    elseif menu == "Training Menu"
        training_session = Game.queryStat("Training Sessions")
    elseif menu == "ContainerMenu"
        time_started = Utility.getCurrentRealTime()
        is_looting = True
    elseif menu == "InventoryMenu"
        food_eaten = Game.queryStat("Food Eaten")
        spell_learned = Game.queryStat("Spells Learned")
    elseif menu == "BarterMenu" || menu == "GiftMenu"
        is_trading = True
        time_started = Utility.getCurrentRealTime()
    else  ;; book, lockpicking
        time_started = Utility.getCurrentRealTime()
    endif
EndEvent


Event OnMenuClose(string menu)
    _debug("Menu closed - " + menu)

    if menu == "Crafting Menu"
        float t = 0.0

        int i = Game.queryStat("Armor Improved") - armor_improved
        if i > 0
            _debug(i + " armor(s) improved")
        endif
        while i > 0
            t += armor_improving_minute * random_time_multiplier() / 60
            i -= 1
        endwhile

        int j = Game.queryStat("Weapons Improved") - weapon_improved
        if j > 0
            _debug(j + " weapon(s) improved")
        endif
        while j > 0
            t += weapon_improving_minute * random_time_multiplier() / 60
            j -= 1
        endwhile
        
        int k = Game.queryStat("Magic Items Made") - item_enchanted
        if k > 0
            _debug(k + " item(s) enchanted")
        endif
        while k > 0
            t += enchanting_hour * random_time_multiplier()
            k -= 1
        endwhile

        pass_time(t)
        is_crafting = False

    elseif menu == "InventoryMenu" && eating_time_to_pass > 0.0
        pass_time(eating_time_to_pass)
        eating_time_to_pass = 0.0

    elseif menu == "Training Menu"
        int i = Game.queryStat("Training Sessions")
        float time_passed = (i - training_session) * training_hour
        pass_time(time_passed)

    elseif menu == "ContainerMenu"
        time_stopped = Utility.getCurrentRealTime()
        float time_passed = (time_stopped - time_started) * \
            TimeScale.getValue() / 60 / 60 * looting_time_multiplier
        pass_time(time_passed)
        is_looting = False

    elseif menu == "Book Menu"
        time_stopped = Utility.getCurrentRealTime()
        float time_passed = (time_stopped - time_started) * \
            TimeScale.getValue() / 60 / 60 * reading_time_multiplier
        pass_time(time_passed)

        float skill_increased = (time_stopped - time_started) * \
            reading_increases_speech_multiplier
        ActorValueInfo.getActorValueInfoByName("Speechcraft")\
            .addSkillExperience(skill_increased)

    elseif menu == "Lockpicking Menu"
        time_stopped = Utility.getCurrentRealTime()
        float time_passed = (time_stopped - time_started) * \
            TimeScale.getValue() / 60 / 60 * lockpicking_time_multiplier
        pass_time(time_passed)

    elseif menu == "BarterMenu" || menu == "GiftMenu"
        time_stopped = Utility.getCurrentRealTime()
        float time_passed = (time_stopped - time_started) * \
            TimeScale.getValue() / 60 / 60 * trading_time_multiplier
        pass_time(time_passed)
        is_trading = False
    endif
EndEvent


Function handle_using_furniture(ObjectReference obj)
    if !is_enabled
        return
    endif
    _debug("Using Furniture")
    furniture_using = obj
EndFunction


Function handle_leaving_furniture(ObjectReference obj)
    if !is_enabled
        return
    endif
    _debug("Leaving Furniture")
    furniture_using = None
EndFunction


Function handle_added_item(Form item, int count, \
        ObjectReference ref, ObjectReference src)
    if !is_enabled || !is_crafting || src || UI.isMenuOpen("Console")
        return
    endif

    _debug("Item added - " + item.getName() + " (" + type + ")")

    int type = item.getType()

    if mods.handle_added_item(item)
        return
    endif

    if furniture_using.hasKeywordString("CraftingSmelter")  ;; ingot or gem
        _debug("Using smelter")
        pass_time(smelting_hour * random_time_multiplier())
    elseif type == 46  ;; potion, poison or food
        Potion p = item as Potion
        if p.isFood()
            _debug("Food cooked")
            pass_time(cooking_minute * random_time_multiplier() / 60)
        else
            _debug("Potion made")
            pass_time(alchemy_minute * random_time_multiplier() / 60)
        endif
    elseif type == 26  ;; armor
        Armor a = item as Armor
        if a.isHelmet()
            _debug("Helmet made")
            pass_time(helmet_crafting_hour * random_time_multiplier())
        elseif a.isCuirass()
            _debug("Armor made")
            pass_time(armor_crafting_hour * random_time_multiplier())
        elseif a.isGauntlets()
            _debug("Gauntlets made")
            pass_time(gauntlets_crafting_hour * random_time_multiplier())
        elseif a.isBoots()
            _debug("Boots made")
            pass_time(boots_crafting_hour * random_time_multiplier())
        elseif a.isShield()
            _debug("Shield made")
            pass_time(shield_crafting_hour * random_time_multiplier())
        elseif a.isJewelry()
            _debug("Jewelry made")
            pass_time(jewelry_crafting_hour * random_time_multiplier())
        elseif a.isClothing()
            _debug("Clothes made")
            pass_time(clothes_crafting_hour * random_time_multiplier())
        else
            _debug("Unknown armor made")
        endif
    elseif type == 41  ;; weapon
        Weapon w = item as Weapon
        if w.isBow()
            _debug("Bow made")
            pass_time(bow_crafting_hour * random_time_multiplier())
        elseif w.isDagger()
            _debug("Dagger made")
            pass_time(dagger_crafting_hour * random_time_multiplier())
        elseif w.isSword()
            _debug("Sword made")
            pass_time(sword_crafting_hour * random_time_multiplier())
        elseif w.isWarAxe()
            _debug("Waraxe made")
            pass_time(waraxe_crafting_hour * random_time_multiplier())
        elseif w.isMace()
            _debug("Mace made")
            pass_time(mace_crafting_hour * random_time_multiplier())
        elseif w.isGreatSword()
            _debug("Greatsword made")
            pass_time(greatsword_crafting_hour * random_time_multiplier())
        elseif w.isBattleAxe()
            _debug("Battleaxe made")
            pass_time(battleaxe_crafting_hour * random_time_multiplier())
        elseif w.isWarhammer()
            _debug("Warhammer made")
            pass_time(warhammer_crafting_hour * random_time_multiplier())
        elseif w.isStaff()
            _debug("Staff made")
            pass_time(staff_crafting_hour * random_time_multiplier())
        else
            _debug("Unknown weapon made")
        endif
    elseif type == 42  ;; ammo
        _debug("Ammo made")
        pass_time(ammo_crafting_hour * random_time_multiplier())
    elseif type == 32  ;; misc items
        if item.getName() == "Leather"
            _debug("Leather made")
            pass_time(leather_crafting_hour * random_time_multiplier())
        endif
    else
        _debug("Item of irrelevant type made")
    endif
EndFunction


Function handle_removed_item(Form item, int count, \
        ObjectReference ref, ObjectReference dst)
    if !is_enabled || is_looting || is_trading || UI.isMenuOpen("Console") \
            || removing_item  ;; OnItemRemoved will be strangely triggered twice
        return
    endif

    removing_item = True
    int type = item.getType()
    _debug("Item removed - " + item.getName() + " (" + type + ")")

    if is_crafting && mods.handle_removed_item(item)
        removing_item = False
        return
    endif

    if type == 46  ;; food
        int food_eaten_now = Game.queryStat("Food Eaten")
        if food_eaten_now > food_eaten
            _debug("Food eaten")
            eating_time_to_pass += eating_minute / 60
            food_eaten = food_eaten_now
        endif

    elseif type == 27  ;; book
        int spell_learned_now = Game.queryStat("Spells Learned")
        if spell_learned_now > spell_learned
            _debug("Spell learned")
            pass_time(spell_learning_hour)
            spell_learned = spell_learned_now
        endif
    endif

    removing_item = False
EndFunction


float Function random_time_multiplier()
    if random_crafting_time
        return Utility.randomFloat(random_time_multiplier_min, \
            random_time_multiplier_max)
    else
        return 1.0
    endif
EndFunction


Function pass_time(float time_passed)
    if time_passed <= 0 || is_paused
        return
    endif

    float time = GameHour.getValue()
    time += time_passed

    int hour_passed = Math.floor(time_passed)
    int minute_passed = Math.floor((time_passed - hour_passed) * 60)
    _debug("Time passed - " + hour_passed + " hour(s), " + \
        minute_passed + " minute(s) (" + time_passed + ")")
    
    if show_notification
        if hour_passed > 0
            notification_long.show(hour_passed, minute_passed)
        elseif minute_passed >= notification_threshold
            notification_short.show(minute_passed)
        endif
    endif
    GameHour.setValue(time)
EndFunction


int Function get_prefix(Form f)
    if f == None
        return -1
    else
        return Math.rightShift(f.getFormID(), 24)
    endif
EndFunction
