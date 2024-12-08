import mysql from 'mysql2'                                                                                     


export const db = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "toor",
    database: "crud_flutter"
});


db.connect((err) => {
    if (err) {
        console.error('Erro ao conectar no banco de dados:', err);
        return;
    }
    console.log('Conectado ao banco de dados MySQL');
});