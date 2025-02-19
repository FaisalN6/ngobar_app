const connection = require('../config/database');

exports.register = (req, res) => {
  const { phone_number } = req.body;

  const phoneRegex = /^(\+62|62|0)8[1-9][0-9]{6,9}$/;
  if (!phoneRegex.test(phone_number)) {
    return res.status(400).json({ message: 'Format nomor telepon tidak valid' });
  }

  const checkPhoneQuery = 'SELECT * FROM users WHERE phone_number = ?';
  connection.query(checkPhoneQuery, [phone_number], (checkError, checkResults) => {
    if (checkError) {
      return res.status(500).json({ message: 'Terjadi kesalahan saat memeriksa nomor telepon' });
    }

    if (checkResults.length > 0) {
      return res.status(400).json({ message: 'Nomor telepon sudah terdaftar' });
    }

    const randomString = Math.random().toString(36).substring(2, 8);
    const username = `user_${randomString}`;
    const full_name = `User ${phone_number.slice(-4)}`;
    const query = 'INSERT INTO users (phone_number, username, full_name, status) VALUES (?, ?, ?, ?)';
    const defaultStatus = 'Hey there! I am using this app';

    connection.query(query, [phone_number, username, full_name, defaultStatus], (error, results) => {
      if (error) {
        return res.status(500).json({ message: 'Terjadi kesalahan saat Register' });
      }

      res.json({
        userId: results.insertId,
        username: username,
        full_name: full_name,
        phone_number: phone_number,
      });
    });
  });
};
