Use PortofolioProjectSQL;
--Adding an ID column to our table for convinience
ALTER TABLE stress
ADD  id INT IDENTITY(1,1) PRIMARY KEY;

--TABLE PREVIEW
SELECT * FROM stress;

--1)Average anxiety level of students
----The anxiety levels range from 0 being the minimum to 21 being the maximum
SELECT AVG(anxiety_level)  as Average_Anxiety FROM stress;

--2)Number of student reporting having a mentalhealt history
----Mental health history is a Boolean variable where 0 means no history record at all and 1 means there exists mental healt history
SELECT COUNT(mental_health_history) as Illness_Records FROM stress
WHERE mental_health_history=1; 

--3)Distribution of sleep quality among students
----0 being the worst sleep quality and 5 being the best
SELECT
  sleep_quality,
  COUNT(*) as num_students,
	(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () ) as percentage
FROM stress
GROUP BY sleep_quality
ORDER BY sleep_quality;

--4)Self esteem difference between students with and without mental healt records
 ----Lowest self esteem is 0 and highest is 30
 SELECT
  AVG(CASE WHEN mental_health_history =1 THEN self_esteem END) AS avg_self_esteem_with_history,
  AVG(CASE WHEN mental_health_history = 0 THEN self_esteem END) AS avg_self_esteem_without_history
FROM stress;

--5)Social support and anxiety level corellation
----Social support does not seem to have a big impact on anxiety levels
SELECT social_support,COUNT(id) AS num_students, AVG(anxiety_level) AS avg_anxiety FROM stress
GROUP BY social_support
ORDER BY social_support;

--6)Health metrics of students with the most anxiety
----If we categorize students in 3 sections depending on their anxiety level we get 3 main groups: 
----Group number 1 is the group with the low anxiety (from 0 to 7) 
----Group number 2 is the group with moderate anxiety (from 8 to 14)
----Group number 3 is the group with high/max anxiety (from 15 to 21)
----If we do so we get some patterns in each category
WITH MaxAnxietyStudents AS (
    SELECT id, headache, blood_pressure, mental_health_history
    FROM stress
    WHERE anxiety_level BETWEEN (SELECT MAX(anxiety_level) FROM stress)-6 AND (SELECT MAX(anxiety_level) FROM stress)
)
SELECT
    'Headache' AS category,
    headache AS level, 
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MaxAnxietyStudents
WHERE headache BETWEEN 0 AND 5
GROUP BY headache

UNION ALL

SELECT
    'Blood Pressure' AS category,
    blood_pressure AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MaxAnxietyStudents
WHERE blood_pressure BETWEEN 1 AND 3
GROUP BY blood_pressure

UNION ALL

SELECT
    'Mental Health History' AS category,
    mental_health_history AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MaxAnxietyStudents
WHERE mental_health_history BETWEEN 0 AND 1
GROUP BY mental_health_history;

WITH ModAnxietyStudents AS (
    SELECT id, headache, blood_pressure, mental_health_history
    FROM stress
    WHERE anxiety_level BETWEEN (SELECT MAX(anxiety_level) FROM stress)-13 AND (SELECT MAX(anxiety_level) FROM stress)-7
)
SELECT
    'Headache' AS category,
    headache AS level, 
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM ModAnxietyStudents
WHERE headache BETWEEN 0 AND 5
GROUP BY headache

UNION ALL

SELECT
    'Blood Pressure' AS category,
    blood_pressure AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM ModAnxietyStudents
WHERE blood_pressure BETWEEN 1 AND 3
GROUP BY blood_pressure

UNION ALL

SELECT
    'Mental Health History' AS category,
    mental_health_history AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM ModAnxietyStudents
WHERE mental_health_history BETWEEN 0 AND 1
GROUP BY mental_health_history;

WITH MinAnxietyStudents AS (
    SELECT id, headache, blood_pressure, mental_health_history, depression
    FROM stress
    WHERE anxiety_level BETWEEN (SELECT MAX(anxiety_level) FROM stress)-21 AND (SELECT MAX(anxiety_level) FROM stress)-14
)
SELECT
    'Headache' AS category,
    headache AS level, 
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MinAnxietyStudents
WHERE headache BETWEEN 0 AND 5
GROUP BY headache

UNION ALL

SELECT
    'Blood Pressure' AS category,
    blood_pressure AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MinAnxietyStudents
WHERE blood_pressure BETWEEN 1 AND 3
GROUP BY blood_pressure

UNION ALL

SELECT
    'Mental Health History' AS category,
    mental_health_history AS level,
    COUNT(*) AS num_stud,
    100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS percentage
FROM MinAnxietyStudents
WHERE mental_health_history BETWEEN 0 AND 1
GROUP BY mental_health_history;

--7)Patterns on the dataset based on teacher student-relationship and social factors
----Group 1: Students where teacher-student relationship score is 0,2 or 3
------ In this group we see that although the teacher-student relationship scores are significantly different ( one is 0(minimum) and the other is 3(medium)) 
------and the average social support for each group varies by 33.33% almost all the other average factors are the same.Specifically Although the subgroups of students
------with scores 0 and 3 on the teacher-student relationship scale vary by 66.66% on the average social support meter , they display only a small amount
------of difference in the average deppression scale by 3 units. Moreover the other subgroup (with student-teacher relationship score of 2) differs by 33% 
------on the average study load section from the previous two , thus explaining the higher average anxiety and depression and also higher concerns on futue
------career than the other subgroup.All of the subgroups have living conditions of 2(medium)
----Group 2: Students where teacher-student relationship is 1
------This group has the highest anxiety and depression and the lowest livnig conditions.These factors are the result of high study load with poor academic
------performance.It is noteworthy that this group presents the highest average on the futere career concerns section which makes total sense when the 
------ nonexistent social support and poor living conditions records are taken into account.
----Group 3: Students  teacher-student relationship is 4 or 5
-------The last group is characterised by its ''well fitted'' scores meaning they are in the perfect score range.Even though they display 1 out of  4 levels 
-------of difference in the social support status (0 being the lowest 3 being the highest) all the other factorts are equall. We see that this group has
------- very close relationships with its teacher, the lowest study load which might explain the highest academic performance. Lastly it exhibits the 
-------lowest future career concerns which might be expained by the highest living conditions.
----From this analysis that the social support plays a more crucial role in the life of a student when it takes its minimum and maximum values.

WITH RelationshipDetails AS (
    SELECT
        teacher_student_relationship,
        AVG(social_support) AS avg_social_support,
        AVG(anxiety_level) AS avg_anxiety,
        AVG(study_load) AS avg_study_load,
		AVG(academic_performance) AS avg_academic_performance,
		AVG(future_career_concerns) AS avg_career_concerns,
		AVG(living_conditions) AS avg_living_conditions,
		AVG(depression) as avg_depression,
        COUNT(*) AS num_students,
		COUNT(*)*100.0/sUM(COUNT(*)) OVER () AS percentage
    FROM stress
    WHERE teacher_student_relationship IS NOT NULL
    GROUP BY teacher_student_relationship
)
SELECT
    
    teacher_student_relationship,
    avg_social_support,
    avg_anxiety,
    avg_study_load,
	avg_academic_performance,
	avg_career_concerns,
	avg_living_conditions,
	avg_depression,
    num_students,
	percentage
FROM RelationshipDetails
ORDER BY teacher_student_relationship;
