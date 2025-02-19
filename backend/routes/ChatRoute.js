const express = require('express');
const router = express.Router();
const ChatController = require('../controllers/ChatController');

// Route untuk mendapatkan semua chat
router.get('/chats', ChatController.getAllChats);

// Route untuk mendapatkan chat berdasarkan profile
router.get('/chats/profile', ChatController.getChatsByProfile);

// Route untuk menambahkan chat baru
router.post('/chats', ChatController.addChat);

module.exports = router;
