require('openzeppelin-test-helpers');
const { shouldBehaveLikeKIP17PausedToken } = require('./KIP17PausedToken.behavior');
const { shouldBehaveLikeKIP17 } = require('./KIP17.behavior');
const { shouldBehaveLikePublicRole } = require('../../behaviors/access/roles/PublicRole.behavior');

const KIP17PausableMock = artifacts.require('KIP17PausableMock.sol');

contract('KIP17Pausable', function ([
  _,
  creator,
  otherPauser,
  ...accounts
]) {
  beforeEach(async function () {
    this.token = await KIP17PausableMock.new({ from: creator });
  });

  describe('pauser role', function () {
    beforeEach(async function () {
      this.contract = this.token;
      await this.contract.addPauser(otherPauser, { from: creator });
    });

    shouldBehaveLikePublicRole(creator, otherPauser, accounts, 'pauser');
  });

  context('when token is paused', function () {
    beforeEach(async function () {
      await this.token.pause({ from: creator });
    });

    shouldBehaveLikeKIP17PausedToken(creator, accounts);
  });

  context('when token is not paused yet', function () {
    shouldBehaveLikeKIP17(creator, creator, accounts);
  });

  context('when token is paused and then unpaused', function () {
    beforeEach(async function () {
      await this.token.pause({ from: creator });
      await this.token.unpause({ from: creator });
    });

    shouldBehaveLikeKIP17(creator, creator, accounts);
  });
});
