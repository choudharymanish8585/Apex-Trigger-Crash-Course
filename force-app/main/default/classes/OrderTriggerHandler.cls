public with sharing class OrderTriggerHandler {
    public static Map<Id, Order__c> ordersWithAmountChanges = new Map<Id, Order__c>();

    public static boolean isFirstBeforeOrderTriggerExecution = true;
    public static boolean isFirstAfterOrderTriggerExecution = true;

    public static void beforeUpdateHandler(
        List<Order__c> newOrders,
        Map<Id, Order__c> oldRecordsMap
    ) {
        if (isFirstBeforeOrderTriggerExecution) {
            isFirstBeforeOrderTriggerExecution = false;
            for (Order__c order : newOrders) {
                Order__c oldOrderVer = oldRecordsMap.get(order.Id);
                if (order.Total_Amount__c != oldOrderVer.Total_Amount__c) {
                    if (order.Total_Amount__c > 5000) {
                        order.Discount__c = 25;
                        order.Final_Amount__c =
                            order.Total_Amount__c -
                            (order.Total_Amount__c * .25);
                    } else if (order.Total_Amount__c > 1000) {
                        order.Discount__c = 10;
                        order.Final_Amount__c =
                            order.Total_Amount__c -
                            (order.Total_Amount__c * .10);
                    } else {
                        order.Discount__c = 0;
                        order.Final_Amount__c = order.Total_Amount__c;
                    }
                }
            }
        }
    }

    public static void afterUpdateHandler(
        List<Order__c> newOrders,
        Map<Id, Order__c> oldRecordsMap
    ) {
        if (isFirstAfterOrderTriggerExecution) {
            isFirstAfterOrderTriggerExecution = false;

            for (Order__c order : newOrders) {
                Order__c oldOrderVer = oldRecordsMap.get(order.Id);
                if (order.Final_Amount__c != oldOrderVer.Final_Amount__c) {
                    ordersWithAmountChanges.put(order.Id, order);
                }
            }
            List<Line_Item__c> itemsToUpdate = new List<Line_Item__c>();
            if (ordersWithAmountChanges.size() > 0) {
                List<Line_Item__c> itemsLinkedToOrders = [
                    SELECT Id, Order__c, Final_Amount__c
                    FROM Line_Item__c
                    WHERE Order__c IN :ordersWithAmountChanges.keySet()
                ];
                for (Line_Item__c item : itemsLinkedToOrders) {
                    Order__c linkedOrder = ordersWithAmountChanges.get(
                        item.Order__c
                    );
                    Decimal finalAmount =
                        item.Final_Amount__c -
                        item.Final_Amount__c * linkedOrder.Discount__c / 100;
                    itemsToUpdate.add(
                        new Line_Item__c(
                            Id = item.Id,
                            Final_Amount__c = finalAmount
                        )
                    );
                }
            }
            if (itemsToUpdate.size() > 0) {
                update itemsToUpdate;
            }
        }
    }
}
