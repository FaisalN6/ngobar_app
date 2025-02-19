const connection = require('../config/database');

// Get messages for a specific chat
exports.getMessages = async (req, res) => {
  const chatId = req.params.chatId;
  try {
    const [results] = await connection.query('SELECT * FROM messages WHERE kd_chat = ?', [chatId]);
    res.status(200).json(results);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};

// Add a new message 
exports.addMessage = async (req, res) => {
  const { kd_chat, id_user, message, time, is_sent_by_user } = req.body;
  console.log("Received message:", req.body); // Log the received message
  try {
    const [result] = await connection.query(
      'INSERT INTO messages (kd_chat, id_user, message, time, is_sent_by_user) VALUES (?, ?, ?, ?, ?)',
      [kd_chat, id_user, message, time, is_sent_by_user]
    );

    // Send the newly inserted `kd_message` back in the response
    res.status(201).json({ kd_message: result.insertId });
  } catch (error) {
    console.error('Error adding message:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
};
