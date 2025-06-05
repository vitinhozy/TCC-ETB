<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.sql.*, java.util.*" %>
<%
    // Verificação de login
    String email = (String) session.getAttribute("usuarioEmail");
    if (email == null || !email.equals("tatuador@leleo.com")) {
        response.sendRedirect("login.jsp");
        return;
    }

    String msg = "";
    List<Map<String, String>> horarios = new ArrayList();
    Connection conn = null;
    PreparedStatement stmt = null;
    Statement listStmt = null;
    ResultSet rs = null;

    // Processamento do formulário
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        String novoHorario = request.getParameter("novoHorario");

        try {
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");

            if ("add".equals(action) && novoHorario != null && !novoHorario.isEmpty()) {
                stmt = conn.prepareStatement("INSERT INTO horarios_disponiveis (horario) VALUES (?)");
                stmt.setString(1, novoHorario);
                stmt.executeUpdate();
                msg = "Horário adicionado com sucesso!";
            } else if ("edit".equals(action)) {
                String id = request.getParameter("id");
                stmt = conn.prepareStatement("UPDATE horarios_disponiveis SET horario = ? WHERE id = ?");
                stmt.setString(1, novoHorario);
                stmt.setString(2, id);
                stmt.executeUpdate();
                msg = "Horário atualizado com sucesso!";
            } else if ("delete".equals(action)) {
                String id = request.getParameter("id");
                stmt = conn.prepareStatement("DELETE FROM horarios_disponiveis WHERE id = ?");
                stmt.setString(1, id);
                stmt.executeUpdate();
                msg = "Horário removido com sucesso!";
            }
        } catch (Exception e) {
            msg = "Erro ao processar formulário: " + e.getMessage();
        } finally {
            if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }

    // Carregar horários disponíveis
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/banco_leleo_tattoo", "root", "");
        listStmt = conn.createStatement();
        rs = listStmt.executeQuery("SELECT * FROM horarios_disponiveis ORDER BY horario");

        while (rs.next()) {
            Map<String, String> horario = new HashMap();
            horario.put("id", rs.getString("id"));
            horario.put("horario", rs.getString("horario"));
            horarios.add(horario);
        }
    } catch (Exception e) {
        msg = "Erro ao carregar horários: " + e.getMessage();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (listStmt != null) try { listStmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Painel do Tatuador - Leleo Tattoo</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        :root {
            --primary: #6a1b9a;
            --secondary: #9c27b0;
            --accent: #e91e63;
            --light: #f5f5f5;
            --dark: #333;
            --success: #4caf50;
            --warning: #ff9800;
            --danger: #f44336;
            --gray: #757575;
        }
        
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f9f5ff;
            color: var(--dark);
            line-height: 1.6;
        }
        
        .container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 20px;
        }
        
        header {
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            color: white;
            padding: 20px 0;
            border-radius: 8px 8px 0 0;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            margin-bottom: 30px;
        }
        
        .header-content {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        h2 {
            font-size: 28px;
            font-weight: 600;
        }
        
        .alert {
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
            background-color: #e3f2fd;
            color: #1565c0;
            border-left: 5px solid #2196f3;
        }
        
        .alert.error {
            background-color: #ffebee;
            color: #c62828;
            border-left-color: #f44336;
        }
        
        .alert.success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border-left-color: #4caf50;
        }
        
        .card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.08);
            padding: 25px;
            margin-bottom: 30px;
        }
        
        .card-title {
            font-size: 20px;
            margin-bottom: 20px;
            color: var(--primary);
            font-weight: 500;
            border-bottom: 2px solid #f0e5ff;
            padding-bottom: 10px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--gray);
        }
        
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 16px;
            transition: border 0.3s;
        }
        
        .form-control:focus {
            border-color: var(--secondary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(156, 39, 176, 0.2);
        }
        
        .btn {
            display: inline-block;
            padding: 12px 24px;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 500;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
        }
        
        .btn-primary {
            background-color: var(--primary);
            color: white;
        }
        
        .btn-primary:hover {
            background-color: var(--secondary);
            transform: translateY(-2px);
        }
        
        .btn-secondary {
            background-color: var(--gray);
            color: white;
        }
        
        .btn-secondary:hover {
            background-color: #616161;
        }
        
        .btn-sm {
            padding: 8px 16px;
            font-size: 14px;
        }
        
        .horarios-list {
            margin-top: 30px;
        }
        
        .horario-item {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 15px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .horario-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .horario-info {
            flex: 1;
        }
        
        .horario-data {
            font-size: 18px;
            font-weight: 500;
            color: var(--dark);
        }
        
        .horario-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn-edit {
            background-color: var(--warning);
            color: white;
        }
        
        .btn-delete {
            background-color: var(--danger);
            color: white;
        }
        
        .btn-edit:hover, .btn-delete:hover {
            opacity: 0.9;
        }
        
        .edit-form {
            display: none;
            margin-top: 15px;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 6px;
            animation: fadeIn 0.3s;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--gray);
        }
        
        .empty-state i {
            font-size: 50px;
            margin-bottom: 20px;
            color: #e0e0e0;
        }
        
        @media (max-width: 768px) {
            .horario-item {
                flex-direction: column;
                align-items: flex-start;
            }
            
            .horario-actions {
                margin-top: 15px;
                width: 100%;
                justify-content: flex-end;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="container header-content">
            <h2>Painel do Tatuador</h2>
            <a href="../index.html" class="btn btn-secondary">Voltar</a>
        </div>
    </header>
    
    <div class="container">
        <% if (!msg.isEmpty()) { %>
            <div class="alert <%= msg.contains("Erro") ? "error" : "success" %>">
                <%= msg %>
            </div>
        <% } %>
        
        <div class="card">
            <h3 class="card-title">Adicionar novo horário</h3>
            <form method="post">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label for="novoHorario">Data e Hora:</label>
                    <input type="datetime-local" id="novoHorario" name="novoHorario" required class="form-control">
                </div>
                <button type="submit" class="btn btn-primary">Salvar Horário</button>
            </form>
        </div>
        
        <div class="card">
            <h3 class="card-title">Horários disponíveis</h3>
            
            <% if (horarios.isEmpty()) { %>
                <div class="empty-state">
                    <div>?</div>
                    <h3>Nenhum horário cadastrado</h3>
                    <p>Adicione horários disponíveis para que clientes possam agendar.</p>
                </div>
            <% } else { %>
                <div class="horarios-list">
                    <% for (Iterator it = horarios.iterator(); it.hasNext();) { 
                        Map horario = (Map) it.next();
                    %>
                        <div class="horario-item">
                            <div class="horario-info">
                                <div class="horario-data">
                                    <%= horario.get("horario") %>
                                </div>
                            </div>
                            <div class="horario-actions">
                                <button onclick="document.getElementById('editForm<%= horario.get("id") %>').style.display='block'" 
                                        class="btn btn-edit btn-sm">Editar</button>
                                <form method="post" action="" style="display:inline;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= horario.get("id") %>">
                                    <button type="submit" class="btn btn-delete btn-sm" 
                                            onclick="return confirm('Tem certeza que deseja excluir este horário?')">Excluir</button>
                                </form>
                            </div>
                            
                            <div id="editForm<%= horario.get("id") %>" class="edit-form">
                                <form method="post">
                                    <input type="hidden" name="action" value="edit">
                                    <input type="hidden" name="id" value="<%= horario.get("id") %>">
                                    <div class="form-group">
                                        <label>Novo horário:</label>
                                        <input type="datetime-local" name="novoHorario" 
                                               value="<%= horario.get("horario").toString().length() >= 16 ? horario.get("horario").toString().substring(0, 16) : horario.get("horario").toString() %>"

                                               required class="form-control">
                                    </div>
                                    <button type="submit" class="btn btn-primary btn-sm">Atualizar</button>
                                    <button type="button" onclick="document.getElementById('editForm<%= horario.get("id") %>').style.display='none'" 
                                            class="btn btn-secondary btn-sm">Cancelar</button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </div>
    </div>
    
    <script>
        // Formata as datas para exibição amigável
        document.addEventListener('DOMContentLoaded', function() {
            const dates = document.querySelectorAll('.horario-data');
            dates.forEach(dateEl => {
                const rawDate = dateEl.textContent.trim();
                const formattedDate = formatDateTime(rawDate);
                if (formattedDate) {
                    dateEl.textContent = formattedDate;
                }
            });
            
            // Confirmação de exclusão
            document.querySelectorAll('form[action=""]').forEach(form => {
                form.addEventListener('submit', function(e) {
                    if (this.querySelector('input[name="action"]').value === 'delete') {
                        if (!confirm('Tem certeza que deseja excluir este horário?')) {
                            e.preventDefault();
                        }
                    }
                });
            });
        });
        
        function formatDateTime(dateTimeStr) {
            try {
                // Ajusta para o formato ISO esperado pelo Date()
                const isoDate = dateTimeStr.replace(' ', 'T');
                const date = new Date(isoDate);
                
                return date.toLocaleString('pt-BR', {
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                });
            } catch (e) {
                console.error("Erro ao formatar data:", e);
                return dateTimeStr; // Retorna o original se houver erro
            }
        }
    </script>
</body>
</html>