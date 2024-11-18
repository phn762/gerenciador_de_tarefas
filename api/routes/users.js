import express from "express";
import { getUsers, addUser, loginUser, addTask, getTasks } from "../controllers/user.js";

const router = express.Router();

router.get("/usuarios", getUsers);
router.post("/cadastro", addUser);
router.post("/login", loginUser);
router.post("/home/tarefas", addTask); // Corrigida a barra inicial
router.get("/home/tarefas", getTasks);

export default router;
