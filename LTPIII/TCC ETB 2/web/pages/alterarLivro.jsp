<%@ page import="java.sql.*" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    String titulo = request.getParameter("titulo");
    String autor = request.getParameter("autor");
    int ano = Integer.parseInt(request.getParameter("ano"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "Admin");
    PreparedStatement stmt = conn.prepareStatement("UPDATE livros SET titulo=?, autor=?, ano=? WHERE id=?");
    stmt.setString(1, titulo);
    stmt.setString(2, autor);
    stmt.setInt(3, ano);
    stmt.setInt(4, id);
    stmt.executeUpdate();

    out.print("Livro alterado com sucesso!");
%>
