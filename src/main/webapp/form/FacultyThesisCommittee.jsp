<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Faculty Thesis Committee Management</title>
    <script>
        function submitDeleteForm(facultyName, thesisCommitteeId) {
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
<h1>Faculty Thesis Committee Management</h1>
<table border="1">
    <thead>
    <tr>
        <th>Faculty Name</th>
        <th>Thesis Committee ID</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>
                <select name="faculty_name" required>
                    <option value="">Select a Faculty Member</option>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            Class.forName("org.postgresql.Driver");
                            conn = DatabaseConnection.getConnection();

                            String selectSQL = "SELECT faculty_name FROM faculty";
                            pstmt = conn.prepareStatement(selectSQL);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                String facultyName = rs.getString("faculty_name");
                    %>
                    <option value="<%= facultyName %>"><%= facultyName %></option>
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
            </td>
            <td>
                <select name="thesis_committee_id" required>
                    <option value="">Select a Thesis Committee</option>
                    <%
                        conn = null;
                        pstmt = null;
                        rs = null;
                        try {
                            Class.forName("org.postgresql.Driver");
                            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/tritonlink132b", "arthur", "");

                            String selectSQL = "SELECT thesis_committee_id, title FROM thesis_committee";
                            pstmt = conn.prepareStatement(selectSQL);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                int thesisCommitteeId = rs.getInt("thesis_committee_id");
                                String title = rs.getString("title");
                    %>
                    <option value="<%= thesisCommitteeId %>"><%= thesisCommitteeId %> - <%= title %></option>
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
            </td>
            <td><input type="submit" value="Add"></td>
            <input type="hidden" name="action" value="insert">
        </form>
    </tr>
    <%
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/tritonlink132b", "arthur", "");
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO faculty_thesis_committee (faculty_name, thesis_committee_id) VALUES (?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("faculty_name"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("thesis_committee_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM faculty_thesis_committee WHERE faculty_name = ? AND thesis_committee_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setString(1, request.getParameter("faculty_name"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("thesis_committee_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT faculty_name, thesis_committee_id FROM faculty_thesis_committee ORDER BY faculty_name, thesis_committee_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                String facultyName = rs.getString("faculty_name");
                int thesisCommitteeId = rs.getInt("thesis_committee_id");
    %>
    <tr>
        <form method="post">
            <td><%= facultyName %></td>
            <td><%= thesisCommitteeId %></td>
            <td>
                <input type="button" value="Delete" onclick="submitDeleteForm('<%= facultyName %>', <%= thesisCommitteeId %>);">
            </td>
        </form>
    </tr>
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
    </tbody>
</table>
</body>
</html>
