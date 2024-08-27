public with sharing class AccountTriggerHandler {
    public static boolean hasAfterUpdateAlreadyExecuted = false;
    List<Account> accountsToUpdate = new List<Account>();
    public void afterUpdateHandler(List<Account> accounts) {
        for (Account acc : accounts) {
            Account newAcc = new Account(Id = acc.Id);
            newAcc.Last_After_Update_Execution_Time__c = Datetime.now();
            accountsToUpdate.add(newAcc);
        }

        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
    }
}
