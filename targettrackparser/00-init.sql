CREATE SCHEMA IF NOT EXISTS tt;

CREATE TABLE IF NOT EXISTS tt."contact_info" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "contact_id" text NULL,
  "name" text NULL,
  "address" text NULL,
  "country" text NULL,
  "email" text NULL,
  "organization" text NULL,
  "lab" text NULL,
  "role" text NULL
);

CREATE TABLE IF NOT EXISTS tt."protocols" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "description" text NULL,
  "name" text NULL,
  "text" text NULL,
  "type" text NULL
);

CREATE TABLE IF NOT EXISTS tt."targets" (
  "id" serial NOT NULL,
  "original_id" text NULL,
  "target_id" text NULL,
  "created_at" timestamp NULL,
  "updated_at" timestamp NULL,
  "laboratory_list" json NULL,
  "contact_info_list" json NULL,
  "projects_list" json NULL,
  "target_rationale" text NULL,
  "target_category_list" json NULL,
  "status" text NULL,
  "url" text NULL,
  "target_sequence_list" json NULL,
  "one_letter_code" text NULL,
  "remark" text NULL,
  "database_list" json NULL,
  "trial_list" json NULL
);

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch SCHEMA tt;
CREATE INDEX IF NOT EXISTS "targets_original_id" ON tt."targets" ("original_id");