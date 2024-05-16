<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="org.example.DatabaseConnection" %>
<!DOCTYPE html>
<html>
<head>
  <title>Section Management</title>
  <script>
    function submitDeleteForm(classId, sectionId) {
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

      form.submit();
    }
  </script>
</head>
<body>
<h1>Section List</h1>
<table border="1">
  <thead>
  <tr>
    <th>Class Id</th>
    <th>Section Id</th>
    <th>Faculty Name</th>
    <th>Enrollment Limit</th>
    <th>Actions</th>
  </tr>
  </thead>
  <tbody>
  <tr>
    <form method="post">
      <td><input type="number" name="class_id" required></td>
      <td><input type="number" name="section_id" required></td>
      <td><input type="text" name="faculty_name" required></td>
      <td><input type="number" name="enrollment_limit" required></td>
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
        String insertSQL = "INSERT INTO section (class_id, section_id, faculty_name, enrollment_limit) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertSQL);
        pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
        pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
        pstmt.setString(3, request.getParameter("faculty_name"));
        pstmt.setInt(4, Integer.parseInt(request.getParameter("enrollment_limit")));
        pstmt.executeUpdate();
      }

      if ("update".equals(action)) {
        String updateSQL = "UPDATE section SET faculty_name = ?, enrollment_limit = ? WHERE class_id = ? AND section_id = ?";
        pstmt = conn.prepareStatement(updateSQL);
        pstmt.setString(1, request.getParameter("faculty_name"));
        pstmt.setInt(2, Integer.parseInt(request.getParameter("enrollment_limit")));
        pstmt.setInt(3, Integer.parseInt(request.getParameter("class_id")));
        pstmt.setInt(4, Integer.parseInt(request.getParameter("section_id")));
        pstmt.executeUpdate();
      }

      if ("delete".equals(action)) {
        String deleteSQL = "DELETE FROM section WHERE class_id = ? AND section_id = ?";
        pstmt = conn.prepareStatement(deleteSQL);
        pstmt.setInt(1, Integer.parseInt(request.getParameter("class_id")));
        pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
        pstmt.executeUpdate();
      }

      conn.commit();
      conn.setAutoCommit(true);

      String selectSQL = "SELECT class_id, section_id, faculty_name, enrollment_limit FROM section ORDER BY class_id, section_id";
      pstmt = conn.prepareStatement(selectSQL);
      rs = pstmt.executeQuery();
      while (rs.next()) {
        int classId = rs.getInt("class_id");
        int sectionId = rs.getInt("section_id");
        String facultyName = rs.getString("faculty_name");
        int enrollmentLimit = rs.getInt("enrollment_limit");
  %>
  <tr>
    <form method="post">
      <td><%= classId %></td>
      <td><%= sectionId %></td>
      <td><input type="text" name="faculty_name" value="<%= facultyName %>" required></td>
      <td><input type="number" name="enrollment_limit" value="<%= enrollmentLimit %>" required></td>
      <td>
        <input type="submit" value="Update">
        <input type="button" value="Delete" onclick="submitDeleteForm(<%= classId %>, <%= sectionId %>);">

        <input type="hidden" name="action" value="update">
        <input type="hidden" name="class_id" value="<%= classId %>">
        <input type="hidden" name="section_id" value="<%= sectionId %>">
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
