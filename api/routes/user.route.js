const { Router } = require("express");
const router = Router()
const users = require('../controllers/user.controller')

//Route to navigate to requests
router.post('/', users.create)
router.get('/self', users.findOne)
router.put('/self', users.update)

module.exports = router
