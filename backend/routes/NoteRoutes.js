const express = require('express');
const router = express.Router();
const NoteController = require('../controllers/noteController');

router.get('/', NoteController.getAllNotes);
router.get('/:id', NoteController.getNoteById);
router.post('/', NoteController.createNote);
router.put('/:id', NoteController.updateNote);
router.delete('/:id', NoteController.deleteNote);

module.exports = router;
