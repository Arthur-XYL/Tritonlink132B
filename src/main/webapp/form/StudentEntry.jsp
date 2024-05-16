<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Management</title>
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
<h1>Student List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student Id</th>
        <th>First Name</th>
        <th>Middle Name</th>
        <th>Last Name</th>
        <th>Residency Status</th>
        <th>Is Enrolled</th>
        <th>Degree Id</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
            <td><input type="text" name="first_name" required></td>
            <td><input type="text" name="middle_name"></td>
            <td><input type="text" name="last_name" required></td>
            <td>
                <select name="residency_status" required>
                    <option value="California Resident">California Resident</option>
                    <option value="Foreign Student">Foreign Student</option>
                    <option value="Non-CA US Student">Non-CA US Student</option>
                </select>
            </td>
            <td><input type="checkbox" name="is_enrolled"></td>
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
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO student (first_name, middle_name, last_name, residency_status, is_enrolled, degree_id) VALUES (?, ?, ?, CAST(? AS residency_status_type), ?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("first_name"));
                pstmt.setString(2, request.getParameter("middle_name"));
                pstmt.setString(3, request.getParameter("last_name"));
                pstmt.setString(4, request.getParameter("residency_status"));
                pstmt.setBoolean(5, "on".equals(request.getParameter("is_enrolled")));
                pstmt.setInt(6, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE student SET first_name = ?, middle_name = ?, last_name = ?, residency_status = CAST(? AS residency_status_type), is_enrolled = ?, degree_id = ? WHERE student_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("first_name"));
                pstmt.setString(2, request.getParameter("middle_name"));
                pstmt.setString(3, request.getParameter("last_name"));
                pstmt.setString(4, request.getParameter("residency_status"));
                pstmt.setBoolean(5, "on".equals(request.getParameter("is_enrolled")));
                pstmt.setInt(6, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.setInt(7, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM student WHERE student_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT student_id, first_name, middle_name, last_name, residency_status, is_enrolled, degree_id FROM student ORDER BY student_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                String firstName = rs.getString("first_name");
                String middleName = rs.getString("middle_name");
                String lastName = rs.getString("last_name");
                String residencyStatus = rs.getString("residency_status");
                boolean isEnrolled = rs.getBoolean("is_enrolled");
                int degreeId = rs.getInt("degree_id");
    %>
    <tr>
        <form method="post">
            <td><%= studentId %></td>
            <td><input type="text" name="first_name" value="<%= firstName %>" required></td>
            <td><input type="text" name="middle_name" value="<%= middleName %>"></td>
            <td><input type="text" name="last_name" value="<%= lastName %>" required></td>
            <td>
                <select name="residency_status" required>
                    <option value="California Resident" <%= "California Resident".equals(residencyStatus) ? "selected" : "" %>>California Resident</option>
                    <option value="Foreign Student" <%= "Foreign Student".equals(residencyStatus) ? "selected" : "" %>>Foreign Student</option>
                    <option value="Non-CA US Student" <%= "Non-CA US Student".equals(residencyStatus) ? "selected" : "" %>>Non-CA US Student</option>
                </select>
            </td>
            <td><input type="checkbox" name="is_enrolled" <%= isEnrolled ? "checked" : "" %>></td>
            <td><input type="number" name="degree_id" value="<%= degreeId %>" required></td>
            <td>
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="student_id" value="<%= studentId %>">
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= studentId %>);">
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
