<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Undergraduate Management</title>
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
<h1>Undergraduate Student List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student ID</th>
        <th>College</th>
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

                            String selectSQL = "SELECT student_id, first_name, last_name FROM student";
                            pstmt = conn.prepareStatement(selectSQL);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                                int studentId = rs.getInt("student_id");
                                String firstName = rs.getString("first_name");
                                String lastName = rs.getString("last_name");
                    %>
                    <option value="<%= studentId %>"><%= studentId %> - <%= firstName %> <%= lastName %></option>
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
                <select name="college" required>
                    <option value="">Select a College</option>
                    <%
                        for (String college : new String[]{"Revelle College", "John Muir College", "Thurgood Marshall College", "Earl Warren College", "Eleanor Roosevelt College", "Sixth College", "Seventh College", "Eighth College"}) {
                    %>
                    <option value="<%= college %>"><%= college %></option>
                    <%
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
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            String action = request.getParameter("action");

            if ("insert".equals(action)) {
                String insertSQL = "INSERT INTO undergraduate (student_id, college) VALUES (?, CAST(? AS college_type))";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setString(2, request.getParameter("college"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE undergraduate SET college = CAST(? AS college_type) WHERE student_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("college"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM undergraduate WHERE student_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT u.student_id, u.college, s.first_name, s.last_name FROM undergraduate u JOIN student s ON u.student_id = s.student_id ORDER BY u.student_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                String college = rs.getString("college");
                String firstName = rs.getString("first_name");
                String lastName = rs.getString("last_name");
    %>
    <tr>
        <form method="post">
            <td><%= studentId %> - <%= firstName %> <%= lastName %></td>
            <td>
                <select name="college" required>
                    <%
                        for (String col : new String[]{"Revelle College", "John Muir College", "Thurgood Marshall College", "Earl Warren College", "Eleanor Roosevelt College", "Sixth College", "Seventh College", "Eighth College"}) {
                    %>
                    <option value="<%= col %>" <%= col.equals(college) ? "selected" : "" %>><%= col %></option>
                    <%
                        }
                    %>
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
