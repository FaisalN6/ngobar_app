const express = require('express');
const router = express.Router();
const authController = require('../controllers/AuthController'); // Pastikan jalurnya benar

router.post('/register', authController.register);
// router.post('/verifyOtp', authController.verifyOtp);

module.exports = router;
