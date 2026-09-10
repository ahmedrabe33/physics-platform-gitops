-- =========================================================
-- Physics Learning Platform - PostgreSQL Schema
-- =========================================================

-- =========================
-- USERS
-- =========================
CREATE TABLE users (
    id SERIAL PRIMARY KEY,

    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password TEXT NOT NULL,

    grade VARCHAR(20),
    role VARCHAR(20) NOT NULL DEFAULT 'student',

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT users_grade_check
        CHECK (grade IS NULL OR grade IN ('second', 'third')),

    CONSTRAINT users_role_check
        CHECK (role IN ('student', 'admin'))
);


-- =========================
-- STUDENTS
-- =========================
CREATE TABLE students (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL UNIQUE,

    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    grade VARCHAR(20) NOT NULL,

    payment_proof TEXT,

    status VARCHAR(20) NOT NULL DEFAULT 'pending',

    registered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    subscription_expiry TIMESTAMPTZ,

    CONSTRAINT students_user_fk
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT students_grade_check
        CHECK (grade IN ('second', 'third')),

    CONSTRAINT students_status_check
        CHECK (
            status IN (
                'pending',
                'approved',
                'rejected',
                'expired'
            )
        )
);


-- =========================
-- CHAPTERS
-- =========================
CREATE TABLE chapters (
    id SERIAL PRIMARY KEY,

    grade VARCHAR(20) NOT NULL,
    title TEXT NOT NULL,
    chapter_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chapters_grade_check
        CHECK (grade IN ('second', 'third'))
);


-- =========================
-- LESSONS
-- =========================
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,

    chapter_id INTEGER NOT NULL,

    title TEXT NOT NULL,
    description TEXT,
    video_url TEXT,

    lesson_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT lessons_chapter_fk
        FOREIGN KEY (chapter_id)
        REFERENCES chapters(id)
        ON DELETE CASCADE
);


-- =========================
-- LESSON TOPICS
-- =========================
CREATE TABLE lesson_topics (
    id SERIAL PRIMARY KEY,

    lesson_id INTEGER NOT NULL,

    title TEXT NOT NULL,
    description TEXT,
    video_url TEXT,

    topic_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT lesson_topics_lesson_fk
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE
);


-- =========================
-- EXERCISES
-- =========================
CREATE TABLE exercises (
    id SERIAL PRIMARY KEY,

    lesson_id INTEGER NOT NULL,

    question TEXT NOT NULL,
    correct_answer TEXT NOT NULL,

    exercise_order INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT exercises_lesson_fk
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE
);


-- =========================
-- PROGRESS
-- =========================
CREATE TABLE progress (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,

    completed BOOLEAN NOT NULL DEFAULT FALSE,
    score INTEGER,
    completed_at TIMESTAMPTZ,

    CONSTRAINT progress_user_fk
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT progress_lesson_fk
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE,

    CONSTRAINT progress_user_lesson_unique
        UNIQUE (user_id, lesson_id)
);


-- =========================
-- VIDEO VIEWS
-- =========================
CREATE TABLE video_views (
    id SERIAL PRIMARY KEY,

    user_id INTEGER NOT NULL,
    lesson_id INTEGER NOT NULL,
    topic_id INTEGER,

    video_url TEXT,
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT video_views_user_fk
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE CASCADE,

    CONSTRAINT video_views_lesson_fk
        FOREIGN KEY (lesson_id)
        REFERENCES lessons(id)
        ON DELETE CASCADE,

    CONSTRAINT video_views_topic_fk
        FOREIGN KEY (topic_id)
        REFERENCES lesson_topics(id)
        ON DELETE SET NULL
);


-- =========================
-- INDEXES
-- =========================
CREATE INDEX idx_students_status
    ON students(status);

CREATE INDEX idx_students_grade
    ON students(grade);

CREATE INDEX idx_chapters_grade_order
    ON chapters(grade, chapter_order);

CREATE INDEX idx_lessons_chapter_order
    ON lessons(chapter_id, lesson_order);

CREATE INDEX idx_topics_lesson_order
    ON lesson_topics(lesson_id, topic_order);

CREATE INDEX idx_exercises_lesson_order
    ON exercises(lesson_id, exercise_order);

CREATE INDEX idx_progress_user
    ON progress(user_id);

CREATE INDEX idx_video_views_user
    ON video_views(user_id);

CREATE INDEX idx_video_views_opened
    ON video_views(opened_at DESC);
