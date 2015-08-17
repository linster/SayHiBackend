--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE "APIadmin";
ALTER ROLE "APIadmin" WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION PASSWORD 'md5c33be35c44e50c931a84a1c56c5f5da3' VALID UNTIL 'infinity';
COMMENT ON ROLE "APIadmin" IS 'Admin API user. Has more permissions';
CREATE ROLE "APIuser";
ALTER ROLE "APIuser" WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION PASSWORD 'md57d7b26d6e3030ae751de50173b663d65' VALID UNTIL 'infinity';
COMMENT ON ROLE "APIuser" IS 'This is the user the ExpressJS API logs in as.';
CREATE ROLE "ProfileAdmin";
ALTER ROLE "ProfileAdmin" WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION CONNECTION LIMIT 3 VALID UNTIL 'infinity';
COMMENT ON ROLE "ProfileAdmin" IS 'Owner of all the tables.';
CREATE ROLE "ProfileUser";
ALTER ROLE "ProfileUser" WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB NOLOGIN NOREPLICATION VALID UNTIL 'infinity';
COMMENT ON ROLE "ProfileUser" IS 'This is the User group for the profile schema. I did this so that a leak in APIUser doesn''t create indexes and do nasty stuff if I do Row-Level Security.';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION PASSWORD 'md5802bfcfa61c6db24cc2d187623bdc74e';


--
-- Role memberships
--

GRANT "ProfileAdmin" TO "APIadmin" GRANTED BY postgres;
GRANT "ProfileAdmin" TO postgres GRANTED BY postgres;
GRANT "ProfileUser" TO "APIadmin" GRANTED BY postgres;
GRANT "ProfileUser" TO "APIuser" GRANTED BY postgres;
GRANT "ProfileUser" TO "ProfileAdmin" WITH ADMIN OPTION GRANTED BY postgres;
GRANT "ProfileUser" TO postgres GRANTED BY postgres;




--
-- Database creation
--

CREATE DATABASE "SayHi" WITH TEMPLATE = template0 OWNER = postgres;
ALTER DATABASE "SayHi" SET search_path TO "$user", public, tiger;
REVOKE ALL ON DATABASE template1 FROM PUBLIC;
REVOKE ALL ON DATABASE template1 FROM postgres;
GRANT ALL ON DATABASE template1 TO postgres;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect "SayHi"

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: SayHi; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE "SayHi" IS 'SayHi Application Database.';


--
-- Name: location; Type: SCHEMA; Schema: -; Owner: ProfileAdmin
--

CREATE SCHEMA location;


ALTER SCHEMA location OWNER TO "ProfileAdmin";

--
-- Name: profile; Type: SCHEMA; Schema: -; Owner: ProfileAdmin
--

CREATE SCHEMA profile;


ALTER SCHEMA profile OWNER TO "ProfileAdmin";

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO postgres;

--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET search_path = public, pg_catalog;

--
-- Name: makecircle_function(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION makecircle_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN

	UPDATE location."LoggedLocations" 
	SET "LocationCircle" = ST_Buffer(NEW."Point", NEW."AccuracyRadius") 
	WHERE "LocationId" = NEW."LocationId";
 
	RETURN NEW;
END;
$$;


ALTER FUNCTION public.makecircle_function() OWNER TO postgres;

SET search_path = location, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: LoggedLocations; Type: TABLE; Schema: location; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "LoggedLocations" (
    "LocationId" bigint NOT NULL,
    "UserId" bigint NOT NULL,
    "AccuracyRadius" double precision,
    "Point" public.geography(Point,4326),
    "DateLogged" timestamp with time zone,
    "LocationCircle" public.geography(Polygon,4326)
);


ALTER TABLE location."LoggedLocations" OWNER TO "ProfileAdmin";

--
-- Name: TABLE "LoggedLocations"; Type: COMMENT; Schema: location; Owner: ProfileAdmin
--

COMMENT ON TABLE "LoggedLocations" IS 'This is where all the phones put their coordinates into.';


--
-- Name: COLUMN "LoggedLocations"."AccuracyRadius"; Type: COMMENT; Schema: location; Owner: ProfileAdmin
--

COMMENT ON COLUMN "LoggedLocations"."AccuracyRadius" IS 'Location accuracy radius reported by Google Location API.';


--
-- Name: COLUMN "LoggedLocations"."DateLogged"; Type: COMMENT; Schema: location; Owner: ProfileAdmin
--

COMMENT ON COLUMN "LoggedLocations"."DateLogged" IS 'Date/time of the point recording.';


--
-- Name: COLUMN "LoggedLocations"."LocationCircle"; Type: COMMENT; Schema: location; Owner: ProfileAdmin
--

COMMENT ON COLUMN "LoggedLocations"."LocationCircle" IS 'Location Circle returned by phone';


--
-- Name: LoggedLocations_LocationId_seq; Type: SEQUENCE; Schema: location; Owner: ProfileAdmin
--

CREATE SEQUENCE "LoggedLocations_LocationId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE location."LoggedLocations_LocationId_seq" OWNER TO "ProfileAdmin";

--
-- Name: LoggedLocations_LocationId_seq; Type: SEQUENCE OWNED BY; Schema: location; Owner: ProfileAdmin
--

ALTER SEQUENCE "LoggedLocations_LocationId_seq" OWNED BY "LoggedLocations"."LocationId";


--
-- Name: LoggedLocations_UserId_seq; Type: SEQUENCE; Schema: location; Owner: ProfileAdmin
--

CREATE SEQUENCE "LoggedLocations_UserId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE location."LoggedLocations_UserId_seq" OWNER TO "ProfileAdmin";

--
-- Name: LoggedLocations_UserId_seq; Type: SEQUENCE OWNED BY; Schema: location; Owner: ProfileAdmin
--

ALTER SEQUENCE "LoggedLocations_UserId_seq" OWNED BY "LoggedLocations"."UserId";


SET search_path = profile, pg_catalog;

--
-- Name: Profile; Type: TABLE; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "Profile" (
    "ProfileId" bigint NOT NULL,
    "UserId" bigint NOT NULL,
    "BusinessCardId" bigint,
    "Chattiness" smallint,
    "ConversationTopics" character varying(4000)[],
    "Nickname" character(250) NOT NULL
);


ALTER TABLE profile."Profile" OWNER TO "ProfileAdmin";

--
-- Name: TABLE "Profile"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON TABLE "Profile" IS 'This is the user-settable part. Contains chattiness, topics to talk about, etc.';


--
-- Name: COLUMN "Profile"."UserId"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Profile"."UserId" IS 'User Id';


--
-- Name: COLUMN "Profile"."BusinessCardId"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Profile"."BusinessCardId" IS 'Link to businesscard';


--
-- Name: COLUMN "Profile"."Chattiness"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Profile"."Chattiness" IS '0-10 rating.';


--
-- Name: COLUMN "Profile"."ConversationTopics"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Profile"."ConversationTopics" IS 'Conversation Topics string array';


--
-- Name: COLUMN "Profile"."Nickname"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Profile"."Nickname" IS 'Nickname for the user';


SET search_path = location, pg_catalog;

--
-- Name: Nearby; Type: VIEW; Schema: location; Owner: ProfileAdmin
--

CREATE VIEW "Nearby" AS
 SELECT DISTINCT ON (l2."LocationId") p."Nickname",
    l2."LocationId",
    l2."UserId",
    l2."AccuracyRadius",
    l2."Point",
    l2."DateLogged",
    l2."LocationCircle"
   FROM "LoggedLocations" l1,
    "LoggedLocations" l2,
    profile."Profile" p
  WHERE ((((l1."LocationId" = 5) AND (l1."LocationId" <> l2."LocationId")) AND public.st_dwithin(l1."Point", l2."Point", (750)::double precision)) AND (p."UserId" = l2."UserId"))
  ORDER BY l2."LocationId", public.st_distance(l1."Point", l2."Point");


ALTER TABLE location."Nearby" OWNER TO "ProfileAdmin";

--
-- Name: VIEW "Nearby"; Type: COMMENT; Schema: location; Owner: ProfileAdmin
--

COMMENT ON VIEW "Nearby" IS 'The view that magically does the spatial sorting to make the nearby list. The ExpressJS api does a select * from Location.Nearby WHERE user=my_user_id and gets what it needs to dump back to the android app.';


SET search_path = profile, pg_catalog;

--
-- Name: Ratings; Type: TABLE; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "Ratings" (
    "UserId" bigint NOT NULL,
    "RatingWho" bigint NOT NULL,
    "CategoryId" integer,
    "Stars" smallint,
    "RatingId" bigint NOT NULL,
    "RatingTime" timestamp with time zone DEFAULT now()
);


ALTER TABLE profile."Ratings" OWNER TO "ProfileAdmin";

--
-- Name: COLUMN "Ratings"."Stars"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Ratings"."Stars" IS '0-10 rating, each 1 is 0.5 stars';


--
-- Name: AverageRatings; Type: VIEW; Schema: profile; Owner: postgres
--

CREATE VIEW "AverageRatings" AS
 SELECT r."UserId",
    r."RatingWho",
    r."CategoryId",
    avg(r."Stars") AS "AverageRating"
   FROM "Ratings" r
  GROUP BY r."CategoryId", r."UserId", r."RatingWho";


ALTER TABLE profile."AverageRatings" OWNER TO postgres;

--
-- Name: BusinessCards; Type: TABLE; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "BusinessCards" (
    "Id" bigint NOT NULL,
    "ProfileId" bigint NOT NULL,
    "FirstName" character varying(50),
    "LastName" character varying(100),
    email character varying(250),
    "Website" character varying(500),
    "Company" character varying(250),
    "Title" character varying(250)
);


ALTER TABLE profile."BusinessCards" OWNER TO "ProfileAdmin";

--
-- Name: TABLE "BusinessCards"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON TABLE "BusinessCards" IS 'BusinessCard Objects';


--
-- Name: COLUMN "BusinessCards"."ProfileId"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."ProfileId" IS 'This is a link to the "Profile", the table with "Chattiness", Nickname, and Conversation topics.';


--
-- Name: COLUMN "BusinessCards"."FirstName"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."FirstName" IS 'First Name';


--
-- Name: COLUMN "BusinessCards"."LastName"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."LastName" IS 'Last Name';


--
-- Name: COLUMN "BusinessCards".email; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards".email IS 'Email Address';


--
-- Name: COLUMN "BusinessCards"."Website"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."Website" IS 'Website Address';


--
-- Name: COLUMN "BusinessCards"."Company"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."Company" IS 'Company';


--
-- Name: COLUMN "BusinessCards"."Title"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "BusinessCards"."Title" IS 'Title at Company';


--
-- Name: BusinessCards_Id_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "BusinessCards_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."BusinessCards_Id_seq" OWNER TO "ProfileAdmin";

--
-- Name: BusinessCards_Id_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "BusinessCards_Id_seq" OWNED BY "BusinessCards"."Id";


--
-- Name: BusinessCards_ProfileId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "BusinessCards_ProfileId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."BusinessCards_ProfileId_seq" OWNER TO "ProfileAdmin";

--
-- Name: BusinessCards_ProfileId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "BusinessCards_ProfileId_seq" OWNED BY "BusinessCards"."ProfileId";


--
-- Name: Profile_BusinessCardId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Profile_BusinessCardId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Profile_BusinessCardId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Profile_BusinessCardId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Profile_BusinessCardId_seq" OWNED BY "Profile"."BusinessCardId";


--
-- Name: Profile_ProfileId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Profile_ProfileId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Profile_ProfileId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Profile_ProfileId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Profile_ProfileId_seq" OWNED BY "Profile"."ProfileId";


--
-- Name: Profile_UserId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Profile_UserId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Profile_UserId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Profile_UserId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Profile_UserId_seq" OWNED BY "Profile"."UserId";


--
-- Name: RatingCategories; Type: TABLE; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "RatingCategories" (
    "Id" integer NOT NULL,
    "CategoryName" character varying(100) NOT NULL
);


ALTER TABLE profile."RatingCategories" OWNER TO "ProfileAdmin";

--
-- Name: TABLE "RatingCategories"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON TABLE "RatingCategories" IS 'Categories for rating... Active Listening, Hygene, etc.';


--
-- Name: Ratings_RatingId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Ratings_RatingId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Ratings_RatingId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Ratings_RatingId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Ratings_RatingId_seq" OWNED BY "Ratings"."RatingId";


--
-- Name: Ratings_RatingWho_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Ratings_RatingWho_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Ratings_RatingWho_seq" OWNER TO "ProfileAdmin";

--
-- Name: Ratings_RatingWho_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Ratings_RatingWho_seq" OWNED BY "Ratings"."RatingWho";


--
-- Name: Ratings_UserId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Ratings_UserId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Ratings_UserId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Ratings_UserId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Ratings_UserId_seq" OWNED BY "Ratings"."UserId";


--
-- Name: Users; Type: TABLE; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE TABLE "Users" (
    "Id" bigint NOT NULL,
    "oAuthId" bigint,
    "Created" timestamp with time zone
);


ALTER TABLE profile."Users" OWNER TO "ProfileAdmin";

--
-- Name: COLUMN "Users"."oAuthId"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Users"."oAuthId" IS 'oAuth ID for Social Login';


--
-- Name: COLUMN "Users"."Created"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON COLUMN "Users"."Created" IS 'Date User Created';


--
-- Name: Users_Id_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Users_Id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Users_Id_seq" OWNER TO "ProfileAdmin";

--
-- Name: Users_Id_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Users_Id_seq" OWNED BY "Users"."Id";


--
-- Name: Users_oAuthId_seq; Type: SEQUENCE; Schema: profile; Owner: ProfileAdmin
--

CREATE SEQUENCE "Users_oAuthId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE profile."Users_oAuthId_seq" OWNER TO "ProfileAdmin";

--
-- Name: Users_oAuthId_seq; Type: SEQUENCE OWNED BY; Schema: profile; Owner: ProfileAdmin
--

ALTER SEQUENCE "Users_oAuthId_seq" OWNED BY "Users"."oAuthId";


SET search_path = location, pg_catalog;

--
-- Name: LocationId; Type: DEFAULT; Schema: location; Owner: ProfileAdmin
--

ALTER TABLE ONLY "LoggedLocations" ALTER COLUMN "LocationId" SET DEFAULT nextval('"LoggedLocations_LocationId_seq"'::regclass);


SET search_path = profile, pg_catalog;

--
-- Name: Id; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "BusinessCards" ALTER COLUMN "Id" SET DEFAULT nextval('"BusinessCards_Id_seq"'::regclass);


--
-- Name: ProfileId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "BusinessCards" ALTER COLUMN "ProfileId" SET DEFAULT nextval('"BusinessCards_ProfileId_seq"'::regclass);


--
-- Name: ProfileId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Profile" ALTER COLUMN "ProfileId" SET DEFAULT nextval('"Profile_ProfileId_seq"'::regclass);


--
-- Name: UserId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Profile" ALTER COLUMN "UserId" SET DEFAULT nextval('"Profile_UserId_seq"'::regclass);


--
-- Name: UserId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings" ALTER COLUMN "UserId" SET DEFAULT nextval('"Ratings_UserId_seq"'::regclass);


--
-- Name: RatingWho; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings" ALTER COLUMN "RatingWho" SET DEFAULT nextval('"Ratings_RatingWho_seq"'::regclass);


--
-- Name: RatingId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings" ALTER COLUMN "RatingId" SET DEFAULT nextval('"Ratings_RatingId_seq"'::regclass);


--
-- Name: Id; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Users" ALTER COLUMN "Id" SET DEFAULT nextval('"Users_Id_seq"'::regclass);


--
-- Name: oAuthId; Type: DEFAULT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Users" ALTER COLUMN "oAuthId" SET DEFAULT nextval('"Users_oAuthId_seq"'::regclass);


SET search_path = location, pg_catalog;

--
-- Data for Name: LoggedLocations; Type: TABLE DATA; Schema: location; Owner: ProfileAdmin
--

COPY "LoggedLocations" ("LocationId", "UserId", "AccuracyRadius", "Point", "DateLogged", "LocationCircle") FROM stdin;
4	1	12	0101000020E6100000A0A9D72D02665CC0880D164ED2C24A40	2015-08-15 00:00:00-04	\N
5	1	12	0101000020E6100000A0A9D72D02665CC0880D164ED2C24A40	2015-08-16 00:00:00-04	0103000020E61000000100000021000000E9F47237FF655CC034E9026FD2C24A40BFD2A140FF655CC0F07409BED1C24A40775D9B66FF655CC04F289912D1C24A40ACFAE9A7FF655CC0D69C4873D0C24A40F12B0B0200665CC0052537E6CFC24A40E03F887100665CC04C91D070CFC24A40746518F200665CC0FCDA9717CFC24A4066D2CA7E01665CC01EC2FADDCEC24A40EB5D371202665CC0491230C6CEC24A409CB1B3A602665CC0C7DA21D1CEC24A406B058B3603665CC0F86F64FECEC24A40404236BC03665CC0908E3A4CCFC24A403163923204665CC0E677A6B7CFC24A404FFE129504665CC0395F873CD0C24A40F003EFDF04665CC00A06C2D5D0C24A4050FC451005665CC083F8727DD1C24A4017553C2405665CC0797B282DD2C24A404EA80D1B05665CC02CF221DED2C24A40F74814F504665CC0344C9289D3C24A40D6CAC5B304665CC0FBEDE228D4C24A40A0A7A45904665CC0A081F4B5D4C24A40978E27EA03665CC07B325B2BD5C24A408851976903665CC0C1029484D5C24A4049BEE4DC02665CC07F2E31BED5C24A407F03784902665CC037E7FBD5D5C24A40BE7EFBB401665CC0491C0ACBD5C24A4092FF232501665CC0B479C79DD5C24A40A7A3789F00665CC0CE44F14FD5C24A40A6741C2900665CC09F3F85E4D4C24A40A2DE9BC6FF655CC02F3BA45FD4C24A407DF0BF7BFF655CC0677A69C6D3C24A40691E694BFF655CC00E75B81ED3C24A40E9F47237FF655CC034E9026FD2C24A40
6	4	12	0101000020E610000093E4B9BE0F665CC0F4A62215C6C24A40	2015-08-16 00:00:00-04	0103000020E61000000100000021000000030557C80C665CC0B2281236C6C24A40F86D85D10C665CC041AE1885C5C24A4043767EF70C665CC09D41A8D9C4C24A408688CC380D665CC08D7D573AC4C24A40A92BED920D665CC0BBB645ADC3C24A40BDB369020E665CC09AC0DE37C3C24A401C55F9820E665CC04F98A5DEC2C24A40954AAB0F0F665CC03A0208A5C2C24A40F46F17A30F665CC0C9CE3C8DC2C24A40BE72933710665CC050122E98C2C24A40018E6AC710665CC04C2670C5C2C24A40D3AC154D11665CC069CC4513C3C24A406FCB71C311665CC0A34AB17EC3C24A40FE7FF22512665CC04ED89103C4C24A40DBB9CE7012665CC0623ACC9CC4C24A4042FF25A112665CC0B1FF7C44C5C24A40E3BA1CB512665CC0C46E32F4C5C24A40FD82EEAB12665CC0A6EB2BA5C6C24A4011A6F58512665CC0AE659C50C7C24A40E3B2A74412665CC00E40EDEFC7C24A40CF1D87EA11665CC0B722FF7CC8C24A40A2900A7B11665CC0F63566F2C8C24A40C7D77AFA10665CC038789F4BC9C24A4002BCC86D10665CC02B213D85C9C24A405E675CDA0F665CC0825D089DC9C24A408533E0450F665CC08B171792C9C24A40E4EC08B60E665CC02AF6D464C9C24A40FEAE5D300E665CC0C039FF16C9C24A40518201BA0D665CC0AF9F93ABC8C24A40DCD280570D665CC0E5F4B226C8C24A407AB0A40C0D665CC0D878788DC7C24A405E914DDC0C665CC0ACA0C7E5C6C24A40030557C80C665CC0B2281236C6C24A40
10	6	12	0101000020E610000015E63DCE34645CC006D49B51F3C14A40	2015-08-16 00:00:00-04	0103000020E610000001000000210000006DFFF3D731645CC0D3842C72F3C14A4016A831E131645CC09AC833C1F2C14A406164380732645CC0B4B7C715F2C14A402418924832645CC008C27E76F1C14A40D8D7BBA232645CC072EF77E9F0C14A40ED9D3E1233645CC0A3A71E74F0C14A405261D19233645CC02661F51AF0C14A40083E831F34645CC01F4469E1EFC14A40CB10ECB234645CC01375B0C9EFC14A40D3A7614735645CC06A53B4D4EFC14A40597D2FD735645CC097810802F0C14A40A8D7CE5C36645CC02E0FEF4FF0C14A40C3261DD336645CC0E19B69BBF0C14A40AD888E3537645CC0E3CA5640F1C14A4083835A8037645CC0EAE49AD9F1C14A40503DA1B037645CC02B195281F2C14A408CC387C437645CC0E66E0A31F3C14A40EB4B4ABB37645CC0982D03E2F3C14A40F2BA439537645CC0E94B6F8DF4C14A403926EA5337645CC0EA57B82CF5C14A408674C0F936645CC05846BFB9F5C14A404BA93D8A36645CC042AB182FF6C14A4061CEAA0936645CC0B20B4288F6C14A405CCBF87C35645CC08E3BCEC1F6C14A4053C98FE934645CC0751387D9F6C14A4043011A5534645CC0A63283CEF6C14A406A004CC533645CC00FF72EA1F6C14A401387AC3F33645CC022534853F6C14A40F6295EC932645CC099AACDE7F5C14A4031CDEC6632645CC07A5EE062F5C14A40E1E9201C32645CC0802A9CC9F4C14A406456DAEB31645CC06BE3E421F4C14A406DFFF3D731645CC0D3842C72F3C14A40
11	5	12	0101000020E6100000295FD04202665CC04A7A185A9DC24A40	2015-08-16 00:00:00-04	0103000020E61000000100000021000000080E734CFF655CC0B62D057B9DC24A40A7DBA155FF655CC021B70BCA9CC24A40130E9B7BFF655CC0CF699B1E9CC24A40510EE9BCFF655CC050DF4A7F9BC24A40F963091700665CC01A6A39F29AC24A401866858600665CC07FDAD27C9AC24A402D4E140701665CC0AF299A239AC24A40265EC59301665CC07817FDE999C24A409E7A302702665CC02F6F32D299C24A404E5BABBB02665CC0D63F24DD99C24A406546814B03665CC07ADD660A9AC24A40AA322BD103665CC07E043D589AC24A402228864704665CC0EAF5A8C39AC24A405FC805AA04665CC0A6E489489BC24A405D0DE1F404665CC0ED91C4E19BC24A40BE86372505665CC0AB8975899CC24A400BA72D3905665CC07E102B399DC24A407A0AFF2F05665CC0838924EA9DC24A406C03060A05665CC03BE494959EC24A404222B8C804665CC00785E5349FC24A40A8DA976E04665CC01416F7C19FC24A4070D31BFF03665CC0CEC25D37A0C24A40DFD38C7E03665CC0968D9690A0C24A409C9DDBF102665CC0ACB233CAA0C24A40DD51705E02665CC0D963FEE1A0C24A402140F5C901665CC0C3900CD7A0C24A40AC291F3A01665CC0B9E5C9A9A0C24A40531E75B400665CC066A8F35BA0C24A40CC1A1A3E00665CC0239B87F09FC24A40A97F9ADBFF655CC0498FA66B9FC24A402652BF90FF655CC00CC86BD29EC24A4010FF6860FF655CC06EBDBA2A9EC24A40080E734CFF655CC0B62D057B9DC24A40
\.


--
-- Name: LoggedLocations_LocationId_seq; Type: SEQUENCE SET; Schema: location; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"LoggedLocations_LocationId_seq"', 11, true);


--
-- Name: LoggedLocations_UserId_seq; Type: SEQUENCE SET; Schema: location; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"LoggedLocations_UserId_seq"', 1, false);


SET search_path = profile, pg_catalog;

--
-- Data for Name: BusinessCards; Type: TABLE DATA; Schema: profile; Owner: ProfileAdmin
--

COPY "BusinessCards" ("Id", "ProfileId", "FirstName", "LastName", email, "Website", "Company", "Title") FROM stdin;
1	6	Boris	Badenov	\N	\N	\N	\N
\.


--
-- Name: BusinessCards_Id_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"BusinessCards_Id_seq"', 1, true);


--
-- Name: BusinessCards_ProfileId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"BusinessCards_ProfileId_seq"', 1, false);


--
-- Data for Name: Profile; Type: TABLE DATA; Schema: profile; Owner: ProfileAdmin
--

COPY "Profile" ("ProfileId", "UserId", "BusinessCardId", "Chattiness", "ConversationTopics", "Nickname") FROM stdin;
6	1	\N	4	{Computers,Technology,Otherthing}	Boris                                                                                                                                                                                                                                                     
8	3	\N	10	{Computers,Technology,Otherthing}	Vaclav                                                                                                                                                                                                                                                    
9	4	\N	4	{Computers,Technology,Otherthing}	Grant                                                                                                                                                                                                                                                     
10	5	\N	6	{Computers,Technology,Otherthing}	Josh                                                                                                                                                                                                                                                      
11	6	\N	5	{Computers,Technology,Otherthing}	Rocky                                                                                                                                                                                                                                                     
\.


--
-- Name: Profile_BusinessCardId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Profile_BusinessCardId_seq"', 5, true);


--
-- Name: Profile_ProfileId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Profile_ProfileId_seq"', 11, true);


--
-- Name: Profile_UserId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Profile_UserId_seq"', 1, false);


--
-- Data for Name: RatingCategories; Type: TABLE DATA; Schema: profile; Owner: ProfileAdmin
--

COPY "RatingCategories" ("Id", "CategoryName") FROM stdin;
1	Attentiveness
2	Creepiness
3	On-Topics
\.


--
-- Data for Name: Ratings; Type: TABLE DATA; Schema: profile; Owner: ProfileAdmin
--

COPY "Ratings" ("UserId", "RatingWho", "CategoryId", "Stars", "RatingId", "RatingTime") FROM stdin;
3	4	1	3	1	2015-08-16 21:35:08.297589-04
3	4	2	5	2	2015-08-16 21:35:08.297589-04
3	4	2	5	3	2015-08-16 21:35:08.297589-04
3	4	2	5	4	2015-08-16 21:35:08.297589-04
3	4	2	5	5	2015-08-16 21:35:08.297589-04
3	4	2	5	6	2015-08-16 21:35:08.297589-04
4	3	1	5	7	2015-08-16 21:35:08.297589-04
4	3	1	4	8	2015-08-16 21:35:08.297589-04
4	3	1	3	9	2015-08-16 21:35:08.297589-04
4	3	2	6	10	2015-08-16 21:35:08.297589-04
4	3	2	10	11	2015-08-16 21:35:08.297589-04
4	3	3	10	12	2015-08-16 21:35:08.297589-04
\.


--
-- Name: Ratings_RatingId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Ratings_RatingId_seq"', 12, true);


--
-- Name: Ratings_RatingWho_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Ratings_RatingWho_seq"', 1, false);


--
-- Name: Ratings_UserId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Ratings_UserId_seq"', 1, false);


--
-- Data for Name: Users; Type: TABLE DATA; Schema: profile; Owner: ProfileAdmin
--

COPY "Users" ("Id", "oAuthId", "Created") FROM stdin;
1	\N	2015-08-15 00:00:00-04
3	\N	2015-08-16 00:00:00-04
4	\N	2015-08-16 00:00:00-04
5	\N	2015-08-16 00:00:00-04
6	\N	2015-08-16 00:00:00-04
\.


--
-- Name: Users_Id_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Users_Id_seq"', 6, true);


--
-- Name: Users_oAuthId_seq; Type: SEQUENCE SET; Schema: profile; Owner: ProfileAdmin
--

SELECT pg_catalog.setval('"Users_oAuthId_seq"', 1, false);


SET search_path = public, pg_catalog;

--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


SET search_path = tiger, pg_catalog;

--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
debug_geocode_address	false	boolean	debug	outputs debug information in notice log such as queries when geocode_addresss is called if true
debug_geocode_intersection	false	boolean	debug	outputs debug information in notice log such as queries when geocode_intersection is called if true
debug_normalize_address	false	boolean	debug	outputs debug information in notice log such as queries and intermediate expressions when normalize_address is called if true
debug_reverse_geocode	false	boolean	debug	if true, outputs debug information in notice log such as queries and intermediate expressions when reverse_geocode
reverse_geocode_numbered_roads	0	integer	rating	For state and county highways, 0 - no preference in name, 1 - prefer the numbered highway name, 2 - prefer local state/county name
use_pagc_address_parser	false	boolean	normalize	If set to true, will try to use the pagc_address normalizer instead of tiger built one
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: postgres
--

COPY pagc_rules (id, rule, is_custom) FROM stdin;
\.


SET search_path = topology, pg_catalog;

--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: postgres
--

COPY layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


SET search_path = location, pg_catalog;

--
-- Name: LOGGEDLOC_PK; Type: CONSTRAINT; Schema: location; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "LoggedLocations"
    ADD CONSTRAINT "LOGGEDLOC_PK" PRIMARY KEY ("LocationId");


SET search_path = profile, pg_catalog;

--
-- Name: BUSCARD_PK_ID; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "BusinessCards"
    ADD CONSTRAINT "BUSCARD_PK_ID" PRIMARY KEY ("Id");


--
-- Name: Id; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "Users"
    ADD CONSTRAINT "Id" PRIMARY KEY ("Id");


--
-- Name: CONSTRAINT "Id" ON "Users"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON CONSTRAINT "Id" ON "Users" IS 'UserId';


--
-- Name: Profile_PK_ID; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "Profile"
    ADD CONSTRAINT "Profile_PK_ID" PRIMARY KEY ("ProfileId");


--
-- Name: RATINGS_PK_RatingId; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "Ratings"
    ADD CONSTRAINT "RATINGS_PK_RatingId" PRIMARY KEY ("RatingId");


--
-- Name: RatingCategories_PK; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "RatingCategories"
    ADD CONSTRAINT "RatingCategories_PK" PRIMARY KEY ("Id");


--
-- Name: RatingCategories_UQ_Name; Type: CONSTRAINT; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

ALTER TABLE ONLY "RatingCategories"
    ADD CONSTRAINT "RatingCategories_UQ_Name" UNIQUE ("CategoryName");


SET search_path = location, pg_catalog;

--
-- Name: fki_LOGGEDLOC_FK_USERID; Type: INDEX; Schema: location; Owner: ProfileAdmin; Tablespace: 
--

CREATE INDEX "fki_LOGGEDLOC_FK_USERID" ON "LoggedLocations" USING btree ("UserId");


--
-- Name: loggedlog_point_gix; Type: INDEX; Schema: location; Owner: ProfileAdmin; Tablespace: 
--

CREATE INDEX loggedlog_point_gix ON "LoggedLocations" USING gist ("Point");

ALTER TABLE "LoggedLocations" CLUSTER ON loggedlog_point_gix;


SET search_path = profile, pg_catalog;

--
-- Name: fki_PROFILE_FK_BUSCARD; Type: INDEX; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE INDEX "fki_PROFILE_FK_BUSCARD" ON "Profile" USING btree ("BusinessCardId");


--
-- Name: fki_PROFILE_FK_USER; Type: INDEX; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE INDEX "fki_PROFILE_FK_USER" ON "Profile" USING btree ("UserId");


--
-- Name: fki_RATINGS_FK_RATINGWHO; Type: INDEX; Schema: profile; Owner: ProfileAdmin; Tablespace: 
--

CREATE INDEX "fki_RATINGS_FK_RATINGWHO" ON "Ratings" USING btree ("RatingWho");


SET search_path = location, pg_catalog;

--
-- Name: makecircle_trigger; Type: TRIGGER; Schema: location; Owner: ProfileAdmin
--

CREATE TRIGGER makecircle_trigger AFTER INSERT ON "LoggedLocations" FOR EACH ROW EXECUTE PROCEDURE public.makecircle_function();


--
-- Name: LOGGEDLOC_FK_USERID; Type: FK CONSTRAINT; Schema: location; Owner: ProfileAdmin
--

ALTER TABLE ONLY "LoggedLocations"
    ADD CONSTRAINT "LOGGEDLOC_FK_USERID" FOREIGN KEY ("UserId") REFERENCES profile."Users"("Id");


SET search_path = profile, pg_catalog;

--
-- Name: PROFILE_FK_BUSCARD; Type: FK CONSTRAINT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Profile"
    ADD CONSTRAINT "PROFILE_FK_BUSCARD" FOREIGN KEY ("BusinessCardId") REFERENCES "BusinessCards"("Id");


--
-- Name: PROFILE_FK_USER; Type: FK CONSTRAINT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Profile"
    ADD CONSTRAINT "PROFILE_FK_USER" FOREIGN KEY ("UserId") REFERENCES "Users"("Id");


--
-- Name: RATINGS_FK_CategoryId; Type: FK CONSTRAINT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings"
    ADD CONSTRAINT "RATINGS_FK_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES "RatingCategories"("Id");


--
-- Name: RATINGS_FK_RATINGWHO; Type: FK CONSTRAINT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings"
    ADD CONSTRAINT "RATINGS_FK_RATINGWHO" FOREIGN KEY ("RatingWho") REFERENCES "Users"("Id");


--
-- Name: CONSTRAINT "RATINGS_FK_RATINGWHO" ON "Ratings"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON CONSTRAINT "RATINGS_FK_RATINGWHO" ON "Ratings" IS 'Who is being rated?';


--
-- Name: RATINGS_FK_USERID; Type: FK CONSTRAINT; Schema: profile; Owner: ProfileAdmin
--

ALTER TABLE ONLY "Ratings"
    ADD CONSTRAINT "RATINGS_FK_USERID" FOREIGN KEY ("UserId") REFERENCES "Users"("Id");


--
-- Name: CONSTRAINT "RATINGS_FK_USERID" ON "Ratings"; Type: COMMENT; Schema: profile; Owner: ProfileAdmin
--

COMMENT ON CONSTRAINT "RATINGS_FK_USERID" ON "Ratings" IS 'Who is Rating?';


--
-- Name: profile; Type: ACL; Schema: -; Owner: ProfileAdmin
--

REVOKE ALL ON SCHEMA profile FROM PUBLIC;
REVOKE ALL ON SCHEMA profile FROM "ProfileAdmin";
GRANT USAGE ON SCHEMA profile TO "ProfileAdmin";
GRANT USAGE ON SCHEMA profile TO "ProfileUser";


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


SET search_path = location, pg_catalog;

--
-- Name: LoggedLocations.LocationCircle; Type: ACL; Schema: location; Owner: ProfileAdmin
--

REVOKE ALL("LocationCircle") ON TABLE "LoggedLocations" FROM PUBLIC;
REVOKE ALL("LocationCircle") ON TABLE "LoggedLocations" FROM "ProfileAdmin";
GRANT ALL("LocationCircle") ON TABLE "LoggedLocations" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT("LocationCircle") ON TABLE "LoggedLocations" TO PUBLIC;
GRANT ALL("LocationCircle") ON TABLE "LoggedLocations" TO "ProfileUser";


SET search_path = profile, pg_catalog;

--
-- Name: Profile; Type: ACL; Schema: profile; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "Profile" FROM PUBLIC;
REVOKE ALL ON TABLE "Profile" FROM "ProfileAdmin";
GRANT REFERENCES,TRIGGER,TRUNCATE ON TABLE "Profile" TO "ProfileAdmin";
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE "Profile" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Profile" TO "ProfileUser";


SET search_path = location, pg_catalog;

--
-- Name: Nearby; Type: ACL; Schema: location; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "Nearby" FROM PUBLIC;
REVOKE ALL ON TABLE "Nearby" FROM "ProfileAdmin";
GRANT TRUNCATE ON TABLE "Nearby" TO "ProfileAdmin";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Nearby" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLE "Nearby" TO "ProfileUser" WITH GRANT OPTION;


SET search_path = profile, pg_catalog;

--
-- Name: Ratings; Type: ACL; Schema: profile; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "Ratings" FROM PUBLIC;
REVOKE ALL ON TABLE "Ratings" FROM "ProfileAdmin";
GRANT TRUNCATE ON TABLE "Ratings" TO "ProfileAdmin";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Ratings" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Ratings" TO "ProfileUser";


--
-- Name: AverageRatings; Type: ACL; Schema: profile; Owner: postgres
--

REVOKE ALL ON TABLE "AverageRatings" FROM PUBLIC;
REVOKE ALL ON TABLE "AverageRatings" FROM postgres;
GRANT ALL ON TABLE "AverageRatings" TO postgres;
GRANT ALL ON TABLE "AverageRatings" TO "ProfileAdmin";


--
-- Name: BusinessCards; Type: ACL; Schema: profile; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "BusinessCards" FROM PUBLIC;
REVOKE ALL ON TABLE "BusinessCards" FROM "ProfileAdmin";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "BusinessCards" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "BusinessCards" TO "ProfileUser";


--
-- Name: RatingCategories; Type: ACL; Schema: profile; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "RatingCategories" FROM PUBLIC;
REVOKE ALL ON TABLE "RatingCategories" FROM "ProfileAdmin";
GRANT TRUNCATE ON TABLE "RatingCategories" TO "ProfileAdmin";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "RatingCategories" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "RatingCategories" TO "ProfileUser";


--
-- Name: Users; Type: ACL; Schema: profile; Owner: ProfileAdmin
--

REVOKE ALL ON TABLE "Users" FROM PUBLIC;
REVOKE ALL ON TABLE "Users" FROM "ProfileAdmin";
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Users" TO "ProfileAdmin" WITH GRANT OPTION;
GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLE "Users" TO "ProfileUser";


SET search_path = location, pg_catalog;

--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: location; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON SEQUENCES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON SEQUENCES  TO PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON SEQUENCES  TO "ProfileAdmin";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON SEQUENCES  TO "ProfileUser";


--
-- Name: DEFAULT PRIVILEGES FOR TYPES; Type: DEFAULT ACL; Schema: location; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON TYPES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON TYPES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON TYPES  TO PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON TYPES  TO "ProfileAdmin" WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON TYPES  TO "ProfileUser" WITH GRANT OPTION;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: location; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON FUNCTIONS  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON FUNCTIONS  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON FUNCTIONS  TO PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON FUNCTIONS  TO "ProfileAdmin";
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT ALL ON FUNCTIONS  TO "ProfileUser";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: location; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,UPDATE ON TABLES  TO "ProfileAdmin" WITH GRANT OPTION;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA location GRANT SELECT,INSERT,REFERENCES,TRIGGER,UPDATE ON TABLES  TO "ProfileUser" WITH GRANT OPTION;


SET search_path = profile, pg_catalog;

--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: profile; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA profile REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA profile REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA profile GRANT ALL ON TABLES  TO "ProfileAdmin";


--
-- PostgreSQL database dump complete
--

\connect postgres

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect template1

SET default_transaction_read_only = off;

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

