<%@ page import="java.sql.*" %>
<%
    String mensagem = "";
    if(request.getParameter("id") != null){
        int id = Integer.parseInt(request.getParameter("id"));
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
        PreparedStatement stmt = conn.prepareStatement("DELETE FROM livros WHERE id = ?");
        stmt.setInt(1, id);
        int res = stmt.executeUpdate();
        mensagem = (res == 0) ? "Livro não encontrado." : "Livro excluído com sucesso.";
    }
%>
<h2>Excluir Livro</h2>
<form method="get">
    <label>ID do livro:</label>
    <input type="number" name="id" required>
    <input type="submit" value="Excluir">
</form>
<p><strong><%= mensagem %></strong></p>
