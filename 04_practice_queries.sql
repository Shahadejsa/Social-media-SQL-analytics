-- ==========================================================
-- 04_practice_queries.sql
-- 10 SQL practice questions
-- ==========================================================


-- 1 Write a SQL query to display every post along with the username of its author, the total number of likes, and the total number of comments.
SELECT 
    p.post_id,
    u.username AS author,
    p.caption,
    COUNT(DISTINCT pl.user_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments
FROM post p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN post_likes pl ON p.post_id = pl.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, u.username, p.caption;

-- 2 Write a SQL query to find all users who have never created a post.
SELECT 
    u.user_id,
    u.username,
    u.email
FROM users u
LEFT JOIN post p ON u.user_id = p.user_id
WHERE p.post_id IS NULL;
-- 3 Write a SQL query to find the five users whose posts have received the highest total number of likes.
SELECT 
    u.user_id,
    u.username,
    COUNT(pl.user_id) AS total_likes_received
FROM users u
JOIN post p ON u.user_id = p.user_id
JOIN post_likes pl ON p.post_id = pl.post_id
GROUP BY u.user_id, u.username
ORDER BY total_likes_received DESC
LIMIT 5;
-- 4 Write a SQL query to display the latest post created by each user, including the username, post caption, location, and creation date.
SELECT 
    u.username,
    p1.caption,
    p1.location,
    p1.created_at
FROM post p1
JOIN users u ON p1.user_id = u.user_id
JOIN (
    SELECT 
        user_id, 
        MAX(created_at) AS latest_created_at
    FROM post
    GROUP BY user_id
) p2 ON p1.user_id = p2.user_id AND p1.created_at = p2.latest_created_at;

-- 5 Write a SQL query to find users whose number of followers is greater than the average follower count of all users.

SELECT 
    u.user_id,
    u.username,
    COUNT(f.follower_id) AS follower_count
FROM users u
LEFT JOIN follows f ON u.user_id = f.followee_id
GROUP BY u.user_id, u.username
HAVING COUNT(f.follower_id) > (
    SELECT AVG(follower_counts.total_followers)
    FROM (
        SELECT COUNT(f2.follower_id) AS total_followers
        FROM users u2
        LEFT JOIN follows f2 ON u2.user_id = f2.followee_id
        GROUP BY u2.user_id
    ) AS follower_counts
);

-- 6 Write a SQL query to find the post or posts that have received the highest number of likes.

WITH RankedPosts AS (
    SELECT 
        p.post_id,
        p.caption,
        p.user_id AS author_id,
        COUNT(pl.user_id) AS total_likes,
        RANK() OVER (ORDER BY COUNT(pl.user_id) DESC) AS rnk
    FROM post p
    LEFT JOIN post_likes pl ON p.post_id = pl.post_id
    GROUP BY p.post_id, p.caption, p.user_id
)
SELECT 
    post_id,
    caption,
    author_id,
    total_likes
FROM RankedPosts
WHERE rnk = 1;

-- 7 Write a SQL query to find hashtags that have been used in at least three different posts. Display each hashtag, the number of posts using it, and the number of users following it.
SELECT 
    h.hashtag_name,
    COUNT(DISTINCT pt.post_id) AS post_count,
    COUNT(DISTINCT hf.user_id) AS follower_count
FROM hashtags h
JOIN post_tags pt ON h.hashtag_id = pt.hashtag_id
LEFT JOIN hashtag_follow hf ON h.hashtag_id = hf.hashtag_id
GROUP BY h.hashtag_id, h.hashtag_name
HAVING COUNT(DISTINCT pt.post_id) >= 3;

-- 8 Write a SQL query to find users who bookmarked a post that they also liked. Display the username, post ID, and post caption.
SELECT DISTINCT
    u.username,
    p.post_id,
    p.caption
FROM bookmarks b
JOIN post_likes pl ON b.user_id = pl.user_id AND b.post_id = pl.post_id
JOIN users u ON b.user_id = u.user_id
JOIN post p ON b.post_id = p.post_id;

-- 9 Write a SQL query to find comments that have received more likes than the average number of likes received by all comments.
SELECT 
    c.comment_id,
    c.comment_text,
    c.user_id AS commenter_id,
    COUNT(cl.user_id) AS total_likes
FROM comments c
LEFT JOIN comment_likes cl ON c.comment_id = cl.comment_id
GROUP BY c.comment_id, c.comment_text, c.user_id
HAVING COUNT(cl.user_id) > (
    SELECT AVG(like_counts.total_likes)
    FROM (
        SELECT COUNT(cl2.user_id) AS total_likes
        FROM comments c2
        LEFT JOIN comment_likes cl2 ON c2.comment_id = cl2.comment_id
        GROUP BY c2.comment_id
    ) AS like_counts
);

-- 10 Write a SQL query to find pairs of users who follow each other. Display each pair only once.
SELECT 
    u1.username AS user_1,
    u2.username AS user_2
FROM follows f1
JOIN follows f2 
    ON f1.follower_id = f2.followee_id 
   AND f1.followee_id = f2.follower_id
JOIN users u1 ON f1.follower_id = u1.user_id
JOIN users u2 ON f1.followee_id = u2.user_id
WHERE f1.follower_id < f1.followee_id;
