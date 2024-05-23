<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Degree_Concentration Management</title>
    <script>
        function submitDeleteForm(concentrationId, degreeId) {
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

            let degreeIdInput = document.createElement('input');
            degreeIdInput.type = 'hidden';
            degreeIdInput.name = 'degree_id';
            degreeIdInput.value = degreeId;
            form.appendChild(degreeIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Degree_Concentration List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Concentration ID</th>
        <th>Degree ID</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="concentration_id" required></td>
            <td><input type="number" name="degree_id" required></td>
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
                String insertSQL = "INSERT INTO degree_concentration (concentration_id, degree_id) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE degree_concentration SET concentration_id = ?, degree_id = ? WHERE concentration_id = ? AND degree_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM degree_concentration WHERE concentration_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("concentration_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT concentration_id, degree_id FROM degree_concentration ORDER BY concentration_id, degree_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int concentrationId = rs.getInt("concentration_id");
                int degreeId = rs.getInt("degree_id");
    %>
    <tr>
        <form method="post">

            <td><input type="number" name="concentrationId" value="<%= concentrationId %>" required></td>
            <td><input type="number" name="degreeId" value="<%= degreeId %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= concentrationId %>, <%= degreeId %>);">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="concentration_id" value="<%= concentrationId %>">
                <input type="hidden" name="degree_id" value="<%= degreeId %>">
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
