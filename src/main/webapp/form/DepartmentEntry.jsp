<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Department Management</title>
    <script>
        function enableEdit(td) {
            if (td.querySelector('input[type="text"]')) {
                return;
            }

            let currentText = td.innerText;
            td.innerHTML = '<input type="text" value="' + currentText + '">';
            var input = td.querySelector('input[type="text"]');
            input.focus();
            input.select();

            // Get the update button and enable it
            let form = td.nextElementSibling.querySelector('form');
            let updateButton = form.querySelector('input[type="submit"]');
            updateButton.disabled = false; // Enable the Update button

            // Attach event to handle Enter key for submitting the form
            input.addEventListener('keypress', function (event) {
                if (event.key === 'Enter') {
                    event.preventDefault();
                    form.submit();
                }
            });

            // Set form field values when input changes
            input.addEventListener('blur', function () {
                form.elements['department_name'].value = input.value;
            });
        }

        function submitDeleteForm(departmentName) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';
            form.innerHTML = '<input type="hidden" name="action" value="delete">' +
                '<input type="hidden" name="department_name" value="' + departmentName + '">';
            form.submit();
        }
    </script>
</head>
<body>
<h1>Department List</h1>
<form method="post">
    <fieldset>
        <input type="hidden" name="action" value="insert">
        Department Name: <input type="text" name="department_name" required><br>
        <input type="submit" value="Create">
    </fieldset>
</form>
<br>
<table border="1">
    <thead>
    <tr>
        <th>Department Name</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <%
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Begin transaction

            String action = request.getParameter("action");
            String departmentName = request.getParameter("department_name");

            // Insert a new department
            if ("insert".equals(action) && departmentName != null && !departmentName.isEmpty()) {
                pstmt = conn.prepareStatement("INSERT INTO department (department_name) VALUES (?)");
                pstmt.setString(1, departmentName);
                pstmt.executeUpdate();
                pstmt.close();
            }

            // Update department
            if ("update".equals(action)) {
                String oldDepartmentName = request.getParameter("old_department_name");
                if (departmentName != null && oldDepartmentName != null) {
                    pstmt = conn.prepareStatement("UPDATE department SET department_name = ? WHERE department_name = ?");
                    pstmt.setString(1, departmentName);
                    pstmt.setString(2, oldDepartmentName);
                    pstmt.executeUpdate();
                    pstmt.close();
                }
            }

            // Delete department
            if ("delete".equals(action) && departmentName != null) {
                pstmt = conn.prepareStatement("DELETE FROM department WHERE department_name = ?");
                pstmt.setString(1, departmentName);
                pstmt.executeUpdate();
                pstmt.close();
            }

            conn.commit(); // Commit transaction
            conn.setAutoCommit(true);

            // Display current list of departments
            pstmt = conn.prepareStatement("SELECT department_name FROM department ORDER BY department_name");
            rs = pstmt.executeQuery();
            while(rs.next()) {
                departmentName = rs.getString("department_name");
    %>
    <tr>
        <td onclick="enableEdit(this)" style="cursor: pointer;">
            <%= departmentName %>
        </td>
        <td>
            <form method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="old_department_name" value="<%= departmentName %>">
                <input type="hidden" name="department_name">
                <input type="submit" value="Update" disabled>
                <input type="button" value="Delete" onclick="submitDeleteForm('<%= departmentName %>');">
            </form>
        </td>
    </tr>
    <%
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
            if (conn != null) try { conn.rollback(); } catch (SQLException ignored) {} // Rollback transaction on error
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
