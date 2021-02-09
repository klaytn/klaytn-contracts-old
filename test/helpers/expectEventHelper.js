const { expect } = require('chai');

function expectEventHelper() {

}

function notExpectEvent (receipt, eventName) {
  if (isWeb3Receipt(receipt)) {
    // We don't need arguments for the assertion, so let's just map it to the expected format.
    const logsWithoutArgs = Object.keys(receipt.events).map(name => {
      return { event: name };
    });
    notInLogs(logsWithoutArgs, eventName);
  } else if (isTruffleReceipt(receipt)) {
    notInLogs(receipt.logs, eventName);
  } else {
    throw new Error('Unknown transaction receipt object');
  }
}
function notInLogs (logs, eventName) {
  // eslint-disable-next-line no-unused-expressions
  expect(logs.find(e => e.event === eventName), `Event ${eventName} was found`).to.be.undefined;
}

async function notInConstruction (contract, eventName) {
  if (!isTruffleContract(contract)) {
    throw new Error('expectEvent.inConstruction is only supported for truffle-contract objects');
  }
  return notInTransaction(contract.transactionHash, contract.constructor, eventName);
}

async function notInTransaction (txHash, emitter, eventName) {
  const receipt = await web3.eth.getTransactionReceipt(txHash);

  const logs = decodeLogs(receipt.logs, emitter, eventName);
  notInLogs(logs, eventName);
}

function isWeb3Receipt (receipt) {
  return 'events' in receipt && typeof receipt.events === 'object';
}

function isTruffleReceipt (receipt) {
  return 'logs' in receipt && typeof receipt.logs === 'object';
}

function isWeb3Contract (contract) {
  return 'options' in contract && typeof contract.options === 'object';
}

function isTruffleContract (contract) {
  return 'abi' in contract && typeof contract.abi === 'object';
}

function decodeLogs (logs, emitter, eventName) {
  let abi;
  let address;
  if (isWeb3Contract(emitter)) {
    abi = emitter.options.jsonInterface;
    address = emitter.options.address;
  } else if (isTruffleContract(emitter)) {
    abi = emitter.abi;
    try {
      address = emitter.address;
    } catch (e) {
      address = null;
    }
  } else {
    throw new Error('Unknown contract object');
  }

  let eventABI = abi.filter(x => x.type === 'event' && x.name === eventName);
  if (eventABI.length === 0) {
    throw new Error(`No ABI entry for event '${eventName}'`);
  } else if (eventABI.length > 1) {
    throw new Error(`Multiple ABI entries for event '${eventName}', only uniquely named events are supported`);
  }

  eventABI = eventABI[0];

  // The first topic will equal the hash of the event signature
  const eventSignature = `${eventName}(${eventABI.inputs.map(input => input.type).join(',')})`;
  const eventTopic = web3.utils.sha3(eventSignature);

  // Only decode events of type 'EventName'
  return logs
    .filter(log => log.topics.length > 0 && log.topics[0] === eventTopic && (!address || log.address === address))
    .map(log => web3.eth.abi.decodeLog(eventABI.inputs, log.data, log.topics.slice(1)))
    .map(decoded => ({ event: eventName, args: decoded }));
}

expectEventHelper.notEmitted = notExpectEvent
expectEventHelper.notEmitted.inConstruction = notInConstruction;
expectEventHelper.notEmitted.inTransaction = notInTransaction;

module.exports = expectEventHelper