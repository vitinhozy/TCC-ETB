<%@ page import="java.sql.*, java.util.*" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> agendamentos = new ArrayList<>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
        PreparedStatement stmt = conexao.prepareStatement("SELECT horario FROM agendamentos WHERE usuario_id = ? ORDER BY horario DESC");
        stmt.setInt(1, usuarioId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            agendamentos.add(rs.getString("horario"));
        }
        rs.close();
        stmt.close();
        conexao.close();
    } catch (Exception e) {
        out.println("Erro: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meus Agendamentos</title>
    <link rel="stylesheet" href="../styles/painel.css">
</head>
<body>
<div class="container">
    <h2>Meus Agendamentos</h2>
    <ul class="list-group">
        <% for (String h : agendamentos) { %>
            <li class="list-group-item agendamento-item"><%= h %></li>
        <% } %>
    </ul>
    <br>
    <a href="painel.jsp" class="btn btn-secondary">Voltar</a>
</div>
</body>
</html>
