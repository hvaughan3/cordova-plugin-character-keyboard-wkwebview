# cordova-plugin-character-keyboard-wkwebview

Cordova plugin to show decimal or dash key on the iOS keyboard.

Taken from [mrchandoo's](https://github.com/mrchandoo) repo [cordova-plugin-decimal-keyboard](https://github.com/mrchandoo/cordova-plugin-decimal-keyboard) and merged with [ericdesa](https://github.com/ericdesa) WKWebView fix into [cordova-plugin-decimal-keyboard](https://github.com/john-doherty/cordova-plugin-decimal-keyboard-wkwebview) and further modified before being checked into this repo.

## Install

```bash
cordova plugin add --save https://github.com/hvaughan3/cordova-plugin-character-keyboard-wkwebview
```

## Decimal Usage

```html
<input type="text" pattern="[0-9]*" decimal="true">
```

Input type number will not work, try to use text with [0-9] pattern instead.

## Multiple decimals

```html
<input type="text" pattern="[0-9]*" decimal="true" allow-multiple-decimals="true">
```

### Different decimal character

```html
<input type="text" pattern="[0-9]*" decimal="true" allow-multiple-decimals="false" decimal-char=",">
```

If you want to localize decimal character, you can change using decimal-char attribute

## Dash Usage

```html
<input type="text" pattern="[0-9]*" dash="true">
```

Input type number will not work, try to use text with [0-9] pattern instead.

## Multiple dashes

```html
<input type="text" pattern="[0-9]*" dash="true" allow-multiple-dashes="true">
```

### Different dash character

```html
<input type="text" pattern="[0-9]*" dash="true" allow-multiple-dashes="false" dash-char=",">
```

If you want to localize dash character, you can change using dash-char attribute

## Known Issues
* Does not handle screen rotation.
## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
