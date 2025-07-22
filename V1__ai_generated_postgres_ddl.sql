-- Create required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create reference data tables
CREATE TABLE ref_case_status (
    case_status_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_case_type (
    case_type_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_party_type (
    party_type_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_contact_type (
    contact_type_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_document_type (
    document_type_code VARCHAR(50) PRIMARY KEY,
    parent_document_type_code VARCHAR(50),
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ,
    CONSTRAINT fk_ref_document_type_parent
      FOREIGN KEY(parent_document_type_code)
      REFERENCES ref_document_type(document_type_code)
      ON DELETE SET NULL
);

CREATE TABLE ref_schedule_type (
    schedule_type_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_specialization (
    specialization_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE ref_party_role (
    party_role_code VARCHAR(50) PRIMARY KEY,
    description TEXT NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

-- Create core tables
CREATE TABLE court (
    court_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    location VARCHAR(200),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE courtroom (
    courtroom_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    court_id UUID NOT NULL,
    name VARCHAR(100) NOT NULL,
    capacity INTEGER,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE judge (
    judge_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    court_id UUID NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE party (
    party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(200) NOT NULL,
    party_type_code VARCHAR(50) NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE lawyer (
    lawyer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    license_number VARCHAR(100) UNIQUE NOT NULL,
    license_expiration_date DATE,
    licensing_jurisdiction VARCHAR(200),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE "case" (
    case_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_number VARCHAR(100) UNIQUE NOT NULL,
    case_type_code VARCHAR(50) NOT NULL,
    case_status_code VARCHAR(50) NOT NULL,
    filing_date DATE NOT NULL,
    closed_date DATE,
    court_id UUID NOT NULL,
    judge_id UUID NOT NULL,
    outcome_description TEXT,
    is_closed BOOLEAN GENERATED ALWAYS AS (case_status_code = 'CLOSED') STORED,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE case_party (
    case_party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL,
    party_id UUID NOT NULL,
    party_role_code VARCHAR(50) NOT NULL,
    CONSTRAINT uq_case_party UNIQUE(case_id, party_id, party_role_code),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE party_contact (
    party_contact_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    party_id UUID NOT NULL,
    contact_type_code VARCHAR(50) NOT NULL,
    contact_value VARCHAR(200) NOT NULL,
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT one_primary_contact_per_party UNIQUE(party_id) WHERE (is_primary),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE lawyer_party (
    lawyer_party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    lawyer_id UUID NOT NULL,
    party_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT uq_lawyer_party UNIQUE(lawyer_id, party_id, start_date),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE lawyer_specialization (
    lawyer_id UUID NOT NULL,
    specialization_code VARCHAR(50) NOT NULL,
    PRIMARY KEY(lawyer_id, specialization_code),
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE schedule (
    schedule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL,
    judge_id UUID NOT NULL,
    courtroom_id UUID NOT NULL,
    schedule_type_code VARCHAR(50) NOT NULL,
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE document (
    document_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID NOT NULL,
    document_type_code VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    created_by_username VARCHAR(150) NOT NULL,
    updated_by_username VARCHAR(150),
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ
);

CREATE TABLE document_version (
    document_version_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL,
    version_number INTEGER NOT NULL,
    file_path TEXT NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_doc_ver UNIQUE(document_id, version_number)
);

CREATE TABLE document_party (
    document_party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL,
    party_id UUID NOT NULL,
    created_by_username VARCHAR(150) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE verdict (
    verdict_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    case_id UUID UNIQUE NOT NULL,
    verdict_date DATE NOT NULL,
    description TEXT,
    created_by_username VARCHAR(150) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Foreign Key Constraints
ALTER TABLE courtroom
  ADD CONSTRAINT fk_courtroom_court FOREIGN KEY(court_id) REFERENCES court(court_id);

ALTER TABLE judge
  ADD CONSTRAINT fk_judge_court FOREIGN KEY(court_id) REFERENCES court(court_id);

ALTER TABLE party
  ADD CONSTRAINT fk_party_type FOREIGN KEY(party_type_code) REFERENCES ref_party_type(party_type_code);

ALTER TABLE lawyer_specialization
  ADD CONSTRAINT fk_law_spec_lawyer FOREIGN KEY(lawyer_id) REFERENCES lawyer(lawyer_id),
  ADD CONSTRAINT fk_law_spec_spec FOREIGN KEY(specialization_code) REFERENCES ref_specialization(specialization_code);

ALTER TABLE lawyer_party
  ADD CONSTRAINT fk_lawyer_party_lawyer FOREIGN KEY(lawyer_id) REFERENCES lawyer(lawyer_id),
  ADD CONSTRAINT fk_lawyer_party_party FOREIGN KEY(party_id) REFERENCES party(party_id);

ALTER TABLE party_contact
  ADD CONSTRAINT fk_party_contact_party FOREIGN KEY(party_id) REFERENCES party(party_id),
  ADD CONSTRAINT fk_party_contact_type FOREIGN KEY(contact_type_code) REFERENCES ref_contact_type(contact_type_code);

ALTER TABLE "case"
  ADD CONSTRAINT fk_case_type FOREIGN KEY(case_type_code) REFERENCES ref_case_type(case_type_code),
  ADD CONSTRAINT fk_case_status FOREIGN KEY(case_status_code) REFERENCES ref_case_status(case_status_code),
  ADD CONSTRAINT fk_case_court FOREIGN KEY(court_id) REFERENCES court(court_id),
  ADD CONSTRAINT fk_case_judge FOREIGN KEY(judge_id) REFERENCES judge(judge_id);

ALTER TABLE case_party
  ADD CONSTRAINT fk_case_party_case FOREIGN KEY(case_id) REFERENCES "case"(case_id),
  ADD CONSTRAINT fk_case_party_party FOREIGN KEY(party_id) REFERENCES party(party_id),
  ADD CONSTRAINT fk_case_party_role FOREIGN KEY(party_role_code) REFERENCES ref_party_role(party_role_code);

ALTER TABLE schedule
  ADD CONSTRAINT fk_schedule_case FOREIGN KEY(case_id) REFERENCES "case"(case_id),
  ADD CONSTRAINT fk_schedule_judge FOREIGN KEY(judge_id) REFERENCES judge(judge_id),
  ADD CONSTRAINT fk_schedule_courtroom FOREIGN KEY(courtroom_id) REFERENCES courtroom(courtroom_id),
  ADD CONSTRAINT fk_schedule_type FOREIGN KEY(schedule_type_code) REFERENCES ref_schedule_type(schedule_type_code);

ALTER TABLE document
  ADD CONSTRAINT fk_document_case FOREIGN KEY(case_id) REFERENCES "case"(case_id),
  ADD CONSTRAINT fk_document_type FOREIGN KEY(document_type_code) REFERENCES ref_document_type(document_type_code);

ALTER TABLE document_version
  ADD CONSTRAINT fk_document_version_doc FOREIGN KEY(document_id) REFERENCES document(document_id);

ALTER TABLE document_party
  ADD CONSTRAINT fk_document_party_doc FOREIGN KEY(document_id) REFERENCES document(document_id),
  ADD CONSTRAINT fk_document_party_party FOREIGN KEY(party_id) REFERENCES party(party_id);

ALTER TABLE verdict
  ADD CONSTRAINT fk_verdict_case FOREIGN KEY(case_id) REFERENCES "case"(case_id);

-- Indexes
CREATE INDEX idx_case_number ON "case"(case_number);
CREATE INDEX idx_schedule_time ON schedule(scheduled_start, scheduled_end);
CREATE INDEX idx_doc_case ON document(case_id);
CREATE INDEX idx_docparty_party ON document_party(party_id);
CREATE INDEX idx_courtroom_court ON courtroom(court_id);
CREATE INDEX idx_judge_court ON judge(court_id);

-- Comments on Tables and Columns
COMMENT ON TABLE court IS 'Court entity storing courts by name and location';
COMMENT ON COLUMN court.court_id IS 'Primary key for court';
COMMENT ON COLUMN court.name IS 'Name of the court';
COMMENT ON COLUMN court.location IS 'Geographic location or address for the court';

COMMENT ON TABLE courtroom IS 'Courtroom entity within a court';
COMMENT ON COLUMN courtroom.courtroom_id IS 'Primary key for courtroom';
COMMENT ON COLUMN courtroom.court_id IS 'Foreign key to court';
COMMENT ON COLUMN courtroom.name IS 'Name or number of the courtroom';
COMMENT ON COLUMN courtroom.capacity IS 'Seating or participant capacity of the courtroom';

COMMENT ON TABLE judge IS 'Judge entity assigned to cases';
COMMENT ON COLUMN judge.judge_id IS 'Primary key for judge';
COMMENT ON COLUMN judge.first_name IS 'Judge''s first name';
COMMENT ON COLUMN judge.last_name IS 'Judge''s last name';
COMMENT ON COLUMN judge.court_id IS 'Court where judge serves';

COMMENT ON TABLE party IS 'Party entity representing individuals or organizations';
COMMENT ON COLUMN party.party_id IS 'Primary key for party';
COMMENT ON COLUMN party.name IS 'Name of the party';
COMMENT ON COLUMN party.party_type_code IS 'Type of party (Individual or Organization)';

COMMENT ON TABLE party_contact IS 'Contact information records for parties';
COMMENT ON COLUMN party_contact.party_contact_id IS 'Primary key for party contact';
COMMENT ON COLUMN party_contact.contact_type_code IS 'Type of contact (Email, Phone, etc.)';
COMMENT ON COLUMN party_contact.contact_value IS 'Contact detail value';
COMMENT ON COLUMN party_contact.is_primary IS 'Flag to indicate primary contact';

COMMENT ON TABLE lawyer IS 'Lawyer entity with licensing information';
COMMENT ON COLUMN lawyer.license_number IS 'Professional license number';
COMMENT ON COLUMN lawyer.license_expiration_date IS 'License expiration date';
COMMENT ON COLUMN lawyer.licensing_jurisdiction IS 'Jurisdiction where lawyer is licensed';

COMMENT ON TABLE ref_case_status IS 'Reference table for case statuses';
COMMENT ON TABLE ref_case_type IS 'Reference table for case types';
COMMENT ON TABLE ref_party_type IS 'Reference table for party types';
COMMENT ON TABLE ref_contact_type IS 'Reference table for contact types';
COMMENT ON TABLE ref_document_type IS 'Reference table for document types with hierarchy';
COMMENT ON TABLE ref_schedule_type IS 'Reference table for schedule types';
COMMENT ON TABLE ref_specialization IS 'Reference table for lawyer specialization areas';
COMMENT ON TABLE ref_party_role IS 'Reference table for party roles in a case';

COMMENT ON TABLE "case" IS 'Court case entity storing core case details';
COMMENT ON COLUMN "case".case_number IS 'Unique case identifier assigned by court';
COMMENT ON COLUMN "case".case_type_code IS 'Reference to type of case';
COMMENT ON COLUMN "case".case_status_code IS 'Reference to status of case';
COMMENT ON COLUMN "case".filing_date IS 'Date when case was filed';
COMMENT ON COLUMN "case".closed_date IS 'Date when case was closed';
COMMENT ON COLUMN "case".judge_id IS 'Judge assigned to the case';
COMMENT ON COLUMN "case".court_id IS 'Court where the case is heard';
COMMENT ON COLUMN "case".is_closed IS 'Indicates if case_status_code = CLOSED';

COMMENT ON TABLE case_party IS 'Linking table between cases and parties with roles';
COMMENT ON COLUMN case_party.party_role_code IS 'Role of party in the case (Plaintiff, Defendant, etc.)';

COMMENT ON TABLE lawyer_party IS 'Representation linkage between lawyers and parties over time';
COMMENT ON COLUMN lawyer_party.start_date IS 'Date representation began';
COMMENT ON COLUMN lawyer_party.end_date IS 'Date representation ended';

COMMENT ON TABLE lawyer_specialization IS 'Many-to-many between lawyers and specializations';

COMMENT ON TABLE schedule IS 'Schedule entries for cases (hearings, deadlines, etc.)';
COMMENT ON COLUMN schedule.scheduled_start IS 'Start datetime of schedule entry';
COMMENT ON COLUMN schedule.scheduled_end IS 'End datetime of schedule entry';

COMMENT ON TABLE document IS 'Document metadata linked to cases';
COMMENT ON COLUMN document.title IS 'Title or name of document';

COMMENT ON TABLE document_version IS 'Version control for documents';
COMMENT ON COLUMN document_version.version_number IS 'Sequential version number of document';

COMMENT ON TABLE document_party IS 'Linking table to tag documents to parties';

COMMENT ON TABLE verdict IS 'Verdict information for closed cases';
COMMENT ON COLUMN verdict.verdict_date IS 'Date when verdict was issued';
COMMENT ON COLUMN verdict.case_id IS 'Reference to the case for this verdict';