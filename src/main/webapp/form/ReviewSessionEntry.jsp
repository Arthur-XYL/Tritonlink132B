<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="static java.time.LocalTime.*" %>
<%@ page import="java.util.TimeZone" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Review Session Management</title>
    <script>
        function submitDeleteForm(classId, sectionId, startDate, startTime) {
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

            let sectionIdInput = document.createElement('input');
            sectionIdInput.type = 'hidden';
            sectionIdInput.name = 'section_id';
            sectionIdInput.value = sectionId;
            form.appendChild(sectionIdInput);

            let startDateInput = document.createElement('input');
            startDateInput.type = 'hidden';
            startDateInput.name = 'start_date';
            startDateInput.value = startDate;
            form.appendChild(startDateInput);

            let startTimeInput = document.createElement('input');
            startTimeInput.type = 'hidden';
            startTimeInput.name = 'start_time';
            startTimeInput.value = startTime;
            form.appendChild(startTimeInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Review Session Schedule</h1>
<table border="1">
    <thead>
    <tr>
        <th>Class ID</th>
        <th>Section ID</th>
        <th>Start Date</th>
        <th>Start Time</th>
        <th>End Time</th>
        <th>Location</th>
        <th>Is Mandatory</th>
        <th>Actions</th>
    </tr>
    </thead>
    <tbody>
    <tr>
        <form method="post">
            <td><input type="number" name="class_id" required></td>
            <td><input type="number" name="section_id" required></td>
            <td><input type="date" name="start_date" required></td>
            <td><input type="time" name="start_time" required></td>
            <td><input type="time" name="end_time" required></td>
            <td><input type="text" name="location" required></td>
            <td><input type="checkbox" name="is_mandatory"></td>
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
                String insertSQL = "INSERT INTO review_session (class_id, section_id, start_date, start_time, end_time, location, is_mandatory) VALUES (?, ?, ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setDate(3, Date.valueOf(request.getParameter("start_date")));
                LocalTime time = LocalTime.parse(request.getParameter("start_time"));
                pstmt.setTime(4, Time.valueOf(time));
                LocalTime time2 = LocalTime.parse(request.getParameter("end_time"));
                pstmt.setTime(5, Time.valueOf(time2));
                pstmt.setString(6, request.getParameter("location"));
                pstmt.setBoolean(7, Boolean.parseBoolean(request.getParameter("is_mandatory")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE review_session SET end_time = ?, location = ?, is_mandatory = ? WHERE class_id = ? AND section_id = ? AND start_date = ? AND start_time = CAST(? AS time without time zone)";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setTime(1, Time.valueOf(LocalTime.parse(request.getParameter("end_time"))));
                pstmt.setString(2, request.getParameter("location"));
                pstmt.setBoolean(3, Boolean.parseBoolean(request.getParameter("is_mandatory")));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(5, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setDate(6, Date.valueOf(request.getParameter("start_date")));
                pstmt.setTime(7, Time.valueOf(LocalTime.parse(request.getParameter("start_time"))));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM review_session WHERE class_id = ? AND section_id = ? AND start_date = ? AND start_time = ?";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setDate(3, Date.valueOf(request.getParameter("start_date")));
                pstmt.setTime(4, Time.valueOf(LocalTime.parse(request.getParameter("start_time"))));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT class_id, section_id, start_date, start_time, end_time, location, is_mandatory FROM review_session ORDER BY class_id, section_id, start_date, start_time";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int classId = rs.getInt("class_id");
                int sectionId = rs.getInt("section_id");
                Date startDate = rs.getDate("start_date");
                Time startTime = rs.getTime("start_time");
                Time endTime = rs.getTime("end_time");
                String location = rs.getString("location");
                boolean isMandatory = rs.getBoolean("is_mandatory");
    %>
    <tr>
        <form method="post">
            <td><%= classId %></td>
            <td><%= sectionId %></td>
            <td><input type="date" name="start_date" value="<%= startDate.toString() %>" required></td>
            <td><input type="time" name="start_time" value="<%= startTime.toString() %>" required></td>
            <td><input type="time" name="end_time" value="<%= endTime.toString() %>" required></td>
            <td><input type="text" name="location" value="<%= location %>" required></td>
            <td><input type="checkbox" name="is_mandatory" <%= isMandatory ? "checked" : "" %>></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= classId %>, <%= sectionId %>, '<%= startDate.toString() %>', '<%= startTime.toString() %>');">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="class_id" value="<%= classId %>">
                <input type="hidden" name="section_id" value="<%= sectionId %>">
                <input type="hidden" name="start_date" value="<%= startDate.toString() %>">
                <input type="hidden" name="start_time" value="<%= startTime.toString() %>">
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
