<%@ page import="java.sql.*" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String agendamentoIdStr = request.getParameter("agendamentoId");
    if (agendamentoIdStr != null) {
        try {
            int agendamentoId = Integer.parseInt(agendamentoIdStr);

            // Conectar ao banco de dados
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

            // Preparar a query para cancelar o agendamento
            PreparedStatement stmt = conexao.prepareStatement("DELETE FROM agendamentos WHERE id = ? AND usuario_id = ?");
            stmt.setInt(1, agendamentoId);
            stmt.setInt(2, usuarioId);
            int rowsAffected = stmt.executeUpdate();

            if (rowsAffected > 0) {
                session.setAttribute("mensagemFeedback", "Agendamento cancelado com sucesso.");
                session.setAttribute("tipoMensagem", "success");
            } else {
                session.setAttribute("mensagemFeedback", "Erro ao cancelar o agendamento.");
                session.setAttribute("tipoMensagem", "danger");
            }

            stmt.close();
            conexao.close();
        } catch (Exception e) {
            session.setAttribute("mensagemFeedback", "Erro: " + e.getMessage());
            session.setAttribute("tipoMensagem", "danger");
        }
    }
    response.sendRedirect("meu_agendamento.jsp");
%>
