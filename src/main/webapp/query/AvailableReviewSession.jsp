<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Class Schedule Conflict Checker</title>
</head>
<body>
<h1>Check Class Schedule Conflicts</h1>
<form method="post">
    <label for="start_date">Start Date:</label>
    <td><input type="date" id="start_date" name="start_date" required></td>

    <label for="end_date">End Date:</label>
    <td><input type="date" id="end_date" name="end_date" required></td>

    <label for="class">Select Class and Section:</label>
    <select name="class" id="class" required onchange="submitForm()">
        <option value="">Select Class and Section</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                //conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "123456");

                String selectSQL = "SELECT DISTINCT e.class_id AS class_id, e.section_id AS section_id" +
                        " FROM enrollment e, class c WHERE c.class_id=e.class_id AND c.quarter='SPRING' AND c.year=2018";
                pstmt = conn.prepareStatement(selectSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String classId = rs.getString("class_id");
                    String sectionId = rs.getString("section_id");
        %>
        <option value="<%= classId %>_<%= sectionId %>"><%= classId %> - <%= sectionId %> </option>
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
    </select><br>
    <input type="submit" value="Generate Report">
</form>

<%
    String combinedParam = request.getParameter("class");
    String startDateParam = request.getParameter("start_date");
    String endDateParam = request.getParameter("end_date");
    if (combinedParam != null && !combinedParam.isEmpty()) {
        try {
            String[] parts = combinedParam.split("_");
            String classParam = parts[0];
            String sectionParam = parts[1];

            conn = DatabaseConnection.getConnection();
            //conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "123456");

            String query = "WITH PrepareSlots AS (" +
                    "    SELECT generate_series(?::timestamp, ?::timestamp, '1 hour') AS start_time" +
                    ")," +
                    "PossibleSlots AS (" +
                    "    SELECT * FROM PrepareSlots ps" +
                    "    WHERE start_time::time >= '08:00'::time" +
                    "    AND start_time::time <= '19:00'::time" +
                    ")," +
                    "StudentMeetings AS (" +
                    "    SELECT DISTINCT m.weekday::text AS weekday, m.start_time, m.end_time" +
                    "    FROM enrollment e" +
                    "    JOIN section sec ON e.section_id = sec.section_id AND e.class_id = sec.class_id" +
                    "    JOIN meeting m ON sec.section_id = m.section_id AND sec.class_id = m.class_id" +
                    "    WHERE EXISTS(" +
                    "        SELECT 1" +
                    "        FROM enrollment ee" +
                    "        WHERE ee.class_id = ? AND ee.section_id = ? AND ee.student_id = e.student_id)" +
                    "    AND m.start_date <= ? AND m.end_date >= ?" +
                    ")," +
                    "AvailableSlots AS (" +
                    "    SELECT p.start_time" +
                    "    FROM PossibleSlots p" +
                    "    WHERE NOT EXISTS (" +
                    "        SELECT 1" +
                    "        FROM StudentMeetings sm" +
                    "        WHERE TRIM(TO_CHAR(p.start_time, 'Day')) = sm.weekday" +
                    "          AND sm.start_time < (p.start_time + INTERVAL '1 hour')::time" +
                    "          AND sm.end_time > p.start_time::time" +
                    "    )" +
                    ")" +
                    " SELECT start_time AS result_start_time, TO_CHAR(start_time, 'Day') AS result_weekday, " +
                    " start_time::time + INTERVAL '1 hour' AS result_end_time " +
                    " FROM AvailableSlots" +
                    " ORDER BY start_time";
            pstmt = conn.prepareStatement(query);

            String startTimestamp = startDateParam + " 08:00:00";
            String endTimestamp = endDateParam + " 20:00:00";
            pstmt.setTimestamp(1, Timestamp.valueOf(startTimestamp));
            pstmt.setTimestamp(2, Timestamp.valueOf(endTimestamp));
            pstmt.setInt(3, Integer.parseInt(classParam));
            pstmt.setInt(4, Integer.parseInt(sectionParam));
            pstmt.setDate(5, Date.valueOf(request.getParameter("start_date")));
            pstmt.setDate(6, Date.valueOf(request.getParameter("end_date")));
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                out.println("<p>No available time slots for class: "+classParam+" section: "+sectionParam+".</p>");
            } else {
%>
<h2>Possible Review Session Slots</h2>
<table border="1">
    <thead>
    <tr>
        <th>Start Time</th>
        <th>Weekday</th>
        <th>End Time</th>
    </tr>
    </thead>
    <tbody>
    <%
        while (rs.next()) {
            String resultStartTime = rs.getString("result_start_time");
            String resultWeekday = rs.getString("result_weekday");
            String resultEndTime = rs.getString("result_end_time");
    %>
    <tr>
        <td><%= resultStartTime %></td>
        <td><%= resultWeekday %></td>
        <td><%= resultEndTime %></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>
<%
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
%>
</body>
</html>
