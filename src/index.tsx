import React from 'react'
import { requireNativeComponent } from 'react-native'

const RCTSignaturePad = requireNativeComponent('RCTSignaturePad')

export default class SignaturePad extends React.Component {
  render () {
    // TODO:
    return <RCTSignaturePad />
  }
}
