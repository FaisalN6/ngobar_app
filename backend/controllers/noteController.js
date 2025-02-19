const connection = require('../config/database');

// Get all notes
exports.getAllNotes = async (req, res) => {
    try {
        const [rows] = await connection.query('SELECT * FROM notes');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get note by ID
exports.getNoteById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await connection.query('SELECT * FROM notes WHERE id = ?', [id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Note not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Create a new note
exports.createNote = async (req, res) => {
    const { id_user, title, content, is_private } = req.body;
    try {
        const [result] = await connection.query(
            'INSERT INTO notes (id_user, title, content, is_private) VALUES (?, ?, ?, ?)',
            [id_user, title, content, is_private]
        );
        res.json({ id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Update a note
exports.updateNote = async (req, res) => {
    const { id } = req.params;
    const { title, content, is_private } = req.body;
    try {
        await connection.query(
            'UPDATE notes SET title = ?, content = ?, is_private = ? WHERE id = ?',
            [title, content, is_private, id]
        );
        res.json({ message: 'Note updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete a note
exports.deleteNote = async (req, res) => {
    const { id } = req.params;
    try {
        await connection.query('DELETE FROM notes WHERE id = ?', [id]);
        res.json({ message: 'Note deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
