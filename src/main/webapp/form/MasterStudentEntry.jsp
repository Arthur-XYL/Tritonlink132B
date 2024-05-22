<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Master Entry Management</title>
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
<h1>Master Students List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student ID</th>
        <th>Department Name</th>
        <th>Type</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>
                <select name="student_id" required>
                    <option value="">Select a Student</option>
                    <%
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        try {
                            Class.forName("org.postgresql.Driver");
                            conn = DatabaseConnection.getConnection();

                            String studentSelectSQL = "SELECT student_id, first_name, middle_name, last_name FROM student";
                            pstmt = conn.prepareStatement(studentSelectSQL);
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
                            rs.close();
                            pstmt.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (conn != null) try { conn.close(); } catch(Exception e) {}
                        }
                    %>
                </select>
            </td>
            <td>
                <select name="department_name" required>
                    <option value="">Select a Department</option>
                    <%
                        try {
                            conn = DatabaseConnection.getConnection();

                            String departmentSelectSQL = "SELECT department_name FROM department";
                            pstmt = conn.prepareStatement(departmentSelectSQL);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                String departmentName = rs.getString("department_name");
                    %>
                    <option value="<%= departmentName %>"><%= departmentName %></option>
                    <%
                            }
                            rs.close();
                            pstmt.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (conn != null) try { conn.close(); } catch(Exception e) {}
                        }
                    %>
                </select>
            </td>
            <td>
                <select name="type" required>
                    <option value="BS/MS">BS/MS</option>
                    <option value="MS">MS</option>
                </select>
            </td>
            <td><input type="submit" value="Add"></td>
            <input type="hidden" name="action" value="insert">
        </form>
    </tr>
    <%
        try {
            Class.forName("org.postgresql.Driver");
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO master (student_id, department_name, type) VALUES (?, ?, CAST(? AS master_type))";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setString(2, request.getParameter("department_name"));
                pstmt.setString(3, request.getParameter("type"));
                pstmt.executeUpdate();
                pstmt.close();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE master SET department_name = ?, type = CAST(? AS master_type) WHERE student_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("department_name"));
                pstmt.setString(2, request.getParameter("type"));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
                pstmt.close();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM master WHERE student_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
                pstmt.close();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT student_id, department_name, type FROM master ORDER BY student_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                String departmentName = rs.getString("department_name");
                String type = rs.getString("type");
    %>
    <tr>
        <form method="post">
            <td><%= studentId %></td>
            <td>
                <select name="department_name" required>
                    <%
                        Connection connDept = null;
                        PreparedStatement pstmtDept = null;
                        ResultSet rsDept = null;
                        try {
                            connDept = DatabaseConnection.getConnection();

                            String departmentSelectSQL = "SELECT department_name FROM department";
                            pstmtDept = connDept.prepareStatement(departmentSelectSQL);
                            rsDept = pstmtDept.executeQuery();
                            while (rsDept.next()) {
                                String deptName = rsDept.getString("department_name");
                    %>
                    <option value="<%= deptName %>" <%= deptName.equals(departmentName) ? "selected" : "" %>><%= deptName %></option>
                    <%
                            }
                            rsDept.close();
                            pstmtDept.close();
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            if (connDept != null) try { connDept.close(); } catch(Exception e) {}
                        }
                    %>
                </select>
            </td>
            <td>
                <select name="type" required>
                    <option value="BS/MS" <%= "BS/MS".equals(type) ? "selected" : "" %>>BS/MS</option>
                    <option value="MS" <%= "MS".equals(type) ? "selected" : "" %>>MS</option>
                </select>
            </td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= studentId %>);">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="student_id" value="<%= studentId %>">
            </td>
        </form>
    </tr>
    <%
            }
            rs.close();
            pstmt.close();
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        } finally {
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    %>
    </tbody>
</table>
</body>
</html>
