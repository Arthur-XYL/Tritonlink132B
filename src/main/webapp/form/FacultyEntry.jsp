<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Faculty Management</title>
    <script>
        function submitDeleteForm(facultyName) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let facultyNameInput = document.createElement('input');
            facultyNameInput.type = 'hidden';
            facultyNameInput.name = 'faculty_name';
            facultyNameInput.value = facultyName;
            form.appendChild(facultyNameInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Faculty List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Faculty Name</th>
        <th>Title</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="text" name="faculty_name" required></td>
            <td><input type="text" name="title" required></td>
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
                String insertSQL = "INSERT INTO faculty (faculty_name, title) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("faculty_name"));
                pstmt.setString(2, request.getParameter("title"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE faculty SET title = ? WHERE faculty_name = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("title"));
                pstmt.setString(2, request.getParameter("faculty_name"));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM faculty WHERE faculty_name = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setString(1, request.getParameter("faculty_name"));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT faculty_name, title FROM faculty ORDER BY faculty_name";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String facultyName = rs.getString("faculty_name");
                String title = rs.getString("title");
    %>
    <tr>
        <form method="post">
            <td><input type="text" name="faculty_name" value="<%= facultyName %>" required></td>
            <td><input type="text" name="title" value="<%= title %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm('<%= facultyName %>');">

                <input type="hidden" name="action" value="update">
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
