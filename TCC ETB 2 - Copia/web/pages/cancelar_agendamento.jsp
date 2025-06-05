<%@ page import="java.sql.*" %>
<%
    // Verifica��o de login
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = "";
    String agendamentoIdStr = request.getParameter("agendamentoId");

    if (agendamentoIdStr != null && !agendamentoIdStr.isEmpty()) {
        int agendamentoId = Integer.parseInt(agendamentoIdStr);

        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

            // Apenas cancela o agendamento se ele for do usu�rio logado (seguran�a extra)
            stmt = conn.prepareStatement("DELETE FROM agendamentos WHERE id = ? AND usuario_id = ?");
            stmt.setInt(1, agendamentoId);
            stmt.setInt(2, usuarioId);

            int linhasAfetadas = stmt.executeUpdate();

            if (linhasAfetadas > 0) {
                msg = "Agendamento cancelado com sucesso.";
            } else {
                msg = "Agendamento n�o encontrado ou n�o pertence ao usu�rio.";
            }

        } catch (Exception e) {
            msg = "Erro ao cancelar agendamento: " + e.getMessage();
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } else {
        msg = "ID do agendamento inv�lido.";
    }

    // Redirecionar com mensagem opcional
    response.sendRedirect("meus_agendamentos.jsp?msg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
%>
