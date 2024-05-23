<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Concentration Management</title>
    <script>
        function submitDeleteForm(concentrationId) {
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

            form.submit();
        }
    </script>
</head>
<body>
<h1>Concentration List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Concentration ID</th>
        <th>Name</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
            <td><input type="text" name="name" required></td>
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
                String insertSQL = "INSERT INTO concentration (name) VALUES (?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("name"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                //out.println("concentration_id is " , request.getParameter("concentration_id"));
                String updateSQL = "UPDATE concentration SET name = ? WHERE concentration_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("name"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM concentration WHERE concentration_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT concentration_id, name FROM concentration ORDER BY name";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int concentrationId = rs.getInt("concentration_id");
                String name = rs.getString("name");
    %>
    <tr>
        <form method="post">
            <td><%= concentrationId %></td>
            <td><input type="text" name="name" value="<%= name %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= concentrationId %>);">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="concentration_id" value="<%= concentrationId %>">
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
