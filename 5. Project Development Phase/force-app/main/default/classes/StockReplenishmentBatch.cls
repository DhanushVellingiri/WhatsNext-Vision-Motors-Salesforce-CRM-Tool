/**
 * @description Batch Apex class for Stock Replenishment Notification.
 *
 *              Queries Vehicle__c records where Stock_Available__c < 5.
 *              Collects all low-stock vehicles and sends a single aggregated
 *              email notification to the system administrator.
 *
 *              Uses Database.Stateful to accumulate vehicle details across
 *              execute() batches, then sends one email in finish().
 *
 * @author      WhatsNext Vision Motors Dev Team
 * @date        2026-04-05
 */
public class StockReplenishmentBatch implements Database.Batchable<SObject>, Database.Stateful {

    // Accumulates low-stock vehicle details across batches
    @TestVisible
    private List<String> lowStockDetails = new List<String>();

    /**
     * @description Defines the scope: vehicles with stock below 5.
     * @param bc Batchable context.
     * @return QueryLocator for low-stock vehicles.
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Name, Make__c, Model__c, Stock_Available__c
            FROM   Vehicle__c
            WHERE  Stock_Available__c < 5
        ]);
    }

    /**
     * @description Accumulates vehicle information for each batch chunk.
     * @param bc    Batchable context.
     * @param scope List of low-stock Vehicle__c records.
     */
    public void execute(Database.BatchableContext bc, List<Vehicle__c> scope) {
        for (Vehicle__c v : scope) {
            String detail = '• ' + v.Name
                          + ' | Make: ' + (v.Make__c  != null ? v.Make__c  : 'N/A')
                          + ' | Model: ' + (v.Model__c != null ? v.Model__c : 'N/A')
                          + ' | Current Stock: ' + (v.Stock_Available__c != null
                                                    ? String.valueOf(v.Stock_Available__c.intValue())
                                                    : '0');
            lowStockDetails.add(detail);
        }
    }

    /**
     * @description Sends a single aggregated email to the admin after all
     *              batches finish. If no low-stock vehicles exist, no email is sent.
     * @param bc Batchable context.
     */
    public void finish(Database.BatchableContext bc) {
        if (lowStockDetails.isEmpty()) {
            System.debug(LoggingLevel.INFO,
                'StockReplenishmentBatch: No low-stock vehicles found. No email sent.');
            return;
        }

        // Build the email body
        String subject = 'Action Required: ' + lowStockDetails.size()
                       + ' Vehicle(s) Need Restocking';

        String body = 'Hello Admin,\n\n'
                    + 'The following vehicles have stock below the minimum threshold of 5 units '
                    + 'and require restocking:\n\n'
                    + String.join(lowStockDetails, '\n')
                    + '\n\nPlease coordinate with the supply chain team to replenish stock.\n\n'
                    + 'Regards,\n'
                    + 'WhatsNext Vision Motors — Automated Notification';

        // Retrieve the admin user's email
        // Using the running user's email, or you can hard-code / use Custom Metadata
        String adminEmail = UserInfo.getUserEmail();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ adminEmail });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        mail.setSaveAsActivity(false);

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
            System.debug(LoggingLevel.INFO,
                'StockReplenishmentBatch: Email sent to ' + adminEmail
                + ' for ' + lowStockDetails.size() + ' vehicle(s).');
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,
                'StockReplenishmentBatch: Failed to send email. Error: ' + e.getMessage());
        }
    }
}
