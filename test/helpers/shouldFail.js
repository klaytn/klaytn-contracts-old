const { expect } = require('chai');
var should = require('chai').should();

async function shouldFailWithMessage (promise, message) {
  try {
    await promise;
  } catch (error) {
    if (message) {
      if( error.receipt ) {
        web3.currentProvider.sendAsync({
          method:"debug_traceTransaction",
          params:[error.receipt.transactionHash, {tracer:'revertTracer'}],
          jsonrpc:"2.0",
          id:"123"
        }, function (err, result) {
          expect(result.result).to.include(message, `txHash: ${error.receipt.transactionHash}.`);
        })
      } else if(error.reason) {
        expect(error.reason).to.include(message)
      } else {
        expect.fail('unprocessed error', error)
      }
    }
    return;
  }

  expect.fail('Expected failure not received');
}

async function reverting (promise) {
  await shouldFailWithMessage(promise, 'revert');
}

async function throwing (promise) {
  await shouldFailWithMessage(promise, 'invalid opcode');
}

async function outOfGas (promise) {
  await shouldFailWithMessage(promise, 'out of gas');
}

async function shouldFail (promise) {
  await shouldFailWithMessage(promise);
}

async function withMessage (promise, message) {
  return shouldFailWithMessage(promise, message);
}

shouldFail.reverting = reverting;
shouldFail.reverting.withMessage = withMessage;
shouldFail.throwing = throwing;
shouldFail.outOfGas = outOfGas;

module.exports = shouldFail;
