<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Probation Period Management</title>
    <script>
        function submitDeleteForm(studentId, startYear, startQuarter) {
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

            let startYearInput = document.createElement('input');
            startYearInput.type = 'hidden';
            startYearInput.name = 'start_year';
            startYearInput.value = startYear;
            form.appendChild(startYearInput);

            let startQuarterInput = document.createElement('input');
            startQuarterInput.type = 'hidden';
            startQuarterInput.name = 'start_quarter';
            startQuarterInput.value = startQuarter;
            form.appendChild(startQuarterInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Probation Period List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student ID</th>
        <th>Start Year</th>
        <th>Start Quarter</th>
        <th>End Year</th>
        <th>End Quarter</th>
        <th>Reason</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="student_id" required></td>
            <td><input type="number" name="start_year" required></td>
            <td>
                <select name="start_quarter" required>
                    <option value="FALL">Fall</option>
                    <option value="WINTER">Winter</option>
                    <option value="SPRING">Spring</option>
                    <option value="SUMMER SESSION 1">Summer Session 1</option>
                    <option value="SUMMER SESSION 2">Summer Session 2</option>
                    <option value="SUMMER SESSION SPECIAL">Summer Session Special</option>
                </select>
            </td>
            <td><input type="number" name="end_year" required></td>
            <td>
                <select name="end_quarter" required>
                    <option value="FALL">Fall</option>
                    <option value="WINTER">Winter</option>
                    <option value="SPRING">Spring</option>
                    <option value="SUMMER SESSION 1">Summer Session 1</option>
                    <option value="SUMMER SESSION 2">Summer Session 2</option>
                    <option value="SUMMER SESSION SPECIAL">Summer Session Special</option>
                </select>
            </td>
            <td><textarea name="reason" required></textarea></td>
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
                String insertSQL = "INSERT INTO probation_period (student_id, start_year, start_quarter, end_year, end_quarter, reason) VALUES (?, ?, CAST(? AS quarter_type), ?, CAST(? AS quarter_type), ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("start_year")));
                pstmt.setString(3, request.getParameter("start_quarter"));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("end_year")));
                pstmt.setString(5, request.getParameter("end_quarter"));
                pstmt.setString(6, request.getParameter("reason"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE probation_period SET end_year = ?, end_quarter = CAST(? AS quarter_type), reason = ? WHERE student_id = ? AND start_year = ? AND start_quarter = CAST(? AS quarter_type)";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("end_year")));
                pstmt.setString(2, request.getParameter("end_quarter"));
                pstmt.setString(3, request.getParameter("reason"));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(5, Integer.parseInt(request.getParameter("start_year")));
                pstmt.setString(6, request.getParameter("start_quarter"));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM probation_period WHERE student_id = ? AND start_year = ? AND start_quarter = CAST(? AS quarter_type)";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("start_year")));
                pstmt.setString(3, request.getParameter("start_quarter"));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT student_id, start_year, start_quarter, end_year, end_quarter, reason FROM probation_period ORDER BY student_id, start_year, start_quarter";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                int startYear = rs.getInt("start_year");
                String startQuarter = rs.getString("start_quarter");
                int endYear = rs.getInt("end_year");
                String endQuarter = rs.getString("end_quarter");
                String reason = rs.getString("reason");
    %>
    <tr>
        <form method="post">
            <td><%= studentId %></td>
            <td><%= startYear %></td>
            <td><%= startQuarter %></td>
            <td><input type="number" name="end_year" value="<%= endYear %>" required></td>
            <td>
                <select name="end_quarter" required>
                    <option value="FALL" <%= "FALL".equals(endQuarter) ? "selected" : "" %>>Fall</option>
                    <option value="WINTER" <%= "WINTER".equals(endQuarter) ? "selected" : "" %>>Winter</option>
                    <option value="SPRING" <%= "SPRING".equals(endQuarter) ? "selected" : "" %>>Spring</option>
                    <option value="SUMMER SESSION 1" <%= "SUMMER SESSION 1".equals(endQuarter) ? "selected" : "" %>>Summer Session 1</option>
                    <option value="SUMMER SESSION 2" <%= "SUMMER SESSION 2".equals(endQuarter) ? "selected" : "" %>>Summer Session 2</option>
                    <option value="SUMMER SESSION SPECIAL" <%= "SUMMER SESSION SPECIAL".equals(endQuarter) ? "selected" : "" %>>Summer Session Special</option>
                </select>
            </td>
            <td><textarea name="reason" required><%= reason %></textarea></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= studentId %>, <%= startYear %>, '<%= startQuarter %>');">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="student_id" value="<%= studentId %>">
                <input type="hidden" name="start_year" value="<%= startYear %>">
                <input type="hidden" name="start_quarter" value="<%= startQuarter %>">
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
