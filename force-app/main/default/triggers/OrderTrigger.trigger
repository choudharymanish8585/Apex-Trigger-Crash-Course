trigger OrderTrigger on Order__C(before update, after update) {
    switch on Trigger.operationType {
        when BEFORE_UPDATE {
            OrderTriggerHandler.beforeUpdateHandler(
                Trigger.new,
                Trigger.oldMap
            );
        }
        when AFTER_UPDATE {
            OrderTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
    }

}
