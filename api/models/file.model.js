module.exports = (sequelize, Sequelize) => {
    const File = sequelize.define("files", {
        file_id: {
            type: Sequelize.UUID,
            primaryKey: true
        },
        file_name: {
            type: Sequelize.STRING,
            validate: { notEmpty: true }
        },
        s3_object_name: {
            type: Sequelize.STRING,
            validate: { notEmpty: true }
        },
        user_id: {
            type: Sequelize.UUID,
            validate: { notEmpty: true }
        }
    });
    return File;
};