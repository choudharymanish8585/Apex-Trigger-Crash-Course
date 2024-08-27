trigger LineItemTrigger on Line_Item__c(
    after insert,
    after update,
    after delete,
    after undelete
) {
    Set<Id> orderIdsToUpdate = new Set<Id>();
    switch on Trigger.operationType {
        when AFTER_INSERT, AFTER_UNDELETE {
            for (Line_Item__c item : Trigger.new) {
                orderIdsToUpdate.add(item.Order__c);
            }
        }
        when AFTER_UPDATE {
            for (Line_Item__c item : Trigger.new) {
                Line_Item__c oldItemVer = Trigger.oldMap.get(item.Id);
                if (
                    item.List_Amount__c != oldItemVer.List_Amount__c ||
                    item.Final_Amount__c != oldItemVer.Final_Amount__c
                ) {
                    orderIdsToUpdate.add(item.Order__c);
                }

                if (item.Order__c != oldItemVer.Order__c) {
                    orderIdsToUpdate.add(item.Order__c);
                    orderIdsToUpdate.add(oldItemVer.Order__c);
                }
            }
        }
        when AFTER_DELETE {
            for (Line_Item__c item : Trigger.old) {
                orderIdsToUpdate.add(item.Order__c);
            }
        }
    }
    if (orderIdsToUpdate.size() > 0) {
        List<AggregateResult> ordersWithAmount = [
            SELECT Order__c, SUM(Final_Amount__c) totalAmount
            FROM Line_Item__c
            WHERE Order__c IN :orderIdsToUpdate
            GROUP BY Order__c
        ];

        Map<Id, Decimal> ordersWithAmountMap = new Map<Id, Decimal>();
        for (AggregateResult orderWithAmount : ordersWithAmount) {
            Id orderId = (Id) orderWithAmount.get('Order__c');
            Decimal orderAmount = (Decimal) orderWithAmount.get('totalAmount');
            ordersWithAmountMap.put(orderId, orderAmount);
        }

        List<Order__c> ordersToUpdate = new List<Order__c>();

        for (Id orderIdToUpdate : orderIdsToUpdate) {
            if (ordersWithAmountMap.containsKey(orderIdToUpdate)) {
                ordersToUpdate.add(
                    new Order__c(
                        Id = orderIdToUpdate,
                        Total_Amount__c = ordersWithAmountMap.get(
                            orderIdToUpdate
                        )
                    )
                );
            } else {
                ordersToUpdate.add(
                    new Order__c(Id = orderIdToUpdate, Total_Amount__c = 0)
                );
            }
        }
        if (ordersToUpdate.size() > 0) {
            update ordersToUpdate;
        }
    }

}
