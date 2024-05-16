<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Classes Taken by Student</title>
    <script>
        function submitForm() {
            document.getElementById('studentForm').submit();
        }
    </script>
</head>
<body>
<h1>Select Student</h1>
<form method="post" id="studentForm">
    <label for="student_id">Student:</label>
    <select name="student_id" id="student_id" required onchange="submitForm()">
        <option value="">Select a student</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                Class.forName("org.postgresql.Driver");
                conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/tritonlink132b", "arthur", "");
                String selectSQL = "SELECT DISTINCT s.student_id, s.first_name, s.middle_name, s.last_name " +
                        "FROM student s " +
                        "JOIN enrollment e ON s.student_id = e.student_id " +
                        "JOIN class c ON e.class_id = c.class_id " +
                        "WHERE s.is_enrolled = true AND c.year = 2018 AND c.quarter = 'Spring'";
                pstmt = conn.prepareStatement(selectSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    int studentId = rs.getInt("student_id");
                    String firstName = rs.getString("first_name");
                    String middleName = rs.getString("middle_name");
                    String lastName = rs.getString("last_name");
        %>
        <option value="<%= studentId %>"><%= studentId %> - <%= firstName %> <%= middleName %> <%= lastName %></option>
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
    String studentIdParam = request.getParameter("student_id");
    if (studentIdParam != null && !studentIdParam.isEmpty()) {
        int studentId = Integer.parseInt(studentIdParam);
%>
<h2>Classes Taken by Student <%= studentId %></h2>
<%
    conn = null;
    pstmt = null;
    rs = null;
    try {
        Class.forName("org.postgresql.Driver");
        conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/tritonlink132b", "arthur", "");

        String query = "SELECT c.class_id, c.course_id, c.year, c.quarter, c.title, e.unit, e.section_id " +
                "FROM class c " +
                "JOIN enrollment e ON c.class_id = e.class_id " +
                "WHERE e.student_id = ? AND c.year = 2018 AND c.quarter = 'Spring'";
        pstmt = conn.prepareStatement(query);
        pstmt.setInt(1, studentId);
        rs = pstmt.executeQuery();

        if (!rs.isBeforeFirst()) {
            out.println("No classes found for the selected student in the current quarter.");
        } else {
%>
<table border="1">
    <thead>
    <tr>
        <th>Class ID</th>
        <th>Course ID</th>
        <th>Year</th>
        <th>Quarter</th>
        <th>Title</th>
        <th>Units</th>
        <th>Section ID</th>
    </tr>
    </thead>
    <tbody>
    <%
        while (rs.next()) {
            int classId = rs.getInt("class_id");
            int courseId = rs.getInt("course_id");
            int year = rs.getInt("year");
            String quarter = rs.getString("quarter");
            String title = rs.getString("title");
            int units = rs.getInt("unit");
            int sectionId = rs.getInt("section_id");
    %>
    <tr>
        <td><%= classId %></td>
        <td><%= courseId %></td>
        <td><%= year %></td>
        <td><%= quarter %></td>
        <td><%= title %></td>
        <td><%= units %></td>
        <td><%= sectionId %></td>
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
