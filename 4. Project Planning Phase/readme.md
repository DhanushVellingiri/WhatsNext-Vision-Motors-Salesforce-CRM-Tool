# Phase 4: Project Planning Phase

## Development Roadmap
The development of the Vision Motors CRM was executed in a structured, agile format:

1. **Environment Initialization:** Setting up the Salesforce Developer Org, configuring VS Code, and authenticating the Salesforce CLI.
2. **Schema Creation:** Building the custom objects (`Dealer__c`, `Vehicle__c`, `Vehicle_Order__c`, etc.) and defining their relationships (Lookups and Master-Detail).
3. **Security & UI Configuration:** Adjusting profile permissions, field-level security, and designing Lightning Record Pages using Dynamic Forms.
4. **Business Logic Implementation (Apex):** Writing the `VehicleOrderTrigger` and its Handler Class to enforce the 0-stock validation rule and execute the `Location.getDistance()` geolocation auto-assignment logic.
5. **Workflow Automation:** Building the Record-Triggered Flow to handle time-based email alerts for scheduled Test Drives.
6. **Testing & Deployment:** Validating trigger logic via the Developer Console and pushing final metadata to GitHub.