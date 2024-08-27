trigger TestOrderTrigger on Order__c(
    before insert,
    before update,
    after update
) {
    Map<Id, Order__c> ordersWithAmountChanges = new Map<Id, Order__c>();
    System.debug('Order Trigger:' + Trigger.operationType);

    switch on Trigger.operationType {
        when BEFORE_INSERT, BEFORE_UPDATE {
            if (OpportunityTriggerHelper.isFirstOrderBeforeTriggerExecution) {
                OpportunityTriggerHelper.isFirstOrderBeforeTriggerExecution = false;
                System.debug('Before update/insert');
                for (Order__c order : Trigger.new) {
                    if (order.Total_Amount__c != null) {
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
        // Do not need handle AFTER_INSERT as no child would exist at that time
        when AFTER_UPDATE {
            if (OpportunityTriggerHelper.isFirstOrderAfterTriggerExecution) {
                OpportunityTriggerHelper.isFirstOrderAfterTriggerExecution = false;
                System.debug('After update');
                for (Order__c order : Trigger.new) {
                    Order__c oldOrderVer = Trigger.oldMap.get(order.Id);
                    System.debug(
                        'After update amount:' +
                            order.Final_Amount__c +
                            ' : ' +
                            oldOrderVer.Final_Amount__c
                    );
                    if (order.Final_Amount__c != oldOrderVer.Final_Amount__c) {
                        ordersWithAmountChanges.put(order.Id, order);
                    }
                }
                System.debug(
                    'After update size: ' + ordersWithAmountChanges.size()
                );
                if (ordersWithAmountChanges.size() > 0) {
                    List<Line_Item__c> items = [
                        SELECT Id, Order__c, Final_Amount__c
                        FROM Line_Item__c
                        WHERE Order__c IN :ordersWithAmountChanges.keySet()
                    ];

                    List<Line_Item__c> itemsToUpdate = new List<Line_Item__c>();
                    System.debug('Item to update:' + itemsToUpdate.size());
                    for (Line_Item__c item : items) {
                        if (
                            ordersWithAmountChanges.containsKey(item.Order__c)
                        ) {
                            Order__c order = ordersWithAmountChanges.get(
                                item.Order__c
                            );
                            Decimal amountToUpdate =
                                item.Final_Amount__c -
                                (item.Final_Amount__c *
                                order.Discount__c /
                                100);
                            System.debug(
                                'Amount to update:' +
                                    item.Id +
                                    ' : ' +
                                    item.Final_Amount__c +
                                    ' : ' +
                                    amountToUpdate
                            );
                            itemsToUpdate.add(
                                new Line_Item__c(
                                    Id = item.Id,
                                    Final_Amount__c = amountToUpdate
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
    }
}
