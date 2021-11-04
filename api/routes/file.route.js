const { Router } = require("express");
const router = Router()
const files = require('../controllers/file.controller')

router.post('/self/pic', files.createFile)
router.delete('/self/pic', files.deleteFile)
router.get('/self/pic', files.findFile)

module.exports = router