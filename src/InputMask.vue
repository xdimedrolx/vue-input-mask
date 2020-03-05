<template>
    <input
       ref="input"
       @focus="onFocus"
       @blur="onBlur"
       @paste="onPaste"
       @keydown="onKeyDown"
       @input.lazy="onChange"
    />
</template>

<script>
import parseMask from 'react-input-mask/lib/utils/parseMask'
import { isAndroidBrowser, isWindowsPhoneBrowser, isAndroidFirefox } from 'react-input-mask/lib/utils/environment'
import {
    clearRange,
    formatValue,
    getFilledLength,
    isFilled,
    isEmpty,
    isPermanentChar,
    getInsertStringLength,
    insertString
} from 'react-input-mask/lib/utils/string'
import defer from 'react-input-mask/lib/utils/defer'

export default {
  name: 'input-mask',

  props: {
    mask: {
      type: String,
      required: true
    },
    value: {
      type: String,
      default: null
    },
    maskChar: {
      type: String,
      default: void 0
    },
    formatChars: {
      type: Object,
      default: null
    },
    defaultValue: {
      type: [String, Number],
      default: ''
    },
    alwaysShowMask: {
      type: Boolean,
      default: false
    }
  },

  computed: {
    config () {
      return {
        mask: this.mask,
        maskChar: this.maskChar,
        formatChars: this.formatChars,
        defaultValue: this.defaultValue,
        alwaysShowMask: this.alwaysShowMask
      }
    }
  },

  watch: {
    value (newValue, oldValue) {
      if (newValue !== oldValue) {
        let value = formatValue(this.maskOptions, newValue || '')
        if (this.getInputValue() !== value) {
          this.setInputValue(value);
          this.$emit('input', isEmpty(this.maskOptions, this.elValue) ? '' : value)
        }
      }
    },
    config: {
      deep: true,
      handler(newProps, oldProps) {
        this.hasValue = this.value != null;
        this.maskOptions = parseMask(newProps.mask, newProps.maskChar, newProps.formatChars);

        if (!this.maskOptions.mask) {
          this.backspaceOrDeleteRemoval = null;
          this.lastCursorPos = null;
          return;
        }

        var isMaskChanged = this.maskOptions.mask && this.maskOptions.mask !== oldProps.mask;
        var showEmpty = newProps.alwaysShowMask || this.isFocused();
        var newValue = this.hasValue ? this.getStringValue(this.value) : this.value;

        if (!oldProps.mask && !this.hasValue) {
          newValue = this.getInputDOMNode().value;
        }

        if (isMaskChanged || (this.maskOptions.mask && (newValue || showEmpty))) {
          newValue = formatValue(this.maskOptions, newValue);

          if (isMaskChanged) {
            var pos = this.lastCursorPos;
            var filledLen = getFilledLength(this.maskOptions, newValue);
            if (pos === null || filledLen < pos) {
              if (isFilled(this.maskOptions, newValue)) {
                pos = filledLen;
              } else {
                pos = this.getRightEditablePos(filledLen);
              }
              this.setCursorPos(pos);
            }
          }
        }

        if (this.maskOptions.mask && isEmpty(this.maskOptions, newValue) && !showEmpty && (!this.hasValue || !this.value)) {
          newValue = '';
        }

        this.elValue = newValue;

        if (this.elValue !== this.value) {
          this.$emit('input', this.elValue);
        }
      }
    }
  },

  data () {
    return {
      isAndroidBrowser: isAndroidBrowser(),
      isWindowsPhoneBrowser: isWindowsPhoneBrowser(),
      isAndroidFirefox: isAndroidFirefox(),
      lastCursorPos: null,
      backspaceOrDeleteRemoval: null,
      focused: false,
      maskOptions: null,
      hasValue: true,
      elValue: this.value,
      changeTriggered: false
    }
  },

  created () {
    this.hasValue = this.elValue != null;
    this.maskOptions = parseMask(this.mask, this.maskChar, this.formatChars)

    if (this.defaultValue == null) {
      this.defaultValue = '';
    }

    if (this.elValue == null) {
      this.elValue = this.defaultValue;
    }

    this.elValue = this.getStringValue(this.elValue);

    if (this.maskOptions.mask && (this.alwaysShowMask || this.elValue)) {
      this.elValue = formatValue(this.maskOptions, this.elValue);

      if (this.value !== this.elValue) {
        this.$emit('input', this.elValue)
      }
    }
  },

  mounted () {
    this.updateValue()
  },

  beforeUpdate () {
    this.updateValue()
  },

  methods: {
    updateValue() {
      if (this.maskOptions.mask && this.getInputValue() !== this.elValue) {
        this.setInputValue(this.elValue);
      }
    },

    getInputDOMNode () {
      return this.$refs.input;
    },

    getInputValue () {
      var input = this.getInputDOMNode();
      if (!input) {
        return null;
      }

      return input.value;
    },

    setInputValue (value) {
      var input = this.getInputDOMNode();
      if (!input) {
        return;
      }

      this.elValue = value;
      input.value = value;
    },

    getLeftEditablePos (pos) {
      for (var i = pos; i >= 0; --i) {
        if (!isPermanentChar(this.maskOptions, i)) {
          return i;
        }
      }
      return null;
    },

    getRightEditablePos (pos) {
      var { mask } = this.maskOptions;
      for (var i = pos; i < mask.length; ++i) {
        if (!isPermanentChar(this.maskOptions, i)) {
          return i;
        }
      }
      return null;
    },

    setCursorToEnd () {
      var filledLen = getFilledLength(this.maskOptions, this.elValue);
      var pos = this.getRightEditablePos(filledLen);
      if (pos !== null) {
        this.setCursorPos(pos);
      }
    },

    setSelection (start, len = 0) {
      var input = this.getInputDOMNode();
      if (!input) {
        return;
      }

      var end = start + len;
      if ('selectionStart' in input && 'selectionEnd' in input) {
        input.selectionStart = start;
        input.selectionEnd = end;
      } else {
        var range = input.createTextRange();
        range.collapse(true);
        range.moveStart('character', start);
        range.moveEnd('character', end - start);
        range.select();
      }
    },

    getSelection () {
      var input = this.getInputDOMNode();
      var start = 0;
      var end = 0;

      if ('selectionStart' in input && 'selectionEnd' in input) {
        start = input.selectionStart;
        end = input.selectionEnd;
      } else {
        var range = document.selection.createRange();
        if (range.parentElement() === input) {
          start = -range.moveStart('character', -input.value.length);
          end = -range.moveEnd('character', -input.value.length);
        }
      }

      return {
        start: start,
        end: end,
        length: end - start
      };
    },

    getCursorPos () {
      return this.getSelection().start;
    },

    setCursorPos (pos) {
      this.setSelection(pos, 0);

      defer(() => {
        this.setSelection(pos, 0);
      });

      this.lastCursorPos = pos;
    },

    isFocused () {
      return this.focused;
    },

    getStringValue (value) {
      return !value && value !== 0 ? '' : value + '';
    },

    onKeyDown (event) {
      this.backspaceOrDeleteRemoval = null;

      // if (typeof this.props.onKeyDown === 'function') {
      //   this.props.onKeyDown(event);
      // }

      this.$emit('keydown', event)

      var { key, ctrlKey, metaKey, defaultPrevented } = event;
      if (ctrlKey || metaKey || defaultPrevented) {
        return;
      }

      if (key === 'Backspace' || key === 'Delete') {
        var selection = this.getSelection();
        var canRemove = (key === 'Backspace' && selection.end > 0)
          ||
          (key === 'Delete' && this.elValue.length > selection.start);

        if (!canRemove) {
          return;
        }

        this.backspaceOrDeleteRemoval = {
          key: key,
          selection: this.getSelection()
        };
      }
    },

    onChange (event) {
      var { beforePasteState } = this;
      var { mask, maskChar, lastEditablePos, prefix } = this.maskOptions;
      var value = this.getInputValue();
      var changeTriggered = this.changeTriggered

      this.changeTriggered = true

      if (beforePasteState) {
        this.beforePasteState = null;
        this.pasteText(beforePasteState.value, value, beforePasteState.selection, event);
        return;
      }

      var oldValue = this.elValue;
      var input = this.getInputDOMNode();

      // autofill replaces whole value, ignore old one
      // https://github.com/sanniassin/react-input-mask/issues/113
      //
      // input.matches throws exception if selector isn't supported
      try {
        if (typeof input.matches === 'function' && input.matches(':-webkit-autofill')) {
          // oldValue = '';
        }
      } catch (e) {}

      var selection = this.getSelection();
      var cursorPos = selection.end;
      var maskLen = mask.length;
      var valueLen = value.length;
      var oldValueLen = oldValue.length;

      var clearedValue;
      var enteredString;

      if (oldValueLen === 0 && valueLen > 0 && !changeTriggered) {
        this.setInputValue(formatValue(this.maskOptions, value || ''));
        this.$emit('input', value)
        return;
      }

      if (this.backspaceOrDeleteRemoval) {
        var deleteFromRight = this.backspaceOrDeleteRemoval.key === 'Delete';
        value = this.elValue;
        selection = this.backspaceOrDeleteRemoval.selection;
        cursorPos = selection.start;

        this.backspaceOrDeleteRemoval = null;

        if (selection.length) {
          value = clearRange(this.maskOptions, value, selection.start, selection.length);
        } else if (selection.start < prefix.length || (!deleteFromRight && selection.start === prefix.length)) {
          cursorPos = prefix.length;
        } else {
          var editablePos = deleteFromRight
            ? this.getRightEditablePos(cursorPos)
            : this.getLeftEditablePos(cursorPos - 1);

          if (editablePos !== null) {
            if (!maskChar) {
              value = value.substr(0, getFilledLength(this.maskOptions, value));
            }
            value = clearRange(this.maskOptions, value, editablePos, 1);
            cursorPos = editablePos;
          }
        }
      } else if (valueLen > oldValueLen) {
        var enteredStringLen = valueLen - oldValueLen;
        var startPos = selection.end - enteredStringLen;
        enteredString = value.substr(startPos, enteredStringLen);

        if (startPos < lastEditablePos && (enteredStringLen !== 1 || enteredString !== mask[startPos])) {
          cursorPos = this.getRightEditablePos(startPos);
        } else {
          cursorPos = startPos;
        }

        value = value.substr(0, startPos) + value.substr(startPos + enteredStringLen);

        clearedValue = clearRange(this.maskOptions, value, startPos, maskLen - startPos);
        clearedValue = insertString(this.maskOptions, clearedValue, enteredString, cursorPos);

        value = insertString(this.maskOptions, oldValue, enteredString, cursorPos);

        if (enteredStringLen !== 1 || (cursorPos >= prefix.length && cursorPos < lastEditablePos)) {
          cursorPos = Math.max(getFilledLength(this.maskOptions, clearedValue), cursorPos);
          if (cursorPos < lastEditablePos) {
            cursorPos = this.getRightEditablePos(cursorPos);
          }
        } else if (cursorPos < lastEditablePos) {
          cursorPos++;
        }
      } else if (valueLen < oldValueLen) {
        var removedLen = maskLen - valueLen;
        enteredString = value.substr(0, selection.end);
        var clearOnly = enteredString === oldValue.substr(0, selection.end);

        clearedValue = clearRange(this.maskOptions, oldValue, selection.end, removedLen);

        if (maskChar) {
          value = insertString(this.maskOptions, clearedValue, enteredString, 0);
        }

        clearedValue = clearRange(this.maskOptions, clearedValue, selection.end, maskLen - selection.end);
        clearedValue = insertString(this.maskOptions, clearedValue, enteredString, 0);

        if (!clearOnly) {
          cursorPos = Math.max(getFilledLength(this.maskOptions, clearedValue), cursorPos);
          if (cursorPos < lastEditablePos) {
            cursorPos = this.getRightEditablePos(cursorPos);
          }
        } else if (cursorPos < prefix.length) {
          cursorPos = prefix.length;
        }
      }
      value = formatValue(this.maskOptions, value);

      this.setInputValue(value);

      this.$emit('input', value)

      // if (typeof this.props.onChange === 'function') {
      //   this.props.onChange(event);
      // }

      if (this.isWindowsPhoneBrowser) {
        defer(() => {
          this.setSelection(cursorPos, 0);
        });
      } else {
        this.setCursorPos(cursorPos);
      }
    },

    onFocus (event) {
      this.focused = true;

      if (this.maskOptions.mask) {
        if (!this.elValue) {
          var prefix = this.maskOptions.prefix;
          var value = formatValue(this.maskOptions, prefix);
          var inputValue = formatValue(this.maskOptions, value);

          // do not use this.getInputValue and this.setInputValue as this.input
          // can be undefined at this moment if autoFocus attribute is set
          var isInputValueChanged = inputValue !== event.target.value;

          if (isInputValueChanged) {
            event.target.value = inputValue;
          }

          this.elValue = inputValue;

          if (isInputValueChanged) {
            this.$emit('input', value);
          }

          // if (isInputValueChanged && typeof this.props.onChange === 'function') {
          //   this.props.onChange(event);
          // }

          this.setCursorToEnd();
        } else if (getFilledLength(this.maskOptions, this.elValue) < this.maskOptions.mask.length) {
          this.setCursorToEnd();
        }
      }

      // if (typeof this.props.onFocus === 'function') {
      //   this.props.onFocus(event);
      // }

      this.$emit('focus', event)
    },

    onBlur (event) {
      this.focused = false;

      if (this.maskOptions.mask && !this.alwaysShowMask && isEmpty(this.maskOptions, this.elValue)) {
        var inputValue = '';
        var isInputValueChanged = inputValue !== this.getInputValue();

        if (isInputValueChanged) {
          this.setInputValue(inputValue);
          this.$emit('input', inputValue);
        }

        // if (isInputValueChanged && typeof this.props.onChange === 'function') {
        //   this.props.onChange(event);
        // }
      }

      this.$emit('blur', event)
    },

    onPaste (event) {
      this.$emit('paste', event)

      // we need raw pasted text, but event.clipboardData
      // may not work in Android browser, so we clean input
      // to get raw text in onChange handler
      if (!event.defaultPrevented) {
        this.beforePasteState = {
          value: this.getInputValue(),
          selection: this.getSelection()
        };
        this.setInputValue('');
      }
    },

    pasteText (value, text, selection, event) {
      var cursorPos = selection.start;
      if (selection.length) {
        value = clearRange(this.maskOptions, value, cursorPos, selection.length);
      }
      var textLen = getInsertStringLength(this.maskOptions, value, text, cursorPos);
      value = insertString(this.maskOptions, value, text, cursorPos);
      cursorPos += textLen;
      cursorPos = this.getRightEditablePos(cursorPos) || cursorPos;

      this.setInputValue(value);
      if (event) {
        this.$emit('input', value)
        // this.props.onChange(event);
      }

      this.setCursorPos(cursorPos);
    }
  }
}
</script>
