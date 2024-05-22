<%--<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>--%>
<%--<%@ page import="java.sql.*" %>--%>
<%--<%@ page import="org.example.DatabaseConnection" %>--%>
<%--<!DOCTYPE html>--%>
<%--<html>--%>
<%--<head>--%>
<%--    <title>Degree Management</title>--%>
<%--    <script>--%>
<%--        function submitDeleteForm(degreeId) {--%>
<%--            let form = document.createElement('form');--%>
<%--            document.body.appendChild(form);--%>
<%--            form.method = 'post';--%>
<%--            form.action = '';--%>

<%--            let actionInput = document.createElement('input');--%>
<%--            actionInput.type = 'hidden';--%>
<%--            actionInput.name = 'action';--%>
<%--            actionInput.value = 'delete';--%>
<%--            form.appendChild(actionInput);--%>

<%--            let degreeIdInput = document.createElement('input');--%>
<%--            degreeIdInput.type = 'hidden';--%>
<%--            degreeIdInput.name = 'degree_id';--%>
<%--            degreeIdInput.value = degreeId;--%>
<%--            form.appendChild(degreeIdInput);--%>

<%--            form.submit();--%>
<%--        }--%>
<%--    </script>--%>
<%--</head>--%>
<%--<body>--%>
<%--<h1>Degree List</h1>--%>
<%--<table border="1">--%>
<%--    <thead>--%>
<%--    <tr>--%>
<%--        <th>Degree Id</th>--%>
<%--        <th>Type</th>--%>
<%--        <th>Name</th>--%>
<%--        <th>Required Units</th>--%>
<%--        <th>Minimum Grade</th>--%>
<%--        <th>Department Name</th>--%>
<%--        <th>Actions</th>--%>
<%--    </tr>--%>
<%--    </thead>--%>
<%--    <tbody>--%>
<%--    <tr>--%>
<%--        <form method="post">--%>
<%--            <td>N/A</td>--%>
<%--            <td>--%>
<%--                <select name="type" required>--%>
<%--                    <option value="Bachelor">Bachelor</option>--%>
<%--                    <option value="Master">Master</option>--%>
<%--                    <option value="PhD">PhD</option>--%>
<%--                </select>--%>
<%--            </td>--%>
<%--            <td><input type="text" name="name" required></td>--%>
<%--            <td><input type="number" name="required_units" required></td>--%>
<%--            <td><input type="text" name="minimum_grade" required></td>--%>
<%--            <td><input type="text" name="department_name"></td>--%>
<%--            <td><input type="submit" value="Create"></td>--%>
<%--            <input type="hidden" name="action" value="insert">--%>
<%--        </form>--%>
<%--    </tr>--%>
<%--    <%--%>
<%--        Connection conn = null;--%>
<%--        PreparedStatement pstmt = null;--%>
<%--        ResultSet rs = null;--%>
<%--        try {--%>
<%--            Class.forName("org.postgresql.Driver");--%>
<%--            conn = DatabaseConnection.getConnection();--%>
<%--            conn.setAutoCommit(false);--%>

<%--            String action = request.getParameter("action");--%>

<%--            if ("insert".equals(action)) {--%>
<%--                String insertSQL = "INSERT INTO degree (type, name, required_units, minimum_grade, department_name) VALUES (CAST(? AS degree_type), ?, ?, ?, ?)";--%>
<%--                pstmt = conn.prepareStatement(insertSQL);--%>
<%--                pstmt.setString(1, request.getParameter("type"));--%>
<%--                pstmt.setString(2, request.getParameter("name"));--%>
<%--                pstmt.setInt(3, Integer.parseInt(request.getParameter("required_units")));--%>
<%--                pstmt.setString(4, request.getParameter("minimum_grade"));--%>
<%--                pstmt.setString(5, request.getParameter("department_name"));--%>
<%--                pstmt.executeUpdate();--%>
<%--            }--%>

<%--            if ("update".equals(action)) {--%>
<%--                String updateSQL = "UPDATE degree SET type = CAST(? AS degree_type), name = ?, required_units = ?, minimum_grade = ?, department_name = ? WHERE degree_id = ?";--%>
<%--                pstmt = conn.prepareStatement(updateSQL);--%>
<%--                pstmt.setString(1, request.getParameter("type"));--%>
<%--                pstmt.setString(2, request.getParameter("name"));--%>
<%--                pstmt.setInt(3, Integer.parseInt(request.getParameter("required_units")));--%>
<%--                pstmt.setString(4, request.getParameter("minimum_grade"));--%>
<%--                pstmt.setString(5, request.getParameter("department_name"));--%>
<%--                pstmt.setInt(6, Integer.parseInt(request.getParameter("degree_id")));--%>
<%--                pstmt.executeUpdate();--%>
<%--            }--%>

<%--            if ("delete".equals(action)) {--%>
<%--                String deleteSQL = "DELETE FROM degree WHERE degree_id = ?";--%>
<%--                pstmt = conn.prepareStatement(deleteSQL);--%>
<%--                pstmt.setInt(1, Integer.parseInt(request.getParameter("degree_id")));--%>
<%--                pstmt.executeUpdate();--%>
<%--            }--%>

<%--            conn.commit();--%>
<%--            conn.setAutoCommit(true);--%>

<%--            String selectSQL = "SELECT degree_id, type, name, required_units, minimum_grade, department_name FROM degree ORDER BY name";--%>
<%--            pstmt = conn.prepareStatement(selectSQL);--%>
<%--            rs = pstmt.executeQuery();--%>
<%--            while (rs.next()) {--%>
<%--                int degreeId = rs.getInt("degree_id");--%>
<%--                String type = rs.getString("type");--%>
<%--                String name = rs.getString("name");--%>
<%--                int requiredUnits = rs.getInt("required_units");--%>
<%--                String minimumGrade = rs.getString("minimum_grade");--%>
<%--                String departmentName = rs.getString("department_name");--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <form method="post">--%>
<%--            <td><%= degreeId %></td>--%>
<%--            <td>--%>
<%--                <select name="type" required>--%>
<%--                    <option value="Bachelor" <%= "Bachelor".equals(type) ? "selected" : "" %>>Bachelor</option>--%>
<%--                    <option value="Master" <%= "Master".equals(type) ? "selected" : "" %>>Master</option>--%>
<%--                    <option value="PhD" <%= "PhD".equals(type) ? "selected" : "" %>>PhD</option>--%>
<%--                </select>--%>
<%--            </td>--%>
<%--            <td><input type="text" name="name" value="<%= name %>" required></td>--%>
<%--            <td><input type="number" name="required_units" value="<%= requiredUnits %>" required></td>--%>
<%--            <td><input type="text" name="minimum_grade" value="<%= minimumGrade %>" required></td>--%>
<%--            <td><input type="text" name="department_name" value="<%= departmentName %>"></td>--%>
<%--            <td>--%>
<%--                <input type="submit" value="Update">--%>
<%--                <input type="button" value="Delete" onclick="submitDeleteForm(<%= degreeId %>);">--%>

<%--                <input type="hidden" name="action" value="update">--%>
<%--                <input type="hidden" name="degree_id" value="<%= degreeId %>">--%>
<%--        </form>--%>
<%--        </td>--%>
<%--    </tr>--%>
<%--    <%--%>
<%--            }--%>
<%--        } catch (Exception e) {--%>
<%--            out.println("Error: " + e.getMessage());--%>
<%--        } finally {--%>
<%--            if (rs != null) try { rs.close(); } catch(Exception e) {}--%>
<%--            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}--%>
<%--            if (conn != null) try { conn.close(); } catch(Exception e) {}--%>
<%--        }--%>
<%--    %>--%>
<%--    </tbody>--%>
<%--</table>--%>
<%--</body>--%>
<%--</html>--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Degree Management</title>
    <script>
        function submitDeleteForm(degreeId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

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
<h1>Degree List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Degree Id</th>
        <th>Type</th>
        <th>Name</th>
        <th>Required Units</th>
        <th>Minimum Grade</th>
        <th>Department Name</th>
        <th>Upper Division Required Units</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
            <td>
                <select name="type" required>
                    <option value="Bachelor">Bachelor</option>
                    <option value="Master">Master</option>
                    <option value="PhD">PhD</option>
                </select>
            </td>
            <td><input type="text" name="name" required></td>
            <td><input type="number" name="required_units" required></td>
            <td><input type="text" name="minimum_grade" pattern="^\d+(\.\d{1})?$" title="Enter a valid grade (e.g., 2.0, 3.5)" required></td>
            <td><input type="text" name="department_name" required></td>
            <td><input type="number" name="upper_division_required_units" required></td>
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
                String insertSQL = "INSERT INTO degree (type, name, required_units, minimum_grade, department_name, upper_division_required_units) VALUES (CAST(? AS degree_type), ?, ?, CAST(? AS numeric(2,1)), ?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setString(1, request.getParameter("type"));
                pstmt.setString(2, request.getParameter("name"));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("required_units")));
                pstmt.setBigDecimal(4, new java.math.BigDecimal(request.getParameter("minimum_grade")));
                pstmt.setString(5, request.getParameter("department_name"));
                pstmt.setInt(6, Integer.parseInt(request.getParameter("upper_division_required_units")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE degree SET type = CAST(? AS degree_type), name = ?, required_units = ?, minimum_grade = CAST(? AS numeric(2,1)), department_name = ?, upper_division_required_units = ? WHERE degree_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("type"));
                pstmt.setString(2, request.getParameter("name"));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("required_units")));
                pstmt.setBigDecimal(4, new java.math.BigDecimal(request.getParameter("minimum_grade")));
                pstmt.setString(5, request.getParameter("department_name"));
                pstmt.setInt(6, Integer.parseInt(request.getParameter("upper_division_required_units")));
                pstmt.setInt(7, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM degree WHERE degree_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("degree_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT degree_id, type, name, required_units, minimum_grade, department_name, upper_division_required_units FROM degree ORDER BY degree_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int degreeId = rs.getInt("degree_id");
                String type = rs.getString("type");
                String name = rs.getString("name");
                int requiredUnits = rs.getInt("required_units");
                String minimumGrade = rs.getString("minimum_grade");
                String departmentName = rs.getString("department_name");
                int upperDivisionRequiredUnits = rs.getInt("upper_division_required_units");
    %>
    <tr>
        <form method="post">
            <td><%= degreeId %></td>
            <td>
                <select name="type" required>
                    <option value="Bachelor" <%= "Bachelor".equals(type) ? "selected" : "" %>>Bachelor</option>
                    <option value="Master" <%= "Master".equals(type) ? "selected" : "" %>>Master</option>
                    <option value="PhD" <%= "PhD".equals(type) ? "selected" : "" %>>PhD</option>
                </select>
            </td>
            <td><input type="text" name="name" value="<%= name %>" required></td>
            <td><input type="number" name="required_units" value="<%= requiredUnits %>" required></td>
            <td><input type="text" name="minimum_grade" value="<%= minimumGrade %>" required></td>
            <td><input type="text" name="department_name" value="<%= departmentName %>"></td>
            <td><input type="number" name="upper_division_required_units" value="<%= upperDivisionRequiredUnits %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= degreeId %>);">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="degree_id" value="<%= degreeId %>">
            </td>
        </form>
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
