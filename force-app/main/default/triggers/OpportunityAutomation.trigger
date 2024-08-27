trigger OpportunityAutomation on Opportunity (before insert, after insert, before update, after update) {

    switch on Trigger.operationType {

        when BEFORE_INSERT {
            OpportunityTriggerHandler.handleBeforeInsert(Trigger.new);
        }

        when BEFORE_UPDATE {
            OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
        }

        when AFTER_INSERT {
            OpportunityTriggerHandler.handleAfterInsert(Trigger.new);
        }

        when AFTER_UPDATE {
            OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}