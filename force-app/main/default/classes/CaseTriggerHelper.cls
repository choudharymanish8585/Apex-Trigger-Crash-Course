public with sharing class CaseTriggerHelper {
    public static List<Case> parentCasesToUpdate;

    public static void updateTotalResolutionDaysOnParentCases(
        Set<Id> parentCaseIdsToUpdate
    ) {
        parentCasesToUpdate = new List<Case>();
        if (parentCaseIdsToUpdate.size() > 0) {
            parentCasesToUpdate = new List<Case>();

            AggregateResult[] casesWithResolutionDays = [
                SELECT Parent_Case__c, SUM(Resolution_Days__c) totalDays
                FROM Case
                WHERE Parent_Case__c IN :parentCaseIdsToUpdate
                GROUP BY Parent_Case__c
            ];

            for (AggregateResult ar : casesWithResolutionDays) {
                // todo list of parent cases to update
                Id parentId = (Id) ar.get('Parent_Case__c');
                Decimal totalDays = (Decimal) ar.get('totalDays');
                parentCasesToUpdate.add(
                    new Case(
                        Id = parentId,
                        Total_Resolution_Days__c = totalDays
                    )
                );
            }

            if (parentCasesToUpdate.size() > 0) {
                update parentCasesToUpdate;
            }
        }
    }

    public static void updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
        Set<Id> parentCaseIdsToUpdate
    ) {
        parentCasesToUpdate = new List<Case>();
        if (parentCaseIdsToUpdate.size() > 0) {
            parentCasesToUpdate = new List<Case>();

            for (Case parentCase : [
                SELECT
                    Id,
                    Total_Resolution_Days__c,
                    (SELECT Id, Resolution_Days__c FROM Cases__r)
                FROM Case
                WHERE Id IN :parentCaseIdsToUpdate
            ]) {
                Decimal totalDays = 0;

                for (Case childCase : parentCase.Cases__r) {
                    totalDays += childCase.Resolution_Days__c;
                }

                parentCasesToUpdate.add(
                    new Case(
                        Id = parentCase.Id,
                        Total_Resolution_Days__c = totalDays
                    )
                );
            }

            if (parentCasesToUpdate.size() > 0) {
                update parentCasesToUpdate;
            }
        }
    }
}
