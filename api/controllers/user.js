import {db} from "../db.js";
import bcrypt from 'bcrypt';


    export const getUsers = (_, res) => { 
    const q = "SELECT * FROM crud_flutter.usuarios";
    
    db.query(q, (err, data) => { 
    if (err) return res.json(err); 
    
    return res.status(200).json(data); 
    }); 
    };
    export const addUser = async (req, res) => {
        console.log(req.body); // Verificar se os dados estão chegando corretamente
    
        const { nome, senha, confirmar_senha, cargo, email } = req.body;
    
        if (senha !== confirmar_senha) {
            return res.status(400).json({ error: "Senhas não correspondem." });
        }
    
        try {
            const saltRounds = 10;
            const hashedPassword = await bcrypt.hash(senha, saltRounds);
    
            // Removido o campo confirmar_senha da query
            const q = "INSERT INTO usuarios (nome, senha, cargo, email) VALUES (?, ?, ?, ?)";
    
            // Inserindo os dados no banco
            const [data] = await db.promise().query(q, [nome, hashedPassword, cargo, email]);
            console.log('Resultado da inserção:', data);
    
            return res.status(200).json("Usuário adicionado com sucesso!");
        } catch (err) {
            console.error('Erro ao salvar no banco de dados:', err); // Adicionado para logar o erro no terminal
            return res.status(500).json(err);
        }
    };

// Função para verificar se o usuário existe e se a senha está correta
export const loginUser = async (req, res) => {
    console.log('Dados de login recebidos:', req.body);
    const { email, senha } = req.body;

    try {
        // Verificando se o usuário existe
        const q = "SELECT * FROM usuarios WHERE email = ?";
        const [rows] = await db.promise().query(q, [email]);

        if (rows.length === 0) {
            return res.status(404).json({ error: "Usuário não encontrado." });
        }

        const user = rows[0];

        // Comparando a senha enviada com a senha armazenada
        const passwordMatch = await bcrypt.compare(senha, user.senha);
        if (!passwordMatch) {
            return res.status(401).json({ error: "Senha incorreta." });
        }

        // Se a autenticação for bem-sucedida
        return res.status(200).json({ message: "Login bem-sucedido", user: user });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Erro no servidor." });
    }
};


export const getTasks = (_, res) => {
    const query = "SELECT * FROM crud_flutter.tarefas"; // Ajuste para selecionar apenas as colunas desejadas

    db.query(query, (err, data) => {
        if (err) return res.json(err);

        return res.status(200).json(data);
    });
};

export const addTask = async (req, res) => {
    console.log(req.body); // Verificar se os dados estão chegando corretamente
    const { nome, data_conclusao, responsavel, resumo, prioridade, area } = req.body;

    try {
        const q = "INSERT INTO tarefas (nome, data_conclusao, responsavel, resumo, prioridade, area) VALUES (?, ?, ?, ?, ?, ?)";

        // Inserindo os dados no banco
        const [result] = await db.promise().query(q, [nome, data_conclusao, responsavel, resumo, prioridade, area]);
        console.log('Resultado da inserção:', result);

        return res.status(200).json({
            message: "Tarefa adicionada com sucesso!",
            tarefaId: result.insertId, // Retorna o ID da nova tarefa
        });
    } catch (err) {
        console.error('Erro ao salvar no banco de dados:', err); // Adicionado para logar o erro no terminal
        return res.status(500).json({
            message: "Erro ao adicionar tarefa",
            error: err.message, // Retorna uma mensagem de erro mais clara
        });
    }
};
