# Phase 2: Requirement Analysis

## Business Requirements
* **Inventory Management:** The system must actively track vehicle stock and physically block users from ordering vehicles that are out of stock.
* **Smart Routing:** The system must capture the geolocation (Latitude/Longitude) of both Customers and Dealerships. When an order is placed, it must automatically route the order to the closest dealership branch.
* **Customer Engagement:** The system must automatically send email reminders to customers 24 hours before a scheduled Test Drive.
* **Service Management:** A dedicated interface must be available to log and track Service Requests.

## Technical Requirements
* **Platform:** Salesforce Developer Edition.
* **Backend Logic:** Apex Classes and Apex Triggers (Before Insert) for complex geolocation math and bulk-safe database queries.
* **Automation:** Salesforce Record-Triggered Flows and Time-Based Workflow Queues.
* **User Interface:** Lightning App Builder and Dynamic Forms to enforce Field-Level Security and provide clean, role-based layouts.
* **Deployment:** Salesforce CLI (sfdx) and VS Code for metadata deployment.