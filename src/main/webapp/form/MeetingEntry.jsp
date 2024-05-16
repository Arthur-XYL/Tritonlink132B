<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Meeting Management</title>
    <script>
        function submitDeleteForm(classId, sectionId, startDate, startTime, weekday) {
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

            let weekdayInput = document.createElement('input');
            weekdayInput.type = 'hidden';
            weekdayInput.name = 'weekday';
            weekdayInput.value = weekday;
            form.appendChild(weekdayInput);

            form.submit();
        }
    </script>
</head>
<body>
<h1>Meeting Schedule</h1>
<table border="1">
    <thead>
    <tr>
        <th>Class ID</th>
        <th>Section ID</th>
        <th>Type</th>
        <th>Start Date</th>
        <th>Weekday</th>
        <th>Start Time</th>
        <th>End Date</th>
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
            <td>
                <select name="type" required>
                    <option value="LE">Lecture</option>
                    <option value="DI">Discussion</option>
                    <option value="LA">Lab</option>
                </select>
            </td>
            <td><input type="date" name="start_date" required></td>
            <td>
                <select name="weekday" required>
                    <option value="Monday">Monday</option>
                    <option value="Tuesday">Tuesday</option>
                    <option value="Wednesday">Wednesday</option>
                    <option value="Thursday">Thursday</option>
                    <option value="Friday">Friday</option>
                    <option value="Saturday">Saturday</option>
                    <option value="Sunday">Sunday</option>
                </select>
            </td>
            <td><input type="time" name="start_time" required></td>
            <td><input type="date" name="end_date" required></td>
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
                String insertSQL = "INSERT INTO meeting (class_id, section_id, type, start_date, weekday, start_time, end_date, end_time, location, is_mandatory) VALUES (?, ?, CAST(? AS meeting_type), ?, CAST(? AS weekday_type), ?, ?, ?, ?, ?)";
                pstmt = conn.prepareStatement(insertSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setString(3, request.getParameter("type"));
                pstmt.setDate(4, Date.valueOf(request.getParameter("start_date")));
                pstmt.setString(5, request.getParameter("weekday"));

                pstmt.setTime(6, Time.valueOf(LocalTime.parse(request.getParameter("start_time"))));
                pstmt.setDate(7, Date.valueOf(request.getParameter("end_date")));
                pstmt.setTime(8, Time.valueOf(LocalTime.parse(request.getParameter("end_time"))));
                pstmt.setString(9, request.getParameter("location"));
                pstmt.setBoolean(10, Boolean.parseBoolean(request.getParameter("is_mandatory")));
                pstmt.executeUpdate();
            }

            if ("update".equals(action)) {
                String updateSQL = "UPDATE meeting SET type = CAST(? AS meeting_type), end_date = ?, end_time = ?, location = ?, is_mandatory = ? WHERE class_id = ? AND section_id = ? AND start_date = ? AND start_time = CAST(? AS time without time zone) AND weekday = CAST(? AS weekday_type)";
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, request.getParameter("type"));
                pstmt.setDate(2, Date.valueOf(request.getParameter("end_date")));
                pstmt.setTime(3, Time.valueOf(LocalTime.parse(request.getParameter("end_time"))));
                pstmt.setString(4, request.getParameter("location"));
                pstmt.setBoolean(5, Boolean.parseBoolean(request.getParameter("is_mandatory")));
                pstmt.setInt(6, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(7, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setDate(8, Date.valueOf(request.getParameter("start_date")));
                pstmt.setTime(9, Time.valueOf(LocalTime.parse(request.getParameter("start_time"))));
                pstmt.setString(10, request.getParameter("weekday"));
                pstmt.executeUpdate();
            }

            if ("delete".equals(action)) {
                String deleteSQL = "DELETE FROM meeting WHERE class_id = ? AND section_id = ? AND start_date = ? AND start_time = ? AND weekday = CAST(? AS weekday_type)";
                pstmt = conn.prepareStatement(deleteSQL);
                pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                pstmt.setDate(3, Date.valueOf(request.getParameter("start_date")));
                pstmt.setTime(4, Time.valueOf(LocalTime.parse(request.getParameter("start_time"))));
                pstmt.setString(5, request.getParameter("weekday"));
                pstmt.executeUpdate();
            }

            conn.commit();
            conn.setAutoCommit(true);

            String selectSQL = "SELECT class_id, section_id, type, start_date, weekday, start_time, end_date, end_time, location, is_mandatory FROM meeting ORDER BY class_id, section_id, start_date, start_time, weekday";
            pstmt = conn.prepareStatement(selectSQL);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                int classId = rs.getInt("class_id");
                int sectionId = rs.getInt("section_id");
                String type = rs.getString("type");
                Date startDate = rs.getDate("start_date");
                String weekday = rs.getString("weekday");
                Time startTime = rs.getTime("start_time");
                Date endDate = rs.getDate("end_date");
                Time endTime = rs.getTime("end_time");
                String location = rs.getString("location");
                boolean isMandatory = rs.getBoolean("is_mandatory");
    %>
    <tr>
        <form method="post">
            <td><%= classId %></td>
            <td><%= sectionId %></td>
            <td>
                <select name="type" required>
                    <option value="LE" <%= "LE".equals(type) ? "selected" : "" %>>Lecture</option>
                    <option value="DI" <%= "DI".equals(type) ? "selected" : "" %>>Discussion</option>
                    <option value="LA" <%= "LA".equals(type) ? "selected" : "" %>>Lab</option>
                </select>
            </td>
            <td><input type="date" name="start_date" value="<%= startDate.toString() %>" required></td>
            <td>
                <select name="weekday" required>
                    <option value="Monday" <%= "Monday".equals(weekday) ? "selected" : "" %>>Monday</option>
                    <option value="Tuesday" <%= "Tuesday".equals(weekday) ? "selected" : "" %>>Tuesday</option>
                    <option value="Wednesday" <%= "Wednesday".equals(weekday) ? "selected" : "" %>>Wednesday</option>
                    <option value="Thursday" <%= "Thursday".equals(weekday) ? "selected" : "" %>>Thursday</option>
                    <option value="Friday" <%= "Friday".equals(weekday) ? "selected" : "" %>>Friday</option>
                    <option value="Saturday" <%= "Saturday".equals(weekday) ? "selected" : "" %>>Saturday</option>
                    <option value="Sunday" <%= "Sunday".equals(weekday) ? "selected" : "" %>>Sunday</option>
                </select>
            </td>
            <td><input type="time" name="start_time" value="<%= startTime.toString() %>" required></td>
            <td><input type="date" name="end_date" value="<%= endDate.toString() %>" required></td>
            <td><input type="time" name="end_time" value="<%= endTime.toString() %>" required></td>
            <td><input type="text" name="location" value="<%= location %>" required></td>
            <td><input type="checkbox" name="is_mandatory" <%= isMandatory ? "checked" : "" %>></td>
            <td>
                <input type="submit" value="Update">
                <input type="button" value="Delete" onclick="submitDeleteForm(<%= classId %>, <%= sectionId %>, '<%= startDate.toString() %>', '<%= startTime.toString() %>', '<%= weekday %>');">

                <input type="hidden" name="action" value="update">
                <input type="hidden" name="class_id" value="<%= classId %>">
                <input type="hidden" name="section_id" value="<%= sectionId %>">
                <input type="hidden" name="start_date" value="<%= startDate.toString() %>">
                <input type="hidden" name="start_time" value="<%= startTime.toString() %>">
                <input type="hidden" name="weekday" value="<%= weekday %>">
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
