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

                // Verifica se o email já está cadastrado
                String checkSql = "SELECT * FROM usuarios WHERE email = ?";
                PreparedStatement checkStmt = conexao.prepareStatement(checkSql);
                checkStmt.setString(1, email);
                ResultSet rs = checkStmt.executeQuery();

                if (rs.next()) {
                    mensagem = "Email já cadastrado!";
                } else {
                    String sql = "INSERT INTO usuarios (email, senha) VALUES (?, ?)";
                    PreparedStatement stmt = conexao.prepareStatement(sql);
                    stmt.setString(1, email);
                    stmt.setString(2, senha);
                    stmt.executeUpdate();
                    mensagem = "Cadastro realizado com sucesso!";
                    stmt.close();
                }

                rs.close();
                checkStmt.close();
                conexao.close();
            } catch (Exception e) {
                mensagem = "Erro ao cadastrar: " + e.getMessage();
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
    <title>CADASTRO - Leleo Tattoo</title>
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
                        <li class="nav-item"><a class="nav-link" href="login.jsp">LOGIN</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </header>

    <main class="mt-5 pt-5">
        <div class="container">
            <div class="form-container animated-form">
                <h2 class="form-title">CRIAR CONTA</h2>
                <% if (!mensagem.isEmpty()) { %>
                    <div class="alert alert-info"><%= mensagem %></div>
                <% } %>
                <form method="post">
                    <div class="mb-3">
                        <input type="email" name="email" class="form-control" placeholder="Email" required>
                    </div>
                    <div class="mb-3">
                        <input type="password" name="senha" class="form-control" id="password" placeholder="Senha" required>
                        <div class="password-strength mt-2">
                            <div class="strength-bar" id="passwordStrength"></div>
                        </div>
                        <small id="passwordHelp" class="form-text text-muted">A senha deve ter pelo menos 6 caracteres.</small>
                    </div>
                    <div class="mb-3">
                        <input type="password" class="form-control" id="confirmPassword" placeholder="Confirmar Senha" required>
                        <small id="confirmHelp" class="form-text text-muted"></small>
                    </div>
                    <button type="submit" class="btn btn-custom">CADASTRAR</button>
                </form>
                <div class="form-footer mt-3">
                    Já tem uma conta? <a href="login.jsp">Faça login</a>
                </div>
            </div>
        </div>
    </main>

    <footer class="custom-footer mt-5">
        <div class="footer-content">
            <div class="footer-line">TODOS OS DIREITOS RESERVADOS &copy; LELEO TATTOO</div>
        </div>
    </footer>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.querySelector("form");
            const passwordInput = document.getElementById('password');
            const confirmPasswordInput = document.getElementById('confirmPassword');
            const passwordStrength = document.getElementById('passwordStrength');
            const passwordHelp = document.getElementById('passwordHelp');
            const confirmHelp = document.getElementById('confirmHelp');

            passwordInput.addEventListener('input', function() {
                const password = this.value;
                let strength = 0;

                if (password.length >= 6) strength++;
                if (password.match(/[a-z]/) && password.match(/[A-Z]/)) strength++;
                if (password.match(/[0-9]/)) strength++;
                if (password.match(/[^a-zA-Z0-9]/)) strength++;

                let width = 0;
                let color = '#dc3545';

                if (strength === 1) {
                    width = 25; color = '#dc3545'; passwordHelp.textContent = 'Senha fraca';
                } else if (strength === 2) {
                    width = 50; color = '#fd7e14'; passwordHelp.textContent = 'Senha moderada';
                } else if (strength === 3) {
                    width = 75; color = '#ffc107'; passwordHelp.textContent = 'Senha boa';
                } else if (strength >= 4) {
                    width = 100; color = '#28a745'; passwordHelp.textContent = 'Senha forte';
                }

                passwordStrength.style.width = width + '%';
                passwordStrength.style.backgroundColor = color;
            });

            confirmPasswordInput.addEventListener('input', function() {
                if (this.value !== passwordInput.value) {
                    confirmHelp.textContent = 'As senhas não coincidem!';
                    confirmHelp.style.color = '#dc3545';
                } else {
                    confirmHelp.textContent = 'As senhas coincidem!';
                    confirmHelp.style.color = '#28a745';
                }
            });

            form.addEventListener('submit', function(e) {
                if (passwordInput.value !== confirmPasswordInput.value || passwordInput.value.length < 6) {
                    e.preventDefault();
                    alert("Verifique os campos de senha.");
                }
            });
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
