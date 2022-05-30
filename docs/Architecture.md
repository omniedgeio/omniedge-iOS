#  OmniEdge iOS Application

## Environment Setup

- You can setup the shared githooks like so:
`git config core.hooksPath .githooks`

- You can use some of our custom Xcode template like so:
`./scripts/setup_templates.sh`

- You can setup our common dev tools like so:
`./scripts/setup_swiftlint.sh`

### Swiftlint

This project uses [Swiftlint](https://github.com/realm/SwiftLint) to enforce coding style. 

#### Installation

You will need to have Swiftlint installed on your development machine which can be done by running the script or following the [Swiftlint installation](https://github.com/realm/SwiftLint#installation) instructions.
`./scripts/setup_swiftlint.sh`

### Dependency Management

Our project uses mainly Swift Package Manager.
If a dependency doesn't have SPM - we can consider adding it via Carthage.

####  Setup

1. Make sure an SSH key is setup for github.com/stubhub.  Support can be found here:

    https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account
2. `cd` to the root of your local ios repo, if you're not there already:

    `cd <path-to-your-local-repo>`
      

### Prepare local machine

TBD

## Developer menu

TBD

