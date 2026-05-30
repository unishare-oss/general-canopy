**Canopy**

*“Canopy” — Concepts and List of Functions*

Submission 1 — Requirements Specification  |  Theme: Fighting the Impact of Earth’s Temperature

# **1\. Project Concept**

## **1.1 Problem Statement**

Urban tree planting is one of the most cost-effective interventions against the urban heat island effect, carbon emissions, and degraded air quality. However, a significant percentage of newly planted street trees die within their first three years — the establishment period — primarily because of insufficient watering and lack of monitoring. Municipal forestry departments lack the manpower to survey every block, and well-intentioned planting initiatives often end at the ribbon-cutting ceremony, leaving thousands of vulnerable saplings unattended.

## **1.2 Proposed Solution**

Canopy is a mobile platform that connects residents to specific, geo-tagged newly planted trees in their neighborhood. Users “adopt” a sapling, receive weather-aware watering reminders, perform monthly photo check-ins, and earn community status by keeping their tree alive through its vulnerable establishment period.

The platform introduces a playful swipe-to-adopt mechanic, inspired by Tinder, to make tree adoption feel discoverable, social, and engaging — turning a civic responsibility into a game.

## **1.3 Vision**

Transform urban tree mortality from an invisible problem into a community-driven success story, while generating a valuable crowdsourced dataset for urban forestry research.

## **1.4 Target Users**

* **Primary:** Urban and suburban residents who walk past newly planted street trees daily.

* **Secondary:** Municipal foresters and campus grounds staff who manage planting programs.

* **Tertiary:** Schools, community groups, and families seeking climate-action activities.

## **1.5 Key Differentiators**

* Focuses on post-planting survival, not just the planting moment.

* Geo-specific — every tree is a real, identifiable sapling, not a generic species placeholder.

* Weather-aware — watering reminders adapt to local rainfall forecasts.

* Community-driven — leaderboards, badges, and a public obituary wall create social pressure.

* Generates research data — photo time-series become training data for urban forestry analytics.

# **2\. Core Concepts**

The table below defines the key domain concepts used throughout this document and the system.

| Concept | Definition |
| :---- | :---- |
| **Sapling** | A real, geo-tagged newly planted tree registered in the system by a city or campus partner. |
| **Guardian** | A registered user who has adopted one or more saplings. |
| **Adoption** | The act of a guardian committing to monitor and care for a specific sapling. |
| **My Grove** | A guardian’s personal collection of adopted saplings. |
| **Check-in** | A periodic photo and health-report submission by a guardian. |
| **Health Score** | A computed indicator (0–100) reflecting a sapling’s current condition. |
| **Watering Event** | A logged instance of a guardian watering an adopted sapling. |
| **Survival Streak** | The number of consecutive days a guardian’s adopted sapling has remained alive. |
| **At-Risk Flag** | An automated alert raised when a sapling shows signs of decline. |
| **Obituary** | A public record entry created when an adopted sapling dies. |
| **Admin Portal** | The interface used by city or campus forestry staff to manage planting lists and view data. |

# **3\. List of Functions**

Functions are grouped by module and classified by priority. MVP functions are required for the minimum viable product; Stretch functions are targeted enhancements to be implemented if time permits.

## **3.1 User Account & Authentication**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F1.1** | Register a new user account via email and password | **MVP** |
| **F1.2** | Sign in and sign out | **MVP** |
| **F1.3** | Sign in with Google OAuth | **MVP** |
| **F1.4** | Reset forgotten password via email | **MVP** |
| **F1.5** | Complete onboarding quiz (location, availability, experience) | **MVP** |
| **F1.6** | View and edit user profile | **MVP** |
| **F1.7** | Upload profile avatar | **MVP** |
| **F1.8** | Delete account and associated data | **MVP** |

## **3.2 Sapling Discovery & Adoption**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F2.1** | View swipeable cards of unadopted saplings near user’s location | **MVP** |
| **F2.2** | Swipe right to adopt, left to pass on a sapling | **MVP** |
| **F2.3** | View detailed sapling profile (species, age, location, photos, bio) | **MVP** |
| **F2.4** | Filter available saplings by distance, species, or sunlight needs | **MVP** |
| **F2.5** | View all saplings on an interactive map with color-coded health pins | **MVP** |
| **F2.6** | Toggle between swipe view and map view | **MVP** |
| **F2.7** | Get walking or driving directions to a sapling’s location | **MVP** |
| **F2.8** | Confirm adoption and generate a shareable adoption certificate | **MVP** |
| **F2.9** | Release an adopted sapling back to the available pool | **MVP** |
| **F2.10** | Use AR camera mode to locate an adopted sapling in physical space | **Stretch** |

## **3.3 My Grove (Guardian Dashboard)**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F3.1** | View list of all adopted saplings with status indicators | **MVP** |
| **F3.2** | View individual sapling detail page with full history | **MVP** |
| **F3.3** | View photo timeline of an adopted sapling | **MVP** |
| **F3.4** | View side-by-side growth comparison (first vs latest photo) | **MVP** |
| **F3.5** | View next scheduled action for each sapling | **MVP** |
| **F3.6** | View current health score for each sapling | **MVP** |

## **3.4 Watering & Care Management**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F4.1** | Generate watering schedule based on species, season, and local weather | **MVP** |
| **F4.2** | Skip scheduled watering when rain is forecast (weather API integration) | **MVP** |
| **F4.3** | Send push notification reminders for due watering | **MVP** |
| **F4.4** | Mark a watering event as completed and log it | **MVP** |
| **F4.5** | View historical watering log per sapling | **MVP** |
| **F4.6** | Manually log unscheduled care activities (e.g., mulching, weeding) | **MVP** |

## **3.5 Health Monitoring & Check-ins**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F5.1** | Upload a monthly photo check-in for each adopted sapling | **MVP** |
| **F5.2** | Submit a structured health report (leaves, trunk, soil condition) | **MVP** |
| **F5.3** | Automatically calculate health score from report inputs | **MVP** |
| **F5.4** | Flag a sapling as at-risk or in distress | **MVP** |
| **F5.5** | Send at-risk alerts to administrator or forestry contact | **MVP** |
| **F5.6** | Mark a sapling as deceased and submit an obituary entry | **MVP** |
| **F5.7** | Estimate tree health from photo using a vision model | **Stretch** |
| **F5.8** | Predict at-risk trees before visible decline (analytics) | **Stretch** |

## **3.6 Impact & Gamification**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F6.1** | View personal impact dashboard (CO₂ offset, water given, survival days) | **MVP** |
| **F6.2** | View real-world equivalents (e.g., equivalent car miles offset) | **MVP** |
| **F6.3** | View current survival streak for each adopted sapling | **MVP** |
| **F6.4** | Earn and display achievement badges | **MVP** |
| **F6.5** | View neighborhood leaderboard rankings | **MVP** |
| **F6.6** | View recent adoption activity feed | **MVP** |
| **F6.7** | Share achievements and certificates to social media | **MVP** |

## **3.7 Community & Public Pages**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F7.1** | View public tree obituary wall with city or area tags | **MVP** |
| **F7.2** | View aggregate community stats (total trees adopted, survival rate) | **MVP** |
| **F7.3** | Co-adopt a sapling with friends or family members | **Stretch** |
| **F7.4** | Send direct message to a city forester | **Stretch** |

## **3.8 Admin / Forestry Portal**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F8.1** | Administrator login with role-based access | **MVP** |
| **F8.2** | Upload sapling planting list via CSV | **MVP** |
| **F8.3** | Manually add, edit, or remove a sapling record | **MVP** |
| **F8.4** | View adoption rate dashboard (adopted vs available) | **MVP** |
| **F8.5** | View map of at-risk and deceased saplings | **MVP** |
| **F8.6** | Receive in-app alerts when a sapling is flagged at-risk | **MVP** |
| **F8.7** | Export survival data and check-in records as CSV | **MVP** |

## **3.9 System & Cross-Cutting Functions**

| ID | Function | Priority |
| :---- | :---- | ----- |
| **F9.1** | Integrate with weather API for rainfall and forecast data | **MVP** |
| **F9.2** | Integrate with maps API for geolocation and routing | **MVP** |
| **F9.3** | Send push notifications via cloud messaging service | **MVP** |
| **F9.4** | Store and serve uploaded images via cloud storage | **MVP** |
| **F9.5** | Persist all user, sapling, and event data in a database | **MVP** |
| **F9.6** | Handle offline photo uploads with sync when reconnected | **Stretch** |

# **4\. Function Summary**

The table below summarizes the total number of functions per module, split by priority.

| Module | MVP | Stretch | Total |
| :---- | ----- | ----- | ----- |
| **User Account & Authentication** | 8 | 0 | 8 |
| **Sapling Discovery & Adoption** | 9 | 1 | 10 |
| **My Grove (Guardian Dashboard)** | 6 | 0 | 6 |
| **Watering & Care Management** | 6 | 0 | 6 |
| **Health Monitoring & Check-ins** | 6 | 2 | 8 |
| **Impact & Gamification** | 7 | 0 | 7 |
| **Community & Public Pages** | 2 | 2 | 4 |
| **Admin / Forestry Portal** | 7 | 0 | 7 |
| **System & Cross-Cutting** | 5 | 1 | 6 |
| **Total** | **56** | **6** | **62** |

# **5\. Assumptions & Constraints**

* The application will be developed for mobile platforms as the primary delivery target.

* Real payment processing and carbon-credit transactions are out of scope for the MVP.

* Multi-language support is out of scope for the MVP.

  