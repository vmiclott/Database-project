CREATE TABLE location
(
  latitude numeric NOT NULL,
  town character varying,
  postalcode integer,
  streetname character varying,
  locationid serial NOT NULL,
  housenr character varying,
  longitude numeric NOT NULL,
  CONSTRAINT location_pkey PRIMARY KEY (locationid),
  CONSTRAINT location_latitude_longitude_housenr_key UNIQUE (latitude, longitude, housenr),
  CONSTRAINT location_latitude_check CHECK (-90 <= latitude and latitude <= 90),
  CONSTRAINT location_longitude_check CHECK (-180 <= longitude and longitude <= 180)
);

CREATE TABLE person
(
  email character varying,
  birthdate date,
  firstname character varying NOT NULL,
  lastname character varying NOT NULL,
  locationid integer,
  personid serial NOT NULL,
  CONSTRAINT person_pkey PRIMARY KEY (personid),
  CONSTRAINT person_locationid_fkey FOREIGN KEY (locationid)
      REFERENCES location (locationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT person_email_key UNIQUE (email),
  CONSTRAINT person_firstn_lastn_birthd_key UNIQUE (firstname,lastname,birthdate),
  CONSTRAINT person_birthdate_check CHECK (birthdate < now())
);

CREATE TABLE fieldtrip
(
  fieldtripfrom date NOT NULL,
  fieldtripto date NOT NULL,
  abstract character varying,
  fieldtripid serial NOT NULL,
  CONSTRAINT fieldtrip_pkey PRIMARY KEY (fieldtripid),
  CONSTRAINT datumcheck CHECK (fieldtripfrom < fieldtripto)
);

CREATE TABLE member
(
  personid integer NOT NULL,
  CONSTRAINT member_pkey PRIMARY KEY (personid),
  CONSTRAINT member_personid_fkey FOREIGN KEY (personid)
      REFERENCES person (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE writer
(
  personid integer NOT NULL,
  CONSTRAINT writer_pkey PRIMARY KEY (personid),
  CONSTRAINT writer_personid_fkey FOREIGN KEY (personid)
      REFERENCES member (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE photographer
(
  personid integer NOT NULL,
  CONSTRAINT photographer_pkey PRIMARY KEY (personid),
  CONSTRAINT photographer_personid_fkey FOREIGN KEY (personid)
      REFERENCES member (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE photo
(
  filename character varying NOT NULL,
  date timestamp with time zone DEFAULT now(),
  title character varying DEFAULT 'untitled'::character varying,
  personid integer NOT NULL,
  CONSTRAINT photo_pkey PRIMARY KEY (personid, filename),
  CONSTRAINT photo_personid_fkey FOREIGN KEY (personid)
      REFERENCES photographer (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT photo_date_check CHECK (date < now())
);

CREATE TABLE article
(
  title character varying DEFAULT 'untitled'::character varying,
  body character varying NOT NULL,
  starttime timestamp without time zone,
  publishtime timestamp without time zone,
  personid integer NOT NULL,
  articleid serial NOT NULL,
  CONSTRAINT article_pkey PRIMARY KEY (articleid),
  CONSTRAINT article_personid_fkey FOREIGN KEY (personid)
      REFERENCES writer (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT article_date_check CHECK (starttime <= publishtime)
);

CREATE TABLE opinion
(
  articleid integer NOT NULL,
  context character varying,
  CONSTRAINT opinion_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT opinion_pkey PRIMARY KEY (articleid)
);

CREATE TABLE interview
(
  articleid integer NOT NULL,
  abstract character varying NOT NULL,
  publishable boolean,
  CONSTRAINT interview_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT interview_pkey PRIMARY KEY (articleid)
);

CREATE TABLE article_fieldtrip
(
  articleid integer NOT NULL,
  fieldtripid integer NOT NULL,
  CONSTRAINT article_fieldtrip_pkey PRIMARY KEY (fieldtripid, articleid),
  CONSTRAINT article_fieldtrip_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT article_fieldtrip_fieldtripid_fkey FOREIGN KEY (fieldtripid)
      REFERENCES fieldtrip (fieldtripid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE article_photo
(
  filename character varying NOT NULL,
  personid integer NOT NULL,
  articleid integer NOT NULL,
  CONSTRAINT article_photo_pkey PRIMARY KEY (filename, personid, articleid),
  CONSTRAINT article_photo_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT article_photo_personid_fkey FOREIGN KEY (personid, filename)
      REFERENCES photo (personid, filename) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE article_references
(
  reference character varying NOT NULL,
  articleid integer NOT NULL,
  CONSTRAINT article_references_pkey PRIMARY KEY (reference, articleid),
  CONSTRAINT article_references_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE interview_person
(
  consenttopublish boolean DEFAULT false,
  personid integer NOT NULL,
  articleid integer NOT NULL,
  CONSTRAINT interview_person_pkey PRIMARY KEY (personid, articleid),
  CONSTRAINT interview_person_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES interview (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT interview_person_personid_fkey FOREIGN KEY (personid)
      REFERENCES person (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE location_fieldtrip
(
  locationid integer NOT NULL,
  fieldtripid integer NOT NULL,
  locationorder integer DEFAULT 1,
  CONSTRAINT location_fieldtrip_pkey PRIMARY KEY (fieldtripid, locationorder),
  CONSTRAINT location_fieldtrip_fieldtripid_fkey FOREIGN KEY (fieldtripid)
      REFERENCES fieldtrip (fieldtripid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT location_fieldtrip_locationid_fkey FOREIGN KEY (locationid)
      REFERENCES location (locationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE member_fieldtrip
(
  personid integer NOT NULL,
  fieldtripid integer NOT NULL,
  CONSTRAINT member_fieldtrip_pkey PRIMARY KEY (personid, fieldtripid),
  CONSTRAINT member_fieldtrip_fieldtripid_fkey FOREIGN KEY (fieldtripid)
      REFERENCES fieldtrip (fieldtripid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT member_fieldtrip_personid_fkey FOREIGN KEY (personid)
      REFERENCES member (personid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

CREATE TABLE related_articles
(
  articleid integer NOT NULL,
  articleid2 integer NOT NULL,
  linkedtype character varying,
  CONSTRAINT related_articles_pkey PRIMARY KEY (articleid2, articleid),
  CONSTRAINT related_articles_articleid_fkey FOREIGN KEY (articleid)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT related_articles_articleid2_fkey FOREIGN KEY (articleid2)
      REFERENCES article (articleid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
);
CREATE OR REPLACE FUNCTION article_fieldtrip_date_function()
  RETURNS trigger AS
$BODY$
BEGIN
if NOT EXISTS(SELECT * FROM article,fieldtrip
WHERE NEW.articleid = article.articleid AND NEW.fieldtripid = fieldtripid
AND (article.publishtime IS NULL OR article.publishtime >= fieldtrip.fieldtripfrom)) THEN
	RAISE NOTICE 'Article % and fieldtrip % were not added because the article was published before the fieldtrip.',NEW.articleid,NEW.fieldtripid;
	RETURN null;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER insert_article_fieldtrip
  BEFORE INSERT
  ON article_fieldtrip
  FOR EACH ROW
  EXECUTE PROCEDURE article_fieldtrip_date_function();



CREATE OR REPLACE FUNCTION article_publishtime_function()
  RETURNS TRIGGER AS
$BODY$
BEGIN
IF(NEW.publishtime IS NOT NULL)
THEN
	IF(NOT (SELECT publishable FROM interview WHERE articleid = NEW.articleid))
	THEN
	RAISE EXCEPTION 'Dit artikel mag niet gepubliceerd worden!';
	END IF;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER article_publishtime
  BEFORE UPDATE
  ON article
  FOR EACH ROW
  EXECUTE PROCEDURE article_publishtime_function();



CREATE OR REPLACE FUNCTION articlestarttime_birthdate()
  RETURNS TRIGGER AS
$BODY$
BEGIN
IF EXISTS (SELECT * FROM person WHERE NEW.personid = person.personid AND birthdate>=NEW.starttime)
THEN RAISE EXCEPTION 'The writer wasn''t born yet when this article was written';
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER insert_article_datecheck
  BEFORE INSERT
  ON article
  FOR EACH ROW
  EXECUTE PROCEDURE articlestarttime_birthdate();



CREATE OR REPLACE FUNCTION interview_person_consent()
  RETURNS TRIGGER AS
$BODY$
BEGIN
IF(NEW.consenttopublish)
THEN
	IF((SELECT publishable FROM interview WHERE articleid = NEW.articleid) IS 	NULL)
	THEN
		UPDATE interview
		SET publishable = true
		WHERE NEW.articleid = articleid;
	END IF;
ELSE 
	UPDATE article
	SET publishtime = null
	WHERE NEW.articleid = articleid;
	
	UPDATE interview
	SET publishable = false
	WHERE NEW.articleid = articleid;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER interview_person_consenttopublish
  BEFORE INSERT
  ON interview_person
  FOR EACH ROW
  EXECUTE PROCEDURE interview_person_consent();



CREATE OR REPLACE FUNCTION interview_person_update_consent()
  RETURNS TRIGGER AS
$BODY$
BEGIN
IF( EXISTS(SELECT * FROM interview INNER JOIN interview_person USING(articleid) 
WHERE NEW.articleid = articleid AND consenttopublish = false))
THEN
	UPDATE interview
	SET publishable = false
	WHERE articleid = NEW.articleid;
ELSE
	UPDATE interview
	SET publishable = true
	WHERE articleid = NEW.articleid;

END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER interview_person_update_consent
  AFTER UPDATE
  ON interview_person
  FOR EACH ROW
  EXECUTE PROCEDURE interview_person_update_consent();



CREATE OR REPLACE FUNCTION location_fieldtrip_order_function()
  RETURNS trigger AS
$BODY$
BEGIN
IF EXISTS(SELECT * FROM (SELECT fieldtripid,max(locationorder) AS maxorder FROM location_fieldtrip
	GROUP BY fieldtripid HAVING(fieldtripid = new.fieldtripid)) AS stuff INNER 	JOIN location_fieldtrip
	ON(maxorder = locationorder) WHERE NEW.fieldtripid = location_fieldtrip.fieldtripid AND NEW.locationid = locationid)
THEN
	RAISE NOTICE 'De location_fieldtrip met locationid % en fieldtripid % is niet toegevoegd. De fieldtrip bevindt zich op dat moment al op die plaats!',NEW.locationid, NEW.fieldtripid;
	RETURN NULL;
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER insert_location_order
  BEFORE INSERT
  ON location_fieldtrip
  FOR EACH ROW
  EXECUTE PROCEDURE location_fieldtrip_order_function();



CREATE OR REPLACE FUNCTION photodate_birthdate()
  RETURNS TRIGGER AS
$BODY$
BEGIN
IF EXISTS (SELECT * FROM person WHERE NEW.personid = person.personid AND birthdate>=NEW.date)
THEN RAISE EXCEPTION 'The photographer wasn''t born yet when this photo was taken';
END IF;
RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE;

CREATE TRIGGER insert_photo
  BEFORE INSERT
  ON photo
  FOR EACH ROW
  EXECUTE PROCEDURE photodate_birthdate();


--Deze functie is pas toegevoegd na het inladen van de data! Anders heeft testquery5 geen zin.
--CREATE OR REPLACE FUNCTION member_fieldtrip_date_function()
--  RETURNS trigger AS
--$BODY$
--BEGIN
--	IF  EXISTS(SELECT * FROM (SELECT fieldtripfrom,fieldtripto FROM fieldtrip WHERE fieldtripid = NEW.fieldtripid) AS stuff1,
--	(SELECT fieldtripfrom,fieldtripto FROM member_fieldtrip 
--	INNER JOIN fieldtrip USING(fieldtripid)
--	WHERE NEW.personid = member_fieldtrip.personid
--	AND NEW.fieldtripid <> fieldtrip.fieldtripid) AS stuff2
--	WHERE stuff1.fieldtripfrom <= stuff2.fieldtripto OR stuff1.fieldtripto >= stuff2.fieldtripfrom)
--	
--	THEN
--		RAISE EXCEPTION 'Dubbele boeking voor member met id %',NEW.personid;
--	END IF;
--	RETURN NEW;
--END;
--$BODY$
--  LANGUAGE plpgsql VOLATILE;
--
--CREATE TRIGGER insert_member_fieldtrip
--  BEFORE INSERT
--  ON member_fieldtrip
--  FOR EACH ROW
--  EXECUTE PROCEDURE member_fieldtrip_date_function();

