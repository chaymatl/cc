--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 15.8

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

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO postgres;

--
-- Name: bin_scans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bin_scans (
    id integer NOT NULL,
    user_id integer,
    qr_code character varying NOT NULL,
    bin_id character varying,
    waste_type character varying,
    weight_kg double precision,
    points_earned double precision,
    score_before double precision,
    score_after double precision,
    firebase_synced boolean,
    scanned_at timestamp without time zone,
    smart_bin_id integer
);


ALTER TABLE public.bin_scans OWNER TO postgres;

--
-- Name: bin_scans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bin_scans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bin_scans_id_seq OWNER TO postgres;

--
-- Name: bin_scans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bin_scans_id_seq OWNED BY public.bin_scans.id;


--
-- Name: center_proposals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.center_proposals (
    id integer NOT NULL,
    user_id integer,
    user_name character varying,
    name character varying,
    address character varying,
    lat character varying,
    lng character varying,
    waste_types character varying,
    description text,
    status character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.center_proposals OWNER TO postgres;

--
-- Name: center_proposals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.center_proposals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.center_proposals_id_seq OWNER TO postgres;

--
-- Name: center_proposals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.center_proposals_id_seq OWNED BY public.center_proposals.id;


--
-- Name: citizen_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citizen_groups (
    id integer NOT NULL,
    educator_id integer,
    name character varying NOT NULL,
    description text,
    color character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.citizen_groups OWNER TO postgres;

--
-- Name: citizen_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.citizen_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.citizen_groups_id_seq OWNER TO postgres;

--
-- Name: citizen_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.citizen_groups_id_seq OWNED BY public.citizen_groups.id;


--
-- Name: citizen_reports; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.citizen_reports (
    id integer NOT NULL,
    collection_point_id integer NOT NULL,
    user_id integer NOT NULL,
    report_type character varying DEFAULT 'other'::character varying NOT NULL,
    description text,
    photo_url character varying,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    assigned_to integer,
    resolution_note text,
    resolved_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.citizen_reports OWNER TO postgres;

--
-- Name: citizen_reports_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.citizen_reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.citizen_reports_id_seq OWNER TO postgres;

--
-- Name: citizen_reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.citizen_reports_id_seq OWNED BY public.citizen_reports.id;


--
-- Name: collection_points; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_points (
    id integer NOT NULL,
    name character varying NOT NULL,
    lat double precision,
    lng double precision,
    is_verified boolean,
    types character varying,
    address character varying,
    hours character varying,
    status character varying,
    load_level double precision DEFAULT '0'::double precision,
    created_at timestamp without time zone
);


ALTER TABLE public.collection_points OWNER TO postgres;

--
-- Name: collection_points_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collection_points_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collection_points_id_seq OWNER TO postgres;

--
-- Name: collection_points_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collection_points_id_seq OWNED BY public.collection_points.id;


--
-- Name: collection_routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collection_routes (
    id integer NOT NULL,
    collector_id integer NOT NULL,
    date_planned timestamp without time zone NOT NULL,
    status character varying DEFAULT 'planned'::character varying NOT NULL,
    point_ids text,
    notes text,
    total_weight_kg double precision,
    completed_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.collection_routes OWNER TO postgres;

--
-- Name: collection_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collection_routes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collection_routes_id_seq OWNER TO postgres;

--
-- Name: collection_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collection_routes_id_seq OWNED BY public.collection_routes.id;


--
-- Name: collector_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collector_logs (
    id integer NOT NULL,
    collector_id integer NOT NULL,
    smart_bin_id integer,
    bin_code character varying NOT NULL,
    bin_type character varying,
    weight_before_kg double precision,
    notified boolean,
    collected_at timestamp without time zone
);


ALTER TABLE public.collector_logs OWNER TO postgres;

--
-- Name: collector_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collector_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collector_logs_id_seq OWNER TO postgres;

--
-- Name: collector_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collector_logs_id_seq OWNED BY public.collector_logs.id;


--
-- Name: collector_zone_assignments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collector_zone_assignments (
    id integer NOT NULL,
    zone_id integer,
    collector_id integer,
    assigned_by integer NOT NULL,
    mission_message text,
    priority character varying,
    status character varying,
    due_date timestamp without time zone,
    assigned_at timestamp without time zone,
    completed_at timestamp without time zone,
    collector_notes text,
    collection_point_id integer,
    group_id integer,
    collection_point_ids text,
    target_label character varying(200)
);


ALTER TABLE public.collector_zone_assignments OWNER TO postgres;

--
-- Name: collector_zone_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collector_zone_assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collector_zone_assignments_id_seq OWNER TO postgres;

--
-- Name: collector_zone_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collector_zone_assignments_id_seq OWNED BY public.collector_zone_assignments.id;


--
-- Name: collector_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.collector_zones (
    id integer NOT NULL,
    name character varying NOT NULL,
    territory character varying NOT NULL,
    description text,
    color_hex character varying NOT NULL,
    created_by integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.collector_zones OWNER TO postgres;

--
-- Name: collector_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.collector_zones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.collector_zones_id_seq OWNER TO postgres;

--
-- Name: collector_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.collector_zones_id_seq OWNED BY public.collector_zones.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    post_id integer,
    user_id integer,
    user_name character varying,
    user_avatar_url character varying,
    content text,
    parent_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comments_id_seq OWNER TO postgres;

--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: custom_actor_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.custom_actor_groups (
    id integer NOT NULL,
    name character varying NOT NULL,
    description character varying,
    member_ids json DEFAULT '[]'::json NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.custom_actor_groups OWNER TO postgres;

--
-- Name: custom_actor_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.custom_actor_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.custom_actor_groups_id_seq OWNER TO postgres;

--
-- Name: custom_actor_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.custom_actor_groups_id_seq OWNED BY public.custom_actor_groups.id;


--
-- Name: educator_videos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.educator_videos (
    id integer NOT NULL,
    educator_id integer,
    educator_name character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    video_url character varying NOT NULL,
    thumbnail_url character varying,
    duration character varying,
    category_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.educator_videos OWNER TO postgres;

--
-- Name: educator_videos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.educator_videos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.educator_videos_id_seq OWNER TO postgres;

--
-- Name: educator_videos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.educator_videos_id_seq OWNED BY public.educator_videos.id;


--
-- Name: group_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.group_members (
    id integer NOT NULL,
    group_id integer,
    user_id integer,
    added_at timestamp without time zone
);


ALTER TABLE public.group_members OWNER TO postgres;

--
-- Name: group_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.group_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_members_id_seq OWNER TO postgres;

--
-- Name: group_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.group_members_id_seq OWNED BY public.group_members.id;


--
-- Name: likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.likes (
    id integer NOT NULL,
    user_id integer,
    post_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.likes OWNER TO postgres;

--
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.likes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.likes_id_seq OWNER TO postgres;

--
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.likes_id_seq OWNED BY public.likes.id;


--
-- Name: local_instructions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.local_instructions (
    id integer NOT NULL,
    territory character varying NOT NULL,
    city character varying,
    waste_type character varying NOT NULL,
    title character varying NOT NULL,
    instruction text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_by integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE public.local_instructions OWNER TO postgres;

--
-- Name: local_instructions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.local_instructions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.local_instructions_id_seq OWNER TO postgres;

--
-- Name: local_instructions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.local_instructions_id_seq OWNED BY public.local_instructions.id;


--
-- Name: meeting_participants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meeting_participants (
    id integer NOT NULL,
    meeting_id integer,
    user_id integer,
    user_name character varying,
    status character varying
);


ALTER TABLE public.meeting_participants OWNER TO postgres;

--
-- Name: meeting_participants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meeting_participants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.meeting_participants_id_seq OWNER TO postgres;

--
-- Name: meeting_participants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meeting_participants_id_seq OWNED BY public.meeting_participants.id;


--
-- Name: meetings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meetings (
    id integer NOT NULL,
    educator_id integer,
    educator_name character varying NOT NULL,
    title character varying NOT NULL,
    description text,
    meet_link character varying NOT NULL,
    scheduled_at timestamp without time zone NOT NULL,
    duration_minutes integer,
    group_name character varying,
    audience character varying,
    status character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.meetings OWNER TO postgres;

--
-- Name: meetings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.meetings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.meetings_id_seq OWNER TO postgres;

--
-- Name: meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.meetings_id_seq OWNED BY public.meetings.id;


--
-- Name: message_group_recipients; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_group_recipients (
    id integer NOT NULL,
    message_id integer NOT NULL,
    user_id integer NOT NULL,
    is_read boolean DEFAULT false NOT NULL
);


ALTER TABLE public.message_group_recipients OWNER TO postgres;

--
-- Name: message_group_recipients_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.message_group_recipients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_group_recipients_id_seq OWNER TO postgres;

--
-- Name: message_group_recipients_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.message_group_recipients_id_seq OWNED BY public.message_group_recipients.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    sender_id integer NOT NULL,
    receiver_id integer,
    group_id integer,
    is_group_broadcast boolean DEFAULT false NOT NULL,
    collector_group_label character varying,
    content text NOT NULL,
    parent_id integer,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_id_seq OWNER TO postgres;

--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id integer NOT NULL,
    user_id integer,
    type character varying,
    title character varying,
    body text,
    from_user_name character varying,
    post_id integer,
    comment_id integer,
    is_read boolean,
    created_at timestamp without time zone,
    sender_id integer,
    source_notification_id integer
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: otp_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.otp_codes (
    id integer NOT NULL,
    identifier character varying,
    code character varying,
    purpose character varying,
    created_at timestamp without time zone,
    expires_at timestamp without time zone,
    is_used boolean
);


ALTER TABLE public.otp_codes OWNER TO postgres;

--
-- Name: otp_codes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.otp_codes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.otp_codes_id_seq OWNER TO postgres;

--
-- Name: otp_codes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.otp_codes_id_seq OWNED BY public.otp_codes.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    user_id integer,
    user_name character varying,
    user_avatar_url character varying,
    image_url character varying,
    description text,
    created_at timestamp without time zone,
    likes_count integer,
    status character varying DEFAULT 'pending_review'::character varying NOT NULL,
    moderation_score double precision NOT NULL,
    moderation_reason character varying,
    moderation_details text,
    moderated_at timestamp without time zone,
    moderation_model_version character varying
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.posts_id_seq OWNER TO postgres;

--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: quiz_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quiz_submissions (
    id integer NOT NULL,
    quiz_id integer,
    student_id integer,
    student_name character varying,
    answers_json text,
    score double precision,
    max_score double precision,
    feedback_json text,
    ai_graded boolean,
    submitted_at timestamp without time zone,
    graded_at timestamp without time zone
);


ALTER TABLE public.quiz_submissions OWNER TO postgres;

--
-- Name: quiz_submissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quiz_submissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quiz_submissions_id_seq OWNER TO postgres;

--
-- Name: quiz_submissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quiz_submissions_id_seq OWNED BY public.quiz_submissions.id;


--
-- Name: quizzes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quizzes (
    id integer NOT NULL,
    educator_id integer,
    title character varying NOT NULL,
    description text,
    pdf_filename character varying NOT NULL,
    questions_json text,
    answer_key_json text,
    total_questions integer,
    status character varying,
    error_message text,
    created_at timestamp without time zone
);


ALTER TABLE public.quizzes OWNER TO postgres;

--
-- Name: quizzes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.quizzes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.quizzes_id_seq OWNER TO postgres;

--
-- Name: quizzes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.quizzes_id_seq OWNED BY public.quizzes.id;


--
-- Name: saved_posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.saved_posts (
    id integer NOT NULL,
    user_id integer,
    post_id integer,
    saved_at timestamp without time zone
);


ALTER TABLE public.saved_posts OWNER TO postgres;

--
-- Name: saved_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.saved_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.saved_posts_id_seq OWNER TO postgres;

--
-- Name: saved_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.saved_posts_id_seq OWNED BY public.saved_posts.id;


--
-- Name: smart_bins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.smart_bins (
    id integer NOT NULL,
    bin_code character varying NOT NULL,
    collection_point_id integer,
    bin_type character varying,
    capacity_kg double precision,
    status character varying,
    location_note character varying,
    created_at timestamp without time zone
);


ALTER TABLE public.smart_bins OWNER TO postgres;

--
-- Name: smart_bins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.smart_bins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.smart_bins_id_seq OWNER TO postgres;

--
-- Name: smart_bins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.smart_bins_id_seq OWNED BY public.smart_bins.id;


--
-- Name: testimonials; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testimonials (
    id integer NOT NULL,
    user_id integer,
    user_name character varying NOT NULL,
    user_avatar_url character varying,
    content text NOT NULL,
    rating integer,
    is_approved boolean,
    is_featured boolean,
    created_at timestamp without time zone
);


ALTER TABLE public.testimonials OWNER TO postgres;

--
-- Name: testimonials_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.testimonials_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.testimonials_id_seq OWNER TO postgres;

--
-- Name: testimonials_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.testimonials_id_seq OWNED BY public.testimonials.id;


--
-- Name: user_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_rewards (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reward_key character varying NOT NULL,
    reward_type character varying DEFAULT 'badge'::character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    icon character varying,
    unlocked_at timestamp without time zone DEFAULT now() NOT NULL,
    notified boolean DEFAULT false NOT NULL
);


ALTER TABLE public.user_rewards OWNER TO postgres;

--
-- Name: user_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_rewards_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_rewards_id_seq OWNER TO postgres;

--
-- Name: user_rewards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_rewards_id_seq OWNED BY public.user_rewards.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying,
    full_name character varying,
    hashed_password character varying,
    is_active boolean,
    is_verified boolean,
    role character varying,
    google_id character varying,
    facebook_id character varying,
    qr_code character varying NOT NULL,
    reset_token character varying,
    token_expires character varying,
    avatar_url character varying,
    global_score double precision,
    created_at timestamp without time zone,
    fcm_token character varying,
    mfa_enabled boolean DEFAULT false NOT NULL,
    mfa_secret character varying
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: video_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.video_categories (
    id integer NOT NULL,
    title character varying NOT NULL,
    description text,
    cover_image_url character varying,
    educator_id integer,
    created_at timestamp without time zone
);


ALTER TABLE public.video_categories OWNER TO postgres;

--
-- Name: video_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.video_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.video_categories_id_seq OWNER TO postgres;

--
-- Name: video_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.video_categories_id_seq OWNED BY public.video_categories.id;


--
-- Name: bin_scans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bin_scans ALTER COLUMN id SET DEFAULT nextval('public.bin_scans_id_seq'::regclass);


--
-- Name: center_proposals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.center_proposals ALTER COLUMN id SET DEFAULT nextval('public.center_proposals_id_seq'::regclass);


--
-- Name: citizen_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_groups ALTER COLUMN id SET DEFAULT nextval('public.citizen_groups_id_seq'::regclass);


--
-- Name: citizen_reports id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_reports ALTER COLUMN id SET DEFAULT nextval('public.citizen_reports_id_seq'::regclass);


--
-- Name: collection_points id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_points ALTER COLUMN id SET DEFAULT nextval('public.collection_points_id_seq'::regclass);


--
-- Name: collection_routes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_routes ALTER COLUMN id SET DEFAULT nextval('public.collection_routes_id_seq'::regclass);


--
-- Name: collector_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_logs ALTER COLUMN id SET DEFAULT nextval('public.collector_logs_id_seq'::regclass);


--
-- Name: collector_zone_assignments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments ALTER COLUMN id SET DEFAULT nextval('public.collector_zone_assignments_id_seq'::regclass);


--
-- Name: collector_zones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zones ALTER COLUMN id SET DEFAULT nextval('public.collector_zones_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: custom_actor_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_actor_groups ALTER COLUMN id SET DEFAULT nextval('public.custom_actor_groups_id_seq'::regclass);


--
-- Name: educator_videos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.educator_videos ALTER COLUMN id SET DEFAULT nextval('public.educator_videos_id_seq'::regclass);


--
-- Name: group_members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members ALTER COLUMN id SET DEFAULT nextval('public.group_members_id_seq'::regclass);


--
-- Name: likes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes ALTER COLUMN id SET DEFAULT nextval('public.likes_id_seq'::regclass);


--
-- Name: local_instructions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.local_instructions ALTER COLUMN id SET DEFAULT nextval('public.local_instructions_id_seq'::regclass);


--
-- Name: meeting_participants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_participants ALTER COLUMN id SET DEFAULT nextval('public.meeting_participants_id_seq'::regclass);


--
-- Name: meetings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetings ALTER COLUMN id SET DEFAULT nextval('public.meetings_id_seq'::regclass);


--
-- Name: message_group_recipients id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_recipients ALTER COLUMN id SET DEFAULT nextval('public.message_group_recipients_id_seq'::regclass);


--
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: otp_codes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otp_codes ALTER COLUMN id SET DEFAULT nextval('public.otp_codes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: quiz_submissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_submissions ALTER COLUMN id SET DEFAULT nextval('public.quiz_submissions_id_seq'::regclass);


--
-- Name: quizzes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes ALTER COLUMN id SET DEFAULT nextval('public.quizzes_id_seq'::regclass);


--
-- Name: saved_posts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_posts ALTER COLUMN id SET DEFAULT nextval('public.saved_posts_id_seq'::regclass);


--
-- Name: smart_bins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smart_bins ALTER COLUMN id SET DEFAULT nextval('public.smart_bins_id_seq'::regclass);


--
-- Name: testimonials id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials ALTER COLUMN id SET DEFAULT nextval('public.testimonials_id_seq'::regclass);


--
-- Name: user_rewards id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rewards ALTER COLUMN id SET DEFAULT nextval('public.user_rewards_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: video_categories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_categories ALTER COLUMN id SET DEFAULT nextval('public.video_categories_id_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alembic_version (version_num) FROM stdin;
0014_merge_levels
\.


--
-- Data for Name: bin_scans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bin_scans (id, user_id, qr_code, bin_id, waste_type, weight_kg, points_earned, score_before, score_after, firebase_synced, scanned_at, smart_bin_id) FROM stdin;
5	16	TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4	BIN-TEST-001	plastique	\N	10	17	27	t	2026-04-30 22:29:21.906483	\N
2	12	TRIDECHET-dc152079-f1a7-4fb3-8ca1-c83466e5c91e	BIN-TEST-001	plastique	\N	10	6	16	t	2026-04-30 22:21:49.304455	\N
4	15	TRIDECHET-fa9eccc1-b57f-4b65-b3fc-6cca4297a9b9	BIN-TEST-001	plastique	\N	10	0	10	t	2026-04-30 22:27:10.104178	\N
6	17	TRIDECHET-f21fe0d2-9511-4f1e-9b3f-8aee914e698b	BIN-TEST-001	plastique	\N	10	0	10	t	2026-04-30 22:55:46.450334	\N
7	22	TRIDECHET-c193d30d-1236-41c2-bff9-b494ba5fe198	BIN-TEST-001	plastique	\N	10	0	10	t	2026-05-01 20:52:40.875395	\N
8	23	TRIDECHET-07caff6d-635b-4261-9020-cb63e06b6a0e	BIN-TEST-001	plastique	\N	10	0	10	t	2026-05-02 13:21:16.056582	\N
9	16	TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4	BIN-PLASTIQUE-001	plastique	\N	13	164	177	t	2026-07-11 17:50:00	1
10	16	TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4	BIN-PLASTIQUE-001	plastique	\N	137	0	137	t	2026-04-28 12:00:00	1
11	16	TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4	BIN-PLASTIQUE-001	plastique	\N	59	177	236	t	2026-07-11 20:20:00	1
3	14	TRIDECHET-b45ad1d3-6c7f-42fe-9118-3f28d0789363	BIN-TEST-001	plastique	\N	10	0	10	t	2026-04-30 22:25:08.579276	\N
\.


--
-- Data for Name: center_proposals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.center_proposals (id, user_id, user_name, name, address, lat, lng, waste_types, description, status, created_at) FROM stdin;
2	16	Amine T.	xcfv	ccc	\N	\N	Papier,Plastique,Verre	cccccccccccccc	rejected	2026-04-08 20:34:51.679875
3	24	Test Diag	Point Tunis	Avenue Plastine	\N	\N	Plastique,Verre		pending	2026-04-08 22:02:42.472784
1	16	Amine T.	lac	avenue la liberté	\N	\N	Métal	bbbj	rejected	2026-04-08 00:41:56.247067
4	31	Backend Tester Updated	Test	Tunis	\N	\N		Test	approved	2026-05-19 23:55:49.217678
5	12	ahmed	centre	Avenue hbib thameur	\N	\N	Électronique,Verre,Papier,Métal	des déchets oar tous et des odeurs incroyable	approved	2026-07-26 12:39:29.811223
6	16	Amine T.	lac1	avenue saint Paul	\N	\N	Plastique		pending	2026-08-19 09:41:46.06621
7	25	Chayma Tlatli	lac1	Avenue de la liberté	\N	\N	Plastique		pending	2026-08-23 15:51:54.89668
8	12	ahmed	centre global	Avenue la liberté	\N	\N	Plastique,Organique		pending	2026-08-31 14:18:21.85394
\.


--
-- Data for Name: citizen_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citizen_groups (id, educator_id, name, description, color, created_at) FROM stdin;
1	2	Groupe 1	hj	#00C896	2026-05-08 01:03:33.653431
2	2	1		#0984E3	2026-05-08 01:04:26.807797
3	31	Test Group	Test	#00C896	2026-05-19 23:54:42.159639
4	2	groupe a		#E17055	2026-08-19 20:54:05.036553
5	2	dd		#00C896	2026-08-19 21:01:25.210357
6	2	girls		#FD79A8	2026-08-25 22:30:30.981439
7	2	boys		#00C896	2026-09-04 08:30:55.816373
\.


--
-- Data for Name: citizen_reports; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.citizen_reports (id, collection_point_id, user_id, report_type, description, photo_url, status, assigned_to, resolution_note, resolved_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: collection_points; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_points (id, name, lat, lng, is_verified, types, address, hours, status, load_level, created_at) FROM stdin;
3	La Marsa	36.8782	10.3247	t	plastique,verre,compost	Rue du Lac, La Marsa	9h-17h	maintenance	0	2026-04-08 21:48:25.717914
5	Ben Arous	36.7256	10.2164	t	plastique,verre,batteries,electronique	Zone industrielle, Ben Arous	7h-19h	disponible	0.72	2026-04-08 21:48:25.717914
6	Manouba	36.8094	10.0971	t	plastique,verre	Centre ville, Manouba	8h-17h	disponible	0.3	2026-04-08 21:48:25.717914
7	Carthage	36.8528	10.3306	t	plastique,verre,papier,compost	Rue Hannibal, Carthage	8h-18h	disponible	0.55	2026-04-08 21:48:25.717914
9	Sidi Bou Said	36.8687	10.3414	t	plastique,verre,compost	Village de Sidi Bou Said	9h-16h	disponible	0.2	2026-04-08 21:48:25.717914
12	ma city	36.467398	10.7430665	f	Verre, Papier, Carton, Métal	Rue el Fell, Dar Chaâbane El Fehri		disponible	0	2026-05-06 22:05:15.302508
8	Lac 1	36.8325	10.2336	f	plastique,batteries	Les Berges du Lac, Tunis	9h-20h	saturé	0.98	2026-04-08 21:48:25.717914
16	point2	36.4694834	10.7521616	f	{"disponible":["Général","Vêtements","Compost","Plastique"],"sature":["Batteries","Électronique","Papier"],"maintenance":["Métal","Carton"]}	Av. de la République, Dar Chaabane Al Fehri 8011, Dar Chaâbane El Fehri		disponible	0	2026-05-10 14:08:01.509452
4	Bardo	36.8189	10.1658	t	plastique,papier	Avenue du Bardo, Le Bardo	8h-16h	disponible	0.45	2026-04-08 21:48:25.717914
14	HopitalNabeulTri	36.4660889	10.7064218	f	{"disponible":["Verre","Papier","Carton"],"sature":["Métal","Électronique","Batteries"],"maintenance":["Général","Vêtements"]}	Bir Challouf, Délégation Nabeul, Gouvernorat Nabeul, 8000, Tunisie		disponible	0	2026-05-08 19:24:33.190334
13	NBtri	36.45036619169526	10.73365544336843	f	{"disponible":["Plastique","Verre","Carton","Métal","Papier"],"sature":["Électronique","Batteries"],"maintenance":["Général","Vêtements","Compost"]}	La Jarre, Nabeul	8-22	maintenance	0	2026-05-06 23:02:47.812279
15	Nabeul Centre	36.4541286	10.7326251	f	{"disponible":["Plastique","Général","Métal","Électronique","Batteries"],"sature":[],"maintenance":[]}	Rue Marbella, Médina		maintenance	0	2026-05-09 20:10:35.545947
18	ch	36.4652735	10.720251	f	{"disponible":["Papier"],"sature":[],"maintenance":[]}	Ennour, Délégation Nabeul, Gouvernorat Nabeul, 8000, Tunisie		saturé	0	2026-08-20 05:00:57.675414
19	cc	36.4541475	10.7326137	f	{"disponible":["Papier","Électronique","Compost","Batteries","Métal","Verre","Carton","Plastique"],"sature":[],"maintenance":[]}	Rue Marbella, Médina		disponible	0	2026-08-20 10:47:54.497178
17	cr	36.8977674	10.190151	t	{"disponible":["Plastique","Verre"],"sature":[],"maintenance":[]}	Rue de Newton	22	disponible	0	2026-06-10 11:42:38.253175
\.


--
-- Data for Name: collection_routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collection_routes (id, collector_id, date_planned, status, point_ids, notes, total_weight_kg, completed_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: collector_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collector_logs (id, collector_id, smart_bin_id, bin_code, bin_type, weight_before_kg, notified, collected_at) FROM stdin;
\.


--
-- Data for Name: collector_zone_assignments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collector_zone_assignments (id, zone_id, collector_id, assigned_by, mission_message, priority, status, due_date, assigned_at, completed_at, collector_notes, collection_point_id, group_id, collection_point_ids, target_label) FROM stdin;
1	1	21	5	urgent	urgent	pending	\N	2026-06-29 23:26:48.90091	\N	\N	\N	\N	\N	\N
2	1	21	5		normal	pending	\N	2026-06-30 00:04:22.427142	\N	\N	\N	\N	\N	\N
3	1	21	5		normal	pending	\N	2026-07-06 21:47:41.541865	\N	\N	\N	\N	\N	\N
5	\N	11	5		normal	pending	\N	2026-07-07 00:39:42.008151	\N	\N	\N	\N	[14]	HopitalNabeulTri
6	\N	21	5	hii	normal	pending	\N	2026-07-07 00:44:38.392149	\N	\N	\N	\N	[7]	Carthage
4	\N	21	5		urgent	pending	\N	2026-07-07 00:39:30.449766	\N	\N	\N	\N	[5]	Ben Arous
7	1	21	5	hi	normal	pending	\N	2026-07-08 20:22:56.018022	\N	\N	\N	\N	\N	tunis
8	1	21	5	hi	normal	pending	\N	2026-07-08 22:55:28.805829	\N	\N	\N	\N	\N	tunis
9	\N	4	5	hi	normal	pending	\N	2026-07-08 23:06:07.074856	\N	\N	\N	\N	[14]	HopitalNabeulTri
10	\N	4	5		normal	pending	\N	2026-07-09 23:14:03.721866	\N	\N	\N	\N	[8]	Lac 1
11	\N	21	5		normal	pending	\N	2026-07-09 23:14:22.350133	\N	\N	\N	\N	[9]	Sidi Bou Said
12	5	4	5		normal	pending	\N	2026-08-20 04:51:07.577373	\N	\N	\N	\N	\N	nabeul
13	\N	11	5		urgent	pending	\N	2026-08-20 05:50:20.514585	\N	\N	\N	\N	[4]	Bardo
\.


--
-- Data for Name: collector_zones; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.collector_zones (id, name, territory, description, color_hex, created_by, created_at, updated_at) FROM stdin;
1	tunis	bardo		#4CAF50	5	2026-06-29 22:19:08.491832	2026-06-29 22:19:08.491832
5	nabeul	hh	\N	#2196f3	5	2026-08-20 04:50:45.32509	2026-08-20 04:50:45.32509
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (id, post_id, user_id, user_name, user_avatar_url, content, parent_id, created_at) FROM stdin;
1	3	16	Amine T.		gfhjhkjl	\N	2026-03-25 21:11:10.784182
3	3	16	Amine T.		dffff	\N	2026-03-30 20:21:40.135216
4	4	29	ddd		cc	\N	2026-03-30 21:21:57.019836
5	4	29	ddd		ccc	\N	2026-03-30 21:23:39.098804
6	4	29	ddd		ddd	\N	2026-03-30 21:24:09.644412
7	4	24	Test Diag		vvvv	\N	2026-04-01 18:46:43.199778
8	6	16	Amine T.		hi	\N	2026-04-01 19:33:14.54317
9	4	16	Amine T.		oki	7	2026-04-01 19:52:41.742826
10	4	16	Amine T.		n,;:	4	2026-04-02 22:15:54.508726
11	6	16	Amine T.		hello test	\N	2026-04-07 23:25:56.261029
12	5	16	Amine T.		Good Morning	\N	2026-04-08 20:33:37.149292
13	57	12	ahmed		bonjour amine	\N	2026-06-14 15:08:30.533181
14	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:36.560736
15	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:36.732846
16	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:36.883764
17	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:37.04473
18	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:37.194122
19	57	12	ahmed		bonjour amine	\N	2026-06-14 15:09:37.34503
20	66	12	ahmed		hi	\N	2026-06-14 15:09:53.94115
21	70	12	ahmed		hello	\N	2026-06-14 15:10:12.369803
22	70	12	ahmed		hi	\N	2026-06-14 15:10:32.5442
24	74	16	Amine T.		hii	\N	2026-06-15 14:19:02.660551
25	72	16	Amine T.		hi ahmed	\N	2026-06-16 20:58:48.546606
26	72	16	Amine T.		hello	\N	2026-06-16 21:18:11.810779
27	72	16	Amine T.		hi hi	\N	2026-06-16 21:18:28.450263
28	74	12	ahmed	\N	Super initiative ! Tu as raison, chacun doit faire sa part pour un environnement plus propre. Bravo ! 💚	\N	2026-06-16 22:59:59.827403
33	72	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	hi	\N	2026-08-20 06:04:49.376238
23	\N	12	ahmed		c'est quoi ca ?	\N	2026-06-14 19:30:00.545135
34	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	bonjour 	\N	2026-08-20 07:13:46.215014
35	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	hi	\N	2026-08-20 07:14:42.552911
36	72	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	hi	\N	2026-08-21 22:33:01.012564
37	91	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	hi	\N	2026-08-21 22:58:05.939864
38	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	bonjour mon ami	\N	2026-08-27 14:28:38.889191
39	72	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	hii	\N	2026-08-27 14:46:20.675154
40	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	hi	\N	2026-08-27 15:00:30.889163
41	66	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	bonjour ahmed	20	2026-08-30 10:29:40.356285
42	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	hi	\N	2026-08-30 10:47:41.045998
43	91	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	bonjour 	\N	2026-08-30 10:47:50.531905
44	72	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	hi	\N	2026-08-30 12:49:45.631451
45	57	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	bonjour amine 	\N	2026-08-30 16:24:42.122835
46	53	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	hi ahmed 	\N	2026-08-30 17:36:33.155918
47	74	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	bonjour 	\N	2026-08-30 19:37:53.599453
\.


--
-- Data for Name: custom_actor_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.custom_actor_groups (id, name, description, member_ids, created_by, created_at) FROM stdin;
1	collecteur	secteur Tunis	[11, 4, 21]	5	2026-06-29 22:17:20.65476
\.


--
-- Data for Name: educator_videos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.educator_videos (id, educator_id, educator_name, title, description, video_url, thumbnail_url, duration, category_id, created_at) FROM stdin;
1	2	Educateur Test	facteur ecologiquue	\N	https://www.youtube.com/watch?v=8-b_T7y7klQ&list=PLAGFiOoRe1nNbmtP5JnXWY9Ucqy7payCZ	https://img.youtube.com/vi/8-b_T7y7klQ/maxresdefault.jpg	\N	\N	2026-04-27 11:42:46.150198
6	2	Educateur Test	Messenger_creation_D3AAC7BA-C6E0-47CC-BF61-510DFE3AA8CB	\N	/uploads/videos/edu_video_288386884c904ffc96f2081e2265c591.mp4	\N	\N	\N	2026-08-19 20:53:30.981173
\.


--
-- Data for Name: group_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.group_members (id, group_id, user_id, added_at) FROM stdin;
1	1	16	2026-05-08 01:03:44.954322
2	1	12	2026-05-08 01:03:46.380885
3	1	22	2026-05-08 01:03:47.542028
4	1	25	2026-05-08 01:03:49.149423
5	4	12	2026-08-19 20:54:47.784924
6	5	22	2026-08-19 21:45:09.959674
7	5	16	2026-08-19 21:45:10.488081
8	5	23	2026-08-19 21:45:11.528645
9	5	30	2026-08-19 21:45:12.536347
10	5	25	2026-08-19 21:45:13.423246
11	5	39	2026-08-19 21:45:16.910967
12	6	30	2026-08-25 22:30:39.126645
13	6	23	2026-08-25 22:30:41.8453
14	6	22	2026-08-25 22:30:43.923197
15	6	25	2026-08-25 22:30:45.078407
16	6	15	2026-08-25 22:30:46.73779
17	6	26	2026-08-25 22:30:48.727459
18	6	29	2026-08-25 22:30:49.571816
19	7	42	2026-09-04 08:30:59.064066
20	7	12	2026-09-04 08:31:00.731047
21	7	16	2026-09-04 08:31:06.90044
22	6	43	2026-09-04 08:33:06.35646
\.


--
-- Data for Name: likes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.likes (id, user_id, post_id, created_at) FROM stdin;
3	24	\N	2026-03-04 21:30:25.266809
4	24	\N	2026-03-04 21:30:49.953703
5	24	\N	2026-03-04 21:32:29.808483
6	16	3	2026-03-30 18:39:03.858375
7	16	4	2026-04-01 18:38:40.199155
8	24	4	2026-04-01 18:46:16.46502
9	24	6	2026-04-01 19:32:22.560293
10	16	6	2026-04-01 19:34:09.468113
11	16	5	2026-04-08 20:33:25.189815
14	12	57	2026-06-14 15:09:37.535991
15	12	70	2026-06-14 15:10:18.477642
17	12	72	2026-06-14 19:31:51.163589
20	16	74	2026-06-15 14:18:52.214893
21	24	\N	2026-06-18 19:01:29.433419
22	24	\N	2026-06-18 19:21:07.63735
23	24	\N	2026-06-18 20:50:53.15752
24	24	\N	2026-06-29 22:56:21.64599
16	12	\N	2026-06-14 19:30:06.285693
26	12	91	2026-08-20 07:14:49.359265
27	25	92	2026-08-21 22:32:39.991299
28	25	91	2026-08-23 15:52:45.971639
29	25	66	2026-08-23 15:52:51.161245
30	25	3	2026-08-23 16:13:09.95935
31	16	66	2026-08-30 10:29:48.51128
32	16	72	2026-08-30 12:49:54.322112
33	25	74	2026-08-30 19:37:59.315995
34	43	88	2026-09-02 10:40:04.260318
\.


--
-- Data for Name: local_instructions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.local_instructions (id, territory, city, waste_type, title, instruction, is_active, created_by, created_at, updated_at) FROM stdin;
1	Ariana	\N	Organique	ghjurg	nn'	t	5	2026-08-19 22:48:32.825539	2026-08-19 22:48:32.825539
\.


--
-- Data for Name: meeting_participants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meeting_participants (id, meeting_id, user_id, user_name, status) FROM stdin;
1	1	24	Test Diag	invited
2	1	25	Chayma Tlatli	invited
3	1	26	chourouk	invited
4	1	27	motaz	invited
5	1	28	ddd	invited
6	1	29	ddd	invited
7	1	12	ahmed	invited
8	1	14	doua	invited
9	1	15	chourouk	invited
10	1	16	Amine T.	invited
11	1	17	nono	invited
12	1	22	asma	invited
13	1	23	amel ben saleh	invited
14	2	25	Chayma Tlatli	invited
15	2	12	ahmed	invited
16	2	16	Amine T.	invited
17	2	22	asma	invited
18	3	24	Test Diag	invited
19	3	25	Chayma Tlatli	invited
20	3	26	chourouk	invited
21	3	27	motaz	invited
22	3	28	ddd	invited
23	3	29	ddd	invited
24	3	12	ahmed	invited
25	3	14	doua	invited
26	3	15	chourouk	invited
27	3	16	Amine T.	invited
28	3	17	nono	invited
29	3	22	asma	invited
30	3	23	amel ben saleh	invited
31	3	30	aida	invited
32	4	24	Test Diag	invited
33	4	25	Chayma Tlatli	invited
34	4	26	chourouk	invited
35	4	27	motaz	invited
36	4	28	ddd	invited
37	4	29	ddd	invited
38	4	12	ahmed	invited
39	4	14	doua	invited
40	4	15	chourouk	invited
41	4	16	Amine T.	invited
42	4	17	nono	invited
43	4	22	asma	invited
44	4	23	amel ben saleh	invited
45	4	30	aida	invited
46	5	22	asma	invited
47	5	25	Chayma Tlatli	invited
48	5	16	Amine T.	invited
49	5	12	ahmed	invited
50	6	12	ahmed	invited
51	7	43	Chayma	invited
52	7	26	chourouk	invited
53	7	29	ddd	invited
54	7	15	chourouk	invited
55	7	22	asma	invited
56	7	30	aida	invited
57	7	23	amel ben saleh	invited
58	7	25	Chayma Tlatli	invited
59	8	43	Chayma	invited
60	8	39	Om Mbarek	invited
61	8	42	abc	invited
62	8	40	omar mbarek	invited
63	8	44	rihem	invited
64	8	26	chourouk	invited
65	8	27	motaz	invited
66	8	28	ddd	invited
67	8	29	ddd	invited
68	8	14	doua	invited
69	8	15	chourouk	invited
70	8	17	nono	invited
71	8	22	asma	invited
72	8	30	aida	invited
73	8	37	Utilisateur Normal Test	invited
74	8	23	amel ben saleh	invited
75	8	24	Test Diag	invited
76	8	25	Chayma Tlatli	invited
77	8	45	chichy	invited
78	8	12	ahmed	invited
79	8	16	Amine T.	invited
\.


--
-- Data for Name: meetings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.meetings (id, educator_id, educator_name, title, description, meet_link, scheduled_at, duration_minutes, group_name, audience, status, created_at) FROM stdin;
1	2	Educateur Test	Tri des déchets plastique		https://meet.google.com/gdq-yicq-pos	2026-05-18 10:00:00	60		all	scheduled	2026-05-08 00:16:26.118656
2	2	Educateur Test	wcv	bbbbbb	https://meet.google.com/vzl-mudc-jbw	2026-05-09 10:00:00	30	Groupe 1	group	scheduled	2026-05-08 01:06:40.72311
3	2	Educateur Test	tri	tri	https://meet.google.com/uea-hfof-wwc	2026-05-13 10:00:00	60	1	group	scheduled	2026-05-12 10:04:16.450616
4	31	Backend Tester Updated	Test	Desc	https://meet.google.com/woc-rsfp-xnw	2026-06-01 10:00:00	60		all	scheduled	2026-05-19 23:55:49.610332
5	2	Educateur Test	tri		https://meet.google.com/nys-dvck-eeh	2026-08-20 10:00:00	30	Groupe 1	all	scheduled	2026-08-19 12:37:19.207205
6	2	Educateur Test	Tri sélectif		https://meet.google.com/wtz-rpwg-mwn	2026-08-22 10:00:00	30	groupe a	group	scheduled	2026-08-19 21:46:59.718848
7	2	Educateur Test	tri		https://meet.google.com/ayb-vnez-oau	2026-09-05 10:00:00	30	girls	group	scheduled	2026-09-04 08:33:41.962755
8	2	Educateur Test	tri		https://meet.google.com/fos-ahsf-oiu	2026-09-05 10:00:00	60		all	scheduled	2026-09-04 08:35:15.338041
\.


--
-- Data for Name: message_group_recipients; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_group_recipients (id, message_id, user_id, is_read) FROM stdin;
1	11	11	f
2	11	4	f
3	11	21	f
4	14	4	f
5	27	11	f
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, sender_id, receiver_id, group_id, is_group_broadcast, collector_group_label, content, parent_id, is_read, created_at) FROM stdin;
1	21	3	\N	f	\N	hi	\N	f	2026-07-07 01:25:48.093553
2	5	21	\N	f	\N	hello	\N	f	2026-07-08 20:18:18.063214
3	5	4	\N	f	\N	hello	\N	t	2026-07-08 23:06:26.919711
4	4	5	\N	f	\N	hi cv ?	\N	t	2026-07-09 02:10:08.371072
6	5	21	\N	f	\N	hii	\N	f	2026-07-09 23:13:42.332929
5	5	4	\N	f	\N	hhmd et toi	\N	t	2026-07-09 23:13:15.258966
7	4	5	\N	f	\N	hmd	\N	t	2026-07-10 17:00:59.504519
8	5	4	\N	f	\N	oki	\N	t	2026-07-10 19:17:37.489416
10	1	4	\N	f	\N	bonjour cv	\N	f	2026-07-26 12:43:23.092202
11	1	\N	\N	t	tunis 	vous devez assurer le tri	\N	f	2026-07-26 12:44:26.72122
12	11	3	\N	f	\N	bonjour	\N	f	2026-07-27 19:00:32.566841
13	1	21	\N	f	\N	hi	\N	f	2026-07-31 20:03:33.551692
14	1	\N	\N	t	\N	hi	\N	f	2026-07-31 20:03:48.847639
16	16	1	\N	f	\N	bonjour	\N	t	2026-08-19 10:05:56.023233
17	1	16	\N	f	\N	bonjour	\N	f	2026-08-19 10:07:06.698772
18	1	16	\N	f	\N	cv ?	\N	f	2026-08-19 10:07:13.318574
19	39	2	\N	f	\N	bonjour monsieur	\N	f	2026-08-19 10:27:10.493433
20	12	1	\N	f	\N	hi	\N	f	2026-08-19 12:35:17.244773
21	20	4	\N	f	\N	bonjour	\N	f	2026-08-19 21:51:14.443944
22	20	4	\N	f	\N	hii	\N	f	2026-08-19 22:39:12.970363
24	11	19	\N	f	\N	hi	\N	f	2026-08-19 22:46:24.445893
23	11	5	\N	f	\N	hi	\N	t	2026-08-19 22:46:13.43173
25	5	11	\N	f	\N	hi	\N	f	2026-08-19 22:49:59.532964
26	38	41	\N	f	\N	bonjour adem	\N	f	2026-08-20 06:00:01.409101
27	38	\N	\N	t	\N	bravo Chiraz pour tes efforts	\N	f	2026-08-20 06:00:48.778624
28	25	41	\N	f	\N	Bonjour	\N	f	2026-08-23 15:52:37.437509
29	13	1	\N	f	\N	Hi	\N	f	2026-08-25 22:28:21.010461
9	16	2	\N	f	\N	bonjour monsieur	\N	t	2026-07-15 01:22:51.751705
15	16	2	\N	f	\N	hii	\N	t	2026-07-31 22:04:55.289195
30	2	16	\N	f	\N	Hii	\N	f	2026-08-25 22:31:37.345445
31	12	1	\N	f	\N	Hello	\N	f	2026-08-27 14:29:01.253358
32	25	1	\N	f	\N	Bonjour	\N	f	2026-08-30 19:38:15.190678
33	16	1	\N	f	\N	Bonjour	\N	f	2026-08-31 14:23:25.28938
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, user_id, type, title, body, from_user_name, post_id, comment_id, is_read, created_at, sender_id, source_notification_id) FROM stdin;
1	16	comment	Nouveau commentaire	ddd a commente votre publication	ddd	4	\N	t	2026-03-30 21:21:57.051032	\N	\N
2	16	comment	Nouveau commentaire	ddd a commente votre publication	ddd	4	\N	t	2026-03-30 21:23:39.122168	\N	\N
3	16	save	Publication sauvegardee	ddd a sauvegarde votre publication	ddd	4	\N	t	2026-03-30 21:24:01.987832	\N	\N
4	16	comment	Nouveau commentaire	ddd a commente votre publication	ddd	4	\N	t	2026-03-30 21:24:09.657718	\N	\N
5	16	like	Nouveau j'aime	Test Diag a aime votre publication	Test Diag	4	\N	t	2026-04-01 18:46:16.471948	\N	\N
6	16	comment	Nouveau commentaire	Test Diag a commente votre publication	Test Diag	4	\N	t	2026-04-01 18:46:31.053502	\N	\N
7	16	comment	Nouveau commentaire	Test Diag a commente votre publication	Test Diag	4	\N	t	2026-04-01 18:46:43.209466	\N	\N
8	23	save	Publication sauvegardee	Test Diag a sauvegarde votre publication	Test Diag	3	\N	f	2026-04-01 18:46:59.947775	\N	\N
9	24	comment	Nouveau commentaire	Amine T. a commente votre publication	Amine T.	6	\N	f	2026-04-01 19:33:14.55979	\N	\N
10	24	like	Nouveau j'aime	Amine T. a aime votre publication	Amine T.	6	\N	f	2026-04-01 19:34:09.473219	\N	\N
11	24	comment	Réponse à votre commentaire	Amine T. a répondu à votre commentaire	Amine T.	4	\N	f	2026-04-01 19:52:41.762624	\N	\N
12	29	comment	Réponse à votre commentaire	Amine T. a répondu à votre commentaire	Amine T.	4	10	f	2026-04-02 22:15:54.52575	\N	\N
13	24	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	6	11	f	2026-04-07 23:25:56.275333	\N	\N
14	24	like	Nouveau j'aime	Amine T. a aime votre publication	Amine T.	5	\N	f	2026-04-08 20:33:25.213684	\N	\N
15	24	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	5	12	f	2026-04-08 20:33:37.17178	\N	\N
16	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	8	\N	f	2026-04-15 23:25:04.601416	\N	\N
17	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	9	\N	f	2026-04-15 23:26:01.002978	\N	\N
18	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	10	\N	t	2026-04-15 23:26:42.914496	\N	\N
19	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	11	\N	t	2026-04-15 23:34:49.274074	\N	\N
20	16	moderation	❌ Publication refusée	Votre publication a été refusée: Contenu ne respectant pas les règles	Administration EcoRewind	9	\N	t	2026-04-16 00:13:52.768832	\N	\N
21	16	moderation	❌ Publication refusée	Votre publication a été refusée: Contenu ne respectant pas les règles	Administration EcoRewind	11	\N	t	2026-04-16 00:14:02.014108	\N	\N
22	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	20	\N	f	2026-04-20 00:25:30.814991	\N	\N
23	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	21	\N	f	2026-04-20 00:26:41.47671	\N	\N
24	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	22	\N	f	2026-04-20 10:47:26.873226	\N	\N
25	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	23	\N	f	2026-04-20 10:50:47.429027	\N	\N
26	16	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	24	\N	f	2026-04-20 11:41:41.519489	\N	\N
27	16	moderation	❌ Publication refusée	Votre publication a été refusée: Contenu ne respectant pas les règles	Administration EcoRewind	22	\N	f	2026-04-20 11:45:10.447105	\N	\N
28	16	moderation	❌ Publication refusée	Votre publication a été refusée par l'administrateur : Contenu ne respectant pas les règles	Administration EcoRewind	8	\N	f	2026-04-20 12:29:18.048369	\N	\N
29	16	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	19	\N	f	2026-04-22 11:32:30.979661	\N	\N
30	16	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	19	\N	f	2026-04-22 11:33:34.082462	\N	\N
31	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	25	\N	f	2026-04-22 13:39:17.103053	\N	\N
32	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	26	\N	f	2026-04-22 13:40:40.220166	\N	\N
33	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	27	\N	f	2026-04-22 13:41:13.401304	\N	\N
34	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	28	\N	f	2026-04-22 13:42:29.99162	\N	\N
35	25	moderation	✅ Publication approuvée	Votre publication a été validée.	Administration EcoRewind	28	\N	f	2026-04-22 13:47:35.173392	\N	\N
36	25	moderation	✅ Publication approuvée	Votre publication a été validée.	Administration EcoRewind	26	\N	f	2026-04-22 13:47:46.528461	\N	\N
37	25	moderation	✅ Publication approuvée	Votre publication a été validée.	Administration EcoRewind	27	\N	f	2026-04-22 13:47:53.095442	\N	\N
38	25	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	29	\N	f	2026-04-22 13:49:12.675081	\N	\N
39	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	30	\N	f	2026-04-22 13:50:02.13505	\N	\N
40	25	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	31	\N	f	2026-04-22 13:50:49.451895	\N	\N
41	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	32	\N	f	2026-04-22 13:51:18.35525	\N	\N
42	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	33	\N	f	2026-04-22 14:06:14.081858	\N	\N
43	25	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	34	\N	f	2026-04-22 14:41:59.527935	\N	\N
44	25	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	36	\N	f	2026-04-22 14:43:59.000823	\N	\N
45	25	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	38	\N	f	2026-04-22 15:30:20.849377	\N	\N
46	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	40	\N	f	2026-04-22 19:57:42.526613	\N	\N
47	16	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	45	\N	f	2026-04-23 21:47:20.153691	\N	\N
48	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	48	\N	f	2026-04-23 22:00:58.258637	\N	\N
49	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	49	\N	f	2026-04-26 22:55:28.141104	\N	\N
50	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	50	\N	f	2026-04-26 22:55:46.228404	\N	\N
51	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	51	\N	f	2026-04-26 22:56:25.40897	\N	\N
52	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	52	\N	f	2026-04-26 22:56:46.358408	\N	\N
53	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	54	\N	f	2026-04-27 19:24:55.538434	\N	\N
54	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	55	\N	f	2026-04-27 19:25:42.218361	\N	\N
55	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	59	\N	f	2026-05-07 18:45:06.049035	\N	\N
56	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	60	\N	f	2026-05-07 18:53:18.345609	\N	\N
57	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	61	\N	f	2026-05-07 19:36:03.456975	\N	\N
58	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	62	\N	f	2026-05-07 19:49:01.158219	\N	\N
59	12	moderation	❌ Publication refusée	Votre publication a été refusée par l'administrateur : Contenu ne respectant pas les règles	Administration EcoRewind	61	\N	f	2026-05-07 19:54:49.480292	\N	\N
60	12	moderation	❌ Publication refusée	Votre publication a été refusée par l'administrateur : Contenu ne respectant pas les règles	Administration EcoRewind	59	\N	f	2026-05-07 19:54:54.923349	\N	\N
61	12	moderation	❌ Publication refusée	Votre publication a été refusée par l'administrateur : Contenu ne respectant pas les règles	Administration EcoRewind	55	\N	f	2026-05-07 19:55:03.389484	\N	\N
62	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	63	\N	f	2026-05-07 20:00:06.612983	\N	\N
63	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	65	\N	f	2026-05-07 20:14:11.4178	\N	\N
64	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	66	\N	f	2026-05-07 20:15:27.255336	\N	\N
65	12	moderation	✅ Publication approuvée	Votre publication a été validée.	Administration EcoRewind	66	\N	f	2026-05-07 20:20:53.267801	\N	\N
66	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	67	\N	f	2026-05-07 20:30:33.990277	\N	\N
67	24	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
68	25	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
69	26	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
70	27	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
71	28	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
72	29	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
73	12	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
74	14	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
75	15	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
76	16	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
77	17	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
78	22	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
79	23	meeting	📅 Nouvelle séance : Tri des déchets plastique	Educateur Test organise une séance le 18/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-08 00:16:26.15323	\N	\N
80	25	meeting	📅 Nouvelle séance : wcv	Educateur Test vous invite à une séance le 09/05/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-05-08 01:06:40.736549	\N	\N
81	12	meeting	📅 Nouvelle séance : wcv	Educateur Test vous invite à une séance le 09/05/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-05-08 01:06:40.736549	\N	\N
82	16	meeting	📅 Nouvelle séance : wcv	Educateur Test vous invite à une séance le 09/05/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-05-08 01:06:40.736549	\N	\N
83	22	meeting	📅 Nouvelle séance : wcv	Educateur Test vous invite à une séance le 09/05/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-05-08 01:06:40.736549	\N	\N
84	12	moderation	❌ Publication refusée	Votre publication a été refusée par l'administrateur : Contenu ne respectant pas les règles	Administration EcoRewind	67	\N	f	2026-05-08 19:22:38.043601	\N	\N
85	24	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
86	25	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
87	26	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
88	27	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
89	28	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
90	29	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
91	12	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
92	14	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
93	15	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
94	16	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
95	17	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
96	22	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
97	23	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
98	30	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 13/05/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-05-12 10:04:16.476646	\N	\N
99	12	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	71	\N	f	2026-05-12 13:15:36.49039	\N	\N
100	24	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
101	25	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
102	26	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
103	27	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
104	28	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
105	29	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
106	12	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
107	14	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
108	15	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
109	16	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
110	17	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
111	22	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
112	23	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
113	30	meeting	📅 Nouvelle séance : Test	Backend Tester Updated vous invite à une séance le 01/06/2026 à 10:00. Durée : 60 min.	Backend Tester Updated	\N	\N	f	2026-05-19 23:55:49.63092	\N	\N
114	25	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	73	\N	f	2026-06-08 19:23:35.756582	\N	\N
115	12	save	Publication sauvegardée	Educateur Test a sauvegardé votre publication	Educateur Test	68	\N	f	2026-06-10 11:55:59.552993	\N	\N
116	12	save	Publication sauvegardée	Educateur Test a sauvegardé votre publication	Educateur Test	68	\N	f	2026-06-10 11:56:05.175765	\N	\N
117	12	like	Nouveau j'aime	Educateur Test a aimé votre publication	Educateur Test	68	\N	f	2026-06-10 11:56:17.80314	\N	\N
118	16	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	74	\N	f	2026-06-14 13:20:16.39891	\N	\N
119	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	13	f	2026-06-14 15:08:30.55786	\N	\N
120	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	14	f	2026-06-14 15:09:36.572426	\N	\N
121	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	15	f	2026-06-14 15:09:36.740885	\N	\N
122	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	16	f	2026-06-14 15:09:36.892388	\N	\N
123	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	17	f	2026-06-14 15:09:37.053682	\N	\N
124	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	18	f	2026-06-14 15:09:37.200863	\N	\N
125	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	19	f	2026-06-14 15:09:37.354596	\N	\N
126	16	like	Nouveau j'aime	ahmed a aimé votre publication	ahmed	57	\N	f	2026-06-14 15:09:37.547673	\N	\N
127	2	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	70	21	f	2026-06-14 15:10:12.379339	\N	\N
128	2	like	Nouveau j'aime	ahmed a aimé votre publication	ahmed	70	\N	f	2026-06-14 15:10:18.48416	\N	\N
129	2	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	70	22	f	2026-06-14 15:10:32.553722	\N	\N
130	16	moderation	✅ Publication approuvée	Votre publication a été validée.	Administration EcoRewind	74	\N	f	2026-06-14 16:46:05.076526	\N	\N
131	16	save	Publication sauvegardée	ahmed a sauvegardé votre publication	ahmed	47	\N	f	2026-06-15 14:14:56.682238	\N	\N
133	12	like	Nouveau j'aime	Amine T. a aimé votre publication	Amine T.	72	\N	f	2026-06-15 14:18:11.403123	\N	\N
134	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	25	f	2026-06-16 20:58:48.561594	\N	\N
135	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	26	f	2026-06-16 21:18:11.817349	\N	\N
136	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	27	f	2026-06-16 21:18:28.45526	\N	\N
132	12	like	Nouveau j'aime	Amine T. a aimé votre publication	Amine T.	72	\N	t	2026-06-15 14:17:56.335117	\N	\N
137	16	comment	Nouveau commentaire	ahmed a commente votre publication	ahmed	74	28	f	2026-06-16 22:59:59.849685	\N	\N
138	24	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	75	\N	f	2026-06-18 19:01:29.333652	\N	\N
139	24	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	78	\N	f	2026-06-18 19:21:07.614732	\N	\N
140	24	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	79	\N	f	2026-06-18 20:50:53.139569	\N	\N
141	16	moderation	⏳ Publication en cours de vérification	Votre publication est en attente de validation par notre équipe de modération. Vous serez notifié dès qu'elle sera traitée.	EcoRewind IA	80	\N	f	2026-06-28 15:42:09.335951	\N	\N
143	11	intercommunality_group_message	mission	vider les centres de tri cr et bardo avant 10h matin	Mairie Test	\N	\N	f	2026-06-29 22:18:26.955665	5	\N
144	21	intercommunality_group_message	mission	vider les centres de tri cr et bardo avant 10h matin	Mairie Test	\N	\N	t	2026-06-29 22:18:26.955665	5	\N
151	21	collector_assignment	[⚠️ MISSION NORMAL] Zone : tunis	Vous avez une nouvelle mission sur tunis.	Mairie Test	\N	\N	f	2026-07-06 21:47:41.549693	5	\N
145	21	collector_assignment	[⚠️ MISSION URGENT] Zone : tunis	urgent	Mairie Test	\N	\N	t	2026-06-29 23:26:48.918275	5	\N
155	21	assignment	[⚠️ MISSION NORMAL] Carthage	hii	Mairie Test	\N	\N	t	2026-07-07 00:44:38.396627	5	\N
150	5	actor_reply	Réponse de Eco-Collecte TN	bonne journée	Eco-Collecte TN	\N	\N	t	2026-07-06 21:40:40.193026	21	149
146	21	collector_assignment	[⚠️ MISSION NORMAL] Zone : tunis	Vous êtes affecté à la zone 'tunis' (bardo).	Mairie Test	\N	\N	t	2026-06-30 00:04:22.448419	5	\N
148	11	intercommunality_group_message	urgent	Bonne journée a tous	Mairie Test	\N	\N	f	2026-07-06 21:38:48.52241	5	\N
149	21	intercommunality_group_message	urgent	Bonne journée a tous	Mairie Test	\N	\N	t	2026-07-06 21:38:48.52241	5	\N
153	11	assignment	[⚠️ MISSION NORMAL] HopitalNabeulTri	Mission : HopitalNabeulTri	Mairie Test	\N	\N	f	2026-07-07 00:39:42.011147	5	\N
154	3	intercommunality_message		hi	Mairie Test	\N	\N	f	2026-07-07 00:40:11.574782	5	\N
156	21	assignment	[⚠️ MISSION NORMAL] Zone : tunis	hi	Mairie Test	\N	\N	f	2026-07-08 20:22:56.02354	5	\N
157	21	assignment	[⚠️ MISSION NORMAL] Zone : tunis	hi	Mairie Test	\N	\N	f	2026-07-08 22:55:28.812822	5	\N
152	21	assignment	[⚠️ MISSION URGENT] Ben Arous	Mission : Ben Arous	Mairie Test	\N	\N	t	2026-07-07 00:39:30.463899	5	\N
147	4	intercommunality_group_message	urgent	Bonne journée a tous	Mairie Test	\N	\N	t	2026-07-06 21:38:48.52241	5	\N
142	4	intercommunality_group_message	mission	vider les centres de tri cr et bardo avant 10h matin	Mairie Test	\N	\N	t	2026-06-29 22:18:26.955665	5	\N
158	4	assignment	[⚠️ MISSION NORMAL] HopitalNabeulTri	hi	Mairie Test	\N	\N	t	2026-07-08 23:06:07.079373	5	\N
160	21	assignment	[⚠️ MISSION NORMAL] Sidi Bou Said	Mission : Sidi Bou Said	Mairie Test	\N	\N	f	2026-07-09 23:14:22.353341	5	\N
159	4	assignment	[⚠️ MISSION NORMAL] Lac 1	Mission : Lac 1	Mairie Test	\N	\N	t	2026-07-09 23:14:03.72789	5	\N
161	12	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	84	\N	f	2026-07-26 12:36:15.864704	\N	\N
162	12	save	Publication sauvegardée	Amine T. a sauvegardé votre publication	Amine T.	72	\N	f	2026-08-19 09:40:48.877881	\N	\N
163	12	save	Publication sauvegardée	Amine T. a sauvegardé votre publication	Amine T.	69	\N	f	2026-08-19 10:05:32.667515	\N	\N
164	16	save	Publication sauvegardée	Om Mbarek a sauvegardé votre publication	Om Mbarek	74	\N	f	2026-08-19 10:25:34.878462	\N	\N
165	2	save	Publication sauvegardée	Om Mbarek a sauvegardé votre publication	Om Mbarek	70	\N	f	2026-08-19 10:25:38.818977	\N	\N
166	39	moderation	✅ Publication approuvée !	Votre publication a été validée et est maintenant visible par la communauté.	EcoRewind IA	88	\N	f	2026-08-19 10:26:40.054869	\N	\N
167	22	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 20/08/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-08-19 12:37:19.236903	\N	\N
168	25	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 20/08/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-08-19 12:37:19.236903	\N	\N
169	16	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 20/08/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-08-19 12:37:19.236903	\N	\N
170	12	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 20/08/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-08-19 12:37:19.236903	\N	\N
171	12	meeting	📅 Nouvelle séance : Tri sélectif	Educateur Test vous invite à une séance le 22/08/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-08-19 21:46:59.73208	\N	\N
172	4	assignment	[⚠️ MISSION NORMAL] Zone : nabeul	Vous êtes affecté à la zone 'nabeul' (hh).	Mairie Test	\N	\N	f	2026-08-20 04:51:07.595384	5	\N
174	3	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
175	4	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
176	11	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
177	13	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
178	31	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
180	21	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	f	2026-08-20 05:00:57.699601	\N	\N
206	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	42	f	2026-08-30 10:47:41.068479	\N	\N
207	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	43	f	2026-08-30 10:47:50.540104	\N	\N
173	1	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	t	2026-08-20 05:00:57.699601	\N	\N
181	11	assignment	[⚠️ MISSION URGENT] Bardo	Mission : Bardo	Mairie Test	\N	\N	f	2026-08-20 05:50:20.523595	5	\N
182	16	moderation	✅ Publication approuvée !	Votre publication a été validée et est maintenant visible par la communauté.	EcoRewind IA	89	\N	f	2026-08-20 05:54:42.029948	\N	\N
183	16	moderation	✅ Publication approuvée !	Votre publication a été validée et est maintenant visible par la communauté.	EcoRewind IA	90	\N	f	2026-08-20 05:55:13.713999	\N	\N
184	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	33	f	2026-08-20 06:04:49.39068	\N	\N
185	16	moderation	✅ Publication approuvée !	Votre publication a été validée et est maintenant visible par la communauté.	EcoRewind IA	91	\N	f	2026-08-20 06:10:25.087592	\N	\N
186	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	34	f	2026-08-20 07:13:46.232079	\N	\N
187	16	like	Nouveau j'aime	ahmed a aimé votre publication	ahmed	91	\N	f	2026-08-20 07:13:51.309478	\N	\N
188	16	save	Publication sauvegardée	ahmed a sauvegardé votre publication	ahmed	91	\N	f	2026-08-20 07:13:52.243277	\N	\N
189	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	35	f	2026-08-20 07:14:42.564748	\N	\N
190	16	like	Nouveau j'aime	ahmed a aimé votre publication	ahmed	91	\N	f	2026-08-20 07:14:49.368858	\N	\N
191	42	moderation	✅ Publication approuvée !	Votre publication a été validée et est maintenant visible par la communauté.	EcoRewind IA	92	\N	f	2026-08-20 11:10:57.482594	\N	\N
192	42	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	92	\N	f	2026-08-21 22:32:40.01025	\N	\N
193	16	save	Publication sauvegardée	Chayma Tlatli a sauvegardé votre publication	Chayma Tlatli	91	\N	f	2026-08-21 22:32:42.998873	\N	\N
195	16	comment	Nouveau commentaire	Chayma Tlatli a commenté votre publication	Chayma Tlatli	91	37	f	2026-08-21 22:58:05.961569	\N	\N
196	16	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	91	\N	f	2026-08-23 15:52:45.980802	\N	\N
197	12	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	66	\N	f	2026-08-23 15:52:51.168624	\N	\N
198	23	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	3	\N	f	2026-08-23 16:13:09.969626	\N	\N
199	16	moderation	⚠️ Publication signalée par l'IA	Votre publication a été détectée comme potentiellement hors-sujet par notre IA. Elle a été transmise à un administrateur pour vérification. Vous serez notifié(e) dès sa décision.	EcoRewind IA	94	\N	f	2026-08-25 22:34:29.534585	\N	\N
200	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	38	f	2026-08-27 14:28:38.901737	\N	\N
201	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	39	f	2026-08-27 14:46:20.697394	\N	\N
194	12	comment	Nouveau commentaire	Chayma Tlatli a commenté votre publication	Chayma Tlatli	72	36	t	2026-08-21 22:33:01.025347	\N	\N
202	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	91	40	f	2026-08-27 15:00:30.920094	\N	\N
203	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	66	41	f	2026-08-30 10:29:40.375009	\N	\N
204	12	comment	Réponse à votre commentaire	Amine T. a répondu à votre commentaire	Amine T.	66	41	f	2026-08-30 10:29:40.404512	\N	\N
205	12	like	Nouveau j'aime	Amine T. a aimé votre publication	Amine T.	66	\N	f	2026-08-30 10:29:48.518808	\N	\N
208	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	72	44	f	2026-08-30 12:49:45.674016	\N	\N
209	12	like	Nouveau j'aime	Amine T. a aimé votre publication	Amine T.	72	\N	f	2026-08-30 12:49:54.332115	\N	\N
210	16	comment	Nouveau commentaire	ahmed a commenté votre publication	ahmed	57	45	f	2026-08-30 16:24:42.140505	\N	\N
211	12	comment	Nouveau commentaire	Amine T. a commenté votre publication	Amine T.	53	46	f	2026-08-30 17:36:33.187084	\N	\N
212	16	comment	Nouveau commentaire	Chayma Tlatli a commenté votre publication	Chayma Tlatli	74	47	f	2026-08-30 19:37:53.606965	\N	\N
213	16	like	Nouveau j'aime	Chayma Tlatli a aimé votre publication	Chayma Tlatli	74	\N	f	2026-08-30 19:37:59.329695	\N	\N
214	39	like	Nouveau j'aime	Chayma a aimé votre publication	Chayma	88	\N	f	2026-09-02 10:40:04.268418	\N	\N
215	43	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
216	26	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
217	29	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
218	15	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
219	22	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
220	30	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
221	23	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
222	25	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 30 min.	Educateur Test	\N	\N	f	2026-09-04 08:33:41.989521	\N	\N
223	43	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
224	39	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
225	42	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
226	40	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
227	44	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
228	26	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
229	27	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
230	28	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
231	29	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
232	14	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
233	15	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
234	17	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
235	22	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
236	30	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
237	37	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
238	23	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
239	24	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
240	25	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
241	45	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
242	12	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
243	16	meeting	📅 Nouvelle séance : tri	Educateur Test vous invite à une séance le 05/09/2026 à 10:00. Durée : 60 min.	Educateur Test	\N	\N	f	2026-09-04 08:35:15.36259	\N	\N
179	20	center_alert	🔴 Centre Saturé	Le centre « ch » est saturé et nécessite une collecte urgente.	Système EcoRewind	18	\N	t	2026-08-20 05:00:57.699601	\N	\N
\.


--
-- Data for Name: otp_codes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.otp_codes (id, identifier, code, purpose, created_at, expires_at, is_used) FROM stdin;
1	otakuotakuu775@gmail.com	594995	register	2026-03-29 23:28:27.756387	2026-03-29 23:33:27.752377	t
2	yasmineboughzala5@gmail.com	648448	register	2026-03-30 17:56:41.017958	2026-03-30 18:01:41.016409	f
3	tchayma2000@gmail.com	778224	register	2026-03-30 17:58:11.489149	2026-03-30 18:03:11.488135	t
4	aidaboughzala343@gmail.com	923808	register	2026-05-08 02:03:12.094702	2026-05-08 02:08:12.091149	t
5	omarmbarek758@gmail.com	383721	register	2026-08-19 21:49:12.839403	2026-08-19 21:54:12.83705	t
6	chemadhouib3@gmail.com	565631	register	2026-09-03 18:55:57.89636	2026-09-03 19:00:57.895263	t
7	+21653216956	380234	register	2026-09-03 18:57:48.651549	2026-09-03 19:02:48.651549	t
8	+21653216956	548296	register	2026-09-03 18:59:13.779655	2026-09-03 19:04:13.778586	f
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (id, user_id, user_name, user_avatar_url, image_url, description, created_at, likes_count, status, moderation_score, moderation_reason, moderation_details, moderated_at, moderation_model_version) FROM stdin;
4	16	Amine T.			ghjhkjlk	2026-03-25 21:11:25.009841	2	published	0	\N	\N	\N	\N
5	24	Test Diag			hello	2026-04-01 18:48:57.236447	1	published	0	\N	\N	\N	\N
6	24	Test Diag		http://localhost:8000/uploads/97377f4798184c60885f502442c5a360.jpeg	hello	2026-04-01 19:31:59.252931	2	published	0	\N	\N	\N	\N
7	16	Amine T.		http://localhost:8000/uploads/5401dd6c0b9449d1a6fcc258517630f0.jpg	bonjour la communauté de la nature	2026-04-15 20:51:12.297454	0	published	0.006	Contenu potentiellement inapproprié	{"score": 0.006, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["nature", "communaute"], "bonus": 0.1, "count": 2, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.016, "identity_attack": 0.002, "insult": 0.011, "threat": 0.001, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.016, "identity_attack": 0.002, "insult": 0.011, "threat": 0.001, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.5568, "off_topic": 0.1944, "toxic": 0.2489, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.006, "processing_time_ms": 103.85, "cnn_probs": {"eco": 0.5568, "off_topic": 0.1944, "toxic": 0.2489}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9305, "off_topic": 0.0558, "nsfw": 0.0137, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 119.2, "resnet_probs": {"eco": 0.9305, "off_topic": 0.0558, "nsfw": 0.0137}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 368.09, "languages_detected": ["fr"]}	\N	\N
8	16	Amine T.		http://localhost:8000/uploads/5936f8149c83433ea49cb4e3cff982fb.jpg	hello	2026-04-15 23:25:04.588056	0	rejected	0.6	Contenu ne respectant pas les règles	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 157.17, "cnn_probs": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.0982, "off_topic": 0.2529, "nsfw": 0.6489, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 86.32, "resnet_probs": {"eco": 0.0982, "off_topic": 0.2529, "nsfw": 0.6489}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 364.87, "languages_detected": ["unknown"]}	\N	\N
10	16	Amine T.		http://localhost:8000/uploads/0b28a5cc977347309dfc9cd7fd5876f6.jpg	hi	2026-04-15 23:26:42.902693	0	pending_review	0.6	Contenu potentiellement inapproprié | Texte sans contexte environnemental détecté	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 38.26, "cnn_probs": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.0982, "off_topic": 0.2529, "nsfw": 0.6489, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 39.53, "resnet_probs": {"eco": 0.0982, "off_topic": 0.2529, "nsfw": 0.6489}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 139.34, "languages_detected": ["unknown"]}	\N	\N
12	16	Amine T.		http://localhost:8000/uploads/e6ec23e4550448119471a955b52ff31e.jpg	vive la tunisie	2026-04-15 23:37:06.298471	0	published	0.007	Contenu potentiellement inapproprié	{"score": 0.007, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.018, "severe_toxicity": 0.0, "obscene": 0.004, "identity_attack": 0.004, "insult": 0.004, "threat": 0.001, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.018, "severe_toxicity": 0.0, "obscene": 0.004, "identity_attack": 0.004, "insult": 0.004, "threat": 0.001, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.3843, "off_topic": 0.3445, "toxic": 0.2713, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.007, "processing_time_ms": 116.99, "cnn_probs": {"eco": 0.3843, "off_topic": 0.3445, "toxic": 0.2713}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9628, "off_topic": 0.0025, "nsfw": 0.0348, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 76.16, "resnet_probs": {"eco": 0.9628, "off_topic": 0.0025, "nsfw": 0.0348}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 306.27, "languages_detected": ["fr"]}	\N	\N
16	16	Amine T.		http://localhost:8000/uploads/b1efbdf29dc54f26ac5a4ebd65e0b12d.jpg	bonjour	2026-04-16 00:01:56.487118	0	published	0.005	Contenu potentiellement inapproprié	{"score": 0.005, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.005, "processing_time_ms": 56.51, "cnn_probs": {"eco": 0.3278, "off_topic": 0.414, "toxic": 0.2582}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9489, "off_topic": 0.0206, "nsfw": 0.0305, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 47.89, "resnet_probs": {"eco": 0.9489, "off_topic": 0.0206, "nsfw": 0.0305}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 170.81, "languages_detected": ["unknown"]}	\N	\N
23	16	Amine T.		http://localhost:8000/uploads/f2f244a568df436f925f3d2914f318fe.jpg	hi	2026-04-20 10:50:47.411327	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Contenu hors sujet detecte : image non liee a l'environnement (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 139.47, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.3086, "nsfw": 0.1587, "off_topic": 0.5327, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5327, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 53.76, "resnet_probs": {"eco": 0.3086, "nsfw": 0.1587, "off_topic": 0.5327}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 304.0, "languages_detected": ["unknown"]}	\N	\N
3	23	amel ben saleh	https://i.pravatar.cc/300?u=amel123@tridechet.tn	https://images.unsplash.com/photo-1611284446314-60a58ac0deb9?w=800&q=80	amel	2026-02-16 22:47:57.903354	2	published	0	\N	\N	\N	\N
20	16	Amine T.		http://localhost:8000/uploads/45d1598dcb84444ab619a671c0c918a6.jpg	hi	2026-04-20 00:25:30.796233	0	pending_review	0.3	Contenu potentiellement inapproprié	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 187.74, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 137.53, "resnet_probs": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 497.68, "languages_detected": ["unknown"]}	\N	\N
21	16	Amine T.		http://localhost:8000/uploads/e99c959c3a7b455388f54d243a95819f.jpg	hello	2026-04-20 00:26:41.469158	0	pending_review	0.3	Contenu potentiellement inapproprié	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 45.07, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 72.03, "resnet_probs": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 180.01, "languages_detected": ["unknown"]}	\N	\N
24	16	Amine T.		http://localhost:8000/uploads/a6e2539a5a404de8a9ebf5e6b3490b6f.jpg	hi	2026-04-20 11:41:41.50213	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 189.56, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.4734, "severity": "high", "source": "ResNet18-CNN"}, "resnet_image": {"eco": 0.3737, "nsfw": 0.4734, "off_topic": 0.1528, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 134.2, "resnet_probs": {"eco": 0.3737, "nsfw": 0.4734, "off_topic": 0.1528}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 607.22, "languages_detected": ["unknown"]}	\N	\N
25	25	Chayma Tlatli		http://localhost:8000/uploads/5bcc5f6e2066435bbbe5d5c3573865fb.jpg	hi	2026-04-22 13:39:17.079425	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Contenu hors sujet detecte : image non liee a l'environnement (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 1340.57, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.3086, "nsfw": 0.1587, "off_topic": 0.5327, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5327, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 504.75, "resnet_probs": {"eco": 0.3086, "nsfw": 0.1587, "off_topic": 0.5327}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 2303.73, "languages_detected": ["unknown"]}	\N	\N
26	25	Chayma Tlatli		http://localhost:8000/uploads/2152b39e2b7f4b459967766b4ba40529.jpg	Bonjour	2026-04-22 13:40:40.2084	0	published	0.3	Approuvé par l'administrateur	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.001, "obscene": 0.005, "identity_attack": 0.001, "insult": 0.004, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.001, "obscene": 0.005, "identity_attack": 0.001, "insult": 0.004, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 133.01, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6325, "nsfw": 0.2271, "off_topic": 0.1404, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.456}], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 317.21, "resnet_probs": {"eco": 0.6325, "nsfw": 0.2271, "off_topic": 0.1404}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 693.76, "languages_detected": ["unknown"]}	\N	\N
27	25	Chayma Tlatli		http://localhost:8000/uploads/106af6c8e9be4491997f04838dcc7ec4.jpg	hello	2026-04-22 13:41:13.376302	0	published	0.3	Approuvé par l'administrateur	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 148.28, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9348, "nsfw": 0.0497, "off_topic": 0.0155, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 112.44, "resnet_probs": {"eco": 0.9348, "nsfw": 0.0497, "off_topic": 0.0155}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 390.53, "languages_detected": ["unknown"]}	\N	\N
28	25	Chayma Tlatli		http://localhost:8000/uploads/3bb27877c4244c92a73cb2e87f7273a3.jpg	Bonjour 	2026-04-22 13:42:29.975141	0	published	0.6	Approuvé par l'administrateur	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.001, "obscene": 0.005, "identity_attack": 0.001, "insult": 0.004, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.001, "obscene": 0.005, "identity_attack": 0.001, "insult": 0.004, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 119.46, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5916, "nsfw": 0.2376, "off_topic": 0.1707, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 114.67, "resnet_probs": {"eco": 0.5916, "nsfw": 0.2376, "off_topic": 0.1707}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 387.02, "languages_detected": ["unknown"]}	\N	\N
29	25	Chayma Tlatli		http://localhost:8000/uploads/0fa1c570d4a544a6b8de467119a8b6e2.jpg	bonjour	2026-04-22 13:49:12.656075	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 185.82, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.4734, "severity": "high", "source": "ResNet18-CNN"}, "resnet_image": {"eco": 0.3737, "nsfw": 0.4734, "off_topic": 0.1528, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 135.43, "resnet_probs": {"eco": 0.3737, "nsfw": 0.4734, "off_topic": 0.1528}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 463.22, "languages_detected": ["unknown"]}	\N	\N
30	25	Chayma Tlatli		http://localhost:8000/uploads/99464eebd1244aaeba1eb3c67ac3728f.jpg	hi	2026-04-22 13:50:02.113051	0	pending_review	0.3	Contenu potentiellement inapproprié	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 100.39, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.474}], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 112.71, "resnet_probs": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 360.26, "languages_detected": ["unknown"]}	\N	\N
31	25	Chayma Tlatli		http://localhost:8000/uploads/f41e6548e9f64607bd2f736702bfc0d0.jpg	Le recyclage est notre responsabilité 	2026-04-22 13:50:49.433113	0	pending_review	0.7	AI_FLAGGED:nsfw	{"score": 0.7, "status": "rejected", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["recyclage"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.0663, "off_topic": 0.0439, "toxic": 0.8898, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.7, "processing_time_ms": 355.57, "cnn_probs": {"eco": 0.0663, "off_topic": 0.0439, "toxic": 0.8898}, "cnn_decision": "toxic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.474}], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 119.53, "resnet_probs": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 676.4, "languages_detected": ["fr"]}	\N	\N
32	25	Chayma Tlatli		http://localhost:8000/uploads/0dee8edda53e484893ef4e258956e12e.jpg	bonjour	2026-04-22 13:51:18.335368	0	pending_review	0.3	Contenu potentiellement inapproprié	{"score": 0.3, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 124.8, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6542, "nsfw": 0.1405, "off_topic": 0.2053, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 116.94, "resnet_probs": {"eco": 0.6542, "nsfw": 0.1405, "off_topic": 0.2053}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 389.17, "languages_detected": ["unknown"]}	\N	\N
33	25	Chayma Tlatli		http://localhost:8000/uploads/31ae631a47ad40778f647e3543bfcaa1.jpg	hi	2026-04-22 14:06:14.059681	0	pending_review	0.6	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 235.71, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5916, "nsfw": 0.2376, "off_topic": 0.1707, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 180.98, "resnet_probs": {"eco": 0.5916, "nsfw": 0.2376, "off_topic": 0.1707}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 646.55, "languages_detected": ["unknown"]}	\N	\N
34	25	Chayma Tlatli		http://localhost:8000/uploads/27b8e66f84944533900ae9c227b198eb.jpg	Notre nature est notre responsabilité	2026-04-22 14:41:59.501678	0	pending_review	0.7	AI_FLAGGED:nsfw	{"score": 0.7, "status": "rejected", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["nature"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.1837, "off_topic": 0.0338, "toxic": 0.7825, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.7, "processing_time_ms": 269.63, "cnn_probs": {"eco": 0.1837, "off_topic": 0.0338, "toxic": 0.7825}, "cnn_decision": "toxic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.474}], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 211.87, "resnet_probs": {"eco": 0.6663, "nsfw": 0.3042, "off_topic": 0.0295}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 707.26, "languages_detected": ["fr"]}	\N	\N
35	25	Chayma Tlatli		http://localhost:8000/uploads/75812018053541d4b692938455126a3f.jpg	planter une arbre pour une tunisie verte 	2026-04-22 14:42:54.510848	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["vert", "arbre", "plante"], "bonus": 0.15000000000000002, "count": 3, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.021, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.001, "insult": 0.002, "threat": 0.01, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.021, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.001, "insult": 0.002, "threat": 0.01, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.1198, "off_topic": 0.7997, "toxic": 0.0804, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 119.02, "cnn_probs": {"eco": 0.1198, "off_topic": 0.7997, "toxic": 0.0804}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8573, "nsfw": 0.0991, "off_topic": 0.0436, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 135.36, "resnet_probs": {"eco": 0.8573, "nsfw": 0.0991, "off_topic": 0.0436}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 368.76, "languages_detected": ["fr"]}	\N	\N
36	25	Chayma Tlatli		http://localhost:8000/uploads/9ee858dc119946a0b93ec2367c0f6670.jpg	c'est quoi l'ecologie vraiment ?	2026-04-22 14:43:58.983465	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["ecologie", "eco"], "bonus": 0.1, "count": 2, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.0, "obscene": 0.007, "identity_attack": 0.0, "insult": 0.003, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.0, "obscene": 0.007, "identity_attack": 0.0, "insult": 0.003, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.0349, "off_topic": 0.3301, "toxic": 0.635, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.7, "processing_time_ms": 134.53, "cnn_probs": {"eco": 0.0349, "off_topic": 0.3301, "toxic": 0.635}, "cnn_decision": "toxic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.4713, "severity": "high", "source": "ResNet18-CNN"}, "resnet_image": {"eco": 0.1982, "nsfw": 0.4713, "off_topic": 0.3306, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 120.71, "resnet_probs": {"eco": 0.1982, "nsfw": 0.4713, "off_topic": 0.3306}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 370.35, "languages_detected": ["fr"]}	\N	\N
37	25	Chayma Tlatli		http://localhost:8000/uploads/fe9039fa84b54ea58bde3a0b8dec10a5.jpg	bonjour	2026-04-22 15:29:52.629485	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.005, "processing_time_ms": 94.23, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 104.02, "resnet_probs": {"eco": 0.8264, "nsfw": 0.0783, "off_topic": 0.0953}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 310.39, "languages_detected": ["unknown"]}	\N	\N
38	25	Chayma Tlatli		http://localhost:8000/uploads/9d6f107289dc4b5a9077712fef444e53.jpg	hi	2026-04-22 15:30:20.831377	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image", "Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 70.16, "cnn_probs": {"eco": 0.384, "off_topic": 0.3627, "toxic": 0.2533}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.8303, "severity": "high", "source": "ResNet18-CNN"}, "resnet_image": {"eco": 0.0798, "nsfw": 0.8303, "off_topic": 0.09, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 104.13, "resnet_probs": {"eco": 0.0798, "nsfw": 0.8303, "off_topic": 0.09}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 300.72, "languages_detected": ["unknown"]}	\N	\N
39	16	Amine T.		http://localhost:8000/uploads/0436e34f751d471c8f5b6c381c116f58.jpg	hi	2026-04-22 19:56:43.9123	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4029, "off_topic": 0.4675, "toxic": 0.1296, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 186.76, "cnn_probs": {"eco": 0.4029, "off_topic": 0.4675, "toxic": 0.1296}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9196, "nsfw": 0.0448, "off_topic": 0.0356, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 133.57, "resnet_probs": {"eco": 0.9196, "nsfw": 0.0448, "off_topic": 0.0356}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 523.34, "languages_detected": ["unknown"]}	\N	\N
40	16	Amine T.		http://localhost:8000/uploads/ac0d2d6a9bc24ab0aa290c67c3a74bba.jpg	protéger le co2 	2026-04-22 19:57:42.511258	0	pending_review	0.45	Contenu potentiellement inapproprié | Contenu hors sujet detecte : image non liee a l'environnement (validation admin requise)	{"score": 0.45, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Contenu hors sujet detecte : image non liee a l'environnement (validation admin requise)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["proteger"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.0, "severe_toxicity": 0.001, "obscene": 0.007, "identity_attack": 0.001, "insult": 0.005, "threat": 0.001, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.0, "severe_toxicity": 0.001, "obscene": 0.007, "identity_attack": 0.001, "insult": 0.005, "threat": 0.001, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.0353, "off_topic": 0.8392, "toxic": 0.1255, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 65.94, "cnn_probs": {"eco": 0.0353, "off_topic": 0.8392, "toxic": 0.1255}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.0587, "nsfw": 0.063, "off_topic": 0.8783, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.8783, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 48.56, "resnet_probs": {"eco": 0.0587, "nsfw": 0.063, "off_topic": 0.8783}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 167.0, "languages_detected": ["fr"]}	\N	\N
41	16	Amine T.		http://localhost:8000/uploads/89bd0b406f5a444690399dc9766099f8.jpg	hi	2026-04-22 20:30:59.961643	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4029, "off_topic": 0.4675, "toxic": 0.1296, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 235.15, "cnn_probs": {"eco": 0.4029, "off_topic": 0.4675, "toxic": 0.1296}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.578, "nsfw": 0.2398, "off_topic": 0.1822, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 183.99, "resnet_probs": {"eco": 0.578, "nsfw": 0.2398, "off_topic": 0.1822}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 709.19, "languages_detected": ["unknown"]}	\N	\N
42	16	Amine T.		http://localhost:8000/uploads/cd30b39bec9842bb86cf16a10b63426c.jpg	hi	2026-04-23 21:44:00.496041	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 224.77, "cnn_probs": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8431, "nsfw": 0.0417, "off_topic": 0.1152, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 193.23, "resnet_probs": {"eco": 0.8431, "nsfw": 0.0417, "off_topic": 0.1152}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 666.38, "languages_detected": ["unknown"]}	\N	\N
44	16	Amine T.		http://localhost:8000/uploads/aa95c7f9e56a4cd39169a1b73e7e2f48.jpg	il faut sauvgarder notre envorinnement 	2026-04-23 21:45:26.754238	0	published	0.2	Contenu potentiellement inapproprié	{"score": 0.2, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.001, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.001, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.9449, "off_topic": 0.0501, "toxic": 0.005, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.001, "processing_time_ms": 149.64, "cnn_probs": {"eco": 0.9449, "off_topic": 0.0501, "toxic": 0.005}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 101.1, "resnet_probs": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 387.28, "languages_detected": ["unknown"]}	\N	\N
45	16	Amine T.		http://localhost:8000/uploads/41f2b78cdf6642088af991050bb3b71f.jpg	hi	2026-04-23 21:47:20.134743	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 105.66, "cnn_probs": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.6679, "severity": "high", "source": "ResNet18-CNN"}, "resnet_image": {"eco": 0.0483, "nsfw": 0.6679, "off_topic": 0.2838, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 90.69, "resnet_probs": {"eco": 0.0483, "nsfw": 0.6679, "off_topic": 0.2838}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 341.8, "languages_detected": ["unknown"]}	\N	\N
48	16	Amine T.		http://localhost:8000/uploads/0950e9801bdb401d89d4e77d3e9676a2.jpg	hi	2026-04-23 22:00:58.244071	0	pending_review	0.4	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 202.1, "cnn_probs": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5086, "nsfw": 0.0254, "off_topic": 0.4659, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 102.96, "resnet_probs": {"eco": 0.5086, "nsfw": 0.0254, "off_topic": 0.4659}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 415.14, "languages_detected": ["unknown"]}	\N	\N
49	12	ahmed		http://localhost:8000/uploads/9fe1e0bee299449dbea9035f1bf7e402.jpg	bonjour	2026-04-26 22:55:28.112771	0	pending_review	0.4	Contenu potentiellement inapproprié | Image positive detectee mais texte sans action eco (validation admin requise)	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["bonjour"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.766, "off_topic": 0.0698, "toxic": 0.1642, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.005, "processing_time_ms": 1737.73, "cnn_probs": {"eco": 0.766, "off_topic": 0.0698, "toxic": 0.1642}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.4835, "nsfw": 0.2023, "off_topic": 0.3142, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 300.44, "resnet_probs": {"eco": 0.4835, "nsfw": 0.2023, "off_topic": 0.3142}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 2464.33, "languages_detected": ["unknown"]}	\N	\N
50	12	ahmed		http://localhost:8000/uploads/1a6b2d564d094d9da4665ba838c0af05.jpg	hi	2026-04-26 22:55:46.187024	0	pending_review	0.4	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 161.45, "cnn_probs": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8954, "nsfw": 0.0304, "off_topic": 0.0742, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 178.47, "resnet_probs": {"eco": 0.8954, "nsfw": 0.0304, "off_topic": 0.0742}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 603.08, "languages_detected": ["unknown"]}	\N	\N
51	12	ahmed		http://localhost:8000/uploads/0f2a6d52f16a400bbb18b30126b339c7.jpg	Pour une Tunisie propre	2026-04-26 22:56:25.373523	0	pending_review	0.601	Contenu potentiellement inapproprié | Texte sans contexte environnemental détecté	{"score": 0.601, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.0, "obscene": 0.003, "identity_attack": 0.003, "insult": 0.002, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.0, "obscene": 0.003, "identity_attack": 0.003, "insult": 0.002, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.9361, "off_topic": 0.0601, "toxic": 0.0039, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.001, "processing_time_ms": 173.7, "cnn_probs": {"eco": 0.9361, "off_topic": 0.0601, "toxic": 0.0039}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8954, "nsfw": 0.0304, "off_topic": 0.0742, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 129.7, "resnet_probs": {"eco": 0.8954, "nsfw": 0.0304, "off_topic": 0.0742}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 482.3, "languages_detected": ["fr"]}	\N	\N
52	12	ahmed		http://localhost:8000/uploads/6fab4af8eb1c47548e4677975e52694c.jpg	hi	2026-04-26 22:56:46.341409	0	pending_review	0.4	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 101.42, "cnn_probs": {"eco": 0.4298, "off_topic": 0.3177, "toxic": 0.2525}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6416, "nsfw": 0.1852, "off_topic": 0.1733, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 122.84, "resnet_probs": {"eco": 0.6416, "nsfw": 0.1852, "off_topic": 0.1733}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 397.27, "languages_detected": ["unknown"]}	\N	\N
53	12	ahmed		http://localhost:8000/uploads/59b3c2a35ba14a23902e54fd5aee9f3e.jpg	planter des fleurs pour colorer notre nature	2026-04-27 19:24:07.94194	0	published	0	Contenu potentiellement inapproprié	{"score": 0.0, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["nature", "plante", "fleur"], "bonus": 0.15000000000000002, "count": 3, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.9666, "off_topic": 0.0061, "toxic": 0.0272, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 299.85, "cnn_probs": {"eco": 0.9666, "off_topic": 0.0061, "toxic": 0.0272}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.4879, "nsfw": 0.1145, "off_topic": 0.3977, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 192.37, "resnet_probs": {"eco": 0.4879, "nsfw": 0.1145, "off_topic": 0.3977}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 795.17, "languages_detected": ["fr"]}	\N	\N
54	12	ahmed		http://localhost:8000/uploads/ac43396db03c4d0ba109a36ad2db1d5d.jpg	jeter les saltés partout 	2026-04-27 19:24:55.515357	0	pending_review	0.685	Contenu potentiellement inapproprié | Texte sans contexte environnemental détecté	{"score": 0.685, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.212, "severe_toxicity": 0.001, "obscene": 0.016, "identity_attack": 0.002, "insult": 0.046, "threat": 0.044, "sexual_explicit": 0.004, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.212, "severe_toxicity": 0.001, "obscene": 0.016, "identity_attack": 0.002, "insult": 0.046, "threat": 0.044, "sexual_explicit": 0.004, "cnn_text": {"eco": 0.2027, "off_topic": 0.5042, "toxic": 0.2932, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.085, "processing_time_ms": 128.69, "cnn_probs": {"eco": 0.2027, "off_topic": 0.5042, "toxic": 0.2932}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 129.65, "resnet_probs": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 395.33, "languages_detected": ["fr"]}	\N	\N
60	12	ahmed		http://localhost:8000/uploads/4ae58541ce0841a585fa72987bebf2b2.jpg	hi	2026-05-07 18:53:18.314909	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 117.99, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5633, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 110.08, "resnet_probs": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 391.86, "languages_detected": ["unknown"]}	\N	\N
62	12	ahmed		http://localhost:8000/uploads/53f1665c05d742ebbcb3e247864d1ee4.jpg	hi	2026-05-07 19:49:01.147489	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 56.14, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5633, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 52.42, "resnet_probs": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 185.47, "languages_detected": ["unknown"]}	\N	\N
61	12	ahmed		http://localhost:8000/uploads/e9b40bd620f34f6095a70559c0cbb4ce.jpg	hi	2026-05-07 19:36:03.421622	0	rejected	0.7	Contenu ne respectant pas les règles	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 377.09, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5633, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 223.45, "resnet_probs": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 1044.04, "languages_detected": ["unknown"]}	\N	\N
59	12	ahmed		http://localhost:8000/uploads/c7a14b0023a143babe18b1a9f6692e86.jpg	hi	2026-05-07 18:45:05.99657	0	rejected	0.7	Contenu ne respectant pas les règles	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 251.62, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5633, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 166.84, "resnet_probs": {"eco": 0.2663, "nsfw": 0.1704, "off_topic": 0.5633}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 664.78, "languages_detected": ["unknown"]}	\N	\N
55	12	ahmed		http://localhost:8000/uploads/2f5062b9aa70403bbcc3fb51bdfa0446.jpg	ne laisser pas les déchets partout pour sauvgardé notre santé	2026-04-27 19:25:42.201953	0	rejected	0.4	Contenu ne respectant pas les règles	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image positive detectee mais texte sans action eco (validation admin requise)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["dechets", "dechet"], "bonus": 0.1, "count": 2, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.165, "severe_toxicity": 0.0, "obscene": 0.002, "identity_attack": 0.0, "insult": 0.129, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.165, "severe_toxicity": 0.0, "obscene": 0.002, "identity_attack": 0.0, "insult": 0.129, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.9812, "off_topic": 0.0087, "toxic": 0.0102, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.066, "processing_time_ms": 155.33, "cnn_probs": {"eco": 0.9812, "off_topic": 0.0087, "toxic": 0.0102}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 114.82, "resnet_probs": {"eco": 0.5751, "nsfw": 0.0729, "off_topic": 0.352}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 403.44, "languages_detected": ["fr"]}	\N	\N
63	12	ahmed		http://localhost:8000/uploads/1fc2179214b44c5c8c99fef77c2b7266.jpg	hi	2026-05-07 20:00:06.605259	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 51.45, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.1631, "nsfw": 0.1862, "off_topic": 0.6507, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.6507, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 54.68, "resnet_probs": {"eco": 0.1631, "nsfw": 0.1862, "off_topic": 0.6507}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 167.98, "languages_detected": ["unknown"]}	\N	\N
65	12	ahmed		http://localhost:8000/uploads/774769163cd84ed9ba74e1b05ec5b9a4.jpg	hi	2026-05-07 20:14:11.405638	0	pending_review	0.7	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.7, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 65.34, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2935, "nsfw": 0.0842, "off_topic": 0.6223, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.6223, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 55.82, "resnet_probs": {"eco": 0.2935, "nsfw": 0.0842, "off_topic": 0.6223}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 198.55, "languages_detected": ["unknown"]}	\N	\N
67	12	ahmed		http://localhost:8000/uploads/559036b229084d9387ee2d2abe59dcf1.jpg	hello	2026-05-07 20:30:33.954416	0	rejected	0.45	Contenu ne respectant pas les règles	{"score": 0.45, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["hello"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 201.8, "cnn_probs": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.0458, "nsfw": 0.0793, "off_topic": 0.8748, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.8748, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 105.58, "resnet_probs": {"eco": 0.0458, "nsfw": 0.0793, "off_topic": 0.8748}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 495.81, "languages_detected": ["unknown"]}	\N	\N
71	12	ahmed		http://127.0.0.1:8000/uploads/23b0b8e644ad451c8dcab36323e5370c.jpg	bonjour	2026-05-12 13:15:36.46388	0	pending_review	0.45	Contenu potentiellement inapproprié | Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation	{"score": 0.45, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["bonjour"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4605, "off_topic": 0.2719, "toxic": 0.2676, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.005, "processing_time_ms": 188.18, "cnn_probs": {"eco": 0.4605, "off_topic": 0.2719, "toxic": 0.2676}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.34, "nsfw": 0.111, "off_topic": 0.549, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.35, "processing_time_ms": 173.24, "resnet_probs": {"eco": 0.34, "nsfw": 0.111, "off_topic": 0.549}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 506.16, "languages_detected": ["unknown"]}	\N	\N
73	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	http://127.0.0.1:8000/uploads/ec994cb8008c4985a607ae2802f739bf.jpg	mmm trés bon	2026-06-08 19:21:42.00429	0	pending_review	0.6	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Texte hors sujet detecte par l'IA : publication envoyee a l'administrateur"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.004, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.004, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.0878, "off_topic": 0.8835, "toxic": 0.0287, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 199.12, "cnn_probs": {"eco": 0.0878, "off_topic": 0.8835, "toxic": 0.0287}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.6571, "nsfw": 0.0628, "off_topic": 0.2801, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 187.6, "resnet_probs": {"eco": 0.6571, "nsfw": 0.0628, "off_topic": 0.2801}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 657.78, "languages_detected": ["unknown"]}	2026-06-08 19:23:35.7377	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
57	16	Amine T.		http://localhost:8000/uploads/14627a793eef4416a964265756427202.jpg	hi\n	2026-05-06 23:06:48.071603	1	published	0.1	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.1, "status": "published", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 92.67, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9585, "nsfw": 0.0359, "off_topic": 0.0056, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 94.59, "resnet_probs": {"eco": 0.9585, "nsfw": 0.0359, "off_topic": 0.0056}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 311.14, "languages_detected": ["unknown"]}	\N	\N
70	2	Educateur Test		http://localhost:8000/uploads/ad71f589c37447dab8efb35b13f4befa.jpg	hi	2026-05-07 23:42:37.517517	1	published	0.1	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.1, "status": "published", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 2583.35, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.9656, "nsfw": 0.0254, "off_topic": 0.009, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 2192.4, "resnet_probs": {"eco": 0.9656, "nsfw": 0.0254, "off_topic": 0.009}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 5475.13, "languages_detected": ["unknown"]}	\N	\N
74	16	Amine T.		http://127.0.0.1:8000/uploads/a883c5fa44894373b3dad7abded17e3c.jpg	notre payé doit etre organisé	2026-06-14 13:19:03.93095	2	published	0.95	Approuvé par l'administrateur	{"score": 0.95, "status": "rejected", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Contenu toxique auto-rejete (profanite + IA)"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.002, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.002, "severe_toxicity": 0.0, "obscene": 0.002, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.189, "off_topic": 0.1762, "toxic": 0.6349, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.7, "processing_time_ms": 148.7, "cnn_probs": {"eco": 0.189, "off_topic": 0.1762, "toxic": 0.6349}, "cnn_decision": "toxic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.2209, "nsfw": 0.0672, "off_topic": 0.7119, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.7119, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 95.78, "resnet_probs": {"eco": 0.2209, "nsfw": 0.0672, "off_topic": 0.7119}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 409.17, "languages_detected": ["unknown"]}	2026-06-14 13:20:16.386238	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
76	24	Test			Test post diag	2026-06-18 19:06:33.128714	0	pending_review	0	\N	\N	\N	\N
80	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/33bc9fbd97914097b9336d42501477e8.jpg	hi	2026-06-28 15:41:09.459864	0	pending_review	0.6	Contenu potentiellement inapproprié | Image sans contexte environnemental détecté	{"score": 0.6, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 140.28, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.0553, "nsfw": 0.4204, "off_topic": 0.5243, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.717}, {"class": "ARMPITS_EXPOSED", "confidence": 0.397}, {"class": "FEMALE_BREAST_COVERED", "confidence": 0.329}], "clip_analysis": {}, "score": 0.35, "processing_time_ms": 90.75, "resnet_probs": {"eco": 0.0553, "nsfw": 0.4204, "off_topic": 0.5243}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 370.64, "languages_detected": ["unknown"]}	2026-06-28 15:42:09.324427	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
77	24	Test			Test post diag	2026-06-18 19:18:00.385584	0	pending_review	0	\N	\N	\N	\N
72	12	ahmed		http://127.0.0.1:8000/uploads/0a1ea9d909cc481bb4d4645e681936bc.jpg	sauvgarder notre plantes	2026-05-20 17:12:44.780832	2	published	0	Contenu potentiellement inapproprié	{"score": 0.0, "status": "published", "reasons": ["Contenu potentiellement inapproprié"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["plante"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.5737, "off_topic": 0.3301, "toxic": 0.0962, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 602.15, "cnn_probs": {"eco": 0.5737, "off_topic": 0.3301, "toxic": 0.0962}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.7315, "nsfw": 0.061, "off_topic": 0.2076, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [{"class": "FACE_FEMALE", "confidence": 0.696}, {"class": "FACE_FEMALE", "confidence": 0.432}], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 322.15, "resnet_probs": {"eco": 0.7315, "nsfw": 0.061, "off_topic": 0.2076}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 1330.8, "languages_detected": ["unknown"]}	\N	\N
81	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/c31ec849894f49cfa083dbab28bd31ea.jpg	hello	2026-06-28 16:33:11.614061	0	pending_review	0.45	Contenu potentiellement inapproprié | Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation	{"score": 0.45, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["hello"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 55.33, "cnn_probs": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.1983, "nsfw": 0.1173, "off_topic": 0.6844, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.6844, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 72.43, "resnet_probs": {"eco": 0.1983, "nsfw": 0.1173, "off_topic": 0.6844}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 197.37, "languages_detected": ["unknown"]}	2026-06-28 16:33:54.828574	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
83	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/fb0622d17c4045d99b0769c55743ea0f.jpg	hi	2026-07-15 01:58:51.229841	0	pending_review	0.7	Image sans contexte environnemental détecté | Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation	{"score": 0.7, "status": "pending_review", "reasons": ["Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 172.75, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.2988, "nsfw": 0.0848, "off_topic": 0.6164, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.6164, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.2988, "nsfw": 0.0848, "off_topic": 0.6164}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 459.71, "languages_detected": ["unknown"]}	2026-07-15 01:59:38.737028	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
84	12	ahmed		http://127.0.0.1:8000/uploads/236a8e5ea33e497f9151b28195feb3b7.jpg	sauver la nature c'est a dire sauver les animaux	2026-07-26 12:35:26.177812	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image"], "text_analysis": {"languages": ["fr", "en"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["nature"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.0335, "off_topic": 0.3945, "toxic": 0.5719, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.7, "processing_time_ms": 195.24, "cnn_probs": {"eco": 0.0335, "off_topic": 0.3945, "toxic": 0.5719}, "cnn_decision": "toxic"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.1452, "nsfw": 0.4686, "off_topic": 0.3862, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "nsfw": {"score": 0.4686, "severity": "high", "source": "ResNet18-CNN"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.1452, "nsfw": 0.4686, "off_topic": 0.3862}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 464.92, "languages_detected": ["fr", "en"]}	2026-07-26 12:36:15.855424	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
85	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/c37ce9007f134ba58c678f80b495acb1.jpg	hi	2026-08-18 20:04:13.786579	0	pending_review	0.7	Image sans contexte environnemental détecté | Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation	{"score": 0.7, "status": "pending_review", "reasons": ["Image sans contexte environnemental détecté", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 296.77, "cnn_probs": {"eco": 0.844, "off_topic": 0.0606, "toxic": 0.0954}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.0755, "nsfw": 0.1127, "off_topic": 0.8118, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.8118, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.0755, "nsfw": 0.1127, "off_topic": 0.8118}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 817.28, "languages_detected": ["unknown"]}	2026-08-18 20:05:09.372543	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
86	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/a57a1741a7e745d1963955ca583d8cd6.jpg	notre nature est notre responsabilité 	2026-08-18 23:14:54.943582	0	pending_review	0.35	Contenu marqué pour révision par précaution	{"score": 0.35, "status": "pending_review", "reasons": ["Contenu marqué pour révision par précaution"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["nature"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.001, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.2708, "off_topic": 0.4342, "toxic": 0.295, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 178.84, "cnn_probs": {"eco": 0.2708, "off_topic": 0.4342, "toxic": 0.295}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.1302, "nsfw": 0.4226, "off_topic": 0.4472, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.35, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.1302, "nsfw": 0.4226, "off_topic": 0.4472}, "resnet_decision": "uncertain"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 334.84, "languages_detected": ["fr"]}	2026-08-18 23:15:32.851527	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
94	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/4eed438e1861460f85d078f4446de7d6.jpg		2026-08-25 22:33:22.457689	0	pending_review	0.95	AI_FLAGGED:nsfw	{"score": 0.95, "status": "rejected", "reasons": ["Contenu adulte détecté dans l'image", "Image sans contexte environnemental détecté"], "text_analysis": {"score": 0.0, "categories": {}, "ml_used": false}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.1762, "nsfw": 0.6889, "off_topic": 0.1348, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "nsfw": {"score": 0.6889, "severity": "high", "source": "ResNet18-CNN"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.95, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.1762, "nsfw": 0.6889, "off_topic": 0.1348}, "resnet_decision": "nsfw"}, "ml_available": true, "text_model_used": "RuleBased", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 332.81, "languages_detected": []}	2026-08-25 22:34:29.526406	RuleBased|NudeNet|EcoCNN_v1
87	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/6b874e1da9d2459f966f0991a3e9ec9f.jpg	hello	2026-08-19 09:42:58.6479	0	pending_review	0.45	Contenu marqué pour révision par précaution | Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation	{"score": 0.45, "status": "pending_review", "reasons": ["Contenu marqué pour révision par précaution", "Salutation avec image hors sujet : publication envoyee a l'administrateur pour validation"], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["hello"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.001, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.001, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 183.73, "cnn_probs": {"eco": 0.4811, "off_topic": 0.2594, "toxic": 0.2596}, "cnn_decision": "eco"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.2919, "nsfw": 0.1385, "off_topic": 0.5696, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.5696, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.2919, "nsfw": 0.1385, "off_topic": 0.5696}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 532.69, "languages_detected": ["unknown"]}	2026-08-19 09:44:27.560212	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
92	42	abc		http://127.0.0.1:8000/uploads/d3042e0d3a0144b2800182c423792e7e.jpg		2026-08-20 11:09:51.048999	1	published	0.25	Contenu approuvé automatiquement	{"score": 0.25, "status": "published", "reasons": [], "text_analysis": {"score": 0.0, "categories": {}, "ml_used": false}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.9435, "nsfw": 0.0429, "off_topic": 0.0136, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.9435, "nsfw": 0.0429, "off_topic": 0.0136}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "RuleBased", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 253.2, "languages_detected": []}	2026-08-20 11:10:57.473066	RuleBased|NudeNet|EcoCNN_v1
93	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	http://127.0.0.1:8000/uploads/5fbca858380545b4a7ffbe1157b789cb.jpg		2026-08-23 15:50:44.226581	0	pending_review	0.7	Image sans contexte environnemental détecté | Contenu hors sujet : publication non liee au tri, a la proprete ou a la sensibilisation environnementale (envoyee a l'administrateur)	{"score": 0.7, "status": "pending_review", "reasons": ["Image sans contexte environnemental détecté", "Contenu hors sujet : publication non liee au tri, a la proprete ou a la sensibilisation environnementale (envoyee a l'administrateur)"], "text_analysis": {"score": 0.0, "categories": {}, "ml_used": false}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.2726, "nsfw": 0.0714, "off_topic": 0.656, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.656, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.2726, "nsfw": 0.0714, "off_topic": 0.656}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "RuleBased", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 199.13, "languages_detected": []}	2026-08-23 15:51:26.131753	RuleBased|NudeNet|EcoCNN_v1
91	16	Amine T.	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	http://127.0.0.1:8000/uploads/f16a9d8c11004a16a6e1623374592c9f.jpg		2026-08-20 06:10:25.02589	2	published	0.25	Contenu approuvé automatiquement	{"score": 0.25, "status": "published", "reasons": [], "text_analysis": {"score": 0.0, "categories": {}, "ml_used": false}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.9702, "nsfw": 0.0222, "off_topic": 0.0076, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.9702, "nsfw": 0.0222, "off_topic": 0.0076}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "RuleBased", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 46.19, "languages_detected": []}	2026-08-20 06:10:25.08337	RuleBased|NudeNet|EcoCNN_v1
66	12	ahmed		http://localhost:8000/uploads/0151cb9255214af894b7e8c4b40eb047.jpg	une Tunisie verte 	2026-05-07 20:15:27.246281	2	published	0.4	Approuvé par l'administrateur	{"score": 0.4, "status": "pending_review", "reasons": ["Contenu potentiellement inapproprié", "Image eco-pertinente mais texte sans encouragement ni salutation (validation admin requise)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["vert"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.008, "severe_toxicity": 0.0, "obscene": 0.005, "identity_attack": 0.008, "insult": 0.002, "threat": 0.001, "sexual_explicit": 0.001, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.008, "severe_toxicity": 0.0, "obscene": 0.005, "identity_attack": 0.008, "insult": 0.002, "threat": 0.001, "sexual_explicit": 0.001, "cnn_text": {"eco": 0.3424, "off_topic": 0.6083, "toxic": 0.0493, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.35, "processing_time_ms": 102.55, "cnn_probs": {"eco": 0.3424, "off_topic": 0.6083, "toxic": 0.0493}, "cnn_decision": "off_topic"}, "image_analysis": {"categories": {"nsfw": {"score": 0.0, "severity": "medium"}, "resnet_image": {"eco": 0.8493, "nsfw": 0.097, "off_topic": 0.0537, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.0, "processing_time_ms": 74.19, "resnet_probs": {"eco": 0.8493, "nsfw": 0.097, "off_topic": 0.0537}, "resnet_decision": "eco"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 313.35, "languages_detected": ["fr"]}	\N	\N
95	12	ahmed	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	http://127.0.0.1:8000/uploads/bd53801ebb584c3da57e332035bc0a6c.jpg	La famille 	2026-08-30 19:36:25.215452	0	pending_review	1	Texte sans contexte environnemental détecté | Image sans contexte environnemental détecté	{"score": 1.0, "status": "pending_review", "reasons": ["Texte sans contexte environnemental détecté", "Image sans contexte environnemental détecté", "Contenu hors sujet : publication non liee au tri, a la proprete ou a la sensibilisation environnementale (envoyee a l'administrateur)"], "text_analysis": {"languages": ["fr"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": [], "bonus": 0.0, "count": 0, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.0, "severe_toxicity": 0.0, "obscene": 0.0, "identity_attack": 0.0, "insult": 0.0, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4094, "off_topic": 0.3737, "toxic": 0.2169, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.0, "processing_time_ms": 129.93, "cnn_probs": {"eco": 0.4094, "off_topic": 0.3737, "toxic": 0.2169}, "cnn_decision": "uncertain"}, "image_analysis": {"categories": {"resnet_image": {"eco": 0.081, "nsfw": 0.1534, "off_topic": 0.7656, "description": "ResNet18 fine-tuné (eco/off_topic/nsfw)"}, "off_topic_image": {"score": 0.7656, "severity": "medium", "source": "ResNet18-CNN", "description": "Image hors-sujet detectable (en attente validation admin)"}}, "ml_used": true, "detections": [], "clip_analysis": {}, "score": 0.45, "processing_time_ms": 0.0, "resnet_probs": {"eco": 0.081, "nsfw": 0.1534, "off_topic": 0.7656}, "resnet_decision": "off_topic"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": "NudeNet", "confidence": 0.95, "processing_time_ms": 280.34, "languages_detected": ["fr"]}	2026-08-30 19:37:11.80366	Detoxify+XLM-RoBERTa|NudeNet|EcoCNN_v1
88	39	Om Mbarek	http://127.0.0.1:8000/uploads/5ce66409b577455ebe260c1b3ca6a8db.jpg		bonjour	2026-08-19 10:26:09.469779	1	published	0.005	Contenu approuvé automatiquement	{"score": 0.005, "status": "published", "reasons": [], "text_analysis": {"languages": ["unknown"], "ml_used": true, "categories": {"profanity": {"found": [], "score": 0.0, "severity": "none", "description": "Profanity/vulgar language"}, "anti_environmental": {"found": [], "score": 0.0, "severity": "none", "description": "Anti-environmental content"}, "positive_context": {"found": ["bonjour"], "bonus": 0.05, "count": 1, "description": "Positive context bonus"}, "off_topic": {"found": [], "score": 0.0, "severity": "none", "count": 0, "description": "Off-topic / hors sujet"}, "ml_toxicity": {"toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "description": "ML toxicity (Detoxify)"}, "toxicity": 0.003, "severe_toxicity": 0.001, "obscene": 0.013, "identity_attack": 0.001, "insult": 0.006, "threat": 0.0, "sexual_explicit": 0.0, "cnn_text": {"eco": 0.4605, "off_topic": 0.2719, "toxic": 0.2676, "description": "Text CNN (EcoTextCNN entraîné sur publications citoyennes)"}}, "rule_score": 0.0, "score": 0.005, "processing_time_ms": 212.39, "cnn_probs": {"eco": 0.4605, "off_topic": 0.2719, "toxic": 0.2676}, "cnn_decision": "eco"}, "image_analysis": {"score": 0.0, "categories": {}, "ml_used": false, "note": "no_image"}, "ml_available": true, "text_model_used": "Detoxify+XLM-RoBERTa", "image_model_used": null, "confidence": 0.95, "processing_time_ms": 281.54, "languages_detected": ["unknown"]}	2026-08-19 10:26:40.04416	Detoxify+XLM-RoBERTa|EcoCNN_v1
\.


--
-- Data for Name: quiz_submissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quiz_submissions (id, quiz_id, student_id, student_name, answers_json, score, max_score, feedback_json, ai_graded, submitted_at, graded_at) FROM stdin;
1	10	16	Amine T.	{"1": "B", "2": "C", "3": "B", "4": "A", "5": "B", "6": "B", "7": "A", "8": "B", "9": "B", "10": "B"}	9	10	{"score": 9.0, "max_score": 10, "total_correct": 9, "total_questions": 10, "details": [{"number": 1, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Correct ! Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique."}, {"number": 9, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Incorrect. Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre. La bonne réponse était A."}, {"number": 10, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées."}], "general_feedback": "Excellent travail ! Vous avez démontré une très bonne compréhension des concepts du développement durable et de l'écologie. Continuez à réviser les causes du changement climatique pour perfectionner vos connaissances. Bravo pour votre engagement !"}	t	2026-04-26 21:19:29.739966	2026-04-26 21:19:29.72701
2	10	16	Amine T.	{"1": "A", "2": "C", "3": "B", "4": "A", "5": "B", "6": "B", "7": "A", "8": "B", "9": "B", "10": "B"}	8	10	{"score": 8.0, "max_score": 10, "total_correct": 8, "total_questions": 10, "details": [{"number": 1, "student_answer": "A", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "Incorrect. Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Correct! Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct! La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct! La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Incorrect. Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}], "general_feedback": "Félicitations pour ce quiz ! Vous avez obtenu un très bon score. Continuez à réviser les concepts du développement durable et de l'impact humain sur l'environnement, notamment les causes du changement climatique et la définition du développement durable, pour parfaire vos connaissances."}	t	2026-04-26 21:51:26.352006	2026-04-26 21:51:26.335736
3	10	25	Chayma Tlatli	{"1": "A", "2": "C", "3": "B", "4": "A", "5": "B", "6": "B", "7": "A", "8": "B", "9": "B", "10": "B"}	8	10	{"score": 8.0, "max_score": 10, "total_correct": 8, "total_questions": 10, "details": [{"number": 1, "student_answer": "A", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}], "general_feedback": "Félicitations pour votre score ! Vous avez une bonne compréhension des concepts clés du développement durable et de l'écologie. Pour améliorer encore, je vous encourage à revoir les questions sur le développement durable et le changement climatique, qui sont des sujets fondamentaux. Continuez vos efforts !"}	t	2026-04-26 22:29:58.916403	2026-04-26 22:29:58.907107
4	10	24	Test Diag	{"1": "A", "2": "B", "3": "B", "4": "A", "5": "B", "6": "B", "7": "A", "8": "B", "9": "A", "10": "B"}	8	10	{"score": 8.0, "max_score": 10, "total_correct": 8, "total_questions": 10, "details": [{"number": 1, "student_answer": "A", "correct_answer": "B", "is_correct": false, "points": 0, "feedback": "Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "B", "correct_answer": "C", "is_correct": false, "points": 0, "feedback": "Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1, "feedback": "Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1, "feedback": "La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1, "feedback": "L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1, "feedback": "Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1, "feedback": "La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1, "feedback": "Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1, "feedback": "Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1, "feedback": "Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}], "general_feedback": "Félicitations pour ce quiz ! Vous avez obtenu un très bon score. Continuez à réviser les concepts de développement durable et d'énergies renouvelables pour maîtriser parfaitement ces sujets importants."}	t	2026-04-26 22:36:26.228493	2026-04-26 22:36:26.224859
5	10	12	ahmed	{"1": "A", "2": "C", "3": "B", "4": "A", "5": "C", "6": "B", "7": "C", "8": "B", "9": "A", "10": "C"}	6	10	{"score": 6.0, "max_score": 10, "total_correct": 6, "total_questions": 10, "details": [{"number": 1, "student_answer": "A", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "Incorrect. The correct answer was B. Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Correct! Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct! La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "C", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "Incorrect. The correct answer was B. L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "C", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Incorrect. The correct answer was A. La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct! Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct! Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "student_answer": "C", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "Incorrect. The correct answer was B. Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}], "general_feedback": "Bien joué pour ce quiz ! Vous avez une bonne compréhension des bases du développement durable et des actions écologiques. Pour améliorer votre score, je vous encourage à revoir les concepts d'empreinte carbone, de biodiversité et les gestes simples pour économiser l'eau. Continuez vos efforts !"}	t	2026-04-26 22:54:03.399055	2026-04-26 22:54:03.39197
6	10	29	ddd	{"1": "B", "2": "B", "3": "B", "4": "B", "5": "B", "6": "B", "7": "B", "8": "B", "9": "B", "10": "B"}	6	10	{"score": 6.0, "max_score": 10, "total_correct": 6, "total_questions": 10, "details": [{"number": 1, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "student_answer": "B", "correct_answer": "C", "is_correct": false, "points": 0.0, "feedback": "Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "student_answer": "B", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}], "general_feedback": "Félicitations pour votre participation au quiz ! Vous avez obtenu un bon score. Continuez à réviser les concepts liés aux énergies renouvelables, à la pollution de l'air, à la biodiversité et aux causes du changement climatique pour améliorer encore vos connaissances."}	t	2026-04-26 23:17:37.182298	2026-04-26 23:17:37.169914
7	12	12	ahmed	{"1": "B", "2": "A", "3": "A", "4": "A", "5": "C", "6": "A", "7": "A", "8": "C", "9": "D", "10": "D"}	8	10	{"score": 8.0, "max_score": 10, "total_correct": 8, "total_questions": 10, "details": [{"number": 1, "student_answer": "B", "correct_answer": "B", "is_correct": true, "points": 1.0, "feedback": "Correct ! L'objectif principal du tri est bien de faciliter le recyclage et la valorisation des déchets."}, {"number": 2, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les bouteilles en plastique sont généralement recyclables."}, {"number": 3, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Jeter des déchets dans la nature nuit gravement aux écosystèmes et à la santé."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les 3R signifient Réduire, Réutiliser, Recycler."}, {"number": 5, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Correct ! Privilégier les produits réutilisables est un excellent moyen de réduire la production de déchets."}, {"number": 6, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les déchets organiques peuvent être transformés en compost, un excellent amendement pour les sols."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Séparer les déchets par matière facilite grandement leur traitement et leur valorisation."}, {"number": 8, "student_answer": "C", "correct_answer": "C", "is_correct": true, "points": 1.0, "feedback": "Correct ! Réduire, réutiliser et trier correctement sont les gestes les plus respectueux de l'environnement."}, {"number": 9, "student_answer": "D", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Incorrect. Une matière recyclable après traitement devient une nouvelle matière première ou un nouveau produit, pas un déchet qui doit toujours être brûlé."}, {"number": 10, "student_answer": "D", "correct_answer": "A", "is_correct": false, "points": 0.0, "feedback": "Incorrect. L'action qui contribue le plus à une bonne gestion des déchets est de trier correctement à la source, et non d'éviter les points de collecte."}], "general_feedback": "Félicitations pour votre score ! Vous avez une très bonne compréhension des principes fondamentaux du tri et de la gestion des déchets. Continuez à réviser les points où vous avez eu des difficultés, notamment sur le devenir des matières recyclables et l'importance du tri à la source. Chaque geste compte pour l'environnement !"}	t	2026-08-19 11:15:35.860488	2026-08-19 11:15:35.856509
8	12	25	Chayma Tlatli	{"1": "A", "2": "A", "3": "A", "4": "A", "5": "A", "6": "A", "7": "A", "8": "A", "9": "A", "10": "A"}	7	10	{"score": 7.0, "max_score": 10, "total_correct": 7, "total_questions": 10, "details": [{"number": 1, "student_answer": "A", "correct_answer": "B", "is_correct": false, "points": 0.0, "feedback": "La bonne réponse est B. Le tri des déchets vise à faciliter leur recyclage et leur valorisation, pas à les mélanger."}, {"number": 2, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les bouteilles en plastique sont généralement recyclables."}, {"number": 3, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Jeter des déchets dans la nature nuit aux écosystèmes et à la santé."}, {"number": 4, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les 3R signifient Réduire, Réutiliser, Recycler."}, {"number": 5, "student_answer": "A", "correct_answer": "C", "is_correct": false, "points": 0.0, "feedback": "La bonne réponse est C. Privilégier les produits réutilisables réduit la production de déchets, contrairement à l'utilisation de produits jetables."}, {"number": 6, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Les déchets organiques peuvent être transformés en compost."}, {"number": 7, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Séparer les déchets par matière facilite leur traitement et leur valorisation."}, {"number": 8, "student_answer": "A", "correct_answer": "C", "is_correct": false, "points": 0.0, "feedback": "La bonne réponse est C. Réduire, réutiliser et trier correctement sont les comportements les plus respectueux de l'environnement."}, {"number": 9, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Une matière recyclable peut devenir une nouvelle matière première ou un nouveau produit."}, {"number": 10, "student_answer": "A", "correct_answer": "A", "is_correct": true, "points": 1.0, "feedback": "Correct ! Le tri correct à la source est essentiel pour une bonne gestion des déchets."}], "general_feedback": "Félicitations pour votre score de 7/10 ! Vous avez une bonne compréhension des bases du tri et du recyclage. Pour améliorer encore, je vous conseille de revoir les principes des 3R et l'objectif principal du tri des déchets. Continuez vos efforts !"}	t	2026-08-21 22:34:11.744402	2026-08-21 22:34:11.742397
\.


--
-- Data for Name: quizzes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quizzes (id, educator_id, title, description, pdf_filename, questions_json, answer_key_json, total_questions, status, error_message, created_at) FROM stdin;
10	2	quiz_environnement	\N	quiz_b61093aa9cdf4f898f95fe7220489d48.pdf	[{"number": 1, "question": "Le développement durable signifie :", "type": "mcq", "options": ["A. Gaspiller les ressources sans limite", "B. Protéger les ressources pour les générations futures", "C. Utiliser uniquement le pétrole"], "correct_answer": "B", "explanation": "Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "question": "Quelle est une énergie renouvelable ?", "type": "mcq", "options": ["A. Charbon", "B. Gaz naturel", "C. Soleil"], "correct_answer": "C", "explanation": "Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "question": "Le recyclage consiste à :", "type": "mcq", "options": ["A. Jeter les déchets", "B. Transformer les déchets en nouveaux produits", "C. Brûler les déchets"], "correct_answer": "B", "explanation": "Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "question": "La pollution de l'air peut causer :", "type": "mcq", "options": ["A. Des maladies respiratoires", "B. Une meilleure santé", "C. Aucun effet"], "correct_answer": "A", "explanation": "La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "question": "L'empreinte carbone mesure :", "type": "mcq", "options": ["A. La taille du pied", "B. Les émissions de CO2", "C. La consommation d'eau"], "correct_answer": "B", "explanation": "L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "question": "Le plastique est un problème car :", "type": "mcq", "options": ["A. Il disparaît rapidement", "B. Il pollue durablement", "C. Il nourrit les animaux"], "correct_answer": "B", "explanation": "Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "question": "La biodiversité représente :", "type": "mcq", "options": ["A. Les différentes espèces vivantes", "B. Les bâtiments", "C. Les routes"], "correct_answer": "A", "explanation": "La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "question": "Une action écologique est :", "type": "mcq", "options": ["A. Gaspiller l'eau", "B. Trier les déchets", "C. Laisser les lumières allumées"], "correct_answer": "B", "explanation": "Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "question": "Le changement climatique est causé par :", "type": "mcq", "options": ["A. Les activités humaines", "B. Les arbres", "C. Les océans uniquement"], "correct_answer": "A", "explanation": "Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "question": "Pour économiser l'eau, on peut :", "type": "mcq", "options": ["A. Laisser couler le robinet", "B. Prendre des douches courtes", "C. Arroser en plein soleil"], "correct_answer": "B", "explanation": "Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}]	[{"number": 1, "correct_answer": "B", "explanation": "Le développement durable vise à répondre aux besoins du présent sans compromettre la capacité des générations futures à répondre aux leurs, en protégeant les ressources."}, {"number": 2, "correct_answer": "C", "explanation": "Le soleil est une source d'énergie renouvelable (énergie solaire), contrairement au charbon et au gaz naturel qui sont des énergies fossiles non renouvelables."}, {"number": 3, "correct_answer": "B", "explanation": "Le recyclage est le processus de transformation des déchets en nouveaux matériaux ou produits pour réduire le gaspillage et la consommation de ressources vierges."}, {"number": 4, "correct_answer": "A", "explanation": "La pollution de l'air est un facteur majeur de maladies respiratoires (asthme, bronchite, etc.) et d'autres problèmes de santé."}, {"number": 5, "correct_answer": "B", "explanation": "L'empreinte carbone est une mesure de la quantité totale de gaz à effet de serre (principalement le CO2) émise directement ou indirectement par une activité, un produit ou un individu."}, {"number": 6, "correct_answer": "B", "explanation": "Le plastique est un problème environnemental majeur car il se dégrade très lentement (polluant durablement les écosystèmes) et peut nuire à la faune."}, {"number": 7, "correct_answer": "A", "explanation": "La biodiversité désigne la variété de la vie sur Terre, incluant la diversité des espèces, des écosystèmes et des gènes."}, {"number": 8, "correct_answer": "B", "explanation": "Trier les déchets permet leur recyclage et réduit l'impact environnemental, ce qui est une action écologique. Gaspiller l'eau et laisser les lumières allumées sont des actions non écologiques."}, {"number": 9, "correct_answer": "A", "explanation": "Le changement climatique actuel est principalement attribué aux activités humaines, notamment la combustion de combustibles fossiles et la déforestation, qui augmentent les émissions de gaz à effet de serre."}, {"number": 10, "correct_answer": "B", "explanation": "Prendre des douches courtes réduit significativement la consommation d'eau par rapport aux bains ou aux douches prolongées. Laisser couler le robinet et arroser en plein soleil sont des actions qui gaspillent l'eau."}]	10	ready	\N	2026-04-26 21:14:48.382535
12	2	_temp_Quiz_Environnement_Tri_des_Dechets	\N	quiz_87e78abb2c4148f181f1c8f7685b56fc.pdf	[{"number": 1, "question": "Quel est l'objectif principal du tri des déchets ?", "type": "mcq", "options": ["A. Mélanger tous les déchets", "B. Faciliter leur recyclage et leur valorisation", "C. Augmenter la quantité de déchets", "D. Éviter toute collecte"], "correct_answer": "B", "explanation": "Le tri des déchets permet de séparer les matériaux pour qu'ils puissent être traités et réutilisés, réduisant ainsi le gaspillage et l'impact environnemental."}, {"number": 2, "question": "Lequel de ces déchets est généralement recyclable ?", "type": "mcq", "options": ["A. Une bouteille en plastique", "B. Un mouchoir usagé", "C. Une couche usagée", "D. Un déchet alimentaire"], "correct_answer": "A", "explanation": "Les bouteilles en plastique sont couramment recyclées pour fabriquer de nouveaux produits. Les autres options sont des déchets non recyclables dans les filières classiques."}, {"number": 3, "question": "Pourquoi faut-il éviter de jeter les déchets dans la nature ?", "type": "mcq", "options": ["A. Pour protéger les écosystèmes et la santé", "B. Pour accélérer leur disparition", "C. Pour augmenter la pollution des sols", "D. Pour réduire la biodiversité"], "correct_answer": "A", "explanation": "Jeter des déchets dans la nature pollue les sols et l'eau, nuit à la faune et la flore, et peut avoir des conséquences néfastes sur la santé humaine."}, {"number": 4, "question": "Que signifie le principe des 3R ?", "type": "mcq", "options": ["A. Réduire, Réutiliser, Recycler", "B. Ramasser, Ranger, Réparer", "C. Réduire, Remplacer, Rejeter", "D. Recycler, Rejeter, Répandre"], "correct_answer": "A", "explanation": "Les 3R sont les piliers de la gestion durable des déchets : Réduire la consommation, Réutiliser les objets et Recycler les matériaux."}, {"number": 5, "question": "Quel geste permet de réduire la production de déchets ?", "type": "mcq", "options": ["A. Utiliser des produits jetables", "B. Acheter systématiquement des emballages multiples", "C. Privilégier les produits réutilisables", "D. Jeter les objets encore utilisables"], "correct_answer": "C", "explanation": "Choisir des produits réutilisables (sacs, bouteilles, contenants) réduit la quantité de déchets générés par les produits à usage unique."}, {"number": 6, "question": "Les déchets organiques peuvent notamment être transformés en :", "type": "mcq", "options": ["A. Compost", "B. Verre", "C. Métal", "D. Plastique"], "correct_answer": "A", "explanation": "Les déchets organiques (restes alimentaires, déchets de jardin) peuvent être compostés pour produire un amendement naturel pour les sols."}, {"number": 7, "question": "Pourquoi séparer les déchets selon leur matière ?", "type": "mcq", "options": ["A. Pour faciliter leur traitement et leur valorisation", "B. Pour rendre la collecte plus difficile", "C. Pour augmenter leur volume", "D. Pour empêcher tout recyclage"], "correct_answer": "A", "explanation": "Séparer les déchets par matière (plastique, verre, papier, métal) permet de les orienter vers les filières de traitement et de recyclage appropriées, optimisant ainsi leur valorisation."}, {"number": 8, "question": "Quel comportement est le plus respectueux de l'environnement ?", "type": "mcq", "options": ["A. Jeter les déchets au sol", "B. Brûler les déchets à l'air libre", "C. Réduire, réutiliser et trier correctement", "D. Mélanger les déchets recyclables"], "correct_answer": "C", "explanation": "L'approche la plus respectueuse de l'environnement est de minimiser la production de déchets (réduire), prolonger la durée de vie des objets (réutiliser) et séparer correctement ceux qui peuvent être recyclés (trier)."}, {"number": 9, "question": "Que peut devenir une matière recyclable après traitement ?", "type": "mcq", "options": ["A. Une nouvelle matière première ou un nouveau produit", "B. Un déchet automatiquement toxique", "C. Un produit qui ne peut jamais être réutilisé", "D. Un déchet qui doit toujours être brûlé"], "correct_answer": "A", "explanation": "Après traitement, les matières recyclables sont transformées en nouvelles matières premières qui peuvent être utilisées pour fabriquer de nouveaux produits, bouclant ainsi la boucle du recyclage."}, {"number": 10, "question": "Quelle action contribue le plus à une bonne gestion des déchets ?", "type": "mcq", "options": ["A. Trier correctement à la source", "B. Tout jeter dans la même poubelle", "C. Abandonner les déchets dans la rue", "D. Éviter les points de collecte"], "correct_answer": "A", "explanation": "Le tri à la source est fondamental car il assure que les déchets sont séparés dès le départ, ce qui est essentiel pour leur recyclage et leur valorisation ultérieure."}]	[{"number": 1, "correct_answer": "B", "explanation": "Le tri des déchets permet de séparer les matériaux pour qu'ils puissent être traités et réutilisés, réduisant ainsi le gaspillage et l'impact environnemental."}, {"number": 2, "correct_answer": "A", "explanation": "Les bouteilles en plastique sont couramment recyclées pour fabriquer de nouveaux produits. Les autres options sont des déchets non recyclables dans les filières classiques."}, {"number": 3, "correct_answer": "A", "explanation": "Jeter des déchets dans la nature pollue les sols et l'eau, nuit à la faune et la flore, et peut avoir des conséquences néfastes sur la santé humaine."}, {"number": 4, "correct_answer": "A", "explanation": "Les 3R sont les piliers de la gestion durable des déchets : Réduire la consommation, Réutiliser les objets et Recycler les matériaux."}, {"number": 5, "correct_answer": "C", "explanation": "Choisir des produits réutilisables (sacs, bouteilles, contenants) réduit la quantité de déchets générés par les produits à usage unique."}, {"number": 6, "correct_answer": "A", "explanation": "Les déchets organiques (restes alimentaires, déchets de jardin) peuvent être compostés pour produire un amendement naturel pour les sols."}, {"number": 7, "correct_answer": "A", "explanation": "Séparer les déchets par matière (plastique, verre, papier, métal) permet de les orienter vers les filières de traitement et de recyclage appropriées, optimisant ainsi leur valorisation."}, {"number": 8, "correct_answer": "C", "explanation": "L'approche la plus respectueuse de l'environnement est de minimiser la production de déchets (réduire), prolonger la durée de vie des objets (réutiliser) et séparer correctement ceux qui peuvent être recyclés (trier)."}, {"number": 9, "correct_answer": "A", "explanation": "Après traitement, les matières recyclables sont transformées en nouvelles matières premières qui peuvent être utilisées pour fabriquer de nouveaux produits, bouclant ainsi la boucle du recyclage."}, {"number": 10, "correct_answer": "A", "explanation": "Le tri à la source est fondamental car il assure que les déchets sont séparés dès le départ, ce qui est essentiel pour leur recyclage et leur valorisation ultérieure."}]	10	ready	\N	2026-08-19 11:12:31.67981
13	2	dechets_Environnement_2	\N	quiz_9726de8515694173b9bf7464cf547f45.pdf	[{"number": 1, "question": "Quel déchet peut être transformé en compost?", "type": "mcq", "options": ["A. Une bouteille en verre", "B. Un reste de fruits et légumes", "C. Une pile", "D. Un sac plastique"], "correct_answer": "B", "explanation": "Les restes de fruits et légumes sont des matières organiques qui se décomposent naturellement pour former du compost."}, {"number": 2, "question": "Pourquoi faut-il trier les déchets ?", "type": "mcq", "options": ["A. Pour augmenter la pollution", "B. Pour faciliter leur recyclage et leur traitement", "C. Pour produire plus de déchets", "D. Pour éviter la réutilisation"], "correct_answer": "B", "explanation": "Le tri des déchets permet de séparer les matériaux recyclables et de faciliter leur traitement spécifique, réduisant ainsi l'impact environnemental."}, {"number": 3, "question": "Quel objet est généralement recyclable ?", "type": "mcq", "options": ["A. Une bouteille en plastique", "B. Un mouchoir utilisé", "C. Une couche usagée", "D. Une éponge sale"], "correct_answer": "A", "explanation": "Les bouteilles en plastique sont couramment recyclées pour fabriquer de nouveaux produits. Les autres options sont des déchets non recyclables ou contaminés."}, {"number": 4, "question": "Quelle action permet de réduire les déchets ?", "type": "mcq", "options": ["A. Utiliser des produits jetables", "B. Acheter uniquement des produits très emballés", "C. Utiliser une gourde réutilisable", "D. Jeter les objets réparables"], "correct_answer": "C", "explanation": "Utiliser une gourde réutilisable réduit la consommation de bouteilles en plastique jetables, diminuant ainsi la quantité de déchets."}, {"number": 5, "question": "Que signifie le principe des 3R ?", "type": "mcq", "options": ["A. Recycler, jeter, brûler", "B. Réduire, Réutiliser, Recycler", "C. Ramasser, réparer, rejeter", "D. Réduire, remplacer, rejeter"], "correct_answer": "B", "explanation": "Le principe des 3R signifie 'Réduire' (sa consommation), 'Réutiliser' (les objets) et 'Recycler' (les matériaux)."}, {"number": 6, "question": "Pourquoi les déchets plastiques sont-ils problématiques ?", "type": "mcq", "options": ["A. Ils disparaissent rapidement", "B. Ils peuvent rester longtemps dans l'environnement", "C. Ils améliorent les sols", "D. Ils sont toujours biodégradables"], "correct_answer": "B", "explanation": "Les plastiques sont des matériaux non biodégradables qui se dégradent très lentement, persistant des centaines d'années dans l'environnement et causant de la pollution."}, {"number": 7, "question": "Où doit-on déposer une pile usagée ?", "type": "mcq", "options": ["A. Dans la nature", "B. Dans le compost", "C. Dans un point de collecte adapté", "D. Dans l'évier"], "correct_answer": "C", "explanation": "Les piles contiennent des substances toxiques et doivent être déposées dans des points de collecte spécifiques pour être recyclées ou traitées correctement."}, {"number": 8, "question": "Quelle est une bonne pratique pour préserver l'eau ?", "type": "mcq", "options": ["A. Laisser couler le robinet inutilement", "B. Jeter les produits chimiques dans l'évier", "C. Éviter le gaspillage d'eau", "D. Polluer les cours d'eau"], "correct_answer": "C", "explanation": "Éviter le gaspillage d'eau, par exemple en fermant le robinet pendant le brossage des dents, est essentiel pour préserver cette ressource."}, {"number": 9, "question": "Que favorise la réutilisation des objets ?", "type": "mcq", "options": ["A. La réduction des déchets", "B. L'augmentation de la pollution", "C. Le gaspillage des ressources", "D. La production de déchets dangereux"], "correct_answer": "A", "explanation": "La réutilisation des objets prolonge leur durée de vie et réduit la nécessité de produire de nouveaux articles, ce qui diminue la quantité de déchets générés."}, {"number": 10, "question": "Quel comportement protège le mieux l'environnement?", "type": "mcq", "options": ["A. Trier, réduire et réutiliser", "B. Jeter les déchets dans la rue", "C. Mélanger tous les déchets", "D. Utiliser davantage de produits jetables"], "correct_answer": "A", "explanation": "Trier les déchets, réduire sa consommation et réutiliser les objets sont des actions clés pour minimiser l'impact environnemental et protéger la planète."}]	[{"number": 1, "correct_answer": "B", "explanation": "Les restes de fruits et légumes sont des matières organiques qui se décomposent naturellement pour former du compost."}, {"number": 2, "correct_answer": "B", "explanation": "Le tri des déchets permet de séparer les matériaux recyclables et de faciliter leur traitement spécifique, réduisant ainsi l'impact environnemental."}, {"number": 3, "correct_answer": "A", "explanation": "Les bouteilles en plastique sont couramment recyclées pour fabriquer de nouveaux produits. Les autres options sont des déchets non recyclables ou contaminés."}, {"number": 4, "correct_answer": "C", "explanation": "Utiliser une gourde réutilisable réduit la consommation de bouteilles en plastique jetables, diminuant ainsi la quantité de déchets."}, {"number": 5, "correct_answer": "B", "explanation": "Le principe des 3R signifie 'Réduire' (sa consommation), 'Réutiliser' (les objets) et 'Recycler' (les matériaux)."}, {"number": 6, "correct_answer": "B", "explanation": "Les plastiques sont des matériaux non biodégradables qui se dégradent très lentement, persistant des centaines d'années dans l'environnement et causant de la pollution."}, {"number": 7, "correct_answer": "C", "explanation": "Les piles contiennent des substances toxiques et doivent être déposées dans des points de collecte spécifiques pour être recyclées ou traitées correctement."}, {"number": 8, "correct_answer": "C", "explanation": "Éviter le gaspillage d'eau, par exemple en fermant le robinet pendant le brossage des dents, est essentiel pour préserver cette ressource."}, {"number": 9, "correct_answer": "A", "explanation": "La réutilisation des objets prolonge leur durée de vie et réduit la nécessité de produire de nouveaux articles, ce qui diminue la quantité de déchets générés."}, {"number": 10, "correct_answer": "A", "explanation": "Trier les déchets, réduire sa consommation et réutiliser les objets sont des actions clés pour minimiser l'impact environnemental et protéger la planète."}]	10	ready	\N	2026-09-04 08:30:15.687235
\.


--
-- Data for Name: saved_posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.saved_posts (id, user_id, post_id, saved_at) FROM stdin;
2	17	3	2026-02-13 17:30:13.576955
5	12	3	2026-02-15 21:21:33.872679
6	23	3	2026-02-16 22:47:39.696771
7	29	3	2026-03-30 17:59:21.031187
8	16	3	2026-03-30 18:38:32.581295
9	29	4	2026-03-30 21:24:01.969681
10	24	3	2026-04-01 18:46:59.939309
11	16	4	2026-04-01 21:05:02.05761
12	24	5	2026-04-01 21:06:03.724768
16	12	66	2026-06-14 19:32:09.261017
26	16	72	2026-08-19 09:40:48.859156
28	39	74	2026-08-19 10:25:34.85627
29	39	70	2026-08-19 10:25:38.803447
27	16	\N	2026-08-19 10:05:32.647595
30	12	\N	2026-08-19 12:34:59.8933
39	25	91	2026-08-21 22:32:42.991942
\.


--
-- Data for Name: smart_bins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.smart_bins (id, bin_code, collection_point_id, bin_type, capacity_kg, status, location_note, created_at) FROM stdin;
1	BIN-PLASTIQUE-001	\N	plastique	50	active	Entree principale	2026-06-12 18:13:06.199362
2	BIN-VERRE-001	\N	verre	60	active	Parking A	2026-06-12 18:13:07.345801
3	BIN-PAPIER-001	\N	papier	40	active	Batiment B	2026-06-12 18:13:07.486891
4	BIN-METAL-001	\N	metal	80	active	Zone industrielle	2026-06-12 18:13:07.622212
5	BIN-ORGANIQUE-001	\N	organique	30	active	Marche central	2026-06-12 18:13:07.766573
6	BIN-GENERAL-001	\N	general	2.5	active	Place publique	2026-06-12 18:13:07.902322
\.


--
-- Data for Name: testimonials; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testimonials (id, user_id, user_name, user_avatar_url, content, rating, is_approved, is_featured, created_at) FROM stdin;
1	16	Amine T.	http://localhost:8000/uploads/f5c43e68cb8b41b09d86857d7e6095e2.png	Good Idea	5	t	f	2026-04-08 20:34:24.440597
2	16	Amine T.	http://localhost:8000/uploads/f5c43e68cb8b41b09d86857d7e6095e2.png	perfect	5	t	t	2026-04-08 21:59:03.933174
3	24	Test Diag	http://localhost:8000/uploads/d77f747cc0474b41a04ca68c3598e33b.png	Proud	5	t	f	2026-04-08 22:01:33.178618
4	31	Backend Test	\N	Super app!	5	f	f	2026-05-19 23:54:31.983143
5	12	ahmed	\N	excelente app	5	t	f	2026-07-26 12:38:13.201673
6	39	Om Mbarek	http://127.0.0.1:8000/uploads/5ce66409b577455ebe260c1b3ca6a8db.jpg	excellente application	5	f	f	2026-08-19 10:27:46.296362
7	25	Chayma Tlatli	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	Magnifique application	5	f	f	2026-08-23 15:52:22.55559
\.


--
-- Data for Name: user_rewards; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_rewards (id, user_id, reward_key, reward_type, label, description, icon, unlocked_at, notified) FROM stdin;
1	26	badge_eco_citoyen	badge	Badge Éco-Citoyen	Félicitations ! Vous avez rejoint la communauté EcoRewind.	🌱	2026-07-15 01:34:51.701095	f
2	26	badge_champion_vert	badge	Badge Champion Vert	Vous avez atteint 2 000 points — un vrai champion du recyclage !	🏆	2026-07-15 01:34:51.701095	f
3	26	avatar_frame_champion	feature	Cadre d'avatar Champion	Cadre doré exclusif pour votre photo de profil.	🖼️	2026-07-15 01:34:51.701095	f
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, email, full_name, hashed_password, is_active, is_verified, role, google_id, facebook_id, qr_code, reset_token, token_expires, avatar_url, global_score, created_at, fcm_token, mfa_enabled, mfa_secret) FROM stdin;
2	educateur@tridechet.tn	Educateur Test	$2b$12$HqviVA5x3pGKsPl0SJoqV.TBNkPuWSeVzUQcG2kUu.KVATT.68yV6	t	t	educator	\N	\N	TRIDECHET-ea6b3ef4-9259-4312-91c5-af4fb2c7754c	\N	\N	http://127.0.0.1:8000/uploads/db3495d32f9a447e9779d72edfa477e7.jpg	0	2026-06-08 12:34:56.823186	\N	f	MH2QPEPFU7C3LMTEPJZA7EYQAX73JMLS
43	c4531134@gmail.com	Chayma		t	f	citoyen	110324187242502675838	\N	ECOREWIND-c9c9d82d-8d3c-4761-806c-fa73cfc9c8a2	\N	\N	\N	0	2026-09-02 10:39:18.457194	\N	f	\N
39	mbarekom102@gmail.com	Om Mbarek		t	f	citoyen	116794192285580272790	\N	ECOREWIND-7eaaf191-9ba3-4b45-bda1-997f17e18aa5	958325	2026-08-18T00:08:59.980626	http://127.0.0.1:8000/uploads/5ce66409b577455ebe260c1b3ca6a8db.jpg	0	2026-08-17 21:59:37.140179	\N	f	\N
42	abc@gmail.com	abc	$2b$12$hI.yZ1mZ9ouF.weTfLlYce7V6B6QWhWE2SvCy0zZXqtGeZGKFXNZG	t	f	citoyen	\N	\N	ECOREWIND-eab1e51d-bba4-4fbd-92b0-d2652971d16a	\N	\N	\N	0	2026-08-20 11:03:59.644235	\N	f	\N
1	admin@tridechet.tn	Admin	$2b$12$QNZ/5mTD.DrjfrbxCeB81eRnvdHhGVh5L7YyuxraF7idUM/Qh61zy	t	t	admin	\N	\N	TRIDECHET-aaa433a8-7683-4574-8fa7-64b600916f0c	\N	\N	http://127.0.0.1:8000/uploads/e26ca73c2a5d42dcad08cfc1ba63d5e2.jpg	0	2026-06-08 12:34:56.823186	\N	f	4P3H4OV7UWO5IR37D7IRWAR3PDO7XH5G
3	pointmanager@tridechet.tn	Gestionnaire Points	$2b$12$LoaWfzTy3nbx1pEC/Vs9felfBXm910zhGd0eIADh.30eW2.YDaMh2	t	t	pointManager	\N	\N	TRIDECHET-0d600f17-68ad-499a-a14e-969ec1a07957	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	TEST_SECRET
10	hassen@gmail.com	hassen dimassi	$2b$12$qhD3xqUxgtAUh9zgnCTuguNgoXd8/A/e3yvh72uJYe76Ccoa//5vy	t	t	educateur	\N	\N	TRIDECHET-0af1c831-aa19-402c-9681-19daaeafcdb8	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
18	amel@tridechet.tn	Amel Ben Saleh	$2b$12$SGhZISAv97.TLy2UxpwIseffR7h3kLYwE7eJSQAffQMntI7FZQxTa	t	t	educator	\N	\N	TRIDECHET-6c255f7b-2114-4f0c-9829-06b2b6b63793	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
19	tunis@tridechet.tn	Grand Tunis	$2b$12$4ULILOxTlaTR4TSKU060cOP0XkEi7YFLrpqIocCXGp036Ti6cR5MG	t	t	intercommunality	\N	\N	TRIDECHET-0a0865b0-b974-46f8-bb46-5110983acf7a	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
40	omarmbarek758@gmail.com	omar mbarek	$2b$12$T62usYI4SupzvLKV1PixgOK3c34ELMmnBlrOHYM.MJF5LxFJtR9Xm	t	t	citoyen	\N	\N	ECOREWIND-c3097d42-44a4-4a4f-86d7-975fbd4ef49a	\N	\N	\N	0	2026-08-17 22:03:27.909131	\N	f	\N
4	collecteur@tridechet.tn	Collecteur Test	$2b$12$3BIkSy6B1oUtD52hx6i1V.ERzPnsKOtUTlgF5OhZNSWK1z1qtypF6	t	t	collector	\N	\N	TRIDECHET-02a49ca4-d370-4a22-813f-c154f1609063	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
13	chaayma.tlatli@gmail.com	chayma tlatli	$2b$12$C8hFRcdF3kDiPvKbEIVAR.RCtNceTyQUadAdmXZTNOM/ZpGg9lJWe	t	t	pointManager	\N	\N	TRIDECHET-dbcbadb2-54da-4fbf-8570-4bc1cb20c308	226320	2026-09-02T13:46:01.586786	\N	0	2026-06-08 12:34:56.823186	\N	f	BCTOSKKCUM2POTA4ATR2VMPOP3U2BAAL
38	superadmin@gmail.com	Super Administrateur	$2b$12$ONlo7/SHyhRlWs6Tu6e/ReRdyqAlWHVj6vJZT6fIGGO72yLFWZ4Pq	t	f	superadmin	\N	\N	ECOREWIND-c2d48c39-89bc-4f9a-9523-de1f05253c66	\N	\N	\N	0	2026-06-18 23:35:22.184357	\N	f	3QVVIZWCIIVR5CLXHCHN3DYMDSIDZPKO
21	eco@tridechet.tn	Eco-Collecte TN	$2b$12$h4wNU4rL1t0Zm8AhVbmbgu5rrGtbo7/xjv0Dr26YAR4m2Q0Ieki.u	t	t	collector	\N	\N	TRIDECHET-7cb9ced2-2185-48e7-a1a2-955e4e7c3ea6	\N	\N	\N	0	2026-06-08 12:34:56.823186	czZb0FAPQbGNvZsuR7EQ4l:APA91bFDUJSexmeu4E6mQY_V6Lk-MwE1E_PuGP-uRFXOaSPMljBVG07RVOh9MDxgxYtaibil32QX0z6rEaGNbL33Tc-1SgwOHm-m3V2Gl60t8Twk_L282s8	f	H3RDEM3OUAPQ33YGS5R5Z7AVB6LSGGJT
31	backendtest@eco.tn	Backend Tester Updated	$2b$12$n1HMW2xN31xsBEk/rkbkA.2I5pRu3f1BydLKdsfMnY3aM0kBIu33S	t	f	admin	\N	\N	ECOREWIND-80ef10f2-7309-451f-b7a2-4fa824ac3e65	245834	2026-05-20T00:54:32.874243	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
44	chemadhouib3@gmail.com	rihem	$2b$12$CvuQcCwOAXQzgJNqVGWoQ.kwMRSQRxTPplHSUXJ8oNcfxVlxg3g5O	t	t	citoyen	\N	\N	ECOREWIND-74ef773d-3e3f-47dd-9148-195700251fe8	\N	\N	\N	0	2026-09-03 18:55:57.059706	\N	f	\N
33	educator_1f8f04dc@test.com	Test Educator Unique	$2b$12$pU3UKuYx9kYg12ApfXv7BulHUhZ2YVQqH07VAsfOnSueSfGzMc17i	t	f	educator	\N	\N	ECOREWIND-25151938-20b1-4138-a4f6-cf6f8b9c448a	\N	\N	\N	0	2026-06-18 19:04:27.954009	\N	f	\N
34	educator_3f84374c@test.com	Test Educator Unique	$2b$12$sKeOFN4pN8xO1SLpyaEWseyq6fjy367vRMWn3uVGwLvXb8gS93tYq	t	f	educator	\N	\N	ECOREWIND-156328c9-e4a0-4a8a-9d22-32f1e8f1250c	\N	\N	\N	0	2026-06-18 19:06:13.136463	\N	f	\N
35	educator_e4be5c29@test.com	Test Educator Unique	$2b$12$swhNBJjwcOgIBA3yBX4mh.If0gwHtpmQLr0poWok3F3qRMyj6YWtq	t	f	educator	\N	\N	ECOREWIND-295bffc0-727c-4f0e-847b-b805b0eb4e7c	\N	\N	\N	0	2026-06-18 19:17:38.285471	\N	f	\N
11	chichi@gmail.com	chiraz	$2b$12$26YYeOorvTysZzdkRFvxbuQwakz0t/0yqRSszNMFwrga2VWQXUTsK	t	t	collector	\N	\N	TRIDECHET-538cf881-452a-4eaa-b631-ad9f6b00faa2	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	YK5AYXTFZ24TVUP6CUZNSFJC6CXQNZVS
32	test_educator@test.com	Test Educator	$2b$12$njir9KYWVPCIIgxtQg6puurNOXaNzuOV.1a/2tys0Jc5Z7N3lgyw.	t	f	educator	\N	\N	ECOREWIND-c1c2a363-3e7d-4711-a8de-a387b52f15d2	\N	\N	\N	0	2026-06-18 19:03:04.258655	\N	f	\N
26	eyabenna303@gmail.com	chourouk	$2b$12$5X2Lfk36S1GyUJxzGvF.0uqvULQXQ3JTldk2le8jmgIxtJrFUSA0G	t	t	citoyen	\N	\N	TRIDECHET-7bbcbe86-963d-4ea2-9dbd-59c46c6a808a	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
36	educator_18798ee4@test.com	Test Educator Unique	$2b$12$TC8mNvYLUkQTSkfqrwhsxOSz4qS8hX8rInZv9XtKr2vw2i2rwuZGG	t	f	educator	\N	\N	ECOREWIND-a6ca49b6-d19a-4223-8eeb-bc4ee3ca696d	\N	\N	\N	0	2026-06-18 19:21:25.771625	\N	f	\N
20	sami@tridechet.tn	Sami (Gestionnaire)	$2b$12$.IMT6JXKMwnfnwrBt7A6Ie5LrnQIz3jxpd4cx.k3QgjXaA/LT3XD2	t	t	pointManager	\N	\N	TRIDECHET-4a14faa1-998e-487f-885a-2636fcc0567c	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
5	intercommunalite@tridechet.tn	Mairie Test	$2b$12$MmWNRfNKCmii2YibPYyUJuEpccXiBnUO8ISidwM6OjHftHsOHW4dW	t	t	intercommunality	\N	\N	TRIDECHET-673b07fc-43c5-46cd-b9d9-89d7039e2ce6	\N	\N	http://127.0.0.1:8000/uploads/a413071fb3ed452faac282f12d3a740b.jpg	0	2026-06-08 12:34:56.823186	f8xkXa4WSEmdoNPS-OEGH3:APA91bFom_HD-VNussOIRtNtcGfRJC8pNUTitpia6u4L-wSghC1gX75b24FZBqHB_y8Kb2AwPlWuVe1Ecx2VivgXEfltbt2YHi1uygHcll1jfjBOKOterVU	f	\N
27	otakuotakuu775@gmail.com	motaz	$2b$12$xrHKzwJGH/exFv1.8CovX.ofrcqpZnB/YLKwLSF3HCp5.5xSznkuC	t	t	citoyen	\N	\N	TRIDECHET-d7b37e01-5edc-47b2-8a76-20ecb418a669	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
28	yasmineboughzala5@gmail.com	ddd	$2b$12$p5u8zwsGaSjRNAK4PdwGS.xcycykRnNdbo99KoPN8Hrlse55o0bdq	t	f	citoyen	\N	\N	TRIDECHET-d3994db3-1cfb-4c44-b35c-2fb88f7b4cd7	\N	\N	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
29	tchayma2000@gmail.com	ddd	$2b$12$SsEHYPsh1ODiFhNxOj3xFuivgNqLZ3jmmiMDmaeAYKzv9H1X5VAbu	t	t	citoyen	\N	\N	TRIDECHET-3ebbad3e-5038-4765-813e-fe5a1b898570	\N	\N	\N	6	2026-06-08 12:34:56.823186	\N	f	\N
14	doua@tridechet.tn	doua	$2b$12$Za5saTNjPW589x0I3webQe6UlQNu1Dj2avUyWUfQvemo6MHKFMrG.	t	t	citoyen	\N	\N	TRIDECHET-b45ad1d3-6c7f-42fe-9118-3f28d0789363	\N	\N	\N	10	2026-06-08 12:34:56.823186	\N	f	\N
15	chouchou@tridechet.tn	chourouk	$2b$12$G2Eu0UIy.PpjJ89ycnSPs.XFa2AfvQiAfma2NJpox./DhyVjGGubC	t	t	citoyen	\N	\N	TRIDECHET-fa9eccc1-b57f-4b65-b3fc-6cca4297a9b9	\N	\N	\N	10	2026-06-08 12:34:56.823186	\N	f	\N
17	nono@tridechet.tn	nono	$2b$12$7XRmGAsGOsmXQ6bykOQay.VttBFUPbbmvR078y82cphxnvb/ce7Zq	t	t	citoyen	\N	\N	TRIDECHET-f21fe0d2-9511-4f1e-9b3f-8aee914e698b	\N	\N	\N	10	2026-06-08 12:34:56.823186	\N	f	\N
22	asmasalhi451@gmail.com	asma	$2b$12$9/P7bz58jJKE4SJzpz6FkeWYExryO25lih37nhxo9/JWYBGAsRzyS	t	t	citoyen	\N	\N	TRIDECHET-c193d30d-1236-41c2-bff9-b494ba5fe198	\N	\N	\N	10	2026-06-08 12:34:56.823186	\N	f	\N
30	aidaboughzala343@gmail.com	aida	$2b$12$w9hVV7sNWtVvVkm8798OM.HKPBo2dGjKa.DxlpTVpWOO72PeAm/jq	t	t	citoyen	\N	\N	ECOREWIND-3baa188b-dd08-4d26-a62c-c5ebabab037c	nQzr4kQq8_2b8ADHjGcMe0VwOnTG6Ayer70vTwJv4w4	2026-05-08T03:04:29.789256	\N	0	2026-06-08 12:34:56.823186	\N	f	\N
37	user_test_1867@tridechet.tn	Utilisateur Normal Test	$2b$12$cLYAq3/V7xycvYZBsMswcuvX/2cPIFXkMNDjUEcuGY0vLXqM8W9JG	t	f	citoyen	\N	\N	ECOREWIND-4cd3d8f0-6794-4df4-921d-3badf400c76c	\N	\N	\N	0	2026-06-18 23:07:13.844135	\N	f	\N
23	amel123@tridechet.tn	amel ben saleh	$2b$12$H3dCn1FGe.F0gFyDQcuNY.iZEAtQYVB8bmhSUp2yyVrK.xUL6vkg6	t	t	citoyen	\N	\N	TRIDECHET-07caff6d-635b-4261-9020-cb63e06b6a0e	\N	\N	\N	40	2026-06-08 12:34:56.823186	\N	f	\N
24	test_diag@test.com	Test Diag	$2b$12$Zk6hqqddPjUWEeECzYqfK.Bw41HTy0yrW7Xnrg9SZ50AJumUBuE6a	t	t	citoyen	\N	\N	TRIDECHET-8227bfeb-1119-444e-a6d7-5d242489fa46	422377	2026-06-29T23:56:21.839320	http://localhost:8000/uploads/d77f747cc0474b41a04ca68c3598e33b.png	8	2026-06-08 12:34:56.823186	e5gLKRiVQbKWKRof1cju8k:APA91bGMGity79oaG2jQgRMViAmt14rj2x3EOOGug80cjbvlr_tA214CghL2vwuOJfOc_CA15jsMBn8oqUHDSrnT5MKEV4gvJZq1w1Bi450fAQrPBpNdexM	f	\N
25	chaymalo5ra@gmail.com	Chayma Tlatli		t	t	citoyen	\N	4279481348996360	TRIDECHET-e6bcd0b4-56f1-4342-8caf-07e15a9e7568	\N	\N	http://127.0.0.1:8000/uploads/3b36a57947204a5599f71784448da085.jpg	15	2026-06-08 12:34:56.823186	\N	f	\N
45	+21653216956	chichy	$2b$12$EVa3nk4QS3NiwgwtJnsUbuLwc4mJiKMYJ.PGcoMHcLLcU7IY60J7W	t	f	citoyen	\N	\N	ECOREWIND-1274958f-9c0a-46aa-826b-588a4afe62ab	\N	\N	\N	0	2026-09-03 18:57:46.055787	\N	f	\N
41	admin@gmail.com	adem	$2b$12$MWkJIq1ptz.1zOm2kS4d9Ot/PubI9FhcRBEUSahrBA1XejlyajnCm	t	f	admin	\N	\N	ECOREWIND-bc2ea31f-8271-4cd7-94ee-932a1c6cd208	\N	\N	\N	0	2026-08-20 05:58:07.731683	\N	f	\N
12	ahmed@gmail.com	ahmed	$2b$12$O9LPxNjFQ0u.KJ/4JNzaCOcXYxFu.sIA1.PCSbXiuMfWerIkNC3ue	t	t	citoyen	\N	\N	TRIDECHET-dc152079-f1a7-4fb3-8ca1-c83466e5c91e	\N	\N	http://127.0.0.1:8000/uploads/7cf0965ed9094fcbbd55a69bd56697d8.jpg	5083	2026-06-08 12:34:56.823186	\N	f	\N
16	amine@tridechet.tn	Amine T.	$2b$12$dG7asabej815Q6hhEiwBve24nD5j1Ua1Lm5IZUwbialhrq/YAzF4W	t	t	citoyen	\N	\N	TRIDECHET-8804aea0-0308-42a8-983d-e9edefcad4e4	\N	\N	http://localhost:8000/uploads/14e4d3539c1749bf939737028570ecb3.jpg	1827	2026-06-08 12:34:56.823186	\N	f	6KF5JFCN7SPRSCPJJ7HWAFQBVVTHNJKU
\.


--
-- Data for Name: video_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.video_categories (id, title, description, cover_image_url, educator_id, created_at) FROM stdin;
1	L'cologie	\N	/uploads/covers/cover_b4ccf8fea3be4cfa955741eb4b31af16.jpeg	2	2026-04-27 13:16:48.110113
2	Astuces 	\N	/uploads/covers/cover_bf126fa079474f108d2425ce41c35faf.jpeg	2	2026-04-27 19:08:59.117798
3	recyclage 	\N	\N	2	2026-08-19 20:51:12.124327
4	cours	\N	/uploads/covers/cover_09b4e5cd1f5444be9ed6d208e62432b3.jpg	2	2026-08-19 20:53:13.633543
\.


--
-- Name: bin_scans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bin_scans_id_seq', 11, true);


--
-- Name: center_proposals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.center_proposals_id_seq', 8, true);


--
-- Name: citizen_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citizen_groups_id_seq', 7, true);


--
-- Name: citizen_reports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.citizen_reports_id_seq', 1, false);


--
-- Name: collection_points_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_points_id_seq', 19, true);


--
-- Name: collection_routes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collection_routes_id_seq', 1, false);


--
-- Name: collector_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collector_logs_id_seq', 1, false);


--
-- Name: collector_zone_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collector_zone_assignments_id_seq', 13, true);


--
-- Name: collector_zones_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.collector_zones_id_seq', 5, true);


--
-- Name: comments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_id_seq', 47, true);


--
-- Name: custom_actor_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.custom_actor_groups_id_seq', 1, true);


--
-- Name: educator_videos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.educator_videos_id_seq', 6, true);


--
-- Name: group_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.group_members_id_seq', 22, true);


--
-- Name: likes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.likes_id_seq', 34, true);


--
-- Name: local_instructions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.local_instructions_id_seq', 1, true);


--
-- Name: meeting_participants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meeting_participants_id_seq', 79, true);


--
-- Name: meetings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.meetings_id_seq', 8, true);


--
-- Name: message_group_recipients_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.message_group_recipients_id_seq', 5, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 33, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 243, true);


--
-- Name: otp_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.otp_codes_id_seq', 8, true);


--
-- Name: posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.posts_id_seq', 95, true);


--
-- Name: quiz_submissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quiz_submissions_id_seq', 8, true);


--
-- Name: quizzes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.quizzes_id_seq', 13, true);


--
-- Name: saved_posts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.saved_posts_id_seq', 39, true);


--
-- Name: smart_bins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.smart_bins_id_seq', 6, true);


--
-- Name: testimonials_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.testimonials_id_seq', 7, true);


--
-- Name: user_rewards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_rewards_id_seq', 3, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 45, true);


--
-- Name: video_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.video_categories_id_seq', 4, true);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: bin_scans bin_scans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bin_scans
    ADD CONSTRAINT bin_scans_pkey PRIMARY KEY (id);


--
-- Name: center_proposals center_proposals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.center_proposals
    ADD CONSTRAINT center_proposals_pkey PRIMARY KEY (id);


--
-- Name: citizen_groups citizen_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_groups
    ADD CONSTRAINT citizen_groups_pkey PRIMARY KEY (id);


--
-- Name: citizen_reports citizen_reports_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_reports
    ADD CONSTRAINT citizen_reports_pkey PRIMARY KEY (id);


--
-- Name: collection_points collection_points_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_points
    ADD CONSTRAINT collection_points_pkey PRIMARY KEY (id);


--
-- Name: collection_routes collection_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_routes
    ADD CONSTRAINT collection_routes_pkey PRIMARY KEY (id);


--
-- Name: collector_logs collector_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_logs
    ADD CONSTRAINT collector_logs_pkey PRIMARY KEY (id);


--
-- Name: collector_zone_assignments collector_zone_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_pkey PRIMARY KEY (id);


--
-- Name: collector_zones collector_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zones
    ADD CONSTRAINT collector_zones_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: custom_actor_groups custom_actor_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_actor_groups
    ADD CONSTRAINT custom_actor_groups_pkey PRIMARY KEY (id);


--
-- Name: educator_videos educator_videos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.educator_videos
    ADD CONSTRAINT educator_videos_pkey PRIMARY KEY (id);


--
-- Name: group_members group_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_pkey PRIMARY KEY (id);


--
-- Name: likes likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- Name: local_instructions local_instructions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.local_instructions
    ADD CONSTRAINT local_instructions_pkey PRIMARY KEY (id);


--
-- Name: meeting_participants meeting_participants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_participants
    ADD CONSTRAINT meeting_participants_pkey PRIMARY KEY (id);


--
-- Name: meetings meetings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_pkey PRIMARY KEY (id);


--
-- Name: message_group_recipients message_group_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_recipients
    ADD CONSTRAINT message_group_recipients_pkey PRIMARY KEY (id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: otp_codes otp_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.otp_codes
    ADD CONSTRAINT otp_codes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: quiz_submissions quiz_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_submissions
    ADD CONSTRAINT quiz_submissions_pkey PRIMARY KEY (id);


--
-- Name: quizzes quizzes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_pkey PRIMARY KEY (id);


--
-- Name: saved_posts saved_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_pkey PRIMARY KEY (id);


--
-- Name: smart_bins smart_bins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smart_bins
    ADD CONSTRAINT smart_bins_pkey PRIMARY KEY (id);


--
-- Name: testimonials testimonials_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_pkey PRIMARY KEY (id);


--
-- Name: user_rewards uq_user_rewards_user_reward; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT uq_user_rewards_user_reward UNIQUE (user_id, reward_key);


--
-- Name: user_rewards user_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT user_rewards_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: video_categories video_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_categories
    ADD CONSTRAINT video_categories_pkey PRIMARY KEY (id);


--
-- Name: ix_bin_scans_firebase_synced; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_firebase_synced ON public.bin_scans USING btree (firebase_synced);


--
-- Name: ix_bin_scans_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_id ON public.bin_scans USING btree (id);


--
-- Name: ix_bin_scans_points_earned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_points_earned ON public.bin_scans USING btree (points_earned);


--
-- Name: ix_bin_scans_scanned_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_scanned_at ON public.bin_scans USING btree (scanned_at);


--
-- Name: ix_bin_scans_smart_bin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_smart_bin_id ON public.bin_scans USING btree (smart_bin_id);


--
-- Name: ix_bin_scans_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_user_id ON public.bin_scans USING btree (user_id);


--
-- Name: ix_bin_scans_waste_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_bin_scans_waste_type ON public.bin_scans USING btree (waste_type);


--
-- Name: ix_center_proposals_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_center_proposals_id ON public.center_proposals USING btree (id);


--
-- Name: ix_center_proposals_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_center_proposals_status ON public.center_proposals USING btree (status);


--
-- Name: ix_center_proposals_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_center_proposals_user_id ON public.center_proposals USING btree (user_id);


--
-- Name: ix_citizen_groups_educator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_groups_educator_id ON public.citizen_groups USING btree (educator_id);


--
-- Name: ix_citizen_groups_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_groups_id ON public.citizen_groups USING btree (id);


--
-- Name: ix_citizen_reports_assigned_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_reports_assigned_to ON public.citizen_reports USING btree (assigned_to);


--
-- Name: ix_citizen_reports_collection_point_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_reports_collection_point_id ON public.citizen_reports USING btree (collection_point_id);


--
-- Name: ix_citizen_reports_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_reports_created_at ON public.citizen_reports USING btree (created_at);


--
-- Name: ix_citizen_reports_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_reports_status ON public.citizen_reports USING btree (status);


--
-- Name: ix_citizen_reports_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_citizen_reports_user_id ON public.citizen_reports USING btree (user_id);


--
-- Name: ix_collection_points_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collection_points_id ON public.collection_points USING btree (id);


--
-- Name: ix_collection_points_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collection_points_status ON public.collection_points USING btree (status);


--
-- Name: ix_collection_routes_collector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collection_routes_collector_id ON public.collection_routes USING btree (collector_id);


--
-- Name: ix_collection_routes_date_planned; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collection_routes_date_planned ON public.collection_routes USING btree (date_planned);


--
-- Name: ix_collection_routes_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collection_routes_status ON public.collection_routes USING btree (status);


--
-- Name: ix_collector_logs_bin_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_bin_code ON public.collector_logs USING btree (bin_code);


--
-- Name: ix_collector_logs_collected_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_collected_at ON public.collector_logs USING btree (collected_at);


--
-- Name: ix_collector_logs_collector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_collector_id ON public.collector_logs USING btree (collector_id);


--
-- Name: ix_collector_logs_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_id ON public.collector_logs USING btree (id);


--
-- Name: ix_collector_logs_notified; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_notified ON public.collector_logs USING btree (notified);


--
-- Name: ix_collector_logs_smart_bin_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_logs_smart_bin_id ON public.collector_logs USING btree (smart_bin_id);


--
-- Name: ix_collector_zone_assignments_assigned_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zone_assignments_assigned_at ON public.collector_zone_assignments USING btree (assigned_at);


--
-- Name: ix_collector_zone_assignments_collector_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zone_assignments_collector_id ON public.collector_zone_assignments USING btree (collector_id);


--
-- Name: ix_collector_zone_assignments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zone_assignments_id ON public.collector_zone_assignments USING btree (id);


--
-- Name: ix_collector_zone_assignments_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zone_assignments_status ON public.collector_zone_assignments USING btree (status);


--
-- Name: ix_collector_zone_assignments_zone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zone_assignments_zone_id ON public.collector_zone_assignments USING btree (zone_id);


--
-- Name: ix_collector_zones_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zones_id ON public.collector_zones USING btree (id);


--
-- Name: ix_collector_zones_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zones_name ON public.collector_zones USING btree (name);


--
-- Name: ix_collector_zones_territory; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_collector_zones_territory ON public.collector_zones USING btree (territory);


--
-- Name: ix_comments_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_comments_id ON public.comments USING btree (id);


--
-- Name: ix_custom_actor_groups_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_custom_actor_groups_created_by ON public.custom_actor_groups USING btree (created_by);


--
-- Name: ix_custom_actor_groups_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_custom_actor_groups_name ON public.custom_actor_groups USING btree (name);


--
-- Name: ix_educator_videos_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_educator_videos_category_id ON public.educator_videos USING btree (category_id);


--
-- Name: ix_educator_videos_educator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_educator_videos_educator_id ON public.educator_videos USING btree (educator_id);


--
-- Name: ix_educator_videos_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_educator_videos_id ON public.educator_videos USING btree (id);


--
-- Name: ix_group_members_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_group_members_group_id ON public.group_members USING btree (group_id);


--
-- Name: ix_group_members_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_group_members_id ON public.group_members USING btree (id);


--
-- Name: ix_group_members_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_group_members_user_id ON public.group_members USING btree (user_id);


--
-- Name: ix_likes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_likes_id ON public.likes USING btree (id);


--
-- Name: ix_local_instructions_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_local_instructions_city ON public.local_instructions USING btree (city);


--
-- Name: ix_local_instructions_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_local_instructions_is_active ON public.local_instructions USING btree (is_active);


--
-- Name: ix_local_instructions_territory; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_local_instructions_territory ON public.local_instructions USING btree (territory);


--
-- Name: ix_meeting_participants_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meeting_participants_id ON public.meeting_participants USING btree (id);


--
-- Name: ix_meeting_participants_meeting_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meeting_participants_meeting_id ON public.meeting_participants USING btree (meeting_id);


--
-- Name: ix_meeting_participants_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meeting_participants_user_id ON public.meeting_participants USING btree (user_id);


--
-- Name: ix_meetings_educator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meetings_educator_id ON public.meetings USING btree (educator_id);


--
-- Name: ix_meetings_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_meetings_id ON public.meetings USING btree (id);


--
-- Name: ix_messages_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_messages_created_at ON public.messages USING btree (created_at);


--
-- Name: ix_messages_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_messages_id ON public.messages USING btree (id);


--
-- Name: ix_messages_receiver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_messages_receiver_id ON public.messages USING btree (receiver_id);


--
-- Name: ix_messages_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_messages_sender_id ON public.messages USING btree (sender_id);


--
-- Name: ix_messages_sender_receiver; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_messages_sender_receiver ON public.messages USING btree (sender_id, receiver_id);


--
-- Name: ix_mgr_message_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mgr_message_id ON public.message_group_recipients USING btree (message_id);


--
-- Name: ix_mgr_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_mgr_user_id ON public.message_group_recipients USING btree (user_id);


--
-- Name: ix_notifications_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_id ON public.notifications USING btree (id);


--
-- Name: ix_notifications_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_sender_id ON public.notifications USING btree (sender_id);


--
-- Name: ix_notifications_source_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_source_id ON public.notifications USING btree (source_notification_id);


--
-- Name: ix_notifications_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notifications_user_id ON public.notifications USING btree (user_id);


--
-- Name: ix_otp_codes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_otp_codes_id ON public.otp_codes USING btree (id);


--
-- Name: ix_otp_codes_identifier; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_otp_codes_identifier ON public.otp_codes USING btree (identifier);


--
-- Name: ix_posts_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_posts_created_at ON public.posts USING btree (created_at);


--
-- Name: ix_posts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_posts_id ON public.posts USING btree (id);


--
-- Name: ix_posts_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_posts_status ON public.posts USING btree (status);


--
-- Name: ix_quiz_submissions_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quiz_submissions_id ON public.quiz_submissions USING btree (id);


--
-- Name: ix_quiz_submissions_quiz_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quiz_submissions_quiz_id ON public.quiz_submissions USING btree (quiz_id);


--
-- Name: ix_quiz_submissions_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quiz_submissions_score ON public.quiz_submissions USING btree (score);


--
-- Name: ix_quiz_submissions_student_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quiz_submissions_student_id ON public.quiz_submissions USING btree (student_id);


--
-- Name: ix_quiz_submissions_submitted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quiz_submissions_submitted_at ON public.quiz_submissions USING btree (submitted_at);


--
-- Name: ix_quizzes_educator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quizzes_educator_id ON public.quizzes USING btree (educator_id);


--
-- Name: ix_quizzes_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_quizzes_id ON public.quizzes USING btree (id);


--
-- Name: ix_saved_posts_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_saved_posts_id ON public.saved_posts USING btree (id);


--
-- Name: ix_smart_bins_bin_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_smart_bins_bin_code ON public.smart_bins USING btree (bin_code);


--
-- Name: ix_smart_bins_collection_point_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_smart_bins_collection_point_id ON public.smart_bins USING btree (collection_point_id);


--
-- Name: ix_smart_bins_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_smart_bins_id ON public.smart_bins USING btree (id);


--
-- Name: ix_testimonials_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_testimonials_id ON public.testimonials USING btree (id);


--
-- Name: ix_testimonials_is_approved; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_testimonials_is_approved ON public.testimonials USING btree (is_approved);


--
-- Name: ix_user_rewards_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_user_rewards_id ON public.user_rewards USING btree (id);


--
-- Name: ix_user_rewards_reward_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_rewards_reward_key ON public.user_rewards USING btree (reward_key);


--
-- Name: ix_user_rewards_unlocked_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_rewards_unlocked_at ON public.user_rewards USING btree (unlocked_at);


--
-- Name: ix_user_rewards_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_rewards_user_id ON public.user_rewards USING btree (user_id);


--
-- Name: ix_users_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_created_at ON public.users USING btree (created_at);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_facebook_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_facebook_id ON public.users USING btree (facebook_id);


--
-- Name: ix_users_global_score; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_global_score ON public.users USING btree (global_score);


--
-- Name: ix_users_google_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_google_id ON public.users USING btree (google_id);


--
-- Name: ix_users_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_id ON public.users USING btree (id);


--
-- Name: ix_users_is_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_is_active ON public.users USING btree (is_active);


--
-- Name: ix_users_qr_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_qr_code ON public.users USING btree (qr_code);


--
-- Name: ix_users_reset_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ix_users_reset_token ON public.users USING btree (reset_token);


--
-- Name: ix_users_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_users_role ON public.users USING btree (role);


--
-- Name: ix_video_categories_educator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_video_categories_educator_id ON public.video_categories USING btree (educator_id);


--
-- Name: ix_video_categories_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_video_categories_id ON public.video_categories USING btree (id);


--
-- Name: bin_scans bin_scans_smart_bin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bin_scans
    ADD CONSTRAINT bin_scans_smart_bin_id_fkey FOREIGN KEY (smart_bin_id) REFERENCES public.smart_bins(id);


--
-- Name: bin_scans bin_scans_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bin_scans
    ADD CONSTRAINT bin_scans_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: center_proposals center_proposals_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.center_proposals
    ADD CONSTRAINT center_proposals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: citizen_groups citizen_groups_educator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_groups
    ADD CONSTRAINT citizen_groups_educator_id_fkey FOREIGN KEY (educator_id) REFERENCES public.users(id);


--
-- Name: citizen_reports citizen_reports_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_reports
    ADD CONSTRAINT citizen_reports_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: citizen_reports citizen_reports_collection_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_reports
    ADD CONSTRAINT citizen_reports_collection_point_id_fkey FOREIGN KEY (collection_point_id) REFERENCES public.collection_points(id) ON DELETE CASCADE;


--
-- Name: citizen_reports citizen_reports_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.citizen_reports
    ADD CONSTRAINT citizen_reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: collection_routes collection_routes_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collection_routes
    ADD CONSTRAINT collection_routes_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: collector_logs collector_logs_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_logs
    ADD CONSTRAINT collector_logs_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.users(id);


--
-- Name: collector_logs collector_logs_smart_bin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_logs
    ADD CONSTRAINT collector_logs_smart_bin_id_fkey FOREIGN KEY (smart_bin_id) REFERENCES public.smart_bins(id);


--
-- Name: collector_zone_assignments collector_zone_assignments_assigned_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_assigned_by_fkey FOREIGN KEY (assigned_by) REFERENCES public.users(id);


--
-- Name: collector_zone_assignments collector_zone_assignments_collection_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_collection_point_id_fkey FOREIGN KEY (collection_point_id) REFERENCES public.collection_points(id) ON DELETE CASCADE;


--
-- Name: collector_zone_assignments collector_zone_assignments_collector_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_collector_id_fkey FOREIGN KEY (collector_id) REFERENCES public.users(id);


--
-- Name: collector_zone_assignments collector_zone_assignments_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.custom_actor_groups(id) ON DELETE CASCADE;


--
-- Name: collector_zone_assignments collector_zone_assignments_zone_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zone_assignments
    ADD CONSTRAINT collector_zone_assignments_zone_id_fkey FOREIGN KEY (zone_id) REFERENCES public.collector_zones(id) ON DELETE CASCADE;


--
-- Name: collector_zones collector_zones_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.collector_zones
    ADD CONSTRAINT collector_zones_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: comments comments_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.comments(id);


--
-- Name: comments comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: comments comments_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: custom_actor_groups custom_actor_groups_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.custom_actor_groups
    ADD CONSTRAINT custom_actor_groups_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: educator_videos educator_videos_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.educator_videos
    ADD CONSTRAINT educator_videos_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.video_categories(id);


--
-- Name: educator_videos educator_videos_educator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.educator_videos
    ADD CONSTRAINT educator_videos_educator_id_fkey FOREIGN KEY (educator_id) REFERENCES public.users(id);


--
-- Name: user_rewards fk_user_rewards_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_rewards
    ADD CONSTRAINT fk_user_rewards_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: group_members group_members_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.citizen_groups(id);


--
-- Name: group_members group_members_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.group_members
    ADD CONSTRAINT group_members_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: likes likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: likes likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: local_instructions local_instructions_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.local_instructions
    ADD CONSTRAINT local_instructions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: meeting_participants meeting_participants_meeting_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_participants
    ADD CONSTRAINT meeting_participants_meeting_id_fkey FOREIGN KEY (meeting_id) REFERENCES public.meetings(id);


--
-- Name: meeting_participants meeting_participants_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meeting_participants
    ADD CONSTRAINT meeting_participants_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: meetings meetings_educator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meetings
    ADD CONSTRAINT meetings_educator_id_fkey FOREIGN KEY (educator_id) REFERENCES public.users(id);


--
-- Name: message_group_recipients message_group_recipients_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_recipients
    ADD CONSTRAINT message_group_recipients_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- Name: message_group_recipients message_group_recipients_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_group_recipients
    ADD CONSTRAINT message_group_recipients_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_group_id_fkey FOREIGN KEY (group_id) REFERENCES public.citizen_groups(id) ON DELETE SET NULL;


--
-- Name: messages messages_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.messages(id) ON DELETE SET NULL;


--
-- Name: messages messages_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: notifications notifications_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_source_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_source_notification_id_fkey FOREIGN KEY (source_notification_id) REFERENCES public.notifications(id) ON DELETE SET NULL;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: posts posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: quiz_submissions quiz_submissions_quiz_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_submissions
    ADD CONSTRAINT quiz_submissions_quiz_id_fkey FOREIGN KEY (quiz_id) REFERENCES public.quizzes(id);


--
-- Name: quiz_submissions quiz_submissions_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quiz_submissions
    ADD CONSTRAINT quiz_submissions_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.users(id);


--
-- Name: quizzes quizzes_educator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quizzes
    ADD CONSTRAINT quizzes_educator_id_fkey FOREIGN KEY (educator_id) REFERENCES public.users(id);


--
-- Name: saved_posts saved_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: saved_posts saved_posts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.saved_posts
    ADD CONSTRAINT saved_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: smart_bins smart_bins_collection_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.smart_bins
    ADD CONSTRAINT smart_bins_collection_point_id_fkey FOREIGN KEY (collection_point_id) REFERENCES public.collection_points(id);


--
-- Name: testimonials testimonials_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testimonials
    ADD CONSTRAINT testimonials_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: video_categories video_categories_educator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.video_categories
    ADD CONSTRAINT video_categories_educator_id_fkey FOREIGN KEY (educator_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

