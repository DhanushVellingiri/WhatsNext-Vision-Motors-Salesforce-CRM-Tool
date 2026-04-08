# Lightning App Setup — WhatsNext Vision Motors

## Prerequisites
- All custom objects and their Tabs have been created (see `01_DataModel_Setup.md`).

---

## Create the Lightning App

1. Go to **Setup → App Manager → New Lightning App**.
2. **App Details & Branding:**
   - **App Name**: `WhatsNext Vision Motors`
   - **Developer Name**: `WhatsNext_Vision_Motors`
   - **Description**: `CRM application for WhatsNext Vision Motors automotive dealership.`
   - (Optional) Upload a custom logo image.
   - Click **Next**.

3. **App Options:**
   - Navigation Style: **Standard Navigation**
   - Supported Form Factors: Check **Desktop** and **Phone** as needed.
   - Click **Next**.

4. **Utility Items (Optional):**
   - You can skip this or add utility items later.
   - Click **Next**.

5. **Select Items (Navigation Items):**
   Add the following tabs in this order:

   | # | Tab Name          |
   |---|-------------------|
   | 1 | Vehicles          |
   | 2 | Dealers           |
   | 3 | Contacts          |
   | 4 | Vehicle Orders    |
   | 5 | Test Drives       |
   | 6 | Service Requests  |
   | 7 | Dashboards        |

   - Use the **Add** arrow to move items from "Available Items" to "Selected Items".
   - Reorder them as listed above using the **Up/Down** arrows.
   - Click **Next**.

6. **Assign to Profiles:**
   - Select the profiles that should have access (e.g., **System Administrator**, **Standard User**, and any custom profiles).
   - Check **Set as Default** for System Administrator if desired.
   - Click **Save & Finish**.

---

## Verify the App

1. Click the **App Launcher** (grid icon, top-left).
2. Search for **WhatsNext Vision Motors**.
3. Click the app name to open it.
4. Confirm all 7 navigation tabs appear in the header bar.

---

## (Optional) Customize Record Pages

For a richer user experience, create **custom Lightning Record Pages** for each object:

1. Navigate to a record (e.g., a Vehicle record).
2. Click the **Gear Icon → Edit Page** to open **Lightning App Builder**.
3. Drag and drop components:
   - **Record Detail** — shows all fields.
   - **Related Lists** — shows child records (e.g., Vehicle Orders on a Vehicle page).
   - **Highlights Panel** — key fields at a glance.
4. Click **Save → Activation → Assign as Org Default** (or App/Record-Type specific).
5. Repeat for Dealer, Vehicle Order, Test Drive, and Service Request record pages.
