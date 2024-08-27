trigger AccountTrigger on Account(after update) {
    switch on Trigger.operationType {
        when AFTER_UPDATE {
            if (!AccountTriggerHandler.hasAfterUpdateAlreadyExecuted) {
                AccountTriggerHandler.hasAfterUpdateAlreadyExecuted = true;
                new AccountTriggerHandler().afterUpdateHandler(Trigger.new);
            }
        }
    }

}
