/**
 * @description Trigger handler for Vehicle_Order__c.
 *              Contains all business logic invoked from VehicleOrderTrigger.
 *
 *              Requirement A — Stock Validation:
 *                If Is_Bulk_Order__c is FALSE and the related Vehicle's
 *                Stock_Available__c is 0 or less, block the order with an error.
 *
 *              Requirement B — Auto-Assign Nearest Dealer:
 *                Calculate the distance between the Customer's Location__c
 *                and every Dealer's Location__c using Location.getDistance().
 *                Populate the Dealer__c lookup with the closest dealer.
 *
 * @author      WhatsNext Vision Motors Dev Team
 * @date        2026-04-05
 */
public with sharing class VehicleOrderTriggerHandler {

    /**
     * @description Entry point called from the before-insert trigger context.
     *              Orchestrates stock validation and dealer auto-assignment.
     * @param newOrders List of Vehicle_Order__c records being inserted.
     */
    public static void handleBeforeInsert(List<Vehicle_Order__c> newOrders) {
        // --- Collect related record IDs for bulk SOQL queries ---
        Set<Id> vehicleIds  = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();

        for (Vehicle_Order__c ord : newOrders) {
            if (ord.Vehicle__c != null) {
                vehicleIds.add(ord.Vehicle__c);
            }
            if (ord.Customer__c != null) {
                customerIds.add(ord.Customer__c);
            }
        }

        // --- Query related Vehicles (for stock validation) ---
        Map<Id, Vehicle__c> vehicleMap = new Map<Id, Vehicle__c>(
            [SELECT Id, Stock_Available__c
             FROM   Vehicle__c
             WHERE  Id IN :vehicleIds]
        );

        // --- Query related Contacts (for geolocation) ---
        Map<Id, Contact> customerMap = new Map<Id, Contact>(
            [SELECT Id, Location__Latitude__s, Location__Longitude__s
             FROM   Contact
             WHERE  Id IN :customerIds]
        );

        // --- Query all Dealers with geolocation data ---
        List<Dealer__c> allDealers = [
            SELECT Id, Location__Latitude__s, Location__Longitude__s
            FROM   Dealer__c
            WHERE  Location__Latitude__s != NULL
            AND    Location__Longitude__s != NULL
        ];

        // --- Process each order ---
        for (Vehicle_Order__c ord : newOrders) {

            // DEBUG: See what the trigger is receiving
            System.debug('Processing Order for Vehicle ID: ' + ord.Vehicle__c);
            System.debug('Is Bulk Order: ' + ord.Is_Bulk_Order__c);

            // ============================================================
            // Requirement A: Stock Validation (non-bulk orders only)
            // ============================================================
            if (ord.Is_Bulk_Order__c == false && ord.Vehicle__c != null) {
                Vehicle__c relatedVehicle = vehicleMap.get(ord.Vehicle__c);

                // DEBUG: See the stock level retrieved from the Map
                System.debug('Related Vehicle Found: ' + (relatedVehicle != null));
                if (relatedVehicle != null) {
                    System.debug('Stock Available: ' + relatedVehicle.Stock_Available__c);
                }

                if (relatedVehicle != null
                    && (relatedVehicle.Stock_Available__c == null
                        || relatedVehicle.Stock_Available__c <= 0)) {

                    System.debug('STRIKE! Stock is 0 or null. Throwing error...');
                    ord.addError('Cannot place this order. The selected vehicle has no available stock.');
                    // Skip dealer assignment for this failed record
                    continue;
                }
            }

            // ============================================================
            // Requirement B: Auto-Assign Nearest Dealer
            // ============================================================
            if (ord.Customer__c != null && !allDealers.isEmpty()) {
                Contact customer = customerMap.get(ord.Customer__c);

                // DEBUG: Log customer geolocation data
                System.debug('Customer found: ' + (customer != null));
                if (customer != null) {
                    System.debug('Customer Location: ' + customer.Location__Latitude__s + ', ' + customer.Location__Longitude__s);
                }

                // Only proceed if the customer has valid geolocation data
                if (customer != null
                    && customer.Location__Latitude__s != null
                    && customer.Location__Longitude__s != null) {

                    Location customerLoc = Location.newInstance(
                        customer.Location__Latitude__s,
                        customer.Location__Longitude__s
                    );

                    Id      closestDealerId = null;
                    Double  minDistance      = null;

                    for (Dealer__c dealer : allDealers) {
                        Location dealerLoc = Location.newInstance(
                            dealer.Location__Latitude__s,
                            dealer.Location__Longitude__s
                        );

                        // getDistance returns distance in the specified unit
                        Double dist = Location.getDistance(
                            customerLoc,
                            dealerLoc,
                            'km'  // Using kilometres; change to 'mi' for miles
                        );

                        // DEBUG: Log distance for each dealer
                        System.debug('Dealer ' + dealer.Id + ' distance: ' + dist + ' km');

                        if (minDistance == null || dist < minDistance) {
                            minDistance      = dist;
                            closestDealerId = dealer.Id;
                        }
                    }

                    // Assign the closest dealer to the order
                    if (closestDealerId != null) {
                        ord.Dealer__c = closestDealerId;
                        System.debug('Assigned closest Dealer: ' + closestDealerId + ' (distance: ' + minDistance + ' km)');
                    }
                }
            }
        }
    }
}
