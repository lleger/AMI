# AMI

**Note**: This app requires motion sensors, which can't be replicated in the simulator. So, you'll need to build on a device, but you can only do that with an Apple Developer Account.

# Dependencies

To run the app, you'll need the following.

- Xcode 4.6
- iOS 6.0 SDK
- [CocoaPods](http://cocoapods.org) (also requires Ruby)
- iPad with iOS 6.0+

# Arduino

The iPad app communicates with an Arduino. That source in the [AMI-Arduino repo](/lleger/AMI-Arduino).

# Building

To build the app, open [`AMI.xcworkspace`](AMI.xcworkspace) and click "Run" in Xcode. If there are errors about `GCDAsyncSocket` missing, you might need to run `pod install`.
