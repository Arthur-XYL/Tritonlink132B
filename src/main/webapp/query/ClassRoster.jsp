<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Class Roster</title>
</head>
<body>
<h1>Class Roster</h1>

<!-- Form to input class title, quarter, and year -->
<form method="post" id="classForm">
    <label for="title">Class Title:</label>
    <input type="text" name="title" id="title" required>
    <br>
    <label for="quarter">Quarter:</label>
    <input type="text" name="quarter" id="quarter" required>
    <br>
    <label for="year">Year:</label>
    <input type="number" name="year" id="year" required>
    <br>
    <input type="submit" value="Submit">
</form>

<%
    String titleParam = request.getParameter("title");
    String quarterParam = request.getParameter("quarter");
    String yearParam = request.getParameter("year");

    if (titleParam != null && !titleParam.isEmpty() && quarterParam != null && !quarterParam.isEmpty() && yearParam != null && !yearParam.isEmpty()) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/tritonlink132b", "arthur", "");

            String query = "SELECT s.student_id, s.first_name, s.middle_name, s.last_name, s.residency_status, s.is_enrolled, s.degree_id, " +
                    "e.unit, e.grade_type " +
                    "FROM student s " +
                    "JOIN enrollment e ON s.student_id = e.student_id " +
                    "JOIN class c ON e.class_id = c.class_id " +
                    "WHERE c.title = ? AND c.quarter = ? AND c.year = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, titleParam);
            pstmt.setString(2, quarterParam);
            pstmt.setInt(3, Integer.parseInt(yearParam));
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                out.println("No students found for the specified class.");
            } else {
%>
<h2>Students Enrolled in <%= titleParam %> - <%= quarterParam %> <%= yearParam %></h2>
<table border="1">
    <thead>
    <tr>
        <th>Student ID</th>
        <th>First Name</th>
        <th>Middle Name</th>
        <th>Last Name</th>
        <th>Residency Status</th>
        <th>Is Enrolled</th>
        <th>Degree ID</th>
        <th>Units</th>
        <th>Grade Option</th>
    </tr>
    </thead>
    <tbody>
    <%
        while (rs.next()) {
            int studentId = rs.getInt("student_id");
            String firstName = rs.getString("first_name");
            String middleName = rs.getString("middle_name");
            String lastName = rs.getString("last_name");
            String residencyStatus = rs.getString("residency_status");
            boolean isEnrolled = rs.getBoolean("is_enrolled");
            int degreeId = rs.getInt("degree_id");
            int units = rs.getInt("unit");
            String gradeType = rs.getString("grade_type");
    %>
    <tr>
        <td><%= studentId %></td>
        <td><%= firstName %></td>
        <td><%= middleName %></td>
        <td><%= lastName %></td>
        <td><%= residencyStatus %></td>
        <td><%= isEnrolled %></td>
        <td><%= degreeId %></td>
        <td><%= units %></td>
        <td><%= gradeType %></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>
<%
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
%>
</body>
</html>
