const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Task = require('./models/Task');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/tasks');

// CRUD Routes
app.get('/tasks', async (req, res) => res.json(await Task.find().sort({ createdAt: -1 })));

app.post('/tasks', async (req, res) => res.json(await Task.create(req.body)));

app.put('/tasks/:id', async (req, res) => {
    const task = await Task.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(task);
});

app.delete('/tasks/:id', async (req, res) => {
    await Task.findByIdAndDelete(req.params.id);
    res.json({ message: "Deleted" });
});

app.listen(5000, () => console.log('Backend on port 5000'));