<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mensagem = "";

    // Cancelar agendamento
    if (request.getParameter("cancelarId") != null) {
        int idCancelar = Integer.parseInt(request.getParameter("cancelarId"));
        try {
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
            PreparedStatement stmt = con.prepareStatement("DELETE FROM agendamentos WHERE id = ? AND usuario_id = ?");
            stmt.setInt(1, idCancelar);
            stmt.setInt(2, usuarioId);
            stmt.executeUpdate();
            mensagem = "Agendamento cancelado com sucesso!";
            stmt.close();
            con.close();
        } catch (Exception e) {
            mensagem = "Erro ao cancelar: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Meus Agendamentos</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="mb-4">Meus Agendamentos</h2>
    
    <% if (!mensagem.isEmpty()) { %>
        <div class="alert alert-info"><%= mensagem %></div>
    <% } %>

    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Data e Horário</th>
                <th>Ações</th>
            </tr>
        </thead>
        <tbody>
            <%
                try {
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
                    PreparedStatement stmt = con.prepareStatement("SELECT * FROM agendamentos WHERE usuario_id = ?");
                    stmt.setInt(1, usuarioId);
                    ResultSet rs = stmt.executeQuery();
                    while (rs.next()) {
                        int agendamentoId = rs.getInt("id");
                        String horario = rs.getString("horario");
            %>
                <tr>
                    <td><%= horario %></td>
                    <td>
                        <a href="editar_agendamento.jsp?id=<%= agendamentoId %>" class="btn btn-warning btn-sm">Editar</a>
                        <a href="meu_agendamento.jsp?cancelarId=<%= agendamentoId %>" class="btn btn-danger btn-sm" onclick="return confirm('Deseja realmente cancelar?')">Cancelar</a>
                    </td>
                </tr>
            <%
                    }
                    rs.close();
                    stmt.close();
                    con.close();
                } catch (Exception e) {
                    out.print("Erro: " + e.getMessage());
                }
            %>
        </tbody>
    </table>

    <a href="painel.jsp" class="btn btn-secondary">Voltar</a>
</div>
</body>
</html>
