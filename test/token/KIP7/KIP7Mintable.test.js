const { shouldBehaveLikeKIP7Mintable } = require('./behaviors/KIP7Mintable.behavior');
const KIP7MintableMock = artifacts.require('KIP7MintableMock');
const { shouldBehaveLikePublicRole } = require('../../behaviors/access/roles/PublicRole.behavior');

contract('KIP7Mintable', function ([_, minter, otherMinter, ...otherAccounts]) {
  beforeEach(async function () {
    this.token = await KIP7MintableMock.new({ from: minter });
  });

  describe('minter role', function () {
    beforeEach(async function () {
      this.contract = this.token;
      await this.contract.addMinter(otherMinter, { from: minter });
    });

    shouldBehaveLikePublicRole(minter, otherMinter, otherAccounts, 'minter');
  });

  shouldBehaveLikeKIP7Mintable(minter, otherAccounts);
});
