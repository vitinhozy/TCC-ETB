<%@ page import="java.sql.*" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "Admin");
    PreparedStatement stmt = conn.prepareStatement("DELETE FROM livros WHERE id = ?");
    stmt.setInt(1, id);
    int res = stmt.executeUpdate();

    if (res == 0) {
        out.print("Livro não encontrado.");
    } else {
        out.print("Livro excluído com sucesso.");
    }
%>
