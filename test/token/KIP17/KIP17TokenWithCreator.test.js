const { BN, constants, expectEvent } = require('openzeppelin-test-helpers');
const expectRevert = require('../../helpers/expectRevert')
const { ZERO_ADDRESS } = constants;
var should = require('chai').should();

const { expect } = require('chai');
const { inTransaction } = require('openzeppelin-test-helpers/src/expectEvent');

const KIP17TokenWithCreator = artifacts.require('KIP17TokenWithCreator');

contract('KIP17TokenWithCreator', function(accounts) {
  const [operator, tokenHolder, tokenHolderTwo, ...otherAccounts] = accounts;
  const initialURI = 'https://token-cdn-domain/1.json';
  const name = 'NFT contract'
  const symbol = 'NFT'
  const tokenOne = '1' 
  const tokenTwo = '2' 

  beforeEach(async function () {
    this.token = await KIP17TokenWithCreator.new(name, symbol);
  });

  describe('mint', async function() {
    beforeEach(async function() {
      ({logs:this.logs} = await this.token.mintWithTokenURI(tokenHolder, tokenOne, initialURI, {from:operator}))
    })

    it('check log', async function() {
      expectEvent.inLogs(this.logs, 'Transfer', {
        from: ZERO_ADDRESS,
        to: tokenHolder,
        tokenId: tokenOne
      })
    })

    it('check interface supported', async function() {
      expect(await this.token.supportsInterface('0xd722b746')).to.equal(true)
    })

    it('check creator', async function() {
      expect(await this.token.creatorOf(tokenOne)).to.equal(tokenHolder)
    })

    it('check creator for an unminted token', async function() {
      expect(await this.token.creatorOf(tokenTwo)).to.equal(ZERO_ADDRESS)
    })

    describe('transfer', async function() {
      beforeEach(async function() {
        ({logs:this.logs} = await this.token.transferFrom(tokenHolder, tokenHolderTwo, tokenOne, {from:tokenHolder}))
      })

      it('check log', async function() {
        expectEvent.inLogs(this.logs, 'Transfer', {
          from: tokenHolder,
          to: tokenHolderTwo,
          tokenId: tokenOne
        })
      })

      it('check creator', async function() {
        expect(await this.token.creatorOf(tokenOne)).to.equal(tokenHolder)
      })
    })

  })
})
