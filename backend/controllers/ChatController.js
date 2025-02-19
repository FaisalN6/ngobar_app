const connection = require('../config/database');

/// Mendapatkan semua chat
exports.getAllChats = async (req, res) => {
  const { id_user } = req.query;
  try {
    const [results] = await connection.query(`
      SELECT 
        c.kd_chat, c.nama_chat, c.nomor_chat, m.message AS last_message, m.time AS last_time FROM chats c
      LEFT JOIN (
        SELECT kd_chat, message, time FROM messages m1 WHERE time = (
          SELECT MAX(time) FROM messages m2 WHERE m2.kd_chat = m1.kd_chat)
      ) m ON c.kd_chat = m.kd_chat WHERE c.id_user = ? ORDER BY m.time DESC
    `, [id_user]);
    res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching chats:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

exports.getChatsByProfile = async (req, res) => {
  const userId = req.query.id_user;
  try {
    const [chats] = await connection.query(
      'SELECT * FROM chats WHERE id_user = ?',
      [userId]
    );
    res.status(200).json(chats);
  } catch (error) {
    console.error('Error fetching chats:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};


/// Menambahkan chat baru
exports.addChat = async (req, res) => {
  const { nama_chat, nomor_chat, id_user } = req.body; // Get data from request body
  try {
    const result = await connection.query(`
      INSERT INTO chats (nama_chat, nomor_chat, id_user)
      VALUES (?, ?, ?)
    `, [nama_chat, nomor_chat, id_user]); // Include id_user in the insert

    res.status(201).json({ message: 'Chat created successfully', kd_chat: result[0].insertId });
  } catch (error) {
    console.error('Error adding chat:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
