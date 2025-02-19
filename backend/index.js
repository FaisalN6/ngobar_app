const express = require('express');
const app = express();
const authRoute = require('./routes/AuthRoute');
const chatRoute = require('./routes/ChatRoute');
const messageRoute = require('./routes/MessageRoute');
const eventRoute = require('./routes/EventRoutes');
const noteRoute = require('./routes/NoteRoutes');

app.use(express.json());

app.use('/', authRoute, chatRoute, messageRoute);
app.use('/api/events', eventRoute);
app.use('/api/notes', noteRoute);

const port = 3000;
app.listen(port, () => {
    console.log(`Server is running on port http://localhost:${port}`);
});

module.exports = app;