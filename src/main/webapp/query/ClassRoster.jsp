<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Class Roster</title>
    <script>
        function submitForm() {
            document.getElementById('classForm').submit();
        }
    </script>
</head>
<body>
<h1>Select Class</h1>
<form method="post" id="classForm">
    <label for="class_title">Title:</label>
    <input type="text" name="class_title" id="class_title" required>

    <label for="class_quarter">Quarter:</label>
    <select name="class_quarter" id="class_quarter" required>
        <option value="">Select a quarter</option>
        <option value="FALL">Fall</option>
        <option value="WINTER">Winter</option>
        <option value="SPRING">Spring</option>
        <option value="SUMMER SESSION 1">Summer Session 1</option>
        <option value="SUMMER SESSION 2">Summer Session 2</option>
        <option value="SUMMER SESSION SPECIAL">Summer Session Special</option>
    </select>

    <label for="class_year">Year:</label>
    <input type="number" name="class_year" id="class_year" required>

    <input type="submit" value="View Roster" onclick="submitForm()">
</form>

<%
    String classTitle = request.getParameter("class_title");
    String classQuarter = request.getParameter("class_quarter");
    String classYearParam = request.getParameter("class_year");

    if (classTitle != null && classQuarter != null && classYearParam != null && !classTitle.isEmpty() && !classQuarter.isEmpty() && !classYearParam.isEmpty()) {
        int classYear = Integer.parseInt(classYearParam);

%>
<h2>Class Roster for <%= classTitle %> (<%= classQuarter %> <%= classYear %>)</h2>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    try {
        conn = DatabaseConnection.getConnection();

        String query = "SELECT s.student_id, s.first_name, s.middle_name, s.last_name, s.residency_status, s.is_enrolled, s.degree_id, e.unit, e.grade_type " +
                "FROM student s " +
                "JOIN enrollment e ON s.student_id = e.student_id " +
                "JOIN section sec ON e.section_id = sec.section_id AND e.class_id = sec.class_id " +
                "JOIN class c ON sec.class_id = c.class_id " +
                "WHERE c.title = ? AND c.quarter = CAST(? AS quarter_type) AND c.year = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, classTitle.trim());
        pstmt.setString(2, classQuarter);
        pstmt.setInt(3, classYear);

        rs = pstmt.executeQuery();

        if (!rs.isBeforeFirst()) {
            out.println("No students found for the selected class.");
        } else {
%>
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