<%@ page import="java.sql.*" %>
<h2>Lista de Livros</h2>
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/biblioteca", "root", "");
        PreparedStatement stmt = conn.prepareStatement("SELECT * FROM livros");
        ResultSet rs = stmt.executeQuery();
%>
<table border="1">
    <tr><th>ID</th><th>Título</th><th>Autor</th><th>Ano</th></tr>
    <%
        while(rs.next()){
    %>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("titulo") %></td>
        <td><%= rs.getString("autor") %></td>
        <td><%= rs.getInt("ano") %></td>
    </tr>
    <% } %>
</table>
<%
    } catch(Exception e){
        out.print("Erro: " + e.getMessage());
    }
%>
