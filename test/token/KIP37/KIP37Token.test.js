const { BN, constants, expectEvent } = require('openzeppelin-test-helpers');
const expectRevert = require('../../helpers/expectRevert')
const { ZERO_ADDRESS } = constants;
var should = require('chai').should();

const { expect } = require('chai');

const expectEventHelper = require('../../helpers/expectEventHelper');
const KIP37TokenMock = artifacts.require('KIP37TokenMock');

contract('KIP37Token', function (accounts) {
  const [operator, tokenHolder, tokenBatchHolder, ...otherAccounts] = accounts;

  const initialURI = 'https://token-cdn-domain/{id}.json';
  const overridenURI = 'https://test.uri';

  beforeEach(async function () {
    this.token = await KIP37TokenMock.new(initialURI);
  });

  describe('create', async function () {
    const tokenId = new BN(1990);
    const tokenIdTwo = new BN(1991);
    const mintAmount = new BN(9001);

    beforeEach(async function () {
      ({ logs: this.logs } = await this.token.create(tokenId, mintAmount, '', { from: operator }))
    })

    it('unauthorized create', async function() {
      await expectRevert(this.token.create(tokenIdTwo, mintAmount, '', { from: tokenHolder}),
      'MinterRole: caller does not have the Minter role')
    })

    describe('normal case', async function () {
      it('emits a TransferSingle Event', async function () {
        expectEvent.inLogs(this.logs, 'TransferSingle', {
          operator,
          from: ZERO_ADDRESS,
          to: operator,
          id: tokenId,
          value: mintAmount,
        })
      })

      it('check uri', async function () {
        expect(await this.token.uri(tokenId)).to.equal(initialURI)
      })

      it('check balance', async function () {
        expect(await this.token.balanceOf(operator, tokenId)).to.be.bignumber.equal(mintAmount);
      })
    })

    describe('normal case with URI overriden', async function () {
      beforeEach(async function() {
        ({ logs: this.logs } = await this.token.create(tokenIdTwo, mintAmount, overridenURI, { from: operator }))
      })

      it('check logs', async function() {
        expectEvent.inLogs(this.logs, 'TransferSingle', {
          operator,
          from: ZERO_ADDRESS,
          to: operator,
          id: tokenIdTwo,
          value: mintAmount,
        })
        expectEvent.inLogs(this.logs, 'URI', {
          value: overridenURI,
          id: tokenIdTwo,
        })
      })

      it('check uri', async function(){
        expect(await this.token.uri(tokenId)).to.equal(initialURI)
        expect(await this.token.uri(tokenIdTwo)).to.equal(overridenURI)
      })
    })

    it('token already created', async function () {
      await expectRevert(
        this.token.create(tokenId, mintAmount, overridenURI, { from: operator }),
        "KIP37: token already created"
      )
    })
  })

  describe('mint single', async function () {
    const tokenId = new BN(1990);
    const tokenIdTwo = new BN(2);
    const mintAmount = new BN(901);

    const data = '0x12345678';

    beforeEach(async function () {
      await this.token.create(tokenId, mintAmount, overridenURI, { from: operator });
    })

    it('unauthorized mint', async function() {
      await expectRevert(
        this.token.methods['mint(uint256,address,uint256)'](tokenId, tokenHolder, mintAmount, { from: tokenHolder}),
        'MinterRole: caller does not have the Minter role')
    })

    describe('normal case', async function () {
      before('mint token', async function () {
        ({ logs: this.logs } = await this.token.methods['mint(uint256,address,uint256)'](tokenId, tokenHolder, mintAmount, { from: operator }))
      })

      if ('check log', async function () {
        expectEvent.inLogs(this.logs, 'TransferSingle', {
          operator,
          from: ZERO_ADDRESS,
          to: operator,
          id: tokenId,
          value: mintAmount,
        })
      })

        it('check balance', async function () {
          expect(await this.token.balanceOf(operator, tokenId)).to.be.bignumber.equal(mintAmount);
        })
    })

    it('not created token minting', async function () {
      await expectRevert(
        this.token.methods['mint(uint256,address,uint256)'](tokenIdTwo, tokenHolder, mintAmount, { from: operator }),
        "KIP37: nonexistent token"
      )
    })

    it('cannot mint to zero address', async function () {
      await expectRevert(
        this.token.methods['mint(uint256,address,uint256)'](tokenId, ZERO_ADDRESS, mintAmount, { from: operator }),
        "KIP37: mint to the zero address"
      )
    })
  })

  describe('mint multiple recipients', async function () {
    const tokenId = new BN(1990);
    const tokenIdTwo = new BN(2);
    const toList = [tokenHolder, tokenBatchHolder]
    const mintAmounts = [new BN(901), new BN(801)]
    const method = 'mint(uint256,address[],uint256[])'

    beforeEach('create a token', async function () {
      await this.token.create(tokenId, '1', overridenURI, { from: operator });
    })

    describe('normal case', async function () {
      beforeEach('mint tokens', async function () {
        ({ logs: this.logs } = await this.token.methods[method](tokenId, toList, mintAmounts, { from: operator }))
      })

      it('check log', async function () {
        toList.map((x, i) => {
          expectEvent.inLogs(this.logs, 'TransferSingle', {
            operator,
            from: ZERO_ADDRESS,
            to: x,
            id: tokenId,
            value: mintAmounts[i],
          })
        })
      })

      it('check balance', async function () {
        expect(await this.token.balanceOf(operator, tokenId)).to.be.bignumber.equal('1');
        for (var i = 0; i < toList.length; i++) {
          expect(await this.token.balanceOf(toList[i], tokenId)).to.be.bignumber.equal(mintAmounts[i]);
        }
      })
    })

    it('toList and values mismatch', async function () {
      await expectRevert(
        this.token.methods[method](tokenId, toList, mintAmounts.slice(1), { from: operator }),
        "KIP37: toList and _values length mismatch"
      )
    })

    it('not created token minting', async function () {
      await expectRevert(
        this.token.methods[method](tokenIdTwo, toList, mintAmounts, { from: operator }),
        "KIP37: nonexistent token"
      )
    })

    it('cannot mint to zero address', async function () {
      await expectRevert(
        this.token.methods[method](tokenId, [ZERO_ADDRESS], ['3'], { from: operator }),
        "KIP37: mint to the zero address"
      )
    })
  })

  describe('mint multiple ids', async function () {
    const tokenId = new BN(1990);
    const tokenIdTwo = new BN(2);
    const idList = [new BN(1990), new BN(21)]
    const mintAmounts = [new BN(901), new BN(801)]
    const method = 'mintBatch(address,uint256[],uint256[])'

    beforeEach('create a token', async function () {
      await idList.map((x) => {
        return this.token.create(x, '0', overridenURI, { from: operator });
      })
    })

    describe('normal case', async function () {
      beforeEach('mint tokens', async function () {
        ({ logs: this.logs } = await this.token.methods[method](tokenHolder, idList, mintAmounts, { from: operator }))
      })

      it('check log', async function () {
        expectEvent.inLogs(this.logs, 'TransferBatch', {
          operator,
          from: ZERO_ADDRESS,
          to: tokenHolder,
          ids: idList,
          values: mintAmounts,
        })
      })

      it('check balance', async function () {
        expect(await this.token.balanceOf(operator, tokenId)).to.be.bignumber.equal('0');
        for (var i = 0; i < idList.length; i++) {
          expect(await this.token.balanceOf(tokenHolder, idList[i])).to.be.bignumber.equal(mintAmounts[i]);
        }
      })
    })

    it('toList and values mismatch', async function () {
      await expectRevert(
        this.token.methods[method](tokenHolder, idList, mintAmounts.slice(1), { from: operator }),
        "KIP37: ids and amounts length mismatch"
      )
    })

    it('not created token minting', async function () {
      await expectRevert(
        this.token.methods[method](tokenHolder, [idList[0], new BN(3)], mintAmounts, { from: operator }),
        "KIP37: nonexistent token"
      )
    })

    it('cannot mint to zero address', async function () {
      await expectRevert(
        this.token.methods[method](ZERO_ADDRESS, idList, mintAmounts, { from: operator }),
        "KIP37: mint to the zero address"
      )
    })
  })

  describe('burn single', async function () {
    const tokenIds = [new BN(1990), new BN(1991)];
    const tokenIdTwo = new BN(2);
    const idList = [new BN(1990), new BN(21)]
    const mintAmounts = [new BN(901), new BN(801)]
    const burnAmounts = [new BN(3), new BN(4)]

    beforeEach('create a token type', async function () {
      await Promise.all(tokenIds.map((x, i) => {
        return this.token.create(x, mintAmounts[i], '', { from: operator })
      }))
    })

    describe('burn single', async function () {
      beforeEach('burn', async function () {
        ({ logs: this.logs } = await this.token.burn(operator, tokenIds[0], burnAmounts[0]))
      })

      it('check log', async function () {
        expectEvent.inLogs(this.logs, 'TransferSingle', {
          operator,
          from: operator,
          to: ZERO_ADDRESS,
          id: tokenIds[0],
          value: burnAmounts[0]
        })
      })

      it('check balance', async function () {
        expect(await this.token.balanceOf(operator, tokenIds[0])).to.be.bignumber.equal(mintAmounts[0].sub(burnAmounts[0]));
      })
    })

    describe('burn batch', async function () {
      beforeEach('burn batch', async function () {
        ({ logs: this.logs } = await this.token.burnBatch(operator, tokenIds, burnAmounts))
      })

      it('check log', async function () {
        expectEvent.inLogs(this.logs, 'TransferBatch', {
          operator,
          from: operator,
          to: ZERO_ADDRESS,
          ids: tokenIds,
          values: burnAmounts,
        })
      })

      it('check balance', async function () {
        var operators = tokenIds.map(x => { return operator })
        const result = await this.token.balanceOfBatch(operators, tokenIds)
        expect(result).to.be.an('array');
        for(var i = 0; i < result.length; i++) {
          expect(result[i]).to.be.bignumber.equal(mintAmounts[i].sub(burnAmounts[i]))
        }
      })
    })
  })

  describe('transfer', async function() {
    const tokenIds = [new BN(1990), new BN(1991)]
    const mintAmounts = [new BN(901), new BN(801)]
    const transferAmounts = [new BN(3), new BN(4)]
    const data = '0x123456'

    beforeEach(async function() {
      for(var i = 0; i < tokenIds.length; i++) {
        await this.token.create(tokenIds[i], mintAmounts[i], '', { from: operator })
      }
    })

    describe('safeTransferFrom', async function() {
      beforeEach(async function() {
        ({logs:this.logs} = await this.token.safeTransferFrom(operator, tokenHolder, tokenIds[0], transferAmounts[0], data))
      })

      it('check insufficient balance', async function() {
        await expectRevert(
          this.token.safeTransferFrom(operator, tokenHolder, tokenIds[0], mintAmounts[0], data),
          'KIP37: insufficient balance for transfer')
      })

      it('check logs', async function() {
        expectEvent.inLogs(this.logs, 'TransferSingle', {
          operator,
          from: operator,
          to: tokenHolder,
          id: tokenIds[0],
          value: transferAmounts[0]
        })
      })

      it('check balance', async function() {
        expect(await this.token.balanceOf(operator, tokenIds[0])).to.be.bignumber.equal(mintAmounts[0].sub(transferAmounts[0]));
        expect(await this.token.balanceOf(tokenHolder, tokenIds[0])).to.be.bignumber.equal(transferAmounts[0]);
      })
    })

    describe('safeBatchTransferFrom', async function() {
      beforeEach(async function() {
        ({logs:this.logs} = await this.token.safeBatchTransferFrom(operator, tokenHolder, tokenIds, transferAmounts, data))
      })

      it('check insufficient balance', async function() {
        await expectRevert(
          this.token.safeTransferFrom(operator, tokenHolder, tokenIds[0], mintAmounts[0], data),
          'KIP37: insufficient balance for transfer')
      })

      it('different array length', async function() {
        await expectRevert(
          this.token.safeBatchTransferFrom(operator, tokenHolder, tokenIds, transferAmounts.slice(1), data),
          'KIP37: ids and amounts length mismatch')
      })

      it('unauthorized transfer', async function() {
        await expectRevert(
          this.token.safeBatchTransferFrom(operator, tokenHolder, tokenIds, transferAmounts.slice(1), data, {from: tokenHolder}),
          'KIP37: ids and amounts length mismatch')
      })

      it('check logs', async function() {
        expectEvent.inLogs(this.logs, 'TransferBatch', {
          operator,
          from: operator,
          to: tokenHolder,
          ids: tokenIds,
          values: transferAmounts
        })
      })

      it('check balance of operator', async function() {
        var operators = tokenIds.map(x=>{return operator})
        const result = await this.token.balanceOfBatch(operators, tokenIds)
        expect(result).to.be.an('array');
        for(var i = 0; i < result.length; i++) {
          expect(result[i]).to.be.bignumber.equal(mintAmounts[i].sub(transferAmounts[i]))
        }
      })

      it('check balance of tokenHolder', async function() {
        var operators = tokenIds.map(x=>{return tokenHolder})
        const result = await this.token.balanceOfBatch(operators, tokenIds)
        expect(result).to.be.an('array');
        for(var i = 0; i < result.length; i++) {
          expect(result[i]).to.be.bignumber.equal(transferAmounts[i])
        }
      })
    })

    describe('approval', async function() {
      beforeEach(async function() {
        ({logs:this.logs} = await this.token.setApprovalForAll(tokenHolder, true, {from: operator}))
      })

      it('check logs', async function() {
        expectEvent.inLogs(this.logs, 'ApprovalForAll', {
          account: operator,
          operator: tokenHolder
        })
      })

      it('unauthorized transfer', async function() {
        await expectRevert(
          this.token.safeTransferFrom(operator, tokenHolder, tokenIds[0], transferAmounts[0], data, {from: tokenBatchHolder}),
          'KIP37: caller is not owner nor approved')
      })

      it('authorized transfer', async function() {
        await this.token.safeTransferFrom(operator, tokenHolder, tokenIds[0], transferAmounts[0], data, {from: tokenHolder})

        expect(await this.token.balanceOf(tokenHolder, tokenIds[0])).to.be.bignumber.equal(transferAmounts[0])
      })
    })
  })

  describe('pausible', async function() {
    const tokenId = new BN(1990);
    const tokenIdTwo = new BN(1991);
    const tokenIdThree = new BN(1992);
    const mintAmount = new BN(9001);
    const data = '0x123456'

    beforeEach(async function () {
      ({ logs: this.logs } = await this.token.create(tokenId, mintAmount, '', { from: operator }))
    })

    it('unauthorized pause contract', async function() {
      await expectRevert(
        this.token.methods['pause()']({from: tokenHolder}),
        'PauserRole: caller does not have the Pauser role'
      )
    })

    it('unauthorized pause token', async function() {
      await expectRevert(
        this.token.methods['pause(uint256)'](tokenId, {from: tokenHolder}),
        'PauserRole: caller does not have the Pauser role'
      )
    })

    it('unauthorized unpause contract', async function() {
      await expectRevert(
        this.token.methods['unpause()']({from: tokenHolder}),
        'PauserRole: caller does not have the Pauser role'
      )
    })

    it('unauthorized unpause token', async function() {
      await expectRevert(
        this.token.methods['unpause(uint256)'](tokenId, {from: tokenHolder}),
        'PauserRole: caller does not have the Pauser role'
      )
    })

    it('unpause already unpaused contract', async function() {
      await expectRevert(
        this.token.methods['unpause()'](),
        'Pausable: not paused'
      )
    })

    it('unpause already unpaused token', async function() {
      await expectRevert(
        this.token.methods['unpause(uint256)'](tokenId),
        'KIP37Pausable: already unpaused'
      )
    })

    it('paused must return false', async function() {
      expect(await this.token.methods['paused()']()).to.equal(false)
    })

    describe('pause contract', async function() {
      beforeEach(async function() {
        ({logs:this.logs} = await this.token.methods['pause()']())
      })

      it('check log', async function() {
        expectEvent.inLogs(this.logs, 'Paused', {
          account:operator
        })
      })

      it('pause already paused contract', async function() {
        await expectRevert(
          this.token.methods['pause()'](),
          'Pausable: paused',
        )
      })

      it('paused must return true', async function() {
        expect(await this.token.methods['paused()']()).to.equal(true)
      })

      it('failed to create token', async function() {
        await expectRevert(
          this.token.create(tokenIdTwo, mintAmount, ''),
          'KIP37Pausable: token transfer while paused'
        )
      })

      it('failed to mint token', async function() {
        await expectRevert(
          this.token.methods['mint(uint256,address,uint256)'](tokenId, tokenHolder, mintAmount),
          'KIP37Pausable: token transfer while paused'
        )
      })

      it('failed to burn token', async function() {
        await expectRevert(
          this.token.burn(operator, tokenId, mintAmount),
          'KIP37Pausable: token transfer while paused'
        )
      })

      it('failed to transfer token', async function() {
        await expectRevert(
          this.token.safeTransferFrom(operator, tokenHolder, tokenId, mintAmount, data),
          'KIP37Pausable: token transfer while paused'
        )
      })

      it('failed to batch transfer token', async function() {
        await expectRevert(
          this.token.safeBatchTransferFrom(operator, tokenHolder, [tokenId], [mintAmount], data),
          'KIP37Pausable: token transfer while paused'
        )
      })

      it('approval should work', async function() {
        await this.token.setApprovalForAll(tokenHolder, true, { from: operator })
      })

      describe('unpause', async function() {
        beforeEach(async function() {
          ({logs:this.logs} = await this.token.methods['unpause()']())
        })

        it('check log', async function() {
          expectEvent.inLogs(this.logs, 'Unpaused', {
            account:operator
          })
        })

        it('paused must return false', async function() {
          expect(await this.token.methods['paused()']()).to.equal(false)
        })
      })

    })

    describe('create another token', async function() {
      beforeEach(async function() {
        await this.token.create(tokenIdTwo, mintAmount, '')
      })

      describe('pause token', async function() {
        beforeEach(async function() {
          ({logs:this.logs} = await this.token.methods['pause(uint256)'](tokenId))
        })

        it('check log', async function() {
          expectEvent.inLogs(this.logs, 'Paused', {
            tokenId,
            account:operator
          })
        })

        it('pause already paused token', async function() {
          await expectRevert(
            this.token.methods['pause(uint256)'](tokenId),
            'KIP37Pausable: already paused',
          )
        })

        it('another token can be paused', async function() {
          await this.token.methods['pause(uint256)'](tokenIdTwo)
        })

        it('paused must return true', async function() {
          expect(await this.token.methods['paused(uint256)'](tokenId)).to.equal(true)
        })

        it('able to create token.', async function() {
          await this.token.create(tokenIdThree, mintAmount, '')
        })

        it('failed to mint token', async function() {
          await expectRevert(
            this.token.methods['mint(uint256,address,uint256)'](tokenId, tokenHolder, mintAmount),
            'KIP37Pausable: the token is paused'
          )
        })

        it('able to mint token of tokenIdTwo', async function() {
          await this.token.methods['mint(uint256,address,uint256)'](tokenIdTwo, tokenHolder, mintAmount)
        })

        it('failed to burn token', async function() {
          await expectRevert(
            this.token.burn(operator, tokenId, mintAmount),
            'KIP37Pausable: the token is paused'
          )
        })

        it('able to burn token of tokenIdTwo', async function() {
          await this.token.burn(operator, tokenIdTwo, mintAmount)
        })

        it('failed to transfer token', async function() {
          await expectRevert(
            this.token.safeTransferFrom(operator, tokenHolder, tokenId, mintAmount, data),
            'KIP37Pausable: the token is paused'
          )
        })

        it('able to transfer token of tokenIdTwo', async function() {
          await this.token.safeTransferFrom(operator, tokenHolder, tokenIdTwo, mintAmount, data)
        })

        it('failed to batch transfer token', async function() {
          await expectRevert(
            this.token.safeBatchTransferFrom(operator, tokenHolder, [tokenId], [mintAmount], data),
            'KIP37Pausable: the token is paused'
          )
        })

        it('able to batch transfer token of tokenIdTwo', async function() {
          await this.token.safeBatchTransferFrom(operator, tokenHolder, [tokenIdTwo], [mintAmount], data)
        })

        it('approval should work', async function() {
          await this.token.setApprovalForAll(tokenHolder, true, { from: operator })
        })

        describe('unpause', async function() {
          beforeEach(async function() {
            ({logs:this.logs} = await this.token.methods['unpause(uint256)'](tokenId))
          })

          it('check log', async function() {
            expectEvent.inLogs(this.logs, 'Unpaused', {
              tokenId,
              account:operator,
            })
          })

          it('paused must return false', async function() {
            expect(await this.token.methods['paused(uint256)'](tokenId)).to.equal(false)
          })
        })

      })
      
    })
  })
});
