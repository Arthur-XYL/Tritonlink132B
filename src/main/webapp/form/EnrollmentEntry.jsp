<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Enrollment Management</title>
    <script>
        function submitDeleteForm(studentId, sectionId, classId) {
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

            let sectionIdInput = document.createElement('input');
            sectionIdInput.type = 'hidden';
            sectionIdInput.name = 'section_id';
            sectionIdInput.value = sectionId;
            form.appendChild(sectionIdInput);

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
<h1>Enrollment List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Student Id</th>
        <th>Section Id</th>
        <th>Class Id</th>
        <th>Units</th>
        <th>Is Waitlisted</th>
        <th>Grade Type</th>
        <th>Grade</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="student_id" required></td>
            <td><input type="number" name="section_id" required></td>
            <td><input type="number" name="class_id" required></td>
            <td><input type="number" name="unit" required></td>
            <td><input type="checkbox" name="is_waitlisted"></td>
            <td>
                <select name="grade_type" required>
                    <option value="Letter Grade">Letter Grade</option>
                    <option value="S/U">S/U</option>
                </select>
            </td>
            <td>
                <select name="grade">
                    <option value="N/A">N/A</option>
                    <option value="A+">A+</option>
                    <option value="A">A</option>
                    <option value="A-">A-</option>
                    <option value="B+">B+</option>
                    <option value="B">B</option>
                    <option value="B-">B-</option>
                    <option value="C+">C+</option>
                    <option value="C">C</option>
                    <option value="C-">C-</option>
                    <option value="D">D</option>
                    <option value="F">F</option>
                    <option value="S">S</option>
                    <option value="U">U</option>
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
                String insertSQL = "INSERT INTO enrollment (student_id, section_id, class_id, unit, is_waitlisted, grade_type, grade) VALUES (?, ?, ?, ?, ?, CAST(? AS enrollment_grade_type), CAST(? AS grade_value))";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("unit")));
                pstmt.setBoolean(5, "on".equals(request.getParameter("is_waitlisted")));
                pstmt.setString(6, request.getParameter("grade_type"));
                pstmt.setString(7, request.getParameter("grade"));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE enrollment SET student_id = ?, section_id = ?, class_id = ?, unit = ?, is_waitlisted = ?, grade_type = CAST(? AS enrollment_grade_type), grade = CAST(? AS grade_value) WHERE student_id = ? AND section_id = ? AND class_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("unit")));
                pstmt.setBoolean(5, "on".equals(request.getParameter("is_waitlisted")));
                pstmt.setString(6, request.getParameter("grade_type"));
                pstmt.setString(7, request.getParameter("grade"));
                pstmt.setInt(8, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(9, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setInt(10, Integer.parseInt(request.getParameter("class_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM enrollment WHERE student_id = ? AND section_id = ? AND class_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("class_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT student_id, section_id, class_id, unit, is_waitlisted, grade_type, grade FROM enrollment ORDER BY student_id, section_id, class_id";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int studentId = rs.getInt("student_id");
                int sectionId = rs.getInt("section_id");
                int classId = rs.getInt("class_id");
                int unit = rs.getInt("unit");
                boolean isWaitlisted = rs.getBoolean("is_waitlisted");
                String gradeType = rs.getString("grade_type");
                String grade = rs.getString("grade") != null ? rs.getString("grade") : "N/A";
    %>
    <tr>
        <form method="post">
            <td><%= studentId %></td>
            <td><%= sectionId %></td>
            <td><%= classId %></td>
            <td><input type="number" name="unit" value="<%= unit %>" required></td>
            <td><input type="checkbox" name="is_waitlisted" <%= isWaitlisted ? "checked" : "" %>></td>
            <td>
                <select name="grade_type" required>
                    <option value="Letter Grade" <%= "Letter Grade".equals(gradeType) ? "selected" : "" %>>Letter Grade</option>
                    <option value="S/U" <%= "S/U".equals(gradeType) ? "selected" : "" %>>S/U</option>
                </select>
            </td>
            <td>
                <select name="grade">
                    <option value="N/A" <%= "N/A".equals(grade) ? "selected" : "" %>>N/A</option>
                    <option value="A+" <%= "A+".equals(grade) ? "selected" : "" %>>A+</option>
                    <option value="A" <%= "A".equals(grade) ? "selected" : "" %>>A</option>
                    <option value="A-" <%= "A-".equals(grade) ? "selected" : "" %>>A-</option>
                    <option value="B+" <%= "B+".equals(grade) ? "selected" : "" %>>B+</option>
                    <option value="B" <%= "B".equals(grade) ? "selected" : "" %>>B</option>
                    <option value="B-" <%= "B-".equals(grade) ? "selected" : "" %>>B-</option>
                    <option value="C+" <%= "C+".equals(grade) ? "selected" : "" %>>C+</option>
                    <option value="C" <%= "C".equals(grade) ? "selected" : "" %>>C</option>
                    <option value="C-" <%= "C-".equals(grade) ? "selected" : "" %>>C-</option>
                    <option value="D" <%= "D".equals(grade) ? "selected" : "" %>>D</option>
                    <option value="F" <%= "F".equals(grade) ? "selected" : "" %>>F</option>
                    <option value="S" <%= "S".equals(grade) ? "selected" : "" %>>S</option>
                    <option value="U" <%= "U".equals(grade) ? "selected" : "" %>>U</option>
                </select>
            </td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= studentId %>, <%= sectionId %>, <%= classId %>);">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="student_id" value="<%= studentId %>">
                <input type="hidden" name="section_id" value="<%= sectionId %>">
                <input type="hidden" name="class_id" value="<%= classId %>">
                <input type="hidden" name="unit" value="<%= unit %>">
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
