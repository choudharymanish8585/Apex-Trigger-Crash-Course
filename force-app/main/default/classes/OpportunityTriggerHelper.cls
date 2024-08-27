public with sharing class OpportunityTriggerHelper {
    public static boolean isFirstOrderBeforeTriggerExecution = true;
    public static boolean isFirstOrderAfterTriggerExecution = true;
    public static List<Account> updateAccountsToVipStatus(List<String> oppIds) {
        List<Opportunity> opps = [
            SELECT Id, AccountId
            FROM Opportunity
            WHERE Id IN :oppIds
        ];

        List<Id> accountIds = new List<Id>();
        for (Opportunity opp : opps) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }
        List<Account> accounts = [
            SELECT Id, Status__c
            FROM Account
            WHERE Id IN :accountIds
        ];

        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : accounts) {
            if (acc.Status__c != 'VIP') {
                acc.Status__c = 'VIP';
                accountsToUpdate.add(acc);
            }
        }

        return accountsToUpdate;
    }

    public static Custom_Approval__c createApprovalForFinanceTeam(
        Opportunity opp
    ) {
        Custom_Approval__c ca = new Custom_Approval__c(
            Opportunity__c = opp.Id,
            Status__c = 'Pending',
            Approver__c = 'Finance Team'
        );
        return ca;
    }

    public static Messaging.SingleEmailMessage sendEmailToFinance(
        Opportunity opp
    ) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ 'sfdcfacts@gmail.com' });
        mail.setSubject('New high value opportunity');
        mail.setPlainTextBody(
            'Good news!! We have a new high value opp: ' +
                opp.Id +
                ' that needs review!!'
        );
        return mail;
    }

    public static Task createOpportunityTask(Opportunity opp, String subject) {
        Task tsk = new Task();
        tsk.WhatId = opp.Id;
        tsk.Subject = 'Send a thank-you email';
        return tsk;
    }
}
