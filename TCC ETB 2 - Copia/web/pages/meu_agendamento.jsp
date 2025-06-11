<%@ page import="java.sql.*, java.util.*" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> agendamentos = new ArrayList<String>();
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
        PreparedStatement stmt = conexao.prepareStatement("SELECT id, horario FROM agendamentos WHERE usuario_id = ? ORDER BY horario DESC");
        stmt.setInt(1, usuarioId);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            agendamentos.add(rs.getString("horario") + "," + rs.getInt("id"));
        }
        rs.close();
        stmt.close();
        conexao.close();
    } catch (Exception e) {
        out.println("Erro: " + e.getMessage());
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Meus Agendamentos - Leleo Tattoo</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="../styles/painel.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="container my-5">
        <h2 class="text-center mb-4">Meus Agendamentos</h2>

        <% if (agendamentos.isEmpty()) { %>
            <div class="alert alert-warning">Você não possui agendamentos.</div>
        <% } else { %>
            <ul class="list-group">
                <% for (String agendamento : agendamentos) { 
                    String[] detalhes = agendamento.split(",");
                    String horario = detalhes[0];
                    int agendamentoId = Integer.parseInt(detalhes[1]);
                %>
                    <li class="list-group-item d-flex justify-content-between align-items-center">
                        <div>
                            <strong><i class="fas fa-calendar-check me-2"></i><%= horario %></strong>
                        </div>
                        <div class="btn-group">

                            <!-- Botão Cancelar -->
                            <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#cancelarModal<%= agendamentoId %>">
                                Cancelar
                            </button>
                        </div>

                        <!-- Modal de Cancelamento -->
                        <div class="modal fade" id="cancelarModal<%= agendamentoId %>" tabindex="-1" aria-labelledby="cancelarModalLabel" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="cancelarModalLabel">Cancelar Agendamento</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
                                    </div>
                                    <div class="modal-body">
                                        <p>Atenção! Deseja realmente cancelar este agendamento?</p>
                                        <p><strong>Cancelamentos feitos com menos de 24 horas de antecedência podem ser penalizados. Caso o cliente queira cancelar, será cobrada uma taxa de 25% do valor do serviço, ou uma nova marcação poderá ser mais difícil devido a alta demanda.</strong></p>
                                    </div>
                                    <div class="modal-footer">
                                        <form method="post" action="./cancelar_agendamento.jsp">
                                            <input type="hidden" name="agendamentoId" value="<%= agendamentoId %>">
                                            <button type="submit" class="btn btn-danger">Confirmar Cancelamento</button>
                                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Fechar</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </li>
                <% } %>
            </ul>
        <% } %>

        <br>
        <a href="painel.jsp" class="btn btn-secondary">Voltar</a>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
