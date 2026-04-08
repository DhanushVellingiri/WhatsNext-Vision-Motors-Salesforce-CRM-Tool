/**
 * @description Batch Apex class to process bulk Vehicle Orders.
 *
 *              Queries Vehicle_Order__c where:
 *                - Is_Bulk_Order__c = TRUE
 *                - Status__c       = 'Draft'
 *
 *              Logic per record:
 *                - If the related Vehicle has stock > 0 →
 *                    set Status to 'Confirmed' and decrement Vehicle stock by 1.
 *                - If stock is 0 →
 *                    set Status to 'Pending'.
 *
 *              This class is bulk-safe and uses Database.Stateful to track
 *              summary metrics across execute batches.
 *
 * @author      WhatsNext Vision Motors Dev Team
 * @date        2026-04-05
 */
public class BulkOrderProcessingBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Counters carried across execute() invocations
    @TestVisible
    private Integer confirmedCount = 0;
    @TestVisible
    private Integer pendingCount   = 0;

    /**
     * @description Defines the scope of records to process.
     * @param bc Batchable context.
     * @return QueryLocator for draft bulk orders.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Vehicle__c, Status__c
            FROM   Vehicle_Order__c
            WHERE  Is_Bulk_Order__c = TRUE
            AND    Status__c = 'Draft'
        ]);
    }

    /**
     * @description Processes a chunk of bulk orders.
     *              Checks vehicle stock and updates order status accordingly.
     * @param bc     Batchable context.
     * @param scope  List of Vehicle_Order__c records in this chunk.
     */
    public void execute(Database.BatchableContext bc, List<Vehicle_Order__c> scope) {

        // 1. Collect all Vehicle IDs referenced by orders in this batch
        Set<Id> vehicleIds = new Set<Id>();
        for (Vehicle_Order__c ord : scope) {
            if (ord.Vehicle__c != null) {
                vehicleIds.add(ord.Vehicle__c);
            }
        }

        // 2. Query current stock for those vehicles
        Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Available__c
             FROM   Vehicle__c
             WHERE  Id IN :vehicleIds]
        );

        // 3. Lists for DML
        List<Vehicle_Order__c> ordersToUpdate   = new List<Vehicle_Order__c>();
        List<Vehicle__c>       vehiclesToUpdate = new List<Vehicle__c>();

        // Track which vehicles have already been decremented in this chunk
        // to handle multiple orders for the same vehicle within one batch
        Map<Id, Decimal> stockAdjustments = new Map<Id, Decimal>();

        for (Vehicle_Order__c ord : scope) {
            if (ord.Vehicle__c == null) {
                continue;
            }

            Vehicle__c vehicle = vehicleMap.get(ord.Vehicle__c);
            if (vehicle == null) {
                continue;
            }

            // Determine effective stock (original stock minus already-consumed in this chunk)
            Decimal originalStock = vehicle.Stock_Available__c != null
                                    ? vehicle.Stock_Available__c
                                    : 0;
            Decimal alreadyConsumed = stockAdjustments.containsKey(vehicle.Id)
                                     ? stockAdjustments.get(vehicle.Id)
                                     : 0;
            Decimal effectiveStock = originalStock - alreadyConsumed;

            if (effectiveStock > 0) {
                // Confirm the order and decrement stock
                ord.Status__c = 'Confirmed';
                confirmedCount++;

                // Track the consumption
                stockAdjustments.put(vehicle.Id, alreadyConsumed + 1);
            } else {
                // No stock available — mark as Pending
                ord.Status__c = 'Pending';
                pendingCount++;
            }

            ordersToUpdate.add(ord);
        }

        // 4. Build the vehicle update list based on total adjustments
        for (Id vehicleId : stockAdjustments.keySet()) {
            Vehicle__c v = vehicleMap.get(vehicleId);
            v.Stock_Available__c = (v.Stock_Available__c != null ? v.Stock_Available__c : 0)
                                   - stockAdjustments.get(vehicleId);
            vehiclesToUpdate.add(v);
        }

        // 5. Perform DML
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
        if (!vehiclesToUpdate.isEmpty()) {
            update vehiclesToUpdate;
        }
    }

    /**
     * @description Called after all batches complete.
     *              Logs summary metrics.
     * @param bc Batchable context.
     */
    public void finish(Database.BatchableContext bc) {
        System.debug(LoggingLevel.INFO,
            '=== BulkOrderProcessingBatch Complete ===\n'
            + 'Confirmed Orders: ' + confirmedCount + '\n'
            + 'Pending Orders  : ' + pendingCount
        );
    }
}
