# react-native-signature-pad

This is a signature pad component for React Native. It only supports iOS for now. The signature curve interpolation algorithm is based on [Smoother Signatures](https://medium.com/square-corner-blog/smoother-signatures-be64515adb33) proposed by [Square](https://squareup.com/), and the implementation heavily references to [signature_pad](https://github.com/szimek/signature_pad)

## Install

```bash
yarn add @envoy/react-native-signature-pad
react-native link @envoy/react-native-signature-pad 
```

## Usage

```TypeScript
import React from 'react'
import { View, Text, TouchableOpacity } from 'react-native'
import SignaturePad from '@envoy/react-native-signature-pad'

export default class MyComponent extends React.Component {
    private pad: SignaturePad

    render () {
        return (
            <View style={{flex: 1}}>
                <SignaturePad
                    style={{width: 600, height: 200}}
                    color='red'
                    onChange={this.onChange}
                    ref={this.onRef}
                />
                <TouchableOpacity onPress={this.onClear}>
                    <Text>Clear</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={this.onCaptureBase64}>
                    <Text>Capture Base64</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={this.onCaptureFile}>
                    <Text>Capture file</Text>
                </TouchableOpacity>
            </View>
        )
    }
    
    private onRef = (ref: any) => {
        this.pad = ref
    }
    
    private onChange = (event: any) => {
        const { count, length } = event.nativeEvent
        console.log('Signature pad update', count, length)
    }
    
    private onClear = () => {
        this.pad.clear()
    }
    
    private onCaptureBase64 = () => {
        this.pad.capture('base64', {})
            .then(data => {
                // handle image data here
            })
    }
    
    private onCaptureFile = () => {
        this.pad.capture('file', { path: '/path/to/file.png' })
            .then(_ => {
                // handle image file here
            })
    }
}
```
