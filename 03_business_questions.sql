-- ==========================================================
-- 03_business_questions.sql
-- Business/analytical questions (8 queries)
-- ==========================================================

-- 1 What is the location of each user in the social media database?
SELECT DISTINCT 
    u.user_id, 
    u.username, 
    p.location
FROM users u
JOIN post p ON u.user_id = p.user_id
WHERE p.location IS NOT NULL;

-- 2 Which hashtag has the highest number of followers in the social media database? (Give me the first 5 ones).
SELECT 
    h.hashtag_id,
    h.hashtag_name,
    COUNT(hf.user_id) AS total_followers
FROM hashtags h
JOIN hashtag_follow hf ON h.hashtag_id = hf.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
ORDER BY total_followers DESC
LIMIT 5;

-- 3 What are the most frequently used hashtags in the social media database? (Give me the used for all hashtags and determine which one is the most).
SELECT 
    h.hashtag_id,
    h.hashtag_name,
    COUNT(pt.post_id) AS usage_count
FROM hashtags h
LEFT JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
ORDER BY usage_count DESC;

-- 4 Who is the most inactive user (or the user with the least activity) in the social media database? (Give me the first 5 and determine which one is the least).
SELECT 
    u.user_id,
    u.username,
    COALESCE(p.post_count, 0) AS total_posts,
    COALESCE(c.comment_count, 0) AS total_comments,
    COALESCE(l.like_count, 0) AS total_likes,
    (COALESCE(p.post_count, 0) + COALESCE(c.comment_count, 0) + COALESCE(l.like_count, 0)) AS total_activity_score
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS post_count 
    FROM post 
    GROUP BY user_id
) p ON u.user_id = p.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS comment_count 
    FROM comments 
    GROUP BY user_id
) c ON u.user_id = c.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS like_count 
    FROM post_likes 
    GROUP BY user_id
) l ON u.user_id = l.user_id
ORDER BY total_activity_score ASC
LIMIT 5;

-- 5 Which posts have received the highest number of likes in the social media database?
SELECT 
    p.post_id,
    p.caption,
    p.user_id AS author_id,
    COUNT(pl.user_id) AS total_likes
FROM post p
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY p.post_id, p.caption, p.user_id
ORDER BY total_likes DESC;

-- 6 What is the average number of posts per user in the social media database?
SELECT 
    COUNT(p.post_id) / COUNT(DISTINCT u.user_id) AS avg_posts_per_user
FROM users u
LEFT JOIN post p ON u.user_id = p.user_id;

-- 7 How many times has each user logged in to the social media platform?
SELECT 
    u.user_id,
    u.username,
    COUNT(l.login_id) AS total_logins
FROM users u
LEFT JOIN login l ON u.user_id = l.user_id
GROUP BY u.user_id, u.username
ORDER BY total_logins DESC;

-- 8 Are there any users who have liked every single post in the social media database?
SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT pl.post_id) AS liked_posts_count
FROM users u
JOIN post_likes pl ON u.user_id = pl.user_id
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT pl.post_id) = (SELECT COUNT(*) FROM post);
