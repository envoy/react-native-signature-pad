# react-native-signature-pad

This is a signature pad component for React Native. It only supports iOS for now. The signature curve interpolation algorithm is based on [Smoother Signatures](https://medium.com/square-corner-blog/smoother-signatures-be64515adb33) proposed by [Square](https://squareup.com/), and the implementation heavily references to [signature_pad](https://github.com/szimek/signature_pad)

## Install

```bash
yarn add @envoy/react-native-signature-pad
```

## Usage

```TypeScript
import React from 'react'
import SignaturePad from '@envoy/react-native-signature-pad'

export default class MyComponent extends React.Component {
    render () {
        return (<SignaturePad />)
    }
}
```
