<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    String usuarioEmail = (String) session.getAttribute("usuarioEmail");

    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String horarioAgendado = "Nenhum horário agendado.";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

        String sql = "SELECT horario FROM agendamentos WHERE usuario_id = ? ORDER BY horario DESC LIMIT 1";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, usuarioId);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            horarioAgendado = rs.getString("horario");
        }

        rs.close();
        stmt.close();
        conexao.close();
    } catch (Exception e) {
        horarioAgendado = "Erro: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meu Agendamento</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Olá, <%= usuarioEmail %></h2>
    <p><strong>Seu último horário agendado:</strong></p>
    <div class="alert alert-success"><%= horarioAgendado %></div>
    <a href="painel.jsp" class="btn btn-secondary">Voltar ao Painel</a>
</div>
</body>
</html>
