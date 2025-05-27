<%@ page import="java.sql.*" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    String titulo = request.getParameter("titulo");
    String autor = request.getParameter("autor");
    int ano = Integer.parseInt(request.getParameter("ano"));

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
    PreparedStatement stmt = conn.prepareStatement("INSERT INTO livros VALUES (?, ?, ?, ?)");
    stmt.setInt(1, id);
    stmt.setString(2, titulo);
    stmt.setString(3, autor);
    stmt.setInt(4, ano);
    stmt.executeUpdate();

    out.print("Livro cadastrado com sucesso!");
%>
