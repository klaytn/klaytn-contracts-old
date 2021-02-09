require('openzeppelin-test-helpers');

const { shouldBehaveLikeKIP17 } = require('./KIP17.behavior');
const {
  shouldBehaveLikeMintAndBurnKIP17,
} = require('./KIP17MintBurn.behavior');

const KIP17BurnableImpl = artifacts.require('KIP17MintableBurnableImpl.sol');

contract('KIP17Burnable', function ([_, creator, ...accounts]) {
  const minter = creator;

  beforeEach(async function () {
    this.token = await KIP17BurnableImpl.new({ from: creator });
  });

  shouldBehaveLikeKIP17(creator, minter, accounts);
  shouldBehaveLikeMintAndBurnKIP17(creator, minter, accounts);
});
