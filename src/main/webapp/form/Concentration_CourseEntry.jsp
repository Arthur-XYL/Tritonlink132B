<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Concentration_Course Management</title>
    <script>
        function submitDeleteForm(concentrationId, courseId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let concentrationIdInput = document.createElement('input');
            concentrationIdInput.type = 'hidden';
            concentrationIdInput.name = 'concentration_id';
            concentrationIdInput.value = concentrationId;
            form.appendChild(concentrationIdInput);

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
<h1>Concentration_Course List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Concentration ID</th>
        <th>Course ID</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="concentration_id" required></td>
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
            //conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "123456");
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO concentration_course (concentration_id, course_id) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE concentration_course SET concentration_id = ?, course_id = ? WHERE concentration_id = ? AND course_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("course_id")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM concentration_course WHERE concentration_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT concentration_id, course_id FROM concentration_course ORDER BY concentration_id, course_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int concentrationId = rs.getInt("concentration_id");
                int courseId = rs.getInt("course_id");
    %>
    <tr>
        <form method="post">

            <td><input type="number" name="concentrationId" value="<%= concentrationId %>" required></td>
            <td><input type="number" name="courseId" value="<%= courseId %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= concentrationId %>, <%= courseId %>);">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="concentration_id" value="<%= concentrationId %>">
                <input type="hidden" name="course_id" value="<%= courseId %>">
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
