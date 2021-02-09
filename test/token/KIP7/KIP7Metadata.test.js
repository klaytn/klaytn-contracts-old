const { BN } = require('openzeppelin-test-helpers');
var should = require('chai').should();
const KIP7MetadataMock = artifacts.require('KIP7MetadataMock');

contract('KIP7Metadata', function () {
  const _name = 'My Metadata KIP7';
  const _symbol = 'MDT';
  const _decimals = new BN(18);

  beforeEach(async function () {
    this.detailedKIP7 = await KIP7MetadataMock.new(_name, _symbol, _decimals);
  });

  it('has a name', async function () {
    (await this.detailedKIP7.name()).should.be.equal(_name);
  });

  it('has a symbol', async function () {
    (await this.detailedKIP7.symbol()).should.be.equal(_symbol);
  });

  it('has an amount of decimals', async function () {
    (await this.detailedKIP7.decimals()).should.be.bignumber.equal(_decimals);
  });
});
