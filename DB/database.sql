/**
  Create tif_admin user
*/
-- CREATE ROLE "tif_admin" IN ROLE "authenticator"
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tif_admin;

-----------------------
-- Tables & policies --
-----------------------

/** 
* USERS
* Note: This table contains user data. Users should only be able to view and update their own data.
*/
create table users (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  auth_user_id uuid references auth.users not null,
  email text UNIQUE,
  username VARCHAR(60) UNIQUE,
  points INT DEFAULT 0
);
alter table users enable row level security;
create policy "Can view own user data." on users for select using (auth.uid() = auth_user_id);
create policy "Can update own user data." on users for update using (auth.uid() = auth_user_id);
-- CREATE POLICY "Can view all data" ON users FOR SELECT USING (true);
CREATE POLICY "Admin can view users data." ON users for SELECT USING (auth.role() = 'tif_admin');

-- CREATE TABLE posts (
--   id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--   title VARCHAR(60),
--   description VARCHAR(60),
--   inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
--   updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
-- );

-- INSERT INTO posts(title, description)
-- VALUES 
--   ('Post #1', 'first post'),
--   ('Post #2', 'second post');

CREATE TABLE events (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  fixture_id INT,
  home_team_id INT,
  home_team_name VARCHAR(60),
  home_team_image VARCHAR(120),
  home_team_score INT,
  visitor_team_id INT,
  visitor_team_name VARCHAR(60),
  visitor_team_image VARCHAR(120),
  visitor_team_score INT,
  venue_id INT,
  venue_name VARCHAR(60),
  venue_slug VARCHAR(60),
  city VARCHAR(60),
  country VARCHAR(60),
  date timestamp with time zone,
  timestamp INT,
  league_id INT,
  round VARCHAR(60),
  group_name VARCHAR(60),
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE UNIQUE INDEX fixture_idx ON events (fixture_id);
-- 2. Enable RLS (Prevent any action on the table)
ALTER TABLE events enable row level security;
CREATE POLICY "Events are viewable by everyone." ON events for SELECT USING (true);

INSERT INTO events(fixture_id, home_team_name, home_team_id, home_team_score, visitor_team_name, 
visitor_team_id, visitor_team_score)
VALUES 
  (1, 'Neuchâtel Xamax FCS', 1, 3, 'Lausanne Sport', 2, 0),
  (2, 'FC Basel', 3, 2, 'FC Zürich', 4, 2);

CREATE TABLE messages (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  event_id INT,
  user_id VARCHAR(255),
  user_email VARCHAR(255),
  content VARCHAR(255),
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- user_id uuid references auth.users,
create type team_type as enum('national', 'club');

CREATE TABLE teams (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  api_football_id INT,
  name VARCHAR(60),
  national BOOLEAN DEFAULT FALSE,
  -- type team_type NOT NULL,
  country VARCHAR(255),
  logo VARCHAR(255),
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- INSERT INTO teams(name)
-- VALUES 
--   ('Neuchâtel Xamax FCS'),
--   ('Lausanne Sport');

CREATE TABLE actions (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  name VARCHAR(60),
  slug VARCHAR(60),
  image VARCHAR(60),
  description VARCHAR(60),
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

INSERT INTO actions(name, slug, image, description)
VALUES 
  ('Hola', 'hola', 'hola.jpg', 'Lancer une hola'),
  ('Vuvuzela', 'vuvuzela', 'vuvzela.jpg', 'Souffler dans une vuvuzela');

CREATE TABLE event_users (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  user_id INT UNIQUE NOT NULL,
  username VARCHAR(60),
  event_id INT,
  joined_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  left_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  CONSTRAINT fk_event_id FOREIGN KEY (event_id) REFERENCES events (id),
  CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE TABLE event_actions (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  event_id INT NOT NULL,
  action_id INT NOT NULL,
  user_id INT NOT NULL,
  -- number_participants INT DEFAULT 1,
  number_participants INT CHECK (number_participants <= participation_threshold) DEFAULT 1 ,
  participation_threshold INT,
  is_completed BOOLEAN DEFAULT FALSE,
  points INT DEFAULT 0,
  expired_at timestamp with time zone DEFAULT timezone('utc'::text, now()),
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  CONSTRAINT fk_event_id FOREIGN KEY (event_id) REFERENCES events (id),
  CONSTRAINT fk_action_id FOREIGN KEY (action_id) REFERENCES actions (id),
  CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id)
);

-- INSERT INTO event_actions(event_id, action_id, user_id)
-- VALUES 
--   (4, 1, 1),
--   (4, 2, 1);

CREATE TABLE event_actions_users (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  user_id INT,
  event_action_id INT,
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  -- CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users (id),
  CONSTRAINT fk_event_action_id FOREIGN KEY (event_action_id) REFERENCES event_actions (id),
  UNIQUE (event_action_id, user_id)
);

CREATE TABLE standings (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  league_id INT,
  rank SMALLINT,
  team_id INT,
  team_name VARCHAR(255),
  points SMALLINT,
  goals_diff SMALLINT,
  group_name VARCHAR(255),
  description VARCHAR(255),
  all_played SMALLINT,
  all_win SMALLINT,
  all_draw SMALLINT,
  all_lose SMALLINT,
  all_goals_for SMALLINT,
  all_goals_against SMALLINT,
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE (league_id, team_id)
);


CREATE TABLE stadiums (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  api_football_id INT UNIQUE,
  name VARCHAR(255),
  slug VARCHAR(255),
  capacity INT,
  city VARCHAR(255),
  country VARCHAR(255),
  country_id INT,
  inserted_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

INSERT INTO stadiums(api_football_id, name, slug, capacity, city, country)
VALUES 
  (489, 'Wembley Stadium', 'wembley_stadium', 90000, 'London', 'United Kingdom'),
  (910, 'Stadio Olimpico', 'stadio_olimpico', 70634, 'Rome', 'Italy'),
  (700, 'Allianz Arena', 'allianz_arena', 70000, 'Munich', 'Germany'),
  (2607, 'Olympic Stadium', 'olympic_stadium', 68700, 'Baku', 'Azerbaijan'),
  (null, 'Krestovsky Stadium', 'krestovsky_stadium', 68134, 'Saint Petersburg', 'Russia'),
  (null, 'Puskás Aréna', 'puskas_arena', 67215, 'Budapest', 'Hungary'),
  (null, 'La Cartuja', 'la_cartuja', 60000, 'Seville', 'Spain'),
  (1326, 'Arena Națională', 'arena_nationala', 55600, 'Bucharest', 'Romania'),
  (1117, 'Johan Cruyff Arena', 'johan_cruyff_arena', 54990, 'Amsterdam', 'The Netherlands'),
  (2617, 'Hampden Park', 'hampden_park', 51866, 'Glasgow', 'United Kingdom'),
  (439, 'Parken Stadium', 'parken_stadium', 38065, 'Copenhagen', 'Denmark');


--------------------------
-- Functions & triggers --
--------------------------

/* This trigger automatically creates a user entry when a new user signs up via Supabase Auth. */ 
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.users (auth_user_id, email)
  values (new.id, new.email);
  return new;
end;
$$ language plpgsql security definer;
-- trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


/* Increment by one function */ 
CREATE OR REPLACE FUNCTION increment_participation_count_by_one (row_id INT) 
RETURNS void AS
$$
  UPDATE event_actions
  SET number_participants = number_participants + 1
  WHERE id = row_id
$$ 
LANGUAGE SQL volatile;

/* Decrement by one function */
CREATE OR REPLACE FUNCTION decrement_participation_count_by_one (row_id INT) 
RETURNS void AS
$$
  UPDATE event_actions
  SET number_participants = number_participants - 1
  WHERE id = row_id
$$ 
LANGUAGE SQL volatile;


/* Check participation threshold trigger, mark as complete if number of participants = participation threshold. If complete, update users total points. */
CREATE OR REPLACE FUNCTION public.check_participation_threshold() 
RETURNS TRIGGER AS $$
DECLARE
r int;
BEGIN
	IF new.number_participants = new.participation_threshold THEN
    -- 1) Mark action as complete
		UPDATE event_actions
    SET is_completed = true
		WHERE id = new.id;
    -- 2) Update user points
    UPDATE users SET points = points + new.points WHERE id IN (SELECT user_id FROM event_actions_users WHERE event_action_id = new.id);
	END IF;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;
CREATE TRIGGER participation_threshold
    AFTER UPDATE OF number_participants ON event_actions
    FOR EACH ROW
    -- [ WHEN ( condition ) ]
    EXECUTE PROCEDURE check_participation_threshold();