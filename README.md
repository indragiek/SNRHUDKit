## SNRHUDKit: 100% code-drawn, resolution independent HUD controls for AppKit

`SNRHUDKit` is a framework that brings missing HUD controls and interface elements to AppKit. All of the controls are fully compatible with **OS X 10.6 and 10.7**. Each of the `NSControl` subclasses are completely independent (aside from a few categories) so you are free to pick and choose the controls you need instead of using the entire framework.

## Usage

As of Xcode 4, IBPlugins are no longer supported. Therefore, you will need to either programatically create the controls OR drag out the standard non-HUD version of the control in Interface Builder and change the cell class to the appropriate HUD class provided in `SNRHUDKit`.

## Work in Progress

`SNRHUDKit` is nowhere near complete at this time. The only controls/elements that have been at least partially implemented are:

* Window (`SNRHUDWindow`)
* Segmented control (`SNRHUDSegmentedCell`)
* Text view (`SNRHUDTextView`)
* Rounded and checkbox buttons (`SNRHUDButtonCell`)
* Text field (`SNRHUDTextFieldCell`)

Here's a mockup of what the complete set of elements will look like:

![SNRHUDKit](http://i.imgur.com/MUD9H.png)

## Licensing

`SNRHUDKit` is licensed under the [BSD license](http://www.opensource.org/licenses/bsd-license.php).

### Coded by [Indragie Karunaratne](http://indragie.com) and Designed by [Tyler Murphy](http://twitter.com/tylrmurphy)