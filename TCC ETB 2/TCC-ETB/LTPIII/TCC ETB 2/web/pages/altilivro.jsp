<%@ page import="java.sql.*" %>
<%
    String status = "";
    int id = 0;
    String titulo = "", autor = "";
    int ano = 0;
    boolean encontrado = false;

    if (request.getParameter("buscar") != null) {
        id = Integer.parseInt(request.getParameter("id"));
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM livros WHERE id = ?");
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            encontrado = true;
            titulo = rs.getString("titulo");
            autor = rs.getString("autor");
            ano = rs.getInt("ano");
        } else {
            status = "Livro não encontrado.";
        }
    }

    if (request.getParameter("salvar") != null) {
        id = Integer.parseInt(request.getParameter("id"));
        titulo = request.getParameter("titulo");
        autor = request.getParameter("autor");
        ano = Integer.parseInt(request.getParameter("ano"));

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
        PreparedStatement stmt = conn.prepareStatement("UPDATE livros SET titulo=?, autor=?, ano=? WHERE id=?");
        stmt.setString(1, titulo);
        stmt.setString(2, autor);
        stmt.setInt(3, ano);
        stmt.setInt(4, id);
        stmt.executeUpdate();
        status = "Livro alterado com sucesso!";
        encontrado = false;
    }
%>

<h2>Alterar Livro</h2>
<form method="get">
    <label>ID do livro:</label>
    <input type="number" name="id" value="<%= id %>" required>
    <input type="submit" name="buscar" value="Buscar">
</form>

<% if(encontrado) { %>
<form method="post">
    <input type="hidden" name="id" value="<%= id %>">
    <p><label>Título:</label><input type="text" name="titulo" value="<%= titulo %>"></p>
    <p><label>Autor:</label><input type="text" name="autor" value="<%= autor %>"></p>
    <p><label>Ano:</label><input type="number" name="ano" value="<%= ano %>"></p>
    <input type="submit" name="salvar" value="Salvar Alterações">
</form>
<% } %>

<p><
