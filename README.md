🚗 Oficina Conectada (Frontend)

Desenvolvido por Lucas Kalell 

"Um café e uma bao musica podemos  codar o mundo "

Gestor de oficinas (Spring Boot + Flutter) focado na experiência do cliente, com estimativas de tempo e notificações de status via API.

Este é o repositório do Frontend da aplicação, construído em Flutter.
O repositório do Backend (Spring Boot) pode ser encontrado aqui: oficina-conectada-api https://github.com/Lucaskalell/oficina-conectada

Tela de Login (Web)

Dashboard/Shell (Web Responsivo)


✨ Visão Geral do Projeto

A "Oficina Conectada" é uma solução full-stack (Backend + Frontend) para modernizar o gerenciamento de oficinas mecânicas. O sistema foca em transparência e comunicação com o cliente, fornecendo um dashboard de gestão para o mecânico e, futuramente, notificações em tempo real (via WhatsApp/Email) para o cliente.

Este projeto está sendo construído do zero, com foco em boas práticas de arquitetura e "memória muscular cerebral" para ambientes de desenvolvimento profissionais.

🚀 Funcionalidades Atuais 

Até o momento, o "alicerce" completo da aplicação está 100% funcional.

Backend (Spring Boot)

Pilar de Segurança (Spring Security):

Autenticação e Autorização completas usando JWT (JSON Web Tokens).

Endpoints públicos POST /auth/register (para criar usuários) e POST /auth/login (para obter um token).

Senhas são 100% criptografadas no banco usando BCryptPasswordEncoder.

API REST Protegida:

Endpoints privados (ex: /**) que só podem ser acessados com um Token JWT válido (testado via Postman e Flutter).

Conexão com Banco de Dados (MySQL):

Setup completo de um servidor MySQL 8 persistente.

Configuração do Spring Data JPA (application.properties) para se conectar ao MySQL.

Módulo de Estoque (Estrutura):

Endpoints GET /estoque/** para listar categorias, subcategorias e produtos.

Modelagem de dados hierárquica com @OneToMany e @ManyToOne: Categoria -> SubCategoria -> Produto.

População de Dados (Seed):

Uso do data.sql para popular automaticamente o banco de dados com categorias e produtos de exemplo na inicialização.

CORS (Cross-Origin Resource Sharing):

Configuração global de CORS (WebConfig.java) para permitir que o frontend Flutter (rodando em outra porta) possa chamar a API do backend.

Frontend (Flutter)

Arquitetura Limpa (BLoC):

Arquitetura de pastas profissional, separada por módulos (/login, /home_page, /core, /common).

Uso do padrão BLoC para gerenciamento de estado (page, bloc, event, state, repository), seguindo o padrão de clean code.

Autenticação de Ponta-a-Ponta:

LoginPage funcional com UI simples e estilizada.

LoginBloc que lida com os estados LoginLoading, LoginSuccess e LoginError.

LoginRepository que chama o POST /auth/login do backend.

Ao receber 200 OK, salva o token JWT localmente usando shared_preferences.

Navegação e Rotas Protegidas:

Gerenciamento de rotas com Navigator 2.0 (/login, /home).

Após o LoginSuccess, o usuário é automaticamente redirecionado para a HomePage (/home).

Cliente de API Centralizado (O "Pegador de Token"):

Criação de um ApiClient reutilizável (em lib/core/api/) que automaticamente lê o token do shared_preferences e o anexa ao Header Authorization: Bearer <token> em todas as requisições privadas (ex: GET /api/estoque).

Shell de Aplicação Responsivo:

Criação da HomePage (o "Shell" principal) que é 100% responsiva.

Em Telas Grandes (Web): Mostra um Drawer (menu lateral) fixo à esquerda.

Em Telas Pequenas (Mobile): Esconde o Drawer e mostra o menu "hambúrguer" padrão.

O "Shell" já contém o layout da AppBar (com o avatar e botão + Nova OS) e do Drawer (com os links de navegação).

🛠️ Como Executar (Ambiente de Dev)

Para rodar este projeto, você precisa clonar ambos os repositórios (frontend e backend) e ter o MySQL Server instalado.

Pré-requisitos

Java JDK 21+

Flutter SDK 3.x+

MySQL Server 8.x+ (Recomendado o "Installer Community" completo)

Um cliente de API (como Postman)

Um cliente de Banco de Dados (como DBeaver ou MySQL Workbench)

1. Backend (Spring Boot)

Clone o repositório oficina-conectada-api.

Abra o MySQL Workbench ou DBeaver.

Crie um novo banco de dados (schema) chamado exatamente: oficinaconectada.

Abra o projeto no IntelliJ IDEA (ou sua IDE Java).

Navegue até src/main/resources/application.properties.

IMPORTANTE: Altere spring.datasource.username e spring.datasource.password para o seu usuário e senha root do MySQL (os que você definiu na instalação).

Rode a classe principal OficinaconectadaApplication.java.

O servidor Spring Boot deve iniciar na http://localhost:8080. O data.sql será executado e irá popular o banco.

2. Frontend (Flutter)

Clone este repositório (oficina-conectada-front).

Abra o projeto no Android Studio (ou VS Code).

Abra o terminal e rode flutter pub get para baixar todas as dependências (http, bloc, etc.).

IMPORTANTE: Verifique o arquivo lib/common/constants/api_constants.dart. Se você estiver rodando no Emulador Android, mude a _localBaseUrl de http://localhost:8080 para http://10.0.2.2:8080. (Se estiver rodando no Chrome (web), localhost está correto).

Inicie a aplicação (ex: flutter run -d chrome para rodar na web).

3. (Projeto em desenvolvimento RoadMap ainda em desenvolvimento )