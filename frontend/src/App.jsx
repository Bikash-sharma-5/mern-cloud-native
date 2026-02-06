import { useEffect, useState } from 'react';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/tasks';

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');

  const fetchTasks = async () => {
    const res = await axios.get(API_URL);
    setTasks(res.data);
  };

  const addTask = async (e) => {
    e.preventDefault();
    if (!title) return;
    await axios.post(API_URL, { title });
    setTitle('');
    fetchTasks();
  };

  const toggleTask = async (id, completed) => {
    await axios.put(`${API_URL}/${id}`, { completed: !completed });
    fetchTasks();
  };

  const deleteTask = async (id) => {
    await axios.delete(`${API_URL}/${id}`);
    fetchTasks();
  };

  useEffect(() => { fetchTasks(); }, []);

  return (
    <div className="min-h-screen bg-gray-100 p-8 font-sans">
      <div className="max-w-md mx-auto bg-white rounded-xl shadow-md overflow-hidden p-6">
        <h1 className="text-2xl font-bold text-gray-800 mb-4">Cloud Tasks</h1>
        
        <form onSubmit={addTask} className="flex mb-4">
          <input 
            className="border p-2 w-full rounded-l-lg outline-none focus:ring-2 ring-blue-400"
            value={title} onChange={(e) => setTitle(e.target.value)}
            placeholder="What needs to be done?"
          />
          <button className="bg-blue-600 text-white px-4 rounded-r-lg hover:bg-blue-700">Add</button>
        </form>

        <div className="space-y-3">
          {tasks.map(task => (
            <div key={task._id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg border">
              <span 
                onClick={() => toggleTask(task._id, task.completed)}
                className={`cursor-pointer ${task.completed ? 'line-through text-gray-400' : 'text-gray-700 font-medium'}`}
              >
                {task.title}
              </span>
              <button onClick={() => deleteTask(task._id)} className="text-red-500 hover:text-red-700 text-sm">Delete</button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
export default App;