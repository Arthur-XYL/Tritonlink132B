<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>PhD Management</title>
    <script>
        function submitDeleteForm(studentId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let studentIdInput = document.createElement('input');
            studentIdInput.type = 'hidden';
            studentIdInput.name = 'student_id';
            studentIdInput.value = studentId;
            form.appendChild(studentIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>PhD Student List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student ID</th>
        <th>Department Name</th>
        <th>Advisor</th>
        <th>Thesis Committee ID</th>
        <th>Type</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="student_id" required></td>
            <td><input type="text" name="department_name" required></td>
            <td><input type="text" name="advisor" required></td>
            <td><input type="number" name="thesis_committee_id"></td>
            <td>
                <select name="type" required>
                    <option value="Pre-candidate">Pre-candidate</option>
                    <option value="Candidate">Candidate</option>
                </select>
            </td>
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
                String insertSQL = "INSERT INTO phd (student_id, department_name, advisor, thesis_committee_id, type) VALUES (?, ?, ?, ?, CAST(? AS phd_type))";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setString(2, request.getParameter("department_name"));
                pstmt.setString(3, request.getParameter("advisor"));
                String committeeId = request.getParameter("thesis_committee_id");
                if (committeeId != null && !committeeId.isEmpty()) {
                    pstmt.setInt(4, Integer.parseInt(committeeId));
                } else {
                    pstmt.setNull(4, Types.INTEGER);
                }
                pstmt.setString(5, request.getParameter("type"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE phd SET department_name = ?, advisor = ?, thesis_committee_id = ?, type = CAST(? AS phd_type) WHERE student_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("department_name"));
                pstmt.setString(2, request.getParameter("advisor"));
                String committeeId = request.getParameter("thesis_committee_id");
                if (committeeId != null && !committeeId.isEmpty()) {
                    pstmt.setInt(3, Integer.parseInt(committeeId));
                } else {
                    pstmt.setNull(3, Types.INTEGER);
                }
                pstmt.setString(4, request.getParameter("type"));
                pstmt.setInt(5, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM phd WHERE student_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT student_id, department_name, advisor, thesis_committee_id, type FROM phd ORDER BY student_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                String departmentName = rs.getString("department_name");
                String advisor = rs.getString("advisor");
                int thesisCommitteeId = rs.getInt("thesis_committee_id");
                String type = rs.getString("type");
    %>
    <tr>
        <form method="post">
            <td><input type="number" name="student_id" value="<%= studentId %>" required></td>
            <td><input type="text" name="department_name" value="<%= departmentName %>" required></td>
            <td><input type="text" name="advisor" value="<%= advisor %>" required></td>
            <td><input type="number" name="thesis_committee_id" value="<%= thesisCommitteeId %>"></td>
            <td>
                <select name="type" required>
                    <option value="Pre-candidate" <%= "Pre-candidate".equals(type) ? "selected" : "" %>>Pre-candidate</option>
                    <option value="Candidate" <%= "Candidate".equals(type) ? "selected" : "" %>>Candidate</option>
                </select>
            </td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= studentId %>);">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="student_id" value="<%= studentId %>">
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
