import express from "express";
import { getUsers, addUser, loginUser, addTask, getTasks, updateTask, deleteTask } from "../controllers/user.js";

const router = express.Router();

router.get("/usuarios", getUsers);
router.post("/cadastro", addUser);
router.post("/login", loginUser);
router.post("/home/tarefas", addTask);
router.get("/home/tarefas", getTasks);
router.put("/home/tarefas/:id", updateTask); 
router.delete("/home/tarefas/:id", deleteTask); 


export default router;
