<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>MS Degree Requirement Checker</title>
    <script>
        function submitForm() {
            document.getElementById('requirementForm').submit();
        }
    </script>
</head>
<body>
<h1>Check Remaining Degree Requirements for MS</h1>
<form method="post" id="requirementForm">
    <label for="ssn">Select Student:</label>
    <select name="ssn" id="ssn" required>
        <option value="">Select a student</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String selectSQL = "SELECT s.ssn, s.first_name, s.middle_name, s.last_name FROM student s JOIN master m ON s.student_id = m.student_id WHERE s.is_enrolled = TRUE";
                pstmt = conn.prepareStatement(selectSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String ssn = rs.getString("ssn");
                    String firstName = rs.getString("first_name");
                    String middleName = rs.getString("middle_name");
                    String lastName = rs.getString("last_name");
        %>
        <option value="<%= ssn %>"><%= ssn %> - <%= firstName %> <%= (middleName != null ? middleName + " " : "") %> <%= lastName %></option>
        <%
                }
            } catch (SQLException e) {
                out.println("<p>Error executing SQL: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                if (conn != null) try { conn.close(); } catch(SQLException e) {}
            }
        %>
    </select>
    <br><br>
    <label for="degree_name">Select Degree:</label>
    <select name="degree_name" id="degree_name" required>
        <option value="">Select a degree</option>
        <%
            try {
                conn = DatabaseConnection.getConnection();
                String degreeSQL = "SELECT name FROM degree WHERE type = 'Master'";
                pstmt = conn.prepareStatement(degreeSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String degreeName = rs.getString("name");
        %>
        <option value="<%= degreeName %>"><%= degreeName %></option>
        <%
                }
            } catch (SQLException e) {
                out.println("<p>Error executing SQL: " + e.getMessage() + "</p>");
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                if (conn != null) try { conn.close(); } catch(SQLException e) {}
            }
        %>
    </select>
    <br><br>
    <input type="submit" value="Check Requirements">
</form>

<%
    String ssn = request.getParameter("ssn");
    String degreeName = request.getParameter("degree_name");

    if (ssn != null && degreeName != null && !ssn.isEmpty() && !degreeName.isEmpty()) {
        try {
            conn = DatabaseConnection.getConnection();

            // Display completed concentrations
            String completedConcentrationsSQL = "SELECT conc.name AS concentration_name FROM concentration conc JOIN degree_concentration dc ON conc.concentration_id = dc.concentration_id JOIN concentration_course cc ON conc.concentration_id = cc.concentration_id JOIN course co ON cc.course_id = co.course_id LEFT JOIN class cl ON co.course_id = cl.course_id LEFT JOIN enrollment en ON cl.class_id = en.class_id AND en.student_id = (SELECT student_id FROM student WHERE ssn = ?) LEFT JOIN grade_conversion gc ON en.grade::text = gc.letter_grade AND en.grade_type = 'Letter Grade' WHERE dc.degree_id = (SELECT degree_id FROM degree WHERE name = ?) GROUP BY conc.concentration_id, conc.name HAVING COUNT(DISTINCT co.course_id) = COUNT(DISTINCT CASE WHEN en.grade NOT IN ('N/A', 'F', 'D', 'S', 'U') OR (en.grade_type = 'S/U' AND en.grade = 'S') THEN co.course_id END) AND AVG(CASE WHEN en.grade_type = 'Letter Grade' THEN gc.number_grade ELSE NULL END) >= (SELECT minimum_grade FROM degree WHERE name = ?)";
            pstmt = conn.prepareStatement(completedConcentrationsSQL);
            pstmt.setString(1, ssn);
            pstmt.setString(2, degreeName);
            pstmt.setString(3, degreeName);
            rs = pstmt.executeQuery();
            out.println("<h3>Completed Concentrations:</h3><ul>");
            boolean hasCompleted = false;
            while (rs.next()) {
                hasCompleted = true;
                String concentrationName = rs.getString("concentration_name");
                out.println("<li>" + concentrationName + "</li>");
            }
            if (!hasCompleted) {
                out.println("<li>No completed concentrations.</li>");
            }
            out.println("</ul>");
            rs.close();
            pstmt.close();

            // List courses not yet taken
            String coursesNotTakenSQL = "SELECT conc.name AS concentration_name, co.course_number, co.course_id, MIN(cl.year || ' ' || cl.quarter) AS next_offering FROM concentration conc JOIN degree_concentration dc ON conc.concentration_id = dc.concentration_id JOIN concentration_course cc ON conc.concentration_id = cc.concentration_id JOIN course co ON cc.course_id = co.course_id LEFT JOIN class cl ON co.course_id = cl.course_id AND (cl.year > 2018 OR (cl.year = 2018 AND cl.quarter IN ('SUMMER SESSION 1', 'SUMMER SESSION 2', 'SUMMER SESSION SPECIAL'))) LEFT JOIN ( SELECT cl.course_id FROM class cl JOIN enrollment en ON cl.class_id = en.class_id WHERE en.student_id = (SELECT student_id FROM student WHERE ssn = ?) AND en.grade NOT IN ('N/A', 'F', 'D', 'U') AND (en.grade_type = 'Letter Grade' OR (en.grade_type = 'S/U' AND en.grade = 'S')) ) completed_courses ON co.course_id = completed_courses.course_id WHERE dc.degree_id = (SELECT degree_id FROM degree WHERE name = ?) AND completed_courses.course_id IS NULL GROUP BY conc.concentration_id, co.course_id, co.course_number, conc.name ORDER BY conc.name, co.course_number;";
            pstmt = conn.prepareStatement(coursesNotTakenSQL);
            pstmt.setString(1, ssn);
            pstmt.setString(2, degreeName);
            rs = pstmt.executeQuery();
            out.println("<h3>Courses Not Yet Taken:</h3>");
            boolean hasCourses = false;
            while (rs.next()) {
                hasCourses = true;
                String concentrationName = rs.getString("concentration_name");
                String courseNumber = rs.getString("course_number");
                int courseId = rs.getInt("course_id");
                String nextOffering = rs.getString("next_offering");
                out.println("<p>" + concentrationName + " - Course ID: " + courseId + ", " + courseNumber + " - Next offered: " + nextOffering + "</p>");
            }
            if (!hasCourses) {
                out.println("<p>All required courses have been completed for this degree.</p>");
            }
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            out.println("<p>Error: " + e.getMessage() + "</p>");
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch(SQLException e) {}
        }
    } else {
        out.println("<p>Please select both a student and a degree to check the requirements.</p>");
    }
%>

</body>
</html>
