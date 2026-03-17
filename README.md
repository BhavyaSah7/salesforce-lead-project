# Salesforce Lead Auto-Assignment, Nurturing System & LWC Components

> **Salesforce Sales Cloud Portfolio Project** — A complete end-to-end lead management system built on Salesforce Developer Edition, demonstrating Apex development, Flow automation, Lightning Web Components, and professional SFDX deployment workflows.

---

## 📋 Table of Contents
- [Business Problem Solved](#business-problem-solved)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Key Concepts Demonstrated](#key-concepts-demonstrated)
- [Testing](#testing)
- [Interview Talking Points](#interview-talking-points)
- [What I Would Add Next](#what-i-would-add-next)

---

## 💼 Business Problem Solved

| Problem | Solution Built |
|---|---|
| Leads assigned manually — slow and error-prone | Lead Assignment Rules route instantly by region and industry |
| No automated follow-up after assignment | Apex Trigger sends personalised email on every assignment |
| Reps forget to log first contact | LWC Quick Action — one click marks contact and timestamps it |
| No visibility into uncontacted leads | Scheduled Flow escalates after 48 hours and alerts manager |
| Managers need daily pipeline overview | LWC Pipeline Dashboard shows live stats on Home page |

---

## 🏗️ Architecture
```
Lead Created
      ↓
[Lead Assignment Rules] — routes by region/industry
      ↓
[Apex Trigger — after insert/update]
Sends personalised follow-up email
Stamps Assignment_Date__c and Follow_Up_Sent__c
      ↓
[LWC Quick Action — Lead Record Page]
One click marks First_Contact_Made__c = true
      ↓
[Scheduled Flow — runs daily 9 AM]
Finds leads uncontacted after 48 hours
Marks Escalated__c = true + emails manager
      ↓
[LWC Pipeline Dashboard — Home Page]
Live stats: total, contacted, pending, escalated
```

---

## ⚙️ Features

### Phase 1 — Data Model
6 custom fields on Lead object tracking the full assignment and contact lifecycle — `Lead_Region__c`, `Assignment_Date__c`, `First_Contact_Made__c`, `Follow_Up_Sent__c`, `Escalated__c`, `Assigned_Rep__c`

### Phase 2 — Lead Assignment Rules
Declarative routing by region (North, South, East, West, International) and industry with a catch-all entry ensuring every lead gets assigned. No code required — demonstrates when to use configuration over development.

### Phase 3 — Apex Trigger (LeadNurturingTrigger)
- Fires on `after insert` AND `after update` — covers creation via Assignment Rules and manual reassignment
- Uses `Trigger.isInsert` / `Trigger.isUpdate` for precise logic separation
- Detects ownership changes via `Trigger.oldMap` comparison
- Sends personalised email using `Messaging.SingleEmailMessage`
- Bulk-safe collector pattern — emails batched outside loop
- `Test.isRunningTest()` prevents email limit errors in test context
- Recursive trigger prevention via `Follow_Up_Sent__c` guard condition

### Phase 4 — Escalation Flow
- Scheduled-Triggered Flow runs daily at 9 AM
- Formula variable calculates 48-hour threshold: `{!$Flow.CurrentDateTime} - (48/24)`
- Filters uncontacted, unescalated, unconverted leads past assignment deadline
- Updates `Escalated__c = True` and sends manager email alert

### Phase 5 — Reports & Dashboard
- Lead Assignment by Region — donut chart
- Rep Follow-Up Performance — bar chart per rep
- Escalated Leads — action table sorted by oldest first
- Lead Pipeline Overview dashboard combining all 3 reports

### Phase 6a — LWC Quick Action (leadQuickAction)
- `@wire` auto-fetches lead details on load
- `@api recordId` receives current record Id from platform
- Button disabled during processing — prevents double clicks
- `ShowToastEvent` for success/error notifications
- `refreshApex` + `getRecordNotifyChange` for instant UI update
- Conditional rendering — button disappears after contact marked
- Restricted to Lead object only via `js-meta.xml`

### Phase 6b — LWC Pipeline Dashboard (leadPipelineDashboard)
- Inner Apex class (`LeadStats`) returns 5 stats in one call
- `renderedCallback()` lifecycle hook sets progress bar width
- Contact rate calculated in JavaScript
- Colour-coded stat tiles with custom CSS
- Live on Home page — visible to all users on login

---

## 🛠️ Tech Stack

| Technology | Usage |
|---|---|
| Salesforce Apex | Trigger, Controller, Test Classes |
| Salesforce Flow | Scheduled-Triggered escalation |
| Lightning Web Components | Quick Action + Pipeline Dashboard |
| SLDS | Component styling |
| Salesforce CLI (SFDX) | Deployment workflow |
| VS Code + SF Extension Pack | Development environment |
| Lead Assignment Rules | Declarative lead routing |
| Reports & Dashboards | Analytics layer |

---

## 📁 Project Structure
```
force-app/main/default/
├── classes/
│   ├── LeadContactController.cls
│   ├── LeadContactControllerTest.cls
│   └── LeadNurturingTriggerTest.cls
├── triggers/
│   └── LeadNurturingTrigger.trigger
└── lwc/
    ├── leadQuickAction/
    │   ├── leadQuickAction.html
    │   ├── leadQuickAction.js
    │   └── leadQuickAction.js-meta.xml
    └── leadPipelineDashboard/
        ├── leadPipelineDashboard.html
        ├── leadPipelineDashboard.js
        ├── leadPipelineDashboard.css
        └── leadPipelineDashboard.js-meta.xml
```

---

## 🔍 Key Concepts Demonstrated

- `Trigger.isInsert` / `Trigger.isUpdate` context separation
- `Trigger.oldMap` for field change detection
- Bulk-safe email batching and DML collector pattern
- `Test.isRunningTest()` for email limit handling
- `@api`, `@wire`, `@track` LWC decorators with correct use cases
- Wire (reactive read) vs imperative (button-triggered write)
- `renderedCallback()` for post-render DOM manipulation
- `getRecordNotifyChange` for cross-component page refresh
- Inner Apex classes for structured multi-value returns
- Flow formula variables for hour-based threshold calculations
- Declarative vs programmatic decision making

---

## 🧪 Testing

| Test Class | Methods | What's Covered |
|---|---|---|
| LeadNurturingTriggerTest | 5 | after insert, after update, null email, no duplicate, bulk 200 |
| LeadContactControllerTest | 4 | markFirstContact, getLeadDetails, getLeadStats, already contacted |

---

## 🚀 What I Would Add Next

- Weighted round-robin assignment using Apex
- Einstein Lead Scoring integration
- Queueable Apex for high-volume email sending
- Custom Metadata for configurable escalation thresholds
- LWC unit tests using `@salesforce/sfdx-lwc-jest`
- Slack integration for real-time breach alerts

---

## 🔗 Related Project

**Project 1 — Salesforce Case Management & SLA Tracker**
Service Cloud implementation — Apex triggers, Scheduled Flows, custom objects, and dashboards.

---

*Built on Salesforce Developer Edition | Deployed via Salesforce CLI (SFDX) | API Version 66.0*
