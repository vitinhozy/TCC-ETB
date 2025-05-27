<%@ page import="java.sql.*, java.util.*, java.time.*, java.time.format.*" %>
<%
    Integer usuarioId = (Integer) session.getAttribute("usuarioId");
    String email = (String) session.getAttribute("usuarioEmail");
    String nome = (String) session.getAttribute("usuarioNome");

    if (usuarioId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Vari?veis para mensagens de feedback
    String mensagemFeedback = (String) session.getAttribute("mensagemFeedback");
    String tipoMensagem = (String) session.getAttribute("tipoMensagem");

    // Limpa as mensagens da sess?o para n?o mostrar novamente ao atualizar
    session.removeAttribute("mensagemFeedback");
    session.removeAttribute("tipoMensagem");

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String dataSelecionadaPost = request.getParameter("dataSelecionada");
        String horarioSelecionado = request.getParameter("horarioSelecionado");

        if (dataSelecionadaPost != null && horarioSelecionado != null && !dataSelecionadaPost.isEmpty() && !horarioSelecionado.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

                // Verifica se o hor?rio ainda est? dispon?vel
                PreparedStatement verificaStmt = conexao.prepareStatement("SELECT COUNT(*) FROM agendamentos WHERE horario = ?");
                verificaStmt.setString(1, dataSelecionadaPost + " " + horarioSelecionado + ":00");
                ResultSet rsVerifica = verificaStmt.executeQuery();
                boolean horarioDisponivel = true;
                if (rsVerifica.next()) {
                    int count = rsVerifica.getInt(1);
                    if (count > 0) {
                        horarioDisponivel = false;
                    }
                }
                rsVerifica.close();
                verificaStmt.close();

                if (horarioDisponivel) {
                    // Verifica se o usu?rio j? agendou esse hor?rio
                    PreparedStatement verificaUsuarioHorarioStmt = conexao.prepareStatement(
                        "SELECT COUNT(*) FROM agendamentos WHERE usuario_id = ? AND horario = ?");
                    verificaUsuarioHorarioStmt.setInt(1, usuarioId);
                    verificaUsuarioHorarioStmt.setString(2, dataSelecionadaPost + " " + horarioSelecionado + ":00");
                    ResultSet rsUsuarioHorario = verificaUsuarioHorarioStmt.executeQuery();
                    boolean jaAgendadoPeloUsuario = false;
                    if (rsUsuarioHorario.next()) {
                        int count = rsUsuarioHorario.getInt(1);
                        if (count > 0) {
                            jaAgendadoPeloUsuario = true;
                        }
                    }
                    rsUsuarioHorario.close();
                    verificaUsuarioHorarioStmt.close();

                    if (jaAgendadoPeloUsuario) {
                        session.setAttribute("mensagemFeedback", "Voc? j? possui um agendamento neste hor?rio.");
                        session.setAttribute("tipoMensagem", "warning");
                    } else {
                        // Inserir o agendamento
                        PreparedStatement stmt = conexao.prepareStatement("INSERT INTO agendamentos (usuario_id, horario) VALUES (?, ?)");
                        stmt.setInt(1, usuarioId);
                        stmt.setString(2, dataSelecionadaPost + " " + horarioSelecionado + ":00");
                        stmt.executeUpdate();
                        stmt.close();

                        session.setAttribute("mensagemFeedback", "Agendamento confirmado para " + dataSelecionadaPost + " ?s " + horarioSelecionado + ".");
                        session.setAttribute("tipoMensagem", "success");
                    }
                } else {
                    session.setAttribute("mensagemFeedback", "O hor?rio selecionado j? est? reservado. Por favor, escolha outro hor?rio.");
                    session.setAttribute("tipoMensagem", "danger");
                }

                conexao.close();
                response.sendRedirect("painel.jsp");
                return;

            } catch (Exception e) {
                session.setAttribute("mensagemFeedback", "Erro ao confirmar agendamento: " + e.getMessage());
                session.setAttribute("tipoMensagem", "danger");
                response.sendRedirect("painel.jsp");
                return;
            }
        } else {
            session.setAttribute("mensagemFeedback", "Data ou hor?rio n?o selecionados.");
            session.setAttribute("tipoMensagem", "warning");
            response.sendRedirect("painel.jsp");
            return;
        }
    }

    // Pegar pontos do usu?rio
    int pontos = 0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
        PreparedStatement stmt = conexao.prepareStatement("SELECT pontos FROM usuarios WHERE id = ?");
        stmt.setInt(1, usuarioId);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            pontos = rs.getInt("pontos");
        }
        rs.close();
        stmt.close();
        conexao.close();
    } catch (Exception e) {
        out.println("Erro ao buscar pontos: " + e.getMessage());
    }

    // Verifica se o usu?rio selecionou uma data para buscar hor?rios dispon?veis (GET)
    String dataSelecionada = request.getParameter("dataSelecionada");
    List<String> horariosDoDia = new ArrayList<String>();

    if (dataSelecionada != null && !dataSelecionada.isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conexao = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

            // Buscar todos os hor?rios dispon?veis da data
            PreparedStatement stmt = conexao.prepareStatement(
                "SELECT horario FROM horarios_disponiveis WHERE DATE(horario) = ?"
            );
            stmt.setString(1, dataSelecionada);
            ResultSet rs = stmt.executeQuery();

            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("HH:mm");

            // Buscar todos os hor?rios j? agendados da mesma data
            PreparedStatement agendadosStmt = conexao.prepareStatement(
                "SELECT horario FROM agendamentos WHERE DATE(horario) = ?"
            );
            agendadosStmt.setString(1, dataSelecionada);
            ResultSet rsAgendados = agendadosStmt.executeQuery();

            Set<String> horariosAgendados = new HashSet<String>();
            while (rsAgendados.next()) {
                Timestamp horarioAgendado = rsAgendados.getTimestamp("horario");
                horariosAgendados.add(sdf.format(horarioAgendado));
            }
            rsAgendados.close();
            agendadosStmt.close();

            // Adicionar ? lista somente os hor?rios livres
            while (rs.next()) {
                Timestamp horario = rs.getTimestamp("horario");
                String horarioFormatado = sdf.format(horario);

                if (!horariosAgendados.contains(horarioFormatado)) {
                    horariosDoDia.add(horarioFormatado);
                }
            }
            rs.close();
            stmt.close();
            conexao.close();
        } catch (Exception e) {
            out.println("Erro ao buscar hor?rios: " + e.getMessage());
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
    <a href="../index.html" class="btn btn-secondary back-button animate__animated animate__fadeInLeft">
        <i class="fas fa-arrow-left me-2"></i>Voltar ao Menu
    </a>
    <div class="text-center mt-4">
    <a href="./meu_agendamento.jsp" class="btn btn-info">
        <i class="fas fa-calendar-check me-2"></i>Verificar meus agendamentos
    </a>
</div>
    <div class="welcome-card p-4 text-center animate__animated animate__fadeInDown">
        <h2><i class="fas fa-user-circle me-2"></i>Bem-vindo!</h2>
        <p class="mb-0">Gerencie seus agendamentos aqui</p>
    </div>

    <% if (mensagemFeedback != null && !mensagemFeedback.isEmpty()) { %>
        <div class="alert alert-<%= tipoMensagem %> animate__animated animate__fadeIn">
            <%= mensagemFeedback %>
        </div>
    <% } %>

    <div class="schedule-card animate__animated animate__fadeInUp">
        <div class="text-center mb-4">
            <div class="calendar-icon floating">
                <i class="fas fa-calendar-alt"></i>
            </div>
            <h3>Agendar Novo Hor?rio</h3>
            <p class="text-muted">Escolha uma data e verifique se está disponível</p>
        </div>

        <div class="mb-4">
            <div class="step">
                <div class="step-number">1</div>
                <div>Selecione a data desejada</div>
            </div>
            <div class="step">
                <div class="step-number">2</div>
                <div>Confirme sua escolha</div>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <div>E verifique se est? dispon?vel</div>
            </div>
        </div>

        <div class="container">
            <div class="card animate__animated animate__fadeIn">
                <div class="card-body">
                    <hr>

                    <h4>Verificar datas dispon?veis</h4>
                    <form method="get" action="painel.jsp" class="mb-3">
                        <input type="date" name="dataSelecionada" class="form-control" required>
                        <button type="submit" class="btn btn-primary mt-2">Buscar datas</button>
                    </form>

                    <% if (dataSelecionada != null && !dataSelecionada.isEmpty()) { %>
                        <hr>
                        <h5>Datas dispon?veis para <%= dataSelecionada %>:</h5>
                        <% if (horariosDoDia.isEmpty()) { %>
                            <div class="alert alert-warning mt-2">Nenhuma data para este dia.</div>
                        <% } else { %>
                            <form method="post" action="painel.jsp">
                                <input type="hidden" name="dataSelecionada" value="<%= dataSelecionada %>">
                                <ul class="list-group mt-2">
                                    <% for (String horario : horariosDoDia) { %>
                                        <li class="list-group-item">
                                            <label>
                                                <input type="radio" name="horarioSelecionado" value="<%= horario %>" required>
                                                <i class="fas fa-clock me-2"></i><%= horario %>
                                            </label>
                                        </li>
                                    <% } %>
                                </ul>
                                <button type="submit" class="btn btn-success mt-3">Confirmar Agendamento</button>
                            </form>
                        <% } %>
                    <% } %>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.5/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var horarioInput = document.querySelector('input[name="dataSelecionada"]');
    if (horarioInput) {
        horarioInput.addEventListener('focus', function() {
            this.classList.add('animate__animated', 'animate__pulse');
        });
        horarioInput.addEventListener('blur', function() {
            this.classList.remove('animate__animated', 'animate__pulse');
        });
    }

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
