<%@ page import="java.sql.*" %>
<%
    String msg = "";
    if(request.getParameter("id") != null){
        try {
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
            msg = "Livro cadastrado com sucesso!";
        } catch(Exception e) {
            msg = "Erro ao cadastrar livro: " + e.getMessage();
        }
    }
%>
<h2>Cadastrar Livro</h2>
<form method="post">
    <p><label>ID:</label><input type="number" name="id" required></p>
    <p><label>Título:</label><input type="text" name="titulo" required></p>
    <p><label>Autor:</label><input type="text" name="autor"></p>
    <p><label>Ano:</label><input type="number" name="ano"></p>
    <input type="submit" value="Salvar">
</form>
<p><strong><%= msg %></strong></p>
