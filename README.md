# gerenciador_de_tarefas
 gerenciador de tarefas feito com flutter e node 


Resumo do Projeto de Gerenciamento de Tarefas
Este projeto é uma aplicação de gerenciamento de tarefas desenvolvida com javascript e flutter. O backend é implementado em Node.js, utilizando MySQL como banco de dados para armazenamento de informações. enquanto o frontend é construído com Flutter. A seguir estão as principais tecnologias e bibliotecas utilizadas:

Tecnologias Utilizadas
Node.js: Ambiente de execução JavaScript no lado do servidor, que permite a construção de aplicações escaláveis e de alto desempenho.

Express.js: Framework para Node.js que facilita a criação de servidores web e o gerenciamento de rotas, simplificando o desenvolvimento de APIs.

MySQL: Sistema de gerenciamento de banco de dados relacional utilizado para armazenar as informações dos usuários, como nome, email e senhas criptografadas.

bcrypt: Biblioteca de criptografia utilizada para proteger as senhas dos usuários, garantindo que as informações sensíveis sejam armazenadas de forma segura no banco de dados. O bcrypt aplica hashing e salting às senhas, tornando-as difíceis de serem revertidas ou comprometidas.

Flutter: Framework para construção de interfaces de usuário nativas, utilizado para desenvolver o frontend da aplicação, proporcionando uma experiência fluida e responsiva para os usuários.

Funcionalidades Implementadas
Cadastro de Usuários: Permite que novos usuários se registrem, validando os dados fornecidos e criptografando suas senhas antes de armazená-las no banco de dados.

Login de Usuários: Permite que os usuários se autentiquem, verificando as credenciais fornecidas em relação às informações armazenadas no banco de dados.

Próximos Passos
Futuras implementações podem incluir:

Gestão de tarefas (criação, edição, remoção e visualização).

