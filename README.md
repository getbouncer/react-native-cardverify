# Deprecation Notice
Hello from the Stripe (formerly Bouncer) team!

We're excited to provide an update on the state and future of the [Card Scan OCR](https://github.com/stripe/stripe-android/tree/master/stripecardscan) product! As we continue to build into Stripe's ecosystem, we'll be supporting the mission to continuously improve the end customer experience in many of Stripe's core checkout products.

If you are not currently a Stripe user, and interested in learning more about improving checkout experience through Stripe, please let us know and we can connect you with the team.

If you are not currently a Stripe user, and want to continue using the existing SDK, you can do so free of charge. Starting January 1, 2022, we will no longer be charging for use of the existing Bouncer Card Scan OCR SDK. For product support on [Android](https://github.com/stripe/stripe-android/issues) and [iOS](https://github.com/stripe/stripe-ios/issues). For billing support, please email [bouncer-support@stripe.com](mailto:bouncer-support@stripe.com).

For the new product, please visit the [stripe github repository](https://github.com/stripe/stripe-android/tree/master/stripecardscan).

# CardVerify
This repository contains the legacy, deprecated open source code for [CardVerify](https://www.getbouncer.com)'s react-native implementation.

[CardVerify](https://www.getbouncer.com/) is a relatively small library that provides fast and accurate payment card scanning and authenticity verification.

CardVerify is an enterprise library build on the CardScan foundation.

![Android Lint](https://github.com/getbouncer/react-native-cardverify/workflows/Android%20Lint/badge.svg)
![Android Unit Tests](https://github.com/getbouncer/react-native-cardverify/workflows/Android%20Unit%20Tests/badge.svg)
![Release](https://github.com/getbouncer/react-native-cardverify/workflows/Release/badge.svg)
[![GitHub release](https://img.shields.io/github/release/getbouncer/react-native-cardverify.svg?maxAge=60)](https://github.com/getbouncer/react-native-cardverify/releases)

Native libraries for android and iOS are also available through our private repositories. Contact [license@getbouncer.com](mailto:license@getbouncer.com) for access to these libraries.

CardVerify is closed source, and requires a license agreement. See the [license](#license) section for details.

![demo](docs/images/demo.gif)

## Contents
* [Requirements](#requirements)
* [Demo](#demo)
* [Integration](#integration)
* [Customizing](#customizing)
* [Developing](#developing)
* [Troubleshooting](#troubleshooting)
* [Authors](#authors)
* [License](#license)

## Requirements
* Android API level 21 or higher
* iOS version 10 or higher

## Demo
This repository contains a demonstration app for the CardVerify product. To build and run the demo app, follow the instructions in the [example app documentation](https://docs.getbouncer.com/card-verify/react-native-integration-guide#example-app).

## Integration
See the [integration documentation](https://docs.getbouncer.com/card-scan/react-native-integration-guide) in the Bouncer Docs.

### Provisioning an API key
CardVerify requires a valid API key to run. To provision an API key, visit the [Bouncer API console](https://api.getbouncer.com/console). CardVerify requires additional API key permissions to validate cards. Please contact [license@getbouncer.com](mailto:license@getbouncer.com) to get the appropriate permissions added to your API key.

### Name and expiration extraction support (BETA)
To test name and/or expiration extraction, please first provision an API key, then reach out to [support@getbouncer.com](mailto:support@getbouncer.com) with details about your use case and estimated volumes.

Follow the [configuration guide](https://docs.getbouncer.com/card-verify/react-native-integration-guide#configuration) to enable name and expiry extraction support.

## Troubleshooting
See the [troubleshooting page](https://docs.getbouncer.com/card-verify/react-native-integration-guide/troubleshooting) in the Bouncer Docs to check if we have covered common issues.

## Authors
Adam Wushensky, Sam King, and Zain ul Abi Din

## License
This library is available under paid and free licenses. See the [LICENSE](LICENSE) file for the full license text.

### Quick summary
In short, this library will remain free forever for non-commercial applications, but use by commercial applications is limited to 90 days, after which time a licensing agreement is required. We're also adding some legal liability protections.

After this period commercial applications need to convert to a licensing agreement to continue to use this library.
* Details of licensing (pricing, etc) are available at [https://getbouncer.com/pricing](https://getbouncer.com/pricing), or you can contact us at [license@getbouncer.com](mailto:license@getbouncer.com).

### More detailed summary
What's allowed under the license:
* Free use for any app for 90 days (for demos, evaluations, hackathons, etc).
* Contributions (contributors must agree to the [Contributor License Agreement](Contributor%20License%20Agreement))
* Any modifications as needed to work in your app

What's not allowed under the license:
* Commercial applications using the license for longer than 90 days without a license agreement. 
* Using us now in a commercial app today? No worries! Just email [license@getbouncer.com](mailto:license@getbouncer.com) and we’ll get you set up.
* Redistribution under a different license
* Removing attribution
* Modifying logos
* Indemnification: using this free software is ‘at your own risk’, so you can’t sue Bouncer Technologies, Inc. for problems caused by this library

Questions? Concerns? Please email us at [license@getbouncer.com](mailto:license@getbouncer.com) or ask us on [slack](https://getbouncer.slack.com).
