const { BN } = require('openzeppelin-test-helpers');

const { shouldBehaveLikeKIP7Burnable } = require('./behaviors/KIP7Burnable.behavior');
const KIP7BurnableMock = artifacts.require('KIP7BurnableMock');

contract('KIP7Burnable', function ([_, owner, ...otherAccounts]) {
  const initialBalance = new BN(1000);

  console.log("owner", owner)

  beforeEach(async function () {
    this.token = await KIP7BurnableMock.new(owner, initialBalance, { from: owner });
  });

  shouldBehaveLikeKIP7Burnable(owner, initialBalance, otherAccounts);
});
