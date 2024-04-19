const Counter = artifacts.require('MedicalRecord');
 
module.exports = function (deployer) {
    deployer.deploy(Counter);
};
