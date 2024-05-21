<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Grade Report</title>
    <script>
        function submitForm() {
            document.getElementById('studentForm').submit();
        }
    </script>
</head>
<body>
<h1>Select Student</h1>
<form method="post" id="studentForm">
    <label for="ssn">Student:</label>
    <select name="ssn" id="ssn" required onchange="submitForm()">
        <option value="">Select a student</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String selectSQL = "SELECT DISTINCT s.ssn, s.first_name, s.middle_name, s.last_name " +
                        "FROM student s " +
                        "JOIN enrollment e ON s.student_id = e.student_id";
                pstmt = conn.prepareStatement(selectSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String ssn = rs.getString("ssn");
                    String firstName = rs.getString("first_name");
                    String middleName = rs.getString("middle_name");
                    String lastName = rs.getString("last_name");
        %>
        <option value="<%= ssn %>"><%= ssn %> - <%= firstName %> <%= middleName %> <%= lastName %></option>
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
</form>

<%
    String ssnParam = request.getParameter("ssn");
    if (ssnParam != null && !ssnParam.isEmpty()) {
%>
<h2>Grade Report for Student SSN: <%= ssnParam %></h2>
<%
        conn = null;
        pstmt = null;
        rs = null;
        try {
            conn = DatabaseConnection.getConnection();
            String query = "SELECT DISTINCT c.class_id, c.course_id, c.year, c.quarter, c.title, e.unit, e.grade, s.first_name, s.middle_name, s.last_name, s.ssn, e.grade_type, gc.number_grade " +
                    "FROM class c " +
                    "JOIN enrollment e ON c.class_id = e.class_id " +
                    "JOIN section sec ON e.section_id = sec.section_id " +
                    "JOIN student s ON e.student_id = s.student_id " +
                    "LEFT JOIN grade_conversion gc ON e.grade::text = gc.letter_grade " +
                    "WHERE s.ssn = ? " +
                    "ORDER BY c.year, c.quarter";
            pstmt = conn.prepareStatement(query);
            pstmt.setString(1, ssnParam);
            rs = pstmt.executeQuery();

            if (!rs.isBeforeFirst()) {
                out.println("No classes found for the selected student.");
            } else {
                String currentQuarter = "";
                String currentYear = "";
                double totalPoints = 0;
                double totalUnits = 0;
                double cumulativePoints = 0;
                double cumulativeUnits = 0;
                out.println("<table border='1'>");
                out.println("<thead><tr><th>Class ID</th><th>Course ID</th><th>Year</th><th>Quarter</th><th>Title</th><th>Units</th><th>Grade</th><th>Grade Type</th></tr></thead>");
                out.println("<tbody>");
                while (rs.next()) {
                    String classId = rs.getString("class_id");
                    String courseId = rs.getString("course_id");
                    String year = rs.getString("year");
                    String quarter = rs.getString("quarter");
                    String title = rs.getString("title");
                    int units = rs.getInt("unit");
                    String grade = rs.getString("grade");
                    String gradeType = rs.getString("grade_type");
                    double gradeValue = rs.getDouble("number_grade");

                    if (!year.equals(currentYear) || !quarter.equals(currentQuarter)) {
                        if (!currentQuarter.isEmpty()) {
                            double gpa = totalPoints / totalUnits;
                            out.println("<tr><td colspan='8'>GPA for " + currentQuarter + " " + currentYear + ": " + String.format("%.2f", gpa) + "</td></tr>");
                            totalPoints = 0;
                            totalUnits = 0;
                        }
                        currentYear = year;
                        currentQuarter = quarter;
                    }

                    if (gradeValue > 0) {
                        totalPoints += gradeValue * units;
                        totalUnits += units;
                        cumulativePoints += gradeValue * units;
                        cumulativeUnits += units;
                    }

                    out.println("<tr>");
                    out.println("<td>" + classId + "</td>");
                    out.println("<td>" + courseId + "</td>");
                    out.println("<td>" + year + "</td>");
                    out.println("<td>" + quarter + "</td>");
                    out.println("<td>" + title + "</td>");
                    out.println("<td>" + units + "</td>");
                    out.println("<td>" + grade + "</td>");
                    out.println("<td>" + gradeType + "</td>");
                    out.println("</tr>");
                }
                if (totalUnits > 0) {
                    double gpa = totalPoints / totalUnits;
                    out.println("<tr><td colspan='8'>GPA for " + currentQuarter + " " + currentYear + ": " + String.format("%.2f", gpa) + "</td></tr>");
                }
                if (cumulativeUnits > 0) {
                    double cumulativeGPA = cumulativePoints / cumulativeUnits;
                    out.println("<tr><td colspan='8'>Cumulative GPA: " + String.format("%.2f", cumulativeGPA) + "</td></tr>");
                }
                out.println("</tbody></table>");
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
