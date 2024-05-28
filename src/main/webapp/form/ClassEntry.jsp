<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Class Management</title>
    <script>
        function submitDeleteForm(classId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let classIdInput = document.createElement('input');
            classIdInput.type = 'hidden';
            classIdInput.name = 'class_id';
            classIdInput.value = classId;
            form.appendChild(classIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Class List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Class Id</th>
        <th>Course Id</th>
        <th>Year</th>
        <th>Quarter</th>
        <th>Title</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
            <td><input type="number" name="course_id" required></td>
            <td><input type="number" name="year" required></td>
            <td>
                <select name="quarter" required>
                    <option value="FALL">Fall</option>
                    <option value="WINTER">Winter</option>
                    <option value="SPRING">Spring</option>
                    <option value="SUMMER SESSION 1">Summer Session 1</option>
                    <option value="SUMMER SESSION 2">Summer Session 2</option>
                    <option value="SUMMER SESSION SPECIAL">Summer Session Special</option>
                </select>
            </td>
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
                String insertSQL = "INSERT INTO class (course_id, year, quarter, title) VALUES (?, ?, CAST(? AS quarter_type), ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("course_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("year")));
                pstmt.setString(3, request.getParameter("quarter"));
                pstmt.setString(4, request.getParameter("title"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE class SET course_id = ?, year = ?, quarter = CAST(? AS quarter_type), title = ? WHERE class_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("course_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("year")));
                pstmt.setString(3, request.getParameter("quarter"));
                pstmt.setString(4, request.getParameter("title"));
                pstmt.setInt(5, Integer.parseInt(request.getParameter("class_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM class WHERE class_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT class_id, course_id, year, quarter, title FROM class ORDER BY course_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int classId = rs.getInt("class_id");
                int courseId = rs.getInt("course_id");
                int year = rs.getInt("year");
                String quarter = rs.getString("quarter");
                String title = rs.getString("title");
    %>
    <tr>
        <form method="post">
            <td><%= classId %></td>
            <td><input type="number" name="course_id" value="<%= courseId %>" required></td>
            <td><input type="number" name="year" value="<%= year %>" required></td>
            <td>
                <select name="quarter" required>
                    <option value="FALL" <%= "FALL".equals(quarter) ? "selected" : "" %>>Fall</option>
                    <option value="WINTER" <%= "WINTER".equals(quarter) ? "selected" : "" %>>Winter</option>
                    <option value="SPRING" <%= "SPRING".equals(quarter) ? "selected" : "" %>>Spring</option>
                    <option value="SUMMER SESSION 1" <%= "SUMMER SESSION 1".equals(quarter) ? "selected" : "" %>>Summer Session 1</option>
                    <option value="SUMMER SESSION 2" <%= "SUMMER SESSION 2".equals(quarter) ? "selected" : "" %>>Summer Session 2</option>
                    <option value="SUMMER SESSION SPECIAL" <%= "SUMMER SESSION SPECIAL".equals(quarter) ? "selected" : "" %>>Summer Session Special</option>
                </select>
            </td>
            <td><input type="text" name="title" value="<%= title %>" required></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= classId %>);">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="class_id" value="<%= classId %>">
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
