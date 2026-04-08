/**
 * @description Trigger on Vehicle_Order__c.
 *              Delegates all logic to VehicleOrderTriggerHandler for
 *              clean separation of concerns.
 *
 * @author      WhatsNext Vision Motors Dev Team
 * @date        2026-04-05
 */
trigger VehicleOrderTrigger on Vehicle_Order__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        VehicleOrderTriggerHandler.handleBeforeInsert(Trigger.new);
    }
}
