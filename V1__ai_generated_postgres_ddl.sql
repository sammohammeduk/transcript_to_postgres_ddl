-- Create Extensions
CREATE EXTENSION IF NOT EXISTS btree_gist;


-- Create Tables and Fields

CREATE TABLE reference_data (
    reference_data_id SERIAL PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    code VARCHAR(100) NOT NULL,
    label VARCHAR(255) NOT NULL,
    description TEXT,
    sort_order INT,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cases (
    case_id SERIAL PRIMARY KEY,
    case_number VARCHAR(50) NOT NULL,
    case_type_id INT NOT NULL,
    case_status_id INT NOT NULL,
    date_opened DATE NOT NULL,
    date_closed DATE,
    case_duration_days INT GENERATED ALWAYS AS (date_closed - date_opened) STORED,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE parties (
    party_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    organization_name VARCHAR(255),
    party_type_id INT,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE judges (
    judge_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    court_assigned VARCHAR(255),
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE attorneys (
    attorney_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    bar_number VARCHAR(50) NOT NULL,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE courtrooms (
    courtroom_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(255),
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE hearings (
    hearing_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL,
    hearing_type_id INT NOT NULL,
    scheduled_start TIMESTAMPTZ NOT NULL,
    scheduled_end TIMESTAMPTZ NOT NULL,
    judge_id INT NOT NULL,
    courtroom_id INT NOT NULL,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE documents (
    document_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL,
    party_id INT,
    document_type_id INT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT,
    upload_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE case_parties (
    case_party_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL,
    party_id INT NOT NULL,
    role_type_id INT,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE case_attorneys (
    case_attorney_id SERIAL PRIMARY KEY,
    case_id INT NOT NULL,
    attorney_id INT NOT NULL,
    role_type_id INT,
    created_by_username VARCHAR(50) NOT NULL,
    updated_by_username VARCHAR(50) NOT NULL,
    created_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_datetime TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- Create Constraints

-- Unique Constraints
ALTER TABLE reference_data ADD CONSTRAINT uq_reference_data_category_code UNIQUE(category, code);
ALTER TABLE cases ADD CONSTRAINT uq_cases_case_number UNIQUE(case_number);
ALTER TABLE attorneys ADD CONSTRAINT uq_attorneys_bar_number UNIQUE(bar_number);

-- Exclusion Constraints to prevent overlapping hearings per judge and courtroom
ALTER TABLE hearings
    ADD CONSTRAINT ex_hearings_judge_no_overlap
    EXCLUDE USING GIST (
        judge_id WITH =,
        tstzrange(scheduled_start, scheduled_end) WITH &&
    );

ALTER TABLE hearings
    ADD CONSTRAINT ex_hearings_courtroom_no_overlap
    EXCLUDE USING GIST (
        courtroom_id WITH =,
        tstzrange(scheduled_start, scheduled_end) WITH &&
    );


-- Create Foreign Keys

ALTER TABLE cases
    ADD CONSTRAINT fk_cases_case_type
    FOREIGN KEY (case_type_id) REFERENCES reference_data(reference_data_id),
    ADD CONSTRAINT fk_cases_case_status
    FOREIGN KEY (case_status_id) REFERENCES reference_data(reference_data_id);

ALTER TABLE parties
    ADD CONSTRAINT fk_parties_party_type
    FOREIGN KEY (party_type_id) REFERENCES reference_data(reference_data_id);

ALTER TABLE hearings
    ADD CONSTRAINT fk_hearings_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    ADD CONSTRAINT fk_hearings_hearing_type
    FOREIGN KEY (hearing_type_id) REFERENCES reference_data(reference_data_id),
    ADD CONSTRAINT fk_hearings_judge
    FOREIGN KEY (judge_id) REFERENCES judges(judge_id),
    ADD CONSTRAINT fk_hearings_courtroom
    FOREIGN KEY (courtroom_id) REFERENCES courtrooms(courtroom_id);

ALTER TABLE documents
    ADD CONSTRAINT fk_documents_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    ADD CONSTRAINT fk_documents_party
    FOREIGN KEY (party_id) REFERENCES parties(party_id),
    ADD CONSTRAINT fk_documents_doc_type
    FOREIGN KEY (document_type_id) REFERENCES reference_data(reference_data_id);

ALTER TABLE case_parties
    ADD CONSTRAINT fk_case_parties_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    ADD CONSTRAINT fk_case_parties_party
    FOREIGN KEY (party_id) REFERENCES parties(party_id),
    ADD CONSTRAINT fk_case_parties_role
    FOREIGN KEY (role_type_id) REFERENCES reference_data(reference_data_id);

ALTER TABLE case_attorneys
    ADD CONSTRAINT fk_case_attorneys_case
    FOREIGN KEY (case_id) REFERENCES cases(case_id),
    ADD CONSTRAINT fk_case_attorneys_attorney
    FOREIGN KEY (attorney_id) REFERENCES attorneys(attorney_id),
    ADD CONSTRAINT fk_case_attorneys_role
    FOREIGN KEY (role_type_id) REFERENCES reference_data(reference_data_id);


-- Create B-tree Indexes

CREATE INDEX idx_cases_case_type ON cases(case_type_id);
CREATE INDEX idx_cases_case_status ON cases(case_status_id);
CREATE INDEX idx_cases_date_opened ON cases(date_opened);
CREATE INDEX idx_parties_name ON parties(last_name, first_name);
CREATE INDEX idx_judges_name ON judges(last_name, first_name);
CREATE INDEX idx_attorneys_name ON attorneys(last_name, first_name);
CREATE INDEX idx_hearings_start ON hearings(scheduled_start);
CREATE INDEX idx_documents_case ON documents(case_id);
CREATE INDEX idx_documents_doc_type ON documents(document_type_id);


-- Comments for Tables and Columns

-- reference_data
COMMENT ON TABLE reference_data IS 'Stores all reference data items such as case types, statuses, hearing types, document types, roles, etc.';
COMMENT ON COLUMN reference_data.reference_data_id IS 'Primary key for reference data records';
COMMENT ON COLUMN reference_data.category IS 'Category grouping for reference data, e.g., case_type, case_status';
COMMENT ON COLUMN reference_data.code IS 'Unique code within its category';
COMMENT ON COLUMN reference_data.label IS 'Human-readable label for the reference data';
COMMENT ON COLUMN reference_data.description IS 'Optional description of the reference data item';
COMMENT ON COLUMN reference_data.sort_order IS 'Order to sort items when presented in lists';
COMMENT ON COLUMN reference_data.created_by_username IS 'User who created the record';
COMMENT ON COLUMN reference_data.updated_by_username IS 'User who last updated the record';
COMMENT ON COLUMN reference_data.created_datetime IS 'Timestamp when the record was created';
COMMENT ON COLUMN reference_data.updated_datetime IS 'Timestamp when the record was last updated';

-- cases
COMMENT ON TABLE cases IS 'Core table storing case metadata and status';
COMMENT ON COLUMN cases.case_id IS 'Primary key for cases';
COMMENT ON COLUMN cases.case_number IS 'Unique case identifier assigned by the court';
COMMENT ON COLUMN cases.case_type_id IS 'Reference to type of case (e.g., civil, criminal)';
COMMENT ON COLUMN cases.case_status_id IS 'Reference to current status of the case';
COMMENT ON COLUMN cases.date_opened IS 'Date when the case was opened';
COMMENT ON COLUMN cases.date_closed IS 'Date when the case was closed (if applicable)';
COMMENT ON COLUMN cases.case_duration_days IS 'Calculated duration of the case in days';
COMMENT ON COLUMN cases.created_by_username IS 'User who created the case record';
COMMENT ON COLUMN cases.updated_by_username IS 'User who last updated the case record';
COMMENT ON COLUMN cases.created_datetime IS 'Timestamp when the case was created';
COMMENT ON COLUMN cases.updated_datetime IS 'Timestamp when the case was last updated';

-- parties
COMMENT ON TABLE parties IS 'Individuals or organizations involved in cases';
COMMENT ON COLUMN parties.party_id IS 'Primary key for parties';
COMMENT ON COLUMN parties.first_name IS 'First name of the party (if individual)';
COMMENT ON COLUMN parties.last_name IS 'Last name of the party (if individual)';
COMMENT ON COLUMN parties.organization_name IS 'Name of the organization (if corporate party)';
COMMENT ON COLUMN parties.party_type_id IS 'Reference to type of party (e.g., plaintiff, defendant)';
COMMENT ON COLUMN parties.created_by_username IS 'User who created the party record';
COMMENT ON COLUMN parties.updated_by_username IS 'User who last updated the party record';
COMMENT ON COLUMN parties.created_datetime IS 'Timestamp when the party was created';
COMMENT ON COLUMN parties.updated_datetime IS 'Timestamp when the party was last updated';

-- judges
COMMENT ON TABLE judges IS 'Judicial officers presiding over hearings';
COMMENT ON COLUMN judges.judge_id IS 'Primary key for judges';
COMMENT ON COLUMN judges.first_name IS 'First name of the judge';
COMMENT ON COLUMN judges.last_name IS 'Last name of the judge';
COMMENT ON COLUMN judges.court_assigned IS 'Court assignment or chamber for the judge';
COMMENT ON COLUMN judges.created_by_username IS 'User who created the judge record';
COMMENT ON COLUMN judges.updated_by_username IS 'User who last updated the judge record';
COMMENT ON COLUMN judges.created_datetime IS 'Timestamp when the judge was created';
COMMENT ON COLUMN judges.updated_datetime IS 'Timestamp when the judge was last updated';

-- attorneys
COMMENT ON TABLE attorneys IS 'Legal representatives associated with cases';
COMMENT ON COLUMN attorneys.attorney_id IS 'Primary key for attorneys';
COMMENT ON COLUMN attorneys.first_name IS 'First name of the attorney';
COMMENT ON COLUMN attorneys.last_name IS 'Last name of the attorney';
COMMENT ON COLUMN attorneys.bar_number IS 'Official bar registration number';
COMMENT ON COLUMN attorneys.created_by_username IS 'User who created the attorney record';
COMMENT ON COLUMN attorneys.updated_by_username IS 'User who last updated the attorney record';
COMMENT ON COLUMN attorneys.created_datetime IS 'Timestamp when the attorney was created';
COMMENT ON COLUMN attorneys.updated_datetime IS 'Timestamp when the attorney was last updated';

-- courtrooms
COMMENT ON TABLE courtrooms IS 'Physical locations where hearings are held';
COMMENT ON COLUMN courtrooms.courtroom_id IS 'Primary key for courtrooms';
COMMENT ON COLUMN courtrooms.name IS 'Name or number identifying the courtroom';
COMMENT ON COLUMN courtrooms.location IS 'Description of the courtroom location';
COMMENT ON COLUMN courtrooms.created_by_username IS 'User who created the courtroom record';
COMMENT ON COLUMN courtrooms.updated_by_username IS 'User who last updated the courtroom record';
COMMENT ON COLUMN courtrooms.created_datetime IS 'Timestamp when the courtroom was created';
COMMENT ON COLUMN courtrooms.updated_datetime IS 'Timestamp when the courtroom was last updated';

-- hearings
COMMENT ON TABLE hearings IS 'Scheduled court events linked to cases';
COMMENT ON COLUMN hearings.hearing_id IS 'Primary key for hearings';
COMMENT ON COLUMN hearings.case_id IS 'Reference to the case for this hearing';
COMMENT ON COLUMN hearings.hearing_type_id IS 'Reference to the type of hearing (e.g., preliminary, trial)';
COMMENT ON COLUMN hearings.scheduled_start IS 'Scheduled start date/time of the hearing';
COMMENT ON COLUMN hearings.scheduled_end IS 'Scheduled end date/time of the hearing';
COMMENT ON COLUMN hearings.judge_id IS 'Reference to the judge presiding over the hearing';
COMMENT ON COLUMN hearings.courtroom_id IS 'Reference to the courtroom assigned';
COMMENT ON COLUMN hearings.created_by_username IS 'User who created the hearing record';
COMMENT ON COLUMN hearings.updated_by_username IS 'User who last updated the hearing record';
COMMENT ON COLUMN hearings.created_datetime IS 'Timestamp when the hearing was created';
COMMENT ON COLUMN hearings.updated_datetime IS 'Timestamp when the hearing was last updated';

-- documents
COMMENT ON TABLE documents IS 'Files and records associated with cases and parties';
COMMENT ON COLUMN documents.document_id IS 'Primary key for documents';
COMMENT ON COLUMN documents.case_id IS 'Reference to the related case';
COMMENT ON COLUMN documents.party_id IS 'Reference to the related party (if applicable)';
COMMENT ON COLUMN documents.document_type_id IS 'Reference to the type of document (e.g., motion, evidence)';
COMMENT ON COLUMN documents.file_name IS 'Original file name of the document';
COMMENT ON COLUMN documents.file_path IS 'Storage path or URL for the document';
COMMENT ON COLUMN documents.upload_datetime IS 'Timestamp when the document was uploaded';
COMMENT ON COLUMN documents.created_by_username IS 'User who created the document record';
COMMENT ON COLUMN documents.updated_by_username IS 'User who last updated the document record';
COMMENT ON COLUMN documents.created_datetime IS 'Timestamp when the document record was created';
COMMENT ON COLUMN documents.updated_datetime IS 'Timestamp when the document record was last updated';

-- case_parties
COMMENT ON TABLE case_parties IS 'Associative table linking cases and parties with roles';
COMMENT ON COLUMN case_parties.case_party_id IS 'Primary key for case-party associations';
COMMENT ON COLUMN case_parties.case_id IS 'Reference to the case';
COMMENT ON COLUMN case_parties.party_id IS 'Reference to the party';
COMMENT ON COLUMN case_parties.role_type_id IS 'Reference to the role of the party in the case';
COMMENT ON COLUMN case_parties.created_by_username IS 'User who created the case-party record';
COMMENT ON COLUMN case_parties.updated_by_username IS 'User who last updated the case-party record';
COMMENT ON COLUMN case_parties.created_datetime IS 'Timestamp when the case-party record was created';
COMMENT ON COLUMN case_parties.updated_datetime IS 'Timestamp when the case-party record was last updated';

-- case_attorneys
COMMENT ON TABLE case_attorneys IS 'Associative table linking cases and attorneys with roles';
COMMENT ON COLUMN case_attorneys.case_attorney_id IS 'Primary key for case-attorney associations';
COMMENT ON COLUMN case_attorneys.case_id IS 'Reference to the case';
COMMENT ON COLUMN case_attorneys.attorney_id IS 'Reference to the attorney';
COMMENT ON COLUMN case_attorneys.role_type_id IS 'Reference to the role of the attorney in the case';
COMMENT ON COLUMN case_attorneys.created_by_username IS 'User who created the case-attorney record';
COMMENT ON COLUMN case_attorneys.updated_by_username IS 'User who last updated the case-attorney record';
COMMENT ON COLUMN case_attorneys.created_datetime IS 'Timestamp when the case-attorney record was created';
COMMENT ON COLUMN case_attorneys.updated_datetime IS 'Timestamp when the case-attorney record was last updated';