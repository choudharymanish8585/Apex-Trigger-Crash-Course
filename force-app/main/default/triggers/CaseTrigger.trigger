trigger CaseTrigger on Case(
    after insert,
    after update,
    after delete,
    after undelete
) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            CaseTriggerHandler.afterInsertHandler(Trigger.new);
        }
        when AFTER_UPDATE {
            CaseTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
        }
        when AFTER_DELETE {
            CaseTriggerHandler.afterDeleteHandler(Trigger.old);
        }
        when AFTER_UNDELETE {
            CaseTriggerHandler.afterUndeleteHandler(Trigger.new);
        }
    }

}
