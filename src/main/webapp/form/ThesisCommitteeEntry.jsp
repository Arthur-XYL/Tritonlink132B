<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Thesis Committee Management</title>
    <script>
        function submitDeleteForm(thesisCommitteeId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let thesisCommitteeIdInput = document.createElement('input');
            thesisCommitteeIdInput.type = 'hidden';
            thesisCommitteeIdInput.name = 'thesis_committee_id';
            thesisCommitteeIdInput.value = thesisCommitteeId;
            form.appendChild(thesisCommitteeIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Thesis Committee List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Thesis Committee ID</th>
        <th>Title</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
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
                String insertSQL = "INSERT INTO thesis_committee (title) VALUES (?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("title"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE thesis_committee SET title = ? WHERE thesis_committee_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("title"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("thesis_committee_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM thesis_committee WHERE thesis_committee_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("thesis_committee_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT thesis_committee_id, title FROM thesis_committee ORDER BY thesis_committee_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int thesisCommitteeId = rs.getInt("thesis_committee_id");
                String title = rs.getString("title");
    %>
    <tr>
        <form method="post">
            <td><%= thesisCommitteeId %></td>
            <td><input type="text" name="title" value="<%= title %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= thesisCommitteeId %>);">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="thesis_committee_id" value="<%= thesisCommitteeId %>">
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
