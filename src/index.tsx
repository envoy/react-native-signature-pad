import React from 'react'
import {
  requireNativeComponent,
  findNodeHandle,
  NativeModules,
  ViewStyle,
  StyleSheet
} from 'react-native'

const RCTSignaturePad = requireNativeComponent('RCTSignaturePad')
const defaultStyles = StyleSheet.create({
  main: {
    backgroundColor: 'transparent'
  }
})

export interface Props {
  style?: ViewStyle
  /// Color of signature stoke
  color?: string
  /// Lowpass velocity filter factor
  velocityFilterWeight?: number
  /// Minimum stroke width
  minWidth?: number
  /// Maximum stroke width
  maxWidth?: number
  /// The minimum number to be consider too close
  minDistance?: number
  /// Callback block called when signature updated with line count and total
  /// signature length
  onUpdate?: (
    event: {
      nativeEvent: { count: number, length: number, target: number }
    }
  ) => void
}

export default class SignaturePad extends React.Component<Props> {
  private signaturePad: any

  render () {
    const { style, ...props } = this.props
    return (
      <RCTSignaturePad
        ref={this.onRef}
        {...{...props, style: [defaultStyles.main, style]}}
      />
    )
  }

  /// Clear signature
  clear () {
    const node = findNodeHandle(this.signaturePad)
    const SignaturePadManager = (NativeModules as any).SignaturePadManager
    SignaturePadManager.clear(node)
  }

  /// Capture signature image
  capture (
    method: 'base64' | 'file',
    details: { path?: string }
  ): Promise<string | null> {
    const node = findNodeHandle(this.signaturePad)
    const SignaturePadManager = (NativeModules as any).SignaturePadManager
    return SignaturePadManager.capture(node, method, details)
  }

  private onRef = (ref: any) => {
    this.signaturePad = ref
  }
}
