Scriptname TimeFliesPlayerAlias extends ReferenceAlias Conditional

TimeFliesMain Property main Auto

Event OnItemAdded(Form item, int count, ObjectReference ref, ObjectReference src)
    main.handle_added_item(item, count, ref, src)
EndEvent

Event OnItemRemoved(Form item, int count, ObjectReference ref, ObjectReference dst)
    main.handle_removed_item(item, count, ref, dst)
EndEvent

Event OnSit(ObjectReference obj)
    main.handle_using_furniture(obj)
EndEvent

Event OnGetUp(ObjectReference obj)
    main.handle_leaving_furniture(obj)
EndEvent
