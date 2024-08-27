public with sharing class OpportunityTriggerHandler {
    public static void handleBeforeInsert(List<Opportunity> newOpps){
        for(Opportunity opp : newOpps){
            if(opp.StageName == 'Closed Won'){
                opp.NextStep = 'Onboard a Contract';
            }
        }
    }

    public static void handleAfterInsert(List<Opportunity> newOpps){
        List<Task> tasks = new List<Task>();
        List<Account> accs = new List<Account>();
        List<Custom_Approval__c> cas = new List<Custom_Approval__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<Id> oppsThatNeedAccountStatusUpdate = new List<Id>();

        for(Opportunity opp : newOpps){

            if(opp.StageName == 'Closed Won'){
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Engage with customer'));
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Schedule a welcome call'));
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Send a thank-you email'));
            }

            if(opp.StageName == 'Closed Won' 
                && opp.Amount >= 100000){
                
                    oppsThatNeedAccountStatusUpdate.add(opp.Id);

                    cas.add(OpportunityTriggerHelper.createApprovalForFinanceTeam(opp));

                    emails.add(OpportunityTriggerHelper.sendEmailToFinance(opp));
            }
        }

        accs.addAll(OpportunityTriggerHelper.updateAccountsToVipStatus(oppsThatNeedAccountStatusUpdate));

        List<Sobject> recordToUpsert = new List<SObject>();
        
        if(emails.size() > 0){
            //Messaging.sendEmail(emails);
        }

        if(tasks.size() > 0){
            recordToUpsert.addAll(tasks);
        }

        if(accs.size() > 0){
            recordToUpsert.addAll(accs);
        }

        if(cas.size() > 0){
            recordToUpsert.addAll(cas);
        }

        if(recordToUpsert.size() > 0){
            upsert recordToUpsert;
        }
    }

    public static void handleBeforeUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap){
        for(Opportunity opp : newOpps){
            if(opp.StageName == 'Closed Won'
                && oldOppMap.get(opp.Id).StageName != 'Closed Won'){
                opp.NextStep = 'Onboard a Contract';
            }
        }
    }

    public static void handleAfterUpdate(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppMap){
        List<Task> tasks = new List<Task>();
        List<Account> accs = new List<Account>();
        List<Custom_Approval__c> cas = new List<Custom_Approval__c>();
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Id> oppsThatNeedAccountStatusUpdate = new List<Id>();
        for(Opportunity opp : newOpps){

            if(opp.StageName == 'Closed Won' 
                && oldOppMap.get(opp.Id).StageName != 'Closed Won'){
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Engage with customer'));
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Schedule a welcome call'));
                tasks.add(OpportunityTriggerHelper.createOpportunityTask(opp, 'Send a thank-you email'));
            }

            if(opp.StageName == 'Closed Won' 
                && oldOppMap.get(opp.Id).StageName != 'Closed Won' 
                && opp.Amount >= 100000
                && oldOppMap.get(opp.Id).Amount < 100000){
                    
                    oppsThatNeedAccountStatusUpdate.add(opp.Id);
                    
                    cas.add(OpportunityTriggerHelper.createApprovalForFinanceTeam(opp));

                    emails.add(OpportunityTriggerHelper.sendEmailToFinance(opp));
            }
        }

        accs.addAll(OpportunityTriggerHelper.updateAccountsToVipStatus(oppsThatNeedAccountStatusUpdate));

        List<Sobject> recordToUpsert = new List<SObject>();

        if(emails.size() > 0){
            //Messaging.sendEmail(emails);
        }

        if(tasks.size() > 0){
            recordToUpsert.addAll(tasks);
        }

        if(accs.size() > 0){
            recordToUpsert.addAll(accs);
        }

        if(cas.size() > 0){
            recordToUpsert.addAll(cas);
        }

        if(recordToUpsert.size() > 0){
            upsert recordToUpsert;
        }
    }
}