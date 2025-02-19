const express = require('express');
const router = express.Router();
const MessageController = require('../controllers/MessageController');

// Route untuk mendapatkan pesan dari chat tertentu
router.get('/messages/:chatId', MessageController.getMessages);

// Route untuk menambahkan pesan baru
router.post('/message', MessageController.addMessage);

module.exports = router;
