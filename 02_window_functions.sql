-- ==========================================================
-- 02_window_functions.sql
-- Window Functions (5 queries)
-- ==========================================================

-- Query 6
-- Purpose: For each post, show the caption of that SAME user's NEXT
-- post in time (the mirror opposite of "previous post" useful to
-- study how a user's content evolves forward in time).
-- Technique: LEAD(column, 1) OVER (PARTITION BY user_id ORDER BY
-- created_at) looks one row AHEAD within each user's partition.
SELECT
    p.user_id,
    u.username,
    p.post_id,
    p.created_at,
    p.caption AS current_caption,
    LEAD(p.caption, 1) OVER (PARTITION BY p.user_id ORDER BY p.created_at) AS next_caption
FROM post p
JOIN users u ON p.user_id = u.user_id
ORDER BY p.user_id, p.created_at;
 
 
-- Query 7
-- Purpose: Segment all users into 4 equal-sized activity "quartiles"
-- based on how many posts they've made (e.g. Quartile 1 = most active
-- 25% of posters, Quartile 4 = least active 25%) -- a common data
-- analyst technique for tiered engagement campaigns.
-- Technique: NTILE(4) OVER (ORDER BY post_count DESC) splits the
-- ordered rows into 4 roughly equal buckets.
SELECT
    user_id,
    username,
    post_count,
    NTILE(4) OVER (ORDER BY post_count DESC) AS activity_quartile
FROM (
    SELECT u.user_id, u.username, COUNT(p.post_id) AS post_count
    FROM users u
    LEFT JOIN post p ON u.user_id = p.user_id
    GROUP BY u.user_id, u.username
) counts;
 
 
-- Query 8
-- Purpose: Rank ALL posts platform-wide by their number of comments,
-- with no GAPS in the ranking when posts tie (e.g. two posts tied for
-- 1st both show rank 1, and the next distinct post shows rank 2, not
-- rank 3) -- useful for a clean "most-discussed posts" leaderboard.
-- Technique: DENSE_RANK() OVER (ORDER BY comment_count DESC).
SELECT
    post_id,
    username,
    caption,
    comment_count,
    DENSE_RANK() OVER (ORDER BY comment_count DESC) AS comment_dense_rank
FROM (
    SELECT p.post_id, u.username, p.caption, COUNT(c.comment_id) AS comment_count
    FROM post p
    JOIN users u ON p.user_id = u.user_id
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.post_id, u.username, p.caption
) post_comment_counts
ORDER BY comment_dense_rank;
 
 
-- Query 9
-- Purpose: Alongside every post a user has made, show the caption of
-- that SAME user's VERY FIRST post ever -- useful for comparing a
-- user's early content style against their later posts.
-- Technique: FIRST_VALUE(column) OVER (PARTITION BY user_id ORDER BY
-- created_at) repeats the earliest row's value across every row in
-- that user's partition.

SELECT
    p.user_id,
    u.username,
    p.post_id,
    p.created_at,
    p.caption AS this_post_caption,
    FIRST_VALUE(p.caption) OVER (PARTITION BY p.user_id ORDER BY p.created_at
                                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS first_ever_caption
FROM post p
JOIN users u ON p.user_id = u.user_id
ORDER BY p.user_id, p.created_at;
 
 
-- Query 10
-- Purpose: For every post, show its cumulative distribution (percentile
-- standing) based on like count -- e.g. a value of 0.90 means that
-- post has more likes than 90% of all posts, useful for identifying
-- "top percentile" viral content.
-- Technique: CUME_DIST() OVER (ORDER BY like_count) returns, for each
-- row, the fraction of rows with a value less than or equal to it.
SELECT
    post_id,
    username,
    like_count,
    ROUND(CUME_DIST() OVER (ORDER BY like_count), 3) AS like_percentile
FROM (
    SELECT p.post_id, u.username, COUNT(pl.user_id) AS like_count
    FROM post p
    JOIN users u ON p.user_id = u.user_id
    LEFT JOIN post_likes pl ON p.post_id = pl.post_id
    GROUP BY p.post_id, u.username
) post_like_counts
ORDER BY like_percentile DESC;

