<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Grade Distribution for Specific Course and Quarter</title>
</head>
<body>
<h1>Grade Distribution Report</h1>
<form method="post">
    <label for="courseId">Course ID:</label>
    <input type="number" id="courseId" name="courseId" required><br>

    <label for="professorName">Professor Name:</label>
    <input type="text" id="professorName" name="professorName" required><br>

    <label for="quarter">Select Quarter:</label>
    <select id="quarter" name="quarter">
        <option value="FALL">FALL</option>
        <option value="WINTER">WINTER</option>
        <option value="SPRING">SPRING</option>
        <option value="SUMMER SESSION 1">SUMMER SESSION 1</option>
        <option value="SUMMER SESSION 2">SUMMER SESSION 2</option>
        <option value="SUMMER SESSION SPECIAL">SUMMER SESSION SPECIAL</option>
    </select><br>

    <input type="submit" value="Generate Report">
</form>

<%
    String courseIdParam = request.getParameter("courseId");
    if (courseIdParam != null && !courseIdParam.isEmpty()) {
        int courseId = Integer.parseInt(courseIdParam);  // Parse the input as integer
        String professorName = request.getParameter("professorName");
        String quarter = request.getParameter("quarter");

        if (professorName != null && quarter != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String query = "SELECT " +
                        "CASE " +
                        "WHEN gc.letter_grade IN ('A+', 'A', 'A-') THEN 'A' " +
                        "WHEN gc.letter_grade IN ('B+', 'B', 'B-') THEN 'B' " +
                        "WHEN gc.letter_grade IN ('C+', 'C', 'C-') THEN 'C' " +
                        "WHEN gc.letter_grade IN ('D+', 'D', 'D-') THEN 'D' " +
                        "ELSE 'Other' " +
                        "END AS grade_category, " +
                        "COUNT(*) AS count " +
                        "FROM enrollment e " +
                        "JOIN section sec ON e.section_id = sec.section_id AND e.class_id = sec.class_id " +
                        "JOIN class cl ON sec.class_id = cl.class_id " +
                        "JOIN faculty fac ON sec.faculty_name = fac.faculty_name " +
                        "JOIN grade_conversion gc ON e.grade::text = gc.letter_grade " +
                        "WHERE cl.course_id = ? " +
                        "AND fac.faculty_name = ? " +
                        "AND cl.quarter::text = ? " +  // Cast quarter to text for comparison
                        "AND e.grade_type = 'Letter Grade' " +
                        "AND e.grade NOT IN ('N/A') " +
                        "GROUP BY grade_category";
                pstmt = conn.prepareStatement(query);
                pstmt.setInt(1, courseId);
                pstmt.setString(2, professorName);
                pstmt.setString(3, quarter);
                rs = pstmt.executeQuery();
                out.println("<h2>Grade Distribution Results</h2>");
                out.println("<table border='1'><tr><th>Grade Category</th><th>Count</th></tr>");
                while (rs.next()) {
                    out.println("<tr><td>" + rs.getString("grade_category") + "</td><td>" + rs.getInt("count") + "</td></tr>");
                }
                out.println("</table>");
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<p>Error executing the query: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                if (conn != null) try { conn.close(); } catch(SQLException e) {}
            }
        }
    }
%>

<h2>Grade Distribution by Professor Over the Years</h2>
<form method="post">
    <label for="courseIdOverall">Course ID:</label>
    <input type="number" id="courseIdOverall" name="courseIdOverall" required><br>

    <label for="professorNameOverall">Professor Name:</label>
    <input type="text" id="professorNameOverall" name="professorNameOverall" required><br>

    <input type="submit" value="Generate Report">
</form>
<%
    String courseIdOverallParam = request.getParameter("courseIdOverall");
    if (courseIdOverallParam != null && !courseIdOverallParam.isEmpty()) {
        int courseIdOverall = Integer.parseInt(courseIdOverallParam);  // Parse the input as integer
        String professorNameOverall = request.getParameter("professorNameOverall");

        if (professorNameOverall != null) {
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String queryOverall = "SELECT " +
                        "CASE " +
                        "WHEN gc.letter_grade IN ('A+', 'A', 'A-') THEN 'A' " +
                        "WHEN gc.letter_grade IN ('B+', 'B', 'B-') THEN 'B' " +
                        "WHEN gc.letter_grade IN ('C+', 'C', 'C-') THEN 'C' " +
                        "WHEN gc.letter_grade IN ('D+', 'D', 'D-') THEN 'D' " +
                        "ELSE 'Other' " +
                        "END AS grade_category, " +
                        "COUNT(*) AS count " +
                        "FROM enrollment e " +
                        "JOIN section sec ON e.section_id = sec.section_id AND e.class_id = sec.class_id " +
                        "JOIN class cl ON sec.class_id = cl.class_id " +
                        "JOIN faculty fac ON sec.faculty_name = fac.faculty_name " +
                        "JOIN grade_conversion gc ON e.grade::text = gc.letter_grade " +
                        "WHERE cl.course_id = ? " +
                        "AND fac.faculty_name = ? " +
                        "AND e.grade_type = 'Letter Grade' " +
                        "AND e.grade NOT IN ('N/A') " +
                        "GROUP BY grade_category";
                pstmt = conn.prepareStatement(queryOverall);
                pstmt.setInt(1, courseIdOverall);
                pstmt.setString(2, professorNameOverall);
                rs = pstmt.executeQuery();
                out.println("<h3>Grade Distribution Results Over the Years</h3>");
                out.println("<table border='1'><tr><th>Grade Category</th><th>Count</th></tr>");
                while (rs.next()) {
                    out.println("<tr><td>" + rs.getString("grade_category") + "</td><td>" + rs.getInt("count") + "</td></tr>");
                }
                out.println("</table>");
            } catch (SQLException e) {
                e.printStackTrace();
                out.println("<p>Error executing the query: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch(SQLException e) {}
                if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
                if (conn != null) try { conn.close(); } catch(SQLException e) {}
            }
        }
    }
%>

<h2>Grade Distribution for a Course Over the Years</h2>
<form method="post">
    <label for="courseIdYears">Course ID:</label>
    <input type="number" id="courseIdYears" name="courseIdYears" required><br>

    <input type="submit" value="Generate Report">
</form>

<%
    String courseIdYearsParam = request.getParameter("courseIdYears");
    if (courseIdYearsParam != null && !courseIdYearsParam.isEmpty()) {
        int courseIdYears = Integer.parseInt(courseIdYearsParam);  // Parse the input as integer

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConnection.getConnection();
            String queryYears = "SELECT " +
                    "CASE " +
                    "WHEN gc.letter_grade IN ('A+', 'A', 'A-') THEN 'A' " +
                    "WHEN gc.letter_grade IN ('B+', 'B', 'B-') THEN 'B' " +
                    "WHEN gc.letter_grade IN ('C+', 'C', 'C-') THEN 'C' " +
                    "WHEN gc.letter_grade IN ('D+', 'D', 'D-') THEN 'D' " +
                    "ELSE 'Other' " +
                    "END AS grade_category, " +
                    "COUNT(*) AS count " +
                    "FROM enrollment e " +
                    "JOIN class cl ON e.class_id = cl.class_id " +
                    "JOIN grade_conversion gc ON e.grade::text = gc.letter_grade " +
                    "WHERE cl.course_id = ? " +
                    "AND e.grade_type = 'Letter Grade' " +
                    "AND e.grade NOT IN ('N/A') " +
                    "GROUP BY grade_category";
            pstmt = conn.prepareStatement(queryYears);
            pstmt.setInt(1, courseIdYears);
            rs = pstmt.executeQuery();
            out.println("<h3>Course Grade Distribution Over the Years</h3>");
            out.println("<table border='1'><tr><th>Grade Category</th><th>Count</th></tr>");
            while (rs.next()) {
                out.println("<tr><td>" + rs.getString("grade_category") + "</td><td>" + rs.getInt("count") + "</td></tr>");
            }
            out.println("</table>");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error executing the query: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
            if (conn != null) try { conn.close(); } catch(SQLException e) {}
        }
    }
%>
<h2>Average Grade Given by a Professor Over the Years</h2>
<form method="post">
    <label for="courseIdAvg">Course ID:</label>
    <input type="number" id="courseIdAvg" name="courseIdAvg" required><br>

    <label for="professorNameAvg">Professor Name:</label>
    <input type="text" id="professorNameAvg" name="professorNameAvg" required><br>

    <input type="submit" value="Generate Report">
</form>

<%
    String courseIdAvgParam = request.getParameter("courseIdAvg");
    String professorNameAvgParam = request.getParameter("professorNameAvg");
    if (courseIdAvgParam != null && !courseIdAvgParam.isEmpty() && professorNameAvgParam != null) {
        int courseIdAvg = Integer.parseInt(courseIdAvgParam);  // Parse the input as integer

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = DatabaseConnection.getConnection();
            String queryAvg = "SELECT AVG(gc.number_grade) AS average_grade " +
                    "FROM enrollment e " +
                    "JOIN section sec ON e.section_id = sec.section_id AND e.class_id = sec.class_id " +
                    "JOIN class cl ON sec.class_id = cl.class_id " +
                    "JOIN faculty fac ON sec.faculty_name = fac.faculty_name " +
                    "JOIN grade_conversion gc ON e.grade::text = gc.letter_grade " +
                    "WHERE cl.course_id = ? " +
                    "AND fac.faculty_name = ? " +
                    "AND e.grade_type = 'Letter Grade' " +
                    "AND e.grade NOT IN ('N/A') " +
                    "GROUP BY fac.faculty_name";
            pstmt = conn.prepareStatement(queryAvg);
            pstmt.setInt(1, courseIdAvg);
            pstmt.setString(2, professorNameAvgParam);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                double averageGrade = rs.getDouble("average_grade");
                out.println("<h3>Average Grade: " + averageGrade + "</h3>");
            } else {
                out.println("<p>No grade data found for the specified criteria.</p>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p>Error executing the query: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch(SQLException e) {}
            if (pstmt != null) try { pstmt.close(); } catch(SQLException e) {}
            if (conn != null) try { conn.close(); } catch(SQLException e) {}
        }
    }
%>

</body>
</html>
