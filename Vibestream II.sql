/* Vibestream II SQL Challenge
Author: Robert Tiger
Date: 20th, Feb, 2023
Masterschool Mar' 23 cohort
*/

/*
Question #1:
Vibestream is designed for users to share brief updates about how they are feeling, as such the platform enforces a character limit of 25.
How many posts are exactly 25 characters long?

Expected column names: char_limit_posts
*/
-- q1 solution:
SELECT COUNT(LENGTH(content)) AS char_limit_posts
FROM posts
WHERE LENGTH(content) = 25

/*
Question #2: 
Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day that at least one of them made a post.
Return dates where the absolute value of the difference between posts made is greater than 2 (i.e dates where JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or vice versa).

Expected column names: post_date
*/
-- q2 solution:

SELECT 
    posts.post_date  -- Selecting the post_date column as the result
FROM 
    (SELECT DISTINCT post_date FROM posts) AS dates  -- Subquery to select all distinct post dates
LEFT JOIN 
    (SELECT 
        post_date,  -- Selecting the post_date column for grouping
        SUM(CASE WHEN user_id = (SELECT user_id FROM users WHERE user_name = 'JamesTiger8285') THEN 1 ELSE 0 END) AS James_posts,  -- Calculating the number of posts made by JamesTiger8285 on each date
        SUM(CASE WHEN user_id = (SELECT user_id FROM users WHERE user_name = 'RobertMermaid7605') THEN 1 ELSE 0 END) AS Robert_posts  -- Calculating the number of posts made by RobertMermaid7605 on each date
    FROM 
        posts
    GROUP BY 
        post_date) AS posts ON dates.post_date = posts.post_date  -- Joining the dates subquery with the posts subquery on post_date
WHERE 
    ABS(James_posts - Robert_posts) > 2  -- Filtering for dates where the absolute difference between the number of posts made by the two users is greater than 2
    OR (James_posts IS NULL AND Robert_posts > 2)  -- Including dates where JamesTiger8285 did not make any posts but RobertMermaid7605 made more than 2 posts
    OR (Robert_posts IS NULL AND James_posts > 2);  -- Including dates where RobertMermaid7605 did not make any posts but JamesTiger8285 made more than 2 posts

/*
Question #3: 
Most users have relatively low engagement and few connections. User WilliamEagle6815, for example, has only 2 followers. 

Network Analysts would say this user has two 1-step path relationships. Having 2 followers doesn’t mean WilliamEagle6815 is isolated, however.
Through his followers, he is indirectly connected to the larger Vibestream network.  

Consider all users up to 3 steps away from this user:

1-step path (X → WilliamEagle6815)
2-step path (Y → X → WilliamEagle6815)
3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815. Order by follower_id and return the top 10 records.

Expected column names: follower_id
*/
-- q3 solution:
WITH RECURSIVE UserPaths AS (
    -- Base case: WilliamEagle6815's immediate followers
    SELECT follower_id, 1 AS steps
    FROM follows
    WHERE followee_id = (SELECT user_id FROM users WHERE user_name = 'WilliamEagle6815')

    UNION ALL

    -- Recursive step: Expand paths by one step
    SELECT f.follower_id, up.steps + 1
    FROM UserPaths up
    JOIN follows f ON up.follower_id = f.followee_id
    WHERE up.steps < 4 -- Limit to 3 steps away conclusive
)

SELECT DISTINCT follower_id
FROM UserPaths
ORDER BY follower_id
LIMIT 10;

/*
 Question #4: 
Return top posters for 2023-11-30 and 2023-12-01.
A top poster is a user who has the most OR second most number of posts in a given day. -- Need to count posts for every user in each of the days and sort DESC
Include the number of posts in the result and order the result by post_date and user_id.

Expected column names: post_date, user_id, posts
*/

-- q4 solution:
SELECT
  user_id,
  post_date,
  COUNT(post_id) AS posts
FROM
  posts
WHERE
  post_date = '2023-11-30'
  OR post_date = '2023-12-01'
GROUP BY
  post_date,
  user_id
HAVING
  COUNT(DISTINCT post_id) > 1
ORDER BY
  2,
  1;
