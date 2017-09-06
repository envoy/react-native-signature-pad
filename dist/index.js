var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) if (e.indexOf(p[i]) < 0)
            t[p[i]] = s[p[i]];
    return t;
};
import React from 'react';
import { requireNativeComponent, findNodeHandle, NativeModules, StyleSheet } from 'react-native';
const RCTSignaturePad = requireNativeComponent('RCTSignaturePad');
const defaultStyles = StyleSheet.create({
    main: {
        backgroundColor: 'transparent'
    }
});
export default class SignaturePad extends React.Component {
    constructor() {
        super(...arguments);
        this.onRef = (ref) => {
            this.signaturePad = ref;
        };
    }
    render() {
        const _a = this.props, { style } = _a, props = __rest(_a, ["style"]);
        return (<RCTSignaturePad ref={this.onRef} {...Object.assign({}, props, { style: [defaultStyles.main, style] })}/>);
    }
    /// Clear signature
    clear() {
        const node = findNodeHandle(this.signaturePad);
        const SignaturePadManager = NativeModules.SignaturePadManager;
        SignaturePadManager.clear(node);
    }
    /// Capture signature image
    capture(method, details) {
        const node = findNodeHandle(this.signaturePad);
        const SignaturePadManager = NativeModules.SignaturePadManager;
        return SignaturePadManager.capture(node, method, details);
    }
}
