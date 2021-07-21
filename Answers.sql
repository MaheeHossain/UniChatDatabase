-- Your Name: Mahee Hossain
-- Your Student Number: 1080102
-- By submitting, you declare that this work was completed entirely by yourself.

-- BEGIN Q1

-- List all the forums created and closed by the same lecturer. Your query should return results of the form 
-- (forum ID, topic, lecturer ID who created/closed them). (1 mark)

SELECT forum.Id, Topic, CreatedBy
FROM forum
WHERE CreatedBy = ClosedBy;

-- END Q1

-- BEGIN Q2

-- For each lecturer show how many forums they have created. Your query should return results of the form 
-- (Lecturer ID, their full name, the number of forums created by them). (1 mark)

SELECT user.Id, CONCAT(user.Firstname, ' ', user.Lastname) AS "Full Name", COUNT(forum.CreatedBy) AS "Number of Forums"
FROM user NATURAL JOIN lecturer NATURAL JOIN forum
GROUP BY user.ID;
-- END Q2

-- BEGIN Q3

-- List all the users who never posted a top-level post. Your query should return results of the form (userID, username). (1 mark) 


SELECT user.Id, Username
FROM user LEFT OUTER JOIN post ON user.Id = post.PostedBy
GROUP BY user.ID
HAVING COUNT(Forum) = 0;

-- END Q3

-- BEGIN Q4

-- Display the post ID of the top-level posts with no comments and no likes. 
-- Your query should return results of the form (postID). (2 marks) 

SELECT post.Id
FROM post
WHERE post.Id NOT IN
 	(SELECT post.ID FROM post NATURAL JOIN likepost
 	 WHERE post.ID = likepost.Post)
  	 AND
  	 post.ParentPost IS NULL
GROUP BY post.Id;

-- END Q4

-- BEGIN Q5

-- List the post ID, content and count of posts with the most number of likes. Display all such posts in case of a tie. 
-- Your query should return results of the form (postID, content string, number of likes). (2 marks) 

SELECT post.Id, Content, COUNT(likepost.Post) AS "Number of Likes"
FROM post INNER JOIN likepost ON post.Id = likepost.Post
GROUP BY post.Id
ORDER BY COUNT(likepost.Post) DESC
LIMIT 1; -- Doesn't account for ties

-- END Q5

-- BEGIN Q6

-- Which top-level post has the longest length? Display its length, its content, topic of the forum where its posted and 
-- the first and last name of the user (combined as full name) who posted it. Display all posts with the longest length 
-- in case of a tie. Your query should return results of the form (length, content string, topic of forum, user’s full name). (2 marks) 

-- Other stuff don't work??
SELECT length(post.Content) AS length-- , post.Content, forum.Topic, CONCAT(user.Firstname, ' ', user.Lastname) as "Full Name"
FROM (forum INNER JOIN post ON forum.Id = post.forum) INNER JOIN user ON user.Id = post.PostedBy
WHERE post.ParentPost IS NULL
GROUP BY length
ORDER BY length DESC
LIMIT 1; -- Doesn't account for ties


-- END Q6

-- BEGIN Q7

-- Display two students who remained friends for the shortest duration. List IDs of both students and the number 
-- of days they remained friends for. Display all such pairs in case of a tie. If A and B are such friends, it is 
-- sufficient to display only A and B (no need to display the symmetrical solution B and A). 
-- Your query should return results of the form (student1ID, student2ID). (2 marks) 

SELECT Student1, Student2
FROM friendof
WHERE friendof.WhenUnfriended IS NOT NULL
ORDER BY DATEDIFF(friendof.WhenConfirmed, friendof.WhenUnfriended) DESC
LIMIT 1; -- Doesn't account for ties



-- END Q7

-- BEGIN Q8

-- For each user liking a post, calculate how many other users have liked the same post. Display the user ID, 
-- the number of other users who are liking the same post and post ID. Your query should return results of the form 
-- (userID of person who liked post, count of other users liking the post, postID). (3 marks) 

SELECT curr.user, (likes-1) AS "Other user likes", post
FROM likepost AS curr INNER JOIN 
(SELECT COUNT(post) AS likes, post AS otherpost
FROM likepost GROUP BY otherpost) AS other
ON curr.post = other.otherpost;


-- END Q8

-- BEGIN Q9

-- Let us call the student who has the greatest number of likes on the website (across all posts)
-- the "most popular student". List userIDs of all the currently confirmed friends of the "most popular student",
-- who are also doing the same degree as the "most popular student". Assume there are no ties
-- (i.e., only one person is most popular). Your query should return results of the form (userID). (3 marks) 

-- Get all the students who are doing the same degree and the same course
SELECT Student1-- *
FROM (friendof INNER JOIN (SELECT Degree as FriendDegree, student.Id, student.karma AS FriendKarma FROM student) AS Friend 
	  ON Friend.id = friendof.student1
	  INNER JOIN (SELECT Degree as FriendDegree2, student.Id, student.karma AS Friend2Karma FROM student) AS Friend2
	  ON Friend2.id = friendof.student2)
      WHERE FriendDegree = FriendDegree2
      ORDER BY FriendKarma DESC;-- We can find that its student 7 who is most popular and that their friends are 3 & 8



-- END Q9

-- BEGIN Q10

-- List all top-level posts by a student which did not receive a reply from the lecturer who created that forum
-- within 48 hours or are currently unanswered. Your query should return results of the form 
-- (post ID, the time when the post was created). (3 marks)

SELECT post.Id, WhenPosted
FROM (post INNER JOIN user ON post.PostedBy = user.id) INNER JOIN student ON user.id = student.id
WHERE post.ParentPost IS NULL AND post.Id <> LecturerComment.ParentPost IN (SELECT post as LecturerComment FROM 
   (post INNER JOIN forum ON post.Forum = forum.id) INNER JOIN lecture ON forum.CreatedBy = lecturer.Id
   WHERE post.PostedBy = lecturer.Id AND TIMESTAMPDIFF(HOUR, post.WhenPosted, LecturerComment.WhenPosted) < 48
   ); -- This should get all the comments the lecturer has made in last 48 hours


-- END Q10

-- END OF ASSIGNMENT Do not write below this line
