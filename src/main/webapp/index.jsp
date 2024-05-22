<%@ page import="java.sql.*" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Database Entry</title>
    <style>
        iframe {
            width: 100%;
            height: 600px; /* Adjust the height as needed */
            border: none;
        }
    </style>
</head>
<body>
<b>Data Entry Menu</b>
<ul>
    <li><a href="form/DepartmentEntry.jsp" target="contentFrame">Departments</a></li>
    <li><a href="form/CourseEntry.jsp" target="contentFrame">Courses</a></li>
    <li><a href="form/ClassEntry.jsp" target="contentFrame">Classes</a></li>
    <li><a href="form/DegreeEntry.jsp" target="contentFrame">Degrees</a></li>
    <li><a href="form/StudentEntry.jsp" target="contentFrame">Students</a></li>
    <li><a href="form/FacultyEntry.jsp" target="contentFrame">Faculty</a></li>
    <li><a href="form/SectionEntry.jsp" target="contentFrame">Sections</a></li>
    <li><a href="form/EnrollmentEntry.jsp" target="contentFrame">Enrollment</a></li>
    <li><a href="form/ThesisCommitteeEntry.jsp" target="contentFrame">Thesis Committee</a></li>
    <li><a href="form/UndergraduateEntry.jsp" target="contentFrame">Undergraduate Entry</a></li>
    <li><a href="form/MasterStudentEntry.jsp" target="contentFrame">Master Student Entry</a></li>
    <li><a href="form/PhDEntry.jsp" target="contentFrame">PhD Entry</a></li>
    <li><a href="form/FacultyThesisCommittee.jsp" target="contentFrame">Faculty Thesis Committee</a></li>
    <li><a href="form/ProbationEntry.jsp" target="contentFrame">Probation</a></li>
    <li><a href="form/MeetingEntry.jsp" target="contentFrame">Meeting</a></li>
    <li><a href="form/ReviewSessionEntry.jsp" target="contentFrame">Review Session</a></li>
</ul>
<b>Query Form</b>
<ul>
    <li><a href="query/ClassesTakenByStudent.jsp" target="contentFrame">Classes Taken by Student</a></li>
    <li><a href="query/ClassRoster.jsp" target="contentFrame">Class Roaster</a></li>
    <li><a href="query/StudentGrade.jsp" target="contentFrame">Student Grade</a></li>
    <li><a href="query/RemainingDegreeRequirements.jsp" target="contentFrame">Student Remaining Degree Requirements</a></li>
</ul>
<iframe name="contentFrame"></iframe>
</body>
</html>
