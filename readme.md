This database is designed to manage court case information, including involved people, hearings, evidence, and related reference data. Below is an explanation of how the data is structured, tailored for non-technical stakeholders.

### Overall Structure and Purpose
The database organises data about legal proceedings, specifically court cases, the people involved, hearings, and evidence. It also includes supporting reference data that standardises terms such as case statuses, access levels, evidence types, and roles people play in cases.

---

### Key Entities and Their Roles

#### 1. **Reference Data**
- This table stores standardised codes and categories used across the system.
- Examples include types of evidence (like documents, photos), case statuses (open, closed), and access levels determining who can view certain information.
- This allows consistent use of common terms throughout the database.

#### 2. **Person**
- Represents any individual involved in the court system.
- This includes judges, lawyers, plaintiffs, defendants, or other relevant roles.
- Basic contact information such as email and phone number is stored here.

#### 3. **App User**
- Stores login details for individuals needing access to the system.
- Each app user is linked to a person record, tying credentials to an individual.
- Passwords are securely stored as hashes (encrypted).

#### 4. **Court Case**
- The central entity representing a legal case.
- Contains case name, dates (filing and optional deadline), status, and access permissions.
- The status reflects whether the case is open, adjourned, closed, etc.
- Access levels control visibility and permissions for sensitive cases.

#### 5. **Hearing**
- Represents scheduled court sessions linked to a specific court case.
- Each hearing has a date/time, location (physical or virtual), a judge who presides, and possibly an associated deadline for submissions related to that hearing.

#### 6. **Case Party**
- Links persons to a court case, specifying the role they play (e.g., plaintiff, defendant).
- This clarifies each person’s position and involvement in the case.

#### 7. **Evidence**
- Records pieces of evidence submitted for a case.
- Each item has a description, type, submission date, and access level restrictions.
- Evidence types might include documents, photos, or videos.

#### 8. **Hearing Evidence**
- A join table that links evidence items to specific hearings where they are presented or referenced.
- Supports many-to-many relationships, recognising that evidence can relate to multiple hearings.

---

### Data Relationships and Integrity
- Many entities are linked via unique identifiers (UUIDs) ensuring each record is completely distinct.
- Foreign keys enforce valid relationships; for example, a hearing must be linked to a valid case and judge.
- The reference data ensures that standardised codes are used (e.g., the status of a case must come from predefined statuses).
- Timestamps and user information track when and by whom records are created or updated, supporting auditability.

---

### Example Use Case Flow:
1. A new **court case** is filed, with its name, filing date, and current status recorded.
2. **People** involved including judges and parties (plaintiffs, defendants) are added.
3. **Hearings** are scheduled for particular dates and linked to the case and a presiding judge.
4. Various **evidence items** are submitted and classified by type.
5. Evidence is linked to hearings where it is presented or discussed.

---

### Benefits of This Model
- **Clear organisation** of complex court case data and related entities.
- **Traceability** of individuals' roles and responsibilities.
- **Controlled access** to sensitive information through access levels.
- **Standardised vocabulary** via reference data ensures common understanding.
- **Support for auditing** through created/updated metadata.

---

If you have further questions or need clarification on any part of this model, please feel free to ask!