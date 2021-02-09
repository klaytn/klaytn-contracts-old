const { expectEvent } = require("openzeppelin-test-helpers");
const shouldFail = require("./shouldFail");

async function expectRevert(promise, message) {
  return shouldFail.reverting.withMessage(promise, message)
}

expectRevert.unspecified = shouldFail;

module.exports = expectRevert;