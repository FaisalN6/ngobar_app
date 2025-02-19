const connection = require('../config/database');
const jwt = require('jsonwebtoken');

// Get all events
exports.getAllEvents = async (req, res) => {
    try {
        const [rows] = await connection.promise().query('SELECT * FROM events');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get event by ID
exports.getEventById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await connection.promise().query('SELECT * FROM events WHERE id = ?', [id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Event not found' });
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Create a new event
exports.createEvent = async (req, res) => {
    const { id_user, title, description, start_time, end_time, location, is_shared } = req.body;
    try {
        const [result] = await connection.promise().query(
            'INSERT INTO events (id_user, title, description, start_time, end_time, location, is_shared) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [id_user, title, description, start_time, end_time, location, is_shared]
        );
        res.json({ id: result.insertId });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Update an event
exports.updateEvent = async (req, res) => {
    const { id } = req.params;
    const { title, description, start_time, end_time, location, is_shared } = req.body;
    try {
        await connection.query(
            'UPDATE events SET title = ?, description = ?, start_time = ?, end_time = ?, location = ?, is_shared = ? WHERE id = ?',
            [title, description, start_time, end_time, location, is_shared, id]
        );
        res.json({ message: 'Event updated' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete an event
exports.deleteEvent = async (req, res) => {
    const { id } = req.params;
    try {
        await connection.query('DELETE FROM events WHERE id = ?', [id]);
        res.json({ message: 'Event deleted' });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
