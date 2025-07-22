-- Create Extensions  
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  

-- Create All Tables and Fields  
CREATE TABLE reference_data (  
    reference_data_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    reference_type VARCHAR(100) NOT NULL,  
    reference_code VARCHAR(100) NOT NULL,  
    description TEXT,  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE UNIQUE INDEX ux_reference_data_type_code  
    ON reference_data(reference_type, reference_code);  

CREATE TABLE person (  
    person_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    first_name VARCHAR(100) NOT NULL,  
    last_name VARCHAR(100) NOT NULL,  
    role VARCHAR(50) NOT NULL,  -- e.g., Judge, Lawyer, Plaintiff, Defendant  
    contact_email VARCHAR(255),  
    contact_phone VARCHAR(50),  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE app_user (  
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    username VARCHAR(100) NOT NULL UNIQUE,  
    password_hash VARCHAR(255) NOT NULL,  
    person_id UUID NOT NULL,  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE court_case (  
    case_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    case_name VARCHAR(200) NOT NULL,  
    filing_date DATE NOT NULL,  
    deadline_date DATE,  
    status_id UUID NOT NULL,  -- FK to reference_data(reference_type='case_status')  
    access_level_id UUID,      -- FK to reference_data(reference_type='access_level')  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE hearing (  
    hearing_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    case_id UUID NOT NULL,  
    hearing_datetime TIMESTAMP WITHOUT TIME ZONE NOT NULL,  
    location VARCHAR(200),  
    judge_id UUID NOT NULL,  
    deadline_date DATE,  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE case_party (  
    case_party_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    case_id UUID NOT NULL,  
    person_id UUID NOT NULL,  
    party_role_id UUID NOT NULL,  -- FK to reference_data(reference_type='party_role')  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE evidence (  
    evidence_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),  
    case_id UUID NOT NULL,  
    description TEXT,  
    type_id UUID NOT NULL,            -- FK to reference_data(reference_type='evidence_type')  
    date_submitted DATE,  
    access_level_id UUID,             -- FK to reference_data(reference_type='access_level')  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW()  
);  

CREATE TABLE hearing_evidence (  
    hearing_id UUID NOT NULL,  
    evidence_id UUID NOT NULL,  
    created_by_username VARCHAR(255),  
    updated_by_username VARCHAR(255),  
    created_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    updated_datetime TIMESTAMP WITHOUT TIME ZONE DEFAULT NOW(),  
    PRIMARY KEY (hearing_id, evidence_id)  
);  

-- Create All Constraints & Foreign Keys in Logical Order  
ALTER TABLE app_user  
    ADD CONSTRAINT fk_app_user_person  
        FOREIGN KEY (person_id) REFERENCES person(person_id);  

ALTER TABLE court_case  
    ADD CONSTRAINT fk_case_status  
        FOREIGN KEY (status_id) REFERENCES reference_data(reference_data_id),  
    ADD CONSTRAINT fk_case_access_level  
        FOREIGN KEY (access_level_id) REFERENCES reference_data(reference_data_id);  

ALTER TABLE hearing  
    ADD CONSTRAINT fk_hearing_case  
        FOREIGN KEY (case_id) REFERENCES court_case(case_id),  
    ADD CONSTRAINT fk_hearing_judge  
        FOREIGN KEY (judge_id) REFERENCES person(person_id);  

ALTER TABLE case_party  
    ADD CONSTRAINT fk_case_party_case  
        FOREIGN KEY (case_id) REFERENCES court_case(case_id),  
    ADD CONSTRAINT fk_case_party_person  
        FOREIGN KEY (person_id) REFERENCES person(person_id),  
    ADD CONSTRAINT fk_case_party_role  
        FOREIGN KEY (party_role_id) REFERENCES reference_data(reference_data_id);  

ALTER TABLE evidence  
    ADD CONSTRAINT fk_evidence_case  
        FOREIGN KEY (case_id) REFERENCES court_case(case_id),  
    ADD CONSTRAINT fk_evidence_type  
        FOREIGN KEY (type_id) REFERENCES reference_data(reference_data_id),  
    ADD CONSTRAINT fk_evidence_access_level  
        FOREIGN KEY (access_level_id) REFERENCES reference_data(reference_data_id);  

ALTER TABLE hearing_evidence  
    ADD CONSTRAINT fk_hearing_evidence_hearing  
        FOREIGN KEY (hearing_id) REFERENCES hearing(hearing_id),  
    ADD CONSTRAINT fk_hearing_evidence_evidence  
        FOREIGN KEY (evidence_id) REFERENCES evidence(evidence_id);  

-- Create Comments for Tables and Fields  
COMMENT ON TABLE reference_data IS 'Generic reference table for codes and types (e.g., case_status, evidence_type, access_level, party_role).';  
COMMENT ON COLUMN reference_data.reference_data_id IS 'Primary key for the reference data item.';  
COMMENT ON COLUMN reference_data.reference_type IS 'Category of reference data (must match business context).';  
COMMENT ON COLUMN reference_data.reference_code IS 'Unique code within its type for business use.';  
COMMENT ON COLUMN reference_data.description IS 'Human-readable description of the reference code.';  

COMMENT ON TABLE person IS 'Represents any individual involved in the court system (judge, lawyer, plaintiff, defendant).';  
COMMENT ON COLUMN person.person_id IS 'Primary key for a person record.';  
COMMENT ON COLUMN person.first_name IS 'Person''s given name.';  
COMMENT ON COLUMN person.last_name IS 'Person''s family name.';  
COMMENT ON COLUMN person.role IS 'Primary legal role (Judge, Lawyer, Plaintiff, Defendant).';  
COMMENT ON COLUMN person.contact_email IS 'Email address of the person.';  
COMMENT ON COLUMN person.contact_phone IS 'Telephone contact number.';  

COMMENT ON TABLE app_user IS 'Login credentials and linkage to a person record for authentication/authorization.';  
COMMENT ON COLUMN app_user.user_id IS 'Primary key for user credentials.';  
COMMENT ON COLUMN app_user.username IS 'Unique login name.';  
COMMENT ON COLUMN app_user.password_hash IS 'Hashed password for authentication.';  
COMMENT ON COLUMN app_user.person_id IS 'Links user credentials to a person entity.';  

COMMENT ON TABLE court_case IS 'Core table storing information about legal cases.';  
COMMENT ON COLUMN court_case.case_id IS 'Primary key for court case.';  
COMMENT ON COLUMN court_case.case_name IS 'Descriptive name/title of the case.';  
COMMENT ON COLUMN court_case.filing_date IS 'Official date when the case was filed.';  
COMMENT ON COLUMN court_case.deadline_date IS 'Optional deadline date for case-related actions.';  
COMMENT ON COLUMN court_case.status_id IS 'References current status (Open, Adjourned, Closed, etc.).';  
COMMENT ON COLUMN court_case.access_level_id IS 'Reference to access restrictions for case visibility.';  

COMMENT ON TABLE hearing IS 'Scheduled court session linked to a case and presided over by a judge.';  
COMMENT ON COLUMN hearing.hearing_id IS 'Primary key for hearing record.';  
COMMENT ON COLUMN hearing.case_id IS 'Foreign key linking to the parent court case.';  
COMMENT ON COLUMN hearing.hearing_datetime IS 'Date and time when the hearing occurs.';  
COMMENT ON COLUMN hearing.location IS 'Physical or virtual location of the hearing.';  
COMMENT ON COLUMN hearing.judge_id IS 'Person (Judge) presiding over this hearing.';  
COMMENT ON COLUMN hearing.deadline_date IS 'Optional deadline date for hearing-related filings.';  

COMMENT ON TABLE case_party IS 'Associates persons with cases in roles such as plaintiff or defendant.';  
COMMENT ON COLUMN case_party.case_party_id IS 'Primary key for case-party assignment.';  
COMMENT ON COLUMN case_party.case_id IS 'Foreign key to the associated court case.';  
COMMENT ON COLUMN case_party.person_id IS 'Foreign key to the person in this role.';  
COMMENT ON COLUMN case_party.party_role_id IS 'References the role in this case (plaintiff or defendant).';  

COMMENT ON TABLE evidence IS 'Records individual evidence items linked to cases and potentially hearings.';  
COMMENT ON COLUMN evidence.evidence_id IS 'Primary key for an evidence item.';  
COMMENT ON COLUMN evidence.case_id IS 'Foreign key to the parent court case.';  
COMMENT ON COLUMN evidence.description IS 'Textual description of the evidence.';  
COMMENT ON COLUMN evidence.type_id IS 'References the type of evidence (Document, Photo, Video).';  
COMMENT ON COLUMN evidence.date_submitted IS 'Date when evidence was submitted to the case.';  
COMMENT ON COLUMN evidence.access_level_id IS 'Reference to access restrictions for evidence.';  

COMMENT ON TABLE hearing_evidence IS 'Join table linking evidence items to hearings where they are presented.';  
COMMENT ON COLUMN hearing_evidence.hearing_id IS 'Foreign key to the hearing.';  
COMMENT ON COLUMN hearing_evidence.evidence_id IS 'Foreign key to the evidence item.';  

-- End of DDL Script.