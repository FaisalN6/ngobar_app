const mysql = require('mysql2'); 

const connection = mysql.createConnection({
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: '',
    database: 'ngobar-app'
});


module.exports = connection;