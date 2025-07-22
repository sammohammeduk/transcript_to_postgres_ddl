-- =============================================================
-- STEP 1: Create Extensions
-- =============================================================

-- Enable generation of UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram indexes for fuzzy search
CREATE EXTENSION IF NOT EXISTS pg_trgm;


-- =============================================================
-- STEP 2: Create All Tables and Fields
-- =============================================================

-- Table: reference_data
CREATE TABLE reference_data (
    id                  uuid            NOT NULL DEFAULT uuid_generate_v4(),
    category            text            NOT NULL,
    code                text            NOT NULL,
    value               text,
    description         text,
    is_active           boolean         NOT NULL DEFAULT TRUE,
    created_by_user_id  uuid,
    created_at          timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id  uuid,
    updated_at          timestamptz     NOT NULL DEFAULT now()
);

-- Table: organisations
CREATE TABLE organisations (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    name                 text            NOT NULL,
    industry             text,
    subscription_tier    text,
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: users
CREATE TABLE users (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    organisation_id      uuid            NOT NULL,
    email                text            NOT NULL,
    password_hash        text            NOT NULL,
    role                 text            NOT NULL,
    last_login_at        timestamptz,
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: clients
CREATE TABLE clients (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    organisation_id      uuid            NOT NULL,
    name                 text            NOT NULL,
    contact_email        text,
    active               boolean         NOT NULL DEFAULT TRUE,
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: campaigns
CREATE TABLE campaigns (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    client_id            uuid            NOT NULL,
    name                 text            NOT NULL,
    platform             text            NOT NULL,
    goal                 text,
    start_date           date,
    end_date             date,
    estimated_budget     numeric(12,2),
    actual_spend         numeric(12,2),
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: scheduled_posts
CREATE TABLE scheduled_posts (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    campaign_id          uuid            NOT NULL,
    content              text,
    media_url            text,
    platform             text            NOT NULL,
    scheduled_time       timestamptz     NOT NULL,
    status               text            NOT NULL DEFAULT 'scheduled',
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: post_metrics
CREATE TABLE post_metrics (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    scheduled_post_id    uuid            NOT NULL,
    likes                integer         NOT NULL DEFAULT 0,
    shares               integer         NOT NULL DEFAULT 0,
    comments             integer         NOT NULL DEFAULT 0,
    impressions          integer         NOT NULL DEFAULT 0,
    collected_at         timestamptz     NOT NULL DEFAULT now(),
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: assets
CREATE TABLE assets (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    campaign_id          uuid,
    scheduled_post_id    uuid,
    file_url             text            NOT NULL,
    asset_type           text,
    title                text,
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

-- Table: notes
CREATE TABLE notes (
    id                   uuid            NOT NULL DEFAULT uuid_generate_v4(),
    user_id              uuid            NOT NULL,
    campaign_id          uuid,
    scheduled_post_id    uuid,
    content              text            NOT NULL,
    created_by_user_id   uuid,
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_by_user_id   uuid,
    updated_at           timestamptz     NOT NULL DEFAULT now()
);


-- =============================================================
-- STEP 3: Create All Constraints
-- =============================================================

-- Primary Keys
ALTER TABLE reference_data ADD CONSTRAINT reference_data_pkey PRIMARY KEY (id);
ALTER TABLE organisations   ADD CONSTRAINT organisations_pkey PRIMARY KEY (id);
ALTER TABLE users           ADD CONSTRAINT users_pkey PRIMARY KEY (id);
ALTER TABLE clients         ADD CONSTRAINT clients_pkey PRIMARY KEY (id);
ALTER TABLE campaigns       ADD CONSTRAINT campaigns_pkey PRIMARY KEY (id);
ALTER TABLE scheduled_posts ADD CONSTRAINT scheduled_posts_pkey PRIMARY KEY (id);
ALTER TABLE post_metrics    ADD CONSTRAINT post_metrics_pkey PRIMARY KEY (id);
ALTER TABLE assets          ADD CONSTRAINT assets_pkey PRIMARY KEY (id);
ALTER TABLE notes           ADD CONSTRAINT notes_pkey PRIMARY KEY (id);

-- Unique Constraints
ALTER TABLE reference_data ADD CONSTRAINT reference_data_cat_code_uniq UNIQUE (category, code);
ALTER TABLE organisations   ADD CONSTRAINT organisations_name_uniq UNIQUE (name);
ALTER TABLE users           ADD CONSTRAINT users_email_uniq UNIQUE (email);
ALTER TABLE clients         ADD CONSTRAINT clients_org_name_uniq UNIQUE (organisation_id, name);
ALTER TABLE campaigns       ADD CONSTRAINT campaigns_client_name_uniq UNIQUE (client_id, name);

-- Check Constraints
ALTER TABLE notes ADD CONSTRAINT notes_subject_check 
    CHECK (
        (campaign_id IS NOT NULL AND scheduled_post_id IS NULL)
        OR 
        (campaign_id IS NULL AND scheduled_post_id IS NOT NULL)
    );


-- =============================================================
-- STEP 4: Create All Foreign Keys
-- =============================================================

-- reference_data metadata
ALTER TABLE reference_data 
    ADD CONSTRAINT reference_data_created_by_fkey FOREIGN KEY (created_by_user_id)  REFERENCES users(id),
    ADD CONSTRAINT reference_data_updated_by_fkey FOREIGN KEY (updated_by_user_id)  REFERENCES users(id);

-- organisations metadata
ALTER TABLE organisations 
    ADD CONSTRAINT org_created_by_fkey FOREIGN KEY (created_by_user_id)  REFERENCES users(id),
    ADD CONSTRAINT org_updated_by_fkey FOREIGN KEY (updated_by_user_id)  REFERENCES users(id);

-- users
ALTER TABLE users
    ADD CONSTRAINT users_org_fkey           FOREIGN KEY (organisation_id)     REFERENCES organisations(id),
    ADD CONSTRAINT users_created_by_self    FOREIGN KEY (created_by_user_id)   REFERENCES users(id),
    ADD CONSTRAINT users_updated_by_self    FOREIGN KEY (updated_by_user_id)   REFERENCES users(id);

-- clients
ALTER TABLE clients
    ADD CONSTRAINT clients_org_fkey         FOREIGN KEY (organisation_id)     REFERENCES organisations(id),
    ADD CONSTRAINT clients_created_by_fkey  FOREIGN KEY (created_by_user_id)   REFERENCES users(id),
    ADD CONSTRAINT clients_updated_by_fkey  FOREIGN KEY (updated_by_user_id)   REFERENCES users(id);

-- campaigns
ALTER TABLE campaigns
    ADD CONSTRAINT campaigns_client_fkey        FOREIGN KEY (client_id)          REFERENCES clients(id),
    ADD CONSTRAINT campaigns_created_by_fkey    FOREIGN KEY (created_by_user_id)  REFERENCES users(id),
    ADD CONSTRAINT campaigns_updated_by_fkey    FOREIGN KEY (updated_by_user_id)  REFERENCES users(id);

-- scheduled_posts
ALTER TABLE scheduled_posts
    ADD CONSTRAINT schedposts_campaign_fkey     FOREIGN KEY (campaign_id)        REFERENCES campaigns(id),
    ADD CONSTRAINT schedposts_created_by_fkey   FOREIGN KEY (created_by_user_id)  REFERENCES users(id),
    ADD CONSTRAINT schedposts_updated_by_fkey   FOREIGN KEY (updated_by_user_id)  REFERENCES users(id);

-- post_metrics
ALTER TABLE post_metrics
    ADD CONSTRAINT metrics_post_fkey            FOREIGN KEY (scheduled_post_id)   REFERENCES scheduled_posts(id),
    ADD CONSTRAINT metrics_created_by_fkey      FOREIGN KEY (created_by_user_id)   REFERENCES users(id),
    ADD CONSTRAINT metrics_updated_by_fkey      FOREIGN KEY (updated_by_user_id)   REFERENCES users(id);

-- assets
ALTER TABLE assets
    ADD CONSTRAINT assets_campaign_fkey         FOREIGN KEY (campaign_id)         REFERENCES campaigns(id),
    ADD CONSTRAINT assets_schedpost_fkey        FOREIGN KEY (scheduled_post_id)   REFERENCES scheduled_posts(id),
    ADD CONSTRAINT assets_created_by_fkey       FOREIGN KEY (created_by_user_id)  REFERENCES users(id),
    ADD CONSTRAINT assets_updated_by_fkey       FOREIGN KEY (updated_by_user_id)  REFERENCES users(id);

-- notes
ALTER TABLE notes
    ADD CONSTRAINT notes_user_fkey              FOREIGN KEY (user_id)             REFERENCES users(id),
    ADD CONSTRAINT notes_campaign_fkey          FOREIGN KEY (campaign_id)         REFERENCES campaigns(id),
    ADD CONSTRAINT notes_schedpost_fkey         FOREIGN KEY (scheduled_post_id)   REFERENCES scheduled_posts(id),
    ADD CONSTRAINT notes_created_by_fkey        FOREIGN KEY (created_by_user_id)   REFERENCES users(id),
    ADD CONSTRAINT notes_updated_by_fkey        FOREIGN KEY (updated_by_user_id)   REFERENCES users(id);


-- =============================================================
-- COMMENTS: Document Tables and Columns
-- =============================================================

-- reference_data
COMMENT ON TABLE reference_data IS 'Stores reference values for categories such as roles, platforms, industries, etc.';
COMMENT ON COLUMN reference_data.id IS 'Primary key, UUID.';
COMMENT ON COLUMN reference_data.category IS 'Grouping category, e.g., role, platform, industry.';
COMMENT ON COLUMN reference_data.code IS 'Code or key within the category.';
COMMENT ON COLUMN reference_data.value IS 'Human-readable value.';
COMMENT ON COLUMN reference_data.description IS 'Optional description.';
COMMENT ON COLUMN reference_data.is_active IS 'Flag indicating active/inactive status.';
COMMENT ON COLUMN reference_data.created_by_user_id IS 'User who inserted this record.';
COMMENT ON COLUMN reference_data.created_at IS 'Timestamp when inserted.';
COMMENT ON COLUMN reference_data.updated_by_user_id IS 'User who last updated this record.';
COMMENT ON COLUMN reference_data.updated_at IS 'Timestamp when last updated.';

-- organisations
COMMENT ON TABLE organisations IS 'Client organisations or agencies using the platform.';
COMMENT ON COLUMN organisations.id IS 'Primary key, UUID.';
COMMENT ON COLUMN organisations.name IS 'Organisation name.';
COMMENT ON COLUMN organisations.industry IS 'Industry code from reference_data.';
COMMENT ON COLUMN organisations.subscription_tier IS 'Subscription tier code from reference_data.';
COMMENT ON COLUMN organisations.created_by_user_id IS 'User who created this organisation record.';
COMMENT ON COLUMN organisations.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN organisations.updated_by_user_id IS 'User who last updated this organisation record.';
COMMENT ON COLUMN organisations.updated_at IS 'Timestamp when last updated.';

-- users
COMMENT ON TABLE users IS 'Platform users with authentication and role-based access.';
COMMENT ON COLUMN users.id IS 'Primary key, UUID.';
COMMENT ON COLUMN users.organisation_id IS 'Owning organisation.';
COMMENT ON COLUMN users.email IS 'Unique login email.';
COMMENT ON COLUMN users.password_hash IS 'Hashed password.';
COMMENT ON COLUMN users.role IS 'Role code from reference_data.';
COMMENT ON COLUMN users.last_login_at IS 'Timestamp of last successful login.';
COMMENT ON COLUMN users.created_by_user_id IS 'User who created this user record.';
COMMENT ON COLUMN users.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN users.updated_by_user_id IS 'User who last updated this user record.';
COMMENT ON COLUMN users.updated_at IS 'Timestamp when last updated.';

-- clients
COMMENT ON TABLE clients IS 'End-clients managed by organisations.';
COMMENT ON COLUMN clients.id IS 'Primary key, UUID.';
COMMENT ON COLUMN clients.organisation_id IS 'Owning organisation.';
COMMENT ON COLUMN clients.name IS 'Client name.';
COMMENT ON COLUMN clients.contact_email IS 'Primary contact email.';
COMMENT ON COLUMN clients.active IS 'Indicates if client is active.';
COMMENT ON COLUMN clients.created_by_user_id IS 'User who created this client record.';
COMMENT ON COLUMN clients.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN clients.updated_by_user_id IS 'User who last updated this client record.';
COMMENT ON COLUMN clients.updated_at IS 'Timestamp when last updated.';

-- campaigns
COMMENT ON TABLE campaigns IS 'Social media campaigns for clients.';
COMMENT ON COLUMN campaigns.id IS 'Primary key, UUID.';
COMMENT ON COLUMN campaigns.client_id IS 'Owning client.';
COMMENT ON COLUMN campaigns.name IS 'Campaign name.';
COMMENT ON COLUMN campaigns.platform IS 'Platform code from reference_data.';
COMMENT ON COLUMN campaigns.goal IS 'Campaign goal code from reference_data.';
COMMENT ON COLUMN campaigns.start_date IS 'Start date.';
COMMENT ON COLUMN campaigns.end_date IS 'End date.';
COMMENT ON COLUMN campaigns.estimated_budget IS 'Planned budget.';
COMMENT ON COLUMN campaigns.actual_spend IS 'Actual spend.';
COMMENT ON COLUMN campaigns.created_by_user_id IS 'User who created this campaign.';
COMMENT ON COLUMN campaigns.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN campaigns.updated_by_user_id IS 'User who last updated this campaign.';
COMMENT ON COLUMN campaigns.updated_at IS 'Timestamp when last updated.';

-- scheduled_posts
COMMENT ON TABLE scheduled_posts IS 'Posts scheduled as part of campaigns.';
COMMENT ON COLUMN scheduled_posts.id IS 'Primary key, UUID.';
COMMENT ON COLUMN scheduled_posts.campaign_id IS 'Owning campaign.';
COMMENT ON COLUMN scheduled_posts.content IS 'Text content of the post.';
COMMENT ON COLUMN scheduled_posts.media_url IS 'URL to image/video asset.';
COMMENT ON COLUMN scheduled_posts.platform IS 'Platform code from reference_data.';
COMMENT ON COLUMN scheduled_posts.scheduled_time IS 'When the post is scheduled to go live.';
COMMENT ON COLUMN scheduled_posts.status IS 'Status code from reference_data.';
COMMENT ON COLUMN scheduled_posts.created_by_user_id IS 'User who created this post.';
COMMENT ON COLUMN scheduled_posts.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN scheduled_posts.updated_by_user_id IS 'User who last updated this post.';
COMMENT ON COLUMN scheduled_posts.updated_at IS 'Timestamp when last updated.';

-- post_metrics
COMMENT ON TABLE post_metrics IS 'Engagement metrics snapshots for each scheduled post.';
COMMENT ON COLUMN post_metrics.id IS 'Primary key, UUID.';
COMMENT ON COLUMN post_metrics.scheduled_post_id IS 'Related scheduled post.';
COMMENT ON COLUMN post_metrics.likes IS 'Number of likes.';
COMMENT ON COLUMN post_metrics.shares IS 'Number of shares.';
COMMENT ON COLUMN post_metrics.comments IS 'Number of comments.';
COMMENT ON COLUMN post_metrics.impressions IS 'Number of impressions.';
COMMENT ON COLUMN post_metrics.collected_at IS 'Timestamp when metrics were fetched.';
COMMENT ON COLUMN post_metrics.created_by_user_id IS 'User who recorded these metrics.';
COMMENT ON COLUMN post_metrics.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN post_metrics.updated_by_user_id IS 'User who last updated these metrics.';
COMMENT ON COLUMN post_metrics.updated_at IS 'Timestamp when last updated.';

-- assets
COMMENT ON TABLE assets IS 'Media assets linked to campaigns or scheduled posts.';
COMMENT ON COLUMN assets.id IS 'Primary key, UUID.';
COMMENT ON COLUMN assets.campaign_id IS 'Optional campaign-level asset.';
COMMENT ON COLUMN assets.scheduled_post_id IS 'Optional post-level asset.';
COMMENT ON COLUMN assets.file_url IS 'URL of the media file.';
COMMENT ON COLUMN assets.asset_type IS 'Type code from reference_data.';
COMMENT ON COLUMN assets.title IS 'Optional title or caption.';
COMMENT ON COLUMN assets.created_by_user_id IS 'User who uploaded the asset.';
COMMENT ON COLUMN assets.created_at IS 'Timestamp when uploaded.';
COMMENT ON COLUMN assets.updated_by_user_id IS 'User who last updated this asset.';
COMMENT ON COLUMN assets.updated_at IS 'Timestamp when last updated.';

-- notes
COMMENT ON TABLE notes IS 'Internal notes linked to campaigns or scheduled posts.';
COMMENT ON COLUMN notes.id IS 'Primary key, UUID.';
COMMENT ON COLUMN notes.user_id IS 'Authoring user.';
COMMENT ON COLUMN notes.campaign_id IS 'Related campaign if applicable.';
COMMENT ON COLUMN notes.scheduled_post_id IS 'Related post if applicable.';
COMMENT ON COLUMN notes.content IS 'Note content.';
COMMENT ON COLUMN notes.created_by_user_id IS 'User who created the note record.';
COMMENT ON COLUMN notes.created_at IS 'Timestamp when created.';
COMMENT ON COLUMN notes.updated_by_user_id IS 'User who last updated the note record.';
COMMENT ON COLUMN notes.updated_at IS 'Timestamp when last updated.';
-- =============================================================
-- End of DDL Script
-- =============================================================