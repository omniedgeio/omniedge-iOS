# OmniEdge iOS

> Bring the intranet on the internet.

[![Build iOS](https://github.com/omniedgeio/omniedge-iOS/actions/workflows/build-ios.yml/badge.svg)](https://github.com/omniedgeio/omniedge-iOS/actions/workflows/build-ios.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)
[![App Store](https://img.shields.io/badge/App_Store-Download-black?style=flat&logo=apple)](https://apps.apple.com/us/app/omniedgenew/id1603005893)

OmniEdge is a cross-platform private network tool for developers, allowing you to access your private servers from anywhere.

<img width="149" alt="OmniEdge iOS App" src="https://user-images.githubusercontent.com/93888/175050671-936ad8d5-60a5-4e3a-917f-794686e67b81.png">

## Changes in v1.0.0

- **Renamed** application from `OmniedgeNew` to `omniedge`.
- **Modernized** codebase with SwiftUI (removed deprecated `edgesIgnoringSafeArea`).
- **Updated** deployment target to iOS 15.0+.
- **Integrated** V2 API with improved stability and performance.
- **Implemented** robust OAuth 2.0 PKCE authentication flow.
- **Added** automated CI/CD for building, testing, and releasing IPAs.

## Getting Started

### For Users
Visit [https://omniedge.io/download](https://omniedge.io/download) to download the app for your platform.

### For Developers

To build the project locally, you will need:
- macOS 14 or later
- Xcode 15.4 or later
- CocoaPods (optional, if required by future dependencies)

#### Build Instructions

1.  Clone the repository with submodules:
    ```bash
    git clone --recursive https://github.com/omniedgeio/omniedge-iOS.git
    cd omniedge-iOS
    ```

2.  Open the workspace:
    ```bash
    open OmniedgeNew/OmniedgeNew.xcworkspace
    ```

3.  Select the **`omniedge`** scheme (formerly `OmniedgeNew`).

4.  Build and Run (`Cmd + R`) on your simulator or device.

**Note**: We recommend compiling components separately if you encounter issues, especially the **Tunnel** package.

## Architecture & Documentation

- [Architecture](/docs/Architecture.md)
- [Network](/docs/Network.md)
- Main Repository: [https://github.com/omniedgeio/omniedge](https://github.com/omniedgeio/omniedge)

## Community

- [Website](https://omniedge.io)
- [Twitter](https://twitter.com/omniedgeio)
- [Discord](https://discord.gg/d4faRPYj)

## Contributing

Please check the `.github` folder for reporting issues or submitting PRs:
1. `ISSUE_TEMPLATE.md`
2. `PULL_REQUEST_TEMPLATE.md`

## Contributors

- @zteshadow

## About Us

[OmniEdge](https://omniedge.io) is primarily developed by the team at [omniedgeio](https://github.com/orgs/omniedgeio/people).
