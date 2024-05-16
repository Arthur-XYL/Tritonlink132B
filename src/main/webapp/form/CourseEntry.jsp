<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Course Management</title>
    <script>
        function submitDeleteForm(courseId) {
            let form = document.createElement('form');
            document.body.appendChild(form);
            form.method = 'post';
            form.action = '';

            let actionInput = document.createElement('input');
            actionInput.type = 'hidden';
            actionInput.name = 'action';
            actionInput.value = 'delete';
            form.appendChild(actionInput);

            let courseIdInput = document.createElement('input');
            courseIdInput.type = 'hidden';
            courseIdInput.name = 'course_id';
            courseIdInput.value = courseId;
            form.appendChild(courseIdInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Course List</h1>
<table border="1">
    <thead>
    <tr>
        <th>Course Id</th>
        <th>Course Number</th>
        <th>Min Units</th>
        <th>Max Units</th>
        <th>Grade Type</th>
        <th>Lab Required</th>
        <th>Instructor Consent Required</th>
        <th>Is Upper Division</th>
        <th>Department Name</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td>N/A</td>
            <td><input type="text" name="course_number" required></td>
            <td><input type="number" name="min_units" required></td>
            <td><input type="number" name="max_units" required></td>
            <td>
                <select name="grade_type" required>
                    <option value="Letter Grade">Letter Grade</option>
                    <option value="S/U">S/U</option>
                    <option value="Letter Grade or S/U">Letter Grade or S/U</option>
                </select>
            </td>
            <td><input type="checkbox" name="lab_required"></td>
            <td><input type="checkbox" name="instructor_consent_required"></td>
            <td><input type="checkbox" name="is_upper_division"></td>
            <td><input type="text" name="department_name" required></td>
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
                if ("insert".equals(action)) {
                    String courseNumber = request.getParameter("course_number");
                    String minUnits = request.getParameter("min_units");
                    String maxUnits = request.getParameter("max_units");
                    String gradeType = request.getParameter("grade_type");
                    String labRequired = request.getParameter("lab_required");
                    String instructorConsentRequired = request.getParameter("instructor_consent_required");
                    String isUpperDivision = request.getParameter("is_upper_division");
                    String departmentName = request.getParameter("department_name");

                    // Check for null values and assign defaults or handle them as required
                    courseNumber = courseNumber != null ? courseNumber : "";
                    minUnits = minUnits != null ? minUnits : "0";
                    maxUnits = maxUnits != null ? maxUnits : "0";
                    gradeType = gradeType != null ? gradeType : "Letter Grade";  // Assuming 'Letter Grade' as default
                    boolean labRequiredBool = "on".equals(labRequired);
                    boolean instructorConsentRequiredBool = "on".equals(instructorConsentRequired);
                    boolean isUpperDivisionBool = "on".equals(isUpperDivision);
                    departmentName = departmentName != null ? departmentName : "";

                    String insertSQL = "INSERT INTO course (course_number, min_units, max_units, grade_type, lab_required, instructor_consent_required, is_upper_division, department_name) VALUES (?, ?, ?, CAST(? AS course_grade_type), ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(insertSQL);
                    pstmt.setString(1, courseNumber);
                    pstmt.setInt(2, Integer.parseInt(minUnits));
                    pstmt.setInt(3, Integer.parseInt(maxUnits));
                    pstmt.setString(4, gradeType);
                    pstmt.setBoolean(5, labRequiredBool);
                    pstmt.setBoolean(6, instructorConsentRequiredBool);
                    pstmt.setBoolean(7, isUpperDivisionBool);
                    pstmt.setString(8, departmentName);
                    pstmt.executeUpdate();
                }

            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE course SET course_number = ?, min_units = ?, max_units = ?, grade_type = CAST(? AS course_grade_type), lab_required = ?, instructor_consent_required = ?, is_upper_division = ?, department_name = ? WHERE course_id = ?";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("course_number"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("min_units")));
                pstmt.setInt(3, Integer.parseInt(request.getParameter("max_units")));
                pstmt.setString(4, request.getParameter("grade_type"));
                pstmt.setBoolean(5, request.getParameter("lab_required") != null && request.getParameter("lab_required").equals("on"));
                pstmt.setBoolean(6, request.getParameter("instructor_consent_required") != null && request.getParameter("instructor_consent_required").equals("on"));
                pstmt.setBoolean(7, request.getParameter("is_upper_division") != null && request.getParameter("is_upper_division").equals("on"));
                pstmt.setString(8, request.getParameter("department_name"));
                pstmt.setInt(9, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM course WHERE course_id = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("course_id")));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT course_id, course_number, min_units, max_units, grade_type, lab_required, instructor_consent_required, is_upper_division, department_name FROM course ORDER BY course_number";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int courseId = rs.getInt("course_id");
                String courseNumber = rs.getString("course_number");
                int minUnits = rs.getInt("min_units");
                int maxUnits = rs.getInt("max_units");
                String gradeType = rs.getString("grade_type");
                boolean labRequired = rs.getBoolean("lab_required");
                boolean instructorConsentRequired = rs.getBoolean("instructor_consent_required");
                boolean isUpperDivision = rs.getBoolean("is_upper_division");
                String departmentName = rs.getString("department_name");
    %>
    <tr>
        <form method="post">
            <td><%= courseId %></td>
            <td><input type="text" name="course_number" value="<%= courseNumber %>" required></td>
            <td><input type="number" name="min_units" value="<%= minUnits %>" required></td>
            <td><input type="number" name="max_units" value="<%= maxUnits %>" required></td>
            <td>
                <select name="grade_type" required>
                    <option value="Letter Grade" <%= "Letter Grade".equals(gradeType) ? "selected" : "" %>>Letter Grade</option>
                    <option value="S/U" <%= "S/U".equals(gradeType) ? "selected" : "" %>>S/U</option>
                    <option value="Letter Grade or S/U" <%= "Letter Grade or S/U".equals(gradeType) ? "selected" : "" %>>Letter Grade or S/U</option>
                </select>
            </td>
            <td><input type="checkbox" name="lab_required" <%= labRequired ? "checked" : "" %>></td>
            <td><input type="checkbox" name="instructor_consent_required" <%= instructorConsentRequired ? "checked" : "" %>></td>
            <td><input type="checkbox" name="is_upper_division" <%= isUpperDivision ? "checked" : "" %>></td>
            <td><input type="text" name="department_name" value="<%= departmentName %>" required></td>
            <td>
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="course_id" value="<%= courseId %>">
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= courseId %>);">
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
