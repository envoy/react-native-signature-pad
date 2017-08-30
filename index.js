/**
 * @providesModule SignaturePad
 * @flow
 */
'use strict';

var NativeSignaturePad = require('NativeModules').SignaturePad;

/**
 * High-level docs for the SignaturePad iOS API can be written here.
 */

var SignaturePad = {
  test: function() {
    NativeSignaturePad.test();
  }
};

module.exports = SignaturePad;
