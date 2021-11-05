const express = require("express")
const bodyParser = require('body-parser')
const db = require("./api/models");
const userRoute = require('./api/routes/user.route')
const fileRoute = require('./api/routes/file.route')
const app = express()

require('dotenv').config();

app.use(bodyParser.urlencoded({extended: true}))
app.use(bodyParser.json())
app.use(bodyParser.raw({ limit: '50mb', type: ['image/*'] }));

app.listen(process.env.PORT || 3000, () => {
    console.log("Connected");
})

app.use('/v1/users', userRoute)
app.use('/v1/users', fileRoute)

db.sequelize.sync();