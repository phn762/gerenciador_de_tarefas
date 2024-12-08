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
        console.log(req.body); 
    
        const { nome, senha, confirmar_senha, cargo, email } = req.body;
    
        if (senha !== confirmar_senha) {
            return res.status(400).json({ error: "Senhas não correspondem." });
        }
    
        try {
            const saltRounds = 10;
            const hashedPassword = await bcrypt.hash(senha, saltRounds);
    
           
            const q = "INSERT INTO usuarios (nome, senha, cargo, email) VALUES (?, ?, ?, ?)";
    
            
            const [data] = await db.promise().query(q, [nome, hashedPassword, cargo, email]);
            console.log('Resultado da inserção:', data);
    
            return res.status(200).json("Usuário adicionado com sucesso!");
        } catch (err) {
            console.error('Erro ao salvar no banco de dados:', err); 
            return res.status(500).json(err);
        }
    };


export const loginUser = async (req, res) => {
    console.log('Dados de login recebidos:', req.body);
    const { email, senha } = req.body;

    try {
     
        const q = "SELECT * FROM usuarios WHERE email = ?";
        const [rows] = await db.promise().query(q, [email]);

        if (rows.length === 0) {
            return res.status(404).json({ error: "Usuário não encontrado." });
        }

        const user = rows[0];

        const passwordMatch = await bcrypt.compare(senha, user.senha);
        if (!passwordMatch) {
            return res.status(401).json({ error: "Senha incorreta." });
        }

        
        return res.status(200).json({ message: "Login bem-sucedido", user: user });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ error: "Erro no servidor." });
    }
};


export const getTasks = (_, res) => {
    const query = "SELECT * FROM crud_flutter.tarefas";
    db.query(query, (err, data) => {
        if (err) return res.json(err);

        return res.status(200).json(data);
    });
};

export const addTask = async (req, res) => {
    console.log(req.body); 
    const { nome, data_conclusao, responsavel, resumo, prioridade, area } = req.body;

    try {
        const q = "INSERT INTO tarefas (nome, data_conclusao, responsavel, resumo, prioridade, area) VALUES (?, ?, ?, ?, ?, ?)";

       
        const [result] = await db.promise().query(q, [nome, data_conclusao, responsavel, resumo, prioridade, area]);
        console.log('Resultado da inserção:', result);

        return res.status(200).json({
            message: "Tarefa adicionada com sucesso!",
            tarefaId: result.insertId,
        });
    } catch (err) {
        console.error('Erro ao salvar no banco de dados:', err); 
        return res.status(500).json({
            message: "Erro ao adicionar tarefa",
            error: err.message,
        });
    }
};

export const deleteTask = async (req, res) => {
    const { id } = req.params; 

    try {
        
        const q = 'DELETE FROM tarefas WHERE id = ?';

       
        const [result] = await db.promise().query(q, [id]);
        console.log('Resultado da exclusão:', result);

        
        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Tarefa não encontrada.' });
        }

       
        return res.status(200).json({ message: 'Tarefa excluída com sucesso!' });
    } catch (err) {
        console.error('Erro ao excluir tarefa:', err); 
        return res.status(500).json({
            message: 'Erro ao excluir tarefa',
            error: err.message, 
        });
    }
};





export const updateTask = async (req, res) => {
    console.log(req.body); 
    const { id } = req.params; 
    const { nome, data_conclusao, prioridade, responsavel, resumo, area } = req.body;

    try {
       
        if (!nome || !data_conclusao || !prioridade || !responsavel || !resumo || !area) {
            return res.status(400).json({ message: 'Todos os campos são obrigatórios.' });
        }

        const q = `
            UPDATE tarefas 
            SET nome = ?, data_conclusao = ?, prioridade = ?, responsavel = ?, resumo = ?, area = ? 
            WHERE id = ?
        `;
        const [result] = await db.promise().query(q, [nome, data_conclusao, prioridade, responsavel, resumo, area, id]);
        console.log('Resultado da atualização:', result);

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Tarefa não encontrada.' });
        }

        return res.status(200).json({ message: 'Tarefa atualizada com sucesso!' });
    } catch (err) {
        console.error('Erro ao atualizar a tarefa:', err); 
        return res.status(500).json({
            message: 'Erro ao atualizar tarefa',
            error: err.message, 
        });
    }
};
  

