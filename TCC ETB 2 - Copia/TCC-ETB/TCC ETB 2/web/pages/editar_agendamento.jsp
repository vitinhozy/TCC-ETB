<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mensagem = "";
    int agendamentoId = Integer.parseInt(request.getParameter("id"));
    String horarioAtual = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String novoHorario = request.getParameter("novoHorario");
        try {
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
            PreparedStatement stmt = con.prepareStatement("UPDATE agendamentos SET horario = ? WHERE id = ? AND usuario_id = ?");
            stmt.setString(1, novoHorario);
            stmt.setInt(2, agendamentoId);
            stmt.setInt(3, usuarioId);
            stmt.executeUpdate();
            mensagem = "Agendamento atualizado com sucesso!";
            stmt.close();
            con.close();
        } catch (Exception e) {
            mensagem = "Erro ao atualizar: " + e.getMessage();
        }
    }

    try {
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
        PreparedStatement stmt = con.prepareStatement("SELECT horario FROM agendamentos WHERE id = ? AND usuario_id = ?");
        stmt.setInt(1, agendamentoId);
        stmt.setInt(2, usuarioId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            horarioAtual = rs.getString("horario");
        }
        rs.close();
        stmt.close();
        con.close();
    } catch (Exception e) {
        mensagem = "Erro ao carregar horário atual: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Editar Agendamento</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Editar Agendamento</h2>

    <% if (!mensagem.isEmpty()) { %>
        <div class="alert alert-info"><%= mensagem %></div>
    <% } %>

    <form method="post">
        <div class="mb-3">
            <label for="novoHorario" class="form-label">Novo Horário:</label>
            <input type="datetime-local" class="form-control" name="novoHorario" id="novoHorario" value="<%= horarioAtual.replace(" ", "T") %>" required>
        </div>
        <button type="submit" class="btn btn-primary">Salvar Alterações</button>
        <a href="meu_agendamento.jsp" class="btn btn-secondary">Cancelar</a>
    </form>
</div>
</body>
</html>
