'use strict';

module.exports.run = function() {
    let channel = this.roundArguments.channel;
    let contractName = this.roundArguments.contractName;
    let functionName = this.roundArguments.function;
    let args = this.roundArguments.args;

    let promises = [];
    for (let i = 0; i < this.roundArguments.txNumber; i++) {
        promises.push(this.sutAdapter.invokeSmartContract(channel, contractName, functionName, args));
    }
    return Promise.all(promises);
};