-- ==========================================================
-- 01_subqueries_joins.sql
-- Advanced Subqueries & Joins (5 queries)
-- ==========================================================

-- Query 1
-- Purpose: Find posts that have received ZERO comments (dead/ignored
-- posts 
-- Technique: LEFT JOIN post -> comments, then filter where the joined
-- comment_id is NULL (no matching comment exists for that post).
SELECT p.post_id, u.username, p.caption, p.created_at
FROM post p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN comments c ON p.post_id = c.post_id
WHERE c.comment_id IS NULL;
 
 
-- Query 2
-- Purpose: Find users who follow MORE people than follow them back
-- (i.e. following_count > follower_count) 
-- Technique: two correlated subqueries in the SELECT list, one
-- counting rows in `follows` where the user is the follower, the other
-- where the user is the followee, compared in the outer WHERE clause.
SELECT
    u.user_id,
    u.username,
    (SELECT COUNT(*) FROM follows f WHERE f.follower_id = u.user_id) AS following_count,
    (SELECT COUNT(*) FROM follows f WHERE f.followee_id = u.user_id) AS follower_count
FROM users u
WHERE (SELECT COUNT(*) FROM follows f WHERE f.follower_id = u.user_id)
    > (SELECT COUNT(*) FROM follows f WHERE f.followee_id = u.user_id);
 
 
-- Query 3
-- Purpose: Find hashtags that exist in the system but have NEVER been
-- used to tag any post (unused hashtags -- candidates for cleanup
-- or for a "trending suggestions" exclusion list).
-- Technique: LEFT JOIN hashtags -> post_tags, filter where the joined
-- post_id is NULL.
SELECT h.hashtag_id, h.hashtag_name
FROM hashtags h
LEFT JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
WHERE pt.post_id IS NULL;
 
 
-- Query 4
-- Purpose: Find users who have given out MORE likes than they have
-- posts (i.e. active "consumers" of content rather than active
-- creators) 
-- Technique: subquery-derived counts for likes given and posts made,
-- joined together and compared in the outer WHERE clause.
SELECT
    likes_given.user_id,
    u.username,
    likes_given.total_likes_given,
    COALESCE(posts_made.total_posts, 0) AS total_posts
FROM (
    SELECT user_id, COUNT(*) AS total_likes_given
    FROM post_likes
    GROUP BY user_id
) likes_given
JOIN users u ON u.user_id = likes_given.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS total_posts
    FROM post
    GROUP BY user_id
) posts_made ON posts_made.user_id = likes_given.user_id
WHERE likes_given.total_likes_given > COALESCE(posts_made.total_posts, 0);
 
 
-- Query 5
-- Purpose: Find videos whose file size is larger than the AVERAGE size
-- of all videos in the platform
-- Technique: simple scalar subquery in the WHERE clause, joined back
-- to post and users to show who posted the oversized video.
SELECT
    v.video_id,
    v.video_url,
    v.size,
    p.post_id,
    u.username
FROM videos v
JOIN post p ON v.video_id = p.video_id
JOIN users u ON p.user_id = u.user_id
WHERE v.size > (SELECT AVG(size) FROM videos);

