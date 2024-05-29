<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Class Schedule Conflict Checker</title>
    <script>
        function submitForm() {
            document.getElementById('studentForm').submit();
        }
    </script>
</head>
<body>
<h1>Check Class Schedule Conflicts</h1>
<form method="post" id="studentForm">
    <label for="ssn">Select Student:</label>
    <select name="ssn" id="ssn" required onchange="submitForm()">
        <option value="">Select a student</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String selectSQL = "SELECT DISTINCT s.ssn, s.first_name, s.middle_name, s.last_name " +
                        "FROM student s WHERE s.is_enrolled = true";
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
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (rs != null) try { rs.close(); } catch(Exception e) {}
                if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
                if (conn != null) try { conn.close(); } catch(Exception e) {}
            }
        %>
    </select>
</form>

<%
    String ssnParam = request.getParameter("ssn");
    if (ssnParam != null && !ssnParam.isEmpty()) {
        try {
            conn = DatabaseConnection.getConnection();
            String query = "SELECT DISTINCT c.title AS conflict_title, cc.course_number AS conflict_course " +
                    "FROM enrollment e1 " +
                    "JOIN class c1 ON e1.class_id = c1.class_id " +
                    "JOIN course cc1 ON c1.course_id = cc1.course_id " +
                    "JOIN meeting m1 ON c1.class_id = m1.class_id " +
                    "JOIN section sec1 ON m1.section_id = sec1.section_id, " +
                    "enrollment e " +
                    "JOIN class c ON e.class_id = c.class_id " +
                    "JOIN course cc ON c.course_id = cc.course_id " +
                    "JOIN meeting m ON c.class_id = m.class_id " +
                    "JOIN section sec ON m.section_id = sec.section_id " +
                    "WHERE e1.student_id = (SELECT student_id FROM student WHERE ssn = ?) " +
                    "AND c1.year = 2018 AND c1.quarter = 'SPRING' " +
                    "AND c.year = 2018 AND c.quarter = 'SPRING' " +
                    "AND m1.weekday = m.weekday " +
                    "AND NOT ((m.start_time >= m1.end_time) OR (m.end_time <= m1.start_time)) " +
                    "AND e1.class_id != e.class_id";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, ssnParam);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                out.println("<p>No conflicts found for the selected student with SSN: " + ssnParam + ".</p>");
            } else {
%>
<h2>Class Conflicts Found</h2>
<table border="1">
    <thead>
    <tr>
        <th>Conflicting Class Title</th>
        <th>Conflicting Class Course Number</th>
    </tr>
    </thead>
    <tbody>
    <%
        while (rs.next()) {
            String conflictTitle = rs.getString("conflict_title");
            String conflictCourse = rs.getString("conflict_course");
    %>
    <tr>
        <td><%= conflictTitle %></td>
        <td><%= conflictCourse %></td>
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
