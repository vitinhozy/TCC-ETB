<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String mensagem = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String email = request.getParameter("email");
        String senha = request.getParameter("senha");

        if (email != null && senha != null && !email.isEmpty() && !senha.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

                String sql = "SELECT * FROM usuarios WHERE email = ? AND senha = ?";
                PreparedStatement stmt = conexao.prepareStatement(sql);
                stmt.setString(1, email);
                stmt.setString(2, senha);
                ResultSet rs = stmt.executeQuery();

                if (rs.next()) {
                    mensagem = "Login realizado com sucesso! Bem-vindo, " + email;
                    session.setAttribute("usuarioId", rs.getInt("id"));
                    session.setAttribute("usuarioEmail", rs.getString("email"));        

                    // Verifica se é o tatuador/admin para redirecionar corretamente
                    if ("tatuador@leleo.com".equalsIgnoreCase(email)) {
                        response.sendRedirect("painelTatuador.jsp");
                    } else {
                        response.sendRedirect("painel.jsp");
                    }
                    return;  // Para garantir que não continue processando o restante da página
                } else {
                    mensagem = "E-mail ou senha inválidos.";
                }

                rs.close();
                stmt.close();
                conexao.close();
            } catch (Exception e) {
                mensagem = "Erro ao fazer login: " + e.getMessage();
            }
        } else {
            mensagem = "Preencha todos os campos!";
        }
    }
%>

<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>LOGIN - Leleo Tattoo</title>
    <link rel="stylesheet" href="../styles/index.css">
    <link rel="stylesheet" href="../styles/cadastro.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <header>
        <nav class="navbar navbar-expand-lg custom-navbar fixed-top">
            <div class="container">
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav mx-auto">
                        <li class="nav-item"><a class="nav-link" href="../index.html">INÍCIO</a></li>
                        <li class="nav-item"><a class="nav-link" href="catalogo.html">CATÁLOGO</a></li>
                        <li class="nav-item"><a class="nav-link" href="cuidadosTattoo.html">CUIDADOS COM A TATTOO</a></li>
                        <li class="nav-item"><a class="nav-link" href="sobreMim.html">SOBRE MIM</a></li>
                        <li class="nav-item"><a class="nav-link" href="cadastro.jsp">CADASTRO</a></li>
                        <li class="nav-item"><a class="nav-link active" href="login.jsp">LOGIN</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <main class="mt-5 pt-5">
        <div class="container">
            <div class="form-container animated-form">
                <h2 class="form-title">ENTRAR NA SUA CONTA</h2>
                <% if (!mensagem.isEmpty()) { %>
                    <div class="alert alert-info"><%= mensagem %></div>
                <% } %>
                <form method="post">
                    <div class="mb-3">
                        <input type="email" name="email" class="form-control" placeholder="E-mail" required>
                    </div>
                    <div class="mb-3">
                        <input type="password" name="senha" class="form-control" placeholder="Senha" required>
                    </div>
                    <button type="submit" class="btn btn-custom">ENTRAR</button>
                </form>
                <div class="form-footer mt-3">
                    Ainda não tem conta? <a href="cadastro.jsp">Cadastre-se</a>
                </div>
            </div>
        </div>
    </main>

    <footer class="custom-footer mt-5">
        <div class="footer-content">
            <div class="footer-line">TODOS OS DIREITOS RESERVADOS &copy; LELEO TATTOO</div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
