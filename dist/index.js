"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const react_1 = require("react");
const { RNTSignaturePad } = require('NativeModules');
class SignaturePad extends react_1.default.Component {
    render() {
        // TODO:
        return <RNTSignaturePad />;
    }
}
exports.default = SignaturePad;
