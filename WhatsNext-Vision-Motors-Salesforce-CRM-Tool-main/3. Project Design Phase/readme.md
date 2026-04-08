# Phase 3: Project Design Phase

## Entity-Relationship Data Model
The system architecture relies on custom objects linking together to form a cohesive database:
* **Contact (Standard Object):** Represents the Customer. Extended with custom Geolocation fields.
* **Dealer__c (Custom Object):** Represents physical branch locations. Contains Geolocation fields.
* **Vehicle__c (Custom Object):** Represents the inventory catalogue. Contains pricing and dynamic stock-level fields.
* **Vehicle_Order__c (Custom Object):** The junction object linking a Customer, a Vehicle, and a Dealer.
* **Test_Drive__c & Service_Request__c:** Child objects related to the Customer and Vehicle for post-sale tracking.

## UI/UX Design Strategy
* **Dynamic Forms:** Utilized to break up monolithic page layouts into modular, logical sections (e.g., separating Geolocation coordinates from basic contact info).
* **Field-Level Security:** Strict visibility controls ensure that backend calculation fields are only exposed to System Administrators, keeping the standard user interface uncluttered.