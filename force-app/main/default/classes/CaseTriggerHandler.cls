public with sharing class CaseTriggerHandler {
    public static Set<Id> parentCaseIdsToUpdate;
    public List<Case> parentCasesToUpdate;

    public static void afterInsertHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for (Case cas : cases) {
            if (cas.Resolution_Days__c != null) {
                parentCaseIdsToUpdate.add(cas.Parent_Case__c);
            }
        }
        CaseTriggerHelper.updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
            parentCaseIdsToUpdate
        );
    }

    public static void afterUpdateHandler(
        List<Case> cases,
        Map<Id, Case> oldCasesMap
    ) {
        parentCaseIdsToUpdate = new Set<Id>();
        for (Case cas : cases) {
            Case oldCaseVer = oldCasesMap.get(cas.Id);
            if (cas.Resolution_Days__c != oldCaseVer.Resolution_Days__c) {
                if (cas.Parent_Case__c != null) {
                    parentCaseIdsToUpdate.add(cas.Parent_Case__c);
                }
            }

            if (cas.Parent_Case__c != oldCaseVer.Parent_Case__c) {
                if (cas.Parent_Case__c != null) {
                    parentCaseIdsToUpdate.add(cas.Parent_Case__c);
                }
                if (oldCaseVer.Parent_Case__c != null) {
                    parentCaseIdsToUpdate.add(oldCaseVer.Parent_Case__c);
                }
            }
        }
        CaseTriggerHelper.updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
            parentCaseIdsToUpdate
        );
    }

    public static void afterDeleteHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for (Case cas : cases) {
            if (cas.Resolution_Days__c != null) {
                parentCaseIdsToUpdate.add(cas.Parent_Case__c);
            }
        }
        CaseTriggerHelper.updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
            parentCaseIdsToUpdate
        );
    }

    public static void afterUndeleteHandler(List<Case> cases) {
        parentCaseIdsToUpdate = new Set<Id>();
        for (Case cas : cases) {
            if (cas.Resolution_Days__c != null) {
                parentCaseIdsToUpdate.add(cas.Parent_Case__c);
            }
        }
        CaseTriggerHelper.updateTotalResolutionDaysOnParentCasesUsingInnerQuery(
            parentCaseIdsToUpdate
        );
    }
}
