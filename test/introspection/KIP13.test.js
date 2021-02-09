const { shouldSupportInterfaces } = require('./SupportsInterface.behavior');
const shouldFail = require('../helpers/shouldFail');

const KIP13Mock = artifacts.require('KIP13Mock');

contract('KIP13', function () {
  beforeEach(async function () {
    this.mock = await KIP13Mock.new();
  });

  it('does not allow 0xffffffff', async function () {
    await shouldFail.reverting.withMessage(this.mock.registerInterface('0xffffffff'), 'KIP13: invalid interface id');
  });

  shouldSupportInterfaces([
    'KIP13',
  ]);
});
