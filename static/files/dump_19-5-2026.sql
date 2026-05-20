--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.22
-- Dumped by pg_dump version 9.6.22

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounting_categories; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.accounting_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_default boolean DEFAULT false,
    color character varying(50),
    icon character varying(50),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.accounting_categories OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.accounting_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounting_categories_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.accounting_categories_id_seq OWNED BY public.accounting_categories.id;


--
-- Name: accounting_entries; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.accounting_entries (
    id integer NOT NULL,
    project_id integer,
    contact_id integer,
    category_id integer,
    name character varying(255) NOT NULL,
    description text,
    amount numeric(12,2) NOT NULL,
    entry_type text DEFAULT 'expense'::text,
    payment_status text DEFAULT 'pending'::text,
    bill_date date,
    payment_date date,
    due_date date,
    attachment character varying(255),
    is_individual_payment boolean DEFAULT false,
    is_musician_fee boolean DEFAULT false,
    invoice_number character varying(255),
    notes text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT accounting_entries_entry_type_check CHECK ((entry_type = ANY (ARRAY['expense'::text, 'income'::text]))),
    CONSTRAINT accounting_entries_payment_status_check CHECK ((payment_status = ANY (ARRAY['pending'::text, 'paid'::text, 'overdue'::text, 'cancelled'::text])))
);


ALTER TABLE public.accounting_entries OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.accounting_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounting_entries_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.accounting_entries_id_seq OWNED BY public.accounting_entries.id;


--
-- Name: accounting_settings; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.accounting_settings (
    id integer NOT NULL,
    project_id integer,
    currency character varying(10) DEFAULT 'EUR'::character varying,
    auto_overdue_enabled boolean DEFAULT true,
    default_payment_terms integer DEFAULT 30,
    tax_rate numeric(5,2) DEFAULT '20'::numeric,
    enable_tax boolean DEFAULT false,
    fiscal_year_start timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.accounting_settings OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.accounting_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounting_settings_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: accounting_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.accounting_settings_id_seq OWNED BY public.accounting_settings.id;


--
-- Name: adonis_schema; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.adonis_schema (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    batch integer NOT NULL,
    migration_time timestamp with time zone DEFAULT now()
);


ALTER TABLE public.adonis_schema OWNER TO ciro3903_melomania_prod;

--
-- Name: adonis_schema_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.adonis_schema_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.adonis_schema_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: adonis_schema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.adonis_schema_id_seq OWNED BY public.adonis_schema.id;


--
-- Name: adonis_schema_versions; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.adonis_schema_versions (
    version integer NOT NULL
);


ALTER TABLE public.adonis_schema_versions OWNER TO ciro3903_melomania_prod;

--
-- Name: answers; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.answers (
    id integer NOT NULL,
    text text DEFAULT ''::text,
    form_id integer,
    participant_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.answers OWNER TO ciro3903_melomania_prod;

--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.answers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.answers_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.answers_id_seq OWNED BY public.answers.id;


--
-- Name: attached_to_callsheets; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.attached_to_callsheets (
    file_id integer NOT NULL,
    callsheet_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.attached_to_callsheets OWNER TO ciro3903_melomania_prod;

--
-- Name: attached_to_mail_templates; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.attached_to_mail_templates (
    file_id integer NOT NULL,
    mail_template_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.attached_to_mail_templates OWNER TO ciro3903_melomania_prod;

--
-- Name: audition_files; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.audition_files (
    id integer NOT NULL,
    audition_id integer NOT NULL,
    file_id integer NOT NULL,
    file_type text NOT NULL,
    description character varying(500),
    file_size bigint,
    duration_seconds integer,
    uploaded_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT audition_files_file_type_check CHECK ((file_type = ANY (ARRAY['video'::text, 'audio'::text])))
);


ALTER TABLE public.audition_files OWNER TO ciro3903_melomania_prod;

--
-- Name: audition_files_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.audition_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audition_files_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: audition_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.audition_files_id_seq OWNED BY public.audition_files.id;


--
-- Name: audition_pdf_files; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.audition_pdf_files (
    id integer NOT NULL,
    audition_id integer NOT NULL,
    file_id integer NOT NULL,
    section_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    "order" integer DEFAULT 0 NOT NULL,
    downloaded_by_candidate boolean DEFAULT false,
    first_downloaded_at timestamp with time zone,
    download_count integer DEFAULT 0,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.audition_pdf_files OWNER TO ciro3903_melomania_prod;

--
-- Name: audition_pdf_files_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.audition_pdf_files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.audition_pdf_files_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: audition_pdf_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.audition_pdf_files_id_seq OWNED BY public.audition_pdf_files.id;


--
-- Name: auditions; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.auditions (
    id integer NOT NULL,
    participant_id integer NOT NULL,
    project_id integer NOT NULL,
    secure_token character varying(512) NOT NULL,
    instructions text,
    required_files json,
    deadline timestamp with time zone,
    is_submitted boolean DEFAULT false NOT NULL,
    submitted_at timestamp with time zone,
    candidate_notes text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.auditions OWNER TO ciro3903_melomania_prod;

--
-- Name: auditions_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.auditions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auditions_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: auditions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.auditions_id_seq OWNED BY public.auditions.id;


--
-- Name: auth_access_tokens; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.auth_access_tokens (
    id integer NOT NULL,
    tokenable_id integer NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255),
    hash character varying(255) NOT NULL,
    abilities text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone
);


ALTER TABLE public.auth_access_tokens OWNER TO ciro3903_melomania_prod;

--
-- Name: auth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.auth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_access_tokens_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: auth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.auth_access_tokens_id_seq OWNED BY public.auth_access_tokens.id;


--
-- Name: callsheets; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.callsheets (
    id integer NOT NULL,
    version character varying(255),
    project_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.callsheets OWNER TO ciro3903_melomania_prod;

--
-- Name: callsheets_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.callsheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.callsheets_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: callsheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.callsheets_id_seq OWNED BY public.callsheets.id;


--
-- Name: composers; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.composers (
    id integer NOT NULL,
    short_name character varying(255),
    long_name character varying(255),
    birth_date date,
    death_date date,
    country character varying(255),
    main_style character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.composers OWNER TO ciro3903_melomania_prod;

--
-- Name: composers_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.composers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.composers_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: composers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.composers_id_seq OWNED BY public.composers.id;


--
-- Name: concerts; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.concerts (
    id integer NOT NULL,
    start_date timestamp with time zone,
    comment text DEFAULT ''::text,
    project_id integer,
    place character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    end_date timestamp with time zone
);


ALTER TABLE public.concerts OWNER TO ciro3903_melomania_prod;

--
-- Name: concerts_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.concerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.concerts_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: concerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.concerts_id_seq OWNED BY public.concerts.id;


--
-- Name: contacts; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.contacts (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) DEFAULT ''::character varying,
    phone character varying(255) DEFAULT ''::character varying,
    messenger character varying(255) DEFAULT ''::character varying,
    comments text DEFAULT ''::text,
    validated boolean DEFAULT false NOT NULL,
    subscribed boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.contacts OWNER TO ciro3903_melomania_prod;

--
-- Name: contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.contacts_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.contacts_id_seq OWNED BY public.contacts.id;


--
-- Name: contacts_lists; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.contacts_lists (
    contact_id integer NOT NULL,
    list_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.contacts_lists OWNER TO ciro3903_melomania_prod;

--
-- Name: contains; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.contains (
    folder_id integer NOT NULL,
    file_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.contains OWNER TO ciro3903_melomania_prod;

--
-- Name: content_callsheets; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.content_callsheets (
    id integer NOT NULL,
    title character varying(255),
    text text DEFAULT ''::text,
    callsheet_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.content_callsheets OWNER TO ciro3903_melomania_prod;

--
-- Name: content_callsheets_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.content_callsheets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.content_callsheets_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: content_callsheets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.content_callsheets_id_seq OWNED BY public.content_callsheets.id;


--
-- Name: content_registrations; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.content_registrations (
    id integer NOT NULL,
    title character varying(255),
    text text DEFAULT ''::text,
    registration_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.content_registrations OWNER TO ciro3903_melomania_prod;

--
-- Name: content_registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.content_registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.content_registrations_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: content_registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.content_registrations_id_seq OWNED BY public.content_registrations.id;


--
-- Name: expense_categories; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.expense_categories (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    is_default boolean DEFAULT false NOT NULL,
    color text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.expense_categories OWNER TO ciro3903_melomania_prod;

--
-- Name: expense_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.expense_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expense_categories_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: expense_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.expense_categories_id_seq OWNED BY public.expense_categories.id;


--
-- Name: files; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.files (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255),
    content text DEFAULT ''::text,
    path character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    size bigint,
    folder_id integer,
    project_id integer,
    piece_id integer,
    material_id integer,
    instrument_part character varying(255),
    part_order integer DEFAULT 0
);


ALTER TABLE public.files OWNER TO ciro3903_melomania_prod;

--
-- Name: files_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.files_id_seq OWNED BY public.files.id;


--
-- Name: folders; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.folders (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent_id integer,
    project_id integer,
    piece_id integer,
    is_system_generated boolean DEFAULT false
);


ALTER TABLE public.folders OWNER TO ciro3903_melomania_prod;

--
-- Name: folders_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.folders_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.folders_id_seq OWNED BY public.folders.id;


--
-- Name: forms; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.forms (
    id integer NOT NULL,
    text text DEFAULT ''::text,
    type character varying(255),
    registration_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.forms OWNER TO ciro3903_melomania_prod;

--
-- Name: forms_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.forms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.forms_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: forms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.forms_id_seq OWNED BY public.forms.id;


--
-- Name: instruments; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.instruments (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    family character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.instruments OWNER TO ciro3903_melomania_prod;

--
-- Name: instruments_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.instruments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.instruments_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: instruments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.instruments_id_seq OWNED BY public.instruments.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.lists (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.lists OWNER TO ciro3903_melomania_prod;

--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.lists_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: mail_templates; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.mail_templates (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content text DEFAULT ''::text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    is_default boolean DEFAULT false
);


ALTER TABLE public.mail_templates OWNER TO ciro3903_melomania_prod;

--
-- Name: mail_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.mail_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mail_templates_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: mail_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.mail_templates_id_seq OWNED BY public.mail_templates.id;


--
-- Name: materials; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.materials (
    id integer NOT NULL,
    piece_id integer NOT NULL,
    name character varying(255) NOT NULL,
    description text,
    edition character varying(255),
    editor character varying(255),
    notes text,
    is_default boolean DEFAULT false,
    is_active boolean DEFAULT true,
    files_count integer DEFAULT 0,
    projects_count integer DEFAULT 0,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.materials OWNER TO ciro3903_melomania_prod;

--
-- Name: materials_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.materials_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.materials_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: materials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.materials_id_seq OWNED BY public.materials.id;


--
-- Name: outgoing_mails; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.outgoing_mails (
    id integer NOT NULL,
    type character varying(255),
    receiver_id integer,
    project_id integer,
    mail_template_id integer,
    sent boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.outgoing_mails OWNER TO ciro3903_melomania_prod;

--
-- Name: outgoing_mails_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.outgoing_mails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.outgoing_mails_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: outgoing_mails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.outgoing_mails_id_seq OWNED BY public.outgoing_mails.id;


--
-- Name: participants; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.participants (
    id integer NOT NULL,
    last_activity timestamp with time zone,
    accepted boolean,
    project_id integer,
    section_id integer,
    contact_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    is_section_leader boolean DEFAULT false,
    audition_status text DEFAULT 'none'::text,
    audition_requested_at timestamp with time zone,
    audition_deadline timestamp with time zone,
    CONSTRAINT participants_audition_status_check CHECK ((audition_status = ANY (ARRAY['none'::text, 'pending'::text, 'completed'::text, 'expired'::text])))
);


ALTER TABLE public.participants OWNER TO ciro3903_melomania_prod;

--
-- Name: participants_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.participants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.participants_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.participants_id_seq OWNED BY public.participants.id;


--
-- Name: participates_in_concerts; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.participates_in_concerts (
    participant_id integer NOT NULL,
    concert_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    comment text DEFAULT ''::text
);


ALTER TABLE public.participates_in_concerts OWNER TO ciro3903_melomania_prod;

--
-- Name: participates_ins; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.participates_ins (
    rehearsal_id integer NOT NULL,
    participant_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    comment text DEFAULT ''::text
);


ALTER TABLE public.participates_ins OWNER TO ciro3903_melomania_prod;

--
-- Name: performed_ins; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.performed_ins (
    project_id integer NOT NULL,
    piece_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    "order" integer DEFAULT 0,
    material_id integer,
    material_specified boolean DEFAULT false
);


ALTER TABLE public.performed_ins OWNER TO ciro3903_melomania_prod;

--
-- Name: pieces; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.pieces (
    id integer NOT NULL,
    name character varying(255),
    opus character varying(255),
    year_of_composition character varying(255),
    composer_id integer,
    type_of_piece_id integer,
    folder_id integer,
    arranger character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    selected_material_id integer
);


ALTER TABLE public.pieces OWNER TO ciro3903_melomania_prod;

--
-- Name: pieces_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.pieces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pieces_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: pieces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.pieces_id_seq OWNED BY public.pieces.id;


--
-- Name: played_in_sections; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.played_in_sections (
    section_id integer NOT NULL,
    instrument_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.played_in_sections OWNER TO ciro3903_melomania_prod;

--
-- Name: plays; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.plays (
    contact_id integer NOT NULL,
    instrument_id integer NOT NULL,
    proficiency_level character varying(255) DEFAULT 'unknown'::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.plays OWNER TO ciro3903_melomania_prod;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.projects (
    id integer NOT NULL,
    name character varying(255),
    section_group_id integer,
    folder_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.projects OWNER TO ciro3903_melomania_prod;

--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.projects_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.projects_id_seq OWNED BY public.projects.id;


--
-- Name: recommendeds; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.recommendeds (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) DEFAULT ''::character varying,
    phone character varying(255) DEFAULT ''::character varying,
    messenger character varying(255) DEFAULT ''::character varying,
    comment text DEFAULT ''::text,
    project_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.recommendeds OWNER TO ciro3903_melomania_prod;

--
-- Name: recommendeds_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.recommendeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recommendeds_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: recommendeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.recommendeds_id_seq OWNED BY public.recommendeds.id;


--
-- Name: recommendeds_instruments; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.recommendeds_instruments (
    recommended_id integer NOT NULL,
    instrument_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.recommendeds_instruments OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_contacts; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.recruitment_contacts (
    id integer NOT NULL,
    project_id integer,
    contact_id integer,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255),
    phone character varying(255),
    messenger character varying(255),
    section_id integer,
    status text DEFAULT 'not_yet_contacted'::text,
    contact_method text DEFAULT 'manual'::text,
    contact_date timestamp with time zone,
    last_follow_up timestamp with time zone,
    notes text,
    recommended_by character varying(255),
    recommender_contact_id integer,
    is_duplicate boolean DEFAULT false,
    source character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    contacted_by character varying(255),
    CONSTRAINT recruitment_contacts_contact_method_check CHECK ((contact_method = ANY (ARRAY['manual'::text, 'email'::text, 'messenger'::text, 'phone'::text]))),
    CONSTRAINT recruitment_contacts_status_check CHECK ((status = ANY (ARRAY['not_yet_contacted'::text, 'awaiting_response'::text, 'to_follow_up'::text, 'not_available'::text, 'pending_validation'::text, 'cancelled'::text, 'recruited'::text])))
);


ALTER TABLE public.recruitment_contacts OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.recruitment_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recruitment_contacts_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.recruitment_contacts_id_seq OWNED BY public.recruitment_contacts.id;


--
-- Name: recruitment_recommendations; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.recruitment_recommendations (
    id integer NOT NULL,
    project_id integer NOT NULL,
    recommender_name character varying(255) NOT NULL,
    recommender_email character varying(255),
    recommended_first_name character varying(255) NOT NULL,
    recommended_last_name character varying(255) NOT NULL,
    recommended_email character varying(255),
    recommended_phone character varying(255),
    recommended_messenger character varying(255),
    recommended_instrument character varying(255),
    recommendation_message text,
    status text DEFAULT 'pending'::text,
    recruitment_contact_id integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT recruitment_recommendations_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'ignored'::text, 'contacted_email'::text, 'contacted_manual'::text])))
);


ALTER TABLE public.recruitment_recommendations OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.recruitment_recommendations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recruitment_recommendations_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.recruitment_recommendations_id_seq OWNED BY public.recruitment_recommendations.id;


--
-- Name: recruitment_settings; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.recruitment_settings (
    id integer NOT NULL,
    project_id integer,
    follow_up_days integer DEFAULT 7,
    auto_follow_up_enabled boolean DEFAULT true,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    auto_import_enabled boolean DEFAULT false,
    last_auto_import timestamp with time zone
);


ALTER TABLE public.recruitment_settings OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.recruitment_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.recruitment_settings_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: recruitment_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.recruitment_settings_id_seq OWNED BY public.recruitment_settings.id;


--
-- Name: registrations; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.registrations (
    id integer NOT NULL,
    project_id integer,
    last_send_date timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.registrations OWNER TO ciro3903_melomania_prod;

--
-- Name: registrations_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.registrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.registrations_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: registrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.registrations_id_seq OWNED BY public.registrations.id;


--
-- Name: rehearsals; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.rehearsals (
    id integer NOT NULL,
    start_date timestamp with time zone,
    comment text DEFAULT ''::text,
    project_id integer,
    place character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    end_date timestamp with time zone
);


ALTER TABLE public.rehearsals OWNER TO ciro3903_melomania_prod;

--
-- Name: rehearsals_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.rehearsals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rehearsals_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: rehearsals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.rehearsals_id_seq OWNED BY public.rehearsals.id;


--
-- Name: responsibles; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.responsibles (
    project_id integer NOT NULL,
    contact_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.responsibles OWNER TO ciro3903_melomania_prod;

--
-- Name: saves; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.saves (
    id integer NOT NULL,
    variable character varying(255),
    value character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.saves OWNER TO ciro3903_melomania_prod;

--
-- Name: saves_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.saves_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saves_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: saves_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.saves_id_seq OWNED BY public.saves.id;


--
-- Name: section_groups; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.section_groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.section_groups OWNER TO ciro3903_melomania_prod;

--
-- Name: section_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.section_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.section_groups_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: section_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.section_groups_id_seq OWNED BY public.section_groups.id;


--
-- Name: section_pdfs; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.section_pdfs (
    id integer NOT NULL,
    project_id integer NOT NULL,
    section_id integer NOT NULL,
    file_id integer NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    "order" integer DEFAULT 0 NOT NULL,
    is_required boolean DEFAULT true,
    is_active boolean DEFAULT true,
    auditions_count integer DEFAULT 0,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.section_pdfs OWNER TO ciro3903_melomania_prod;

--
-- Name: section_pdfs_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.section_pdfs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.section_pdfs_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: section_pdfs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.section_pdfs_id_seq OWNED BY public.section_pdfs.id;


--
-- Name: section_section_groups; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.section_section_groups (
    section_id integer NOT NULL,
    section_group_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    "order" integer DEFAULT 0
);


ALTER TABLE public.section_section_groups OWNER TO ciro3903_melomania_prod;

--
-- Name: sections; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.sections (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    size integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.sections OWNER TO ciro3903_melomania_prod;

--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.sections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sections_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.sections_id_seq OWNED BY public.sections.id;


--
-- Name: seens; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.seens (
    callsheet_id integer NOT NULL,
    participant_id integer NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.seens OWNER TO ciro3903_melomania_prod;

--
-- Name: shared_folders; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.shared_folders (
    id integer NOT NULL,
    folder_id integer,
    token character varying(50) NOT NULL,
    view_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    expires_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.shared_folders OWNER TO ciro3903_melomania_prod;

--
-- Name: shared_folders_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.shared_folders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shared_folders_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: shared_folders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.shared_folders_id_seq OWNED BY public.shared_folders.id;


--
-- Name: type_of_pieces; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.type_of_pieces (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.type_of_pieces OWNER TO ciro3903_melomania_prod;

--
-- Name: type_of_pieces_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.type_of_pieces_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.type_of_pieces_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: type_of_pieces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.type_of_pieces_id_seq OWNED BY public.type_of_pieces.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE TABLE public.users (
    id integer NOT NULL,
    full_name character varying(255),
    email character varying(254) NOT NULL,
    password character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO ciro3903_melomania_prod;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO ciro3903_melomania_prod;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: accounting_categories id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_categories ALTER COLUMN id SET DEFAULT nextval('public.accounting_categories_id_seq'::regclass);


--
-- Name: accounting_entries id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_entries ALTER COLUMN id SET DEFAULT nextval('public.accounting_entries_id_seq'::regclass);


--
-- Name: accounting_settings id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_settings ALTER COLUMN id SET DEFAULT nextval('public.accounting_settings_id_seq'::regclass);


--
-- Name: adonis_schema id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.adonis_schema ALTER COLUMN id SET DEFAULT nextval('public.adonis_schema_id_seq'::regclass);


--
-- Name: answers id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.answers ALTER COLUMN id SET DEFAULT nextval('public.answers_id_seq'::regclass);


--
-- Name: audition_files id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_files ALTER COLUMN id SET DEFAULT nextval('public.audition_files_id_seq'::regclass);


--
-- Name: audition_pdf_files id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files ALTER COLUMN id SET DEFAULT nextval('public.audition_pdf_files_id_seq'::regclass);


--
-- Name: auditions id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions ALTER COLUMN id SET DEFAULT nextval('public.auditions_id_seq'::regclass);


--
-- Name: auth_access_tokens id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.auth_access_tokens_id_seq'::regclass);


--
-- Name: callsheets id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.callsheets ALTER COLUMN id SET DEFAULT nextval('public.callsheets_id_seq'::regclass);


--
-- Name: composers id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.composers ALTER COLUMN id SET DEFAULT nextval('public.composers_id_seq'::regclass);


--
-- Name: concerts id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.concerts ALTER COLUMN id SET DEFAULT nextval('public.concerts_id_seq'::regclass);


--
-- Name: contacts id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contacts ALTER COLUMN id SET DEFAULT nextval('public.contacts_id_seq'::regclass);


--
-- Name: content_callsheets id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_callsheets ALTER COLUMN id SET DEFAULT nextval('public.content_callsheets_id_seq'::regclass);


--
-- Name: content_registrations id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_registrations ALTER COLUMN id SET DEFAULT nextval('public.content_registrations_id_seq'::regclass);


--
-- Name: expense_categories id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.expense_categories ALTER COLUMN id SET DEFAULT nextval('public.expense_categories_id_seq'::regclass);


--
-- Name: files id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files ALTER COLUMN id SET DEFAULT nextval('public.files_id_seq'::regclass);


--
-- Name: folders id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.folders ALTER COLUMN id SET DEFAULT nextval('public.folders_id_seq'::regclass);


--
-- Name: forms id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.forms ALTER COLUMN id SET DEFAULT nextval('public.forms_id_seq'::regclass);


--
-- Name: instruments id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.instruments ALTER COLUMN id SET DEFAULT nextval('public.instruments_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: mail_templates id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.mail_templates ALTER COLUMN id SET DEFAULT nextval('public.mail_templates_id_seq'::regclass);


--
-- Name: materials id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.materials ALTER COLUMN id SET DEFAULT nextval('public.materials_id_seq'::regclass);


--
-- Name: outgoing_mails id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.outgoing_mails ALTER COLUMN id SET DEFAULT nextval('public.outgoing_mails_id_seq'::regclass);


--
-- Name: participants id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participants ALTER COLUMN id SET DEFAULT nextval('public.participants_id_seq'::regclass);


--
-- Name: pieces id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces ALTER COLUMN id SET DEFAULT nextval('public.pieces_id_seq'::regclass);


--
-- Name: projects id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.projects ALTER COLUMN id SET DEFAULT nextval('public.projects_id_seq'::regclass);


--
-- Name: recommendeds id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds ALTER COLUMN id SET DEFAULT nextval('public.recommendeds_id_seq'::regclass);


--
-- Name: recruitment_contacts id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts ALTER COLUMN id SET DEFAULT nextval('public.recruitment_contacts_id_seq'::regclass);


--
-- Name: recruitment_recommendations id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_recommendations ALTER COLUMN id SET DEFAULT nextval('public.recruitment_recommendations_id_seq'::regclass);


--
-- Name: recruitment_settings id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_settings ALTER COLUMN id SET DEFAULT nextval('public.recruitment_settings_id_seq'::regclass);


--
-- Name: registrations id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.registrations ALTER COLUMN id SET DEFAULT nextval('public.registrations_id_seq'::regclass);


--
-- Name: rehearsals id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.rehearsals ALTER COLUMN id SET DEFAULT nextval('public.rehearsals_id_seq'::regclass);


--
-- Name: saves id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.saves ALTER COLUMN id SET DEFAULT nextval('public.saves_id_seq'::regclass);


--
-- Name: section_groups id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_groups ALTER COLUMN id SET DEFAULT nextval('public.section_groups_id_seq'::regclass);


--
-- Name: section_pdfs id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs ALTER COLUMN id SET DEFAULT nextval('public.section_pdfs_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.sections ALTER COLUMN id SET DEFAULT nextval('public.sections_id_seq'::regclass);


--
-- Name: shared_folders id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.shared_folders ALTER COLUMN id SET DEFAULT nextval('public.shared_folders_id_seq'::regclass);


--
-- Name: type_of_pieces id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.type_of_pieces ALTER COLUMN id SET DEFAULT nextval('public.type_of_pieces_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: accounting_categories accounting_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_categories
    ADD CONSTRAINT accounting_categories_pkey PRIMARY KEY (id);


--
-- Name: accounting_entries accounting_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_entries
    ADD CONSTRAINT accounting_entries_pkey PRIMARY KEY (id);


--
-- Name: accounting_settings accounting_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_settings
    ADD CONSTRAINT accounting_settings_pkey PRIMARY KEY (id);


--
-- Name: accounting_settings accounting_settings_project_id_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_settings
    ADD CONSTRAINT accounting_settings_project_id_unique UNIQUE (project_id);


--
-- Name: adonis_schema adonis_schema_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.adonis_schema
    ADD CONSTRAINT adonis_schema_pkey PRIMARY KEY (id);


--
-- Name: adonis_schema_versions adonis_schema_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.adonis_schema_versions
    ADD CONSTRAINT adonis_schema_versions_pkey PRIMARY KEY (version);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: attached_to_callsheets attached_to_callsheets_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_callsheets
    ADD CONSTRAINT attached_to_callsheets_pkey PRIMARY KEY (file_id, callsheet_id);


--
-- Name: attached_to_mail_templates attached_to_mail_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_mail_templates
    ADD CONSTRAINT attached_to_mail_templates_pkey PRIMARY KEY (file_id, mail_template_id);


--
-- Name: audition_files audition_files_audition_id_file_id_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_files
    ADD CONSTRAINT audition_files_audition_id_file_id_unique UNIQUE (audition_id, file_id);


--
-- Name: audition_files audition_files_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_files
    ADD CONSTRAINT audition_files_pkey PRIMARY KEY (id);


--
-- Name: audition_pdf_files audition_pdf_files_audition_id_file_id_title_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files
    ADD CONSTRAINT audition_pdf_files_audition_id_file_id_title_unique UNIQUE (audition_id, file_id, title);


--
-- Name: audition_pdf_files audition_pdf_files_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files
    ADD CONSTRAINT audition_pdf_files_pkey PRIMARY KEY (id);


--
-- Name: auditions auditions_participant_id_project_id_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions
    ADD CONSTRAINT auditions_participant_id_project_id_unique UNIQUE (participant_id, project_id);


--
-- Name: auditions auditions_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions
    ADD CONSTRAINT auditions_pkey PRIMARY KEY (id);


--
-- Name: auditions auditions_secure_token_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions
    ADD CONSTRAINT auditions_secure_token_unique UNIQUE (secure_token);


--
-- Name: auth_access_tokens auth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auth_access_tokens
    ADD CONSTRAINT auth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: callsheets callsheets_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.callsheets
    ADD CONSTRAINT callsheets_pkey PRIMARY KEY (id);


--
-- Name: composers composers_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.composers
    ADD CONSTRAINT composers_pkey PRIMARY KEY (id);


--
-- Name: concerts concerts_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.concerts
    ADD CONSTRAINT concerts_pkey PRIMARY KEY (id);


--
-- Name: contacts_lists contacts_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contacts_lists
    ADD CONSTRAINT contacts_lists_pkey PRIMARY KEY (contact_id, list_id);


--
-- Name: contacts contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contacts
    ADD CONSTRAINT contacts_pkey PRIMARY KEY (id);


--
-- Name: contains contains_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contains
    ADD CONSTRAINT contains_pkey PRIMARY KEY (folder_id, file_id);


--
-- Name: content_callsheets content_callsheets_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_callsheets
    ADD CONSTRAINT content_callsheets_pkey PRIMARY KEY (id);


--
-- Name: content_registrations content_registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_registrations
    ADD CONSTRAINT content_registrations_pkey PRIMARY KEY (id);


--
-- Name: expense_categories expense_categories_name_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_name_unique UNIQUE (name);


--
-- Name: expense_categories expense_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_pkey PRIMARY KEY (id);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (id);


--
-- Name: folders folders_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_pkey PRIMARY KEY (id);


--
-- Name: forms forms_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_pkey PRIMARY KEY (id);


--
-- Name: instruments instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.instruments
    ADD CONSTRAINT instruments_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: mail_templates mail_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.mail_templates
    ADD CONSTRAINT mail_templates_pkey PRIMARY KEY (id);


--
-- Name: materials materials_piece_id_name_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_piece_id_name_unique UNIQUE (piece_id, name);


--
-- Name: materials materials_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_pkey PRIMARY KEY (id);


--
-- Name: outgoing_mails outgoing_mails_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.outgoing_mails
    ADD CONSTRAINT outgoing_mails_pkey PRIMARY KEY (id);


--
-- Name: participants participants_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_pkey PRIMARY KEY (id);


--
-- Name: participates_in_concerts participates_in_concerts_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_in_concerts
    ADD CONSTRAINT participates_in_concerts_pkey PRIMARY KEY (participant_id, concert_id);


--
-- Name: participates_ins participates_ins_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_ins
    ADD CONSTRAINT participates_ins_pkey PRIMARY KEY (rehearsal_id, participant_id);


--
-- Name: performed_ins performed_ins_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.performed_ins
    ADD CONSTRAINT performed_ins_pkey PRIMARY KEY (project_id, piece_id);


--
-- Name: pieces pieces_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces
    ADD CONSTRAINT pieces_pkey PRIMARY KEY (id);


--
-- Name: played_in_sections played_in_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.played_in_sections
    ADD CONSTRAINT played_in_sections_pkey PRIMARY KEY (section_id, instrument_id);


--
-- Name: plays plays_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.plays
    ADD CONSTRAINT plays_pkey PRIMARY KEY (contact_id, instrument_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: recommendeds_instruments recommendeds_instruments_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds_instruments
    ADD CONSTRAINT recommendeds_instruments_pkey PRIMARY KEY (recommended_id, instrument_id);


--
-- Name: recommendeds recommendeds_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds
    ADD CONSTRAINT recommendeds_pkey PRIMARY KEY (id);


--
-- Name: recruitment_contacts recruitment_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_pkey PRIMARY KEY (id);


--
-- Name: recruitment_contacts recruitment_contacts_project_id_contact_id_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_project_id_contact_id_unique UNIQUE (project_id, contact_id);


--
-- Name: recruitment_recommendations recruitment_recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_recommendations
    ADD CONSTRAINT recruitment_recommendations_pkey PRIMARY KEY (id);


--
-- Name: recruitment_settings recruitment_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_settings
    ADD CONSTRAINT recruitment_settings_pkey PRIMARY KEY (id);


--
-- Name: recruitment_settings recruitment_settings_project_id_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_settings
    ADD CONSTRAINT recruitment_settings_project_id_unique UNIQUE (project_id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: rehearsals rehearsals_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.rehearsals
    ADD CONSTRAINT rehearsals_pkey PRIMARY KEY (id);


--
-- Name: responsibles responsibles_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.responsibles
    ADD CONSTRAINT responsibles_pkey PRIMARY KEY (project_id, contact_id);


--
-- Name: saves saves_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.saves
    ADD CONSTRAINT saves_pkey PRIMARY KEY (id);


--
-- Name: section_groups section_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_groups
    ADD CONSTRAINT section_groups_pkey PRIMARY KEY (id);


--
-- Name: section_pdfs section_pdfs_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs
    ADD CONSTRAINT section_pdfs_pkey PRIMARY KEY (id);


--
-- Name: section_pdfs section_pdfs_project_id_section_id_file_id_title_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs
    ADD CONSTRAINT section_pdfs_project_id_section_id_file_id_title_unique UNIQUE (project_id, section_id, file_id, title);


--
-- Name: section_section_groups section_section_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_section_groups
    ADD CONSTRAINT section_section_groups_pkey PRIMARY KEY (section_id, section_group_id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: seens seens_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.seens
    ADD CONSTRAINT seens_pkey PRIMARY KEY (callsheet_id, participant_id);


--
-- Name: shared_folders shared_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.shared_folders
    ADD CONSTRAINT shared_folders_pkey PRIMARY KEY (id);


--
-- Name: shared_folders shared_folders_token_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.shared_folders
    ADD CONSTRAINT shared_folders_token_unique UNIQUE (token);


--
-- Name: type_of_pieces type_of_pieces_name_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.type_of_pieces
    ADD CONSTRAINT type_of_pieces_name_unique UNIQUE (name);


--
-- Name: type_of_pieces type_of_pieces_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.type_of_pieces
    ADD CONSTRAINT type_of_pieces_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: accounting_categories_name_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX accounting_categories_name_index ON public.accounting_categories USING btree (name);


--
-- Name: accounting_entries_due_date_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX accounting_entries_due_date_index ON public.accounting_entries USING btree (due_date);


--
-- Name: accounting_entries_entry_type_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX accounting_entries_entry_type_index ON public.accounting_entries USING btree (entry_type);


--
-- Name: accounting_entries_payment_date_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX accounting_entries_payment_date_index ON public.accounting_entries USING btree (payment_date);


--
-- Name: accounting_entries_project_id_payment_status_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX accounting_entries_project_id_payment_status_index ON public.accounting_entries USING btree (project_id, payment_status);


--
-- Name: audition_files_audition_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_files_audition_id_index ON public.audition_files USING btree (audition_id);


--
-- Name: audition_files_file_type_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_files_file_type_index ON public.audition_files USING btree (file_type);


--
-- Name: audition_files_uploaded_at_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_files_uploaded_at_index ON public.audition_files USING btree (uploaded_at);


--
-- Name: audition_pdf_files_audition_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_pdf_files_audition_id_index ON public.audition_pdf_files USING btree (audition_id);


--
-- Name: audition_pdf_files_order_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_pdf_files_order_index ON public.audition_pdf_files USING btree ("order");


--
-- Name: audition_pdf_files_section_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX audition_pdf_files_section_id_index ON public.audition_pdf_files USING btree (section_id);


--
-- Name: auditions_deadline_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX auditions_deadline_index ON public.auditions USING btree (deadline);


--
-- Name: auditions_is_submitted_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX auditions_is_submitted_index ON public.auditions USING btree (is_submitted);


--
-- Name: auditions_participant_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX auditions_participant_id_index ON public.auditions USING btree (participant_id);


--
-- Name: auditions_project_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX auditions_project_id_index ON public.auditions USING btree (project_id);


--
-- Name: auditions_secure_token_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX auditions_secure_token_index ON public.auditions USING btree (secure_token);


--
-- Name: files_folder_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX files_folder_id_index ON public.files USING btree (folder_id);


--
-- Name: files_material_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX files_material_id_index ON public.files USING btree (material_id);


--
-- Name: files_material_id_part_order_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX files_material_id_part_order_index ON public.files USING btree (material_id, part_order);


--
-- Name: files_piece_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX files_piece_id_index ON public.files USING btree (piece_id);


--
-- Name: files_project_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX files_project_id_index ON public.files USING btree (project_id);


--
-- Name: folders_is_system_generated_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX folders_is_system_generated_index ON public.folders USING btree (is_system_generated);


--
-- Name: folders_parent_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX folders_parent_id_index ON public.folders USING btree (parent_id);


--
-- Name: folders_piece_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX folders_piece_id_index ON public.folders USING btree (piece_id);


--
-- Name: folders_project_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX folders_project_id_index ON public.folders USING btree (project_id);


--
-- Name: idx_recommendations_created_at; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX idx_recommendations_created_at ON public.recruitment_recommendations USING btree (created_at);


--
-- Name: idx_recommendations_project_status; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX idx_recommendations_project_status ON public.recruitment_recommendations USING btree (project_id, status);


--
-- Name: idx_recommendations_status; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX idx_recommendations_status ON public.recruitment_recommendations USING btree (status);


--
-- Name: materials_is_active_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX materials_is_active_index ON public.materials USING btree (is_active);


--
-- Name: materials_is_default_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX materials_is_default_index ON public.materials USING btree (is_default);


--
-- Name: materials_piece_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX materials_piece_id_index ON public.materials USING btree (piece_id);


--
-- Name: participants_audition_deadline_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX participants_audition_deadline_index ON public.participants USING btree (audition_deadline);


--
-- Name: participants_audition_status_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX participants_audition_status_index ON public.participants USING btree (audition_status);


--
-- Name: performed_ins_material_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX performed_ins_material_id_index ON public.performed_ins USING btree (material_id);


--
-- Name: performed_ins_material_specified_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX performed_ins_material_specified_index ON public.performed_ins USING btree (material_specified);


--
-- Name: pieces_selected_material_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX pieces_selected_material_id_index ON public.pieces USING btree (selected_material_id);


--
-- Name: recruitment_contacts_contact_date_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX recruitment_contacts_contact_date_index ON public.recruitment_contacts USING btree (contact_date);


--
-- Name: recruitment_contacts_contacted_by_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX recruitment_contacts_contacted_by_index ON public.recruitment_contacts USING btree (contacted_by);


--
-- Name: recruitment_contacts_project_id_status_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX recruitment_contacts_project_id_status_index ON public.recruitment_contacts USING btree (project_id, status);


--
-- Name: recruitment_settings_auto_import_enabled_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX recruitment_settings_auto_import_enabled_index ON public.recruitment_settings USING btree (auto_import_enabled);


--
-- Name: recruitment_settings_last_auto_import_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX recruitment_settings_last_auto_import_index ON public.recruitment_settings USING btree (last_auto_import);


--
-- Name: section_pdfs_is_active_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX section_pdfs_is_active_index ON public.section_pdfs USING btree (is_active);


--
-- Name: section_pdfs_order_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX section_pdfs_order_index ON public.section_pdfs USING btree ("order");


--
-- Name: section_pdfs_project_id_section_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX section_pdfs_project_id_section_id_index ON public.section_pdfs USING btree (project_id, section_id);


--
-- Name: shared_folders_folder_id_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX shared_folders_folder_id_index ON public.shared_folders USING btree (folder_id);


--
-- Name: shared_folders_is_active_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX shared_folders_is_active_index ON public.shared_folders USING btree (is_active);


--
-- Name: shared_folders_token_index; Type: INDEX; Schema: public; Owner: ciro3903_melomania_prod
--

CREATE INDEX shared_folders_token_index ON public.shared_folders USING btree (token);


--
-- Name: accounting_entries accounting_entries_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_entries
    ADD CONSTRAINT accounting_entries_category_id_foreign FOREIGN KEY (category_id) REFERENCES public.accounting_categories(id) ON DELETE SET NULL;


--
-- Name: accounting_entries accounting_entries_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_entries
    ADD CONSTRAINT accounting_entries_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: accounting_entries accounting_entries_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_entries
    ADD CONSTRAINT accounting_entries_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: accounting_settings accounting_settings_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.accounting_settings
    ADD CONSTRAINT accounting_settings_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: answers answers_form_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_form_id_foreign FOREIGN KEY (form_id) REFERENCES public.forms(id) ON DELETE CASCADE;


--
-- Name: answers answers_participant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.answers
    ADD CONSTRAINT answers_participant_id_foreign FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- Name: attached_to_callsheets attached_to_callsheets_callsheet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_callsheets
    ADD CONSTRAINT attached_to_callsheets_callsheet_id_foreign FOREIGN KEY (callsheet_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: attached_to_callsheets attached_to_callsheets_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_callsheets
    ADD CONSTRAINT attached_to_callsheets_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.callsheets(id) ON DELETE CASCADE;


--
-- Name: attached_to_mail_templates attached_to_mail_templates_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_mail_templates
    ADD CONSTRAINT attached_to_mail_templates_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: attached_to_mail_templates attached_to_mail_templates_mail_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.attached_to_mail_templates
    ADD CONSTRAINT attached_to_mail_templates_mail_template_id_foreign FOREIGN KEY (mail_template_id) REFERENCES public.mail_templates(id) ON DELETE CASCADE;


--
-- Name: audition_files audition_files_audition_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_files
    ADD CONSTRAINT audition_files_audition_id_foreign FOREIGN KEY (audition_id) REFERENCES public.auditions(id) ON DELETE CASCADE;


--
-- Name: audition_files audition_files_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_files
    ADD CONSTRAINT audition_files_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: audition_pdf_files audition_pdf_files_audition_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files
    ADD CONSTRAINT audition_pdf_files_audition_id_foreign FOREIGN KEY (audition_id) REFERENCES public.auditions(id) ON DELETE CASCADE;


--
-- Name: audition_pdf_files audition_pdf_files_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files
    ADD CONSTRAINT audition_pdf_files_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: audition_pdf_files audition_pdf_files_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.audition_pdf_files
    ADD CONSTRAINT audition_pdf_files_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: auditions auditions_participant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions
    ADD CONSTRAINT auditions_participant_id_foreign FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- Name: auditions auditions_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auditions
    ADD CONSTRAINT auditions_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: auth_access_tokens auth_access_tokens_tokenable_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.auth_access_tokens
    ADD CONSTRAINT auth_access_tokens_tokenable_id_foreign FOREIGN KEY (tokenable_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: callsheets callsheets_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.callsheets
    ADD CONSTRAINT callsheets_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: concerts concerts_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.concerts
    ADD CONSTRAINT concerts_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: contacts_lists contacts_lists_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contacts_lists
    ADD CONSTRAINT contacts_lists_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: contacts_lists contacts_lists_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contacts_lists
    ADD CONSTRAINT contacts_lists_list_id_foreign FOREIGN KEY (list_id) REFERENCES public.lists(id) ON DELETE CASCADE;


--
-- Name: contains contains_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contains
    ADD CONSTRAINT contains_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: contains contains_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.contains
    ADD CONSTRAINT contains_folder_id_foreign FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- Name: content_callsheets content_callsheets_callsheet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_callsheets
    ADD CONSTRAINT content_callsheets_callsheet_id_foreign FOREIGN KEY (callsheet_id) REFERENCES public.callsheets(id) ON DELETE CASCADE;


--
-- Name: content_registrations content_registrations_registration_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.content_registrations
    ADD CONSTRAINT content_registrations_registration_id_foreign FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- Name: files files_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_folder_id_foreign FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- Name: files files_material_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_material_id_foreign FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE CASCADE;


--
-- Name: files files_piece_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_piece_id_foreign FOREIGN KEY (piece_id) REFERENCES public.pieces(id) ON DELETE CASCADE;


--
-- Name: files files_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: folders folders_parent_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_parent_id_foreign FOREIGN KEY (parent_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- Name: folders folders_piece_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_piece_id_foreign FOREIGN KEY (piece_id) REFERENCES public.pieces(id) ON DELETE CASCADE;


--
-- Name: folders folders_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.folders
    ADD CONSTRAINT folders_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: forms forms_registration_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_registration_id_foreign FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- Name: materials materials_piece_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.materials
    ADD CONSTRAINT materials_piece_id_foreign FOREIGN KEY (piece_id) REFERENCES public.pieces(id) ON DELETE CASCADE;


--
-- Name: outgoing_mails outgoing_mails_mail_template_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.outgoing_mails
    ADD CONSTRAINT outgoing_mails_mail_template_id_foreign FOREIGN KEY (mail_template_id) REFERENCES public.mail_templates(id) ON DELETE CASCADE;


--
-- Name: outgoing_mails outgoing_mails_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.outgoing_mails
    ADD CONSTRAINT outgoing_mails_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: outgoing_mails outgoing_mails_receiver_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.outgoing_mails
    ADD CONSTRAINT outgoing_mails_receiver_id_foreign FOREIGN KEY (receiver_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: participants participants_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: participants participants_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: participants participants_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participants
    ADD CONSTRAINT participants_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE RESTRICT;


--
-- Name: participates_in_concerts participates_in_concerts_concert_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_in_concerts
    ADD CONSTRAINT participates_in_concerts_concert_id_foreign FOREIGN KEY (concert_id) REFERENCES public.concerts(id) ON DELETE CASCADE;


--
-- Name: participates_in_concerts participates_in_concerts_participant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_in_concerts
    ADD CONSTRAINT participates_in_concerts_participant_id_foreign FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- Name: participates_ins participates_ins_participant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_ins
    ADD CONSTRAINT participates_ins_participant_id_foreign FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- Name: participates_ins participates_ins_rehearsal_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.participates_ins
    ADD CONSTRAINT participates_ins_rehearsal_id_foreign FOREIGN KEY (rehearsal_id) REFERENCES public.rehearsals(id) ON DELETE CASCADE;


--
-- Name: performed_ins performed_ins_material_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.performed_ins
    ADD CONSTRAINT performed_ins_material_id_foreign FOREIGN KEY (material_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: performed_ins performed_ins_piece_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.performed_ins
    ADD CONSTRAINT performed_ins_piece_id_foreign FOREIGN KEY (piece_id) REFERENCES public.pieces(id) ON DELETE CASCADE;


--
-- Name: performed_ins performed_ins_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.performed_ins
    ADD CONSTRAINT performed_ins_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: pieces pieces_composer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces
    ADD CONSTRAINT pieces_composer_id_foreign FOREIGN KEY (composer_id) REFERENCES public.composers(id) ON DELETE SET NULL;


--
-- Name: pieces pieces_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces
    ADD CONSTRAINT pieces_folder_id_foreign FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE SET NULL;


--
-- Name: pieces pieces_selected_material_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces
    ADD CONSTRAINT pieces_selected_material_id_foreign FOREIGN KEY (selected_material_id) REFERENCES public.materials(id) ON DELETE SET NULL;


--
-- Name: pieces pieces_type_of_piece_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.pieces
    ADD CONSTRAINT pieces_type_of_piece_id_foreign FOREIGN KEY (type_of_piece_id) REFERENCES public.type_of_pieces(id) ON DELETE SET NULL;


--
-- Name: played_in_sections played_in_sections_instrument_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.played_in_sections
    ADD CONSTRAINT played_in_sections_instrument_id_foreign FOREIGN KEY (instrument_id) REFERENCES public.instruments(id) ON DELETE CASCADE;


--
-- Name: played_in_sections played_in_sections_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.played_in_sections
    ADD CONSTRAINT played_in_sections_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: plays plays_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.plays
    ADD CONSTRAINT plays_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: plays plays_instrument_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.plays
    ADD CONSTRAINT plays_instrument_id_foreign FOREIGN KEY (instrument_id) REFERENCES public.instruments(id) ON DELETE CASCADE;


--
-- Name: projects projects_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_folder_id_foreign FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE SET NULL;


--
-- Name: projects projects_section_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_section_group_id_foreign FOREIGN KEY (section_group_id) REFERENCES public.section_groups(id) ON DELETE RESTRICT;


--
-- Name: recommendeds_instruments recommendeds_instruments_instrument_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds_instruments
    ADD CONSTRAINT recommendeds_instruments_instrument_id_foreign FOREIGN KEY (instrument_id) REFERENCES public.instruments(id) ON DELETE CASCADE;


--
-- Name: recommendeds_instruments recommendeds_instruments_recommended_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds_instruments
    ADD CONSTRAINT recommendeds_instruments_recommended_id_foreign FOREIGN KEY (recommended_id) REFERENCES public.recommendeds(id) ON DELETE CASCADE;


--
-- Name: recommendeds recommendeds_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recommendeds
    ADD CONSTRAINT recommendeds_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: recruitment_contacts recruitment_contacts_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: recruitment_contacts recruitment_contacts_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: recruitment_contacts recruitment_contacts_recommender_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_recommender_contact_id_foreign FOREIGN KEY (recommender_contact_id) REFERENCES public.contacts(id) ON DELETE SET NULL;


--
-- Name: recruitment_contacts recruitment_contacts_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_contacts
    ADD CONSTRAINT recruitment_contacts_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE SET NULL;


--
-- Name: recruitment_recommendations recruitment_recommendations_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_recommendations
    ADD CONSTRAINT recruitment_recommendations_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: recruitment_recommendations recruitment_recommendations_recruitment_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_recommendations
    ADD CONSTRAINT recruitment_recommendations_recruitment_contact_id_foreign FOREIGN KEY (recruitment_contact_id) REFERENCES public.recruitment_contacts(id) ON DELETE SET NULL;


--
-- Name: recruitment_settings recruitment_settings_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.recruitment_settings
    ADD CONSTRAINT recruitment_settings_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: registrations registrations_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: rehearsals rehearsals_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.rehearsals
    ADD CONSTRAINT rehearsals_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: responsibles responsibles_contact_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.responsibles
    ADD CONSTRAINT responsibles_contact_id_foreign FOREIGN KEY (contact_id) REFERENCES public.contacts(id) ON DELETE CASCADE;


--
-- Name: responsibles responsibles_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.responsibles
    ADD CONSTRAINT responsibles_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: section_pdfs section_pdfs_file_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs
    ADD CONSTRAINT section_pdfs_file_id_foreign FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE;


--
-- Name: section_pdfs section_pdfs_project_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs
    ADD CONSTRAINT section_pdfs_project_id_foreign FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;


--
-- Name: section_pdfs section_pdfs_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_pdfs
    ADD CONSTRAINT section_pdfs_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: section_section_groups section_section_groups_section_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_section_groups
    ADD CONSTRAINT section_section_groups_section_group_id_foreign FOREIGN KEY (section_group_id) REFERENCES public.section_groups(id) ON DELETE CASCADE;


--
-- Name: section_section_groups section_section_groups_section_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.section_section_groups
    ADD CONSTRAINT section_section_groups_section_id_foreign FOREIGN KEY (section_id) REFERENCES public.sections(id) ON DELETE CASCADE;


--
-- Name: seens seens_callsheet_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.seens
    ADD CONSTRAINT seens_callsheet_id_foreign FOREIGN KEY (callsheet_id) REFERENCES public.callsheets(id) ON DELETE CASCADE;


--
-- Name: seens seens_participant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.seens
    ADD CONSTRAINT seens_participant_id_foreign FOREIGN KEY (participant_id) REFERENCES public.participants(id) ON DELETE CASCADE;


--
-- Name: shared_folders shared_folders_folder_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: ciro3903_melomania_prod
--

ALTER TABLE ONLY public.shared_folders
    ADD CONSTRAINT shared_folders_folder_id_foreign FOREIGN KEY (folder_id) REFERENCES public.folders(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

