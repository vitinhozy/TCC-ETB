<%@ page import="java.sql.*" %>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
    PreparedStatement stmt = conn.prepareStatement("SELECT * FROM livros WHERE id = ?");
    stmt.setInt(1, id);
    ResultSet rs = stmt.executeQuery();

    if (!rs.next()) {
        out.print("Livro não encontrado.");
    } else {
%>
    <form method="post" action="alterarLivro.jsp">
        <input type="hidden" name="id" value="<%= rs.getInt("id") %>">
        <p><label>Título:</label><input type="text" name="titulo" value="<%= rs.getString("titulo") %>"></p>
        <p><label>Autor:</label><input type="text" name="autor" value="<%= rs.getString("autor") %>"></p>
        <p><label>Ano:</label><input type="number" name="ano" value="<%= rs.getInt("ano") %>"></p>
        <input type="submit" value="Salvar Alterações">
    </form>
<% } %>
