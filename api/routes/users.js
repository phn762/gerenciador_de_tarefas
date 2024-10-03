import express from "express"
import {getUsers, addUser, loginUser} from "../controllers/user.js"

const router = express.Router()

router.get ("/usuarios",getUsers)

router.post("/cadastro",addUser)

router.post("/login",loginUser)

export default router