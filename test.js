const validator = require('email-validator')

describe("Email Validation Test", () => {
    test('Valid username/email must return true', () => {
        expect(validator.validate('csye6225@csye.com')).toBe(true)
    })

    test('Invalid username/email must return false', () => {
        expect(validator.validate('csye6225csye.com')).toBe(false)
    })
})

