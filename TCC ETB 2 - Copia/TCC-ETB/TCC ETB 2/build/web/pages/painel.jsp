<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Checa se o usuário está logado
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    String usuarioEmail = (String) session.getAttribute("usuarioEmail");
    String mensagem = "";

    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Agendamento
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("horario") != null) {
        String horarioStr = request.getParameter("horario");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

            // Checa se o horário já está ocupado
            String checkSql = "SELECT * FROM agendamentos WHERE horario = ?";
            PreparedStatement checkStmt = conexao.prepareStatement(checkSql);
            checkStmt.setString(1, horarioStr);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                mensagem = "Horário já foi agendado por outra pessoa.";
            } else {
                String sql = "INSERT INTO agendamentos (usuario_id, horario) VALUES (?, ?)";
                PreparedStatement stmt = conexao.prepareStatement(sql);
                stmt.setInt(1, usuarioId);
                stmt.setString(2, horarioStr);
                stmt.executeUpdate();
                mensagem = "Agendamento realizado com sucesso!";
                stmt.close();
            }

            rs.close();
            checkStmt.close();
            conexao.close();
        } catch (Exception e) {
            mensagem = "Erro ao agendar: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Painel do Cliente - Leleo Tattoo</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="../styles/painel.css">
</head>
<body>
<div class="container animate__animated animate__fadeIn">
    <!-- Botão de voltar -->
    <a href="../index.html" class="btn btn-secondary back-button animate__animated animate__fadeInLeft">
        <i class="fas fa-arrow-left me-2"></i>Voltar ao Menu
    </a>
    
    <div class="welcome-card p-4 text-center animate__animated animate__fadeInDown">
        <h2><i class="fas fa-user-circle me-2"></i>Bem-vindo!</h2>
        <p class="mb-0">Gerencie seus agendamentos aqui</p>
    </div>
    
    <% if (!mensagem.isEmpty()) { %>
        <div class="alert alert-info animate__animated animate__bounceIn"><%= mensagem %></div>
    <% } %>

    <div class="schedule-card animate__animated animate__fadeInUp">
        <div class="text-center mb-4">
            <div class="calendar-icon floating">
                <i class="fas fa-calendar-alt"></i>
            </div>
            <h3>Agendar Novo Horário</h3>
            <p class="text-muted">Escolha uma data e horário disponíveis</p>
        </div>
        
        <div class="mb-4">
            <div class="step">
                <div class="step-number">1</div>
                <div>Selecione a data e horário desejados</div>
            </div>
            <div class="step">
                <div class="step-number">2</div>
                <div>Confirme sua escolha</div>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <div>Pronto! Seu agendamento será confirmado</div>
            </div>
        </div>
        
        <form method="post">
            <div class="mb-3">
                <label for="horario" class="form-label">Data e Horário:</label>
                <input type="datetime-local" name="horario" id="horario" class="form-control" required>
            </div>
            <div class="text-center">
                <button type="submit" class="btn btn-primary pulse">
                    <i class="fas fa-calendar-check me-2"></i>Confirmar Agendamento
                </button>
            </div>
        </form>
    </div>

    <div class="text-center">
        <form action="meu_agendamento.jsp" method="get">
            <button type="submit" class="btn btn-secondary">
                <i class="fas fa-list-alt me-2"></i>Ver Meus Agendamentos
            </button>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Adiciona animação quando o campo de data/horário recebe foco
    document.getElementById('horario').addEventListener('focus', function() {
        this.classList.add('animate__animated', 'animate__pulse');
    });
    
    document.getElementById('horario').addEventListener('blur', function() {
        this.classList.remove('animate__animated', 'animate__pulse');
    });
    
    // Remove a mensagem após 5 segundos
    setTimeout(function() {
        var alert = document.querySelector('.alert');
        if (alert) {
            alert.classList.add('animate__animated', 'animate__fadeOut');
            setTimeout(function() {
                alert.remove();
            }, 1000);
        }
    }, 5000);
</script>
</body>
</html>