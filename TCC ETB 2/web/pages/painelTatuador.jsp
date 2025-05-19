<%@ page import="java.sql.*, java.util.*" %>
<%
    String email = (String) session.getAttribute("usuarioEmail");
    if (email == null || !email.equals("tatuador@leleo.com")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = "";
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("novoHorario") != null) {
        String novoHorario = request.getParameter("novoHorario");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
            PreparedStatement stmt = conn.prepareStatement("INSERT INTO horarios_disponiveis (horario) VALUES (?)");
            stmt.setString(1, novoHorario);
            stmt.executeUpdate();
            stmt.close();
            conn.close();
            msg = "Horário adicionado!";
        } catch (Exception e) {
            msg = "Erro: " + e.getMessage();
        }
    }
%>
<html>
<head>
    <title>Painel do Tatuador</title>
    <link rel="stylesheet" href="../styles/painel.css">
</head>
<body>
<div class="container">
    <h2>Painel do Tatuador</h2>
    <% if (!msg.isEmpty()) { %><div class="alert alert-info"><%= msg %></div><% } %>
    <form method="post">
        <label for="novoHorario">Novo horário disponível:</label>
        <input type="datetime-local" name="novoHorario" required class="form-control">
        <button type="submit" class="btn btn-primary mt-2">Salvar</button>
    </form>
</div>
</body>
</html>
