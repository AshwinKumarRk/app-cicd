const AWS = require('aws-sdk');

const s3Client = new AWS.S3({});

const Parameters = {
  Bucket: process.env.S3_BUCKET,
  Key: '', 
  Body: null,
};

const s3 = {};

s3.s3Client = s3Client;
s3.Parameters = Parameters;

module.exports = s3;