The database is designed to support a platform managing social media campaigns for client organisations. Here is a straightforward explanation of the structure and key points:

### Key Concepts

- **Organisations** are companies or agencies that use this platform.
- **Users** are individuals within these organisations who access the platform.
- These organisations manage **clients**, for whom they run **campaigns** across various social media platforms.
- Each campaign consists of **scheduled posts** — specific pieces of content planned to go live on certain dates and times.
- The platform tracks **engagement metrics** for each scheduled post, such as likes, shares, comments, and impressions.
- Media files like images or videos used in campaigns or posts are stored as **assets**.
- Users can create **notes** linked to campaigns or specific posts for internal communication or documentation.

### Database Structure Overview

1. **Reference Data**  
   This table holds system-wide static values grouped by categories, such as user roles, platform types, industries, and subscription tiers. It ensures consistency when categorising information throughout the platform.

2. **Organisations**  
   Stores details about client organisations or agencies, including their industry and subscription type.

3. **Users**  
   Represents platform users who belong to organisations. Each user has a unique email for login, a hashed password for security, and an assigned role determining their access level.

4. **Clients**  
   Represents end-clients managed by organisations. Each client is linked to a single organisation and has contact information and an active status.

5. **Campaigns**  
   Social media campaigns are linked to clients. Each campaign is defined by a name, targeted platform, goal, scheduled start and end dates, and budget details.

6. **Scheduled Posts**  
   Within a campaign, posts are scheduled with content, optional media, the platform they will be published to, and timing. Each post has a status indicating whether it is scheduled, published, or otherwise.

7. **Post Metrics**  
   Contains snapshots of engagement data for scheduled posts, capturing how users interact with the content (likes, shares, comments, impressions) at specific points in time.

8. **Assets**  
   Media files such as images or videos linked either directly to campaigns or individual scheduled posts.

9. **Notes**  
   Internal textual notes authored by users, linked either to campaigns or scheduled posts. Only one of these links may be set for each note, ensuring clarity on the note’s context.

### Data Integrity and Relationships

- Each table uses a unique identifier (UUID) as its primary key to track each record consistently across the database.
- Foreign keys enforce relationships, such as users belonging to organisations, campaigns tied to clients, and posts related to campaigns.
- Unique constraints prevent duplication, for example ensuring user emails are unique across the platform and campaign names don't duplicate for a given client.
- Check constraints guarantee that notes can only be linked to either a campaign or a scheduled post, not both.
- Timestamps record creation and update times, with references to users who performed these actions, enabling auditability.

### Overall

The database is structured to ensure a clear hierarchical model: organisations own clients, who have campaigns, which contain posts. The platform captures user roles and permissions while tracking content scheduling, media, user interactions, and internal communication through notes. The design emphasises integrity, audit trails, and flexibility in managing social media marketing activities.