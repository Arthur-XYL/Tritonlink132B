<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Undergraduate Degree Requirement Checker</title>
    <script>
        function submitForm() {
            document.getElementById('requirementForm').submit();
        }
    </script>
</head>
<body>
<h1>Check Remaining Degree Requirements</h1>
<form method="post" id="requirementForm">
    <label for="ssn">Select Student:</label>
    <select name="ssn" id="ssn" required>
        <option value="">Select a student</option>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            try {
                conn = DatabaseConnection.getConnection();
                String selectSQL = "SELECT s.ssn, s.first_name, s.middle_name, s.last_name FROM student s JOIN undergraduate u ON s.student_id = u.student_id WHERE s.is_enrolled = TRUE";
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
    <br><br>
    <label for="degree_name">Select Degree:</label>
    <select name="degree_name" id="degree_name" required>
        <option value="">Select a degree</option>
        <%
            try {
                conn = DatabaseConnection.getConnection();
                String degreeSQL = "SELECT name FROM degree WHERE type = 'Bachelor'";
                pstmt = conn.prepareStatement(degreeSQL);
                rs = pstmt.executeQuery();
                while (rs.next()) {
                    String degreeName = rs.getString("name");
        %>
        <option value="<%= degreeName %>"><%= degreeName %></option>
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
    <br><br>
    <input type="submit" value="Check Requirements">
</form>

<%
    String ssn = request.getParameter("ssn");
    String degreeName = request.getParameter("degree_name");

    if (ssn != null && degreeName != null && !ssn.isEmpty() && !degreeName.isEmpty()) {
        try {
            conn = DatabaseConnection.getConnection();

            // Get student information
            String studentInfoSQL = "SELECT first_name, middle_name, last_name FROM student WHERE ssn = ?";
            pstmt = conn.prepareStatement(studentInfoSQL);
            pstmt.setString(1, ssn);
            rs = pstmt.executeQuery();
            String studentName = "";
            if (rs.next()) {
                String firstName = rs.getString("first_name");
                String middleName = rs.getString("middle_name");
                String lastName = rs.getString("last_name");
                studentName = firstName + " " + middleName + " " + lastName;
            }
            rs.close();
            pstmt.close();

            // Get student's completed units
            String studentUnitsSQL = "SELECT SUM(e.unit) as completed_units FROM enrollment e JOIN student s ON e.student_id = s.student_id WHERE s.ssn = ?";
            pstmt = conn.prepareStatement(studentUnitsSQL);
            pstmt.setString(1, ssn);
            rs = pstmt.executeQuery();
            int completedUnits = 0;
            if (rs.next()) {
                completedUnits = rs.getInt("completed_units");
            }
            rs.close();
            pstmt.close();

            // Get degree's required units
            String degreeUnitsSQL = "SELECT required_units, upper_division_required_units FROM degree WHERE name = ?";
            pstmt = conn.prepareStatement(degreeUnitsSQL);
            pstmt.setString(1, degreeName);
            rs = pstmt.executeQuery();
            int requiredUnits = 0;
            int upperDivisionRequiredUnits = 0;
            if (rs.next()) {
                requiredUnits = rs.getInt("required_units");
                upperDivisionRequiredUnits = rs.getInt("upper_division_required_units");
            }
            rs.close();
            pstmt.close();

            // Calculate remaining units
            int remainingUnits = requiredUnits - completedUnits;
            if (remainingUnits < 0) remainingUnits = 0;

            // Calculate completed upper division units
            String upperDivisionUnitsSQL = "SELECT SUM(e.unit) as upper_division_units FROM enrollment e JOIN student s ON e.student_id = s.student_id JOIN class c ON e.class_id = c.class_id JOIN course co ON c.course_id = co.course_id WHERE s.ssn = ? AND co.is_upper_division = TRUE";
            pstmt = conn.prepareStatement(upperDivisionUnitsSQL);
            pstmt.setString(1, ssn);
            rs = pstmt.executeQuery();
            int completedUpperDivisionUnits = 0;
            if (rs.next()) {
                completedUpperDivisionUnits = rs.getInt("upper_division_units");
            }
            rs.close();
            pstmt.close();

            int remainingUpperDivisionUnits = upperDivisionRequiredUnits - completedUpperDivisionUnits;
            if (remainingUpperDivisionUnits < 0) remainingUpperDivisionUnits = 0;

            // Display results
            out.println("<h2>Requirements for " + studentName + " for the degree " + degreeName + "</h2>");
            out.println("<p>Completed Units: " + completedUnits + "</p>");
            out.println("<p>Required Units: " + requiredUnits + "</p>");
            out.println("<p>Remaining Units: " + remainingUnits + "</p>");

            // Display upper division units
            if (upperDivisionRequiredUnits > 0) {
                out.println("<p>Completed Upper Division Units: " + completedUpperDivisionUnits + "</p>");
                out.println("<p>Required Upper Division Units: " + upperDivisionRequiredUnits + "</p>");
                out.println("<p>Remaining Upper Division Units: " + remainingUpperDivisionUnits + "</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
%>

</body>
</html>
