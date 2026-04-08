/**
 * @description Schedulable Apex class that runs both daily Batch jobs:
 *              1. BulkOrderProcessingBatch   — processes draft bulk orders.
 *              2. StockReplenishmentBatch    — notifies admin of low-stock vehicles.
 *
 *              Schedule this class to run daily at midnight using:
 *
 *                  System.schedule(
 *                      'WhatsNext Daily Batch Jobs',
 *                      '0 0 0 * * ?',
 *                      new DailyBatchScheduler()
 *                  );
 *
 *              Cron Expression Breakdown:
 *                  0 0 0 * * ?
 *                  │ │ │ │ │ └── Day of week (? = no specific)
 *                  │ │ │ │ └──── Month (every month)
 *                  │ │ │ └────── Day of month (every day)
 *                  │ │ └──────── Hour (0 = midnight)
 *                  │ └────────── Minute (0)
 *                  └──────────── Second (0)
 *
 * @author      WhatsNext Vision Motors Dev Team
 * @date        2026-04-05
 */
public class DailyBatchScheduler implements Schedulable {

    // Default batch size; can be adjusted per org limits and data volume
    private static final Integer BATCH_SIZE = 200;

    /**
     * @description Called by the Salesforce scheduler at the configured time.
     *              Kicks off both Batch Apex jobs.
     * @param sc SchedulableContext provided by the platform.
     */
    public void execute(SchedulableContext sc) {
        // Job 1: Process draft bulk Vehicle Orders
        Database.executeBatch(new BulkOrderProcessingBatch(), BATCH_SIZE);

        // Job 2: Notify admin about low-stock vehicles
        Database.executeBatch(new StockReplenishmentBatch(), BATCH_SIZE);
    }
}
