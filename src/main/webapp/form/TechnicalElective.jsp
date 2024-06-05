<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Technical Electives Management</title>
    <script>
        function submitDeleteForm(degreeId, courseId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let degreeIdInput = document.createElement('input');
            degreeIdInput.type = 'hidden';
            degreeIdInput.name = 'degree_id';
            degreeIdInput.value = degreeId;
            form.appendChild(degreeIdInput);

            let courseIdInput = document.createElement('input');
            courseIdInput.type = 'hidden';
            courseIdInput.name = 'course_id';
            courseIdInput.value = courseId;
            form.appendChild(courseIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Technical Electives List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Degree ID</th>
        <th>Course ID</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="degree_id" required></td>
            <td><input type="number" name="course_id" required></td>
            <td><input type="submit" value="Create"></td>
            <input type="hidden" name="action" value="insert">
        </form>
    </tr>
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO technical_electives (degree_id, course_id) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM technical_electives WHERE degree_id = ? AND course_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT degree_id, course_id FROM technical_electives ORDER BY degree_id, course_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int degreeId = rs.getInt("degree_id");
                int courseId = rs.getInt("course_id");
    %>
    <tr>
        <form method="post">
            <td><%= degreeId %></td>
            <td><%= courseId %></td>
            <td>
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= degreeId %>, <%= courseId %>);">
                <input type="hidden" name="action" value="delete">
        </form>
        </td>
    </tr>
    <%
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    %>
    </tbody>
</table>
</body>
</html>
