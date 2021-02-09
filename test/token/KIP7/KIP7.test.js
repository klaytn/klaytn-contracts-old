const { BN, constants, expectEvent } = require('openzeppelin-test-helpers');
const shouldFail = require('../../helpers/shouldFail');
const { ZERO_ADDRESS } = constants;

const {
  shouldBehaveLikeKIP7,
  shouldBehaveLikeKIP7Transfer,
  shouldBehaveLikeKIP7Approve,
} = require('./KIP7.behavior');

const KIP7Mock = artifacts.require('KIP7Mock');

contract('KIP7', function ([_, initialHolder, recipient, anotherAccount]) {
  const initialSupply = new BN(100);

  beforeEach(async function () {
    this.token = await KIP7Mock.new(initialHolder, initialSupply);
  });

  shouldBehaveLikeKIP7('KIP7', initialSupply, initialHolder, recipient, anotherAccount);

  describe('_mint', function () {
    const amount = new BN(50);
    it('rejects a null account', async function () {
      await shouldFail.reverting.withMessage(
        this.token.mint(ZERO_ADDRESS, amount), 'KIP7: mint to the zero address'
      );
    });

    describe('for a non zero account', function () {
      beforeEach('minting', async function () {
        const { logs } = await this.token.mint(recipient, amount);
        this.logs = logs;
      });

      it('increments totalSupply', async function () {
        const expectedSupply = initialSupply.add(amount);
        (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
      });

      it('increments recipient balance', async function () {
        (await this.token.balanceOf(recipient)).should.be.bignumber.equal(amount);
      });

      it('emits Transfer event', async function () {
        const event = expectEvent.inLogs(this.logs, 'Transfer', {
          from: ZERO_ADDRESS,
          to: recipient,
        });

        event.args.value.should.be.bignumber.equal(amount);
      });
    });
  });

  describe('_burn', function () {
    it('rejects a null account', async function () {
      await shouldFail.reverting.withMessage(this.token.burn(ZERO_ADDRESS, new BN(1)),
        'KIP7: burn from the zero address');
    });

    describe('for a non zero account', function () {
      it('rejects burning more than balance', async function () {
        await shouldFail.reverting.withMessage(this.token.burn(
          initialHolder, initialSupply.addn(1)), 'SafeMath: subtraction overflow'
        );
      });

      const describeBurn = function (description, amount) {
        describe(description, function () {
          beforeEach('burning', async function () {
            const { logs } = await this.token.burn(initialHolder, amount);
            this.logs = logs;
          });

          it('decrements totalSupply', async function () {
            const expectedSupply = initialSupply.sub(amount);
            (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
          });

          it('decrements initialHolder balance', async function () {
            const expectedBalance = initialSupply.sub(amount);
            (await this.token.balanceOf(initialHolder)).should.be.bignumber.equal(expectedBalance);
          });

          it('emits Transfer event', async function () {
            const event = expectEvent.inLogs(this.logs, 'Transfer', {
              from: initialHolder,
              to: ZERO_ADDRESS,
            });

            event.args.value.should.be.bignumber.equal(amount);
          });
        });
      };

      describeBurn('for entire balance', initialSupply);
      describeBurn('for less amount than balance', initialSupply.subn(1));
    });
  });

  describe('_burnFrom', function () {
    const allowance = new BN(70);

    const spender = anotherAccount;

    beforeEach('approving', async function () {
      await this.token.approve(spender, allowance, { from: initialHolder });
    });

    it('rejects a null account', async function () {
      await shouldFail.reverting.withMessage(this.token.burnFrom(ZERO_ADDRESS, new BN(1)),
        'KIP7: burn from the zero address'
      );
    });

    describe('for a non zero account', function () {
      it('rejects burning more than allowance', async function () {
        await shouldFail.reverting.withMessage(this.token.burnFrom(initialHolder, allowance.addn(1)),
          'SafeMath: subtraction overflow'
        );
      });

      it('rejects burning more than balance', async function () {
        await shouldFail.reverting.withMessage(this.token.burnFrom(initialHolder, initialSupply.addn(1)),
          'SafeMath: subtraction overflow'
        );
      });

      const describeBurnFrom = function (description, amount) {
        describe(description, function () {
          beforeEach('burning', async function () {
            const { logs } = await this.token.burnFrom(initialHolder, amount, { from: spender });
            this.logs = logs;
          });

          it('decrements totalSupply', async function () {
            const expectedSupply = initialSupply.sub(amount);
            (await this.token.totalSupply()).should.be.bignumber.equal(expectedSupply);
          });

          it('decrements initialHolder balance', async function () {
            const expectedBalance = initialSupply.sub(amount);
            (await this.token.balanceOf(initialHolder)).should.be.bignumber.equal(expectedBalance);
          });

          it('decrements spender allowance', async function () {
            const expectedAllowance = allowance.sub(amount);
            (await this.token.allowance(initialHolder, spender)).should.be.bignumber.equal(expectedAllowance);
          });

          it('emits a Transfer event', async function () {
            const event = expectEvent.inLogs(this.logs, 'Transfer', {
              from: initialHolder,
              to: ZERO_ADDRESS,
            });

            event.args.value.should.be.bignumber.equal(amount);
          });

          it('emits an Approval event', async function () {
            expectEvent.inLogs(this.logs, 'Approval', {
              owner: initialHolder,
              spender: spender,
              value: await this.token.allowance(initialHolder, spender),
            });
          });
        });
      };

      describeBurnFrom('for entire allowance', allowance);
      describeBurnFrom('for less amount than allowance', allowance.subn(1));
    });
  });

  describe('_transfer', function () {
    shouldBehaveLikeKIP7Transfer('KIP7', initialHolder, recipient, initialSupply, function (from, to, amount) {
      return this.token.transferInternal(from, to, amount);
    });

    describe('when the sender is the zero address', function () {
      it('reverts', async function () {
        await shouldFail.reverting.withMessage(this.token.transferInternal(ZERO_ADDRESS, recipient, initialSupply),
          'KIP7: transfer from the zero address'
        );
      });
    });
  });

  describe('_approve', function () {
    shouldBehaveLikeKIP7Approve('KIP7', initialHolder, recipient, initialSupply, function (owner, spender, amount) {
      return this.token.approveInternal(owner, spender, amount);
    });

    describe('when the owner is the zero address', function () {
      it('reverts', async function () {
        await shouldFail.reverting.withMessage(this.token.approveInternal(ZERO_ADDRESS, recipient, initialSupply),
          'KIP7: approve from the zero address'
        );
      });
    });
  });
});
